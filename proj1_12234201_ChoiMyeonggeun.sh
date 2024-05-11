#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "usage: $0 file1 file2 file3"
    exit 1
fi

cat $1 $2 $3 >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "error: cannot find specified files"
    echo "usage: $0 file1 file2 file3"
    exit 1
fi

echo "************ OSS1 - Project1 ************"
echo "*         StudentID : 12234201          *"
echo "*         Name : Choi Myeonggeun        *"
echo "*****************************************"
echo

choice=0
IFS=,

while :; do
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in "
    echo "players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in mateches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
    read -p "Enter your CHOICE (1~7) : " choice

    case $choice in
    1)
        read -p "Do you want to get the Heung-Min Son's data? (y/n) :" choice
        if [ $choice = y ]; then
            awk -F, '$1=="Heung-Min Son" {printf("Team:%s, Appearance:%d, Goal:%d, Assist:%d\n\n", $4, $6, $7, $8)}' $2
        fi
        ;;
    2)
        read -p "What do you want to get the team data of league_position[1~20] : " choice
        awk -F, -v a=$choice '$6==a {printf("%d %s %f\n", $6, $1, $2/($2+$3+$4))}' $1
        ;;
    3)
        read -p "Do you want to know Top-3 attendance data? (y/n) : " choice
        if [ $choice = y ]; then
            echo '***Top-3 Attendance Match***'
            echo
            cat $3 | sort -t , -r -n -k 2 | head -n 3 | awk -F, '{printf("%s vs %s (%s)\n%d %s\n\n", $3, $4, $1, $2, $7)}'
        fi
        ;;
    4)
        read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " choice
        if [ $choice = y ]; then
            teams=$(cat $1 | tail -n $(($(cat $1 | wc -l) - 1)) | sort -t , -n -k 6 | awk -F, '{printf("%s,",$1)}')
            echo
            cnt=0
            for val in $teams; do
                cnt=$((cnt + 1))
                midx=$(awk -F, -v t=$val 't==$4&&s<=$7 {s=$7;i=NR} END {print i}' $2)
                awk -F, -v c=$cnt -v i=$midx 'NR==i {printf("%d %s\n%s %d\n\n", c, $4, $1, $7)}' $2
            done
        fi
        ;;
    5)
        read -p "Do you want to modify the format of date? (y/n) : " choice
        if [ $choice = y ]; then
            awk -F, 'NR!=1&&NR<=11 {print $1}' $3 | sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' -e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g' | sed -E -e 's/([0-9]{2}) ([0-9]{2}) ([0-9]{4}) - ([0-9]{1,2}:[0-9]{2}[ap]m)/\3\/\1\/\2 \4/'
            echo
        fi
        ;;
    6)
        PS3="Enter your team number: "
        select val in $(cat $1 | awk -F, 'NR!=1 {printf("%s,",$1)}'); do
            ldiff=$(awk -F, -v h=$val -v t=-1000000000 '$3==h&&t<($5-$6) {t=$5-$6} END {print t}' $3)
            echo
            awk -F, -v h=$val -v d=$ldiff '$3==h&&($5-$6)==d {printf("%s\n%s %d vs %d %s\n\n", $1, $3, $5, $6, $4)}' $3
            break
        done
        ;;
    7)
        echo "Bye!"
        echo
        exit 0
        ;;
    *) ;;
    esac
done
