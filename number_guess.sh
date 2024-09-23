
#!/bin/bash

# Variável para consultar o banco de dados
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt para o nome do usuário
echo -e "\nEnter your username:"
read USERNAME

# Consultar dados do usuário
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# Obter user_id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# Se o jogador não for encontrado
if [[ -z $USERNAME_RESULT ]]
then
    # Boas-vindas para novos usuários
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    # Adicionar jogador ao banco de dados
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    # Obter o novo user_id
    USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
    # Buscar o número de jogos e o melhor jogo (menos tentativas)
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id='$USER_ID_RESULT'")
    BEST_GAME=$($PSQL "SELECT MIN(best_guess) FROM games WHERE user_id='$USER_ID_RESULT'")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Gerar número secreto entre 1 e 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Variável para contar o número de tentativas
GUESS_COUNT=0

# Primeiro palpite
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

# Loop até acertar o número secreto
until [[ $USER_GUESS == $SECRET_NUMBER ]]
do
    # Verificar se o palpite é um número válido
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
        echo -e "\nThat is not an integer, guess again:"
    else
        if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
        then
            echo "It's higher than that, guess again:"
        else
            echo "It's lower than that, guess again:"
        fi
    fi
    read USER_GUESS
    ((GUESS_COUNT++))
done

# Incrementar a última tentativa
((GUESS_COUNT++))

# Inserir o resultado no banco de dados
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, best_guess) VALUES ($USER_ID_RESULT, $GUESS_COUNT)")

# Mensagem de vitória
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
