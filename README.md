# Datahub Resource Modules

Public repository containing terraform resource modules for Datahub.

## Template Structure

A template directory typically contains the following files:

- `readme.md` - A markdown file containing a description of the template and instructions for using it.
- `<template-name>.variables.tf.json` - A terraform file containing the variables used by only the template.
  > Note: The template variables file should not contain any variables that are used by more than one modules, except for the main resource group module.
- `<template-name>.tf` - A terraform file containing the resources created by the template, usually a reference to a module.
