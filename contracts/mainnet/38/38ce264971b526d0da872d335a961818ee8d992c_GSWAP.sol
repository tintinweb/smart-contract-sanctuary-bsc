/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/** 
      /$$$$$$   /$$$$$$  /$$      /$$  /$$$$$$ 
     /$$__  $$ /$$__  $$| $$$    /$$$ /$$__  $$
    | $$  \__/| $$  \ $$| $$$$  /$$$$| $$  \ $$
    | $$ /$$$$| $$  | $$| $$ $$/$$ $$| $$$$$$$$
    | $$|_  $$| $$  | $$| $$  $$$| $$| $$__  $$
    | $$  \ $$| $$  | $$| $$\  $ | $$| $$  | $$
    |  $$$$$$/|  $$$$$$/| $$ \/  | $$| $$  | $$
     \______/  \______/ |__/     |__/|__/  |__/
    
*/
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
}

interface IPancakeswapCalculations {
    // Uniswap/Sushiswap
    function getPriceUsdc(address tokenAddress) external view returns (uint256);
}

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

contract GSWAP is Ownable {
    using SafeMath for uint256;

    // address public V1 = 0x9f8a31DdE81A8fa13Aad31ad753D75cC1e30ed35;
    address public V1 = 0xAb14952d2902343fde7c65D7dC095e5c8bE86920;
    // address public V2 = 0x3E06419d60EC92785484457ecFB8Fd67CBC2e2d7;
    address public V2 = 0x9EC55d57208cb28a7714A2eA3468bD9d5bB15125;

    address public V1Backup = 0x21eFFbef01c8f269D9BAA6e0151A54D793113b45;
    // address public V2Treasury = 0x24bb6907efe6d5BCE80A50BE2e54929637378729;
    address public V2Treasury = 0x321194aeAb28031BA4B8D00b58DB0D38aB7c7Ffe;

    bool public postedLiquidity = false;
    bool private enabledManualRatio = true;
    uint256 private manualRatio = 100; // 100% = 1 : 1, 50% = 2 : 1
    uint256 private origV1PriceUsdc = 8900000000;

    mapping (address => bool) private _migrated;
    mapping (address => uint256) private _receivedV1Token;
    mapping (address => uint256) private _sentV2Token;
    
    event Migrated(address account, uint256 amount1, uint256 amount2);
    
    constructor () {
    }

    function migrated(address _address) external view returns (bool) {
        return _migrated[_address];
    }

    function getMigratedAmounts(address _address) external view returns (uint256, uint256) {
        return (_receivedV1Token[_address], _sentV2Token[_address]);
    }

    function setV1TokenAddress(address _address) external onlyOwner {
        V1 = _address;
    }

    function setV2TokenAddress(address _address) external onlyOwner {
        V2 = _address;
    }

    function setV1Backup(address _address) external onlyOwner {
        V1Backup = _address;
    }

    function setV2Treasury(address _address) external onlyOwner {
        V2Treasury = _address;
    }

    function enablePostLiquidity(bool value) external onlyOwner {
        postedLiquidity = value;
    }

    function enableManualRatio(bool value) external onlyOwner {
        enabledManualRatio = value;
    }

    function setRatioPercent(uint256 ratio) external onlyOwner {
        manualRatio = ratio;        
    }

    function setV1PriceOfUsdc(uint256 price) external onlyOwner {
        origV1PriceUsdc = price;
    }

    function getV1PriceUsdc() public view returns (uint256) {
        return IPancakeswapCalculations(0x26EAb094e543C8FF49980FA2CD02B34644a71478).getPriceUsdc(V1);
    }

    function getV2Amount(uint256 amount) public view returns (uint256) {
        uint256 v2Amount = amount;
        v2Amount = amount.add(amount.mul(3).div(100));

        if (postedLiquidity) {
            if (enabledManualRatio) { // manual ratio
                v2Amount = v2Amount.mul(manualRatio).div(100);
            }
            else { // automatic ratio based on usdc price
                uint256 currentPrice = getV1PriceUsdc();
                v2Amount = v2Amount.mul(currentPrice).div(origV1PriceUsdc);
            }
        }

        return v2Amount;
    }

    function migrate() public {
        address account = _msgSender();
        uint256 amount = IBEP20(V1).balanceOf(account);        
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 v2Amount = getV2Amount(amount);

        bool success = IBEP20(V1).transferFrom(account, V1Backup, amount);
        require(success, "Failed to transfer v1 token");

        _receivedV1Token[account] = _receivedV1Token[account] + amount;

        success = IBEP20(V2).transferFrom(V2Treasury, account, v2Amount);
        require(success, "Failed to transfer v2 token");

        _sentV2Token[account] = _sentV2Token[account] + v2Amount;

        _migrated[account] = true;

        emit Migrated(account, amount, v2Amount);
    }
}