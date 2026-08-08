# Index lifecycle for the logging indices.
#
# Three pieces that only work together:
#   1. an ISM policy describing rollover/retention,
#   2. a composable index template that stamps the rollover alias (and shard
#      counts) onto every index matching the pattern,
#   3. a bootstrap index carrying the write alias, so the very first rollover
#      has something to roll over from.
#
# Without (3) the policy attaches but never fires, because ISM rollover needs an
# index that already holds the alias as its write index.

resource "opensearch_ism_policy" "retention" {
  policy_id = var.ism_policy_id
  body      = var.ism_policy_body
}

# The body uses top-level index_patterns with a nested "template" block, which is
# the composable (_index_template) format, not the legacy _template one.
resource "opensearch_composable_index_template" "logging" {
  name = var.index_template_name
  body = var.index_template_body
}

# Created only if absent. ISM takes over rollover from here, so Terraform must
# not fight it over settings that ISM changes after creation.
resource "opensearch_index" "bootstrap" {
  name               = var.bootstrap_index_name
  number_of_shards   = var.bootstrap_number_of_shards
  number_of_replicas = var.bootstrap_number_of_replicas

  aliases = jsonencode({
    (var.rollover_alias) = {
      is_write_index = true
    }
  })

  # The template must exist first, or the bootstrap index is created without the
  # rollover alias setting and ISM cannot roll it over.
  depends_on = [opensearch_composable_index_template.logging]

  lifecycle {
    ignore_changes = [
      # ISM renames/rolls indices and moves the write alias. Reconciling these
      # would make every apply want to undo whatever ISM last did.
      aliases,
      number_of_replicas,
    ]
  }
}
