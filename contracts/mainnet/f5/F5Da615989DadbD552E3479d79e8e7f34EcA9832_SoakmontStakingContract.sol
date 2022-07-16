//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract SoakmontStakingContract is Ownable, IERC20 {

    using SafeMath for uint256;

    // lock time in blocks
    uint256 public lockTime = 2592000;

    // fee for leaving staking early
    uint256 public leaveEarlyFee = 10;

    // recipient of fee
    address public feeRecipient;

    // recipient of fee
    address public swapper;

    // Staking Token
    address public immutable token;

    // Reward Token
    address public immutable reward;

    // User Info
    struct UserInfo {
        uint256 amount;
        uint256 unlockBlock;
        uint256 totalExcluded;
    }
    // Address => UserInfo
    mapping ( address => UserInfo ) public userInfo;

    // Tracks Dividends
    uint256 public totalRewards;
    uint256 private totalShares;
    uint256 private dividendsPerShare;
    uint256 private constant precision = 10**18;

    // Events
    event SetLockTime(uint LockTime);
    event SetEarlyFee(uint earlyFee);
    event SetFeeRecipient(address FeeRecipient);
    event DepositRewards(uint256 tokenAmount);

    constructor(address token_, address feeRecipient_, address reward_){
        require(
            token_ != address(0) &&
            feeRecipient_ != address(0) &&
            reward_ != address(0),
            'Zero Address'
        );
        token = token_;
        feeRecipient = feeRecipient_;
        reward = reward_;
        swapper = reward_;
    }

    /** Token Name */
    function name() public pure override returns (string memory) {
        return "Staked Soakmont V2";
    }

    /** Token Ticker Symbol */
    function symbol() public pure override returns (string memory) {
        return "StakedSKMT";
    }

    /** Returns the total number of tokens in existence */
    function totalSupply() external view override returns (uint256) { 
        return totalShares; 
    }

    /** Returns the number of tokens owned by `account` */
    function balanceOf(address account) public view override returns (uint256) { 
        return userInfo[account].amount;
    }

    /** Returns the number of tokens `spender` can transfer from `holder` */
    function allowance(address, address) external pure override returns (uint256) { 
        return 0; 
    }

    /** Tokens decimals */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /** Approves `spender` to transfer `amount` tokens from caller */
    function approve(address spender, uint256) public override returns (bool) {
        emit Approval(msg.sender, spender, 0);
        return true;
    }
  
    /** Transfer Function */
    function transfer(address recipient, uint256) external override returns (bool) {
        _claimReward(msg.sender);
        emit Transfer(msg.sender, recipient, 0);
        return true;
    }

    /** Transfer Function */
    function transferFrom(address, address recipient, uint256) external override returns (bool) {
        _claimReward(msg.sender);
        emit Transfer(msg.sender, recipient, 0);
        return true;
    }

    function setLockTime(uint256 newLockTime) external onlyOwner {
        require(
            newLockTime < 2592000,
            'Lock Time Too Long'
        );
        lockTime = newLockTime;
        emit SetLockTime(newLockTime);
    }

    function setLeaveEarlyFee(uint256 newEarlyFee) external onlyOwner {
        require(
            newEarlyFee < 10,
            'Fee Too High'
        );
        leaveEarlyFee = newEarlyFee;
        emit SetEarlyFee(newEarlyFee);
    }

    function setFeeRecipient(address newFeeRecipient) external onlyOwner {
        require(
            newFeeRecipient != address(0),
            'Zero Address'
        );
        feeRecipient = newFeeRecipient;
        emit SetFeeRecipient(newFeeRecipient);
    }

    function setSwapper(address newSwapper) external onlyOwner {
        require(
            newSwapper != address(0),
            'Zero Address'
        );
        swapper = newSwapper;
    }

    function withdrawToken(address token_) external onlyOwner {
        require(
            token != token_,
            'Cannot Withdraw Staked Token'
        );
        require(
            IERC20(token_).transfer(
                msg.sender,
                IERC20(token_).balanceOf(address(this))
            ),
            'Failure On Token Withdraw'
        );
    }

    function claimRewards() external {
        _claimReward(msg.sender);
    }

    function unstake(uint256 amount) external {
        require(
            amount <= userInfo[msg.sender].amount,
            'Insufficient Amount'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        if (userInfo[msg.sender].amount > 0) {
            _claimReward(msg.sender);
        }

        totalShares -= amount;
        userInfo[msg.sender].amount -= amount;
        userInfo[msg.sender].totalExcluded = getCumulativeDividends(userInfo[msg.sender].amount);

        uint fee = timeUntilUnlock(msg.sender) == 0 ? 0 : ( amount * leaveEarlyFee ) / 100;
        if (fee > 0) {
            require(
                IERC20(token).transfer(feeRecipient, fee),
                'Failure On Token Transfer'
            );
        }

        uint sendAmount = amount - fee;
        require(
            IERC20(token).transfer(msg.sender, sendAmount),
            'Failure On Token Transfer To Sender'
        );
    }

    function stake(uint256 amount) external {
        if (userInfo[msg.sender].amount > 0) {
            _claimReward(msg.sender);
        }

        // transfer in tokens
        uint received = _transferIn(token, amount);
        
        // update data
        totalShares += received;
        userInfo[msg.sender].amount += received;
        userInfo[msg.sender].unlockBlock = block.number + lockTime;
        userInfo[msg.sender].totalExcluded = getCumulativeDividends(userInfo[msg.sender].amount);
    }

    function depositRewards(uint256 amount) external {
        uint received = _transferIn(reward, amount);
        dividendsPerShare = dividendsPerShare.add(precision.mul(received).div(totalShares));
        totalRewards += received;
        emit DepositRewards(amount);
    }


    function _claimReward(address user) internal {

        // exit if zero value locked
        if (userInfo[user].amount == 0) {
            return;
        }

        // fetch pending rewards
        uint256 amount = pendingRewards(user);
        
        // exit if zero rewards
        if (amount == 0) {
            return;
        }

        // update total excluded
        userInfo[msg.sender].totalExcluded = getCumulativeDividends(userInfo[msg.sender].amount);

        // transfer reward to user
        require(
            IERC20(reward).transfer(user, amount),
            'Failure On Token Claim'
        );
    }

    function _transferIn(address _token, uint256 amount) internal returns (uint256) {
        uint before = IERC20(_token).balanceOf(address(this));
        bool s = IERC20(_token).transferFrom(msg.sender, address(this), amount);
        uint received = IERC20(_token).balanceOf(address(this)) - before;
        require(
            s && received > 0 && received <= amount,
            'Error On Transfer From'
        );
        return received;
    }

    function timeUntilUnlock(address user) public view returns (uint256) {
        return userInfo[user].unlockBlock < block.number ? 0 : userInfo[user].unlockBlock - block.number;
    }

    function pendingRewards(address shareholder) public view returns (uint256) {
        if(userInfo[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(userInfo[shareholder].amount);
        uint256 shareholderTotalExcluded = userInfo[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(precision);
    }

    receive() external payable {
        uint before = IERC20(reward).balanceOf(address(this));
        (bool s,) = payable(swapper).call{value: address(this).balance}("");
        require(s, 'Failure On Reward Purchase');
        uint received = IERC20(reward).balanceOf(address(this)).sub(before);
        dividendsPerShare = dividendsPerShare.add(precision.mul(received).div(totalShares));
        totalRewards += received;
    }
}