/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

/**

███╗░░░███╗██╗██╗░░░░░██╗░░░░░██╗███╗░░░███╗░█████╗░░█████╗░██╗
████╗░████║██║██║░░░░░██║░░░░░██║████╗░████║██╔══██╗██╔══██╗╚═╝
██╔████╔██║██║██║░░░░░██║░░░░░██║██╔████╔██║███████║██║░░╚═╝░░░
██║╚██╔╝██║██║██║░░░░░██║░░░░░██║██║╚██╔╝██║██╔══██║██║░░██╗░░░
██║░╚═╝░██║██║███████╗███████╗██║██║░╚═╝░██║██║░░██║╚█████╔╝██╗
╚═╝░░░░░╚═╝╚═╝╚══════╝╚══════╝╚═╝╚═╝░░░░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝

███╗░░░███╗██╗██╗░░░░░██╗░░░░░██╗░█████╗░███╗░░██╗░█████╗░██╗██████╗░███████╗
████╗░████║██║██║░░░░░██║░░░░░██║██╔══██╗████╗░██║██╔══██╗██║██╔══██╗██╔════╝
██╔████╔██║██║██║░░░░░██║░░░░░██║██║░░██║██╔██╗██║███████║██║██████╔╝█████╗░░
██║╚██╔╝██║██║██║░░░░░██║░░░░░██║██║░░██║██║╚████║██╔══██║██║██╔══██╗██╔══╝░░
██║░╚═╝░██║██║███████╗███████╗██║╚█████╔╝██║░╚███║██║░░██║██║██║░░██║███████╗
╚═╝░░░░░╚═╝╚═╝╚══════╝╚══════╝╚═╝░╚════╝░╚═╝░░╚══╝╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚══════╝

███╗░░░███╗░█████╗░░█████╗░██╗░░██╗██╗███╗░░██╗███████╗
████╗░████║██╔══██╗██╔══██╗██║░░██║██║████╗░██║██╔════╝
██╔████╔██║███████║██║░░╚═╝███████║██║██╔██╗██║█████╗░░
██║╚██╔╝██║██╔══██║██║░░██╗██╔══██║██║██║╚████║██╔══╝░░
██║░╚═╝░██║██║░░██║╚█████╔╝██║░░██║██║██║░╚███║███████╗
╚═╝░░░░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░╚══╝╚══════╝

*/


// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]
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


// File @openzeppelin/contracts/utils/math/[email protected]
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


// File @openzeppelin/contracts/token/ERC20/[email protected]
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}


// File @openzeppelin/contracts/security/[email protected]
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity =0.8.7;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

contract CLOTMILLIMAC is ReentrancyGuard {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    /* ========== STATE VARIABLES ========== */

    struct Pool {
        uint256 top;
        uint256 current;
        uint256 ticketTotal;
        uint256[] wins;
    }

    mapping(uint256 => mapping(address => uint256)) private balance;
    mapping(uint256 => mapping(address => address)) private ref;
    mapping(uint256 => IterableMapping.Map) private ticketMap;
    Pool[] public pools;

    struct Ticket {
        uint256 from;
        uint256 to;
        uint256 multiplier;
    }

    Ticket[] public tickets;

    address public clotpool;
    address public serviceFeeReceiver;

    address[] private _winners;

    /* ========== MODIFIERS ========== */

    modifier lottery(uint256 poolID) {
        _;
        executeLottery(poolID);
        if (poolID < 3) executeLottery(poolID+1);
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(address _clotpool, address _serviceFeeReceiver) {
        clotpool = _clotpool;
        serviceFeeReceiver = _serviceFeeReceiver;

        _addTicket(0, 10, 4);
        _addTicket(10, 20, 3);
        _addTicket(20, 50, 2);
        _addTicket(50, 100, 1);

        _addPool(2.5 ether);
        pools[0].wins = [90];
        _addPool(25 ether);
        pools[1].wins = [50,25,15];
        _addPool(250 ether);
        pools[2].wins = [45,20,15,5,5];
        _addPool(2500 ether);
        pools[3].wins = [40,10,9,8,7,6,5,4,3,2];
    }

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
    event LotteryReward(address indexed winner, uint256 amount);

    /* ========== FUNCTIONS ========== */

    function sendFees(uint256 poolID) internal {
        uint256 amount = pools[poolID].current;
        bool success;

        uint256 feeToClotpool = amount.mul(3).div(100);
        uint256 feeToService = amount.mul(3).div(100);
        uint256 feeToNextPool = amount.mul(4).div(100);

        if (poolID == pools.length - 1) { // LAST POOL
            feeToService = amount.mul(4).div(100);
            feeToClotpool = amount.mul(2).div(100);
        } else {
            internalTranfer(poolID, poolID+1, feeToNextPool);
        }

        pools[poolID].current -= feeToClotpool;
        (success,) = payable(clotpool).call{value: feeToClotpool}("");
        pools[poolID].current -= feeToService;
        (success,) = payable(serviceFeeReceiver).call{value: feeToService}("");
    }

    function internalTranfer(uint256 from, uint256 to, uint256 amount) internal {
        pools[from].current -= amount;
        pools[to].current += amount;
    }

    function getMultiplier(uint256 poolID) public view returns (uint256) {
        uint256 currentPercent = pools[poolID].current * 100 / pools[poolID].top;

        for (uint i=0; i<tickets.length; i++) {
            if (tickets[i].from <= currentPercent && currentPercent < tickets[i].to) return tickets[i].multiplier;
        }

        return 1;
    }

    function stake(uint256 poolID) external payable nonReentrant lottery(poolID) {
        _stake(address(0), poolID);
    }

    function stakeWithRef(address referral, uint256 poolID) external payable nonReentrant lottery(poolID) {
        _stake(referral, poolID);
    }

    function _stake(address referral, uint256 poolID) internal {
        require(msg.value > 0, "Cannot stake 0");

        uint256 ticketAmount = getMultiplier(poolID) * msg.value;

        pools[poolID].current += msg.value;
        balance[poolID][msg.sender] += msg.value;

        if (ref[poolID][msg.sender] == address(0) && referral != address(0) && referral != msg.sender) {
            ref[poolID][msg.sender] = referral;

            addBalance(poolID, referral, ticketAmount.div(100));
        }
        addBalance(poolID, msg.sender, ticketAmount);

        emit Staked(msg.sender, msg.value);
    }

    function exit(uint256 poolID) external nonReentrant {
        require(balance[poolID][msg.sender] > 0, "Cannot withdraw 0");

        uint256 senderBalance = balance[poolID][msg.sender];

        pools[poolID].current -= senderBalance;
        balance[poolID][msg.sender] = 0;

        setBalanceToZero(poolID, msg.sender);

        uint256 feeToClotpool = senderBalance.mul(5).div(100);
        uint256 feeToService = senderBalance.mul(5).div(100);

        (bool success,) = payable(clotpool).call{value: feeToClotpool}("");
        (success,) = payable(serviceFeeReceiver).call{value: feeToService}("");

        senderBalance = senderBalance.sub(feeToService).sub(feeToClotpool);

        (success,) = payable(msg.sender).call{value: senderBalance}("");

        if (success) {
            emit Withdrawn(msg.sender, senderBalance);  
        }
    }

    function executeLottery(uint256 poolID) internal {
        if (canSendLottery(poolID)) {
            uint256 initialBalance = pools[poolID].current;
            sendFees(poolID);

            delete _winners;

            uint256 noWinCombo = 0;
            uint256 salt = 0;

            for (uint256 i=0; i<pools[poolID].wins.length; i++) {
                uint256 reward = initialBalance.mul(pools[poolID].wins[i]).div(100);

                noWinCombo = 0;
                address winner = address(0);
                bool existing = true;
                while (existing) {
                    if(noWinCombo >= 10) {
                        delete _winners;
                        noWinCombo = 0;
                    }

                    salt++;
                    winner = randWinningAddress(poolID, salt);

                    uint256 index = 0;
                    existing = false;
                    while (index < _winners.length) {
                        if (_winners[index] == winner) { 
                            existing = true;
                            noWinCombo++;
                            break;
                        }
                        index++;
                    }
                }

                if (winner == address(0)) break;

                pools[poolID].current -= reward;

                (bool success,) = payable(winner).call{value: reward}("");

                if(success) {
                    _winners.push(winner);

                    emit LotteryReward(winner, reward);
                }
            }

            while (ticketMap[poolID].size() > 0) {
                address account = ticketMap[poolID].getKeyAtIndex(0);
                balance[poolID][account] = 0;
                ref[poolID][account] = address(0);
                setBalanceToZero(poolID, account);
            }
        }
    }

    function canSendLottery(uint256 poolID) internal view returns (bool) {
        return pools[poolID].current >= pools[poolID].top;
    }

    function rand(uint256 poolID, uint256 salt) internal view returns (uint256) {
        uint256 randomHash = uint256(keccak256(abi.encodePacked(
            block.difficulty, block.timestamp, msg.sender, pools[poolID].ticketTotal, salt
        )));
        return randomHash % pools[poolID].ticketTotal + 1;
    }

    function randWinningAddress(uint256 poolID, uint256 salt) internal view returns (address) {
        if (pools[poolID].ticketTotal > 0) {
            uint256 winningTicket = rand(poolID, salt);
            uint256 checkedTickets = 0;
            uint256 index = 0;

            address addressToCheck = ticketMap[poolID].getKeyAtIndex(index);

            while (addressToCheck != address(0)) {
                checkedTickets = checkedTickets.add(getTickets(poolID, addressToCheck));

                if (checkedTickets >= winningTicket) {
                    return addressToCheck;
                }

                index++;
                addressToCheck = ticketMap[poolID].getKeyAtIndex(index);
            }
        }
        // No addresses eligible to lottery
        return address(0);
    }

    function setBalanceToZero(uint256 poolID, address account) internal {
        pools[poolID].ticketTotal -= getTickets(poolID, account);

        ticketMap[poolID].remove(account);
    }

    function addBalance(uint256 poolID, address account, uint256 additionalBalance) internal {
        if (additionalBalance > 0) {
            uint256 currentBalance = getTickets(poolID, account);
            ticketMap[poolID].set(account, currentBalance.add(additionalBalance));

            pools[poolID].ticketTotal += additionalBalance;
        }
    }

    function getTickets(uint256 poolID, address account) public view returns (uint256) {
        return ticketMap[poolID].get(account);
    }

    function _addTicket(uint256 from, uint256 to, uint256 multiplier) internal {
        require(multiplier >= 1 && to <= 100);

        if (tickets.length > 0)
            require(tickets[tickets.length-1].to == from);
        
        tickets.push(Ticket(from, to, multiplier));
    }

    function _addPool(uint256 top) internal {        
        pools.push(Pool(top, 0, 0, new uint256[](0)));
    }
}