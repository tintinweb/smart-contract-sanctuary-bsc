/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

pragma solidity 0.6.0;

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

    modifier everyoneElseAsideOwner() {
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
    // ===================================== STAKING CONTRACT BODY =====================================

contract StakingProgram is Ownable, SafeMath {
    ERC20token public erc20tokenInstance;
    uint256 public stakingFee; // percentage
    uint256 public unstakingFee; // percentage
    uint256 public round = 1;
    uint256 public totalStakes = 0;
    uint256 public totalDividends = 0;
    uint256 internal scaling = 10 ** 10;
    bool public stakingStopped = false;
    address public acceleratorAddress = address(0);

    struct Staker {
        uint256 stakedTokens;
        uint256 round;
        uint256 remainder;
    }

    mapping(address => Staker) public stakers;
    mapping(uint256 => uint256) public payouts;

    constructor() public {
        erc20tokenInstance = ERC20token(0x5cE57d58B3C70a31975cC1AdC5FaC248Bf29C18C);
        stakingFee = 8;
        unstakingFee = 7;
    }

    // ==================================== EVENTS ====================================
    event staked(address staker, uint256 tokens, uint256 fee);
    event unstaked(address staker, uint256 tokens, uint256 fee);
    event payout(uint256 round, uint256 tokens, address sender);
    event claimedReward(address staker, uint256 reward);
    // ==================================== /EVENTS ====================================

    // ==================================== MODIFIERS ====================================
    modifier onlyAccelerator() {
        require(msg.sender == address(acceleratorAddress));
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
    function stake(uint256 _tokens_amount) external checkIfStakingStopped {
        require(_tokens_amount > 0, "Invalid token amount.");
        require(erc20tokenInstance.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");

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

    function acceleratorStake(uint256 _tokens_amount, address _staker) external checkIfStakingStopped onlyAccelerator {
        require(acceleratorAddress != address(0), "Invalid address.");
        require(_tokens_amount > 0, "Invalid token amount.");
        require(erc20tokenInstance.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");

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
        uint256 pendingReward = getPendingReward(msg.sender);
        if (pendingReward > 0) {
            stakers[msg.sender].remainder = 0;
            stakers[msg.sender].round = round; // update the round

            require(erc20tokenInstance.transfer(msg.sender, pendingReward), "ERROR: error in sending reward from contract to sender.");

            emit claimedReward(msg.sender, pendingReward);
        }
    }

    function addRewards(uint256 _tokens_amount) external checkIfStakingStopped {
        require(erc20tokenInstance.transferFrom(msg.sender, address(this), _tokens_amount), "Tokens cannot be transferred from sender.");
        _addPayout(_tokens_amount);
    }

    function _addPayout(uint256 _fee) internal {
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
}
    // ===================================== DEX BODY =====================================

contract DEX is StakingProgram {

    ERC20token public Usdt;
    ERC20token public Token;
    address public feeReceiver;
    uint256 public pUsdt;
    uint256 public pToken;
    uint256 public pool;
    uint256 public price;
    uint256 private deci = 10 ** 18;
    uint256 public stakeFromBuy;
    uint256 public PoolStartTime;
    uint256 public CurrentPoolTime;
    uint256 public timePeriod;

    event Bought(uint256 amount);
    event Sold(uint256 amount);


    constructor(address _wallet, ERC20token _token, ERC20token _usdt, uint256 _pUsdt, uint256 _pToken) public {
        require(_wallet != address(0));
        
        CurrentPoolTime = block.timestamp;
        PoolStartTime = block.timestamp;
        timePeriod = block.timestamp;
        
        feeReceiver = _wallet;
        Token = _token;
        Usdt = _usdt;
        pUsdt = _pUsdt * 10 ** 18;
        pToken = _pToken * 10 ** 18;
        pool = pUsdt * pToken;
        uint256 pSim = pUsdt * 10 ** 18;
        price = pSim/pToken;
        stakeFromBuy = 5;
  }
    function modifyPoolTime(uint256 _timePeriodInSeconds) external onlyOwner  {
        CurrentPoolTime = block.timestamp;
        timePeriod = CurrentPoolTime + _timePeriodInSeconds;
    }

    function setStakePercent(uint256 _sharePercent) external onlyOwner {
        require(_sharePercent > 0);
        require(_sharePercent <= 10);
        stakeFromBuy = _sharePercent;
    }

    function swapusdTforToken(uint256 iUsdt, uint256 slippage) external {
        require(slippage > 0 );
        require(slippage < 46 * deci);
        require(iUsdt > 0);

        uint256 feeFilter = iUsdt/price;
        uint256 filteredFee = feeFilter * deci;
        uint256 nUsdt = pUsdt + iUsdt;
        uint256 usdtamt = nUsdt - pUsdt;
        uint256 nToken = pool/nUsdt;
        uint256 nSim = nUsdt * deci;
        uint256 nPrice = nSim/nToken;
        uint256 pDiff = nPrice - price;
        uint256 diffSim = pDiff * deci;
        uint256 pImpact = diffSim/price;
        uint256 PriceImpact = pImpact * 100;
        uint256 tokensToSend = pToken - nToken;
        uint256 Impactfee = filteredFee - tokensToSend;
        price = nPrice;
        pUsdt = nUsdt;
        pToken = nToken - Impactfee;

       if (PriceImpact > slippage) {
           revert ('Price Impact too high');
       } else {
           Usdt.transferFrom(msg.sender, address(this), usdtamt);
           processStake(tokensToSend);
           _addPayout(Impactfee);
       }
        
    }

    function processStake(uint256 amtofTokens) internal {

        uint256 stakePercent = amtofTokens/100;
        uint256 stakeRatio = stakePercent * stakeFromBuy;
        uint256 amtToSend = amtofTokens - stakeRatio;
        uint256 amountToStake = amtofTokens - amtToSend;

        _stake(amountToStake);
        Token.transfer(msg.sender, amtToSend);
        emit Bought(amtToSend);
    }

    function swapTokenforusdT(uint256 iToken, uint256 slippage) external {
        require(slippage > 0 );
        require(slippage < 46 * deci);
        require(iToken > 0);

        
        uint256 feeFilter = iToken * price; //1250
        uint256 filteredFee = feeFilter * deci; //1250 * deci
        uint256 nToken = pToken + iToken;
        uint256 tokenAmt = nToken - pToken;
        uint256 nUsdt = pool/nToken;
        uint256 nSim = nUsdt * deci;
        uint256 nPrice = nSim/nToken;
        uint256 pDiff = price - nPrice;
        uint256 diffSim = pDiff * deci;
        uint256 pImpact = diffSim/price;
        uint256 PriceImpact = pImpact * 100;
        uint256 amtToSend = pUsdt - nUsdt;
        uint256 Impactfee = filteredFee - amtToSend;

        price = nPrice;
        pUsdt = nUsdt - Impactfee;
        pToken = nToken;

       if (PriceImpact > slippage) {
           revert ('Price Impact too high');
       } else {
           Token.transferFrom(msg.sender, address(this), tokenAmt);
           Usdt.transfer(msg.sender, amtToSend);
           Usdt.transfer(feeReceiver, Impactfee);
           emit Sold(amtToSend);
       }
        
    }
    function _stake(uint256 _tokens_amount) internal checkIfStakingStopped {
        require(_tokens_amount > 0, "Invalid token amount.");

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
    function unstake(uint256 _tokens_amount) external {
        require(_tokens_amount > 0 && stakers[msg.sender].stakedTokens >= _tokens_amount, "Invalid token amount to unstake.");

        stakers[msg.sender].stakedTokens = sub(stakers[msg.sender].stakedTokens, _tokens_amount);
        stakers[msg.sender].round = round;

        // calculating this user unstaking fee based on the tokens amount that user want to unstake
        uint256 _fee = div(mul(_tokens_amount, unstakingFee), 100);

        // sending to user desired token amount minus his unstacking fee
        require(erc20tokenInstance.transfer(msg.sender, sub(_tokens_amount, _fee)), "Error in unstaking tokens.");

        totalStakes = sub(totalStakes, _tokens_amount);
        if (totalStakes > 0) {
            _addPayout(_fee);
        }
        if (block.timestamp < timePeriod) {
            revert ("Tokens are only available after correct time period has elapsed");
        }

        emit unstaked(msg.sender, sub(_tokens_amount, _fee), _fee);
    }
    function updatefeeReceiver(address _newfeeReceiver) external onlyOwner {
        require(_newfeeReceiver != address(0));
        feeReceiver = _newfeeReceiver;
    }

}