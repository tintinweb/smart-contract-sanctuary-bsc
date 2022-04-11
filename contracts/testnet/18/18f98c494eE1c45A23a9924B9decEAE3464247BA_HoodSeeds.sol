/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/Seeds.sol



pragma solidity 0.8.9;




/*
HoodSeeds - Whatever miner
*/

contract HoodSeeds is Context, Ownable {
    using SafeMath for uint256;

    uint256 private SEEDS_TO_BUY_FARM = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;

    //Revrite to smaller memory
    uint256 private devFeeVal = 1;
    uint256 private investFeeVal = 2;

    bool private initialized = false;

    address payable private devAddress;
    address payable private hoodAddress;
    address payable private investAddress;

    mapping(address => uint256) private stackedFarms;
    mapping(address => uint256) private claimedSeeds;
    mapping(address => uint256) private lastStack;
    mapping(address => address) private referrals;
    uint256 private marketSeeds;

    constructor(address hAddr, address iAddr) {
        devAddress = payable(msg.sender);
        hoodAddress = payable(hAddr);
        investAddress = payable(iAddr);
    }

    function stackFarms(address ref) public {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        uint256 seedsUsed = getMySeeds(msg.sender);
        // TODO: Check optimisation we dont need to store it here
        uint256 newFarms = SafeMath.div(seedsUsed, SEEDS_TO_BUY_FARM);
        stackedFarms[msg.sender] = SafeMath.add(stackedFarms[msg.sender], newFarms);
        claimedSeeds[msg.sender] = 0;
        lastStack[msg.sender] = block.timestamp;

        //send referral seeds
        // TODO: WHY FUCKED 8 IF 12 PROMISED for referrals
        claimedSeeds[referrals[msg.sender]] = SafeMath.add(claimedSeeds[referrals[msg.sender]], SafeMath.div(seedsUsed, 8));

        //boost market to nerf farms hoarding
        marketSeeds = SafeMath.add(marketSeeds, SafeMath.div(seedsUsed, 5));
    }

    function sellSeeds() public {
        require(initialized);
        uint256 hasSeeds = getMySeeds(msg.sender);
        uint256 seedValue = calculateSeedSell(hasSeeds);
        uint256 fee = devFee(seedValue);
        uint256 iFee = investFee(seedValue);
        claimedSeeds[msg.sender] = 0;
        lastStack[msg.sender] = block.timestamp;
        marketSeeds = SafeMath.add(marketSeeds, hasSeeds);
        devAddress.transfer(fee);
        hoodAddress.transfer(fee);
        investAddress.transfer(iFee);
        payable(msg.sender).transfer(SafeMath.sub(seedValue, fee));
    }

    function seedRewards(address adr) public view returns (uint256) {
        uint256 hasSeeds = getMySeeds(adr);
        uint256 seedValue = calculateSeedSell(hasSeeds);
        return seedValue;
    }

    function buySeeds(address ref) public payable {
        require(initialized);
        uint256 seedsBought = calculateSeedBuy(msg.value, SafeMath.sub(address(this).balance, msg.value));
        seedsBought = SafeMath.sub(seedsBought, SafeMath.mul(devFee(seedsBought),4));
        uint256 fee = devFee(msg.value);
        uint256 iFee = investFee(msg.value);
        devAddress.transfer(fee);
        hoodAddress.transfer(fee);
        investAddress.transfer(iFee);
        claimedSeeds[msg.sender] = SafeMath.add(claimedSeeds[msg.sender], seedsBought);
        stackFarms(ref);
    }

    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private view returns (uint256) {
        //buy - eth,contractBalance,marketSeeds
        // 0.2 | 0 | 108000000000
        // 207692307692,307

        //sell - seeds, marketSeeds, address(this).balance
        //29727539 | 108000000000 | 35
        //0,000000000324029
        return SafeMath.div(
        // 10000 * 108000000000

        // 10000 * 35
            SafeMath.mul(
                PSN,
                bs
            ),
        // 5000 + 200 = 5200

        // 5000 + 10000 * 108000000000 + 148637695000
            SafeMath.add(
                PSNH,
                SafeMath.div(
                // 1000 / 0.2 = 200

                // 10000 * 108000000000 + 148637695000
                    SafeMath.add(
                    // 10000 * 0

                    // 10000 * 108000000000
                        SafeMath.mul(
                            PSN,
                            rs
                        ),

                    // 5000 * 0.2 = 1000

                    // 5000 * 29727539 = 148637695000
                        SafeMath.mul(
                            PSNH,
                            rt
                        )
                    ),
                    rt
                )
            )
        );
    }

    function calculateSeedSell(uint256 seeds) public view returns (uint256) {
        return calculateTrade(seeds, marketSeeds, address(this).balance);
    }

    function calculateSeedBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketSeeds);
    }

    function devFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100);
    }

    function investFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, investFeeVal), 100);
    }

    function seedMarket() public payable onlyOwner {
        require(marketSeeds == 0);
        initialized = true;
        marketSeeds = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyFarms(address adr) public view returns (uint256) {
        return stackedFarms[adr];
    }

    function getMySeeds(address adr) public view returns (uint256) {
        return SafeMath.add(claimedSeeds[adr], getSeedsSinceLastStack(adr));
    }

    function getSeedsSinceLastStack(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(SEEDS_TO_BUY_FARM, SafeMath.sub(block.timestamp, lastStack[adr]));
        return SafeMath.mul(secondsPassed, stackedFarms[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}