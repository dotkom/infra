resource "google_pubsub_topic" "this" {
  name = var.gcloud_pubsub_topic_name
  message_retention_duration = "86600s"
}

# grant gmail api service account permission to publish to this topic
resource "google_pubsub_topic_iam_member" "gmail" {
  topic = google_pubsub_topic.this.name
  role  = "roles/pubsub.publisher"
  member = "serviceAccount:gmail-api-push@system.gserviceaccount.com"
}

resource "google_pubsub_subscription" "this" {
  name  = var.gcloud_pubsub_subscription_name
  topic = google_pubsub_topic.this.id

  ack_deadline_seconds = 20

  retry_policy {
    minimum_backoff = "600s" # if the push endpoint is down, the subscription will retry every 10 minutes instead of constantly retrying
  }

  enable_message_ordering    = false

  push_config {
    push_endpoint = var.gcloud_push_endpoint

    attributes = {
      x-goog-version = "v1"
    }
  }
}
