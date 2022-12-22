/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns(uint256);
    function transfer(address receiver, uint256 tokenAmount) external  returns(bool);
    function transferFrom( address tokenOwner, address recipient, uint256 tokenAmount) external returns(bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Airdrop is Ownable {
    using SafeMath for uint256;

    IERC20 public HPG;
    uint256 public  timeSlot ;
    uint256 public rewardPerMinutes ;
    uint256 public  lockTime ;
    uint256 public dropToken;
    uint256 public fee;

    address taxAddress;

    address[] public Stakeholders;

    struct Staking {
        uint256 stakedAmount;
        uint256 claimedReward;
        uint256 stakingTime;
        uint256 withdrawlAmount;
    }

    mapping(address => Staking) public userInfo;

    constructor() {
        HPG = IERC20(0xa4991a918f8459DCB9DCc707a13655Ac07a8b02E);
        timeSlot = 1 minutes;
        rewardPerMinutes = 138888880000000; //0.2 reward
        lockTime = 525600;
        dropToken = 200000000000000000000; // 200 token
        fee = 10; //10%
        taxAddress = 0xc2E3aDdd10F6C48082Ac8173B864dd304930E6d8;
    }
 
    function TokensDrop(address[] memory _recipients) public onlyOwner returns (bool) {
       
        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0));
            lockStake(_recipients[i], dropToken);
        }
        return true;
    }

    function lockStake(address user,uint256 amount) private {
        userInfo[user].stakedAmount = amount;
        userInfo[user].stakingTime = block.timestamp;
        Stakeholders.push(user);
    }

    function unstake() public {
        require(block.timestamp <= lockTime,"lock time not completed!");
        require(userInfo[msg.sender].stakedAmount > 0, "No staking found for the given user");
        HPG.transfer(msg.sender, userInfo[msg.sender].stakedAmount);
        userInfo[msg.sender].withdrawlAmount = userInfo[msg.sender].stakedAmount;
        userInfo[msg.sender].stakedAmount = 0;
    }

    function calculateReward(address user) public view returns (uint256 reward) {
        uint256 time = (block.timestamp.sub(userInfo[user].stakingTime)).div(timeSlot);
        reward = rewardPerMinutes.mul(time);
        return reward.sub(userInfo[user].claimedReward);
    }

    function calculateFees(uint256 amount) public view returns(uint256 taxFee, uint256 transferFee){
        taxFee = (amount.mul(fee)).div(100);
        transferFee = amount.sub(taxFee);
    }

    function claimReward(address user) public {
        (uint256 taxAmount , uint256 transferAmount) = calculateFees(calculateReward(user));
        uint256 reward = calculateReward(user);
        HPG.transfer(taxAddress, taxAmount);
        HPG.transfer(user, transferAmount);
        userInfo[user].claimedReward = userInfo[user].claimedReward.add(reward);
    }

    function getStakeHolders() public view returns(uint256){
        return Stakeholders.length;
    }


}