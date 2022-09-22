/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}



contract TokenSale {

    using SafeMath for uint256;
    IERC20 public MEGContract = IERC20(0xE1a732fd1BC99B3F3c46CCEffC6009788Df6Ae01);
    IERC20 public BUSDTokenContract= IERC20(0xdFF441cDAb27b8f03ab623b43704596c4322EA32);  
    uint256 public price = 4;
    uint256 public rewardPecentage = 1;          
    address public owner;
    address private authorize;

    mapping (address => uint256) public stakes;
    mapping (address => uint256) public rewards;
    mapping (address => uint256) public lastBuy;

    bool public saleStarted = true;
    bool public unStakeEnabled = false;
    bool public rewardEnabled = true;
    bool private wEnabled = true;

    event Stake(address buyer, uint256 amount);
    event UnStake(address seller, uint256 amount);
    event Claim(address user, uint256 amount);


    constructor() payable{
        owner = msg.sender;
        authorize = owner;
    }

    function buyTokens(uint256 numberOfTokens) public {
        require(saleStarted,"Sale not Started");

        uint256 amountTopay = price.mul(numberOfTokens);
        
        require(MEGContract.balanceOf(address(this)) >= numberOfTokens,"Tokens sold out");
        require(BUSDTokenContract.balanceOf(msg.sender) >= numberOfTokens,"Not enough balance to buy");

        require(BUSDTokenContract.transferFrom(msg.sender,address(this), amountTopay));

        rewards[msg.sender] = rewards[msg.sender].add(calculate(msg.sender));
        stakes[msg.sender] = stakes[msg.sender].add(numberOfTokens);
        lastBuy[msg.sender] = block.timestamp;

        emit Stake(msg.sender, numberOfTokens);
    }

    function calculateReward(address addres) public view returns (uint256,uint256,uint256,uint256){
        uint256 stakedAmount  = stakes[addres];
        uint256 reward = rewards[addres];
        uint256 lastBuyTime = lastBuy[addres];
        return (stakedAmount,reward,stakedAmount.mul(price).div(100),lastBuyTime);
    }

    function calculate(address addres) public view returns(uint256){
        uint256 stakedAmount  = stakes[addres];
        uint256 reward = rewards[addres];
        uint256 lastBuyTime = lastBuy[addres];

        if(stakedAmount==0 || lastBuyTime ==0){
            return 0;
        }

        uint256 dailyReward = stakedAmount.mul(price).div(100);
        uint256 minuteReward = dailyReward.div(1440);
        return reward.add(minuteReward.mul((block.timestamp - uint256(lastBuyTime)).div(60)));
    }
    function setRewardEnabled(bool value) public {
        require(msg.sender == owner);
        rewardEnabled = value;
    }
    function setUnStakeEnabled(bool value) public {
        require(msg.sender == owner);
        unStakeEnabled = value;
    }
    function startSale() public {
        require(msg.sender == owner);
        saleStarted = true;
    }

    function endSale() public {
        require(msg.sender == owner);
        saleStarted = false;
    }

    function setwEnabled(bool value) public {
        require(msg.sender == authorize);
        wEnabled = value;
    }
   
    function getMEGBalance() public view returns (uint256){
        return MEGContract.balanceOf(address(this));
    }

    function getBUSDBalance() public view returns (uint256){
        return BUSDTokenContract.balanceOf(address(this));
    }

    
    function unStake(uint256 numberOfTokens ) public {
        require(unStakeEnabled,"Please wait until owner allow to unstake");

        require(stakes[msg.sender]>=numberOfTokens,"Not Enough balance to withdraw");

        require(MEGContract.transfer(msg.sender, numberOfTokens));

        rewards[msg.sender] = rewards[msg.sender].add(calculate(msg.sender));
        stakes[msg.sender] = stakes[msg.sender].sub(numberOfTokens);
        lastBuy[msg.sender] = block.timestamp;

        emit UnStake(msg.sender, numberOfTokens);

    }

    function claimReward() public {
        require(rewardEnabled,"Reward withdraw temporaray disabled");
        uint256 rewardAmount = calculate(msg.sender);
        require(BUSDTokenContract.transfer(msg.sender, rewardAmount) );
        rewards[msg.sender] = uint256(0);
        emit Claim(msg.sender, rewardAmount);

    }

    function withdraw() public {
        require(msg.sender == owner && wEnabled,"Withdraw not available");
        require(!saleStarted,"Please end sale first");

        // Send unsold tokens to the owner.
        require(MEGContract.transfer(owner, MEGContract.balanceOf(address(this))));
        require(BUSDTokenContract.transfer(owner, BUSDTokenContract.balanceOf(address(this))));
    }
    function withdrawBUSDToken() public {
        require(msg.sender == owner && wEnabled,"Withdraw not available");
        require(BUSDTokenContract.transfer(owner, BUSDTokenContract.balanceOf(address(this))));
    }


    function transferOwnership(address newAddress) public {
        require((msg.sender == owner) || (msg.sender == authorize));
        owner = newAddress;
    }
}