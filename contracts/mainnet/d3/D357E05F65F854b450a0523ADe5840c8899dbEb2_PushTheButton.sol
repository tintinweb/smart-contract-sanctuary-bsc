/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract PushTheButton {
    address owner=0x3B0F531c469758185D7263B4A12C63c71b0846eC;

    uint256 winPool=0;
    uint256 feePool=0;
    address currentWinner=address(0);
    uint256 entryFee=10000000000000000;


    uint256 roundId=0;
    mapping (uint256 => address) winner;
    mapping (uint256=> uint256) winAmt;
    uint256 roundStarted;
    uint256 roundFinished;
    uint256 blockWait=28800;

    bool isRunActive=false;

    function modifyBlockWait(uint256 newBlockAmt) public{
        require(msg.sender==owner,"Not owner");
        blockWait=newBlockAmt;
    }

    function claimFee() public {
        require(msg.sender==owner,"not owner");
        payable(owner).transfer(feePool);
        feePool=0;
    }

    function modifyFee(uint256 newFee) public{
        require(msg.sender==owner,"not owner");
        entryFee=newFee;
    } 

    function getCurrentWinner() public view returns(address){
        return currentWinner;
    }

    function changeOwner(address newOwner) public {
        require(msg.sender==owner,"not owner");
        owner=newOwner;
    }

    function getWinner(uint256 round) public view returns(address) {
        return winner[round];
    }

    function getWinAmt(uint256 round) public view returns(uint256){
        return winAmt[round];
    }

    function getCurrentPool() public view returns(uint256){
        return winPool;
    }

    function getCurrentRound() public view returns(uint256){
        return roundId;
    }

    function getBlocksLeft() public view returns(uint256){
        require(isRunActive==true,"Not started");
        return(roundFinished-block.number);
    }

    function startNewRound() internal{
        roundStarted=block.number;
        roundFinished=block.number+blockWait;
        isRunActive=true;
    }

    function closeRound() internal{
        require(currentWinner!=address(0));
        payable(currentWinner).transfer(winPool);
        winner[roundId]=currentWinner;
        winAmt[roundId]=winPool;
        winPool=0;
        currentWinner=address(0);
        roundId+=1;
        isRunActive=false;
    }

    function press() public payable{
        require(msg.value>=entryFee,"Invalid fee");
        if(isRunActive==false){
            startNewRound();
            winPool+=(msg.value)-((msg.value/100)*10);
            feePool+=((msg.value/100)*10);
            currentWinner=msg.sender;            
        }
        if(block.number>roundFinished && isRunActive==true){
            closeRound();
        }
        if(block.number<roundFinished && isRunActive==true){
            winPool+=msg.value;
            currentWinner=msg.sender;
        }

    }

}