# Rippled Score
SDK for multi-player game scoring using ripple protocol

## Functions:

API Call | Description  | Parameters
--- |--- | ---
create_player | Create a player with 300 Points (300 XRP) | void
transfer_points | Transfer 5 points from player one to player two | ACCOUNT_ID1 ACCOUNT_ID2 SECRET1
top_players | Shows the first 10 players with the highest points record | Array of the Players (transfer by name)
user_status | Shows the player's scoring record | ACCOUNT_ID
