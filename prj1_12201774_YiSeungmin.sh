#!/bin/bash

item_file="$1"
data_file="$2"
user_file="$3"

user_name=$(whoami)
sid=$(echo "$0" | grep -oP 'prj1_\K\d+')

echo "--------------------------"
echo "User Name: $user_name"
echo "Student Number: $sid"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do
    read -p "Enter your choice [ 1-9 ] " choice

    case $choice in
        1)
            echo
            read -p "Please enter the 'movie id' (1~1682): " movie_id
            echo
            movie_info=$(awk -F "|" -v id="$movie_id" '$1 == id {print $0}' "$item_file")
            if [ -n "$movie_info" ]; then
                echo -e "$movie_info"
            else
                echo "Movie not found"
            fi
	    echo
            ;;

        2)
            echo
            echo -n "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n) "
            read answer
            echo
            if [ "$answer" == "y" ]; then
                awk -F "|" '$7 ~ /1/ {print $1, $2}' "$item_file" | sort -n | head -n 10
            else
                echo "Data not requested"
            fi
	    echo
            ;;

        3)
            echo
            read -p "Please enter the 'movie id' (1~1682): " movie_id
            average_rating=$(awk -v id="$movie_id" '$2 == id {total += $3; count++} END {if (count > 0) printf "%.5f", total/count}' "$data_file")
            echo
            if [ -n "$average_rating" ]; then
                echo "average rating of $movie_id: $average_rating"
            else
                echo "Rating not found"
            fi
	    echo
            ;;

        4)
            echo
            echo -n "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n) "
            read answer
            echo
            if [ "$answer" == "y" ]; then
                awk -F "|" -v item_file="$item_file" 'BEGIN {OFS=FS} {$5=""; print}' "$item_file" | sort -n | head -n 10
            else
                echo "Data not requested"
            fi
	    echo
            ;;

        5)
            echo
            echo -n "Do you want to get the data about users from 'u.user'?(y/n) "
            read answer
            echo
            if [ "$answer" == "y" ]; then
                awk -F "|" '{
                    gender = ($3 == "M") ? "male" : "female";
                    printf "user %s is %s years old %s %s\n", $1, $2, gender, $4;
                }' "$user_file" | sort -n -t" " -k2,2 | head -n 10
            else
                echo "Data not requested"
            fi
	    echo
            ;;

        6)
            echo
            echo -n "Do you want to Modify the format of 'release date' in 'u.item'?(y/n) "
            read answer
            echo
            if [ "answer" == "y" ]; then
                awk -F "|" '{
                    split($3, date, "-");
                    r_date = sprintf("%s%02d%02d", date[3], (index("JanFebMarAprMayJunJulAugSepOctNovDec", date[2]) + 2) / 3, date[1]);
                    $3 = r_date;
                    OFS = "|";
                    print;
                }' "$item_file" | sort -n | tail -n 10
            else
                echo "Data not modified"
            fi
	    echo
            ;;

        7)
            echo
            echo -n "Please enter the 'user id' (1~943): "
            echo
            read user_id

            movie_ids=$(awk -F "\t" -v id="$user_id" '$1 == id {print $2}' "$data_file")

            if [ -z "$movie_ids" ]; then
                echo "No movies found for the user identified by 'user id': $user_id"
            else
                sorted_ids=$(echo "$movie_ids" | tr ' ' '|')
                echo "$sorted_ids"
                echo
                
		echoecho
            fi
            ;;

        9)
            echo "Bye!"
            exit 0
            ;;
        *)
            echo
            echo "Enter your choice [ 1-9 ] "
            ;;
    esac
done
