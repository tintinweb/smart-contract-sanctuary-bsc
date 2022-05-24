/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract CryptoPie {
    mapping(address => uint256) public addressToLastProcess;
    address public owner;
    uint256 public subscriptionSeconds = 20;
    uint256 public subscriptionPrice = 10 * (10 ** 18);
    uint256 public subscriptionFee = 1 * (10 ** 18);
    address public businessAddress = 0x81Ca88F4719Df39a751c632D57150B966D8938ef;
    IERC20 usdt = IERC20(address(0x55d398326f99059fF775485246999027B3197955));

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function process(address user) public onlyOwner {
        require(usdt.allowance(user, address(this)) >= subscriptionPrice, "User did't give permission");
        uint256 time_now = block.timestamp;
        require(time_now > subscriptionSeconds + addressToLastProcess[user], "Not enough time passed");
        addressToLastProcess[user] = time_now;
        usdt.transferFrom(user, address(this), subscriptionPrice);
        usdt.transfer(businessAddress, subscriptionPrice - subscriptionFee);
    }
    
    function claim_fees() public onlyOwner {
        usdt.transfer(owner, usdt.balanceOf(address(this)));
    }
}