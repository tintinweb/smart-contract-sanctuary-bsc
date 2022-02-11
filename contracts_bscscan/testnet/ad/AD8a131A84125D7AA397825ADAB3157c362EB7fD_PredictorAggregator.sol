/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

pragma solidity ^0.8.10;

contract PredictorAggregator {
    mapping(address=>uint256) bank;
    address owner=0x020Ea6F53B4301A782DC8F658e35694cDda4d721;
    event newDeposit(uint256 amount,address user);
    function deposit() public payable{
        address payable thisContract=payable(address(this));
        thisContract.transfer(msg.value);
        emit newDeposit(msg.value,msg.sender);
    }

    function withdraw(uint256 amount,address to) public{
        require(msg.sender==owner);
        address payable requestor=payable(to);
        requestor.transfer(amount);

    }
}