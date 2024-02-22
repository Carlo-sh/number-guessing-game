#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guessing_game -t --tuples-only -c"

echo -e "\n~~~ Number Guessing Game ~~~\n"

SECRET_NUMBER=$((1 + RANDOM % 1000))
NUMBER_OF_GUESSES=0

GAME() {

  echo -e "Enter your username:\n"
  read USERNAME

  if [[ ${#USERNAME} -gt 22 ]]; then
    echo "Invalid username"
    GAME
  fi

  CURR_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

  if [[ -z $CURR_USER ]]; then
    INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1001)")

    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    echo -e "\nGuess the secret number between 1 and 1000:"

    GUESSING $USERNAME
  else
    SELECTED_USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")
    echo "$SELECTED_USER" | while read USER BAR GAMES BAR BEST
    do
      echo -e "Welcome back, $USER! You have played $GAMES games, and your best game took $BEST guesses."
    done

    echo -e "\nGuess the secret number between 1 and 1000:"
    GUESSING $USERNAME
  fi
}

GUESSING() {
  
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"
    GUESSING
  else
    if [[ $GUESS -gt $SECRET_NUMBER ]]; then
      (( NUMBER_OF_GUESSES++ ))
      echo -e "\nIt's lower than that, guess again:"
      GUESSING
    elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
      (( NUMBER_OF_GUESSES++ ))
      echo -e "\nIt's higher than that, guess again:"
      GUESSING
    else
      (( NUMBER_OF_GUESSES++ ))
      BEST_SCORE=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
      UPDATE_USERS=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
      if [[ $NUMBER_OF_GUESSES -lt $BEST_SCORE ]]; then
        UPDATE_BEST_SCORE=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
      fi

      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  fi
}

GAME
