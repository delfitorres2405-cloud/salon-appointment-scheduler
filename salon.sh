#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?"
  echo -e "\n1) Cut\n2) Color\n3) Perm\n4) Style\n5) Trim\n6) Exit"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) APPOINTMENT_MENU $SERVICE_ID_SELECTED ;; 
    6) EXIT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac 
}

APPOINTMENT_MENU(){
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # if input is not a number
  if [[ ! $CUSTOMER_PHONE =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "That is not a valid phone number"
  else
    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if customer doesn't exist 
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME"

  fi
}

EXIT(){
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU