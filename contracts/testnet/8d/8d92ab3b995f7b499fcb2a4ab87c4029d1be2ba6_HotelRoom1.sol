/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract HotelRoom1{
    //Ether - pay smart contracts
    //Modifiers
    //Visibility
    //Events
    //Enums
    address payable public owner;// state variable ..payment will be sent to owner from user
    // payable -- here owner can receive payment in  ether 
    constructor()public { 
        owner = msg.sender;
        currentStatus = Statuses.vacant;
        
    }
    //room vacant
    // or occupied?
    //enum 
    enum Statuses{vacant,occupied} // enum doesn't end with semi-colon
    Statuses currentStatus ;
    // we can abstract the requirements into modifiers
    modifier onlyWhileVacant{ //this function is run before fn gets execucted..checks for requirements separately
       //check status
        require(currentStatus == Statuses.vacant, "Currently occupied..");//requirements to be fulfilled..constraints to be checked before ruuning below commands...you can specify an error msg "" if the condition fails and program in this fn halts...doen't procced further
         _;//this will execute the function body
    }
    modifier costs(uint _amount){
        //check price
        require(msg.value >= _amount, "Not sufficient ether provided...");
        _;
          
    }
    
    //Events - allow external consumers to subscribe to them
    // if u want to know if something happened in a smart contract
    //like a smart lock ...that unlocks hotel room by listening to events in blockchain
    event Occupy(address _occupant, uint _value);
    // receive - special fn will receive ether paid in smart contract automatically
    receive()external payable onlyWhileVacant costs(5 wei){
        owner .transfer(msg.value);// user pays through function book to the owner
        currentStatus = Statuses.occupied;//updating status
        emit Occupy(msg.sender,msg.value);
    }
    
    
}