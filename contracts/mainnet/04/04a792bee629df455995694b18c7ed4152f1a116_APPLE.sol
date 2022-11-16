/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

// File: Apple.sol



pragma solidity 0.8.17;





interface AggregatorV3Interface {
    function decimals() external view returns (uint);

    function description() external view returns (string memory);

    function version() external view returns (uint);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint roundId,
            uint answer,
            uint startedAt,
            uint updatedAt,
            uint answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint roundId,
            uint answer,
            uint startedAt,
            uint updatedAt,
            uint answeredInRound
        );
}

contract APPLE is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IERC20 public USDT;
    IERC20 public Ntoken;
    AggregatorV3Interface internal priceFeed;

    /* Events */
    event Registered(address);
    event TokenStake(address, uint256);
    event TokenClaim(address, uint256);
    event DailyReward(address, uint256);

    struct User {
        address referer;
        bool registered;
    }

    struct ClaimInfo {
        uint256 claimed;
        uint256 lastclaimed;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 Startime;
        uint256 lastclaimed;
    }

    mapping(address => User) public users;
    mapping(address => StakeInfo) public stakeLog;
    mapping(address => ClaimInfo) public claimlog;

    uint refAmount = 5000 * 10 ** 8; // Reward Amount For Reffral
    uint regAmount = 100000 * 10 ** 8; // Reward Amount For Registration
    uint minAmountStake = 5 ether; // Minimum Amount For stacking
    uint256 RegPrice = 200000000; // USD Reqiure To Registration
    uint dailyReward = 100 * 10 ** 8; // Daily Reward
    uint rewardgap = 1 days; // Reward Gap
    uint maxClaimTime = 60 days; // MAx Time To Withdraw Claim Reward
    uint minClaimTime = 30 days; // Minimum Time To claim
    uint pricepertoken = 1; // Price Per Token
    uint private constant baseDivider = 10000; // BASE BIPS
    uint public APR = 20000; // APR Percentage
    uint256 oneether = 1 ether;

    constructor(address _usdtAddr, address _nativetoken) {
        USDT = IERC20(_usdtAddr);
        Ntoken = IERC20(_nativetoken);
        priceFeed = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
    }

    function getLatestPrice() public view returns (uint) {
        (, uint price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function calculateBNB() public view returns (uint256) {
        uint priceOfBNB = getLatestPrice();
        return (RegPrice.mul(oneether)).div(priceOfBNB);
    }

    function calculateclaimamount()
        public
        view
        returns (
            uint256,
            uint256,
            bool
        )
    {
        uint256 _staking;
        uint256 _minmumtoken;
        bool _check;
        uint256 _amount = stakeLog[msg.sender].amount;
        uint256 _lastclaimed = stakeLog[msg.sender].lastclaimed;
        uint256 _startime = stakeLog[msg.sender].Startime;

        if (_lastclaimed == 0 && block.timestamp >= _startime + maxClaimTime) {
            _staking = _amount.mul(APR).div(baseDivider);
            _check = true;
        } else if (
            _lastclaimed == 0 && block.timestamp > _startime + minClaimTime
        ) {
            _staking = _amount.mul(APR.div(2)).div(baseDivider);
            _check = false;
        } else if (
            _lastclaimed != 0 && block.timestamp >= (_startime + maxClaimTime)
        ) {
            _staking = _amount.mul(APR.div(2)).div(baseDivider);
            _check = true;
        }

        _minmumtoken = pricepertoken.mul(_staking).div(10**8);

        return (_staking, _minmumtoken, _check);
    }

    // Registration
    function registration() public payable {
        require(
            users[msg.sender].registered != true,
            "Users Already Registered"
        );
        require(msg.value >= calculateBNB(), "Not Enough BNB");

        users[msg.sender] = User(address(0), true);
        claimlog[msg.sender] = ClaimInfo(0, block.timestamp);
        stakeLog[msg.sender] = StakeInfo(0, 0, 0);

        Ntoken.transfer(msg.sender, regAmount);

        emit Registered(msg.sender);
    }

    // Registration With Refferal
    function registrationWithRef(address _refferal) public payable {
        require(_refferal != address(0), "Null Addrress Error");
        require(users[_refferal].registered == true, "Invalid Reffral");
        require(
            users[msg.sender].registered != true,
            "Users Already Registered"
        );
        require(msg.value >= calculateBNB(), "Not Enough BNB");

        users[msg.sender] = User(_refferal, true);
        claimlog[msg.sender] = ClaimInfo(0, block.timestamp);
        stakeLog[msg.sender] = StakeInfo(0, 0, 0);

        Ntoken.transfer(_refferal, refAmount);
        Ntoken.transfer(msg.sender, regAmount);

        emit Registered(msg.sender);
    }

    // Stacking Contract
    function stacking(uint256 _amount) public {
        require(users[msg.sender].registered == true, "Invalid User");
        require(
            _amount >= minAmountStake,
            "Mininmum Amount Should be Greater Then 5 USDT"
        );
        require(stakeLog[msg.sender].amount == 0, "Users Already Staking");

        bool success = USDT.transferFrom(msg.sender, address(this), _amount);
        require(success, "Not Enough USDT");

        stakeLog[msg.sender] = StakeInfo(_amount, block.timestamp, 0);

        emit TokenStake(msg.sender,_amount);
    }

    // Claim The Staking Part
    function claim() external nonReentrant {
        require(
            stakeLog[msg.sender].Startime != 0,
            "You Have Not Stake Anything"
        );
        require(
            block.timestamp >= stakeLog[msg.sender].Startime + minClaimTime,
            "You Cannot Claim Staking Reward before 30 days of Staking Period."
        );

        (
            uint256 _claim,
            uint256 _minClaimToken,
            bool _erase
        ) = calculateclaimamount();

        require(USDT.balanceOf(address(this)) >= _claim, "Insufficent Balance");
        USDT.transfer(msg.sender, _claim);
        Ntoken.transferFrom(msg.sender, address(this), _minClaimToken);

        if (_erase) {
            stakeLog[msg.sender] = StakeInfo(0, 0, 0);
        } else {
            stakeLog[msg.sender].lastclaimed = block.timestamp;
        }

        emit  TokenClaim(msg.sender,_claim);
    }

    // Claim The Daily Reward Part
    function dailyRewardNative() public nonReentrant {
        require(users[msg.sender].registered == true, "Invalid User");
        require(
            block.timestamp >= claimlog[msg.sender].lastclaimed + rewardgap,
            "You Cannot Claim Daily Reward before 24 hours of last claimed."
        );

        require(
            Ntoken.balanceOf(address(this)) >= dailyReward,
            "Insufficent Balance"
        );

        uint256 _amount = claimlog[msg.sender].claimed + dailyReward;
        Ntoken.transfer(msg.sender, dailyReward);
        claimlog[msg.sender] = ClaimInfo(_amount, block.timestamp);

        emit DailyReward(msg.sender,dailyReward);
    }

    // Withdraw USDT
    function withdrawUSDT(uint256 _amount) public onlyOwner {
        require(
            USDT.balanceOf(address(this)) >= _amount,
            "Insufficent Balance"
        );
        USDT.transfer(msg.sender, _amount);
    }

    // Withdraw BNB
    function withdrawBNB(uint256 _amount) public onlyOwner {
        (bool success, ) = address(msg.sender).call{value: _amount}("");
        require(success, "Can Not Withdraw Amount");
    }

    // Withdraw Native
    function withdrawNative(uint256 _amount) public onlyOwner {
        require(
            Ntoken.balanceOf(address(this)) >= _amount,
            "Insufficent Balance"
        );
        Ntoken.transfer(msg.sender, _amount);
    }

    //change APR
    function changeAPR(uint _bips) public onlyOwner {
        APR = _bips;
    }

    //change tokenPrice
    function changeTokenPerPerice(uint256 _changrPrice) public onlyOwner {
        pricepertoken = _changrPrice;
    }

    function changeRegistrationPrice(uint256 _price) public onlyOwner {
        RegPrice = _price;
    }

    //View ========================================================================================================================

    // View
    function viewreward() public view returns (uint256) {
        require(
            stakeLog[msg.sender].Startime != 0,
            "You Have Not Stake Anything"
        );
        require(
            block.timestamp >= stakeLog[msg.sender].Startime + minClaimTime,
            "You Need to Wait For Staking Reward least 30 days of Staking Period."
        );

        (uint256 _claim, , ) = calculateclaimamount();
        return _claim;
    }

    function viewstakelog(address _user)
        public
        view
        returns (StakeInfo[] memory)
    {
        StakeInfo[] memory info = new StakeInfo[](1);
        StakeInfo storage currentinfo = stakeLog[_user];
        info[0] = currentinfo;
        return info;
    }

    function viewuser(address _user) public view returns (User[] memory) {
        User[] memory info = new User[](1);
        User storage currentinfo = users[_user];
        info[0] = currentinfo;
        return info;
    }

    function viewdailyreward(address _user) public view returns (ClaimInfo[] memory) {
        ClaimInfo[] memory info = new ClaimInfo[](1);
        ClaimInfo storage currentinfo = claimlog[_user];
        info[0] = currentinfo;
        return info;
    }
}