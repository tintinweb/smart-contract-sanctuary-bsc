/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

pragma solidity ^0.8.17;

contract Lesson17 {
    address public owner;
    uint256 public amount;
    uint public endTime;

    modifier onlyOwner {
        require(msg.sender == owner, "Not onwer");
        _;
    }

    function lock() public payable {
        owner = msg.sender;
        amount = msg.value;
        if(endTime == 0){
            endTime = block.timestamp + 5;
        }
    }

    function withdraw(uint256 _amount) public onlyOwner{
        require(amount <= _amount, "Fail amount");
        require(block.timestamp >= endTime, "Fail time");

        amount -= _amount;
        assert(amount >= 0);
        payable(owner).transfer(_amount);
    }

}