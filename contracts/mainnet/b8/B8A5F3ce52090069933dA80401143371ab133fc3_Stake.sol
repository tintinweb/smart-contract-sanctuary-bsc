/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// File: lib/IManager.sol


// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.8.6;

interface TokenManager {

    //Get
    function poolBalance()external view returns(uint);
    function unclaimedAmount()external view returns(uint);

    //Write
    function addLpFee(uint amount)external;
    function addNodeFee(uint amount)external;
    function subUnclaimedAmount(uint _amount)external;
    function subPoolBalance(uint _amount)external;
    function removeLpUser(address _userAddr)external;
    function addLpUser(address _userAddr,uint _amount)external;
    
}
// File: lib/TransferHelper.sol



pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}
// File: lib/ReentrancyGuard.sol


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

// File: lib/IFMT.sol


// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.8.6;

interface IFMT {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function unburn() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function fundAddr() external view returns (address);
    function getTokenManager()external view returns(address);
    function getMainPair()external view returns(address);
    function getUserAddress(uint)external view returns(address);
    function getUserId(address)external view returns(uint);
    function getUserTeamTotalAmount(address _user)external view returns(uint,uint[9] memory);
    function getUserTeamr(address _user,uint8 _layer,uint _begin,uint _end)external view returns(address[] memory _teamr);
    function getInviter(address _userAddr)external view returns(address[9] memory);
    function getUserData(address _userAddr)external view returns(uint,address,uint,uint,uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function checkReleasedAmount(address _userAddr) external view returns (uint256);
    function safeRegisterUser(address _userAddress,address _inviter) external returns(bool);
    function includedUser(address) external returns (bool);
    function fmtBurn(uint _amount)external;
    function addBuyAmount(address _user,uint _amount)external;
    function initUserBuyAmount(uint _userId,uint _buyAmount)external;
}
// File: lib/IPair.sol


pragma solidity >=0.5.0;

interface IPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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
// File: lib/IRouter.sol


pragma solidity >=0.8.6;

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
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
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

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
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

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
    ) external pure returns (uint256 amountB);

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

// File: lib/IFactory.sol


pragma solidity >=0.8.6;

interface IFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
// File: lib/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: lib/Strings.sol



pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: lib/Context.sol



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

// File: lib/Ownable.sol



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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: lib/IERC20.sol


// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// File: contract/FMT-Stake.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.6;














contract Stake is Context, Ownable,ReentrancyGuard {
    using Strings for uint256;
    using Address for address;

    uint256 private constant MAX = type(uint256).max;
    address[] public path_FMTtoUSDT;

    enum SupLevel{normal,primary,intermediate,senior}

    
    TokenManager private _tokenManager;


    IFMT FMT;
    IRouter swapRouter;
    IFactory swapFactory;
    IPair mainPairC;
    IERC20 public USDT;
    uint decimalsU;
    uint256 public poolBalance;
    uint public unclaimedAmount;
    uint public lpFmtRequire;
    uint public lpRequire;
    uint public lpStakerAmount;
    uint public stakerAmount;

    mapping(address=>bool) isLpStaker;
    mapping(address=>uint) lpStakeAmount;
    mapping(address=>uint) lpStakeTime;
    uint public allStakedAmountLP;
    uint public fmtRequire;
    uint public allStakedAmountFMT;
    enum StakeOptions{day30,day90,day180}
    uint16[3] stakeRate;
    uint16[3] cycle;
    struct StakeData{
        uint stakeAmount;
        uint stakeTime;
        StakeOptions stakeOptions;
    }
    mapping(address=>StakeData[10]) getStakeData;
    mapping(address=>uint8) getStakeNum;
    uint computeCycle;
    uint lpCycle;


    constructor(
        address _fmtAddress
    ) 
    {

        FMT = IFMT(_fmtAddress);
        swapRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapFactory = IFactory(swapRouter.factory());
        mainPairC = IPair(FMT.getMainPair());
        _tokenManager = TokenManager(FMT.getTokenManager());
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        decimalsU = USDT.decimals();
                     
        fmtRequire = 40000*(10**FMT.decimals());
        lpRequire = 1000*(10**FMT.decimals());
        lpFmtRequire = 10000*(10**FMT.decimals());
        stakeRate=[110,150,250];
        cycle = [30,90,180];
        poolBalance = 80000000000000000000000000;

        computeCycle = 60*60*24;
        lpCycle = 31536000;

        FMT.approve(address(swapRouter), MAX);
        USDT.approve(address(swapRouter), MAX);
    }

    
    function getStakeDataLP(address _user)public view returns(uint,uint,uint,bool,uint,uint) {
        return (lpFmtRequire,allStakedAmountLP,mainPairC.balanceOf(_user),isLpStaker[_user],lpStakeAmount[_user],lpStakeTime[_user]);
    }
    function getStakeDataFMT(address _user)public view returns(uint,uint,uint,uint8,StakeData[10] memory) {
        return (_tokenManager.poolBalance(),allStakedAmountFMT,FMT.balanceOf(_user),getStakeNum[_user],getStakeData[_user]);
    }





    function setData(address _fmtAddress,address _mainPair,address _managerAddr,uint _computeCycle,uint _lpCycle)public onlyOwner{
        

        FMT = IFMT(_fmtAddress);
        mainPairC = IPair(_mainPair);
        _tokenManager=TokenManager(_managerAddr);

        computeCycle = _computeCycle;
        lpCycle = _lpCycle;
        
        FMT.approve(address(swapRouter), MAX);
        USDT.approve(address(swapRouter), MAX);
    }
    function setRequire(uint _lpAmount,uint _lpFmtAmount,uint _fmtAmount)public onlyOwner{
        lpRequire = _lpAmount;
        lpFmtRequire = _lpFmtAmount;
        fmtRequire = _fmtAmount;
    }
    function setFmtRate(uint16[3] calldata _stakeRate,uint16[3] calldata _cycle)public onlyOwner{
        stakeRate=_stakeRate;
        cycle = _cycle;
    }
    function setComputeCycle(uint _cycle)public onlyOwner{
        computeCycle=_cycle;
    }



    
    function managerLpStake(uint _stakeAmount)public {
        address _sender = msg.sender;
        require(_sender==address(_tokenManager));

        if(isLpStaker[_sender]){
            lpStakeAmount[_sender]+=_stakeAmount;
        }else{
            lpStakerAmount+=1;
            isLpStaker[_sender]=true;
            lpStakeAmount[_sender]=_stakeAmount;
            lpStakeTime[_sender]=block.timestamp;
        }
        allStakedAmountLP+=_stakeAmount;
    }
    function LpStake(uint _stakeAmount,address _inviter)public {
        address _sender = msg.sender;
        require(_stakeAmount>=lpRequire,"stake amount less than stakeRequire.");
        require(mainPairC.balanceOf(_sender)>=_stakeAmount,"Insufficient balance!");
        require(mainPairC.allowance(_sender,address(this)) >= _stakeAmount,"Insufficient allowance!");
        mainPairC.transferFrom(_sender, address(this), _stakeAmount);

        FMT.safeRegisterUser(_sender, _inviter);

        if(isLpStaker[_sender]){
            lpStakeAmount[_sender]+=_stakeAmount;
        }else{
            lpStakerAmount+=1;
            isLpStaker[_sender]=true;
            lpStakeAmount[_sender]=_stakeAmount;
            lpStakeTime[_sender]=block.timestamp;
        }
        allStakedAmountLP+=_stakeAmount;
        _tokenManager.addLpUser(_sender, _stakeAmount);
    }
    function addLpAndStake(uint _amountFMT,address _inviter)public returns(uint,uint,uint){
        address _sender=msg.sender;
        uint amountFMT=_amountFMT;
        uint amountUSDT=_amountFMT*USDT.balanceOf(address(mainPairC))/FMT.balanceOf(address(mainPairC));

        uint256 unfreezeBalance;
        unfreezeBalance = FMT.checkReleasedAmount(_sender);
        require(unfreezeBalance >= _amountFMT);
        require(_amountFMT>=lpFmtRequire,"stake amount less than stakeRequire.");
        require(USDT.balanceOf(_sender) >= amountUSDT,"Insufficient USDT balance!");
        require(USDT.allowance(_sender,address(this)) >= amountUSDT,"Insufficient USDT allowance!");
        require(FMT.allowance(_sender,address(this)) >= amountFMT,"Insufficient FMT allowance!");
        TransferHelper.safeTransferFrom(address(FMT),_sender,address(this),amountFMT);
        USDT.transferFrom(_sender, address(this), amountUSDT);
        (uint amountA,uint amountB,uint amountLP) = swapRouter.addLiquidity(address(FMT), address(USDT), amountFMT, amountUSDT, 0, 0, address(this), block.timestamp+180);
        
        FMT.safeRegisterUser(_sender, _inviter);

        if(isLpStaker[_sender]){
            lpStakeAmount[_sender]+=amountLP;
        }else{
            lpStakerAmount+=1;
            isLpStaker[_sender]=true;
            lpStakeAmount[_sender]=amountLP;
            lpStakeTime[_sender]=block.timestamp;
        }
        allStakedAmountLP+=amountLP;
        _tokenManager.addLpUser(_sender, amountLP);

        return (amountA,amountB,amountLP);

    }
    
    function withdrawLpStaked()public nonReentrant returns(uint,uint){
        address _sender = msg.sender;
        require(isLpStaker[_sender],"user not pledged.");
        require(block.timestamp-lpStakeTime[_sender]>=lpCycle,"The extractable time is not reached");
        _tokenManager.removeLpUser(_sender);
        if(lpStakerAmount>0) lpStakerAmount-=1;
        isLpStaker[_sender] = false;
        uint _stakeAmount = lpStakeAmount[_sender];
        delete lpStakeAmount[_sender];
        delete lpStakeTime[_sender];
        allStakedAmountLP-=_stakeAmount;
        mainPairC.approve(address(swapRouter), _stakeAmount);
        uint oldBalanceF=FMT.balanceOf(address(this));
        uint oldBalanceU=USDT.balanceOf(address(this));
        (uint amountFMT,uint amountUSDT) = swapRouter.removeLiquidity(address(FMT), address(USDT), _stakeAmount, 0, 0, address(this), block.timestamp+60);
        TransferHelper.safeTransfer(address(FMT),_sender,amountFMT);
        USDT.transfer(_sender, amountUSDT);
        require(oldBalanceF==FMT.balanceOf(address(this)),"FMT Balance verification failed!"); 
        require(oldBalanceU==USDT.balanceOf(address(this)),"USDT Balance verification failed!"); 
        return (amountFMT,amountUSDT);
    }
    
    function stake(uint _stakeAmount,StakeOptions _options,address _inviter) public {
        address _sender = msg.sender;
        require(_stakeAmount>=fmtRequire,"Less than the minimum pledge quantity!");
        uint8 _lastStakeNum = getStakeNum[_sender];
        require(_lastStakeNum<10,"The upper limit is 5.");
        uint expectedProfit = _stakeAmount/100*(stakeRate[uint8(_options)]-100);
        uint _unclaimedAmount=_tokenManager.unclaimedAmount();
        require(_unclaimedAmount>0&&expectedProfit<=_unclaimedAmount,"Insufficient remaining mineable resources!");
        FMT.safeRegisterUser(_sender, _inviter);

        uint256 unfreezeBalance;
        unfreezeBalance = FMT.checkReleasedAmount(_sender);
        require(unfreezeBalance >= _stakeAmount);
        require(FMT.allowance(_sender,address(this)) >= _stakeAmount,"Insufficient FMT allowance!");
        TransferHelper.safeTransferFrom(address(FMT),_sender,address(this),_stakeAmount);

        
        uint8 vacancy;
        for(uint8 i=0;i<10;i++){
            if(getStakeData[_sender][i].stakeAmount==0){
                vacancy = i;
                break;
            }
        }
        getStakeNum[_sender]=_lastStakeNum+1;
        StakeData storage _newStakeData = getStakeData[_sender][vacancy];
        _newStakeData.stakeAmount=_stakeAmount;
        _newStakeData.stakeOptions=_options;
        _newStakeData.stakeTime=block.timestamp;
        if(_lastStakeNum==0){
            stakerAmount+=1;
        }

        allStakedAmountFMT+=_stakeAmount;
        _tokenManager.subUnclaimedAmount(_stakeAmount);
    }

    
    function withdrawStaked(uint8 _num) public nonReentrant {
        address _sender = msg.sender;
        uint8 _lastStakeNum = getStakeNum[_sender];
        require((getStakeData[_sender][_num].stakeAmount>0)&&(_lastStakeNum>0),"UnStaked");
        StakeData memory _data = getStakeData[_sender][_num];
        uint16 selectedCycle=cycle[uint8(_data.stakeOptions)];
        uint _days = (block.timestamp-_data.stakeTime)/computeCycle;
        require(_days>=selectedCycle,"Stake not finished");
        if(_lastStakeNum==1){
            stakerAmount-=1;
        }
        uint _profit=_data.stakeAmount/100*(stakeRate[uint8(_data.stakeOptions)]-100);
        uint _principal = _data.stakeAmount;
        delete getStakeData[_sender][_num];

        getStakeNum[_sender]=_lastStakeNum-1;
        allStakedAmountFMT-=_data.stakeAmount;
        _tokenManager.subPoolBalance(_profit+_principal);
        TransferHelper.safeTransferFrom(address(FMT),address(_tokenManager),_sender,_profit);
        TransferHelper.safeTransfer(address(FMT),_sender,_principal);
        
    }




}