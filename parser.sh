#!/bin/bash

VSTUP=$1
DELKA=`wc -l "$VSTUP" | tr -s ' ' | cut -d ' ' -f 2`

otazka="nic"

mkdir -p otazky

IFS="\n"
while read line
do
    otazka=`echo "$line" | sed -n '/^Otázka\ [1-9][0-9]*:\ .*/ p' | sed 's/^Otázka\ [1-9][0-9]*:\ //'`

    if [ -n "$otazka" ]
    then
        otisk=`echo "$otazka" | md5`
        otazka_dir=$otisk
        mkdir -p "otazky/""$otisk"
        mkdir -p "zneni"
        echo "$otazka" > "zneni/""$otisk"
    else
        zneni=`echo "$line" | sed -n '/^[	]/ p' | sed 's/^[ 	]*//;s/[ 	]*$//'`
        if [ -n "$zneni" ]
        then
            otisk=`echo "$zneni" | md5`
            touch "otazky/""$otazka_dir""/""$otisk"
            echo "$zneni" > "zneni/""$otisk"
        fi
    fi
done < $VSTUP

replace_line=`cat otazky.tex | sed -n '/%%% REPLACE_CONTENT %%%/='`
lines=`wc -l otazky.tex | tr -s ' ' | cut -d ' ' -f 2`
head -n $( expr "$replace_line" - 1 ) otazky.tex

while read otazka
do
    otazka_cont=`cat "zneni/""$otazka" | sed 's/\\\/\\\backslash/g' | sed 's/\\\$/\\\\$/g' | sed 's/\([{}#^%&]\)/\\\1/g'`

    echo '\Qitem{ \Qq{'"$otazka_cont"'}'
    echo '  \begin{Qlist}'

    while read odpoved
    do
        if [ "$odpoved" == "9dd172a836334f81b8e77c6bdd621ba2" ]; then :; continue; fi;

        odpoved_cont=`cat "zneni/""$odpoved" | sed 's/\\\/\\\backslash/g' | sed 's/\\\$/\\\\$/g' | sed 's/\([{}#^%&]\)/\\\1/g'`
        echo '  \item '"$odpoved_cont"
    done < <( ls otazky/"$otazka" | sort )

    echo '  \end{Qlist}'
    echo '}'
    echo ''

done < <( ls otazky | sort )

tail -n $( expr "$lines" - "$replace_line" ) otazky.tex
