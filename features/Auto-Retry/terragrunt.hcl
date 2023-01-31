terraform{
  retryable_errors = [
    "a regex to match the error",
    "another regex"
  ]

  retry_max_attempts = 5
  retry_sleep_interval_sec = 60
}