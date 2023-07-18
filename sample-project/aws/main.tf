data "aws_caller_identity" "current" {}

module "project" {
  source     = "./project"
  project_cd = "sw3"
}


module "s3" {
  source          = "./s3"
  project_cd      = "sw3"
  project_key_arn = module.project.aws_project_key_arn
}
