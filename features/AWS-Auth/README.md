# AWS credentials
terragruntは[AWS SDK for Go](https://aws.amazon.com/sdk-for-go/)を使用しているため、[AWSの標準的なアプローチ](https://aws.amazon.com/blogs/security/a-new-and-standardized-way-to-manage-credentials-in-the-aws-sdks/)で自動的にロードされます。

# AWS IAM policies
remote stateのS3, DynamoDBへのアクセス許可を以下の様に構成することが必要になります。  
アカウントIDとバケットを正しいものに置き換える必要があります。
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllDynamoDBActionsOnAllTerragruntTables",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": [
                "arn:aws:dynamodb:*:1234567890:table/terragrunt*"
            ]
        },
        {
            "Sid": "AllowAllS3ActionsOnTerragruntBuckets",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::terragrunt*",
                "arn:aws:s3:::terragrunt*/*"
            ]
        }
    ]
}
```

## 最小権限
`BUCKET_NAME`と`TABLE_NAME`を置き換える必要があります。
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCreateAndListS3ActionsOnSpecifiedTerragruntBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketVersioning",
                "s3:GetObject",
                "s3:GetBucketAcl",
                "s3:GetBucketLogging",
                "s3:CreateBucket",
                "s3:PutObject",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutBucketTagging",
                "s3:PutBucketPolicy",
                "s3:PutBucketVersioning",
                "s3:PutEncryptionConfiguration",
                "s3:PutBucketAcl",
                "s3:PutBucketLogging",
                "s3:GetEncryptionConfiguration",
                "s3:GetBucketPolicy",
                "s3:GetBucketPublicAccessBlock",
                "s3:PutLifecycleConfiguration"
            ],
            "Resource": "arn:aws:s3:::BUCKET_NAME"
        },
        {
            "Sid": "AllowGetAndPutS3ActionsOnSpecifiedTerragruntBucketPath",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::BUCKET_NAME/some/path/here"
        },
        {
            "Sid": "AllowCreateAndUpdateDynamoDBActionsOnSpecifiedTerragruntTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:CreateTable"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/TABLE_NAME"
        }
    ]
}
```

## 外部S3
外部で作成されたS3にのみ権限を与えたい場合は以下の様になります。  
また、`skip_bucket_versioning`をtrueにする必要があります。(バケットの所有者のみがステータスを確認できる)
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetBucketLocation",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::<BucketName>"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<BucketName>/\*"
            ],
            "Effect": "Allow"
        }
    ]
}
```