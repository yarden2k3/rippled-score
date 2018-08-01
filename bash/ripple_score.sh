#! /bin/bash

function create_player {
	BANKSTAT=`user_status rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh`
	SEQUENCE=`echo $BANKSTAT |  grep "Sequence\"\s*:\s*[0-9]*" -o | sed 's/Sequence" : //'`
	WALLET=`rippled wallet_propose 2>/dev/null`
	ACCOUNT=`echo $WALLET |  grep "account_id\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/account_id" : "//'`
	SECRET=`echo $WALLET |  grep "master_seed\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/master_seed" : "//'`
	FEE=10
	TRANSACTION='{"TransactionType": "Payment", "Account": "rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh", "Destination": "'$ACCOUNT'", "Amount": "301000000",  "Fee": "'$FEE'", "Flags": "0", "Sequence": "'$SEQUENCE'"}'
	SIGN=`rippled sign "snoPBrXtMeMyMHUVTgbuqAfg1SUTb" "$TRANSACTION" offline 2>/dev/null`
	TXBLOB=`echo $SIGN | grep "tx_blob\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/tx_blob" : "//'`
	rippled submit $TXBLOB 2>/dev/null >/dev/null

	SEQUENCE=1
	REGWALLET=`rippled wallet_propose 2>/dev/null`
	REGACC=`echo $REGWALLET |  grep "account_id\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/account_id" : "//'`
	TRANSACTION='{"TransactionType": "SetRegularKey", "Account": "'$ACCOUNT'", "RegularKey": "'$REGACC'",  "Fee": "'$FEE'", "Sequence": "'$SEQUENCE'"}'
	SIGN=`rippled sign $SECRET "$TRANSACTION" offline 2>/dev/null`
	TXBLOB=`echo $SIGN | grep "tx_blob\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/tx_blob" : "//'`
	rippled submit $TXBLOB 2>/dev/null >/dev/null
	echo '{"account": "'$ACCOUNT'", "secret": "'$SECRET'"}'
}


function transfer_points {
	FRSTPLAYER=$1
	SCNDPLAYER=$2
	SECRET=$3
	FPSEQ=`user_status $FRSTPLAYER`
	FEE=10
	SEQUENCE=`echo $FPSEQ |  grep "Sequence\"\s*:\s*[0-9]*" -o | sed 's/Sequence" : //'`
	TRANSACTION='{"TransactionType": "Payment", "Account": "'$FRSTPLAYER'", "Destination": "'$SCNDPLAYER'", "Amount": "5000000",  "Fee": "'$FEE'", "Flags": "0", "Sequence": "'$SEQUENCE'"}'
	SIGN=`rippled sign $SECRET "$TRANSACTION" offline 2>/dev/null`
	TXBLOB=`echo $SIGN | grep "tx_blob\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/tx_blob" : "//'`
	rippled submit $TXBLOB 2>/dev/null >/dev/null
}

function user_status {
	echo `rippled account_info $1 2>/dev/null`

}


function user_balance {
	ACCOUNT=$1
	#echo `rippled account_info $1 2>/dev/null`
	ACC=`user_status $ACCOUNT`
	BALANCE=`echo $ACC | grep "Balance\"\s*:\s*\"[0-9]*" -o | sed 's/Balance" : "//'`
	echo $BALANCE
}

function user_validator {
	EXIT_CODE=1
	ACCOUNT=$1
	VALID="NOT OK"
	ACC=`user_status $ACCOUNT`
	BALANCE=`echo $ACC | grep "Balance\"\s*:\s*\"[0-9]*" -o | sed 's/Balance" : "//'`
	if [ -z "$BALANCE" ]
	then
		VALID="Not Valid username or password empty BALANCE"
	else
		if [ $BALANCE -le 0 ]
		then 
			VALID="Not Valid username or password"
		else
			ACC=`user_status $ACCOUNT`
			SEQUENCE=`echo $ACC |  grep "Sequence\"\s*:\s*[0-9]*" -o | sed 's/Sequence" : //'`
			SECRET=$2
			FEE=10
			REGWALLET=`rippled wallet_propose 2>/dev/null`
			REGACC=`echo $REGWALLET |  grep "account_id\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/account_id" : "//'`
			TRANSACTION='{"TransactionType": "SetRegularKey", "Account": "'$ACCOUNT'", "RegularKey": "'$REGACC'",  "Fee": "'$FEE'", "Sequence": "'$SEQUENCE'"}'
			SIGN=`rippled sign $SECRET "$TRANSACTION" offline 2>/dev/null`
			TXBLOB=`echo $SIGN | grep "tx_blob\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/tx_blob" : "//'`
			rippled submit $TXBLOB 2>/dev/null >/dev/null
			ACC=`user_status $ACCOUNT`
			
			BALANCE2=`echo $ACC | grep "Balance\"\s*:\s*\"[0-9]*" -o | sed 's/Balance" : "//'`
			if [ $BALANCE -eq $BALANCE2 ]
			then
				VALID="Balance equal Not Valid username or password"
			else
				VALID="OK"
                                EXIT_CODE=0
			fi
		fi
	fi
	echo $VALID
        exit $EXIT_CODE
	
}

function top_ten {
	NAME=$1[@]
	ACCARR=("${!NAME}")
	declare -A HASHACC
	declare -A HASHMAXACC
#	for ACC in "${ACCARR4[@]}"; do echo "$ACC"; done

	for ACC in "${ACCARR[@]}"
	do
		USER=`user_status $ACC`
		BALANCE=`echo $USER | grep "Balance\"\s*:\s*\"[0-9]*" -o | sed 's/Balance" : "//'`
		HASHACC["$ACC"]="$BALANCE"
	done

#	for ACC in "${!HASHACC[@]}"; do echo "$ACC - ${HASHACC[$ACC]}"; done

	MAX=0
	COUNTER=1
	if [ ${#ACCARR[@]} -ge 10 ]
	then
		PLAYERSNUM=10
	else
		PLAYERSNUM=${#ACCARR[@]}
	fi
	
	while [ $COUNTER -le $PLAYERSNUM ]; do
		for ACC in "${!HASHACC[@]}"; do
			POTENTIAL=${HASHACC[$ACC]}
			if [ $POTENTIAL -gt $MAX ]
			then
				MAX=$POTENTIAL
				MAXACC=$ACC
			fi
		done
		HASHMAXACC["$MAXACC"]="$MAX"
		MAX=0
		HASHACC["$MAXACC"]=0
		((COUNTER++))
	done
	ANSWER=" "
	for ACC in "${!HASHMAXACC[@]}"; do ANSWER+="Account ID : $ACC Score: ${HASHMAXACC[$ACC]}\n"; done

	echo -e $ANSWER
}

