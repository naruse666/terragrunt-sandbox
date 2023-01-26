# get_terragrunt_dir関数
`get_terragrunt_dir()`は`path.module`のようにカレントディレクトリを取得する。
[Documentation](https://terragrunt.gruntwork.io/docs/reference/built-in-functions/#get_terragrunt_dir)

# プライベートGitリポジトリの参照
`terraform`ブロックの`source`に`git::ssh://`を使用してプライベートリポジトリを参照できる。  
だが、`ssh -T -oStrictHostKeyChecking=accept-new git@github.com || true`を実行してsshホストの登録を確認する必要がある。