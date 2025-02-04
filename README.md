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
      PUID: "1000"                       # User ID
      PGID: "1000"                       # Group ID
      TZ: "America/New_York"    
      DEFAULT_WORKSPACE: "/bean"         # Default workspace for code-server 
      BEANCOUNT_FILE: "/bean/main.bean"  # Main beancount file for fava
      PASSWORD_HASH: "$$1$$/ehE7oaa$$5wh58GfqogHQ6H107w64j/""  # Hashed user password
    ports:
      - 2222:2222  # If you don't use VSCode or SSH, you may want to not expose this port
      - 8443:8443  # Port for code-server
      - 5000:5000  # Port for fava
    volumes:
      - path/to/your/beancount/directory:/bean:rw # Directory to your beancount files
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
| `GIT_USER` | Git global config `user.name` will be set to this value if specified. | Not Specified  |
| `GIT_EMAIL` | Git global config `user.email` will be set to this value if specified. | Not Specified  |


## Environment Variables from linuxserver/code-server
| Parameter | Description | Default Value |
| :----: | --- | --- |
| `DEFAULT_WORKSPACE` | Path to the default workspace for code-server. | "/bean" |
| `PUID` | UserID for 'abc' | Not Specified |
| `PGID` | GroupID for 'abc' | Not Specified |
| `TZ` | Timezone | Not Specified |
| `PASSWORD` | Plain password for code-server web UI | Not Specified |
| `HASHED_PASSWORD` | Hashed password for code-server web UI, overrides `PASSWORD` | Not Specified |

>[!NOTE]
>`PASSWORD_HASH` and `HASHED_PASSWORD` are TWO DIFFERENT environment variables, the first one is associated with the password for the built-in user `abc`, the second one is for code-server web UI password.

# Ports

| Port | Service |
| :----: | --- |
| 5000 | fava |
| 2222 | ssh |
| 8443 | code-server |

# Appendix

## Config files for VSCode and/or code-server

Config files of VSCode and code-server are stored in the `/config/.vscode-server/` and `/config` respectively. You may want to use docker volumes to supply your own config directory.

Sample config snippet:
```yaml

 # ...
    volumes:
      - /path/to/code-server/config:/config:rw
```

## Working with git remote repository

If you use git to manage your beancount file(s). You may want to set the environment variable `GIT_USER` and `GIT_EMAIL` to allow git command to work properly.

If you are working with remote repositories. You may want to use docker volumes to place approperate ssh key files for user `abc` under the `/config/.ssh/` directory, so that `git push` command can find and use the correct ssh key.

Sample config snippet:
```yaml

 # ...
    volumes:
      - /home/user_name/.ssh/id_rsa:/config/.ssh/id_rsa:ro
      - /home/user_name/.ssh/id_rsa.pub:/config/.ssh/id_rsa.pub:ro
```

## Working with VSCode

### SSH configuration

If you want to edit your beancount file using VSCode from a remote machine, you will need to expose the port `2222` of the docker container to accept incoming ssh connection.

Then, use the following configuration when connecting to the docker through ssh:

| Item | Value |
| :----: | --- |
| User | abc |
| Port | 2222 |
| Password | See document for env 'PASSWORD_HASH' |

### Pinning host fingerprint

Every time the container gets recreated, its host fingerprint for ssh connection will change. This may cause your SSH client to complain or even refuse to connect.

You can use docker volumes to supply `ssh host key files` under directory `/etc/ssh/`.

Sample config snippet:
```yaml

 # ...
    volumes:
      - ./path/to/ssh/host/keys/ssh_host_ecdsa_key:/etc/ssh/ssh_host_ecdsa_key:ro
      - ./path/to/ssh/host/keys/ssh_host_ecdsa_key.pub:/etc/ssh/ssh_host_ecdsa_key.pub:ro
      - ./path/to/ssh/host/keys/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key:ro
      - ./path/to/ssh/host/keys/ssh_host_ed25519_key.pub:/etc/ssh/ssh_host_ed25519_key.pub:ro
      - ./path/to/ssh/host/keys/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key:ro
      - ./path/to/ssh/host/keys/ssh_host_rsa_key.pub:/etc/ssh/ssh_host_rsa_key.pub:ro
```

### python3 path for the beancount Extension

If you want to use the `beancount` extension for VSCode, you may want to set the python3 path to `/config/.local/share/pipx/venvs/beancount/bin/python3`. This the path to the virtual environment where beancount is installed.
