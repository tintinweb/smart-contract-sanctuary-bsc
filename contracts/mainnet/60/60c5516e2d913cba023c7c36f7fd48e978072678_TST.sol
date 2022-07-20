/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

pragma solidity ^0.8.0;

interface ChiRS {
    function mint(uint256 value) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TST {
    ChiRS Chi = ChiRS(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    function TS1(uint256 a) public {
        Chi.mint(a);
    }
    function Withdraw(uint256 a) public {
        Chi.transfer(msg.sender,a);
    }
}