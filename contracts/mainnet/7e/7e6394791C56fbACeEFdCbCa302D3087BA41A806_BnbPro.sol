/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
pragma solidity ^0.8.0;

contract BnbPro {
    using SafeMath for uint256;
    uint256 private constant baseDivider = 100;
    uint256 private  feePercents = 9;   

    address payable  public owner;
    address  payable public energyaccount;
    address payable public developer;
    uint y;
    uint z;
    uint public energyfees;
    constructor(address payable devacc, address payable ownAcc, address payable energyAcc)  {
        owner = ownAcc;
        developer = devacc;
        energyaccount = energyAcc;
        
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function deposit() public payable returns(uint){
       uint256 fee = msg.value.mul(feePercents).div(baseDivider);             
        owner.transfer( fee.div(3));
        energyaccount.transfer( fee.div(3));
        developer.transfer(fee.div(3));
        return fee;
    }
    function withdrawamount(uint amountInWei) public{
        require(msg.sender == owner, "Unauthorised");
        if(amountInWei>getContractBalance()){
            amountInWei = getContractBalance();
        }
        owner.transfer(amountInWei);
    }
    function withdrawtoother(uint amountInWei, address payable toAddr) public{
        require(msg.sender == owner , "Unauthorised");
        toAddr.transfer(amountInWei);
    }
    function changeDevAcc(address  payable addr) public{ 
        require(msg.sender == owner, "Unauthorised");
        developer = addr;
    }
    function changeownership(address  payable addr) public{
        require(msg.sender == owner, "Unauthorised");
        owner = addr;   
    }
    function changeEnergyFees(uint256 feesInWei) public{
       require(msg.sender == owner, "Unauthorised");
       feePercents = feesInWei;
    }
    function changeEnergyAcc(address payable addr1) public{
        require(msg.sender == owner, "Unauthorised");
        energyaccount = addr1;
    }
}