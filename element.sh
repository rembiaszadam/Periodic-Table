#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements
    WHERE '$1' IN(atomic_number)")
  else
    ELEMENT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements
    WHERE '$1' IN(symbol, name)")
  fi

  if [[ -z $ELEMENT_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT_RESULT" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
    do
      PROPERTIES_RESULT=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id
      FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      echo "$PROPERTIES_RESULT" | while read ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE_ID
      do
        TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
        TYPE_FORMATTED=$(echo $TYPE | sed 's/* *//')
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE_FORMATTED, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
    done

  fi
fi
