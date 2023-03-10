# terraformバックエンド
ルートの`terragrunt.hcl`に`remote_state`を定義して、自動でバックエンドを構成できる。バックエンドストレージが存在しない場合、自動生成します。

## バックエンドs3の設定
以下の様な設定を使える。[参考](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#remote_state)
```
remote_state {
  # ...

  config = {
    skip_bucket_versioning         = true # use only if the object store does not support versioning
    skip_bucket_ssencryption       = true # use only if non-encrypted Terraform State is required and/or the object store does not support server-side encryption
    skip_bucket_root_access        = true # use only if the AWS account root user should not have access to the remote state bucket for some reason
    skip_bucket_enforced_tls       = true # use only if you need to access the S3 bucket without TLS being enforced
    enable_lock_table_ssencryption = true # use only if non-encrypted DynamoDB Lock Table for the Terraform State is required and/or the NoSQL database service does not support server-side encryption
    accesslogging_bucket_name      = <string> # use only if you need server access logging to be enabled for your terraform state S3 bucket. Provide a <string> value representing the name of the target bucket to be used for logs output.
    accesslogging_target_prefix    = <string> # use only if you want to set a specific prefix for your terraform state S3 bucket access logs when Server Access Logging is enabled. Provide a <string> value representing the TargetPrefix to be used for the logs output objects. If set to empty <string>, then TargetPrefix will be set to empty <string>. If attribute is not provided at all, then TargetPrefix will be set to default value `TFStateLogs/`.

    shared_credentials_file     = "/path/to/credentials/file"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```