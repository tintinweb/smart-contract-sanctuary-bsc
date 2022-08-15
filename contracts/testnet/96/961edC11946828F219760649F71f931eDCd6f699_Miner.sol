/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity ^0.8.6; // compiler version

contract Miner {
    function transer() public payable {}
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}