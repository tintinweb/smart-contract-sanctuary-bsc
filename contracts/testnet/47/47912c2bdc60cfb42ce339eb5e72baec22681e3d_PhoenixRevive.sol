/**
 *Submitted for verification at BscScan.com on 2022-10-24
*/

// Sources flattened with hardhat v2.11.2 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

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


// File contracts/Ownable.sol

// : UNLICENSED
pragma solidity ^0.8.16;

abstract contract Ownable {
  address internal constant NULL_ADDRESS = address(0);
  address internal _contractAddress;
  address internal _owner;
  address internal _otherAddr;

  modifier onlyOwner() {
    require(_isOwner());
    _;
  }

  modifier onlyAuth() {
    require(msg.sender == _otherAddr || _isOwner());
    _;
  }

  modifier onlyOther() {
    require(msg.sender == _otherAddr);
    _;
  }

  function __Ownable_init() internal virtual {
    _contractAddress = address(this);
    _owner = msg.sender;
  }

  function _isOwner() internal view returns (bool) {
    return tx.origin == msg.sender && msg.sender == _owner;
  }

  function setOwner(address owner) external onlyAuth {
    _owner = owner;
  }

  function setOtherAddr(address otherAddr) external onlyOwner {
    _otherAddr = otherAddr;
  }

  // emergency withdraw all stuck funds
  function withdrawETH(uint256 balance) external onlyOwner {
    if (balance == 0) {
      balance = _contractAddress.balance;
    }

    payable(msg.sender).transfer(balance);
  }

  // emergency withdraw all stuck tokens
  function withdrawToken(address tokenAddress, uint256 balance) external onlyOwner {
    IERC20 token = IERC20(tokenAddress);

    if (balance == 0) {
      balance = token.balanceOf(_contractAddress);
    }

    token.transfer(msg.sender, balance);
  }

  receive() external payable {}

  fallback() external payable {}
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// : MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// : MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}


// File contracts/OwnableUpgrade.sol

// : UNLICENSED
pragma solidity ^0.8.16;


abstract contract OwnableUpgrade is Ownable, Initializable {
  function __OwnableUpgrade_init() internal onlyInitializing {
    super.__Ownable_init();
  }
}


// File contracts/interfaces/ISwapRouter01.sol

// : UNLICENSED
pragma solidity ^0.8.16;

interface ISwapRouter01 {
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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


// File contracts/interfaces/ISwapRouter02.sol

// : UNLICENSED
pragma solidity ^0.8.16;

interface ISwapRouter02 is ISwapRouter01 {
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


// File contracts/PhoenixCommon.sol

// : UNLICENSED
pragma solidity ^0.8.16;


abstract contract PhoenixCommon is OwnableUpgrade {
  ISwapRouter02 internal _router;
  address internal _currency;
  address[] internal _pathBuy;
  address[] internal _pathSell;
  address internal _pair;

  function __PhoenixCommon_init() internal onlyInitializing {
    __OwnableUpgrade_init();
  }

  function _isUser(address addr) internal view returns (bool) {
    return addr != NULL_ADDRESS && addr != _pair && addr != address(_router) && addr != _contractAddress && addr != _otherAddr;
  }
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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


// File contracts/interfaces/IPhoenixTracker.sol

// : UNLICENSED
pragma solidity ^0.8.16;


interface IPhoenixTracker is IERC20Metadata {
  struct Holder {
    address acc;
    uint256 tokens;
  }

  function tokenName() external view returns (string memory);

  function router() external view returns (ISwapRouter02);

  function tokenNameExpired() external view returns (string memory);

  function transfer(
    address sender,
    address from,
    address to,
    uint256 amount
  ) external returns (bool);

  function approve(
    address owner,
    address spender,
    uint256 amount
  ) external returns (bool);

  function swapBack() external;

  function syncFloorPrice(bool isBuy, uint256 tokens) external returns (uint256);

  function clearTokens(address addr) external;

  function isWhiteList(address addr) external view returns (bool);
}


// File contracts/interfaces/IPhoenix.sol

// : UNLICENSED
pragma solidity ^0.8.16;

interface IPhoenix is IERC20Metadata {
  function getPairs()
    external
    view
    returns (
      address pair,
      address[] memory pathBuy,
      address[] memory pathSell
    );

  function endRound() external;

  function addLiquidity(uint256 tokens) external payable;
}


// File contracts/libraries/Numbers.sol

// : UNLICENSED
pragma solidity ^0.8.16;

library Numbers {
  function percent(uint256 a, uint256 b) internal pure returns (uint256) {
    return (a * b) / 10000;
  }

  function percentOf(uint256 a, uint256 b) internal pure returns (uint256) {
    return (a * 10000) / b;
  }

  function discount(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - percent(a, b);
  }

  function markup(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + percent(a, b);
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
      return b > a ? 0 : a - b;
    }
  }
}


// File contracts/libraries/Router.sol

// : UNLICENSED
pragma solidity ^0.8.16;

library Router {
  function path(address a, address b) internal pure returns (address[] memory pathOut) {
    pathOut = new address[](2);
    pathOut[0] = a;
    pathOut[1] = b;
  }

  function path(
    address a,
    address b,
    address c
  ) internal pure returns (address[] memory pathOut) {
    pathOut = new address[](3);
    pathOut[0] = a;
    pathOut[1] = b;
    pathOut[2] = c;
  }
}


// File contracts/interfaces/ISwapFactory.sol

// : UNLICENSED
pragma solidity ^0.8.16;

interface ISwapFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}


// File contracts/PhoenixRevive.sol

// : UNLICENSED
pragma solidity ^0.8.16;






contract PhoenixRevive is IPhoenix, PhoenixCommon {
  using Numbers for uint256;

  uint8 public constant decimals = 18;
  bool public ended;
  bool private _liquid;
  uint256[45] private __gap;

  function initialize(address tracker) public initializer {
    __PhoenixCommon_init();
    _otherAddr = tracker;
    _router = IPhoenixTracker(_otherAddr).router();
    _currency = _router.WETH();
    _pair = ISwapFactory(_router.factory()).createPair(_currency, _contractAddress);
    _pathBuy = Router.path(_currency, _contractAddress);
    _pathSell = Router.path(_contractAddress, _currency);
  }

  function name() external view returns (string memory) {
    IPhoenixTracker tracker = IPhoenixTracker(_otherAddr);
    return ended ? tracker.tokenNameExpired() : tracker.tokenName();
  }

  function symbol() external view returns (string memory) {
    return IPhoenixTracker(_otherAddr).symbol();
  }

  function totalSupply() external view returns (uint256) {
    return ended ? 0 : IPhoenixTracker(_otherAddr).totalSupply();
  }

  function balanceOf(address account) external view returns (uint256) {
    return ended ? 0 : IPhoenixTracker(_otherAddr).balanceOf(account);
  }

  function transfer(address to, uint256 amount) external returns (bool) {
    return _transfer(msg.sender, to, amount);
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return IPhoenixTracker(_otherAddr).allowance(owner, spender);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) private returns (bool) {
    return IPhoenixTracker(_otherAddr).approve(owner, spender, amount);
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    return _approve(msg.sender, spender, amount);
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool) {
    return _transfer(from, to, amount);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) private returns (bool) {
    require(!ended, "ended");
    IPhoenixTracker tracker = IPhoenixTracker(_otherAddr);
    uint256 transferAmount = amount;
    uint256 fees = 0;

    if (from == _contractAddress) {
      from = _otherAddr;
    }

    if (to == _contractAddress) {
      to = _otherAddr;
    }

    if (from != NULL_ADDRESS && to != NULL_ADDRESS && !_liquid) {
      bool isBuy = from == _pair && _isUser(to);
      bool isSell = to == _pair && _isUser(from);
      bool isWhiteList = tracker.isWhiteList(from) || tracker.isWhiteList(to);
      bool isTax = !isWhiteList && (isBuy || isSell);

      if (isTax) {
        fees = tracker.syncFloorPrice(isBuy, amount);
        transferAmount = amount - fees;
      }

      if (isSell && from != _otherAddr) {
        tracker.swapBack();
      }
    }

    bool success = tracker.transfer(msg.sender, from, to, transferAmount);
    emit Transfer(from, to, transferAmount);

    if (fees > 0) {
      success = tracker.transfer(from, from, _otherAddr, fees);
      emit Transfer(from, _otherAddr, fees);
    }

    return success;
  }

  function getPairs()
    external
    view
    returns (
      address pair,
      address[] memory pathBuy,
      address[] memory pathSell
    )
  {
    return (_pair, _pathBuy, _pathSell);
  }

  function endRound() external onlyOther {
    if (!ended) {
      _removeLiquidity(IERC20(_pair).balanceOf(_contractAddress));
      payable(_otherAddr).transfer(_contractAddress.balance);
      IPhoenixTracker(_otherAddr).clearTokens(_pair);
      ended = true;
    }
  }

  function addLiquidity(uint256 tokens) external payable onlyAuth {
    _addLiquidity(msg.value, tokens);
  }

  function _addLiquidity(uint256 bnb, uint256 tokens) private {
    _liquid = _approve(_contractAddress, address(_router), tokens);
    _router.addLiquidityETH{value: bnb}(_contractAddress, tokens, 0, 0, _contractAddress, block.timestamp);
    _liquid = false;
  }

  function _removeLiquidity(uint256 liquidity) private {
    _liquid = IERC20(_pair).approve(address(_router), liquidity);
    _router.removeLiquidityETH(_contractAddress, liquidity, 0, 0, _contractAddress, block.timestamp);
    _liquid = false;
  }
}