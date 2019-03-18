# Monitor

Monitora uma url.

Alerta indisponibilidade no Telegram.

```
docker run -it --rm \
           -e URL=https://exemplo.org/status \
           -e INTERVALO=5 \
           -e TOKEN=AAAAAAAAA:BBBBBCCCCCCDDDDDDD \
           -e CHAT_ID=-123456789 \
           -e DEBUG=true \
           seniocaires/monitor:latest
```

#### Envs

1 - [URL] - Url monitorada. Ex: https://www.google.com

2 - [INTERVALO] - Intervalo de tempo (segundos) entre as checagens. Ex: 60

3 - [TOKEN] - Token do Bot no Telegram. Ex: AAAAAAAAA:BBBBBCCCCCCDDDDDDD

4 - [CHAT_ID] - ID do Chat no Telegram. Ex: -123456789

5 - [DEBUG] - Exibir log com request de sucesso. Ex: true