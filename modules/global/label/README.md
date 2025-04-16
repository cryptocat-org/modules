# Common Label / Tags

This module designed to generate consistent names and tags for resources. Use this to implement a strict naming convention.

Module generates IDs using the following convention:
`{environment}-{namespace}-{region}-{name}`

# Using this module

* Add context from `exports/context.tf` to your module as a **symlink**. It contains this module and variables.

* Add `label` module to your module

```
module "label" {
  source  = "git::ssh://git@github.com/coingaming/infra-modules.git?ref=modules/global/label/v1.0.0"
  context = module.this.context
}
```

* Use `label` module. For example for resource name and tags

```
name = module.label.id
tags = module.label.tags
```



