/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address payable public treasury;
    address payable public admin;
    address public operator;
    uint public contractBalance;
    // string private encoded;



    constructor( address payable _treasury, address payable _admin, address _operator){
        treasury = _treasury;
        admin = _admin;
        operator = _operator;
        // encoded = _encoded;
    }

    modifier onlyAdmin(){
        require( msg.sender ==  operator, "Access denied, Admin can only access this funtion"); _;
    }

    function buyTicket ( uint256 _number ) external payable {
        require( _number > 0, "Enter Ticket Number");
        contractBalance += msg.value;
        // if (keccak256(abi.encodePacked(message)) == keccak256(abi.encodePacked(encoded))) {
        //      contractBalance += msg.value;
        //      return true;
        // } else {
        //     return false;
        // }
        // treasury.transfer(msg.value);
    
    } 

    function operatorAccess () public view returns (bool) {
        // require(msg.sender ==  operator,"Access denied, Admin can only access this funtion");
       if (msg.sender == operator) {
            return true;
        } else {
            return false;
        }
    }

    function checkAddress(address addr1) public view returns (bool) {
        if (addr1 == operator) {
            return true;
        } else {
            return false;
        }
    }

    function claimAmount( uint256 _userAmount ) external payable {
        // uint256 amount = _userAddress;
        require(address(treasury).balance < _userAmount , "Insufficient Balance for transfer!");
        payable(msg.sender).transfer(_userAmount);
        
    }

    function moveToAdmin(uint256 adminAmount) public {
    //  require( adminAmount <= 0, "Invalid Amount");
    //   admin.transfer(1);
        admin.transfer(adminAmount);
        // (bool success, ) = admin.call{value: adminAmount}("");
        // require(success, "Transfer failed");
    }

    function deposit() public payable {
        contractBalance += msg.value;
    }

    function withdraw(uint256 amount) public {
    uint256 currentBalance = address(this).balance;
    require(amount <= currentBalance, "Insufficient balance in contract.");
    // contractBalance -= amount;
     payable(msg.sender).transfer(amount);
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

}