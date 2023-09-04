#! /bin/bash

## Anzahl der Nutzen pro Seite
ANPS=4

## PDF Datei 
PDFFILE=$1

## Find out number of pages
NPAGES=$(pdftk $PDFFILE dump_data | grep NumberOfPages | awk '{print $2}')

## Number of final imposed pages
AFP=$(bc <<<$NPAGES/$ANPS)

## Generate reordering string
ORDER=""

## Loop through each place in the final pdf and
## figure out which page should go in its place.
for ((i = 0 ; i < $NPAGES ; i++ )); 
do
    ## Round is the number on which imposed page we are
    ROUND=$(bc <<<$i/$ANPS)
    
    ## POS is the position on a imposed page that is possible
    ## (assumes 2x2 layout)
    POS=$(bc <<<$i%$ANPS)

    ## If Round is Odd, the pages need to be horizontally flipped
    ## To check if it is odd we divide by two and check the remainder
    REMAINDER=$(bc <<<$ROUND%2)
    if [ $REMAINDER == 1 ]; then                                                                            
        case $POS in
            0)
                POS=1
                ;;
            1)
                POS=0
                ;;
            2)
                POS=3
                ;;
            3)
                POS=2
                ;;
        esac
    fi

    ## Now we can calculate the final page position
    ## Plus one!
    FPOS=$(bc <<< $AFP*$POS+$ROUND+1)

    ORDER=$ORDER" "$FPOS 
done

echo $ORDER; 


### Do the reordering:
NEWNAME=$PDFFILE".reordered.pdf"



pdftk $PDFFILE cat $ORDER output $NEWNAME