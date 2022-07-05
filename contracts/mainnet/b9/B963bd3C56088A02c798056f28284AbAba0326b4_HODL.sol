/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: Unlicensed
//
//   __    __     ______     _____       __
//  |  |  |  |   /  __  \   |      \    |  |
//  |  |__|  |  |  |  |  |  |   _   \   |  |
//  |   __   |  |  |  |  |  |  |_)   |  |  |
//  |  |  |  |  |  `--'  |  |       /   |  |____
//  |__|  |__|   \______/   |_____ /    |_______|
//
//
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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

interface IWBNB {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    receive() external payable;

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
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
contract Ownable is Context, Initializable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {}

    function initOwner(address owner_) public initializer {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountETHDesired,
        uint256 amountAMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountETH,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountETH);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountETH);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(

        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountETH);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: contracts/protocols/bep/Utils.sol

pragma solidity ^0.8.0;

library Utils {
    using SafeMath for uint256;
   
    function calculateBNBReward(
        uint256 currentBalance,
        uint256 currentBNBPool,
        uint256 totalSupply,
        uint256 rewardHardcap
    ) public pure returns (uint256) {
        uint256 bnbPool = currentBNBPool > rewardHardcap ? rewardHardcap : currentBNBPool;
        return bnbPool.mul(currentBalance).div(totalSupply);
    }

    function calculateTopUpClaim(
        uint256 currentRecipientBalance,
        uint256 basedRewardCycleBlock,
        uint256 threshHoldTopUpRate,
        uint256 amount
    ) public pure returns (uint256) {
        uint256 rate = amount.mul(100).div(currentRecipientBalance);

        if (rate >= threshHoldTopUpRate) {
            uint256 incurCycleBlock = basedRewardCycleBlock
                .mul(rate)
                .div(100);

            if (incurCycleBlock >= basedRewardCycleBlock) {
                incurCycleBlock = basedRewardCycleBlock;
            }

            return incurCycleBlock;
        }

        return 0;
    }

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        public
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function swapETHForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function swapTokensForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ethAmount, // wbnb input
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function getAmountsout(uint256 amount, address routerAddress)
        public
        view
        returns (uint256 _amount)
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // fetch current rate
        uint256[] memory amounts = pancakeRouter.getAmountsOut(amount, path);
        return amounts[1];
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 360
        );
    }
    
    /**
    * @dev Returns the stacked amount of rewards. 
    *
    * First add reflections to the amount of stacked tokens. If the stackingRate is 0
    * stacking was started before refelctions were implemented into the contract. 
    * 
    * Then calculate the reward and check with the stacking limit.
    *
    *   "Scared money don't make money" - Billy Napier 
    */
    function calcStacked(StackingStruct.stacking memory tmpstacking, uint256 totalsupply, uint256 currentRate, uint256 stackingRate) public view returns (uint256) {
        uint256 reward;
        uint256 amount;

        uint256 stackedTotal = 1E6 + (block.timestamp-tmpstacking.tsStartStacking).mul(1E6) / tmpstacking.cycle;
        uint256 stacked = stackedTotal.div(1E6);
        uint256 rest = stackedTotal-stacked.mul(1E6);
        
        uint256 initialBalance = address(this).balance;

        if (stackingRate > 0)
        {
            amount = tmpstacking.amount * stackingRate / currentRate;
        } else {
            amount = tmpstacking.amount;
        }
        
        if (initialBalance >= tmpstacking.hardcap)
        {
            reward = uint256(tmpstacking.hardcap) * amount / totalsupply * stackedTotal / 1E6;
            if (reward >= initialBalance) reward = 0;

            if (reward == 0 || initialBalance.sub(reward) < tmpstacking.hardcap)
            {
                reward = initialBalance - calcReward(initialBalance, totalsupply /amount, stacked, 15);
                reward += initialBalance.sub(reward) * amount / totalsupply * rest / 1E6;
            }
        } else {
            reward = initialBalance - calcReward(initialBalance, totalsupply / amount, stacked, 15); 
            reward += initialBalance.sub(reward) * amount / totalsupply * rest / 1E6;
        }

        return reward > tmpstacking.stackingLimit ? uint256(tmpstacking.stackingLimit) : reward;
    }

    /** 
    * @dev Computes `k * (1+1/q) ^ N`, with precision `p`. The higher
    * the precision, the higher the gas cost. To prevent overflows devide
    * exponent into 3 exponents with max n^10
    */
    function calcReward(uint256 coefficient, uint256 factor, uint256 exponent, uint256 precision) public pure returns (uint256) {
        
        precision = exponent < precision ? exponent : precision;
        if (exponent > 100) {
            precision = 30;
        }
        if (exponent > 200) exponent = 200;

        uint256 reward = coefficient;
        uint256 calcExponent = exponent * (exponent-1) / 2;
        uint256 calcFactor_1 = 1;
        uint256 calcFactor_2 = 1;
        uint256 calcFactor_3 = 1;
        uint256 i;

        for (i = 2; i <= precision; i += 2){
            if (i > 20) {
                calcFactor_1 = factor**10;
                calcFactor_2 = calcFactor_1;
                 calcFactor_3 = factor**(i-20);
            }
            else if (i > 10) {
                calcFactor_1 = factor**10;
                calcFactor_2 = factor**(i-10);
                calcFactor_3 = 1;
            }
            else {
                calcFactor_1 = factor**i;
                calcFactor_2 = 1;
                calcFactor_3 = 1;
            }
            reward += coefficient * calcExponent / calcFactor_1 / calcFactor_2 / calcFactor_3;
            calcExponent = i == exponent ? 0 : calcExponent * (exponent-i) * (exponent-i-1) / (i+1) / (i+2);  
        }
        
        calcExponent = exponent;

        for (i = 1; i <= precision; i += 2){
            if (i > 20) {
                calcFactor_1 = factor**10;
                calcFactor_2 = calcFactor_1;
                calcFactor_3 = factor**(i-20);
            }
            else if (i > 10) {
                calcFactor_1 = factor**10;
                calcFactor_2 = factor**(i-10);
                calcFactor_3 = 1;
            }
            else {
                calcFactor_1 = factor**i;
                calcFactor_2 = 1;
                calcFactor_3 = 1;
            }
            reward -= coefficient * calcExponent / calcFactor_1 / calcFactor_2 / calcFactor_3;
            calcExponent = i == exponent ? 0 : calcExponent * (exponent-i) * (exponent-i-1) / (i+1) / (i+2);  
        }

        return reward;
    }

}

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(
            IPancakeFactory(factory).getPair(tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountETH) {
        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountETH = amountA.mul(reserveB) / reserveA;
    }

}

// File: contracts/protocols/bep/ReentrancyGuard.sol

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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

// File: contracts/protocols/HODL.sol

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract HODL is Context, IBEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxTx;

    // trace BNB claimed rewards and reinvest value
    mapping(address => uint256) public userClaimedBNB;
    uint256 public totalClaimedBNB;

    mapping(address => uint256) public userreinvested;
    uint256 public totalreinvested;

    // trace gas fees distribution
    uint256 private totalgasfeesdistributed;
    mapping(address => uint256) private userrecievedgasfees;

    address public deadAddress;

    address[] private _excluded;

    uint256 private MAX;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;

    bool private _inSwapAndLiquify;

    uint256 private daySeconds;

    struct WalletAllowance {
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => WalletAllowance) userWalletAllowance;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event ClaimBNBSuccessfully(
        address recipient,
        uint256 ethReceived,
        uint256 nextAvailableClaimDate
    );

    event SetMaxTxPercent(uint256 newValue);

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor() {}

    mapping(address => bool) isBlacklisted;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) external onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Pancake router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {      
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**3);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256){
        return _amount.mul(_liquidityFee).div(10**3);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            reflectionFeesDisabled
        ) {
            takeFee = false;
        }

        // take sell fee
        if (
            pairAddresses[to] &&
            from != address(this) &&
            from != owner()
        ) {
            /*
            *   "If you can't hold, you won't be rich" - CZ
            */
            ensureMaxTxAmount(from, to, amount);          
            _taxFee = selltax.mul(_Reflection).div(100); 
            _liquidityFee = selltax.mul(_Tokenomics).div(100);
            if (!_inSwapAndLiquify) {
                swapAndLiquify(from, to);
            }
        }
        
        // take buy fee
        else if (
            pairAddresses[from] && to != address(this) && to != owner()
        ) {
            _taxFee = buytax.mul(_Reflection).div(100);
            _liquidityFee = buytax.mul(_Tokenomics).div(100);
        }
        
        // take transfer fee
        else {
            if (takeFee && from != owner() && from != address(this)) {
                _taxFee = transfertax.mul(_Reflection).div(100);
                _liquidityFee = transfertax.mul(_Tokenomics).div(100);
            }
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        // top up claim cycle for recipient and sender
        topUpClaimCycleAfterTransfer(sender, recipient, amount);

        // top up claim cycle for sender
        //topUpClaimCycleAfterTransfer(sender, amount);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Innovation for protocol by HODL Team
    uint256 public rewardCycleBlock;
    uint256 private reserve_2;
    uint256 public threshHoldTopUpRate;
    uint256 public _maxTxAmount;
    uint256 public bnbStackingLimit;
    mapping(address => uint256) public nextAvailableClaimDate;
    bool public swapAndLiquifyEnabled;
    uint256 private reserve_5;
    uint256 private reserve_6;

    bool public reflectionFeesDisabled;

    uint256 private _taxFee;
    uint256 private _previousTaxFee;

    uint256[6] private antiFlipTax;

    LayerTax public bnbClaimTax;

    struct LayerTax {
        uint256 layer1;
        uint256 layer2;
        uint256 layer3;
        uint256 layer4;
        uint256 layer5;
        uint256 layer6;
    }

    uint256 public selltax;
    uint256 public buytax;
    uint256 public transfertax;

    uint256 public claimBNBLimit;
    uint256 public reinvestLimit;
    uint256 private reserve_1;

    address public reservewallet;
    address public teamwallet;
    address public marketingwallet;
    address public stackingWallet;
    
    uint256 private _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public minTokenNumberToSell; 
    uint256 public minTokenNumberUpperlimit;

    uint256 public rewardHardcap;

    Tokenomics public tokenomics;
    
    struct Tokenomics {
        uint256 bnbReward;
        uint256 liquidity;
        uint256 marketing;
        uint256 reflection;
        uint256 reserve;
    }

    uint256 private _Reflection;
    uint256 private _Tokenomics;

    address public triggerwallet;

    mapping(address => bool) public pairAddresses;

    address public HodlMasterChef;

    mapping(address => uint256) private firstBuyTimeStamp;

    mapping(address => StackingStruct.stacking) public rewardStacking;
    bool public stackingEnabled;

    mapping(address => uint256) private stackingRate;

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        require(maxTxPercent <= 100, "Error");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(100000);
        emit SetMaxTxPercent(maxTxPercent);
    }

    event changeValue(string tag, uint256 value);

    event StartStacking(
        address sender,
        uint256 amount
    );

    function setExcludeFromMaxTx(address _address, bool value) external onlyOwner{
        _isExcludedFromMaxTx[_address] = value;
    }

    /*
    *   "Rome was not built in a day" - John Heywood
    */
    function calculateBNBReward(address ofAddress) external view returns (uint256){
        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(address(0)))
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        
        return Utils.calculateBNBReward(
                balanceOf(address(ofAddress)),
                address(this).balance,
                totalsupply,
                rewardHardcap
            );
    }

    /** @dev Function to claim the rewards.
    *   First calculate the rewards with checking rewardhardcap and current pool
    *   Depending on user selected percentage pay reward in bnb or reinvest in tokens
    *
    *   "Keep building. That's how you prove them wrong." - David Gokhstein     
    */
    function redeemRewards(uint256 perc) external isHuman nonReentrant {
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: next available not reached");
        require(balanceOf(msg.sender) > 0, "Error: must own HODL to claim reward");

        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        uint256 currentBNBPool = address(this).balance;

        uint256 reward = currentBNBPool > rewardHardcap ? rewardHardcap.mul(balanceOf(msg.sender)).div(totalsupply) : currentBNBPool.mul(balanceOf(msg.sender)).div(totalsupply);

        uint256 rewardreinvest;
        uint256 rewardBNB;

        if (perc == 100) {
            require(reward > claimBNBLimit, "Reward below gas fee");
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {
            
            require(reward > reinvestLimit, "Reward below gas fee");

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;

            uint256 rAmount = expectedtoken * _getRate();
        
            if (_isExcluded[msg.sender]) { 
                _rOwned[msg.sender] = _rOwned[msg.sender].add(rAmount);
                _tOwned[msg.sender] = _tOwned[msg.sender].add(expectedtoken);
                _rOwned[address(this)] = _rOwned[address(this)].add(rAmount);
            } else {
                _rOwned[msg.sender] = _rOwned[msg.sender].add(rAmount);
                _rOwned[address(this)] = _rOwned[address(this)].sub(rAmount);
            }
            emit Transfer(stackingWallet, msg.sender, expectedtoken);
            //_tokenTransfer(address(this), msg.sender, expectedtoken, false);

        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            uint256 rewardfee;
            bool success;
            // deduct tax
            if (rewardBNB < 0.1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer1).div(100);
            } else if (rewardBNB < 0.25 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer2).div(100);
            } else if (rewardBNB < 0.5 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer3).div(100);
            } else if (rewardBNB < 0.75 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer4).div(100);
            } else if (rewardBNB < 1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer5).div(100);
            } else {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer6).div(100);
            }
            rewardBNB -= rewardfee;
            (success, ) = address(reservewallet).call{value: rewardfee}("");
            require(success, " Error: Cannot send reward");

            // send bnb to user
            (success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Error: Cannot withdraw reward");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }

    function topUpClaimCycleAfterTransfer(address _sender, address _recipient, uint256 amount) private {
        //_recipient
        uint256 currentBalance = balanceOf(_recipient);
        if ((_recipient == owner() && nextAvailableClaimDate[_recipient] == 0) || currentBalance == 0) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
        } else {
            nextAvailableClaimDate[_recipient] += Utils.calculateTopUpClaim(
                                                currentBalance,
                                                rewardCycleBlock,
                                                threshHoldTopUpRate,
                                                amount);
            if (nextAvailableClaimDate[_recipient] > block.timestamp + rewardCycleBlock) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
            }
        }

        //sender
        if (_recipient != HodlMasterChef) {
            currentBalance = balanceOf(_sender);
            if ((_sender == owner() && nextAvailableClaimDate[_sender] == 0) || currentBalance == 0) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
            } else {
                nextAvailableClaimDate[_sender] += Utils.calculateTopUpClaim(
                                                    currentBalance,
                                                    rewardCycleBlock,
                                                    threshHoldTopUpRate,
                                                    amount);
                if (nextAvailableClaimDate[_sender] > block.timestamp + rewardCycleBlock) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
                }                                     
            }
        }
    }

    function ensureMaxTxAmount(address from, address to, uint256 amount) private {
        if (
            _isExcludedFromMaxTx[from] == false && // default will be false
            _isExcludedFromMaxTx[to] == false // default will be false
        ) {
                WalletAllowance storage wallet = userWalletAllowance[from];

                if (block.timestamp > wallet.timestamp.add(daySeconds)) {
                    wallet.timestamp = 0;
                    wallet.amount = 0;
                }

                uint256 totalAmount = wallet.amount.add(amount);

                require(
                    totalAmount <= _maxTxAmount,
                    "Amount is more than the maximum limit"
                );

                if (wallet.timestamp == 0) {
                    wallet.timestamp = block.timestamp;
                }

                wallet.amount = totalAmount;
        }
    }

    /* @dev Function that swaps tokens from the contract for bnb
    *   Bnb is split up due to tokenomics and send to the specified wallets
    *
    *       "They talk, we build" - Josh from StaySAFU
    */
    function swapAndLiquify(address from, address to) private lockTheSwap {

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 initialBalance = address(this).balance;

        if (contractTokenBalance >= minTokenNumberUpperlimit &&
            initialBalance <= rewardHardcap &&
            swapAndLiquifyEnabled &&
            from != pancakePair &&
            !(from == address(this) && to == address(pancakePair))
            ) {             
                Utils.swapTokensForEth(address(pancakeRouter), minTokenNumberToSell);       
                uint256 deltaBalance = address(this).balance.sub(initialBalance);

                if (tokenomics.marketing > 0) {
                    // send marketing rewards
                    (bool sent, ) = payable(address(marketingwallet)).call{value: deltaBalance.mul(tokenomics.marketing).div(_Tokenomics)}("");
                    require(sent, "Error: Cannot send reward");
                }

                if (tokenomics.reserve > 0) {
                    // send resere rewards
                    (bool succ, ) = payable(address(reservewallet)).call{value: deltaBalance.mul(tokenomics.reserve).div(_Tokenomics)}("");
                    require(succ, "Error: Cannot send reward");
                }   

                if (tokenomics.liquidity > 0) {
                    // add liquidity to pancake
                    uint256 liquidityToken = minTokenNumberToSell.mul(tokenomics.liquidity).div(_Tokenomics);
                    Utils.addLiquidity(
                        address(pancakeRouter),
                        owner(),
                        liquidityToken,
                        deltaBalance.mul(tokenomics.liquidity).div(_Tokenomics)
                    ); 
                    emit SwapAndLiquify(liquidityToken, deltaBalance, liquidityToken);
                }          
            }
    }

    function triggerSwapAndLiquify() external lockTheSwap {
        require(((_msgSender() == address(triggerwallet)) || (_msgSender() == owner())) && swapAndLiquifyEnabled, "Wrong caller or swapAndLiquify not enabled");

        uint256 initialBalance = address(this).balance;

        //check triggerwallet balance
        if (address(triggerwallet).balance < 0.1 ether && initialBalance > 0.1 ether) {
            (bool sent, ) = payable(address(triggerwallet)).call{value: 0.1 ether}("");
            require(sent, "Error: Cannot send gas fee");
            initialBalance = address(this).balance;
        }

        Utils.swapTokensForEth(address(pancakeRouter), minTokenNumberToSell);       
        uint256 deltaBalance = address(this).balance.sub(initialBalance);

        if (tokenomics.marketing > 0) {
            // send marketing rewards
            (bool sentm, ) = payable(address(marketingwallet)).call{value: deltaBalance.mul(tokenomics.marketing).div(_Tokenomics)}("");
            require(sentm, "Error: Cannot send reward");
        }

        if (tokenomics.reserve > 0) {
            // send resere rewards
            (bool sentr, ) = payable(address(reservewallet)).call{value: deltaBalance.mul(tokenomics.reserve).div(_Tokenomics)}("");
            require(sentr, "Error: Cannot send reward");
        }

        if (tokenomics.liquidity > 0) {
            // add liquidity to pancake
            uint256 liquidityToken = minTokenNumberToSell.mul(tokenomics.liquidity).div(_Tokenomics);
            Utils.addLiquidity(
                address(pancakeRouter),
                owner(),
                liquidityToken,
                deltaBalance.mul(tokenomics.liquidity).div(_Tokenomics)
            ); 
            emit SwapAndLiquify(liquidityToken, deltaBalance, liquidityToken);
        }
    }

    function changeRewardCycleBlock(uint256 newcycle) external onlyOwner {
        require(newcycle >= 86400, "Error"); //min 1 day
        rewardCycleBlock = newcycle;
    }

    function changeReserveWallet(address payable _newaddress) external onlyOwner {
        require(_newaddress != address(0), "Error"); 
        reservewallet = _newaddress;
    }

    function changeMarketingWallet(address payable _newaddress) external onlyOwner {
        require(_newaddress != address(0), "Error");
        marketingwallet = _newaddress;
    }

    function changeTriggerWallet(address payable _newaddress) external onlyOwner {
        require(_newaddress != address(0), "Error");
        triggerwallet = _newaddress;
    }

    // disable enable reflection fee , value == false (enable)
    function reflectionFeeStartStop(bool _value) external onlyOwner {
        reflectionFeesDisabled = _value;
    }

    function migrateToken(address _newadress, uint256 _amount) external onlyOwner{
        removeAllFee();
        _transferStandard(address(this), _newadress, _amount);
        restoreAllFee();
    }

    function migrateWBnb(address _newadress, uint256 _amount) external onlyOwner {
        IWBNB(payable(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c))).transfer(_newadress,_amount);
    }

    function migrateBnb(address payable _newadd, uint256 amount) external onlyOwner{
        require(_newadd != address(0), "Error");
        (bool success, ) = address(_newadd).call{value: amount}("");
        require(success, "Address: unable to send value, charity may have reverted");
    }

    function changeThreshHoldTopUpRate(uint256 _newrate) external onlyOwner {
        threshHoldTopUpRate = _newrate;
    }

    function changeSellTax(uint256 _selltax) external onlyOwner {
        require(_selltax <= 110, "Error");
        selltax = _selltax;
        emit changeValue("sell tax", _selltax);  
    }

    function changeBuyTax(uint256 _buytax) external onlyOwner {
        require(_buytax <= 110, "Error");
        buytax = _buytax;
        emit changeValue("buy tax", _buytax);
    }

    function changeTransferTax(uint256 _transfertax) external onlyOwner {
        require(_transfertax <= 110, "Error");
        transfertax = _transfertax;
        emit changeValue("transfer tax", _transfertax);
    }

    function changeTokenomics(uint256 bnbReward, uint256 liquidity, uint256 marketing, uint256 reflection, uint256 reserve) external onlyOwner {
        require(bnbReward + liquidity + marketing + reflection + reserve == 100, "Have to be 100 in total");
        tokenomics = Tokenomics(bnbReward, liquidity, marketing, reflection, reserve);
        updateTokenomics();
    }

    function changeBnbClaimTax(uint256 _layer1, uint256 _layer2, uint256 _layer3, uint256 _layer4, uint256 _layer5, uint256 _layer6) external onlyOwner {
        require(_layer1 <= 250 && _layer2 <= 250 && _layer3 <= 250 && _layer4 <= 250 && _layer5 <= 250 && _layer6 <= 250, "Error");
        bnbClaimTax = LayerTax(_layer1, _layer2, _layer3, _layer4, _layer5, _layer6);
    }           

    function changeMinTokenNumberToSell(uint256 _newvalue) external onlyOwner {
        require(_newvalue <= minTokenNumberUpperlimit, "Incorrect Value");
        minTokenNumberToSell = _newvalue;
        emit changeValue("MinTokenNumberToSell", _newvalue);
    }

    function changeMinTokenNumberUpperLimit(uint256 _newvalue) external onlyOwner {
        require(_newvalue >= minTokenNumberToSell, "Incorrect Value");
        minTokenNumberUpperlimit = _newvalue;
        emit changeValue("MinTokenNumberUpperLimit", _newvalue);
    }

    function changeRewardHardcap(uint256 _newvalue) external onlyOwner {
        require(_newvalue >= 1e18, "Error");
        rewardHardcap = _newvalue;
        emit changeValue("RewardHardcap", _newvalue);
    }

    function updateTokenomics() private {
        _Reflection = tokenomics.reflection;
        _Tokenomics = tokenomics.bnbReward.add
                      (tokenomics.marketing).add
                      (tokenomics.liquidity).add
                      (tokenomics.reserve);
    }

    function updatePairAddress(address _pairAddress, bool _enable) external onlyOwner {
        require(pairAddresses[_pairAddress] != _enable, "Will have no effect..");
        pairAddresses[_pairAddress] = _enable;
    }

    function changeClaimBNBLimit(uint256 _newvalue) external onlyOwner {
        require(_newvalue <= 1e16, "Error"); //0.01bnb
        claimBNBLimit = _newvalue;
        emit changeValue("ClaimBNBLimit", _newvalue);
    }

    function changeReinvestLimit(uint256 _newvalue) external onlyOwner {
        require(_newvalue <= 1e16, "Error"); //0.01bnb
        reinvestLimit = _newvalue;
        emit changeValue("ReinvestLimit", _newvalue);
    }

    function changeHODLMasterChef(address _newaddress) external onlyOwner {
        require(_newaddress != address(0), "Error");
        HodlMasterChef = _newaddress;
    }

    function changeStackingWallet(address payable _newaddress) external onlyOwner {
        require(_newaddress != address(0), "Error");
        stackingWallet = _newaddress;
    }

    function enableStacking(bool _enable) external onlyOwner {
        stackingEnabled = _enable;
    }

    function changeBNBstackingLimit(uint256 _newvalue) external onlyOwner {
        require(_newvalue >= 1e16, "Error"); //min 0.01bnb
        bnbStackingLimit = _newvalue;
        emit changeValue("BNBstackingLimit", _newvalue);
    }

    /*  @dev Function to start rward stacking. the whole tokens (minus 1) are sent to the
    *   stacking wallet. While stacking is enabled the bnb reward is accumulated.
    *   Once the user stops stacking the amount it sent back plus the accumulated reward.
    *
    *       "HODL Bears to ride Bulls" - Adam Roberts
    */
    function startStacking() external {
        
        uint96 balance = uint96(balanceOf(msg.sender)-1E9);

        require(stackingEnabled && !rewardStacking[msg.sender].enabled, "Not available");
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: next available not reached");
        require(balance > 15000000000000000, "Error: Wrong amount");

        rewardStacking[msg.sender] = StackingStruct.stacking(
            true, 
            uint64(rewardCycleBlock), 
            uint64(block.timestamp), 
            uint96(bnbStackingLimit), 
            uint96(balance), 
            uint96(rewardHardcap));

        uint256 currentRate = _getRate();
        stackingRate[msg.sender] = currentRate;

        uint256 rBalance = balance * currentRate;

        if (_isExcluded[msg.sender]) { 
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(balance);
            _rOwned[msg.sender] = _rOwned[msg.sender].sub(rBalance);
            _rOwned[stackingWallet] = _rOwned[stackingWallet].add(rBalance);
        } else {
            _rOwned[msg.sender] = _rOwned[msg.sender].sub(rBalance);
            _rOwned[stackingWallet] = _rOwned[stackingWallet].add(rBalance);
        }
        //_tokenTransfer(msg.sender, stackingWallet, balance, false);
        emit Transfer(msg.sender, stackingWallet, balance);
        emit StartStacking(msg.sender, balance);
    }
    
    function getStacked(address _address) public view returns (uint256) {
        StackingStruct.stacking memory tmpStack =  rewardStacking[_address];
        if (tmpStack.enabled) {
            uint256 totalsupply = uint256(_tTotal)
                .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
                .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        
            return Utils.calcStacked(tmpStack, totalsupply, _getRate(), stackingRate[msg.sender]);
        }
        return 0;
    }

    /* @dev Technically same function as 'redeemReward' but with stacked amount and 
    *  stacked claim cycles. Reward is calculated with function getStacked.
    *   
    *   "Max pain before gain in crypto" - Travladd
    *
    *   Reflections are added before amount is sent back to the user
    */
    function stopStackingAndClaim(uint256 perc) external nonReentrant {

        StackingStruct.stacking memory tmpstacking = rewardStacking[msg.sender];

        require(tmpstacking.enabled, "Stacking not enabled");
        uint256 amount;
        uint256 rewardBNB;
        uint256 rewardreinvest;
        uint256 reward = getStacked(msg.sender);

        if (perc == 100) {
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;
            _tokenTransfer(address(this), msg.sender, expectedtoken, false);

        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            uint256 rewardfee;
            bool success;
            // deduct tax
            if (rewardBNB < 0.1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer1).div(100);
            } else if (rewardBNB < 0.25 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer2).div(100);
            } else if (rewardBNB < 0.5 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer3).div(100);
            } else if (rewardBNB < 0.75 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer4).div(100);
            } else if (rewardBNB < 1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer5).div(100);
            } else {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer6).div(100);
            }
            rewardBNB -= rewardfee;
            (success, ) = address(reservewallet).call{value: rewardfee}("");
            require(success, " Error: Cannot send reward");

            // send bnb to user
            (success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Error: Cannot withdraw reward");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        uint256 rate = stackingRate[msg.sender];
        uint256 currentRate =  _getRate();

        if (rate > 0)
        {
            amount = tmpstacking.amount * rate /currentRate;
        } else {
            amount = tmpstacking.amount;
        }

        uint256 rAmount = amount *  currentRate;
        
        if (_isExcluded[msg.sender]) { 
            _rOwned[msg.sender] = _rOwned[msg.sender].add(rAmount);
            _tOwned[msg.sender] = _tOwned[msg.sender].add(amount);
            _rOwned[stackingWallet] = _rOwned[stackingWallet].add(rAmount);
        } else {
            _rOwned[msg.sender] = _rOwned[msg.sender].add(rAmount);
            _rOwned[stackingWallet] = _rOwned[stackingWallet].sub(rAmount);
        }
        emit Transfer(stackingWallet, msg.sender, amount);
        //_tokenTransfer(stackingWallet, msg.sender, amount, false);

        StackingStruct.stacking memory tmpStack;
        rewardStacking[msg.sender] = tmpStack;

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }

    function withdrawBEB20(address _token, uint256 amount) external onlyOwner {
        uint256 tokenBalance = IBEP20(_token).balanceOf(address(this));
        if (amount == 0) {
            amount = tokenBalance;
        } else {
            require(amount <= tokenBalance, "Wrong amount");
        }
        IBEP20(_token).transfer(msg.sender, amount);
    }

}

library StackingStruct {
    struct stacking {
        bool enabled;
        uint64 cycle;
        uint64 tsStartStacking;
        uint96 stackingLimit;
        uint96 amount;
        uint96 hardcap;   
    }
}