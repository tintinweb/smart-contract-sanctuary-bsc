/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// File: contracts/libs/SwapSettingsLib.sol


pragma solidity 0.8.11;

library SwapSettingsLib {
    function netWorkSettings(
    )
        internal
        view
        returns(address,address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        if ((chainId == 0x1) || (chainId == 0x3) || (chainId == 0x4) || (chainId == 0x539) || (chainId == 0x7a69)) {  //+ localganache chainId, used for fork 
            // Ethereum-Uniswap
            return( 
                0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, //uniswapRouter
                0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f  //uniswapRouterFactory
            );
        } else if(chainId == 0x89) {
            // Matic-QuickSwap
            return( 
                0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff, //uniswapRouter
                0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32  //uniswapRouterFactory
            );
        } else if(chainId == 0x38) {
            // Binance-PancakeSwap
            return( 
                0x10ED43C718714eb63d5aA57B78B54704E256024E, //uniswapRouter
                0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73  //uniswapRouterFactory
            );
        } else {
            revert("unsupported chain");
        }
    }

}
// File: contracts/interfaces/ITrustedForwarder.sol


pragma solidity 0.8.11;

interface ITrustedForwarder {

    function isTrustedForwarder(address forwarder) external view returns(bool);
        

  

}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol


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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC777/IERC777RecipientUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Recipient.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777RecipientUpgradeable {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// File: @openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// File: contracts/interfaces/ICommunityCoin.sol


pragma solidity ^0.8.0;

interface ICommunityCoin {
    
    function initialize(
        address poolImpl,
        address poolErc20Impl,
        address hook,
        address instancesImpl,
        uint256 discountSensitivity,
        address rolesManagementClone,
        address reserveToken,
        address tradedToken
    ) external;

    event InstanceCreated(address indexed tokenA, address indexed tokenB, address instance);
    event InstanceErc20Created(address indexed erc20token, address instance);

    function issueWalletTokens(address account, uint256 amount, uint256 priceBeforeStake) external;

}

// File: contracts/interfaces/IStructs.sol


pragma solidity ^0.8.11;

interface IStructs {
    struct StructAddrUint256 {
        address account;
        uint256 amount;
    }


}
// File: contracts/interfaces/ICommunityStakingPool.sol


pragma solidity ^0.8.0;


interface ICommunityStakingPool {
    
    function initialize(
        address stakingProducedBy_,
        address reserveToken_,
        address tradedToken_, 
        IStructs.StructAddrUint256[] memory donations_,
        uint64 lpFraction_,
        address lpFractionBeneficiary_
    ) external;
    /*
    function stake(address addr, uint256 amount) external;
    function getMinimum(address addr) external view returns(uint256);
    */
    function redeem(address account, uint256 amount) external;
    function redeemAndRemoveLiquidity(address account, uint256 amount) external;
}

// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC1820RegistryUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC1820Registry.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820RegistryUpgradeable {
    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     * @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     * @param account Address of the contract for which to update the cache.
     * @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not.
     * If the result is not cached a direct lookup on the contract address is performed.
     * If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     * {updateERC165Cache} with the contract address.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: contracts/CommunityStakingPoolBase.sol


pragma solidity 0.8.11;

//import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
//import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
//import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
//import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


//import "@openzeppelin/contracts-upgradeable/token/ERC777/IERC777SenderUpgradeable.sol";












//import "hardhat/console.sol";

abstract contract CommunityStakingPoolBase is Initializable, ContextUpgradeable, IERC777RecipientUpgradeable, ReentrancyGuardUpgradeable/*, IERC777SenderUpgradeable*/ {
 
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint64 public constant FRACTION = 100000;

    //bytes32 private constant TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // CommunityCoin address
    address internal stakingProducedBy;

    // if donations does not empty then after staking any tokens will obtain proportionally by donations.address(end user) in donations.amount(ratio)
    IStructs.StructAddrUint256[] donations;

    /**
    * @custom:shortd beneficiary's address which obtain lpFraction of LP tokens
    * @notice beneficiary's address which obtain lpFraction of LP tokens
    */

    address public lpFractionBeneficiary;
    /**
    * @custom:shortd fraction of LP token multiplied by `FRACTION`
    * @notice fraction of LP token multiplied by `FRACTION`
    */
    uint64 public lpFraction;

    address internal uniswapRouter;
    address internal uniswapRouterFactory;

    IUniswapV2Router02 internal UniswapV2Router02;

    modifier onlyStaking() {
        require(stakingProducedBy == msg.sender);
        _;
    }

    event Redeemed(address indexed account, uint256 amount);
    event Donated(address indexed from, address indexed to, uint256 amount);
    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    // left when will be implemented
    // function tokensToSend(
    //     address operator,
    //     address from,
    //     address to,
    //     uint256 amount,
    //     bytes calldata userData,
    //     bytes calldata operatorData
    // )   override
    //     virtual
    //     external
    // {
    // }

    
    /**
    * @notice used to catch when used try to redeem by sending shares directly to contract
    * see more in {IERC777RecipientUpgradeable::tokensReceived}
    */
    function tokensReceived(
        address /*operator*/,
        address from,
        address to,
        uint256 amount,
        bytes calldata /*userData*/,
        bytes calldata /*operatorData*/
    ) 
        external 
        override
    {
    }
    
    
    /**
    * @notice initialize method. Called once by the factory at time of deployment
    * @param stakingProducedBy_ address of Community Coin token. 
    * @param donations_ array of tuples [[address,uint256],...] account, ratio
    * @param lpFraction_ fraction of LP token multiplied by `FRACTION`. 
    * @param lpFractionBeneficiary_ beneficiary's address which obtain lpFraction of LP tokens. if address(0) then it would be owner()
    * @custom:shortd initialize method. Called once by the factory at time of deployment
    */
    function CommunityStakingPoolBase_init(
        address stakingProducedBy_,
        IStructs.StructAddrUint256[] memory donations_,
        uint64 lpFraction_,
        address lpFractionBeneficiary_
    ) 
        onlyInitializing
        internal
    {
        stakingProducedBy = stakingProducedBy_; //it's should ne community coin token
        lpFraction = lpFraction_;
        lpFractionBeneficiary = lpFractionBeneficiary_;

        //donations = donations_; 
        // UnimplementedFeatureError: Copying of type struct IStructs.StructAddrUint256 memory[] memory to storage not yet supported.
        
        for(uint256 i = 0; i < donations_.length; i++) {
            donations.push(IStructs.StructAddrUint256({account: donations_[i].account, amount: donations_[i].amount}));
        }

        __ReentrancyGuard_init();

        // setup swap addresses
        (uniswapRouter, uniswapRouterFactory) = SwapSettingsLib.netWorkSettings();
        UniswapV2Router02 = IUniswapV2Router02(uniswapRouter);
        
        

    }

    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    function doSwapOnUniswap(
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn
    ) 
        internal 
        returns(uint256 amountOut) 
    {
        if (tokenIn == tokenOut) {
            // situation when WETH is a reserve token
            amountOut = amountIn;
        } else {
            require(IERC20Upgradeable(tokenIn).approve(address(uniswapRouter), amountIn), "APPROVE_FAILED");
            address[] memory path = new address[](2);
            path[0] = address(tokenIn);
            path[1] = address(tokenOut);
            // amountOutMin is set to 0, so only do this with pairs that have deep liquidity
            uint256[] memory outputAmounts = UniswapV2Router02.swapExactTokensForTokens(
                amountIn, 0, path, address(this), block.timestamp
            );
            amountOut = outputAmounts[1];
        }
    }
    
    /**
     * method will send `fraction_` of `amount_` of token `token_` to address `fractionAddr_`.
     * if `fractionSendOnly_` == false , all that remaining will send to address `to`
     */
    function _fractionAmountSend(
        address token_, 
        uint256 amount_, 
        uint256 fraction_, 
        address fractionAddr_, 
        address to_
    ) 
        internal 
        returns(uint256 remainingAfterFractionSend) 
    {
        bool fractionSendOnly_ = (to_ == address(0));
        remainingAfterFractionSend = 0;
        if (fraction_ == FRACTION) {
            IERC20Upgradeable(token_).transfer(fractionAddr_, amount_);
            // if (fractionSendOnly_) {} else {}
        } else if (fraction_ == 0) {
            if (fractionSendOnly_) {
                remainingAfterFractionSend = amount_;
            } else {
                IERC20Upgradeable(token_).transfer(to_, amount_);
            }
        } else {
            uint256 adjusted = amount_ * fraction_ / FRACTION;
            IERC20Upgradeable(token_).transfer(fractionAddr_, adjusted);
            remainingAfterFractionSend = amount_ - adjusted;
            if (!fractionSendOnly_) {
                IERC20Upgradeable(token_).transfer(to_, remainingAfterFractionSend);
                remainingAfterFractionSend = 0;
            }
        }
    }
    
    function _stake(
        address addr, 
        uint256 amount, //lpAmount
        uint256 priceBeforeStake
    ) 
        internal 
        virtual 
    {   
        uint256 left = amount;
        if (donations.length != 0) {
            uint256 tmpAmount;
            for (uint256 i = 0; i < donations.length; i++) {
                tmpAmount = amount * donations[i].amount / FRACTION;
                if (tmpAmount > 0) {
                    ICommunityCoin(stakingProducedBy).issueWalletTokens(donations[i].account, tmpAmount, priceBeforeStake);
                    emit Donated(addr, donations[i].account, tmpAmount);
                    left -= tmpAmount;
                }
            }
            
            
        }
        
        ICommunityCoin(stakingProducedBy).issueWalletTokens(addr, left, priceBeforeStake);
        
    }
    
    ////////////////////////////////////////////////////////////////////////
    // private section /////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * @dev implemented EIP-2771
    */
    function _msgSender(
    ) 
        internal 
        virtual
        override
        view 
        returns (address signer) 
    {
        signer = msg.sender;
        if (msg.data.length>=20 && ITrustedForwarder(stakingProducedBy).isTrustedForwarder(signer)) {
            assembly {
                signer := shr(96,calldataload(sub(calldatasize(),20)))
            }
        }    
    }
   
}

// File: @uniswap/v2-periphery/contracts/interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: contracts/CommunityStakingPool.sol


pragma solidity 0.8.11;







// import "hardhat/console.sol";

contract CommunityStakingPool is CommunityStakingPoolBase, ICommunityStakingPool {
 
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /**
    * @custom:shortd address of traded token. ie investor token - ITR
    * @notice address of traded token. ie investor token - ITR
    */
    address public tradedToken;

    /**
    * @custom:shortd address of reserve token. ie WETH,USDC,USDT,etc
    * @notice address of reserve token. ie WETH,USDC,USDT,etc
    */
    address public reserveToken;

    address private _token0;
    address private _token1;

    //bytes32 private constant TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    //bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    
    address internal WETH;

    /**
    * @custom:shortd uniswap v2 pair
    * @notice uniswap v2 pair
    */
    IUniswapV2Pair public uniswapV2Pair;
    
    IERC1820RegistryUpgradeable internal constant _ERC1820_REGISTRY = IERC1820RegistryUpgradeable(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    
    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * @notice Special function receive ether
    */
    receive() external payable {
    }
 
    /**
    * @notice initialize method. Called once by the factory at time of deployment
    * @param stakingProducedBy_ address of Community Coin token. 
    * @param reserveToken_ address of reserve token. ie WETH,USDC,USDT,etc
    * @param tradedToken_ address of traded token. ie investor token - ITR
    * @param donations_ array of tuples donations. address,uint256. if array empty when coins will obtain sender, overwise donation[i].account  will obtain proportionally by ration donation[i].amount
    * @param lpFraction_ fraction of LP token multiplied by `FRACTION`. 
    * @param lpFractionBeneficiary_ beneficiary's address which obtain lpFraction of LP tokens. if address(0) then it would be owner()
    * @custom:shortd initialize method. Called once by the factory at time of deployment
    */
    function initialize(
        address stakingProducedBy_,
        address reserveToken_,
        address tradedToken_, 
        IStructs.StructAddrUint256[] memory donations_,
        uint64 lpFraction_,
        address lpFractionBeneficiary_
    ) 
        initializer 
        external 
        override 
    {
        

        CommunityStakingPoolBase_init(stakingProducedBy_, donations_, lpFraction_, lpFractionBeneficiary_);

        (tradedToken, reserveToken) = (tradedToken_, reserveToken_);
        
        address pair =  IUniswapV2Factory(uniswapRouterFactory).getPair(tradedToken, reserveToken);
        require(pair != address(0), "NO_UNISWAP_V2_PAIR");
        uniswapV2Pair = IUniswapV2Pair(pair);
        _token0 = uniswapV2Pair.token0();
        _token1 = uniswapV2Pair.token1();

        WETH = UniswapV2Router02.WETH();
    }

    /**
    * @notice way to redeem via approve/transferFrom. Another way is send directly to contract. User will obtain uniswap-LP tokens
    * @param account account address will redeemed from
    * @param amount The number of shares that will be redeemed.
    * @custom:calledby staking contract
    * @custom:shortd redeem lp tokens
    */
    function redeem(
        address account,
        uint256 amount
    ) 
        external
        override 
        onlyStaking
    {
        uint256 amount2Redeem = __redeem(account, amount);
        uniswapV2Pair.transfer(account, amount2Redeem);
    }

    /**
    * @notice way to redeem and remove liquidity via approve/transferFrom shares. User will obtain reserve and traded tokens back
    * @param account account address will redeemed from
    * @param amount The number of shares that will be redeemed.
    * @custom:calledby staking contract
    * @custom:shortd redeem and remove liquidity
    */
    function redeemAndRemoveLiquidity(
        address account,
        uint256 amount
    ) 
        external
        override 
        onlyStaking 
    {
        __redeemAndRemoveLiquidity(account, amount);
    }

    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /** 
    * @notice method will receive Traded token, exchange to reserve token via uniswap. 
    * Finally will add to liquidity pool and stake it.
    * @custom:shortd  the way to sell traded token and stake liquidity.
    */
    function sellAndStakeLiquidity(
        uint256 amountTradedToken
    )
        public 
        nonReentrant
    {
        address account = _msgSender();
        IERC20Upgradeable(tradedToken).transferFrom(account, address(this), amountTradedToken);

        _sellTradedAndStake(account, amountTradedToken);
    }

    /** 
    * @notice method will receive Traded token, exchange to reserve token via uniswap. 
    * Finally will add to liquidity pool and stake it. Beneficiary will obtain shares 
    * @custom:shortd  the way to sell traded token and stake liquidity. Beneficiary will obtain shares 
    */
    function sellAndStakeLiquidity(
        uint256 amountTradedToken,
        address beneficiary
    )
        public 
        nonReentrant
    {
        IERC20Upgradeable(tradedToken).transferFrom(_msgSender(), address(this), amountTradedToken);
        _sellTradedAndStake(beneficiary, amountTradedToken);
    }
    /** 
    * @notice payble method will receive ETH, convert it to WETH, exchange to reserve token via uniswap. 
    * Finally will add to liquidity pool and stake it. Sender will obtain shares 
    * @custom:shortd  the way to buy liquidity and stake via ETH
    */
    function buyAndStakeLiquidity(
    ) 
        public 
        payable 
        nonReentrant
    {
        address account = _msgSender();
        require(msg.value>0, "INSUFFICIENT_BALANCE");
        uint256 amountETH = msg.value;
        IWETH(WETH).deposit{value: amountETH}();
        uint256 amountReserveToken = doSwapOnUniswap(WETH, reserveToken, amountETH);
        _buyAndStakeLiquidity(account, amountReserveToken);
    }
    
    /** 
    * @notice method will receive payingToken token, exchange to reserve token via uniswap. 
    * Finally will add to liquidity pool and stake it. Sender will obtain shares 
    * @custom:shortd  the way to buy liquidity and stake via paying token
    */
    function buyAndStakeLiquidity(
        address payingToken, 
        uint256 amount
    ) 
        public 
        nonReentrant
    {
        address account = _msgSender();
        IERC20Upgradeable(payingToken).transferFrom(account, address(this), amount);
        uint256 amountReserveToken = doSwapOnUniswap(payingToken, reserveToken, amount);
        _buyAndStakeLiquidity(account, amountReserveToken);
    }
    
    /** 
    * @notice method will receive reserveToken token then will add to liquidity pool and stake it. Sender will obtain shares 
    * @custom:shortd  the way to buy liquidity and stake via reserveToken
    */
    function buyAndStakeLiquidity(
        uint256 tokenBAmount
    ) 
        public 
        nonReentrant
    {

        address account = _msgSender();
        IERC20Upgradeable(reserveToken).transferFrom(account, address(this), tokenBAmount);
        _buyAndStakeLiquidity(account, tokenBAmount);
    }

    /** 
    * @notice payble method will receive ETH, convert it to WETH, exchange to reserve token via uniswap. 
    * Finally will add to liquidity pool and stake it. Beneficiary will obtain shares 
    * @custom:shortd  the way to buy liquidity and stake via ETH. Beneficiary will obtain shares 
    */
    function buyAndStakeLiquidity(
        address beneficiary
    ) 
        public 
        payable 
        nonReentrant
    {
        require(msg.value>0, "INSUFFICIENT_BALANCE");
        uint256 amountETH = msg.value;
        IWETH(WETH).deposit{value: amountETH}();
        uint256 amountReserveToken = doSwapOnUniswap(WETH, reserveToken, amountETH);
        _buyAndStakeLiquidity(beneficiary, amountReserveToken);
    }
    
    /** 
    * @notice method will receive payingToken token, exchange to reserve token via uniswap. 
    * Finally will add to liquidity pool and stake it. Beneficiary will obtain shares 
    * @custom:shortd  the way to buy liquidity and stake via paying token. Beneficiary will obtain shares 
    */
    function buyAndStakeLiquidity(
        address payingToken, 
        uint256 amount,
        address beneficiary
    ) 
        public 
        nonReentrant
    {
        // note that here can be magic trick
        // trusted forwarder can be call tx as a Bob that wanted to specify alice as a beneficiary
        address account = _msgSender();
        IERC20Upgradeable(payingToken).transferFrom(account, address(this), amount);
        uint256 amountReserveToken = doSwapOnUniswap(payingToken, reserveToken, amount);
        _buyAndStakeLiquidity(beneficiary, amountReserveToken);
    }
    
    /** 
    * @notice method will receive reserveToken token then will add to liquidity pool and stake it. Beneficiary will obtain shares 
    * @custom:shortd  the way to buy liquidity and stake via reserveToken. Beneficiary will obtain shares 
    */
    function buyAndStakeLiquidity(
        uint256 tokenBAmount,
        address beneficiary
    ) 
        public 
        nonReentrant
    {
        IERC20Upgradeable(reserveToken).transferFrom(_msgSender(), address(this), tokenBAmount);
        _buyAndStakeLiquidity(beneficiary, tokenBAmount);
    }
       
    /**
    * @notice way to stake LP tokens of current pool(traded/reserve tokens)
    * @dev keep in mind that user can redeem lp token from other staking contract with same pool but different duration and use here.
    * @param lpAmount liquidity tokens's amount
    * @custom:shortd way to stake LP tokens
    */
    function stakeLiquidity(
        uint256 lpAmount
    ) 
        public 
        nonReentrant
    {
        require (lpAmount > 0, "AMOUNT_EMPTY" );
        IERC20Upgradeable(address(uniswapV2Pair)).transferFrom(
            _msgSender(), address(this), lpAmount
        );
        (uint256 reserve0, uint256 reserve1,) = uniswapV2Pair.getReserves();
        uint256 priceBeforeStake = (
            _token0 == reserveToken
                ? FRACTION * reserve0 / reserve1
                : FRACTION * reserve1 / reserve0
        );
        _stake(_msgSender(), lpAmount, priceBeforeStake);
    }

    function addAndStakeLiquidity(
        uint256 amountTradedToken,
        uint256 amountReserveToken
    ) 
        public
        nonReentrant
    {
        (/*uint256 rTraded*/, /*uint256 rReserved*/, uint256 priceTraded, /*uint256 priceReserved*/) = uniswapPrices();

        require (amountTradedToken > 0 && amountReserveToken > 0, "AMOUNT_EMPTY" );

        IERC20Upgradeable(tradedToken).transferFrom(_msgSender(), address(this), amountTradedToken);
        IERC20Upgradeable(reserveToken).transferFrom(_msgSender(), address(this), amountReserveToken);

        require(
            IERC20Upgradeable(tradedToken).approve(uniswapRouter, amountTradedToken)
            && IERC20Upgradeable(reserveToken).approve(uniswapRouter, amountReserveToken),
            "APPROVE_FAILED"
        );

        (uint256 A, uint256 B, uint256 lpTokens) = UniswapV2Router02.addLiquidity(
            tradedToken,
            reserveToken,
            amountTradedToken,
            amountReserveToken,
            0, // there may be some slippage
            0, // there may be some slippage
            address(this),
            block.timestamp
        );
        require (lpTokens > 0, "NO_LIQUIDITY");

        _stake(_msgSender(), lpTokens, priceTraded);

    }

    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    function uniswapPrices(
    ) 
        internal 
        view 
        // reserveTraded, reserveReserved, priceTraded, priceReserved
        returns(uint256, uint256, uint256, uint256)
    {
        (uint256 reserve0, uint256 reserve1,) = uniswapV2Pair.getReserves();

        require (reserve0 != 0 && reserve1 != 0, "RESERVES_EMPTY");
        if (_token0 == tradedToken) {
            return(
                reserve0, 
                reserve1, 
                FRACTION * reserve0 / reserve1,
                FRACTION * reserve1 / reserve0
            );
        } else {
            return(
                reserve1, 
                reserve0, 
                FRACTION * reserve1 / reserve0,
                FRACTION * reserve0 / reserve1
            );
        }

    }
    function _sellTradedAndStake(
        address from, 
        uint256 incomingTradedToken
    )
        internal
    {

        (uint256 rTraded, /*uint256 rReserved*/, uint256 priceTraded, /*uint256 priceReserved*/) = uniswapPrices();
        

        uint256 r3 = 
            sqrt(
                (rTraded + incomingTradedToken)*(rTraded)
            ) - rTraded; //    
        require(r3 > 0 && incomingTradedToken > r3, "BAD_AMOUNT");
        // remaining (r2-r3) we will exchange at uniswap to traded token
        uint256 amountReserveToken = doSwapOnUniswap(tradedToken, reserveToken, r3);
        uint256 amountTradedToken = incomingTradedToken - r3;

        require(
            IERC20Upgradeable(tradedToken).approve(uniswapRouter, amountTradedToken)
            && IERC20Upgradeable(reserveToken).approve(uniswapRouter, amountReserveToken),
            "APPROVE_FAILED"
        );

        (uint256 A, uint256 B, uint256 lpTokens) = UniswapV2Router02.addLiquidity(
            tradedToken,
            reserveToken,
            amountTradedToken,
            amountReserveToken,
            0, // there may be some slippage
            0, // there may be some slippage
            address(this),
            block.timestamp
        );
        require (lpTokens > 0, "NO_LIQUIDITY");

        _stake(from, lpTokens, priceTraded);

    }

    function _buyAndStakeLiquidity(
        address from, 
        uint256 incomingReserveToken
    ) 
        internal 
    {
        
        (/*uint256 rTraded*/, uint256 rReserved, /*uint256 priceTraded*/, uint256 priceReserved) = uniswapPrices();

        //Then the amount they would want to swap is
        // r3 = sqrt( (r1 + r2) * r1 ) - r1
        // where 
        //  r1 - reserve at uniswap(reserve1)
        //  r2 - incoming amount of reserve token
        uint256 r3 = 
            sqrt(
                (rReserved + incomingReserveToken)*(rReserved)
            ) - rReserved; //    
        require(r3 > 0 && incomingReserveToken > r3, "BAD_AMOUNT");
        // remaining (r2-r3) we will exchange at uniswap to traded token
        uint256 amountTradedToken = doSwapOnUniswap(reserveToken, tradedToken, r3);
        uint256 amountReserveToken = incomingReserveToken - r3;
        require(
            IERC20Upgradeable(tradedToken).approve(uniswapRouter, amountTradedToken)
            && IERC20Upgradeable(reserveToken).approve(uniswapRouter, amountReserveToken),
            "APPROVE_FAILED"
        );
        (,, uint256 lpTokens) = UniswapV2Router02.addLiquidity(
            tradedToken,
            reserveToken,
            amountTradedToken,
            amountReserveToken,
            0, // there may be some slippage
            0, // there may be some slippage
            address(this),
            block.timestamp
        );
        require (lpTokens > 0, "NO_LIQUIDITY");

        _stake(from, lpTokens, priceReserved);
    }
    
    ////////////////////////////////////////////////////////////////////////
    // private section /////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    function __redeemAndRemoveLiquidity(
        address sender, 
        uint256 amount
    ) 
        private 
    {
        
        uint256 amount2Redeem = __redeem(sender, amount);

        require(uniswapV2Pair.approve(uniswapRouter, amount2Redeem), "APPROVE_FAILED");
        (uint amountA, uint amountB) = UniswapV2Router02.removeLiquidity(
            tradedToken,//address tokenA,
            reserveToken,//address tokenB,
            amount2Redeem,//uint liquidity,
            0,//uint amountAMin,
            0,//uint amountBMin,
            address(this),//address to,
            block.timestamp//uint deadline
        );
        // _fractionAmountSend(tradedToken, amountA, tradedTokenClaimFraction, stakingProducedBy, sender);
        // _fractionAmountSend(reserveToken, amountB, reserveTokenClaimFraction, stakingProducedBy, sender);
        _fractionAmountSend(tradedToken, amountA, 0, stakingProducedBy, sender);
        _fractionAmountSend(reserveToken, amountB, 0, stakingProducedBy, sender);
        
    }
    
    function __redeem(
        address sender, 
        uint256 amount
    ) 
        private 
        returns(uint256 amount2Redeem)
    {
        emit Redeemed(sender, amount);

        // validate free amount to redeem was moved to method _beforeTokenTransfer
        // transfer and burn moved to upper level
        amount2Redeem = _fractionAmountSend(
            address(uniswapV2Pair), 
            amount, 
            lpFraction, 
            lpFractionBeneficiary == address(0) ? stakingProducedBy : lpFractionBeneficiary, 
            address(0)
        );
    }

    /**
    * @dev implemented EIP-2771
    */
    function _msgSender(
    ) 
        internal 
        virtual
        override
        view 
        returns (address signer) 
    {
        signer = msg.sender;
        if (msg.data.length>=20 && ITrustedForwarder(stakingProducedBy).isTrustedForwarder(signer)) {
            assembly {
                signer := shr(96,calldataload(sub(calldatasize(),20)))
            }
        }    
    }
    
    function sqrt(
        uint256 x
    ) 
        internal 
        pure 
        returns(uint256 result) 
    {
        if (x == 0) {
            return 0;
        }
        // Calculate the square root of the perfect square of a
        // power of two that is the closest to x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }
        // The operations can never overflow because the result is
        // max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}