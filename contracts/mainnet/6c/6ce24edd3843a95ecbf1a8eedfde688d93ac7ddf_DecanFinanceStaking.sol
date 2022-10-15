/**
 *Submitted for verification at BscScan.com on 2022-10-15
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

    event Staking(address depositor, address referral, uint256 amount);
    event ReStaking(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);

    BEP20 public decan = BEP20(0xee1c916AFc1aB015c76b27AFd4ED239941afEb62);
    address aggregator;
    address lapseAccount;
    uint16 reward = 40;
    
    struct User{
        uint256 capping;
        uint256 stakeTime;
    }

    mapping(address => User) public users;

    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized aggregator.");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }
    
    function getLapseAccount() view public returns(address _lapseAccount){
        return lapseAccount;
    }

    function getRewardInfo() view public returns(uint16 _reward){
        return reward;
    }

    function getContractInfo() view public returns(uint256 contractBalance){
        return contractBalance = decan.balanceOf(address(this));
    }

    constructor() public {
        aggregator = msg.sender;
        users[aggregator].capping = 500;
        users[aggregator].stakeTime = block.timestamp;
    }

    function stake(address _referral, uint256 _decan) public security {
        require(users[_referral].capping>=10,"Invalid referral or capping.");
        decan.transferFrom(msg.sender,address(this),_decan);
        uint256 referralReward = _decan.div(1e18).mul(reward).div(100);
        uint256 lapseAmount;
        
        if(referralReward>users[_referral].capping){
            lapseAmount = referralReward.sub(users[_referral].capping);
            referralReward = referralReward.sub(lapseAmount);
            decan.transfer(lapseAccount,lapseAmount.mul(1e18));
        }
        
        decan.transfer(_referral,referralReward.mul(1e18));
        users[msg.sender].capping += _decan.div(1e18);
        users[msg.sender].stakeTime = block.timestamp;
        emit Staking(msg.sender,_referral, _decan);
    }
    
    function setReward(uint16 _percent) external security onlyAggregator{
        reward = _percent;
    }

    function setLapseAccount(address _lapseAccount) external security onlyAggregator{
        lapseAccount = _lapseAccount;
    }

    function stakeDistribution(address _staker, uint _decan) external security onlyAggregator{
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