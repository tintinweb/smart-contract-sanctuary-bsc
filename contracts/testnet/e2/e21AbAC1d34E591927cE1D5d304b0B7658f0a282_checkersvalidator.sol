/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

/*
An off chain Checkers validator contract by TG:@DualityMan
*/
pragma solidity 0.8.8;
// SPDX-License-Identifier: Unlicensed

contract checkersvalidator{
modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
mapping (address => uint256) public QueuedFunds;
mapping (address => uint256) public from;
mapping (address => uint256) public to;
//keep track of in validator if >0 reset on game end
mapping (address => uint256) public MoveTimestamp;
address public _owner;
//need to update to get x amount of spins
uint256 public MoveCost = 2500000000000000;
uint256 public validatorfee = 4000000000000000;
uint256 public Tax = 10;
//remove and add the , from string
string default_board = "x,x,x,x,x,x,x,x,x,x,x,x,_,_,_,_,_,_,_,_,o,o,o,o,o,o,o,o,o,o,o,o";
game[] public games;
address[] public movequeue;
constructor(){_owner = msg.sender;}
//Player one is always X
//Player Two is always O
//false turn == playerone
struct game
{
string GameTitle;
string board;
address playerone;
address playertwo;
bool turn;
}

receive() external payable {}
fallback() external payable {}
//global var checks
function CheckMoveCost() public view returns(uint256){return MoveCost;}
//mapping checks
function CheckQueuedFunds(address wallet) public view returns(uint256){return QueuedFunds[wallet];}
function CheckMoveTimestamp(address wallet) public view returns(uint256){return MoveTimestamp[wallet];}
//array checks
function CheckGamesLength() public view returns(uint256){return games.length;}
function CheckGameTitle(uint256 i) public view returns(string memory){return games[i].GameTitle;}
function CheckGameBoard(uint256 i) public view returns(string memory){return games[i].board;}
function CheckGamePlayerOne(uint256 i) public view returns(address){return games[i].playerone;}
function CheckGamePlayerTwo(uint256 i) public view returns(address){return games[i].playertwo;}
function CheckGameTurn(uint256 i) public view returns(bool){return games[i].turn;}
function CheckMoveQueue(uint256 i) public view returns(address){return movequeue[i];}
function CheckMoveQueueLength() public view returns(uint256){return movequeue.length;}
function CheckMoveQueuePos(address wallet, uint256 i) public view returns(uint256)
{
if(i == 0){return from[wallet];}
if(i == 1){return to[wallet];}
return 0;
}
//custom checks
function CheckGameJoined(address wallet) public view returns(uint256)
{
uint256 ID;
bool GameFound;
for(uint256 x; x< games.length; x++)
{
if(games[x].playerone == wallet){GameFound = true; ID = x;}    
if(games[x].playertwo == wallet){GameFound = true; ID = x;}   
}
require(GameFound, "address not found in any games");
return ID;
}

function CheckIfAddressPlaying(address wallet) public view returns(bool)
{
for(uint256 x; x< games.length; x++)
{
if(games[x].playerone == wallet){return true;}    
if(games[x].playertwo == wallet){return true;}   
}
return false;
}

function CheckIfAddressQueued(address wallet) public view returns(bool)
{
for(uint256 x; x< movequeue.length; x++)
{
if(movequeue[x] == wallet){return true;}    
}
return false;
}

function CheckIfGameActive(uint256 ID) public view returns(bool)
{
if(MoveTimestamp[games[ID].playerone] > 0){return true;} 
if(MoveTimestamp[games[ID].playertwo] > 0){return true;} 
return false;
}

//Close game if one move hasn't been made
//user who move wins if timeout getting fees
function CreateGamePublic(string memory GameTitle) payable public returns(uint256)
{
QueuedFunds[msg.sender] += msg.value; 
games.push(game(GameTitle, default_board, msg.sender, address(this), false));
return games.length - 1;
}

function CheckIfAwaitingJoin(uint256 ID) public view returns(bool)
{
if(games[ID].playertwo == address(this)){return true;}   
return false;
}

function JoinPublicGame(uint256 ID) public payable
{
//User's wager matches the opponents
require(msg.value >= QueuedFunds[games[ID].playerone]);
//not already in existing game
require(CheckIfAddressPlaying(msg.sender) == false, "address is currently not within a game");
//Check if game is awaiting join
require(CheckIfAwaitingJoin(ID) == true, "Game already filled");
games[ID].playertwo = msg.sender;
}

function MakeMove(uint256 frompos, uint256 topos) public payable
{
require(msg.value >= MoveCost, "Sent amount less than minimum cost to play");
require(frompos >=0 && frompos <= 32, "ilegal move 0-32, input out of range");
require(topos >=0 && topos <= 32, "ilegal move 0-32, input out of range");
require(CheckIfAddressPlaying(msg.sender), "address is currently not within a game");
uint256 ID = CheckGameJoined(msg.sender);
require(games[ID].playerone != address(this) && games[ID].playertwo != address(this),"no opponent in game.");
require(games[ID].turn == false && CheckGamePlayerOne(ID) == msg.sender || games[ID].turn == true && CheckGamePlayerTwo(ID) == msg.sender, "not your turn");

if(payable(_owner).send(MoveCost)){}
MoveTimestamp[msg.sender] = block.timestamp;
from[msg.sender] = frompos;
to[msg.sender] = topos;
movequeue.push(msg.sender);
}

function ResetMove(address wallet) onlyOwner public{_ResetMove(wallet);}
function _ResetMove(address wallet) internal {QueuedFunds[wallet] = 0;}

function _SetBoard(uint256 ID,string memory boardstr) internal{games[ID].board = boardstr;} 

function ValidateMove(uint256 ID, string memory boardstr, bool WasValid, address wallet) onlyOwner public
{
require(CheckIfAddressQueued(wallet), "address not found in move queue");
for(uint256 x = 0; x < movequeue.length; x++)
{
if(movequeue[x] == wallet){poparraymove(x);}
}
if(WasValid == false)
{
_ResetMove(wallet);
}
else
{
games[ID].board = boardstr;
games[ID].turn = !games[ID].turn;
_ResetMove(wallet);
}
}

function EndGame(uint256 ID, address Winner) onlyOwner public 
{
require(CheckIfAddressPlaying(Winner), "address is currently not within a game");
_ResetMove(games[ID].playerone);
_ResetMove(games[ID].playertwo);
MoveTimestamp[games[ID].playerone] = 0;
MoveTimestamp[games[ID].playerone] = 0;
Payout(Winner, (QueuedFunds[games[ID].playerone] + QueuedFunds[games[ID].playertwo]));
poparray(ID);
}

function Payout(address wallet, uint256 amount) internal 
{
//reset vars and payout here, close game struct
require(amount <= address(this).balance,"Bot error, value over contract balance");
if(amount > 0){if(payable(wallet).send(amount)){}}
if(amount == 0){}
}

function poparray(uint index) internal {
require(index < games.length);
games[index] = games[games.length-1];
games.pop();
}

function poparraymove(uint index) internal {
require(index < games.length);
games[index] = games[games.length-1];
games.pop();
}

//Testing only emergency transfer to recipient.
function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
function ColdTransferAll(address recipient) onlyOwner public{payable(recipient).transfer(address(this).balance);}
}