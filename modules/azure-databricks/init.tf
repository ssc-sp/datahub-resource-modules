resource "databricks_workspace_file" "init_script_geo" {
  content_base64 = base64encode(<<-EOT
    #!/bin/bash
    /databricks/python/bin/pip install databricks-mosaic
    EOT
  )
  path = "/init-geo.sh"
}
