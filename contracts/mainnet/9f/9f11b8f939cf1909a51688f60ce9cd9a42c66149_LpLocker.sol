/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract LpLocker {
    uint256 public releaseTime;
    address public owner;
    
    constructor(uint releaseTime_) {
        releaseTime = releaseTime_;
        owner = msg.sender;
    }

    function withdraw(address lpToken) public {
        address beneficiary = msg.sender;
        require(beneficiary == owner, "invalid caller");
        require(block.timestamp >= releaseTime, "lock peroid is not meet");
        IERC20 erc20 = IERC20(lpToken);
        erc20.transfer(beneficiary, erc20.balanceOf(address(this)));
    }
}