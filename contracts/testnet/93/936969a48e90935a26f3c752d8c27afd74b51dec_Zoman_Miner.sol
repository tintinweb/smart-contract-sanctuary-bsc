/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/zoman.sol


pragma solidity 0.8.14;



contract Zoman_Miner is Ownable {
    /** base parameters **/
    uint256 public constant ZOMAN_TO_HIRE_1MINER = 10 days; //10% daily apr
    uint256 public constant REFERRAL = 90; //% to ref
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public devTax = 55;
    uint256 public constant DAMPENING_FACTOR = 80;

    uint256 public COMPOUND_BONUS = 30;
    uint256 public COMPOUND_BONUS_MAX_TIMES = 20;
    uint256 public COMPOUND_STEP = 1 days;

    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public totalStaked;
    uint256 public totalUsers;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 private marketZoman = 100_000 * ZOMAN_TO_HIRE_1MINER;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;

    bool private _initialized;

    uint256 public CUTOFF_STEP = 2 days;
    uint256 public WITHDRAW_COOLDOWN = 1 days;

    /* addresses */
    address payable public dev1;

    IERC20 public token;

    mapping(address => bool) private hasParticipated;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedZoman;
        uint256 lastHireTime;
        address referrer;
        uint256 referralsCount;
        uint256 referralZomanRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 farmerCompoundCount; //added to monitor farmer consecutive compound without cap
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    modifier initialized() {
        require(_initialized, "Contract not initialized");
        _;
    }

    constructor(address payable _dev1, IERC20 _token) {
        dev1 = _dev1;
        token=_token;
    }

    function startFarm(address addr,uint256 amount) public payable onlyOwner {
        require(!_initialized, "Already initialized");
        _initialized = true;
        buyZoman(addr,amount);
    }

    function hireMiners(bool isCompound) public initialized {
        User storage user = users[msg.sender];

        uint256 zomansUsed = getMyZoman(msg.sender);
        uint256 zomanForCompound = zomansUsed;

        if (isCompound) {
            zomanForCompound += getDailyCompoundBonus(
                msg.sender,
                zomanForCompound
            );
            uint256 zomansUsedValue = calculateZomanSell(zomanForCompound);
            user.userDeposit += zomansUsedValue;
            totalCompound += zomansUsedValue;
        }

        if (block.timestamp - user.lastHireTime >= COMPOUND_STEP) {
            if (user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                ++user.dailyCompoundBonus;
            }
            //add compoundCount for monitoring purposes.
            ++user.farmerCompoundCount;
        }
        user.claimedZoman = zomanForCompound % ZOMAN_TO_HIRE_1MINER;
        user.miners += zomanForCompound / ZOMAN_TO_HIRE_1MINER;
        user.lastHireTime = block.timestamp;

        marketZoman += dampenZoman(zomansUsed);

        if (!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            totalUsers++;
        }
    }

    function dampenZoman(uint256 amount) private pure returns (uint256) {
        return (amount * DAMPENING_FACTOR) / 100;
    }

    function sellZoman() public initialized {
        
        User storage user = users[msg.sender];
        require(block.timestamp-user.lastHireTime>=WITHDRAW_COOLDOWN, "must wait 24 hours before sell");

        uint256 hasZoman = getMyZoman(msg.sender);
        uint256 zomanValue = calculateZomanSell(hasZoman);

        /** 
            if user compound < to mandatory compound days**/
        if (user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
            //daily compound bonus count will not reset and zomanValue will be deducted with 60% feedback tax.
            zomanValue -= ((zomanValue * WITHDRAWAL_TAX) / PERCENTS_DIVIDER);
        } else {
            //set daily compound bonus count to 0 and zomanValue will remain without deductions
            user.dailyCompoundBonus = 0;
            user.farmerCompoundCount = 0;
        }

        user.lastWithdrawTime = block.timestamp;
        user.claimedZoman = 0;
        user.lastHireTime = block.timestamp;
        marketZoman += dampenZoman(hasZoman);

        if (token.balanceOf(address(this)) < zomanValue) {
            zomanValue = token.balanceOf(address(this));
        }

        uint256 zomansPayout = zomanValue - payFees(zomanValue);
        token.transfer(msg.sender,zomansPayout);
        user.totalWithdrawn = user.totalWithdrawn + zomansPayout;
        totalWithdrawn += zomansPayout;
        if (user.miners == 0) {
            hasParticipated[msg.sender] = false;
            totalUsers--;
        }
    }

    function buyZoman(address ref, uint256 amount) public payable initialized {
        User storage user = users[msg.sender];
        token.transferFrom(msg.sender,address(this),amount);
        uint256 zomanBought = calculateZomanBuy(
            amount,
            token.balanceOf(address(this))-amount
        );
        user.userDeposit += amount;
        user.initialDeposit += amount;
        user.claimedZoman += zomanBought;

        if (
            user.referrer == address(0) 
        ) {

            user.referrer = (ref != address(0) && ref != msg.sender) ? ref : dev1 ;
            ++users[user.referrer].referralsCount;
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            uint256 refRewards = (amount * REFERRAL) / PERCENTS_DIVIDER;
            token.transfer(upline,refRewards);

            users[upline].referralZomanRewards += refRewards;
            totalRefBonus += refRewards;
        }

        uint256 zomansPayout = payFees(amount);
        totalStaked += amount - zomansPayout;
        hireMiners(false);
    }

    function payFees(uint256 zomanValue) internal returns (uint256) {
        uint256 tax = (zomanValue * devTax) / PERCENTS_DIVIDER;
        token.transfer(dev1,tax);
        return tax;
    }

    function getDailyCompoundBonus(address _adr, uint256 amount)
        public
        view
        returns (uint256)
    {
        uint256 totalBonus = users[_adr].dailyCompoundBonus * COMPOUND_BONUS;
        uint256 result = (amount * totalBonus) / PERCENTS_DIVIDER;
        return result;
    }

    function getUserInfo(address _adr)
        public
        view
        returns (
            uint256 _initialDeposit,
            uint256 _userDeposit,
            uint256 _miners,
            uint256 _claimedZoman,
            uint256 _lastHireTime,
            address _referrer,
            uint256 _referrals,
            uint256 _totalWithdrawn,
            uint256 _referralZomanRewards,
            uint256 _dailyCompoundBonus,
            uint256 _farmerCompoundCount,
            uint256 _lastWithdrawTime
        )
    {
        _initialDeposit = users[_adr].initialDeposit;
        _userDeposit = users[_adr].userDeposit;
        _miners = users[_adr].miners;
        _claimedZoman = users[_adr].claimedZoman;
        _lastHireTime = users[_adr].lastHireTime;
        _referrer = users[_adr].referrer;
        _referrals = users[_adr].referralsCount;
        _totalWithdrawn = users[_adr].totalWithdrawn;
        _referralZomanRewards = users[_adr].referralZomanRewards;
        _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
        _farmerCompoundCount = users[_adr].farmerCompoundCount;
        _lastWithdrawTime = users[_adr].lastWithdrawTime;
    }

    function getAvailableEarnings(address _adr) public view returns (uint256) {
        return calculateZomanSell(getMyZoman(_adr));
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        return (PSN * bs) / (PSNH + (PSN * rs + PSNH * rt) / rt);
    }

    function calculateZomanSell(uint256 zoman) public view returns (uint256) {
        return calculateTrade(zoman, marketZoman, token.balanceOf(address(this)));
    }

    function calculateZomanBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketZoman);
    }

    function calculateZomanBuySimple(uint256 eth) public view returns (uint256) {
        return calculateZomanBuy(eth, token.balanceOf(address(this)));
    }

    /** How many miners and zoman per day user will recieve based on BNB deposit **/
    function getZomanYieldPerDay(uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 zomanAmount = calculateZomanBuy(amount, token.balanceOf(address(this)));
        uint256 miners = zomanAmount / ZOMAN_TO_HIRE_1MINER;
        uint256 day = 1 days;
        uint256 zomanPerDay = day * miners;
        uint256 earningsPerDay = calculateZomanSellForYield(zomanPerDay, amount);
        return (miners, earningsPerDay);
    }

    function calculateZomanSellForYield(uint256 zoman, uint256 amount)
        public
        view
        returns (uint256)
    {
        return
            calculateTrade(zoman, marketZoman, token.balanceOf(address(this)) + amount);
    }

    function getSiteInfo()
        public
        view
        returns (
            uint256 _totalStaked,
            uint256 _totalUsers,
            uint256 _totalCompound,
            uint256 _totalRefBonus
        )
    {
        return (totalStaked, totalUsers, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns (uint256) {
        return users[msg.sender].miners;
    }

    function getMyZoman(address addr) public view returns (uint256) {
        return users[addr].claimedZoman + getZomansSinceLastHireTime(addr);
    }

    function getZomansSinceLastHireTime(address adr)
        public
        view
        returns (uint256)
    {
        uint256 secondsSinceLastHireTime = block.timestamp -
            users[adr].lastHireTime;
        /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHireTime, CUTOFF_STEP);
        uint256 secondsPassed = min(ZOMAN_TO_HIRE_1MINER, cutoffTime);
        return secondsPassed * users[adr].miners;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function setDevTax(uint256 value) external onlyOwner {
        require(value <= 150);
        devTax = value;
    }
}