#! /bin/bash

function create_player {
	WALLET=`rippled wallet_propose 2>/dev/null`
	ACCOUNT=`echo $WALLET |  grep "account_id\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/account_id" : "//'`
	SECRET=`echo $WALLET |  grep "master_seed\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/master_seed" : "//'`
	FEE=10
	SEQUENCE=2
	TRANSACTION='{"TransactionType": "Payment", "Account": "rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh", "Destination": "'$ACCOUNT'", "Amount": "300000020",  "Fee": "'$FEE'", "Flags": "0", "Sequence": "'$SEQUENCE'"}'
	SIGN=`rippled sign "snoPBrXtMeMyMHUVTgbuqAfg1SUTb" "$TRANSACTION" offline 2>/dev/null`
	TXBLOB=`echo $SIGN | grep "tx_blob\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/tx_blob" : "//'`
	rippled submit $TXBLOB 2>/dev/null >/dev/null


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
	
	FEE=10
	SEQUENCE=3
	TRANSACTION='{"TransactionType": "Payment", "Account": "'$FRSTPLAYER'", "Destination": "'$SCNDPLAYER'", "Amount": "5000000",  "Fee": "'$FEE'", "Flags": "0", "Sequence": "'$SEQUENCE'"}'
	SIGN=`rippled sign $SECRET "$TRANSACTION" offline 2>/dev/null`
	TXBLOB=`echo $SIGN | grep "tx_blob\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/tx_blob" : "//'`
	rippled submit $TXBLOB 2>/dev/null >/dev/null
}

function user_status {
	echo `rippled account_info $1 2>/dev/null`

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

	for ACC in "${!HASHMAXACC[@]}"; do echo "$ACC - ${HASHMAXACC[$ACC]}"; done

}

