/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

pragma solidity >=0.7.0 <0.9.0;

contract Callee {

    event alRight(uint256);

    function receiveCall(uint256 n) external{
        emit alRight(n);
    }
}