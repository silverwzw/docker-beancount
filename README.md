# silverwzw/docker-beancount

silverwzw/docker-beancount is a repository for the Dockerfile of silverwzw/beancount-server

# silverwzw/beancount-server

silverwzw/docker-beancount is a docker image for beancount users. The image has the following service/binary installed:

| Name | Explanation |
| :----: | --- |
| beancount | The beancount executable. |
| fava | The offical beancount Web UI. |
| code-server | Web-based editor with `Beancount` and `Beancount Formatter` extension installed. |
| openssh-server | Provides ssh service for VSCode remote to edit the beancount files. |
| python3 | Execution environment for beancount plugins. |

This docker image is based on linuxserver/code-server

# Usage

Sample docker compose config:

```yaml
services:
 beancount-server:
    container_name: beancount-server
    image: silverwzw/beancount-server
    hostname: bean
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: "America/New_York"
      DEFAULT_WORKSPACE: "/bean"
      BEANCOUNT_FILE: "/bean/main.bean"
      PASSWORD_HASH: "$$1$$/ehE7oaa$$5wh58GfqogHQ6H107w64j/""
    ports:
      - 2222:2222
      - 8443:8443
      - 5000:5000
    volumes:
      - path/to/your/beancount/directory:/bean:rw
    restart: unless-stopped
```

>[!NOTE]
>Your can use `openssl passwd -1 <your_password>` to generate hashed password. Symbol `$` needs to be escaped by `$$`.


# The built-in user

Name of the built-in user is `abc`. This is the user that runs code-server and have ssh access.

Default password for this user is also `abc`. Password can be changed by specifing the `PASSWORD_HASH` env variable.

The `GroupID` and `UserID` of this user must be specified using the `PUID` and `PGID` env variables. Tip: Set the UserID to the owner of your exisiting beancount files.

# Environment Variables

| Parameter | Description | Default Value |
| :----: | --- | --- |
| `BEANCOUNT_FILE` | Path to the beancount file. | "/bean/main.bean" |
| `PASSWORD_HASH` | Hashed password for user 'abc'. | "$1$/ehE7oaa$5wh58GfqogHQ6H107w64j/" |


## Environment Variables from linuxserver/code-server
| Parameter | Description | Default Value |
| :----: | --- | --- |
| `DEFAULT_WORKSPACE` | Path to the default workspace for code-server. | "/bean" |
| `PUID` | UserID for 'abc' | REQUIRED |
| `PGID` | GroupID for 'abc' | REQUIRED |
| `TZ` | Timezone | REQUIRED |
| `PASSWORD` | Plain password for code-server web UI | Not Specified |
| `HASHED_PASSWORD` | Hashed password for code-server web UI, overrides `PASSWORD` | Not Specified |

# Ports

| Port | Service | 
| :----: | --- |
| 5000 | fava |
| 2222 | ssh |
| 8443 | code-server |
