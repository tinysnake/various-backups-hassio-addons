ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk add --no-cache rsync openssh expect

COPY run.sh /
COPY rsync.exp /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
