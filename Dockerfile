FROM node:14

RUN rm /bin/sh && \
    ln -s /bin/bash /bin/sh && \
    mkdir -p /root/.nvm

RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update
RUN apt-get install -y git ssh-client openssl curl bash ca-certificates git gettext-base yarn

# #  very handy for easier signal handling of SIGINT/SIGTERM/SIGKILL etc.
# RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
# RUN dpkg -i dumb-init_*.deb
# ENTRYPOINT ["dumb-init"]

# Install Google Chrome (for testing purposes)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable

# set high timeout for yarn, see https://github.com/dhis2/notes/issues/29
RUN yarn config set network-timeout 600000 -g 
# add meteor (used by some apps)
RUN curl https://install.meteor.com/ | sh
# install some additional used released (should theoretically speed up ci-builds)
RUN meteor update --release 1.8.1 --allow-superuser
RUN meteor update --release 1.8.2 --allow-superuser
RUN meteor update --release 1.9 --allow-superuser
RUN meteor update --release 1.9.1 --allow-superuser

RUN yarn global add semantic-release @semantic-release/commit-analyzer @semantic-release/release-notes-generator @semantic-release/git @semantic-release/changelog @semantic-release/gitlab;

ENV KUBERNETES_VERSION 1.18.20
RUN curl -L -o /usr/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl" ;\
    chmod +x /usr/bin/kubectl ;\
    kubectl version --client

ENV HELM_2_VERSION 2.14.3
RUN curl "https://get.helm.sh/helm-v${HELM_2_VERSION}-linux-amd64.tar.gz" | tar zx ;\
    mv linux-amd64/helm /usr/bin/ ;\
    helm version --client
RUN cp /usr/bin/helm /usr/bin/helm2
# also install helm3
ENV HELM_VERSION 3.6.3
RUN curl "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar zx ;\
    mv linux-amd64/helm /usr/bin/helm3 ;\
    helm3 version --client

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
RUN source /root/.nvm/nvm.sh
RUN chmod +x /root/.nvm/nvm.sh
RUN /root/.nvm/nvm.sh install 10
RUN /root/.nvm/nvm.sh install 11
RUN /root/.nvm/nvm.sh install 12
RUN /root/.nvm/nvm.sh install 13
RUN /root/.nvm/nvm.sh install 14
RUN /root/.nvm/nvm.sh install 15
RUN /root/.nvm/nvm.sh install 16
# ENV NVM_DIR=/root/.nvm
# RUN bash -c 'source /root/.nvm/nvm.sh'
# RUN echo '. /root/.nvm/nvm.sh' >> /root/.bashrc
# RUN bash -c 'source /root/.nvm/nvm.sh'
# RUN echo '. ~/.nvm/nvm.sh' >> $HOME/.profile
# RUN . /root/.nvm/nvm.sh && nvm --version
