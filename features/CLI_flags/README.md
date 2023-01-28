# extra_arguments blocks
特定のterraformコマンドに引数を自動でつけてくれるよ。というイメージ。  
`terraform`ブロックに複数の`extra_arguments`を指定できる。

# Required and optional var-files
一般的なユースケースとして、var-file(.tfvars)がある。  
`extra_arguments`のvar-fileには、`required_var_files`と`optional_var_files`が存在している。違いは指定したファイルが見つからない場合、`required_var_files`はエラーを発生させること。