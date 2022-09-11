/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: No

// staking SAFU

// AAA

pragma solidity ^0.8.4;


abstract contract Context {
    constructor() {

    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract Staking is Context, Pausable{

    uint256 public duration;
    uint256 public whenfinish;
    uint256 public lastupdate;
    uint256 public RateForRewards;
    uint256 public rewardPerTokenStored;
    uint256 public triggerwithdrawalfee;
    uint256 public remainingTokensStaked;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastclaimedtime;
    mapping(address => uint256) public lastTimeStaked;


    IERC20 public immutable stakingToken;

    address public owner;
    address public SafuDev;

    uint256 public MaxTokensStaked; // 10% of total supply of the main token.
    uint256 public totalSupply; // amount of all token staked

    mapping(address => uint256) public balanceOf;

    constructor(address _stakingToken, address _SafuDev) {
        SafuDev = _SafuDev;
        stakingToken = IERC20(_stakingToken);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == SafuDev, "not authorized");
        _;
    }

    modifier onlySafu() {
        require(msg.sender == SafuDev, "not authorized");
        _;
    }


    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastupdate = LastTime();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    function LastTime() public view returns (uint256) {
        return confronta(whenfinish, block.timestamp);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (RateForRewards * (LastTime() - lastupdate) * 1e9) /
            remainingTokensStaked;
    }


    function stake(uint256 _amount) external whenNotPaused updateReward(msg.sender) {
        require(totalSupply + _amount <= MaxTokensStaked,"Can't stake more than 10% of total supply");
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount); // make sure to add in the js the approve function. 
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
        lastclaimedtime[msg.sender] = block.timestamp;
    }

    function updateMaxTokensStaked(uint256 amount) external onlyOwner{
        require(amount > 0);
        MaxTokensStaked = amount;
    }




    function pause() external onlySafu { // Contract Owner cannot pause smart contract only SAFU Developer
        _pause();
    }

    function unpause() external onlySafu { // Contract Owner cannot unpause smart contract only SAFU Developer
        _unpause();
    }

    function withdraw(uint256 _amount) external whenNotPaused updateReward(msg.sender) {
        uint256 fees;
        uint256 finalBalance;
        require(block.timestamp > lastclaimedtime[msg.sender], "cannot claim in the same block"); // No claim in the same blocks
        require(_amount > 0, "amount = 0"); // Amunt should be greater than 0
        require(balanceOf[msg.sender] >= _amount, "Cannot withdraw more"); // No claim more than actual balance

        // check if block time passed if not apply fees
        if(lastclaimedtime[msg.sender] >= block.timestamp + triggerwithdrawalfee) {

        balanceOf[msg.sender] -= _amount; 
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);

        } else {

        fees = (balanceOf[msg.sender] * 10) / 100; // calculate fees
        finalBalance = balanceOf[msg.sender] - fees; // calculate final withdrawal balance
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(owner, fees); // transfer fees to the owner address
        stakingToken.transfer(msg.sender, finalBalance); } // transfer final withdrawal balance to the msg.sender address

    }

    function earned(address _account) public view returns (uint256) {
        return
            ((balanceOf[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e9) +
            rewards[_account];
    }

    function ClaimRewards() external whenNotPaused updateReward(msg.sender) {
        require(block.timestamp > lastclaimedtime[msg.sender], "cannot claim in the same block");
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
        }
    }


    // Contract owner cannot claim tokens only SAFU Developer.
    function TokenWithdrawSAFU(address token, uint256 amount) external onlySafu {

        // Do not need to withdraw BNB as smart contract will revert every transaction.

        IERC20 _token = IERC20(token);
        _token.transfer(msg.sender, amount);
    } 

    function depositTokenForStaking(uint256 amount) external whenNotPaused onlyOwner {
        uint256 balanceContractTokens = stakingToken.balanceOf(address(this));
        require(balanceContractTokens == 0, "Tokens already in the smart contract");
        require(amount > 0, "amount = 0");
        remainingTokensStaked = amount;
        stakingToken.transferFrom(msg.sender, address(this), amount); // must allowance >= amount;
    }

    // when should finish the staking
    function setFinish(uint256 _duration) external onlyOwner {
        require(whenfinish < block.timestamp, "reward duration not finished");
        duration = _duration;
    }


    // WithdrawalLockFee
    function setTriggerWithdrawalFees(uint256 _time) external onlyOwner {
        require(_time <= 86400, "no more than 86400 blocks");
        triggerwithdrawalfee = _time;
    }


    function ResetSettings() external onlySafu {
        RateForRewards = 0;
        whenfinish = block.timestamp;
        lastupdate = block.timestamp;
        remainingTokensStaked = 0;
        triggerwithdrawalfee = 0;
    }

    function ChangeRewardAmount(uint256 _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        if (block.timestamp >= whenfinish) {
            RateForRewards = _amount / duration;
        } else {
            uint256 remainingRewards = (whenfinish - block.timestamp) * RateForRewards;

            RateForRewards = (_amount + remainingRewards) / duration;
        }

        require(RateForRewards > 0, "reward rate = 0");
        require(
            RateForRewards * duration <= stakingToken.balanceOf(address(this)),
            "reward amount > balance"
        );

        whenfinish = block.timestamp + duration;
        lastupdate = block.timestamp;
    }

    function confronta(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}