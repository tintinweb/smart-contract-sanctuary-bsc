// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
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

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * To buy AhouZ user must be Whitelisted
 * Add user address and value to Whitelist
 * Remove user address from Whitelist
 * Check if User is Whitelisted
 * Check if User have equal or greater value than Whitelisted
 */

library Whitelist {
    struct List {
        mapping(address => bool) registry;
        mapping(address => uint256) amount;
    }

    function addUserWithValue(
        List storage list,
        address _addr,
        uint256 _value
    ) internal {
        list.registry[_addr] = true;
        list.amount[_addr] = _value;
    }

    function add(List storage list, address _addr) internal {
        list.registry[_addr] = true;
    }

    function remove(List storage list, address _addr) internal {
        list.registry[_addr] = false;
        list.amount[_addr] = 0;
    }

    function check(
        List storage list,
        address _addr
    ) internal view returns (bool) {
        return list.registry[_addr];
    }

    function checkValue(
        List storage list,
        address _addr,
        uint256 _value
    ) internal view returns (bool) {
        /**
         * divided by  10^18 because bnb decimal is 18
         * and conversion to bnb to uint256 is carried out
         */

        return list.amount[_addr] <= _value;
    }
}

/**
 * Contract to whitelist User for buying token
 */
contract Whitelisted is Ownable {
    Whitelist.List private _list;
    uint256 decimals = 100000000000000;
    address public whitelister;

    modifier onlyWhitelisted() {
        require(Whitelist.check(_list, msg.sender) == true);
        _;
    }

    modifier onlyWhitelister() {
        require(msg.sender == whitelister);
        _;
    }

    event AddressAdded(address _addr);
    event AddressRemoved(address _addr);
    event AddressReset(address _addr);

    /**
     * Add User to Whitelist with bnb amount
     * @param _address User Wallet address
     * @param amount The amount of bnb user Whitelisted in wei
     */
    function addWhiteListAddress(
        address _address,
        uint256 amount
    ) public onlyWhitelister {
        require(!isAddressWhiteListed(_address));

        Whitelist.addUserWithValue(_list, _address, amount);

        emit AddressAdded(_address);
    }

    /**
     * Set User's Whitelisted bnb amount to 0 so that
     * during second buy transaction user won't need to
     * validate for Whitelisted amount
     */
    function resetUserWhiteListAmount() internal {
        Whitelist.addUserWithValue(_list, msg.sender, 9999999 ether);
        emit AddressReset(msg.sender);
    }

    /**
     * Disable User from Whitelist so user can't buy token
     * @param _addr User Wallet address
     */
    function disableWhitelistAddress(address _addr) public onlyOwner {
        Whitelist.remove(_list, _addr);
        emit AddressRemoved(_addr);
    }

    /**
     * Check if User is Whitelisted
     * @param _addr User Wallet address
     */
    function isAddressWhiteListed(address _addr) public view returns (bool) {
        return Whitelist.check(_list, _addr);
    }

    /**
     * Check if User has enough bnb amount in Whitelisted to buy token
     * @param _addr User Wallet address
     * @param amount The amount of bnb user inputed
     */
    function isWhiteListedValueValid(
        address _addr,
        uint256 amount
    ) public view returns (bool) {
        return Whitelist.checkValue(_list, _addr, amount);
    }

    /**
     * Check if User is valid to buy token
     * @param _addr User Wallet address
     * @param amount The amount of bnb user inputed
     */
    function isValidUser(
        address _addr,
        uint256 amount
    ) public view returns (bool) {
        return
            isAddressWhiteListed(_addr) &&
            isWhiteListedValueValid(_addr, amount);
    }

    /**
     * returns the total amount of the address hold by the user during white list
     */
    function getUserAmount(address _addr) public view returns (uint256) {
        require(isAddressWhiteListed(_addr));
        return _list.amount[_addr];
    }

    /**
     * change whitelister address
     */
    function transferWhitelister(address newWhitelister) public onlyOwner {
        whitelister = newWhitelister;
    }
}

contract AhouZCrowdsale is Whitelisted {
    using SafeMath for uint256;

    AggregatorV3Interface internal priceFeed;
    address public beneficiary;
    uint256 public SoftCap;
    uint256 public HardCap;
    uint256 public amountRaised;
    uint256[2] public seedSaleDates;
    uint256[2] public privateSale1Dates;
    uint256[2] public privateSale2Dates;
    uint256[2] public publicSaleDates;
    uint256 public fundTransferred;
    uint256 public tokenSold;
    uint256 public tokenSoldWithBonus;
    uint256[4] public price;
    IERC20 public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public crowdsaleClosed = false;
    bool public returnFunds = false;

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);

    constructor(
        address _priceFeed,
        address _benificiary,
        address _tokenReward
    ) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        beneficiary = _benificiary;
        SoftCap = 8333 ether;
        HardCap = 25000 ether;
        seedSaleDates = [1666224000, 1671494400];
        privateSale1Dates = [1671494400, 1679270400];
        privateSale2Dates = [1679270400, 1687219200];
        publicSaleDates = [1687219200, 1693267200];
        // price should be in 10^18 format.
        price = [
            500000000000000,
            550000000000000,
            600000000000000,
            750000000000000
        ];
        tokenReward = IERC20(_tokenReward);
    }

    function getRewardAmount(
        uint256 _amount,
        uint256 _price
    ) public view returns (uint256) {
        uint256 priceOfEth = uint256(getLatestPrice());
        uint256 cost = priceOfEth.div(_price);
        uint256 amount = _amount.mul(cost);
        return amount;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    fallback() external payable {}

    receive() external payable {
        // custom function code
        uint256 bonus = 0;
        uint256 bonusPercent = 0;
        uint256 amount = 0;
        uint256 amountWithBonus = 0;
        uint256 ethamount = msg.value;

        require(!crowdsaleClosed);

        require(isValidUser(msg.sender, ethamount));

        //add bonus for funders
        if (
            block.timestamp >= seedSaleDates[0] &&
            block.timestamp <= seedSaleDates[1]
        ) {
            amount = getRewardAmount(ethamount, price[0]);
            bonusPercent = getBonusForSeedSale();
        } else if (
            block.timestamp >= privateSale1Dates[0] &&
            block.timestamp <= privateSale1Dates[1]
        ) {
            amount = getRewardAmount(ethamount, price[1]);
            bonusPercent = getBonusForPrivateSale1();
        } else if (
            block.timestamp >= privateSale2Dates[0] &&
            block.timestamp <= privateSale2Dates[1]
        ) {
            amount = getRewardAmount(ethamount, price[2]);
            bonusPercent = getBonusForPrivateSale2();
        } else if (
            block.timestamp >= publicSaleDates[0] &&
            block.timestamp <= publicSaleDates[1]
        ) {
            amount = getRewardAmount(ethamount, price[3]);
            bonusPercent = getBonusForPublicSale();
        }

        bonus = (amount * bonusPercent) / 100;
        amountWithBonus = amount.add(bonus);

        balanceOf[msg.sender] = balanceOf[msg.sender].add(ethamount);
        amountRaised = amountRaised.add(ethamount);

        tokenReward.transfer(msg.sender, amountWithBonus.div(10 ** 4));
        tokenSold = tokenSold.add(amount.div(10 ** 4));
        tokenSoldWithBonus = tokenSoldWithBonus.add(
            amountWithBonus.div(10 ** 4)
        );

        resetUserWhiteListAmount();
        emit FundTransfer(msg.sender, ethamount, true);
    }

    function getBonusForSeedSale() private view returns (uint256) {
        uint256 saleDuration = seedSaleDates[1] - seedSaleDates[0];
        uint256 meanPoint = (saleDuration / 2) + seedSaleDates[0];
        if (block.timestamp <= meanPoint) {
            return 25;
        }
        return 23;
    }

    function getBonusForPrivateSale1() private view returns (uint256) {
        uint256 saleDuration = privateSale1Dates[1] - privateSale1Dates[0];
        uint256 meanPoint = (saleDuration / 2) + privateSale1Dates[0];
        if (block.timestamp <= meanPoint) {
            return 20;
        }
        return 18;
    }

    function getBonusForPrivateSale2() private view returns (uint256) {
        uint256 saleDuration = privateSale2Dates[1] - privateSale2Dates[0];
        uint256 meanPoint = (saleDuration / 2) + privateSale2Dates[0];
        if (block.timestamp <= meanPoint) {
            return 15;
        }
        return 12;
    }

    function getBonusForPublicSale() private view returns (uint256) {
        uint256 saleDuration = publicSaleDates[1] - publicSaleDates[0];
        uint256 meanPoint = (saleDuration / 2) + publicSaleDates[0];
        if (block.timestamp <= meanPoint) {
            return 10;
        }
        return 5;
    }

    modifier afterDeadline() {
        if (block.timestamp >= publicSaleDates[1]) _;
    }

    function getLatestPrice() public view returns (int) {
        (
            ,
            /*uint80 roundID*/ int answer /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return answer * 10 ** 10;
    }

    /**
     *ends the campaign after deadline
     */

    function endCrowdsale() public afterDeadline onlyOwner {
        crowdsaleClosed = true;
    }

    function EnableReturnFunds() public onlyOwner {
        returnFunds = true;
    }

    function DisableReturnFunds() public onlyOwner {
        returnFunds = false;
    }

    function bonusSent() public view returns (uint256) {
        return tokenSoldWithBonus - tokenSold;
    }

    /**
     * seed sale price
     * private sale 1 price
     * private sale 2 price
     * public sale price
     */
    function ChangeSalePrices(
        uint256 _seed_price,
        uint256 _privatesale1_price,
        uint256 _privatesale2_price,
        uint256 _publicsale_price
    ) public onlyOwner {
        price[0] = _seed_price;
        price[1] = _privatesale1_price;
        price[2] = _privatesale2_price;
        price[3] = _publicsale_price;
    }

    function changeAggregator(address _priceFeed) public onlyOwner {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function ChangeBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function SeedSaleDates(
        uint256 _seedSaleStartdate,
        uint256 _seedSaleDeadline
    ) public onlyOwner {
        if (_seedSaleStartdate != 0) {
            seedSaleDates[0] = _seedSaleStartdate;
        }
        if (_seedSaleDeadline != 0) {
            seedSaleDates[1] = _seedSaleDeadline;
        }

        if (crowdsaleClosed == true) {
            crowdsaleClosed = false;
        }
    }

    function ChangePrivateSale1Dates(
        uint256 _privateSale1Startdate,
        uint256 _privateSale1Deadline
    ) public onlyOwner {
        if (_privateSale1Startdate != 0) {
            privateSale1Dates[0] = _privateSale1Startdate;
        }
        if (_privateSale1Deadline != 0) {
            privateSale1Dates[1] = _privateSale1Deadline;
        }

        if (crowdsaleClosed == true) {
            crowdsaleClosed = false;
        }
    }

    function ChangePrivateSale2Dates(
        uint256 _privateSale2Startdate,
        uint256 _privateSale2Deadline
    ) public onlyOwner {
        if (_privateSale2Startdate != 0) {
            privateSale2Dates[0] = _privateSale2Startdate;
        }
        if (_privateSale2Deadline != 0) {
            privateSale2Dates[1] = _privateSale2Deadline;
        }

        if (crowdsaleClosed == true) {
            crowdsaleClosed = false;
        }
    }

    function ChangeMainSaleDates(
        uint256 _mainSaleStartdate,
        uint256 _mainSaleDeadline
    ) public onlyOwner {
        if (_mainSaleStartdate != 0) {
            publicSaleDates[0] = _mainSaleStartdate;
        }
        if (_mainSaleDeadline != 0) {
            publicSaleDates[1] = _mainSaleDeadline;
        }

        if (crowdsaleClosed == true) {
            crowdsaleClosed = false;
        }
    }

    /**
     * Get all the remaining token back from the contract
     */
    function getTokensBack() public onlyOwner {
        require(crowdsaleClosed);

        uint256 remaining = tokenReward.balanceOf(address(this));
        tokenReward.transfer(beneficiary, remaining);
    }

    /**
     * User can get their bnb back if crowdsale didn't meet it's requirement
     */
    function safeWithdrawal() public afterDeadline {
        if (returnFunds) {
            uint256 amount = balanceOf[msg.sender];
            if (amount > 0) {
                if (payable(msg.sender).send(amount)) {
                    emit FundTransfer(msg.sender, amount, false);
                    balanceOf[msg.sender] = 0;
                    fundTransferred = fundTransferred.add(amount);
                }
            }
        }

        if (returnFunds == false && beneficiary == msg.sender) {
            uint256 ethToSend = amountRaised - fundTransferred;
            if (payable(beneficiary).send(ethToSend)) {
                fundTransferred = fundTransferred.add(ethToSend);
            }
        }
    }
}