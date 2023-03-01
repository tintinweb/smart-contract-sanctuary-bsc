//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IToken {
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 _amount) external;

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function decimals() external view returns (uint256);
}

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function latestAnswer() external view returns (int256);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


contract VcxVesting is Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    struct roundInfo {
        bool islaunched;
        uint256 totalTokensForSale;
        uint256 tokenPrice;
        uint256 totalvestingDays;
        uint256 vestingStartTime;
        uint256 vestingSlicePeriod;
        uint256 tgePrecentage;
    }

    struct buyBackInfo {
        bool isEnabled ;
        uint256 tokenPrice ;
        uint256 tokenPrecentage ;
    }

    struct claimInfo {
        bool initialized;
        address owner;
        uint8 roundId;
        uint256 totalEligible;
        uint256 totalClaimed;
        uint256 remainingBalTokens;
        uint256 lastClaimedAt;
        uint256 startTime;
        uint256 totalVestingDays;
        uint256 slicePeriod;
        bool isBuyBackUsed;
    }

    AggregatorV3Interface internal priceFeed;

    mapping(uint8 => buyBackInfo) public buyBackData ;
    mapping(uint8 => roundInfo) public roundData;
    mapping(address => uint256[]) vestingIds;
    mapping(address => mapping(uint256 => claimInfo)) public userClaimData;

    address public admin;
    address public tokenAddress;

    uint256 public rateDecimals = 2;
    uint256 public tokenDecimals;
    uint8  public currentRound;

    Counters.Counter private _id;

    uint256 public timeUnit;
    uint256 public totalbuyBackAmount ;

    modifier onlyOwnerAndAdmin() {
        require(
            owner() == _msgSender() || _msgSender() == admin,
            "Ownable: caller is not the owner or admin"
        );
        _;
    }

    constructor(address _token, 
    address _admin
    ) {
        admin = _admin;
        timeUnit = 2592000;
        tokenAddress = _token;
        tokenDecimals = IToken(tokenAddress).decimals();
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

    }

    function setAdmin(address account) external onlyOwnerAndAdmin  {
        require(
            account != address(0),
            "Invalid Address, Address should not be zero"
        );
        admin = account;
    }

    function createVesting(
        address _creator,
        uint8 _roundId,
        uint256 _tokenAmount
    ) public onlyOwnerAndAdmin {
        _id.increment();

        vestingIds[_creator].push(_id.current());

        userClaimData[_creator][_id.current()] = claimInfo({
            initialized: true,
            roundId: _roundId,
            owner: _creator,
            totalEligible: _tokenAmount,
            totalClaimed: 0,
            remainingBalTokens: _tokenAmount,
            lastClaimedAt: 0,
            startTime: 0,
            totalVestingDays: roundData[_roundId].totalvestingDays,
            slicePeriod: roundData[_roundId].vestingSlicePeriod,
            isBuyBackUsed:false
        });
    }


    function setRoundData(
        uint8 _roundIds,
        uint256 _totalTokensForSale,
        uint256 _tokenPrice,
        uint256 _totalvestingDays,
        uint256 _vestingStartTime,
        uint256 _vestingSlicePeriod,
        uint256 _tgePrecentage
    ) public onlyOwnerAndAdmin {
        roundData[_roundIds].islaunched = false;
        roundData[_roundIds].totalTokensForSale = _totalTokensForSale;
        roundData[_roundIds].tokenPrice = _tokenPrice;
        roundData[_roundIds].totalvestingDays = _totalvestingDays;
        roundData[_roundIds].vestingStartTime = _vestingStartTime;
        roundData[_roundIds].vestingSlicePeriod = _vestingSlicePeriod;
        roundData[_roundIds].tgePrecentage = _tgePrecentage;
        currentRound = _roundIds ;
    }

    function launchRound(uint8 _roundId, uint256 _vestingStartTime,bool _status)
        external
        onlyOwnerAndAdmin
    {
        roundData[_roundId].vestingStartTime = _vestingStartTime;
        roundData[_roundId].islaunched = _status;
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    function balance() public view returns (uint256) {
        return IToken(tokenAddress).balanceOf(address(this));
    }

    function setTimeUnit(uint256 _unit) public onlyOwnerAndAdmin {
        timeUnit = _unit;
    }

    receive() external payable {}

    //Recover eth accidentally sent to the contract
    function removeEth(address payable destination) public onlyOwnerAndAdmin {
        require(
            destination != address(0),
            "Invalid Address, Address should not be zero"
        );
        destination.transfer(address(this).balance);
    }

    function removeERC20(address _owner) public onlyOwnerAndAdmin {
        IToken(tokenAddress).transfer(_owner, IToken(tokenAddress).balanceOf(address(this)));
    }

    function removeTotalBuyBackAmount(address _owner)public onlyOwnerAndAdmin  {
        IToken(tokenAddress).transfer(_owner, totalbuyBackAmount);        
        totalbuyBackAmount = 0;
    }

    function getLaunchedAt(uint8 _roundId) public view returns (uint256) {
        return (roundData[_roundId].vestingStartTime);
    }

    function getClaimableAmount(address _walletAddress, uint256 _vestingId)
        public
        view
        returns (uint256 _claimAmount)
    {
        claimInfo storage userData = userClaimData[_walletAddress][_vestingId];

        uint8 _roundId = userData.roundId;
        uint256 currentTime = getCurrentTime();

        if (roundData[_roundId].islaunched == false || currentTime < getLaunchedAt(_roundId)) {
            return 0;
        }

        uint256 timeLeft = 0;
        uint256 slicePeriodSeconds = userData.slicePeriod * timeUnit;
        uint256 claimAmount = 0;
        uint256 _amount = 0;

        uint256 totalEligible = userData.totalEligible;
        uint256 lastClaimedAt = userData.lastClaimedAt;
        if (roundData[_roundId].islaunched && lastClaimedAt == 0) {
            if (currentTime > getLaunchedAt(_roundId)) {
                timeLeft = currentTime.sub(getLaunchedAt(_roundId));
            } else {
                timeLeft = getLaunchedAt(_roundId).sub(currentTime);
            }
        } else {
            if (currentTime > lastClaimedAt) {
                timeLeft = currentTime.sub(lastClaimedAt);
            } else {
                timeLeft = lastClaimedAt.sub(currentTime);
            }
        }
        _amount = totalEligible;

        if (timeLeft / slicePeriodSeconds > 0) {
            claimAmount =
                ((_amount * userData.slicePeriod) / userData.totalVestingDays) *
                (timeLeft / slicePeriodSeconds);
        }

        uint256 _lastReleaseAmount = userData.totalClaimed;

        uint256 temp = _lastReleaseAmount.add(claimAmount);

        if (temp > totalEligible) {
            _amount = totalEligible.sub(_lastReleaseAmount);
            return (_amount);
        }
        return (claimAmount);
    }

    function getIslaunched(uint8 _roundId) external view returns(bool) {
        return roundData[_roundId].islaunched ;
    }

    function claim(address _walletAddress, uint256 _vestingId) public {

        claimInfo storage userData = userClaimData[_walletAddress][_vestingId];
        uint8 _roundId = userData.roundId;
        require(roundData[_roundId].islaunched, "Not yet launched");
        require( getClaimableAmount(_walletAddress, _vestingId) > 0, "Insufficient funds to claims." );
        require(_msgSender() == userData.owner, "You are not the owner");
        uint256 _amount = getClaimableAmount(_walletAddress, _vestingId);
        userData.totalClaimed += _amount;
        userData.remainingBalTokens = userData.totalEligible - userData.totalClaimed;
        userData.lastClaimedAt = getCurrentTime();
        IToken(tokenAddress).transfer(_walletAddress, _amount);
        
    }

    function getVestingIds(address _walletAddress) public view returns(uint256[] memory) {
        return vestingIds[_walletAddress];
    }

    function getRoundData(uint8 _roundId) external view returns(bool,uint256,uint256,uint256,uint256,uint256,uint256){
       
        return(roundData[_roundId].islaunched,roundData[_roundId].totalTokensForSale,
        roundData[_roundId].tokenPrice,
        roundData[_roundId].totalvestingDays,
        roundData[_roundId].vestingStartTime,
        roundData[_roundId].vestingSlicePeriod,
        roundData[_roundId].tgePrecentage
        );
    }

    function setBuyBackData(uint8 _roundId,uint256 _tokenPrecentage,uint256 _tokenPrice) public onlyOwnerAndAdmin{
        buyBackData[_roundId].tokenPrice = _tokenPrice ;
        buyBackData[_roundId].tokenPrecentage = _tokenPrecentage ;
    }

    function enableBuyBack(uint8 _roundId) public onlyOwnerAndAdmin{
        buyBackData[_roundId].isEnabled = true;
    }

    function disableBuyBack(uint8 _roundId) public onlyOwnerAndAdmin{
        buyBackData[_roundId].isEnabled = false;
    }


    function buyBack (uint256 _vestingId,address _walletAddress) public {

        claimInfo storage userData = userClaimData[_walletAddress][_vestingId];
        uint8 _roundId = userData.roundId;
        require(roundData[_roundId].islaunched, "Not yet launched");
        require(buyBackData[_roundId].isEnabled, "Not yet started");
        require(_msgSender() == userData.owner, "You are not the owner");
        require(!userData.isBuyBackUsed,"already Used buyBack for this vesting");

        uint256 buyBackAmount = (userData.totalEligible * buyBackData[_roundId].tokenPrecentage)/10**(2+rateDecimals);
        totalbuyBackAmount +=  buyBackAmount;
        userData.totalEligible -= buyBackAmount;
        userData.remainingBalTokens = userData.remainingBalTokens - buyBackAmount;
        userData.isBuyBackUsed = true;

        payable(userData.owner).transfer(getAmount(buyBackAmount,_roundId));

    }

    function getAmount(uint256 _buyBackAmount,uint8 _roundId) public view returns(uint256) {
        uint256 usdAmount = (buyBackData[_roundId].tokenPrice*_buyBackAmount)/ (10**(2+rateDecimals));
        return (usdAmount*10**(18-(tokenDecimals))/uint256(getEthPriceInUsd()));
    }


    function setRateDecimals(uint256 decimals) external onlyOwnerAndAdmin {
        rateDecimals = decimals;
    }
    
    function setTokenAddress(address token) external onlyOwnerAndAdmin {
        require(token != address(0), "Token address zero not allowed.");
        tokenAddress = token;
        tokenDecimals = IToken(token).decimals();
    }

    function getEthPriceInUsd() public view returns(int256) {
        return (priceFeed.latestAnswer()/1e8);
    }

    function setCurrentRound(uint8 _roundId) public onlyOwnerAndAdmin {
        currentRound = _roundId;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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