/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

interface forInter {
    function Increase() external returns (uint256);
    }
contract connection{
    address public forInterAddr;

    function UpdateAddr(address _increase) public returns(bool){
        forInterAddr = _increase;
        return true;

    }

    function CallIncrease() public returns(bool){
        forInter(forInterAddr).Increase();
        return true;

    }
}