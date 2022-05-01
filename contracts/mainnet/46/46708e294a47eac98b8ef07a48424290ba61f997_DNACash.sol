/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

/**************************************************************************************/
/*                                                                                    */
/*    $$$$$$$\  $$\   $$\  $$$$$$\                                      $$\           */
/*    $$  __$$\ $$$\  $$ |$$  __$$\                                     $$ |          */
/*    $$ |  $$ |$$$$\ $$ |$$ /  $$ |       $$$$$$$\  $$$$$$\   $$$$$$$\ $$$$$$$\      */
/*    $$ |  $$ |$$ $$\$$ |$$$$$$$$ |      $$  _____| \____$$\ $$  _____|$$  __$$\     */
/*    $$ |  $$ |$$ \$$$$ |$$  __$$ |      $$ /       $$$$$$$ |\$$$$$$\  $$ |  $$ |    */
/*    $$ |  $$ |$$ |\$$$ |$$ |  $$ |      $$ |      $$  __$$ | \____$$\ $$ |  $$ |    */
/*    $$$$$$$  |$$ | \$$ |$$ |  $$ |      \$$$$$$$\ \$$$$$$$ |$$$$$$$  |$$ |  $$ |    */
/*    \_______/ \__|  \__|\__|  \__|       \_______| \_______|\_______/ \__|  \__|    */
/*                                                                                    */
/**************************************************************************************/

/// @title DNA cash
/// @author DNA cash
/// @notice High-end engineered reward pool on the Binance Smart Chain
///         Up to 13% daily return and 15% referral bonus

/**************************************************************************************/
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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

/**************************************************************************************/
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

/**************************************************************************************/
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

/**************************************************************************************/
// File: contracts/dnacash.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract DNACash is Context, Ownable {
    using SafeMath for uint256;

    uint256 private TIME_TO_GET_ONE_MINER = 665000; // 864000 10%
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 29; // (30) 3%. (10) 1%
    uint256 private referralBonus = 15;
    bool private initialized = false;
    address[] private devAddrs;
    address private splitRewardsAddr;
    mapping(address => uint256) private miners;
    mapping(address => uint256) private claimedRewards;
    mapping(address => uint256) private lastClaim;
    mapping(address => address) private referrals;
    uint256 private marketRewards;

    constructor() {}

    // compound rewards
    function compoundRewards(address ref) public {
        require(initialized);

        if (ref == msg.sender || ref == address(0) || miners[ref] == 0) {
            ref = splitRewardsAddr;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        uint256 investmentUsed = getInvested(msg.sender);
        uint256 newMiners = SafeMath.div(investmentUsed, TIME_TO_GET_ONE_MINER);
        miners[msg.sender] = SafeMath.add(miners[msg.sender], newMiners);
        claimedRewards[msg.sender] = 0;
        lastClaim[msg.sender] = block.timestamp;

        // send referral rewards
        claimedRewards[referrals[msg.sender]] = SafeMath.add(
            claimedRewards[referrals[msg.sender]],
            SafeMath.div(SafeMath.mul(investmentUsed, referralBonus), 100)
        );

        // boost market to nerf miners hoarding
        marketRewards = SafeMath.add(
            marketRewards,
            SafeMath.div(investmentUsed, 5)
        );
    }

    // get rewards
    function getRewards() public {
        require(initialized);
        uint256 hasRewards = getInvested(msg.sender);
        uint256 rewardsValue = calculateRewardsSell(hasRewards);
        claimedRewards[msg.sender] = 0;
        lastClaim[msg.sender] = block.timestamp;
        marketRewards = SafeMath.add(marketRewards, hasRewards);
        uint256 devFeesAmount = SafeMath.div(
            SafeMath.mul(rewardsValue, devFeeVal),
            1000
        );
        payDevs(devFeesAmount);
        payable(msg.sender).transfer(SafeMath.sub(rewardsValue, devFeesAmount));
    }

    // buy dna
    function buyDna(address ref) public payable {
        require(initialized);
        uint256 investmentBought = calculateInvestBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        investmentBought = SafeMath.sub(
            investmentBought,
            devFee(investmentBought)
        );
        uint256 devFeesAmount = devFee(msg.value);
        payDevs(devFeesAmount);
        claimedRewards[msg.sender] = SafeMath.add(
            claimedRewards[msg.sender],
            investmentBought
        );
        compoundRewards(ref);
    }

    // pay the developers
    function payDevs(uint256 amount) private {
        uint256 howManyDevs = devAddrs.length;
        uint256 singleDevAmount = SafeMath.div(amount, howManyDevs);
        for (uint256 i = 0; i < howManyDevs; i++) {
            payable(devAddrs[i]).transfer(singleDevAmount);
        }
    }

    // magic trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return
            SafeMath.div(
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

    // calculate rewards for a specific address
    function calculateRewards(address adr) public view returns (uint256) {
        uint256 hasRewards = getInvested(adr);
        uint256 rewardsValue = calculateRewardsSell(hasRewards);
        return rewardsValue;
    }

    function calculateRewardsSell(uint256 rewards)
        public
        view
        returns (uint256)
    {
        return calculateTrade(rewards, marketRewards, address(this).balance);
    }

    function calculateInvestBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketRewards);
    }

    function calculateInvestBuySimple(uint256 eth)
        public
        view
        returns (uint256)
    {
        return calculateInvestBuy(eth, address(this).balance);
    }

    // calculate developer fee
    function devFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, devFeeVal), 1000);
    }

    // start the contract
    function seedMarket(address[] memory _addrs, address _splitRewards)
        public
        payable
        onlyOwner
    {
        require(marketRewards == 0);
        require(_addrs.length > 0);
        require(_splitRewards != address(0));
        for (uint256 i = 0; i < _addrs.length; i++) {
            devAddrs.push(_addrs[i]);
        }
        splitRewardsAddr = _splitRewards;
        initialized = true;
        marketRewards = 86400000000;
    }

    // get contract balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // get miners
    function getMiners(address adr) public view returns (uint256) {
        return miners[adr];
    }

    // get investment
    function getInvested(address adr) public view returns (uint256) {
        return SafeMath.add(claimedRewards[adr], getRewardsSinceLastClaim(adr));
    }

    function getRewardsSinceLastClaim(address adr)
        public
        view
        returns (uint256)
    {
        uint256 secondsPassed = min(
            TIME_TO_GET_ONE_MINER,
            SafeMath.sub(block.timestamp, lastClaim[adr])
        );
        return SafeMath.mul(secondsPassed, miners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}