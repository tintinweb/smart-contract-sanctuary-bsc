/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

pragma solidity ^0.8.0;

contract Wonka {
address public willy = 0xD72fc5f0b676fE591E6c036EadE7Dae5D25Ec7Bf;

function bye(address _wonka) public {
require(willy == msg.sender, "No eres Mr Wonka");
selfdestruct(payable(_wonka));
}
}