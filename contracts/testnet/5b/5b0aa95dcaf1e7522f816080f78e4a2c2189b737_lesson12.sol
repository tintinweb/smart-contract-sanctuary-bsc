/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

pragma solidity ^0.8.17;

contract lesson12 {
    uint256 public balances;
    address public owner;

    function deposion() public payable {
        owner = msg.sender;
        balances = msg.value;
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}