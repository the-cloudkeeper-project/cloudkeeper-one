FROM ubuntu:16.04

ARG branch=master
ARG version
ENV applDir /var/spool/cloudkeeper/appliances

LABEL application="cloudkeeper-one" \
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
RUN gem install cloudkeeper-one -v ${version} --no-document

# env
RUN mkdir -p ${applDir} /var/log/cloudkeeper/

VOLUME ${applDir}

EXPOSE 50051

ENTRYPOINT ["cloudkeeper-one"]
