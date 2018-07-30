#! /bin/bash

function create_player {
	WALLET=`rippled wallet_propose 2>/dev/null`
	ACCOUNT=`echo $WALLET |  grep "account_id\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/account_id" : "//'`
	SECRET=`echo $WALLET |  grep "master_seed\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/master_seed" : "//'`
	FEE=10
	SEQUENCE=1
	TRANSACTION='{"TransactionType": "Payment", "Account": "rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh", "Destination": "'$ACCOUNT'", "Amount": "300000010",  "Fee": "'$FEE'", "Flags": "0", "Sequence": "'$SEQUENCE'"}'
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
	SEQUENCE=2
	TRANSACTION='{"TransactionType": "Payment", "Account": "'$FRSTPLAYER'", "Destination": "'$SCNDPLAYER'", "Amount": "5000000",  "Fee": "'$FEE'", "Flags": "0", "Sequence": "'$SEQUENCE'"}'
	SIGN=`rippled sign $SECRET "$TRANSACTION" offline 2>/dev/null`
	TXBLOB=`echo $SIGN | grep "tx_blob\"\s*:\s*\"[a-zA-Z0-9]*" -o | sed 's/tx_blob" : "//'`
	rippled submit $TXBLOB 2>/dev/null >/dev/null
}

function user_status {
	echo `rippled account_info $1`
}
