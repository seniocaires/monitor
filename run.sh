#!/bin/sh

  printParametros() {
    echo "PARAMETROS:";
    echo "1 - [URL] - Url monitorada. Ex: https://www.google.com";
    echo "2 - [INTERVALO] - Intervalo de tempo (segundos) entre as checagens. Ex: 60";
    echo "3 - [TOKEN] - Token do Bot no Telegram. Ex: AAAAAAAAA:BBBBBCCCCCCDDDDDDD";
    echo "4 - [CHAT_ID] - ID do Chat no Telegram. Ex: -123456789"
    echo "5 - [DEBUG] - Exibir log com request de sucesso. Ex: true";
    echo "Exemplo: https://www.google.com 5 AAAAAAAAA:BBBBBCCCCCCDDDDDDD -123456789 true";
  }

  # Preparar monitor para iniciar
  echo "Preparando monitor...";
  echo "200" > status.log;
  echo "Monitor iniciado";
  url=$1
  intervalo=$2
  token=$3
  chat=$4
  debug=$5

  # Checar parametros obrigatorios
  if [ -z "$url" ] || [ -z "$intervalo" ] || [ -z "$token" ] || [ -z "$chat" ]
    then
      echo "Erro: Parametro nao informado!";
      printParametros;
      exit 137;
  fi

  # Checa se o parametro [INTERVALO] e um numero
  if [ ! -z ${intervalo##*[0-9]*} ]
    then
      echo "Erro: Informe um numero no parametro [INTERVALO] " >&2;
      printParametros;
      exit 137;
  fi

  # Loop checagem
  while true
    do
      if [ "$debug" = true ]
        then
          echo "Request URL "$url; # Log debug
      fi
      status_code=$(curl -fsSL -o /dev/null -i -w "%{http_code}" $1); # Request [URL]
      if [ "$debug" = true ]
        then
          echo "Status code "$status_code; # Log debug
      fi
      status_code_log=$(cat status.log); # Ultimo status_code
      if [ "$status_code" != "$status_code_log" ] # Compara status_code atual e o ultimo para nao enviar mensagem repedida para o Telegram
        then
          echo "Status code alterado. Atual: "$status_code". Ultimo status: "$status_code_log;
          echo $status_code > status.log; # Atualiza o ultimo status_code com o atual
          if [ "$status_code" != "200" ] # Se status_code nao for 200, informa no Telegram
            then
              mensagem="[Alerta] Status Code "$status_code" na URL "$url; 
              curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "'"$chat"'", "text": "'"$mensagem"'", "disable_notification": true}' https://api.telegram.org/bot$token/sendMessage
            else # Status voltou ao normal - 200
              mensagem="[OK] URL "$url" respondendo corretamente. Status code: "$status_code; 
              curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "'"$chat"'", "text": "'"$mensagem"'", "disable_notification": true}' https://api.telegram.org/bot$token/sendMessage
          fi
      fi

      sleep $intervalo; # Aguarda [INTERVALO] para a proxima checagem
    done
