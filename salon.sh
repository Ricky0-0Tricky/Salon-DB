#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salão Mozart ~~~~~"

# Menu principal e tratamento da entrada do utilizador
MENU_PRINCIPAL() {
    if [[ $1 ]]; then
        echo -e "\nNão consegui encontrar esse serviço. O que deseja hoje?"
    else
        echo -e "\nBem-vindo ao Salão Mozart, como posso ajudar?"
    fi
    
    # Listar serviços
    SERVICOS=$($PSQL "SELECT * FROM services")
    echo "$SERVICOS" | while read ID_SERVICO BAR NOME; do
        echo -e "$ID_SERVICO) $NOME"
    done
    
    read SERVICO_SELECIONADO

    # Validar ID do serviço e tratar a seleção do utilizador
    if [[ "$SERVICO_SELECIONADO" =~ ^[1-5]$ ]]; then
        OFERECER_SERVICO
    else
        MENU_PRINCIPAL "Não consegui encontrar esse serviço. O que deseja hoje?"
    fi
}

# Oferecer serviço ao cliente
OFERECER_SERVICO() {
    echo -e "Qual é o seu número de telefone?"
    read TELEFONE_CLIENTE
    
    # Verificar se o cliente existe
    NOME_CLIENTE=$($PSQL "SELECT name FROM customers WHERE phone='$TELEFONE_CLIENTE'")
    
    if [[ -z $NOME_CLIENTE ]]; then
        echo -e "\nNão tenho um registro para esse número de telefone, qual é o seu nome?"
        read NOME_CLIENTE
        $PSQL "INSERT INTO customers(phone, name) VALUES('$TELEFONE_CLIENTE', '$NOME_CLIENTE')"
    fi

    echo -e "\nA que horas gostaria de agendar o seu atendimento?"
    read HORA_SERVICO

    ID_CLIENTE=$($PSQL "SELECT customer_id FROM customers WHERE phone='$TELEFONE_CLIENTE'")
    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($ID_CLIENTE, $SERVICO_SELECIONADO, '$HORA_SERVICO')"

    NOME_SERVICO=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICO_SELECIONADO")
    echo -e "I have put you down for a $NOME_SERVICO at $HORA_SERVICO, $NOME_CLIENTE.\n"
}

MENU_PRINCIPAL
