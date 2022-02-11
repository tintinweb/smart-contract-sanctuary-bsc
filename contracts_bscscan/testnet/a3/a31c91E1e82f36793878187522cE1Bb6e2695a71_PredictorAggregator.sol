/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

pragma solidity ^0.8.10;

contract PredictorAggregator {
    mapping(address=>uint256) bank;
    address owner=0x020Ea6F53B4301A782DC8F658e35694cDda4d721;
    event bet(uint256 amount,address user,bool long);
    function deposit(bool islong) public payable{
        address payable thisContract=payable(address(this));
        thisContract.transfer(msg.value);
        emit bet(msg.value,msg.sender,islong);
    }

    function withdraw(uint256 amount,address to) public{
        require(msg.sender==owner);
        address payable requestor=payable(to);
        requestor.transfer(amount);

    }
}