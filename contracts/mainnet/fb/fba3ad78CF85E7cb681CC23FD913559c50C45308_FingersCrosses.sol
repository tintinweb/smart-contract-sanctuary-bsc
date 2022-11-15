/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FingersCrosses{

    Round[] public arrayRound;
    address public owner;
    address[] public spinners;
    
    struct Round{
        string roundNo;
        uint256 small;
        uint256 big;
        uint256 dateCreate;
        uint blockNumber;
    }

    constructor(){
        owner = msg.sender;
    }

    modifier checkOwner(){
        require(msg.sender==owner);
        _;
    }

    modifier checkSpinner(){
        bool check = false;
        for(uint  i=0; i<spinners.length; i++){
            if(spinners[i]==msg.sender){
                check=true;
            }
        }
        require(check==true, "Sorry, you are not spinner.");
        _;
    }

    event Blockchain_random_numbers_result(string roundNo,
        uint256 small,
        uint256 big,
        uint256 dateCreate,
        uint blockNumber
    );

    function FingersCrossedGetRandomNumber(string memory roundNumber) public checkSpinner {
        uint256 small = rand(10);
        uint256 big = rand(100);
        Round memory newRound = Round(roundNumber, small, big, block.timestamp, block.number);
        arrayRound.push(newRound);
        emit Blockchain_random_numbers_result(newRound.roundNo,
        newRound.small,
        newRound.big,
        newRound.dateCreate,
        newRound.blockNumber);
    }

    function getRoundDetail(string memory _roundNumber) public view returns(string memory, uint256, uint256, uint256){
        for(uint i=0; i<arrayRound.length; i++){
            if(keccak256(bytes(arrayRound[i].roundNo)) == keccak256(bytes(_roundNumber))){
                return(arrayRound[i].roundNo,arrayRound[i].small,arrayRound[i].big, arrayRound[i].blockNumber);
            }
        }
        return("0",0,0,0);
    }

    function rand(uint256 max) public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        uint256 aabb =  seed - ( (seed/10000)*10000 );
        uint256 aa = aabb/100;
        uint256 bb = seed - ((seed/100)*100);
        uint256 cc = aa+bb;

        return (cc - ((cc / max) * max));
    }

    // function rand(uint256 max) public view returns(uint256)
    // {
    //     uint256 seed = uint256(keccak256(abi.encodePacked(
    //         block.timestamp + block.difficulty +
    //         ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
    //         block.gaslimit + 
    //         ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
    //         block.number
    //     )));
    //     return (seed - ((seed / max) * max));
    // }

    function updateSpinners(address[] memory spinnersArray) public checkOwner{
        spinners = spinnersArray;
    }

    // function changeOwnerAddress(address newAddress) public checkOwner{
    //     require(newAddress != address(0), "Wrong address");
    //     owner = newAddress;
    // }

}