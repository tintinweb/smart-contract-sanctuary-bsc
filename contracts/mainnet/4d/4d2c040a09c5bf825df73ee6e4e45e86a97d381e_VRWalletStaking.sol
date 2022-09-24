/**
 *Submitted for verification at BscScan.com on 2022-09-24
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



contract VRWalletStaking {

    IERC20 public VRGWContract = IERC20(0xfDD2374be7ae7a71138B9f6b93d9eF034a49edB6);
    using SafeMath for uint256;
    uint public duration = 30 days;
    uint public apy = 30;
    uint256 public minimumStake = 25000;          
    address public owner;
    bool public StakeEnabled = true;


    mapping (address => uint256) public stakes;
    mapping (address => uint256) public rewards;
    mapping (address => uint256) public firstStake;
    mapping (address => uint256) public lastStake;


    event Stake(address userAddress, uint256 amount);
    event UnStake(address userAddress, uint256 amount);


    constructor() payable{
        owner = msg.sender;
    }

    function StakeToken(uint256 numberOfTokens) public {

        require(StakeEnabled,"Staking Not Available");
        require(numberOfTokens >= minimumStake.mul(uint(10).mul(VRGWContract.decimals())),"Staking Not Available");
        require(VRGWContract.transferFrom(msg.sender,address(this), numberOfTokens));

        rewards[msg.sender] = rewards[msg.sender].add(calculate(msg.sender));
        stakes[msg.sender] = stakes[msg.sender].add(numberOfTokens);
        if(lastStake[msg.sender]==0){
            firstStake[msg.sender] = block.timestamp;
        }
        lastStake[msg.sender] = block.timestamp;

        emit Stake(msg.sender, numberOfTokens);
    }


    function calculate(address addres) public view returns(uint256){
        uint256 stakedAmount  = stakes[addres];
        uint256 reward = rewards[addres];
        uint256 lastBuyTime = lastStake[addres];

        if(stakedAmount==0 || lastBuyTime ==0){
            return 0;
        }

        uint256 dailyReward = stakedAmount.mul(apy).div(uint(100)).div(uint(365));
        
        return reward.add(dailyReward.mul((block.timestamp - uint256(lastBuyTime)).div(86400)));
    }
    
    function unStake() public {

          //Checking if staking Exist
        require(stakes[msg.sender] > uint(0),"Don't have any staking");
    
        //Checking if staking matured
        require((block.timestamp - uint256(firstStake[msg.sender])).div(86400) >= duration,"Staking is not matured");
       
        //send back staking amount
        require(VRGWContract.transfer(msg.sender, stakes[msg.sender]));

        // send reward amount
        require(VRGWContract.transfer(msg.sender, calculate(msg.sender)));

        emit UnStake(msg.sender, stakes[msg.sender]);

        // reset all map data related to the address
        rewards[msg.sender] = uint(0);
        stakes[msg.sender] = uint(0);
        lastStake[msg.sender] = uint(0);


    }


    function withdraw() public {
        require(msg.sender == owner,"Only Owner can withdraw");
        require(VRGWContract.transfer(owner, VRGWContract.balanceOf(address(this))));
    }

    function transferOwnership(address newAddress) public {
        require((msg.sender == owner), "Only Owner can transfer ownership");
        owner = newAddress;
    }
}