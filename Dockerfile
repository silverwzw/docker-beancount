FROM linuxserver/code-server
RUN \
  apt-get update && \
  apt-get install -y python3 pipx git openssh-server && \
  apt-get clean && \
  pipx ensurepath && \
  pipx install beancount && \
  pipx install fava && \
  pipx ensurepath && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* && \
  mkdir /custom-services.d && \
  mkdir -p --mode=700 /config/data/Machine && chmod 755 /config/data && \
  usermod --shell /bin/bash abc && \
  echo "Port 2222" >> /etc/ssh/sshd_config && \
  echo "AllowUsers abc" >> /etc/ssh/sshd_config && \
  /app/code-server/bin/code-server --extensions-dir /config/extensions \
    --install-extension dongfg.vscode-beancount-formatter \
    --install-extension lencerf.beancount

COPY ./build-data/start_fava /custom-services.d/start_fava
COPY ./build-data/start_ssh /custom-services.d/start_ssh
COPY ./build-data/set_passwd /custom-services.d/set_passwd
COPY ./build-data/settings.json /config/data/Machine/settings.json

RUN chown root:root /custom-services.d/start_fava /custom-services.d/start_ssh /custom-services.d/start_ssh && \
    chown abc:users /config/data &&  chown abc:users /config/data/Machine && chown abc:users /config/data/Machine/settings.json

EXPOSE 8443
EXPOSE 5000
EXPOSE 2222

ENV BEANCOUNT_FILE="/bean/main.bean"
ENV FAVA_HOST="0.0.0.0"
ENV PATH="$PATH:/config/.local/bin"
ENV DEFAULT_WORKSPACE="/bean"
ENV PASSWORD_HASH="\$1\$/ehE7oaa\$5wh58GfqogHQ6H107w64j/"
