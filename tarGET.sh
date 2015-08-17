#~/bin/bash
# Target Gift Card Balance Checker
# Description: Checks the balance of a list of Target gift cards.
# Author: Caleb Gross
# FILENAME=target_gift_cards_$(date +%s).txt

CARDS_FILE=$1
i=0

while read CARD_INFO
do

	GCCARDNUMBER=$(echo $CARD_INFO | awk '{ print $1 }')
	GCACCESSNUMBER=$(echo $CARD_INFO | awk '{ print $2 }')
	URL="https://www-secure.target.com/GuestGCCheckGiftCardBalCmd"
	DATA="gcCardNumber=$GCCARDNUMBER&gcAccessNumber=$GCACCESSNUMBER"
	BALANCE=$( \
		curl -s $URL -d $DATA |\
		grep -E ".*?(opening|remaining) balance:.*?" |\
		perl -pe "s|.*?<strong>(.)(.*?:)</strong> (.*?)</li>|\U\1\L\2	\3|" |\
		perl -pe "s|\&\#36\;|\\$|g" \
		)
	OPENING=$(echo "$BALANCE" | grep -i "opening" | perl -pe "s|.*?(\d+)\.(\d+).*|\1\2|g")
	REMAINING=$(echo "$BALANCE" | grep -i "remaining" | perl -pe "s|.*?(\d+)\.(\d+).*|\1\2|g")
	PERCENTAGE=$(($REMAINING / $OPENING * 100))

	((i++))
	echo "===== CARD $i ($PERCENTAGE%) ====="
	echo "Card number:		$GCCARDNUMBER"
	echo "Access number:		$GCACCESSNUMBER"
	echo "$BALANCE"
	echo

done < $CARDS_FILE