dependencies {
  paths = ["../vpc", "../mysql", "../redis"]
}
inputs = {
  mysql_url = dependency.mysql.outputs.domain
  redis_url = dependency.redis.outputs.domain
}