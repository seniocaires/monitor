#!/bin/sh

  # Imprimir informações sobre os parâmetros do sistema.
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
  prepararInicio() {
    echo "Preparando monitor...";
    echo "200" > status.log;
    echo "Monitor iniciado";
  }

  # Validar parâmetros do sistema
  validarParametros() {

    _url=$1;
    _intervalo=$2;
    _token=$3;
    _chat=$4;
    _debug=$5;

    # Checar parâmetros obrigatórios
    if [ -z "$_url" ] || [ -z "$_intervalo" ] || [ -z "$_token" ] || [ -z "$_chat" ]
      then
        echo "Erro: Parametro nao informado!";
        printParametros;
        exit 137;
    fi

    # Checa se o parâmetro [INTERVALO] é um número
    if [ ! -z ${_intervalo##*[0-9]*} ]
      then
        echo "Erro: Informe um numero no parametro [INTERVALO] " >&2;
        printParametros;
        exit 137;
    fi
  }

  log() {

    _mensagem=$1;
    _debug=$2;

    if [ "$_debug" = true ]
      then
        echo $_mensagem; # Log debug
    fi
  }

  checarHTTP() {

    _url=$1;
    _token=$2;
    _chat=$3;
    _debug=$4;

    log "Request URL "$_url $_debug;
    status_code=$(curl -fsSL -o /dev/null -i -w "%{http_code}" $_url); # Request [URL]
    log "Status code "$status_code $_debug;

    status_code_log=$(cat status.log); # Último status_code
    if [ "$status_code" != "$status_code_log" ] # Compara status_code atual e o último para não enviar mensagem repedida para o Telegram
      then
        echo "Status code alterado. Atual: "$status_code". Ultimo status: "$status_code_log;
        echo $status_code > status.log; # Atualiza o último status_code com o atual
        if [ "$status_code" != "200" ] # Se status_code não for 200, informa no Telegram
          then
            mensagem="[Alerta] Status Code "$status_code" na URL "$_url; 
            curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "'"$_chat"'", "text": "'"$mensagem"'", "disable_notification": true}' https://api.telegram.org/bot$_token/sendMessage
          else # Status voltou ao normal - 200
            mensagem="[OK] URL "$_url" respondendo corretamente. Status code: "$status_code; 
            curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "'"$_chat"'", "text": "'"$mensagem"'", "disable_notification": true}' https://api.telegram.org/bot$_token/sendMessage
        fi
    fi
  }

  run() {

    # Atribuir parâmetros para variáveis
    _url=$1;
    _intervalo=$2;
    _token=$3;
    _chat=$4;
    _debug=$5;

    prepararInicio;
    validarParametros $_url $_intervalo $_token $_chat $_debug;

    # Loop checagem
    while true
      do
        checarHTTP $_url $_token $_chat $_debug
        sleep $_intervalo; # Aguarda [INTERVALO] para a próxima checagem
      done    
  }

  run $1 $2 $3 $4 $5