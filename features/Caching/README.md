# Clearing the Terragrunt cache
terragruntは`.terragrunt-cache`というディレクトリを作成します。  
`terragrunt run-all apply`コマンドを実行後、このディレクトリをクリアしたい場合、以下のコマンドを実行できます。  


### Mac and Linux
探索コマンド
```
find . -type d -name ".terragrunt-cache"
```
削除コマンド
```
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```

環境変数`TERRAGRUNT_DOWNLOAD`を使用してキャッシュされるディレクトリを指定できます。