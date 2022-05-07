/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT



interface IMasterChef {
//    function () external view returns (uint);
    function deposit(uint256 _pid, uint256 _amount) external;
    function poolLength() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract MultiTransaction {
    address MasterChefAddr;

    function setCounterAddr(address _MasterChef) public payable {
       MasterChefAddr = _MasterChef;
    }

    function deposit(uint256 _pid, uint256 _amount)  public {
        IMasterChef(MasterChefAddr).deposit(_pid, _amount);
    }

    function poolLength() external view returns (uint256) {
        return IMasterChef(MasterChefAddr).poolLength();
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        IMasterChef(MasterChefAddr).transfer(recipient, amount);
        return true;
    }

}