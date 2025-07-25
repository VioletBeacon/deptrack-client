# VioletBeacon Dependency-Track Client

A command-line Dependency-Track client that is primarily useful for CI/CD environments.

GitHub: https://github.com/VioletBeacon/deptrack-client

PyPI: https://pypi.org/project/violetbeacon-deptrack-client

## Installation

```bash
pip install violetbeacon-deptrack-client
```

This will install the deptrack-client cli into your Python environment.

## Usage

Use the `-h` option to display usage options.

```bash
$ deptrack-client -h
usage: deptrack-client [-h] {version,create-config,upload-bom} ...

Dependency-Track Client

positional arguments:
  {version,create-config,upload-bom}
                        Commands
    version             Print version information
    create-config       Create configuration file
    upload-bom          Upload BOM

options:
  -h, --help            show this help message and exit
```

### Create a configuation file (optional)

```bash
$ deptrack-client create-config -h
usage: deptrack-client create-config [-h] [-v] -c CONFIG [-H DTRACK_BASEURL] [-A API_KEY] [-a]
                                     -p PROJECT_NAME -q PROJECT_VERSION

options:
  -h, --help            show this help message and exit
  -v                    Increase logging verbosity. Can be provided multiple times.
  -c, --config CONFIG   Path to configuration file. Default: deptrack-client.yaml
  -H, --dtrack-baseurl DTRACK_BASEURL
                        Base URL of Dependency-Track API instance (excluding /api/v1/...). If
                        prefixed with `env:` this is the name of the environment variable which
                        contains the hostname. Default=env:DTRACK_BASEURL
  -A, --api-key API_KEY
                        API key for the Dependency-Track API. If prefixed with `env:` this is the
                        name of the environment variable which contains the API key.
                        Default=env:DTRACK_APIKEY
  -a, --autocreate      Tell Dependency-Track to autocreate the project if it does not exist
  -p, --project-name PROJECT_NAME
                        Project name
  -q, --project-version PROJECT_VERSION
                        Project ID
```

Example:

```bash
$ deptrack-client create-config -H https://my-dependency-track-instance 
```


### Upload a BOM file to Dependency-Track

```bash
$ deptrack-client upload-bom --help
usage: deptrack-client upload-bom [-h] [-v] [-c CONFIG] [-H DTRACK_BASEURL] [-A API_KEY] [-a]
                                  -p PROJECT_NAME -q PROJECT_VERSION -f BOM_FILE

options:
  -h, --help            show this help message and exit
  -v                    Increase logging verbosity. Can be provided multiple times.
  -c, --config CONFIG   Path to configuration file. Default: deptrack-client.yaml
  -H, --dtrack-baseurl DTRACK_BASEURL
                        Base URL of Dependency-Track API instance (excluding /api/v1/...). If
                        prefixed with `env:` this is the name of the environment variable which
                        contains the hostname. Default=env:DTRACK_BASEURL
  -A, --api-key API_KEY
                        API key for the Dependency-Track API. If prefixed with `env:` this is the
                        name of the environment variable which contains the API key.
                        Default=env:DTRACK_APIKEY
  -a, --autocreate      Autocreate the project if it does not exist
  -p, --project-name PROJECT_NAME
                        Project name
  -q, --project-version PROJECT_VERSION
                        Project ID
  -f, --bom-file BOM_FILE
                        Path to BOM file
```

Example (**Note**: this is not best practice since it will put the API key in the bash history):

```bash:
$ deptrack-client upload-bom -A odt_... -H https://my-dependency-track-instance -a -p ${PROJECT} -q ${VERSION} -f bom.json
```

Following is a typical CI/CD example where secrets are injected into the build environment via environment variables:

The default value for the `-A | --api-key` parameter is `env:DTRACK_APIKEY`, which tells the client to pull the API key from the environment variable named `DTRACK_APIKEY`.

The default value for the `-H | --dtrack-baseurl` parameters is `env:DTRACK_BASEURL`, which tells the client to pull the base URL from the environment variable named `DTRACK_BASEURL`.

You can modify these parameters by setting `-A env:<APIKEY_VARNAME>` and `-H env:<URL_VARNAME>` options.

```bash:
# Prerequisites
# 1. The API key is set in the DTRACK_APIKEY environment variable
# 2. The Base URL is set in the DTRACK_BASEURL environment variable
$ deptrack-client upload-bom -a -p ${PROJECT} -q ${VERSION} -f bom.json
```

## Development

See [DEVELOPMENT.md](./DEVELOPMENT.md).
