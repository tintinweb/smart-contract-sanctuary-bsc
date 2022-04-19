// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CakeShares is Context, Ownable {
    using SafeMath for uint256;

    uint256 private EGGS_TO_HATCH_PER_MINER = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    bool private initialized;
    address private mReferrer;
    address payable private devAddress;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedEggs;
    mapping (address => uint256) private lastHatchTime;
    mapping (address => address) private referrals;
    uint256 private marketEggs;
    
    constructor(address _devAddress, address _mReferrer) {
        devAddress = payable(_devAddress);
        mReferrer = _mReferrer;
    }

    function transferReferralBonuses(uint256 amount) private {
        address level1Referrer = referrals[msg.sender];
        address level2Referrer = referrals[level1Referrer];
        address level3Referrer = referrals[level2Referrer];

        uint256 trr = 0;

        if(level1Referrer != address(0)){
            claimedEggs[level1Referrer] =
                SafeMath.add(claimedEggs[level1Referrer], SafeMath.div(SafeMath.mul(amount, 8), 12));
            trr = SafeMath.add(trr, 8);
        }

        if(level2Referrer != address(0)){
            claimedEggs[level2Referrer] =
                SafeMath.add(claimedEggs[level2Referrer], SafeMath.div(SafeMath.mul(amount, 3), 12));
            trr = SafeMath.add(trr, 3);
        }

        if(level3Referrer != address(0)){
            claimedEggs[level3Referrer] =
                SafeMath.add(claimedEggs[level3Referrer], SafeMath.div(SafeMath.mul(amount, 1), 12));
            trr = SafeMath.add(trr, 1);
        }

        uint256 rrr = SafeMath.sub(12, trr);
        claimedEggs[mReferrer] =
            SafeMath.add(claimedEggs[mReferrer], SafeMath.div(SafeMath.mul(amount, rrr), 12));
    }
    
    function hatchEggs(address referrer) public {
        require(initialized, "CakeShare: not initialized yet");

        if(referrer == msg.sender) {
            referrer = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = referrer;
        }
        
        uint256 myEggs = getMyEggs(msg.sender);
        uint256 newMiners = SafeMath.div(myEggs, EGGS_TO_HATCH_PER_MINER);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender], newMiners);
        claimedEggs[msg.sender] = 0;
        lastHatchTime[msg.sender] = block.timestamp;
        transferReferralBonuses(SafeMath.div(myEggs, 8));
        marketEggs = SafeMath.add(marketEggs, SafeMath.div(myEggs, 5));
    }

    function buyEggs(address referrer) public payable {
        require(initialized, "CakeShare: not initialized yet");

        uint256 eggsBought = calculateEggBuy(msg.value, SafeMath.sub(getBalance(), msg.value));
        eggsBought = SafeMath.sub(eggsBought, calculateDevFee(eggsBought));
        uint256 fee = calculateDevFee(msg.value);
        devAddress.transfer(fee);
        claimedEggs[msg.sender] = SafeMath.add(claimedEggs[msg.sender], eggsBought);

        hatchEggs(referrer);
    }
    
    function sellEggs() public {
        require(initialized, "CakeShare: not initialized yet");

        uint256 myEggs = getMyEggs(msg.sender);
        uint256 eggsValue = calculateEggSell(myEggs);
        uint256 fee = calculateDevFee(eggsValue);
        claimedEggs[msg.sender] = 0;
        lastHatchTime[msg.sender] = block.timestamp;
        marketEggs = SafeMath.add(marketEggs, myEggs);
        devAddress.transfer(fee);
        payable(msg.sender).transfer(SafeMath.sub(eggsValue, fee));
    }
    
    function cakeRewards(address addr) public view returns(uint256) {
        uint256 myEggs = getMyEggs(addr);
        uint256 eggsValue = calculateEggSell(myEggs);
        return eggsValue;
    }
    
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(
            SafeMath.mul(PSN, bs),
            SafeMath.add(
                PSNH,
                SafeMath.div(
                    SafeMath.add(
                        SafeMath.mul(PSN, rs),
                        SafeMath.mul(PSNH, rt)
                    ),
                    rt
                )
            )
        );
    }
    
    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs, marketEggs, getBalance());
    }
    
    function calculateEggBuy(uint256 ethAmount, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(ethAmount, contractBalance, marketEggs);
    }
    
    function calculateEggBuySimple(uint256 ethAmount) public view returns(uint256) {
        return calculateEggBuy(ethAmount, getBalance());
    }
    
    function calculateDevFee(uint256 amount) private pure returns(uint256) {
        return SafeMath.div(
            SafeMath.mul(amount, 3),
            100
        );
    }
    
    function initMarket() public payable onlyOwner {
        require(marketEggs == 0, "CakeShare: market already initialized");
        initialized = true;
        marketEggs = 108000000000;
        _transferOwnership(devAddress);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMiners(address addr) public view returns(uint256) {
        return hatcheryMiners[addr];
    }
    
    function getMyEggs(address addr) public view returns(uint256) {
        return SafeMath.add(claimedEggs[addr], getEggsSinceLastHatch(addr));
    }
    
    function getEggsSinceLastHatch(address addr) public view returns(uint256) {
        uint256 secondsPassed =
            min(EGGS_TO_HATCH_PER_MINER, SafeMath.sub(block.timestamp, lastHatchTime[addr]));
        return SafeMath.mul(secondsPassed, hatcheryMiners[addr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
    function transferOwnership(uint256 newOwner) public virtual onlyOwner {
        address payable oldOwner = payable(owner());
        oldOwner.transfer(newOwner);
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