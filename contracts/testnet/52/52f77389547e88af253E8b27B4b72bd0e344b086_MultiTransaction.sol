/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT

interface IMasterChef {
//    function () external view returns (uint);
    function deposit(uint256 _pid, uint256 _amount) external;
}

contract MultiTransaction {
    address MasterChefAddr;

    function setCounterAddr(address _MasterChef) public payable {
       MasterChefAddr = _MasterChef;
    }

    function deposit(uint256 _pid, uint256 _amount)  public {
        IMasterChef(MasterChefAddr).deposit(_pid, _amount);
    }
}