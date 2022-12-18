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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/BitMaps.sol)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMOBLock {
    function lockTreasury(address adr, uint256 amount) external;

    function treasuryAvailableClaim(address adr, uint256 percent)
        external
        view
        returns (uint256 avl, uint256 claimed);

    function releaseTreasury(address adr, uint256 percent)
        external
        returns (uint256);

    function lockNFT(
        address adr,
        uint256 init,
        uint256 amount
    ) external;

    function addLiq(
        address adr,
        uint256 amount,
        uint256 addedLp
    ) external;

    function releaseNFT(address adr, uint256 percent)
        external
        returns (uint256 released, uint256 blackhole);

    function nftAvailableClaim(address adr, uint256 percent)
        external
        view
        returns (uint256 avl, uint256 claimed);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PancakeLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   //mainnet
            )))));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "./library/Math.sol";
import "./library/SafeMath.sol";
import "./library/PancakeLibrary.sol";
import "./interface/IPancakeRouter01.sol";
import "./interface/IPancakePair.sol";
import "./interface/IPancakeFactory.sol";
import "./interface/IMOBLock.sol";
import "./Rel.sol";

contract MOB is IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using BitMaps for BitMaps.BitMap;

    struct BuyOrder {
        uint256 timestamp;
        uint256 price;
        uint256 amount;
        uint256 claimed;
    }

    event addFeeWl(address indexed adr);

    event removeFeeWl(address indexed adr);

    event addBotWl(address indexed adr);

    event removeBotWl(address indexed adr);

    event addBL(address indexed adr);

    event removeBL(address indexed adr);

    event distributeLpFee(uint256 amount);

    event distributeNftFee(uint256 amount);

    address private constant ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private constant USDT_ADDRESS =
        0x55d398326f99059fF775485246999027B3197955;

    uint256 public constant LP_DIS_AMOUNT = 3000 * 1e18;

    uint256 public constant NFT_DIS_AMOUNT = 6000 * 1e18;

    uint256 public constant initPrice = 1e16;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address public communityAddress;

    address public techAddress;

    address public netAddress;

    address public relAddress;

    address public lockAddress;

    address public comTreasury;

    address public techTreasury;

    uint256 public startTradeTime = 2**200;

    mapping(address => BuyOrder[]) public buyOrderPerAccount;

    address public pair;

    mapping(address => uint256) public buyPerAccount;

    mapping(address => uint256) public sellPerAccount;

    mapping(address => uint256) public feePerAccount;

    BitMaps.BitMap private feeWhitelist;

    BitMaps.BitMap private botWhitelist;

    BitMaps.BitMap private bList;

    uint256 public lpFeeDisAmount;

    uint256 public lpFee;

    uint256 public nftFeeDisAmount;

    uint256 public nftFee;

    constructor(
        address _receiver,
        address _genesis,
        address _techAddress,
        address _communityAddress,
        address _netAddress,
        address _comTreasury,
        address _techTreasury,
        address _relAddress
    ) {
        _name = "MobileCoin";
        _symbol = "MOB";
        techAddress = _techAddress;
        communityAddress = _communityAddress;
        relAddress = _relAddress;
        comTreasury = _comTreasury;
        techTreasury = _techTreasury;
        netAddress = _netAddress;
        pair = IPancakeFactory(IPancakeRouter01(ROUTER_ADDRESS).factory())
            .createPair(address(this), USDT_ADDRESS);
        _mint(_receiver, 1000000 * 10**decimals());
        addFeeWhitelist(_genesis);
        addFeeWhitelist(_receiver);
        addFeeWhitelist(techAddress);
        addFeeWhitelist(communityAddress);
    }

    function setLockAdress(address adr) external onlyOwner {
        lockAddress = adr;
    }

    function setStartTradeTime(uint256 startTime) external onlyOwner {
        startTradeTime = startTime;
    }

    function airdropTreasury() external onlyOwner {
        IMOBLock lock = IMOBLock(lockAddress);
        uint256 amount = 1000000 * 10**decimals();
        _mint(lockAddress, amount);
        lock.lockTreasury(comTreasury, amount);
        amount = 1000000 * 10**decimals();
        _mint(lockAddress, amount);
        lock.lockTreasury(techTreasury, amount);
    }

    function price() public view returns (uint256) {
        (uint256 r0, uint256 r1, ) = IPancakePair(pair).getReserves();
        if (r0 > 0 && r1 > 0) {
            return (r0 * 1e18) / r1;
        }
        return 0;
    }

    function treasuryClaim() external {
        require(
            msg.sender == comTreasury || msg.sender == techTreasury,
            "not allowed call"
        );
        uint256 k = (price() * 10) / initPrice;
        require(k >= 15, "nothing claim");
        uint256 percent = ((k - 10) / 5) * 2;
        if (percent > 100) {
            percent = 100;
        }
        uint256 amount = IMOBLock(lockAddress).releaseTreasury(
            msg.sender,
            percent
        );
        _balances[lockAddress] -= amount;
        _balances[msg.sender] += amount;
        emit Transfer(lockAddress, msg.sender, amount);
    }

    function airdropNFT(address[] calldata adr, uint256[] calldata amount)
        external
        onlyOwner
    {
        require(adr.length == amount.length, "length error");
        require(adr.length <= 1100, "length max 1100");
        IMOBLock lock = IMOBLock(lockAddress);
        for (uint256 i = 0; i < adr.length; ++i) {
            uint256 init = amount[i] / 2;
            uint256 rest = amount[i] - init;
            _mint(adr[i], init);
            _mint(lockAddress, rest);
            lock.lockNFT(adr[i], init, rest);
            addBlist(adr[i]);
        }
    }

    function nftClaim() external {
        uint256 begin = startTradeTime + 30 days * 3;
        require(block.timestamp > begin, "nothing claim");
        uint256 percent = ((block.timestamp - begin) / 30 days) * 3;
        if (percent > 100) {
            percent = 100;
        }
        (uint256 released, uint256 blackhole) = IMOBLock(lockAddress)
            .releaseNFT(msg.sender, percent);
        _balances[lockAddress] -= (released + blackhole);
        _balances[msg.sender] += released;
        emit Transfer(lockAddress, msg.sender, released);
        if (blackhole > 0) {
            _burn(lockAddress, blackhole);
        }
    }

    function availableClaim()
        public
        view
        returns (uint256 avl, uint256 claimed)
    {
        return availableClaim(msg.sender);
    }

    function availableClaim(address adr)
        public
        view
        returns (uint256 avl, uint256 claimed)
    {
        uint256 mp = price() * 100;
        for (uint256 i = 0; i < buyOrderPerAccount[adr].length; ++i) {
            BuyOrder memory bo = buyOrderPerAccount[adr][i];
            claimed += bo.claimed;
            uint256 k = mp / bo.price;
            if (k < 115) {
                continue;
            }
            uint256 percent = ((k - 100) / 15) * 2;
            if (percent > 100) {
                percent = 100;
            }
            uint256 release = (percent * bo.amount) / 100;
            if (release <= bo.claimed) {
                continue;
            }
            avl += (release - bo.claimed);
        }
    }

    function treasuryAvailableClaim()
        public
        view
        returns (uint256 avl, uint256 claimed)
    {
        return treasuryAvailableClaim(msg.sender);
    }

    function treasuryAvailableClaim(address adr)
        public
        view
        returns (uint256 avl, uint256 claimed)
    {
        require(adr == comTreasury || adr == techTreasury, "not allowed call");
        uint256 k = (price() * 10) / initPrice;
        if (k >= 15) {
            uint256 percent = ((k - 10) / 5) * 2;
            if (percent > 100) {
                percent = 100;
            }
            (avl, claimed) = IMOBLock(lockAddress).treasuryAvailableClaim(
                msg.sender,
                percent
            );
        } else {
            (avl, claimed) = IMOBLock(lockAddress).treasuryAvailableClaim(
                msg.sender,
                0
            );
        }
    }

    function nftAvailableClaim()
        public
        view
        returns (uint256 avl, uint256 claimed)
    {
        return nftAvailableClaim(msg.sender);
    }

    function nftAvailableClaim(address adr)
        public
        view
        returns (uint256 avl, uint256 claimed)
    {
        uint256 begin = startTradeTime + 30 days * 3;
        if (block.timestamp > begin) {
            uint256 percent = ((block.timestamp - begin) / 30 days) * 3;
            if (percent > 100) {
                percent = 100;
            }
            (avl, claimed) = IMOBLock(lockAddress).nftAvailableClaim(
                adr,
                percent
            );
        }
    }

    function buyOrderLength(address adr) public view returns (uint256) {
        return buyOrderPerAccount[adr].length;
    }

    function buyOrderList(
        address adr,
        uint256 pageIndex,
        uint256 pageSize
    ) public view returns (BuyOrder[] memory) {
        uint256 mp = price() * 100;
        uint256 len = buyOrderPerAccount[adr].length;
        if (len == 0) {
            return new BuyOrder[](0);
        }
        BuyOrder[] memory list = new BuyOrder[](
            pageIndex * pageSize <= len
                ? pageSize
                : len - (pageIndex - 1) * pageSize
        );
        uint256 start = len - 1 - (pageIndex - 1) * pageSize;
        uint256 end = start > list.length ? start - list.length + 1 : 0;
        for (uint256 i = start; i >= end; ) {
            BuyOrder memory bo = buyOrderPerAccount[adr][i];
            uint256 k = mp / bo.price;
            if (k < 115) {
                list[start - i] = BuyOrder(
                    bo.timestamp,
                    bo.price,
                    bo.amount,
                    bo.claimed
                );
            } else {
                uint256 percent = ((k - 100) / 15) * 2;
                if (percent > 100) {
                    percent = 100;
                }
                uint256 release = (percent * bo.amount) / 100;
                list[start - i] = BuyOrder(
                    bo.timestamp,
                    bo.price,
                    bo.amount,
                    release
                );
            }
            if (i > 0) {
                --i;
            } else {
                break;
            }
        }
        return list;
    }

    function claim() external {
        uint256 amount;
        uint256 mp = price() * 100;
        for (uint256 i = 0; i < buyOrderPerAccount[msg.sender].length; ++i) {
            BuyOrder memory bo = buyOrderPerAccount[msg.sender][i];
            uint256 k = mp / bo.price;
            if (k < 115) {
                continue;
            }
            uint256 percent = ((k - 100) / 15) * 2;
            if (percent > 100) {
                percent = 100;
            }
            uint256 release = (percent * bo.amount) / 100;
            if (release <= bo.claimed) {
                continue;
            }
            amount += (release - bo.claimed);
            buyOrderPerAccount[msg.sender][i].claimed = release;
        }
        if (amount > 0) {
            _balances[lockAddress] -= amount;
            _balances[msg.sender] += amount;
            emit Transfer(lockAddress, msg.sender, amount);
        }
    }

    function addFeeWhitelist(address adr) public onlyOwner {
        feeWhitelist.set(uint256(uint160(adr)));
        emit addFeeWl(adr);
    }

    function removeFeeWhitelist(address adr) public onlyOwner {
        feeWhitelist.unset(uint256(uint160(adr)));
        emit removeFeeWl(adr);
    }

    function getFeeWhitelist(address adr) public view returns (bool) {
        return feeWhitelist.get(uint256(uint160(adr)));
    }

    function addBotWhitelist(address adr) public onlyOwner {
        botWhitelist.set(uint256(uint160(adr)));
        emit addBotWl(adr);
    }

    function removeBotWhitelist(address adr) public onlyOwner {
        botWhitelist.unset(uint256(uint160(adr)));
        emit removeBotWl(adr);
    }

    function getBotWhitelist(address adr) public view returns (bool) {
        return botWhitelist.get(uint256(uint160(adr)));
    }

    function addBlist(address adr) public onlyOwner {
        bList.set(uint256(uint160(adr)));
        emit addBL(adr);
    }

    function removeBlist(address adr) public {
        require(
            msg.sender == owner() || msg.sender == lockAddress,
            "not allowed call"
        );
        bList.unset(uint256(uint160(adr)));
        emit removeBL(adr);
    }

    function getBlist(address adr) public view returns (bool) {
        return bList.get(uint256(uint160(adr)));
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (to.isContract() && to != pair && to != lockAddress) {
            revert("can't transfer to contract");
        }

        uint256 tranType = 0;
        uint112 r0;
        uint112 r1;
        uint256 balanceA;
        uint256 curPrice;
        if (to == pair) {
            (r0, r1, ) = IPancakePair(pair).getReserves();
            uint256 amountA;
            if (r0 > 0 && r1 > 0) {
                amountA = IPancakeRouter01(ROUTER_ADDRESS).quote(
                    amount,
                    r1,
                    r0
                );
            }
            balanceA = IERC20(USDT_ADDRESS).balanceOf(pair);
            if (balanceA < r0 + amountA) {
                tranType = 1;
            } else {
                tranType = 2;
            }
        }
        if (from == pair) {
            (r0, r1, ) = IPancakePair(pair).getReserves();
            uint256 amountA;
            if (r0 > 0 && r1 > 0) {
                amountA = IPancakeRouter01(ROUTER_ADDRESS).getAmountIn(
                    amount,
                    r0,
                    r1
                );
            }
            balanceA = IERC20(USDT_ADDRESS).balanceOf(pair);
            if (balanceA >= r0 + amountA) {
                require(to == lockAddress, "to must be lockAddress");
                tranType = 3;
                curPrice = ((balanceA - r0) * 1e18) / amount;
            } else {
                tranType = 4;
            }
        }

        if (block.timestamp >= startTradeTime) {
            if (bList.get(uint256(uint160(tx.origin)))) {
                revert("not allowed transfer");
            }
            if (tranType <= 2 && bList.get(uint256(uint160(from)))) {
                revert("not allowed transfer");
            }
            if (tranType == 3 && bList.get(uint256(uint160(tx.origin)))) {
                revert("not allowed transfer");
            }
            if (tranType == 4 && bList.get(uint256(uint160(to)))) {
                revert("not allowed transfer");
            }
        } else if (tranType != 2) {
            revert("not allowed now");
        }

        uint256 oldBalance = balanceOf(from);
        require(oldBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = oldBalance - amount;
        }

        uint256 subAmount;
        if (tranType == 1) {
            if (!feeWhitelist.get(uint256(uint160(from)))) {
                uint256 marketAmount = (amount * 20) / 1000;
                marketSellReward(from, amount, marketAmount);
                subAmount += marketAmount;
                subAmount += shareFee(
                    from,
                    address(this),
                    (amount * 20) / 1000,
                    1
                );
                subAmount += shareFee(
                    from,
                    address(this),
                    (amount * 15) / 1000,
                    2
                );
                subAmount += _burn(from, (amount * 10) / 1000);
                subAmount += shareFee(
                    from,
                    communityAddress,
                    (amount * 7) / 1000,
                    0
                );
                subAmount += shareFee(
                    from,
                    techAddress,
                    (amount * 8) / 1000,
                    0
                );
            }
            sellPerAccount[from] += amount;
        } else if (tranType == 2) {
            if (block.timestamp < startTradeTime) {
                (uint256 addedLp, ) = calLiquidity(balanceA, amount, r0, r1);
                _burn(from, _balances[from]);
                _balances[from] = 0;
                IMOBLock(lockAddress).addLiq(from, amount, addedLp);
            }
        } else if (tranType == 3) {
            if (!feeWhitelist.get(uint256(uint160(tx.origin)))) {
                uint256 marketAmount = (amount * 20) / 1000;
                marketBuyReward(tx.origin, amount, marketAmount);
                subAmount += marketAmount;
                subAmount += shareFee(
                    tx.origin,
                    address(this),
                    (amount * 20) / 1000,
                    1
                );
                subAmount += shareFee(
                    tx.origin,
                    address(this),
                    (amount * 15) / 1000,
                    2
                );
                subAmount += _burn(tx.origin, (amount * 10) / 1000);
                subAmount += shareFee(
                    tx.origin,
                    communityAddress,
                    (amount * 7) / 1000,
                    0
                );
                subAmount += shareFee(
                    tx.origin,
                    techAddress,
                    (amount * 8) / 1000,
                    0
                );
            }
            BuyOrder memory bo = BuyOrder(
                block.timestamp,
                curPrice,
                amount - subAmount,
                0
            );
            buyOrderPerAccount[tx.origin].push(bo);
            buyPerAccount[tx.origin] += (amount - subAmount);
        }

        uint256 toAmount = amount - subAmount;
        _balances[to] += toAmount;
        emit Transfer(from, to, toAmount);
    }

    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint112 r0,
        uint112 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = IPancakePair(pair).totalSupply();
        address feeTo = IPancakeFactory(
            IPancakeRouter01(ROUTER_ADDRESS).factory()
        ).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = IPancakePair(pair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(r0).mul(r1));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply
                        .mul(rootK.sub(rootKLast))
                        .mul(8);
                    uint256 denominator = rootK.mul(17).add(rootKLast.mul(8));
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function shareFee(
        address from,
        address to,
        uint256 amount,
        uint256 t
    ) private returns (uint256) {
        _balances[to] += amount;
        feePerAccount[to] += amount;
        emit Transfer(from, to, amount);
        if (t == 1) {
            lpFee += amount;
            uint256 r = lpFee / LP_DIS_AMOUNT;
            if (r > 0) {
                lpFee = lpFee % LP_DIS_AMOUNT;
                lpFeeDisAmount += LP_DIS_AMOUNT * r;
                emit distributeLpFee(LP_DIS_AMOUNT * r);
            }
        } else if (t == 2) {
            nftFee += amount;
            uint256 r = nftFee / NFT_DIS_AMOUNT;
            if (r > 0) {
                nftFee = nftFee % NFT_DIS_AMOUNT;
                nftFeeDisAmount += NFT_DIS_AMOUNT * r;
                emit distributeNftFee(NFT_DIS_AMOUNT * r);
            }
        }
        return amount;
    }

    function marketBuyReward(
        address to,
        uint256 amount,
        uint256 restAmount
    ) private {
        Rel rel = Rel(relAddress);
        address p = rel.parents(to);
        for (uint256 i = 1; i <= 5 && p != address(0) && p != address(1); ++i) {
            uint256 pAmount;
            if (i == 1) {
                pAmount = (amount * 6) / 1000;
            } else if (i == 2) {
                pAmount = (amount * 5) / 1000;
            } else if (i == 3) {
                pAmount = (amount * 4) / 1000;
            } else if (i == 4) {
                pAmount = (amount * 3) / 1000;
            } else {
                pAmount = restAmount;
            }
            _balances[p] += pAmount;
            feePerAccount[p] += pAmount;
            emit Transfer(to, p, pAmount);
            restAmount -= pAmount;
            p = rel.parents(p);
        }
        if (restAmount > 0) {
            _balances[netAddress] += restAmount;
            feePerAccount[netAddress] += restAmount;
            emit Transfer(to, netAddress, restAmount);
        }
    }

    function marketSellReward(
        address to,
        uint256 amount,
        uint256 restAmount
    ) private {
        Rel rel = Rel(relAddress);
        address p = rel.parents(to);
        for (uint256 i = 1; i <= 3 && p != address(0) && p != address(1); ++i) {
            uint256 pAmount;
            if (i == 1) {
                pAmount = (amount * 8) / 1000;
            } else if (i == 2) {
                pAmount = (amount * 6) / 1000;
            } else {
                pAmount = restAmount;
            }
            _balances[p] += pAmount;
            feePerAccount[p] += pAmount;
            emit Transfer(to, p, pAmount);
            restAmount -= pAmount;
            p = rel.parents(p);
        }
        if (restAmount > 0) {
            _balances[netAddress] += restAmount;
            feePerAccount[netAddress] += restAmount;
            emit Transfer(to, netAddress, restAmount);
        }
    }

    function disLpFee(address[] calldata addr, uint256[] calldata amount)
        external
    {
        require(
            botWhitelist.get(uint256(uint160(msg.sender))),
            "not allowed call"
        );
        require(addr.length == amount.length, "addrLen!=amountLen");
        require(addr.length <= 500, "addrLen max 500");
        uint256 total;
        for (uint256 i = 0; i < addr.length; ++i) {
            address adr = addr[i];
            uint256 a = amount[i];
            _transfer(address(this), adr, a);
            total += a;
        }
        lpFeeDisAmount -= total;
    }

    function disNftFee(address[] calldata addr, uint256[] calldata amount)
        external
    {
        require(
            botWhitelist.get(uint256(uint160(msg.sender))),
            "not allowed call"
        );
        require(addr.length == amount.length, "addrLen!=amountLen");
        require(addr.length <= 500, "addrLen max 500");
        uint256 total;
        for (uint256 i = 0; i < addr.length; ++i) {
            address adr = addr[i];
            uint256 a = amount[i];
            _transfer(address(this), adr, a);
            total += a;
        }
        nftFeeDisAmount -= total;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        require(_totalSupply <= 25000000 * 10**decimals(), "max mint");
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private returns (uint256) {
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        return amount;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function getInfo(address[] calldata addr)
        external
        view
        returns (uint256[4][] memory r)
    {
        uint256 lp = IPancakePair(pair).totalSupply();
        uint256 tokenAmount = balanceOf(pair);
        r = new uint256[4][](addr.length);
        for (uint256 i = 0; i < addr.length; ++i) {
            uint256 lpBalance = IPancakePair(pair).balanceOf(addr[i]);
            r[i] = [
                lp > 0 ? (lpBalance * tokenAmount) / lp : 0,
                feePerAccount[addr[i]],
                buyPerAccount[addr[i]],
                sellPerAccount[addr[i]]
            ];
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rel is Ownable {
    event Bind(address indexed user, address indexed parent);

    mapping(address => address) public parents;

    mapping(bytes32 => address[]) public children;

    constructor(address receiver, address genesis) {
        parents[genesis] = address(1);
        emit Bind(genesis, address(1));
        parents[receiver] = genesis;
        addChild(receiver, genesis);
        emit Bind(receiver, genesis);
    }

    function bind(address parent) external {
        require(parents[msg.sender] == address(0), "already bind");
        require(parents[parent] != address(0), "parent invalid");
        parents[msg.sender] = parent;
        addChild(msg.sender, parent);
        emit Bind(msg.sender, parent);
    }

    function addChild(address user, address p) private {
        for (uint256 i = 1; i <= 5 && p != address(0) && p != address(1); ++i) {
            children[keccak256(abi.encode(p, i))].push(user);
            p = parents[p];
        }
    }

    function getChildren(address user, uint256 level)
        external
        view
        returns (address[] memory)
    {
        return children[keccak256(abi.encode(user, level))];
    }

    function getChildrenLength(address user, uint256 level)
        external
        view
        returns (uint256)
    {
        return children[keccak256(abi.encode(user, level))].length;
    }

    function getChildrenLength(address user) external view returns (uint256) {
        uint256 len;
        for (uint256 i = 1; i <= 5; ++i) {
            len += children[keccak256(abi.encode(user, i))].length;
        }
        return len;
    }

    function getChildren(
        address user,
        uint256 level,
        uint256 pageIndex,
        uint256 pageSize
    ) external view returns (address[] memory) {
        bytes32 key = keccak256(abi.encode(user, level));
        uint256 len = children[key].length;
        address[] memory list = new address[](
            pageIndex * pageSize <= len
                ? pageSize
                : len - (pageIndex - 1) * pageSize
        );
        uint256 start = (pageIndex - 1) * pageSize;
        for (uint256 i = start; i < start + list.length; ++i) {
            list[i - start] = children[key][i];
        }
        return list;
    }
}