/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Jackpot {

    address public owner;
    address payable public feeReceiver;
    address payable[] public players;
    address payable[] public winners;
    uint public depositAmount;
    uint public maxParticipants;
    uint public counter = 0;
    uint public gameCount = 0;
    bool public gameStatus = false;
    
    constructor(address payable _feeReceiver, uint _depositAmount, uint _maxParticipants){
        owner = msg.sender;
        feeReceiver = _feeReceiver;
        //deposit amount is a multiplier of 0.1 BNB. If you input _depositAmount as 1, the deposit amount is going to be 0.1 BNB.
        depositAmount = _depositAmount * 1E17;
        maxParticipants = _maxParticipants;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner can call this function.");
        _;
    }

    //This function resets the game, turns the game into initial state
    function resetGame() public virtual onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you reset the game.");
        players = new address payable[](0);
        counter = 0;
    }

    //This function can stop/start the lottery
    function gameToggle() public virtual onlyOwner{
        gameStatus = !gameStatus;
    }

    //This function changes how many participants are allowed to join the game
    function setMaxParticipants(uint _amount) public virtual onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you change maxParticipants.");
        maxParticipants = _amount;
    }

    //deposit amount is a multiplier of 0.1 BNB. If you input _depositAmount as 1, the deposit amount is going to be 0.1 BNB.
    //This function changes the deposit amount
     function changeDepositAmount(uint _amount) public virtual onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you change depositAmount.");
        depositAmount = 1E17 * _amount;
    }

    //This function rescues if any BNB gets stuck in the contract
    function rescueStuckBalance() public onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you rescue.");
        feeReceiver.transfer(address(this).balance);
    }

    //This function sets the Fee Receiver
    function setFeeReceiver(address payable _address) public virtual onlyOwner {
        feeReceiver = _address;
    }

    //This function displays balance of the contract
    function getBalance() public view returns (uint){
        return address(this).balance;
    }

    //This function gets players address list
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
    
    //This function gets winners address list
    function getWinners() public view returns (address payable[] memory){
        return winners;
    }

    //This function makes you enter the lottery
    function enter() external payable{
        require(gameStatus == true,"The Lottery has been stopped");
        require(msg.value == depositAmount,"You can only deposit depositAmount BNB");
        
        //address of player entering lottery
        players.push(payable(msg.sender));
        //increased player count
         counter += 1;
         //if there are maximum amount of participants, pick the winner and send balances.
        if(counter == maxParticipants){
            pickWinner();
        }
    }

    //This function generates a random number
    function getRandomNumber() internal view returns (uint){
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    //This function Picks the winner
    function pickWinner() internal {
        uint index = getRandomNumber() % players.length;
    
        //Send the winner's funds and lottery fee cut
        players[index].transfer(address(this).balance*80/100);
        feeReceiver.transfer(address(this).balance);

        //Save winner of the current game
        winners.push(players[index]);
        
        //reset the state of the contract and count the game
        players = new address payable[](0);
        counter = 0;
        gameCount += 1;
    }
}