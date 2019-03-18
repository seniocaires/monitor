FROM alpine:3.9.2

WORKDIR /usr/share/monitor

ADD . .

RUN chmod +x run.sh && apk add --update curl && rm -rf /var/cache/apk/*

ENTRYPOINT ./run.sh $URL $INTERVALO $TOKEN $CHAT_ID $DEBUG
