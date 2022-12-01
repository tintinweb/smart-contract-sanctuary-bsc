/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TALPAKDapp {
    //global dynamic array for playerlist.
    uint public nowPlaying;
    uint public maxPlayer;
    uint public minBet;
    uint public currentBet;
    uint public totalPayin;
    uint public totalPayout;
    uint public totalRefund;
    uint public managementFee;
    address payable public manager;
    address payable[] private playerList;
    address payable[] private refundedPlayers;
    address payable[] private winnerList; 
    uint []private payinList;
    uint []private payoutList;
    uint []private refundList;
    uint private seed;

    constructor(){
        //msg.sender is a global variable used to store contract address to manager.
        manager = payable(msg.sender); 
        maxPlayer =2; 
        minBet = 0.01 ether; //default is 0.01 ether.
        managementFee = 10; //default fees.
        totalPayin = getCasinoVolume();
        totalPayout = getTotalPayout();
        totalRefund = getTotalRefund();
        seed = (block.timestamp + block.difficulty) % 100;
    }

    // function that only manager can call.
    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this");
        _;
    }

    //show total casinovolumes.
    function getCasinoVolume() internal view returns(uint) {
        return  payinList.length;
    }

    //show total payouts.
    function getTotalPayout() internal view returns(uint){
        return payoutList.length;
    }

    //show total refund.
    function getTotalRefund() internal view returns(uint){
        return refundList.length;
    }

    //show player's currentbet.
    function previousBets() public view returns(uint [] memory){
        return payinList;
    }

    //show currentplayers.
    function players() public view returns (address payable[] memory) {
        return playerList;
    }

    //show to previous winner.
    function previousWinner() public view returns (address payable[] memory){
        return winnerList;
    }

    //function to set maxplayers.
    function setMaxPlayer(uint _maxPlayer) external onlyManager{ 
        require(nowPlaying == 0, "Game ongoing");
        maxPlayer = _maxPlayer;
    }

    //show total current casionbalance.
    function casinoBalance() public view returns(uint){
        return address(this).balance;
    }

    //show current maxbet.
    function maxBet() public view returns(uint){
        return address(this).balance;
    }

    //funtion to set minbet.
    function setMinBet(uint _minBet) external onlyManager{
        require(nowPlaying == 0, "Game ongoing");
        minBet = _minBet;
    }

    //show to current payout.
    function previousPayout() external view returns(uint [] memory){
        return payoutList;
    }

    //funtion during deposit.
    function callOnBet() internal {
        currentBet=(msg.value);
        totalPayin+=((msg.value));
        payinList.push((msg.value));
    }

    function placeBet() public payable {
        //require is used to assure gas is maximized by the users.
        require(msg.value >= minBet,"Bet must be equal or higher than minBet");
        require(msg.value  >= currentBet,"Bet must be equal or higher than previousBet amount");
        if (nowPlaying < maxPlayer  ){
            playerList.push(payable(msg.sender));
            nowPlaying++;
            callOnBet();
        } else if (nowPlaying == maxPlayer){
            clearLogsA();
            pickWinner();
        }
    }

    //sending/transfer is counted placeBet or join game. 
   receive() external payable {
        //require is used to assure gas is maximized by the users.
        require(msg.value >= minBet,"Bet must be equal or higher than minBet");
        require(msg.value  >= currentBet,"Bet must be equal or higher than previousBet amount");
        if (nowPlaying < maxPlayer){
            playerList.push(payable(msg.sender));
            nowPlaying++;
            callOnBet();
        } else if (nowPlaying == maxPlayer){
            clearLogsA();
            pickWinner();
        }
    }

    //call before pickwinner.
    function clearLogsA() internal{
        delete payoutList;
        delete winnerList;
    }

    //call during reset and restart. 
    function clearLogsB() internal {
        delete playerList;
        delete currentBet; 
        delete nowPlaying;
        delete payoutList;
        delete winnerList;
        delete payinList;
    }

    //call after pickwinner.
    function callAfterPickWinnerA() internal {
        delete playerList;
        delete payinList;
        delete currentBet; 
        nowPlaying = 0;
    }

    //call after pickwinner.
    function callAfterPickWinnerB() internal {
        currentBet=(msg.value);
        playerList.push(payable(msg.sender));
        payinList.push((msg.value));
        nowPlaying++;
        nowPlaying = 1;
        totalPayin+=((msg.value));
    }

    //this random function will generate random value and from player's array and then return to the pickWinner Function.
    function runRandom() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,seed,playerList.length)));
    }

    // funtion to call automated choose winner randomly.
    function pickWinner() internal{
        require(address(this).balance > 0 ether, "Balance can not be less than zero"); 
        require(nowPlaying == maxPlayer); 
        require(msg.value  >= currentBet,"Bet must be equal or higher than previousBet amount");
        uint256 r = runRandom(); 
        uint256 index = r % playerList.length;
        address payable winner;
        winner = playerList[index];
        uint prizeAmount = previousBets()[index] * 2;
        payable(manager).transfer(prizeAmount / managementFee);  
        winner.transfer(prizeAmount - (prizeAmount / managementFee)); 
        winnerList.push(payable(winner));
        payoutList.push((prizeAmount));
        totalPayout+=((prizeAmount));
        callAfterPickWinnerA();
        callAfterPickWinnerB(); 
    }

    //funtion to call the smart contract to set on the pre-game state.
    function resetGame() external {
        require(nowPlaying == 1,"nowPlaying must be equal to 1");
        require(casinoBalance() >= currentBet,"casinoBalance must be equal or higher than currentBet");
        uint refund = currentBet;
        payable(manager).transfer(refund / managementFee); 
        payable(playerList[0]).transfer(refund - (refund / managementFee));
        totalPayin-=((refund));
        refundList.push((refund));
        refundedPlayers.push(payable(playerList[0]));
        totalRefund+=((refund));
        clearLogsB();
    }

     //funtion only manager can call the smart contract to restartgame.
    function restart() external onlyManager {
        require(nowPlaying == 1,"nowPlaying must be equal to 1");
        require(casinoBalance() < currentBet,"casinoBalance must be lower than currentBet");
        uint refund = casinoBalance();
        payable(manager).transfer(refund / managementFee); 
        payable(playerList[0]).transfer(refund - (refund / managementFee));
        totalPayin-=((refund));
        refundList.push((refund));
        refundedPlayers.push(payable(playerList[0]));
        totalRefund+=((refund));
        clearLogsB();
    }
      // Function to rescue any erc20 token accidentally sent to the contract.
    function rescueERC20(IERC20 token, address to, uint256 amount) external onlyManager{
        uint256 erc20balance = token.balanceOf(address(this));
        require(amount <= erc20balance, "balance is low");
        token.transfer(to, amount);
    }  

    //call to change ownership.
    function transferOwnership(address _newManager) external onlyManager virtual {
        manager = payable(_newManager);
    }

    /// @notice Returns the (ETH) balance of a given address
    function playerBalance() public view returns (uint) {
        return msg.sender.balance;
    }
}