/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



// Part: ICrowdFundBasic

interface ICrowdFundBasic {
    struct PledgeInfo {
        uint256 total;
        address referrer;
        uint256 referrals;
        uint256 refAmount;
        uint256 whitelistAmount;
        bool claimed;
    }

    event Pledge(address indexed user, uint256 amount, address referrer);
    event RaiseStart(uint256 endTime, bool whitelist);
    event Claim(address indexed user, uint256 claim_amount);

    /// @notice Send funds to the crowdfund contract to safekeep while raise is in progress
    /// @param amount Amount to pledge
    /// @dev This function is payable since we might take in ETH
    function pledge(uint256 amount) external payable;

    /** @notice variant of pledge, if not used, simply revert
     *   @param amount the amount of TOKEN to pledge
     *   @param affiliate the referral wallet.
     *   @dev This function is payable since we might take in ETH
     *   @dev Checks to make:
     *     amount is in specific intervals (optional)
     *     referral is not empty
     *     referral is already pledged in
     */
    function pledgeReferred(uint256 amount, address affiliate) external payable;

    /// @notice Claims allocated reward tokens based on tokensPerETH (IF APPLIES)
    /// @dev Make sure function is only able to be called once.
    function claim() external;

    /** @notice View Function that returns all the sale stats in once call
     *   @param user The address to verify, if zero address, everything user related should be zero
     *   @return numStats Definition below:
     *        0   softcap
     *        1   hardcap
     *        2   tokensPerETH    this can be zero value
     *        3   userPledged
     *        4   totalPledged
     *        5   tokenRaise      if this is a token raise
     *        6   referrals       number of referrals if number above 10 billion, then it's a no referral raise
     *        7   whitelist       0 - not whitelisted, 1 - whitelisted
     *        8   endSale         Time when the sale ends "automatically" // 0 if there is not END TIME.
     *        9   userReward      Reward of tokens (if it exists)
     *   @return tokens Definition below:
     *        0   pledgeToken     if zero address then it's ETH
     *        1   rewardToken     if zero address then none
     **/
    function raiseStatus(address user)
        external
        view
        returns (uint256[10] memory numStats, address[2] memory tokens);
}

// Part: OpenZeppelin/[email protected]/Context

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// Part: OpenZeppelin/[email protected]/Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Part: VectorShards

contract VectorShards is IERC20, Ownable {
    struct PoolInfo {
        uint256 shards;
        uint256 debt;
        uint256 claimed;
    }

    uint256 public totalSupply = 350_000 ether;
    uint256 public allocatedShards;

    string public constant name = "VectorShards";
    string public constant symbol = "MVS";
    uint8 public constant decimals = 18;

    uint256 public accRewardsPerShare;
    uint256 public totalDistributed;
    uint256 public totalClaimed;
    uint256 public nonEarning;

    IERC20 public reward;
    bool public blockTransfer;

    address public currentRaise;

    mapping(address => bool) public nonEarners;
    mapping(address => PoolInfo) public balances;
    mapping(address => mapping(address => uint256)) private _allowance;

    event Distributed(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    constructor(address _reward) {
        reward = IERC20(_reward);
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return balances[account].shards;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowance[owner][spender];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        require(!blockTransfer, "No transfers");
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(!blockTransfer, "No transfers");
        _spendAllowance(from, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        PoolInfo storage sender = balances[from];
        PoolInfo storage receiver = balances[to];
        require(sender.shards >= amount, "Insufficient balance");
        _claim(from);
        _claim(to);
        sender.shards -= amount;
        sender.debt = sender.shards * accRewardsPerShare;
        receiver.shards += amount;
        receiver.debt = receiver.shards * accRewardsPerShare;
        // Switch earnables
        if (!nonEarners[from] && nonEarners[to]) nonEarning += amount;
        else if (nonEarners[from] && !nonEarners[to]) nonEarning -= amount;

        emit Transfer(from, to, amount);
    }

    function _spendAllowance(address from, uint256 amount) private {
        require(
            allowance(from, msg.sender) >= amount,
            "Insufficient allowance"
        );
        _allowance[from][msg.sender] -= amount;
        emit Approval(from, msg.sender, _allowance[from][msg.sender]);
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allocateShards(address user, uint256 amount) external {
        require(msg.sender == currentRaise, "401"); // dev: HTTP Unauthorized
        allocatedShards += amount;
        require(allocatedShards <= totalSupply, "Invalid shards");
        PoolInfo storage investor = balances[user];
        if (investor.shards > 0) {
            _claim(user);
        }
        investor.shards += amount;
        investor.debt = investor.shards * accRewardsPerShare;
        emit Transfer(address(0), user, amount);
    }

    function distribute(uint256 amount) external {
        // transfer in the amount of BUSD to distribute
        reward.transferFrom(msg.sender, address(this), amount);
        uint256 shardsToDistributeTo = allocatedShards - nonEarning;
        require(shardsToDistributeTo > 0, "No one to distribute to");
        accRewardsPerShare += (amount * 1 ether) / shardsToDistributeTo;
        totalDistributed += amount;
        emit Distributed(msg.sender, amount);
    }

    function claim() external {
        uint256 pending = _claim(msg.sender);
        require(pending > 0, "Nothing to claim");
    }

    function _claim(address user) private returns (uint256) {
        if (nonEarners[user]) return 0;

        PoolInfo storage investor = balances[user];
        if (investor.shards == 0) return 0;
        uint256 pending = pendingReward(user);
        if (pending > 0) reward.transfer(user, pending);
        investor.claimed += pending;
        emit Claim(user, pending);
        return pending;
    }

    function pendingReward(address user) public view returns (uint256 pending) {
        PoolInfo storage investor = balances[user];
        pending = investor.shards * accRewardsPerShare;
        pending -= investor.debt;
        pending = pending / 1 ether;
    }

    function setRaise(address _raise) external onlyOwner {
        currentRaise = _raise;
    }

    function toggleBlockTransfer() external onlyOwner {
        blockTransfer = !blockTransfer;
    }

    function recoverOtherTokens(address _token) external onlyOwner {
        if (_token == address(0)) {
            uint256 balance = address(this).balance;
            (bool succ, ) = payable(owner()).call{value: balance}("");
            require(succ, "TX eth"); // Error sending ETH
        } else {
            uint256 balance = IERC20(_token).balanceOf(address(this));
            if (_token == address(reward)) {
                require(balance > totalDistributed - totalClaimed, "Rewards"); //dev: Dont touch rewards bro;
                balance = balance - (totalDistributed - totalClaimed);
            }
            IERC20(_token).transfer(owner(), balance);
        }
    }

    function editNonEarner(address _nonEarner, bool status) external onlyOwner {
        if (!nonEarners[_nonEarner]) {
            uint256 bal = balances[_nonEarner].shards;
            nonEarning += bal;
            balances[_nonEarner].debt = bal * accRewardsPerShare;
        } else {
            uint256 bal = balances[_nonEarner].shards;
            nonEarning -= bal;
            balances[_nonEarner].debt = bal * accRewardsPerShare;
        }
        nonEarners[_nonEarner] = status;
    }
}

// File: MoonVectorRaise.sol

/** Marked as abstract since we omit the following functions:
    toggleRaise
    getRefund
    claimRaise
    setRewardToken
    cancelRaise
    setWhitelistStatus
    setWhitelistMultiple
**/

contract MoonVectorRaise is ICrowdFundBasic, Ownable {
    uint256 public refBonus = 10_0;
    uint256 public constant PERCENT = 100_0;
    uint256 public hardcap;
    uint256 public totalRaised;
    uint256 public totalClaimed;
    uint256 public minDeposit = 25 ether;
    uint256 public minStep = 1 ether;
    address public moonvectorWallet;
    VectorShards public shards;
    IERC20 public busd;

    uint256[] public tiers; // Tiers go from highest to lowest. Index is what determines the multiplier amount

    mapping(address => PledgeInfo) public pledges;
    mapping(address => uint256) public claimed;
    mapping(uint8 => uint256) public tierBonus;

    constructor(address _busd, uint256 _hardcap) {
        busd = IERC20(_busd);
        require(_hardcap % minStep == 0); //dev: invalid hardcap
        hardcap = _hardcap;
        moonvectorWallet = msg.sender;

        tiers.push(1000 ether);
        tiers.push(500 ether);
        tiers.push(200 ether);
        tierBonus[0] = 500_0;
        tierBonus[1] = 250_0;
        tierBonus[2] = 200_0;
        emit RaiseStart(0, false);
    }

    // ---------------------------------------------
    //              EXTERNAL FUNCTIONS
    // ---------------------------------------------

    function pledge(uint256 amount) external payable override {
        require(msg.value == 0, "Not actually payable");
        _pledge(amount, address(0));
    }

    function pledgeReferred(uint256 amount, address affiliate)
        external
        payable
        override
    {
        require(msg.value == 0, "Not actually payable");
        _pledge(amount, affiliate);
    }

    function claim() external override {
        require(address(shards) != address(0), "Not ready to Claim");
        _distributeShares(msg.sender);
    }

    // ---------------------------------------------
    //              PRIVATE FUNCTIONS
    // ---------------------------------------------
    function _pledge(uint256 amount, address _ref) private {
        busd.transferFrom(msg.sender, moonvectorWallet, amount);
        require(totalRaised + amount <= hardcap, "Hardcap reached");
        require(amount > 0, "Invalid Amount"); //dev: Invalid amount
        PledgeInfo storage pledger = pledges[msg.sender];
        require(amount % minStep == 0, "No pennies");
        if (pledger.total == 0)
            require(minDeposit <= amount, "Amount lower than 25BUSD");
        setReferrer(pledger, _ref, amount);
        pledger.total += amount;
        totalRaised += amount;
        _distributeShares(msg.sender);
        emit Pledge(msg.sender, amount, pledger.referrer);
    }

    function setReferrer(
        PledgeInfo storage pledger,
        address _ref,
        uint256 amount
    ) private {
        require(msg.sender != _ref, "foul");
        if (_ref != address(0) && pledger.referrer == address(0)) {
            require(pledges[_ref].total > 0, "Invalid referral");
            pledger.referrer = _ref;
            pledges[_ref].referrals++;
        }
        if (pledger.referrer != address(0)) {
            uint256 bonus = (amount * refBonus) / PERCENT;
            pledges[_ref].refAmount += bonus;
            _distributeShares(_ref);
        }
    }

    function _distributeShares(address user) private {
        if (address(shards) == address(0)) return;
        PledgeInfo storage pledger = pledges[user];
        uint256 bonus = _getBonus(pledger.total);
        bonus = (pledger.total * bonus) / PERCENT;
        uint256 shares = bonus + pledger.refAmount - claimed[user];

        if (shares > 0) shards.allocateShards(user, shares);

        claimed[user] += shares;
        totalClaimed += shares;
        emit Claim(user, shares);
    }

    function _getBonus(uint256 amountGiven) private view returns (uint256) {
        for (uint8 i = 0; i < tiers.length; i++) {
            if (amountGiven >= tiers[i]) return tierBonus[i];
        }
        return PERCENT;
    }

    function setShards(address _shards) external onlyOwner {
        shards = VectorShards(_shards);
    }

    // ---------------------------------------------
    //           EXTERNAL VIEW FUNCTIONS
    // ---------------------------------------------
    function raiseStatus(address user)
        external
        view
        override
        returns (uint256[10] memory numStats, address[2] memory tokens)
    {
        uint256 rewarded = _getBonus(pledges[user].total);
        rewarded = (rewarded * pledges[user].total) / PERCENT;
        numStats[0] = 0;
        numStats[1] = hardcap;
        numStats[2] = 0;
        numStats[3] = pledges[user].total;
        numStats[4] = totalRaised;
        numStats[5] = 0;
        numStats[6] = pledges[user].referrals;
        numStats[7] = 0;
        numStats[8] = 0;
        numStats[9] = rewarded + pledges[user].refAmount;
        tokens[0] = address(busd);
        tokens[1] = address(shards);
    }
}