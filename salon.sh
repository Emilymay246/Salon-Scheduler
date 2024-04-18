#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to the salon ~~~~~\n"
echo -e "\nHow man I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

  #get list of services
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")

  # ask what services
  echo "$SERVICES_LIST" | while read SERVICEID BAR NAME
  do
    echo "$SERVICEID) $NAME"
  done
  # ask to pick
  read SERVICE_ID_SELECTED

  #if not a #
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
     MAIN_MENU "please input a number"
    else

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    # Return to home with message
    HOME_MENU "Please input a number"
    else

      #check services
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id= '$SERVICE_ID_SELECTED'")

      #if service doesn't exist
      if [[ -z $SERVICE_NAME ]]
      then
        #send them home
        MAIN_MENU "we don't offer that service, can I offer another service?"
      else
        REGISTERATION_MENU "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
      fi
    fi
  fi
}

REGISTERATION_MENU() {
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME=$2

  # Ask for phone number
  echo -e "What's your phone number?"
  read CUSTOMER_PHONE

  # Get customer name from database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # If customer doesn't exist
  if [[ -z $CUSTOMER_ID ]]
  then
    # Ask for customer name 
    echo -e "\nI don't have a record of that phone number, what's your name?"
    read CUSTOMER_NAME

    #add customer to database
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # Get customer name from database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # ask what time
  echo -e "\nWhat time would you like?"
  read SERVICE_TIME

  #add appt to database
  ADD_APPT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VAlUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Print success message
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
  

}

MAIN_MENU
