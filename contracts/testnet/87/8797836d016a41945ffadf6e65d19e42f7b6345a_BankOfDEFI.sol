/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.0;

    // ===================================== CONTRACT BODY =====================================

interface ERC20token {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender == owner)
            _;
    }

    modifier everyoneElseBesideOwner() {
        if (msg.sender != owner)
            _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) owner = newOwner;
    }
}

contract SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract BankOfDEFI is Ownable, SafeMath {
    ERC20token public USDT;
    uint256 public stakingFee; // percentage
    uint256 public unstakingFee; // percentage
    uint256 public round = 1;
    uint256 public totalStakes = 0;
    uint256 public totalDividends = 0;
    uint256 private scaling = 10 ** 10;
    uint256 public refbonus;
    uint256 public TotalUsers;
    bool public stakingStopped = false;
    address public acceleratorAddress = address(0);

    struct Staker {
        uint256 stakedTokens;
        uint256 round;
        uint256 remainder;
    }

    mapping(address => Staker) public stakers;
    mapping(uint256 => uint256) public payouts;
    mapping (address => uint256) private balances;
    mapping (address => bool) public enrolled;
    mapping (address => uint256) private referals;
    mapping (address => uint256) private referalRewards;
    mapping (address => uint256) private fixedtime;

    constructor(address _erc20token_address, uint256 _stakingFee, uint256 _unstakingFee) public {
        USDT = ERC20token(_erc20token_address);
        stakingFee = _stakingFee;
        unstakingFee = _unstakingFee;
    }

    // ==================================== EVENTS ====================================
    event staked(address staker, uint256 tokens, uint256 fee);
    event unstaked(address staker, uint256 tokens, uint256 fee);
    event payout(uint256 round, uint256 tokens, address sender);
    event claimedReward(address staker, uint256 reward);
    event LogEnrolled(address indexed accountAddress);
    event LogDepositMade(address indexed accountAddress, uint amount);
    event LogWithdrawal(address indexed accountAddress, uint withdrawAmount, uint newBalance);
    event LogTransfer(address indexed accountAddress, uint TransferAmount, uint newBalance, address addressTo);
    // ==================================== /EVENTS ====================================

    // ==================================== MODIFIERS ====================================
    modifier onlyAccelerator() {
        require(msg.sender == address(acceleratorAddress));
        _;
    }

    modifier checkRegistered() {
        require(enrolled[msg.sender] == true, "Please enroll first");
        _;
    }

    modifier checkIfStakingStopped() {
        require(!stakingStopped, "Staking is stopped.");
        _;
    }
    // ==================================== /MODIFIERS ====================================

    // ==================================== CONTRACT ADMIN ====================================
    function stopUnstopStaking() external onlyOwner {
        if (!stakingStopped) {
            stakingStopped = true;
        } else {
            stakingStopped = false;
        }
    }

    function setFees(uint256 _stakingFee, uint256 _unstakingFee) external onlyOwner {
        require(_stakingFee <= 10 && _unstakingFee <= 10, "Invalid fees.");

        stakingFee = _stakingFee;
        unstakingFee = _unstakingFee;
    }

    function setAcceleratorAddress(address _address) external onlyOwner {
        acceleratorAddress = address(_address);
    }
    // ==================================== /CONTRACT ADMIN ====================================

    // ==================================== CONTRACT BODY ====================================

    function balance() public view returns (uint) {
        /* Get the balance of the sender of this transaction */
        return balances[msg.sender];
    }

    function referral() public view returns (uint) {
        /* Get the referal count of the sender of this transaction */
        return referals[msg.sender];
    }

    function userRefRewards() public view returns (uint) {
        /* Get the referal count of the sender of this transaction */
        return referalRewards[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    function enroll() public returns (bool) {
        enrolled[msg.sender] = true;
        TotalUsers += 1;
        return enrolled[msg.sender];
        emit LogEnrolled(msg.sender);
    }
    function setBonus(uint256 _bonus) external onlyOwner {
        refbonus = _bonus;
    }

    function refEnroll(address _ref) external returns (bool) {
    require(enrolled[msg.sender] == false, "User is already registered");
    require(enrolled[_ref] == true, "referee is not registered");
    enrolled[msg.sender] = true;
    TotalUsers += 1;
    referals[_ref] += 1;
    referalRewards[_ref] += refbonus;
    
    return enrolled[msg.sender];
    emit LogEnrolled(msg.sender);
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit(uint amtofTokens) external returns (uint) {
        require(enrolled[msg.sender] == true, "Please enroll first");
        require(amtofTokens > 0);
        require(USDT.transferFrom(msg.sender, address(this), amtofTokens), "Approve Tokens First.");
        balances[msg.sender] += amtofTokens;
        emit LogDepositMade(msg.sender, amtofTokens);
        return balance();
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    function withdraw(uint withdrawAmount) public returns (uint accountBalance) {
           require(enrolled[msg.sender] == true, "Please enroll first");
        /* If the sender's balance is at least the amount they want to withdraw,
           Subtract the amount from the sender's balance, and try to send that amount of ether
           to the user attempting to withdraw.
           return the user's balance.*/
           require(balances[msg.sender] >= withdrawAmount);
           USDT.transfer(msg.sender, withdrawAmount);
           balances[msg.sender] -= withdrawAmount;
           emit LogWithdrawal (msg.sender, withdrawAmount, balances[msg.sender]);
           return balances[msg.sender];
    } 
    function sendFunds(uint256 _amt, address _receiver) external returns (uint accountBalance) {
        require(enrolled[msg.sender] == true, "Please enroll first");
        require(enrolled[_receiver] == true, "Receiver is not enrolled");
        require(_amt > 0, "Please input valid amount");
        require(_amt <= balances[msg.sender], "Insufficient Funds");

        balances[msg.sender] -= _amt;
        balances[_receiver] += _amt;
        emit LogTransfer(msg.sender, _amt, balances[msg.sender], _receiver);
        return balances[msg.sender];
    }

    // function enrollref() internal returns (bool) {
    //     if (enrolled[msg.sender] = true) {
    //         revert ('User registered proceed to stake')
    //     } else {;
    //         enrolled[msg.sender] = true;
    //         return enrolled[msg.sender];
    //         emit LogEnrolled(msg.sender);
    //     }
    // }

    // function register() external onlyOwner returns (bool) {
    //     enrolled[msg.sender] = true;
    //     return enrolled[msg.sender];
    //     emit LogEnrolled(msg.sender);
    // }
    // 2419200

    function stake(uint256 _tokens_amount) private {
        require(enrolled[msg.sender] == true, "Please enroll first");
        require(_tokens_amount > 0, "Invalid token amount.");
        require(_tokens_amount <= balances[msg.sender]);

        uint256 _fee = 0;
        if (totalStakes  > 0) {
            // calculating this user staking fee based on the tokens amount that user want to stake
            _fee = div(mul(_tokens_amount, stakingFee), 100);
            _addPayout(_fee);
        }

        // if staking not for first time this means that there are already existing rewards
        uint256 existingRewards = getPendingReward(msg.sender);
        if (existingRewards > 0) {
            stakers[msg.sender].remainder = add(stakers[msg.sender].remainder, existingRewards);
        }

        // saving user staked tokens minus the staking fee
        stakers[msg.sender].stakedTokens = add(sub(_tokens_amount, _fee), stakers[msg.sender].stakedTokens);
        stakers[msg.sender].round = round;

        // adding this user stake to the totalStakes
        totalStakes = add(totalStakes, sub(_tokens_amount, _fee));

        emit staked(msg.sender, sub(_tokens_amount, _fee), _fee);
    }

    function stakeTime(uint256 _time) private {
        uint256 _set = block.timestamp;
        uint256 fTime = _set + _time;
        if (fixedtime[msg.sender] <= _set) {
            fixedtime[msg.sender] = fTime;
        } else {
            fixedtime[msg.sender] += _time;
        }
    }

    function initStake(uint256 _token, uint256 _time) external checkIfStakingStopped {
        stake(_token);

        if (_time != 0) {
            require(_time >= 2419200, "Minimum Stake is Four Weeks or set Time to zero");
            stakeTime(_time);
        } 
        if (_time == 0) {
            require(fixedtime[msg.sender] > block.timestamp, "No stake Owned");
        }
    }

    function acceleratorStake(uint256 _tokens_amount, address _staker) external checkIfStakingStopped onlyAccelerator {
        require(acceleratorAddress != address(0), "Invalid address.");
        require(_tokens_amount > 0, "Invalid token amount.");
        require(USDT.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");

        uint256 _fee = 0;
        if (totalStakes  > 0) {
            // calculating this user staking fee based on the tokens amount that user want to stake
            _fee = div(mul(_tokens_amount, stakingFee), 100);
            _addPayout(_fee);
        }

        // if staking not for first time this means that there are already existing rewards
        uint256 existingRewards = getPendingReward(_staker);
        if (existingRewards > 0) {
            stakers[_staker].remainder = add(stakers[_staker].remainder, existingRewards);
        }

        // saving user staked tokens minus the staking fee
        stakers[_staker].stakedTokens = add(sub(_tokens_amount, _fee), stakers[_staker].stakedTokens);
        stakers[_staker].round = round;

        // adding this user stake to the totalStakes
        totalStakes = add(totalStakes, sub(_tokens_amount, _fee));

        emit staked(_staker, sub(_tokens_amount, _fee), _fee);
    }

    function claimReward() external {
        require(enrolled[msg.sender] == true, "Please enroll first");
        uint256 pendingReward = getPendingReward(msg.sender);
        if (pendingReward > 0) {
            stakers[msg.sender].remainder = 0;
            stakers[msg.sender].round = round; // update the round

            require(USDT.transfer(msg.sender, pendingReward), "ERROR: error in sending reward from contract to sender.");

            emit claimedReward(msg.sender, pendingReward);
        }
    }

    function unstake(uint256 _tokens_amount) external {
        require(enrolled[msg.sender] == true, "Please enroll first");
        require(_tokens_amount > 0 && stakers[msg.sender].stakedTokens >= _tokens_amount, "Invalid token amount to unstake.");

        stakers[msg.sender].stakedTokens = sub(stakers[msg.sender].stakedTokens, _tokens_amount);
        stakers[msg.sender].round = round;

        // calculating this user unstaking fee based on the tokens amount that user want to unstake
        uint256 _fee = div(mul(_tokens_amount, unstakingFee), 100);

        // sending to user desired token amount minus his unstacking fee
        require(USDT.transfer(msg.sender, sub(_tokens_amount, _fee)), "Error in unstaking tokens.");

        totalStakes = sub(totalStakes, _tokens_amount);
        if (totalStakes > 0) {
            _addPayout(_fee);
        }

        emit unstaked(msg.sender, sub(_tokens_amount, _fee), _fee);
    }

    function addRewards(uint256 _tokens_amount) external checkIfStakingStopped {
        require(USDT.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");
        _addPayout(_tokens_amount);
    }

    function _addPayout(uint256 _fee) private {
        uint256 dividendPerToken = div(mul(_fee, scaling), totalStakes);
        totalDividends = add(totalDividends, dividendPerToken);
        payouts[round] = add(payouts[round-1], dividendPerToken);
        round+=1;

        emit payout(round, _fee, msg.sender);
    }

    function getPendingReward(address _staker) public view returns(uint256) {
        uint256 amount = mul((sub(totalDividends, payouts[stakers[_staker].round - 1])), stakers[_staker].stakedTokens);
        return add(div(amount, scaling), stakers[_staker].remainder);
    }

    function ClaimRefReward() external checkRegistered {
        require(referalRewards[msg.sender] > 0, "No rewards to claim");
        balances[msg.sender] += referalRewards[msg.sender];
        referalRewards[msg.sender] -= referalRewards[msg.sender];        
    }

    function userShareOfPool() public view returns(uint256) {
        uint256 userStaked = stakers[msg.sender].stakedTokens;
        uint256 UstakedToDec = userStaked * 10**18;
        uint256 shareOfPool = UstakedToDec/totalStakes;
        uint256 shareOfPoolT = shareOfPool/100;
        return shareOfPoolT;
    }
}