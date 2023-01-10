/**
 *Submitted for verification at BscScan.com on 2023-01-09
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
    uint256 private  timeSlot ;
    uint256 private rewardPerMinutes ;
    uint256 private  lockTime ;
    uint256 private dropToken;
    uint256 private fee;
    uint256 private slotTime;

    address taxAddress;
    address[] private Stakeholders;

    struct Staking {
        uint256 stakedAmount;
        uint256 claimedReward;
        uint256 stakingTime;
        uint256 unstakeTime;
        uint256 withdrawlAmount;
    }

    mapping(address => Staking) public userInfo;

    constructor() {
        HPG = IERC20(0x991453ba35e8468C6F20561660CFaB2466DD1943);
        timeSlot = 1 minutes;
        rewardPerMinutes = 138888880000000; //0.2 reward
        lockTime = 10 minutes;
        slotTime = 10;
        dropToken = 200000000000000000000; // 200 token
        fee = 10; //10%
        taxAddress = 0xc2E3aDdd10F6C48082Ac8173B864dd304930E6d8;
    }
    /* 
        200*0.10% = 0.2
        0.2*365 = 73
        0.2/1440 = 0.00013888888 per minutes
    */

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
        userInfo[user].unstakeTime = block.timestamp.add(lockTime);
        Stakeholders.push(user);
    }

    function unstake() public {
        require(block.timestamp <= lockTime,"lock time not completed!");
        require(userInfo[msg.sender].stakedAmount > 0, "No staking found for the given user");
        HPG.transfer(msg.sender, userInfo[msg.sender].stakedAmount);
        userInfo[msg.sender].withdrawlAmount = userInfo[msg.sender].stakedAmount;
        userInfo[msg.sender].stakedAmount = 0;
    }

    function calcTime(address user) public view returns(uint256 time_){
        
        uint256 time = ((block.timestamp.sub(userInfo[user].stakingTime)).div(timeSlot));
        if(time >= slotTime){
            time_ =slotTime;
        }else{
           time_ = time; 
        }
    } 

    function calculateReward(address user) public view returns (uint256) {
        uint256 reward;
        uint256 time = calcTime(user);
        reward = rewardPerMinutes.mul(time);
        return reward.sub(userInfo[user].claimedReward);
    }

    function calculateFees(uint256 amount) private view returns(uint256 taxFee, uint256 transferFee){
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

    function setFee(uint256 feeAmount) public onlyOwner {
        fee = feeAmount;
    }

}
// ["0xC92cC6a8652F1A0639f2f42Cf531160D50aEb4F2","0xcCE1f97A492802a1B94E5Dc322feE6978DdFf276","0x3EF65b7ae37966a1d8775c58b569B2F02Dda493b","0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C","0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x617F2E2fD72FD9D5503197092aC168c91465E7f2","0xf8F76f766B39420019E4301ca7949279302D1A90"]