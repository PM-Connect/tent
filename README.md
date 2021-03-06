# Tent [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=master)](https://travis-ci.org/PM-Connect/tent) [![Go Report Card](https://goreportcard.com/badge/github.com/pm-connect/tent)](https://goreportcard.com/report/github.com/pm-connect/tent)

A simple tool to manage builds and deployments when using [Nomad](https://nomadproject.io) and Docker. (Although docker is optional!)

1. [Features](#features)
2. [Configuration](#configuration)
    1. [Reference](#reference)
    2. [Examples](#examples)
3. [Nomad](#nomad)
4. [Commands](#commands)
    1. [Build](#build)
    2. [Deploy](#deploy)
    3. [Destroy](#destroy)
5. [Upcomming Features](#upcomming_features)

## Features

- Simple YAML configuration
    - Environment variable interpolation within config
    - Sensible defaults assumed for nearly all config properties
- Concurrent processing
    - Run up to 5 build tasks at once
    - Run up to 5 deployment tasks at once
- Build Docker images ready for deployment
    - Tagging of images
    - Pushing built images to custom registries
- Run custom build scripts instead of docker
- Deploy the build Docker images
    - Docker images can be injected into a `*.nomad` file using Tent variables
- Supports multiple environments (eg, staging/production)
- Handles cases where the nomad file and group counts within may be out of sync with the running job

## Configuration

Configuration is done in a `tent.yaml` file within the root of your project.

### Reference

Most config variables support environment variable interpolation. This can be done using the following format:

```
// Outputs the value of $MY_VARIABLE or an empty string
${MY_VARIABLE}
```

Defaults are also supported using the following format:

```
// Outputs "default-value"
${MY_VARIABLE:-default_value}
```

Any config values that support environment variable interpolation are marked below.

```yaml
# (Required) Specify the name of your service.
# - Must only contain lowercase alpha characters (a-z) and hyphens (-)
# - Available as `[!name!]` within a nomad file.
# - Supports environment variable interpolation.
name: my-service

# Enable running multiple builds/deployments/destructions at the same time.
concurrent: true

# Setup specific config for different environments.
# These environments can be specified when passing in the -env flag to the
# deploy or destroy commands.
#
# Has no effect in build.
environments:

  # Repeat enviroment config as many times as desired.
  staging:

    # (Required) The URL to the nomad server to use.
    # - Supports environment variable interpolation.
    nomad_url: https://example.com/

    # (Optional) Any variables to make available when parsing the nomad file.
    # Default: 
    variables:

      # A variable that can be used within a nomad file.
      # The below variable would be available as so: `[!env_my_variable!]`
      # - Supports environment variable interpolation.
      my_variable: test

  production:

    # (Required) The URL to the nomad server to use.
    # - Supports environment variable interpolation.
    nomad_url: https://example.com/

# Configure the deployments to be run.
#
# Minimal config:
# deployments:
#   my-app:
#     nomad_file: example.nomad
#
# Minimal config with builds:
# deployments:
#   my-app:
#     nomad_file: example.nomad
#     builds:
#       my-build:
#         name: image_name
#         tags:
#           - my-tag
#         push: true
#         deploy_tag: my-tag
deployments:

  # The name of the deployment.
  # Available as `[!deployment_name!]` within a nomad file.
  app:

    # Builds for this deployment.
    builds:

      # The name of the build.
      web:

        # (Optional) The docker context to use.
        # Default: .
        context: .

        # (Optional) The path to the dockerfile to use.
        # Default: Dockerfile
        file: example.Dockerfile

        # (Optional) The docker registry url to use.
        # - Supports environment variable interpolation.
        # - Should NOT include the protocol.
        # Default: <none>
        registry_url: example.com

        # The name of the docker image.
        # - Supports environment variable interpolation.
        name: tent

        # (Optional) Any tags to apply to the image. (Should NOT contain the image name or registry!)
        # - Supports environment variable interpolation.
        # Default: [latest]
        tags:
          - my-tag
          - latest

        # (Optional) Should the tags be pushed to the registry?
        # Default: false
        push: true

        # (Optional) The dockerfile multi-stage target.
        # - Supports environment variable interpolation.
        # Default: <none>
        target: production
        
        # (Optional) The dockerfile build arguments.
        # - Supports environment variable interpolation.
        # Default: <none>
        build_args:
          arg: value

        # The tag to use when generating the image url/name to use in the nomad file.
        # The generated/built image (eg, 240422614719.dkr.ecr.eu-west-1.amazonaws.com/tent:my-tag)
        # is available as `[!image_{build_name}!]` within a nomad file, where {build_name}
        # is the name of the build.
        #
        # In this example, {build_name} would be web, giving `[!image_web!]` as the variable.
        #
        # - Supports environment variable interpolation.
        # Default: latest
        deploy_tag: my-tag

    # (Optional) The path to the nomad file to use.
    # - Supports environment variable interpolation.
    # Default: Defaults to the `name` property from the root of this configuration concatenated with the name of the deployment.
    # In this example. The default would be `my-service-web.nomad`
    nomad_file: my-service.nomad

    # (Optional) The number of instances to start if no currently running job is found.
    # Default: 2
    start_instances: 2

    # (Optional) Only to be used if the job name is hard coded within the nomad file. (job "my-name-here" { ... })
    # - Supports environment variable interpolation.
    # Default: <none>
    service_name: my-service

    # (Optional) Any variables to make available when parsing the nomad file.
    # Default: <none>
    variables:
      # A variable that can be used within a nomad file.
      # The below variable would be available as so: `[!var_some_variable!]`
      # - Supports environment variable interpolation.
      some_variable: example
```

## Examples

### Minimal Configuration (With Builds)

```yaml
name: test

environments:

  production:
    nomad_url: http://example.com/

deployments:

  web:
    builds:
      app:
        push: true
    
```

### Minimal Configuration (Without Builds)

```yaml
name: test

  environments:

    production:
      nomad_url: http://example.com/

  deployments:
  
    web:
```

## Nomad

Tent is built to work seamlessly with Nomad and the way Nomad handles deployments.

Out of the box, Tent will deploy a `*.nomad` file to nomad and monitor the deployment until success or failure.

### Nomad File Variables

Tent will replace certain variables found within a nomad file with their computed value.

**Any variables that can not be found will be replaced with an empty string!**

Available Variables:

- `[!name!]`
    - This is the `name` property from the yaml config.
- `[!deployment_name!]`
    - This is the name of the currently running deployment from the yaml config.
- `[!job_name!]`
    - This is either the `service_name` property from the yaml config for the running deployment, or the combination of the `name` property and the currently running deployment name from the yaml config.
- `[!image_{build_name}!]`
    - This is the generated docker image name, where `{bulild_name}` is replaced with the name of the build within the currently running deployment.
- `[!group_{task_group}_size!]`
    - This is the current size of the `Task Group` if the job is already running in nomad. This will be the same as the group name in your `.nomad` file. If you use the `[!deployment_name!]` variable for your nomad group you may use `[!group_size!]` to retrieve the value.
    - If there is no job running, this will be replaced with `2`.
- `[!env_{var_name}!]`
    - You can use any variable defined within the `variables` map of an environment configuration using this syntax.
- `[!var_{var_name}!]`
    - You can use any variable defined within the `variables` map of a deployment using this syntax.

## Commands

```text
Usage: tent [-version] [-help] [-verbose] [-autocomplete-(un)install] <command> [args]

Common commands:
    build        Build the project according to the config.
    deploy       Deploy the project according to the config.
    destroy      Destroy the project according to the config.
```

The `-verbose` option may be provided to **ANY** command.

### Build

The build command is responsible for running the build configuration for each configured deployment.

If `concurrent` is set to `true`, up to 5 builds will be run at once.

```text
Usage: tent build

    Build is used to build the project ready for deployment.

General Options:

    -verbose
        Enables verbose logging.
```

### Deploy

The deploy command is responsible for deploying the configured setup and `.nomad` file to Nomad, and monitoring the deploment until completion.

If `concurrent` is set to `true`, up to 5 deployments will be run at once.

```text
Usage: tent deploy [-env=]

    Deploy is used to build the project ready for deployment.

    -env=
        Specify the environment configuration to use.

General Options:

    -verbose
        Enables verbose logging.
```

### Destroy

The deploy command is responsible for bringing down any currently running deployments.

If `concurrent` is set to `true`, up to 5 destructions will be run at once.

```text
Usage: tent destroy [-env=] [-purge] [-force]

    Destroy is used to build the project ready for deployment.

    -purge
        Forces garbage collection of the job within nomad.
    -env=
        Specify the environment configuration to use.

General Options:

    -verbose
        Enables verbose logging.
```

## Upcomming Features

The following features will be added in later releases, in no particular order.

- A `rollback` command to rollback to the last (or a given) nomad version.
- Ability to automatically rollback all defined deployments on a single deployment failure.
- Enable generation of a nomad file.
- Allow configuration of max concurrent jobs in yaml config file.
