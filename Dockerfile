FROM ubuntu:16.04

ARG branch=master
ARG version

ENV name="cloudkeeper-one" \
    username="cloudkeeper"
ENV spoolDir="/var/spool/${username}"
ENV applDir="${spoolDir}/appliances" \
    logDir="/var/log/${username}"

LABEL application=${name} \
      description="A tool for synchronizing appliances between cloudkeeper and OpenNebula" \
      maintainer="kimle@cesnet.cz" \
      version=${version} \
      branch=${branch}

SHELL ["/bin/bash", "-c"]

# update + dependencies
RUN apt-get update && \
    apt-get --assume-yes upgrade && \
    apt-get --assume-yes install ruby ruby-dev zlib1g-dev gcc patch make

# cloudkeeper-one
RUN gem install ${name} -v ${version} --no-document

# env
RUN useradd --system --shell /bin/false --home ${spoolDir} --create-home ${username} && \
    usermod -L ${username} && \
    mkdir -p ${applDir} ${logDir} && \
    chown -R ${username}:${username} ${spoolDir} ${logDir}

VOLUME ${applDir}

EXPOSE 50051

USER ${username}

ENTRYPOINT ["cloudkeeper-one"]
