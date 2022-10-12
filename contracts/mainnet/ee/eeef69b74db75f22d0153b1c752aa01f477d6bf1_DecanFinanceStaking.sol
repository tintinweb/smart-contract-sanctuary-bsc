/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract DecanFinanceStaking{
    using SafeMath for uint256;
    BEP20 public decan = BEP20(0xee1c916AFc1aB015c76b27AFd4ED239941afEb62);
    address aggregator;
    uint16 reward = 40;
    event Staking(address depositor, address referral, uint256 amount);
    event ReStaking(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);
    
    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized owner.");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBalance){
        return contractBalance = decan.balanceOf(address(this));
    }

    constructor() public {
        aggregator = msg.sender;
    }

    function stake(address _referral, uint256 _decan) public security {
        decan.transferFrom(msg.sender,address(this),_decan);
        decan.transfer(_referral,_decan.mul(reward).div(100));
        emit Staking(msg.sender,_referral, _decan);
    }
    
    function restake(uint256 _decan) public security {
        decan.transferFrom(msg.sender,address(this),_decan);
        emit ReStaking(msg.sender, _decan);
    }
    
    function setReward(uint16 _percent) external security onlyAggregator{
        reward = _percent;
    }

    function stakeDistribution(address payable _staker, uint _decan) external security onlyAggregator{
        decan.transfer(_staker,_decan);
        emit StakeDistribution(_staker,_decan);
    }
    
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}