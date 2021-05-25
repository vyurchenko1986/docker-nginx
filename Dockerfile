FROM  alpine:latest

LABEL maintainer="Valery Yurchenko <vyurchenko1986@gmail.com>"
LABEL company="My Home Company"
LABEL name="nginx"

ARG tz="Europe/Kiev"
ARG service_port="80"

# https://github.com/Yelp/dumb-init/releases
ARG dumb_init_release="https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64"

ENV SERVICE_PORT=${SERVICE_PORT:-$service_port}
ENV TZ=${TZ:-$tz}

ENV DUMB_INIT_RELEASE=${DUMB_INIT_RELEASE:-$dumb_init_release}

RUN set -x \
    && apk update \
    && apk upgrade \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && apk add --update tzdata \
    && apk --no-cache add --virtual .build-dependencies curl nginx \
    #
    && adduser -S -D -u 8062 -H nginx \
    && curl -Lo /usr/local/bin/dumb-init ${DUMB_INIT_RELEASE} \
    && chmod +x /usr/local/bin/dumb-init \
    #
    && apk del --purge -r .build-dependencies \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/cache/distfiles/*

# Default configuration
COPY resources/nginx/nginx.conf /etc/nginx/nginx.conf
COPY resources/nginx/conf.d/*conf /etc/nginx/conf.d/

EXPOSE ${SERVICE_PORT}

ENTRYPOINT ["dumb-init"]
CMD ["nginx"]
