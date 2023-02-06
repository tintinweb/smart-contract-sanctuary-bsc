/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// Sources flattened with hardhat v2.12.4 https://hardhat.org

// File contracts/interfaces/IAveragePriceOracle.sol

// SPDX-License-Identifier: UNLICENSED
 
pragma solidity ^0.8.4;

interface IAveragePriceOracle {
    function getAverageHoneyForOneEth()
        external
        view
        returns (uint256 amountOut);

    function updateHoneyEthPrice() external;
}


// File contracts/interfaces/IReferral.sol

 
pragma solidity ^0.8.4;

interface IReferral {
    function totalReferralDepositForPool(address _poolAddress)
        external
        view
        returns (uint256);

    function referralDeposit(
        uint256 _amount,
        address _referralRecipient,
        address _referralGiver
    ) external;

    function referralWithdraw(uint256 _amount, address _referralRecipient)
        external;

    function getReferralRewards(address _poolAddress, address _referralGiver)
        external
        view
        returns (uint256);

    function withdrawReferralRewards(uint256 _amount, address _poolAddress)
        external;

    function withdrawAllReferralRewards(address[] memory _poolAddress)
        external
        returns (uint256);

    function referralUpdateRewards(uint256 _rewardedAmount) external;

    function getExpericencePoints(address _from)
        external
        view
        returns (uint256 points);

    function getLevel(address _from) external view returns (uint256 level);

    function REWARDER_ROLE() external view returns (bytes32);

    function grantRole(bytes32 _role, address _to) external;
}


// File contracts/interfaces/IHoney.sol

 
pragma solidity ^0.8.4;

interface IHoney {
    function totalClaimed(address claimer) external view returns (uint256);

    function claimTokens(uint256 amount) external;

    function setDevelopmentFounders(address _developmentFounders) external;

    function setAdvisors(address _advisors) external;

    function setMarketingReservesPool(address _marketingReservesPool) external;

    function setDevTeam(address _devTeam) external;

    function claimTokensWithoutAdditionalTokens(uint256 amount) external;

    function MINTER_ROLE() external view returns (bytes32);

    function grantRole(bytes32 _role, address _to) external;
}


// File contracts/interfaces/IUniswapV2Router01.sol

 
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


// File contracts/interfaces/IDEX.sol

 
pragma solidity ^0.8.4;
interface IDEX {
    function SwapRouter() external returns (IUniswapV2Router01);

    function convertEthToPairLP(address lpAddress)
        external
        payable
        returns (
            uint256 lpAmount,
            uint256 unusedTokenA,
            uint256 unusedTokenB
        );

    function convertEthToTokenLP(address token)
        external
        payable
        returns (
            uint256 lpAmount,
            uint256 unusedEth,
            uint256 unusedToken
        );

    function convertPairLpToEth(address lpAddress, uint256 amount)
        external
        returns (uint256 ethAmount);

    function convertTokenLpToEth(address token, uint256 amount)
        external
        returns (uint256 ethAmount);

    function convertEthToToken(address token)
        external
        payable
        returns (uint256 tokenAmount);

    function convertTokenToEth(uint256 amount, address token)
        external
        returns (uint256 ethAmount);

    function getTokenEthPrice(address token) external view returns (uint256);

    function totalPendingReward(uint256 poolID) external view returns (uint256);

    function totalStakedAmount(uint256 poolID) external view returns (uint256);

    function checkSlippage(
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage
    ) external view;

    function recoverFunds() external;
}


// File contracts/interfaces/IAlpacaVault.sol

 
pragma solidity >=0.8.13;
interface IAlpacaVault {
    function token() external view returns (address);

    //! @todo Check if how we can use this for the Front End, else delete
    // function pendingInterest(uint256 value) external view returns (uint);

    //! @todo Check if how we can use this for the Front End, else delete
    // function debtShareToVal(uint256 debtShare) external view returns (uint256 debtValue);

    //! @todo Check if how we can use this for the Front End, else delete [ibPriceToken calc]
    // function totalToken() external view returns (
    //     uint256 balanceInVault
        // uint256 vaultDebVal, // Interest yield back to lender
        // uint256 reserveAmount
    // );

    //! @todo Check if how we can use this for the Front End, else delete [ibPriceToken calc]
    // function totalSupply() external view returns(uint);

    function deposit(uint256 amountToken) external payable;

    function withdraw(uint256 share) external;

    function balanceOf(address from) external returns (uint256);
}


// File contracts/interfaces/IFairlaunch.sol

 
pragma solidity >=0.8.13;

/// @title Alpaca Staking Interface 
interface IFairlaunch {
    function alpaca() external pure returns (address);
    function userInfo(uint256 _pid, address _user) external pure returns(
        uint256 amount,
        uint256 rewardDebt,
        uint256 bonusDebt,
        address fundedBy
    );
/*
    function poolInfo(uint256 _pid) external pure returns(
        address stakeToken, // Address of Staking token contract.
        uint256 allocPoint, // How many allocation points assigned to this pool. ALPACAs to distribute per block.
        uint256 lastRewardBlock, // Last block number that ALPACAs distribution occurs.
        uint256 accAlpacaPerShare, // Accumulated ALPACAs per share, times 1e12. See below.
        uint256 accAlpacaPerShareTilBonusEnd // Accumated ALPACAs per share until Bonus End.
    );
    */
    function deposit(address _for, uint256 _pid, uint256 _amount) external;

    function harvest(uint256 _pid) external;

    function updatePool(uint256 _pid) external;

    function withdraw(address _for, uint256 _pid, uint256 _amount) external;

    function withdrawAll(address _for, uint256 _pid) external;

    function pendingAlpaca(uint256 _pid, address _user) external; 

}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

 
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

 
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


// File @openzeppelin/contracts-upgradeable/utils/math/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // ÔåÆ `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // ÔåÆ `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/security/[email protected]

 
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/utils/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File contracts/Config/BaseConfig.sol

 
pragma solidity ^0.8.4;
/// @title Base config for AlpacaGrizzly contract
/// @notice This contract contains all external addresses and dependencies for the AlpacaGrizzly contract. It also approves dependent contracts to spend tokens on behalf of AlpacaGrizzly.sol
/// @dev The contract AlpacaGrizzly.sol inherits this contract to have all dependencies available. This contract is always inherited and never deployed alone
abstract contract BaseConfig is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant FUNDS_RECOVERY_ROLE =
        keccak256("FUNDS_RECOVERY_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant MAX_PERCENTAGE = 100000;
    uint256 public constant DECIMAL_OFFSET = 10e12;

    IFairlaunch public AlpacaStakingContract;   
    IAlpacaVault public AlpacaVault;
    IHoney public HoneyToken;
    IERC20Upgradeable public depositToken;
    IERC20Upgradeable public AlpacaRewardToken;
    IReferral public Referral;
    IAveragePriceOracle public AveragePriceOracle;
    IDEX public DEX;

    uint256 public AlpacaPoolID;
    address public DevTeam;

    function __BaseConfig_init(
        address _Admin,
        address _AlpacaStakingContractAddress,
        address _AlpacaDepositContractAddress,
        address _HoneyTokenAddress,
        address _DevTeamAddress,
        address _ReferralAddress,
        address _AveragePriceOracleAddress,
        address _DEXAddress,     
        uint256 _AlpacaPoolID
    ) internal {
        _grantRole(DEFAULT_ADMIN_ROLE, _Admin);
        AlpacaStakingContract = IFairlaunch(_AlpacaStakingContractAddress);

        AlpacaVault = IAlpacaVault(_AlpacaDepositContractAddress);

        HoneyToken = IHoney(_HoneyTokenAddress);

        Referral = IReferral(_ReferralAddress);

        AveragePriceOracle = IAveragePriceOracle(_AveragePriceOracleAddress);

        DEX = IDEX(_DEXAddress);

        DevTeam = _DevTeamAddress;

        AlpacaPoolID = _AlpacaPoolID;

        depositToken= IERC20Upgradeable(AlpacaVault.token());

        AlpacaRewardToken = IERC20Upgradeable(AlpacaStakingContract.alpaca());

        IERC20Upgradeable(address(depositToken)).safeApprove(
            address(AlpacaVault),
            type(uint256).max
        );

        IERC20Upgradeable(address(AlpacaVault)).safeApprove(
            address(AlpacaStakingContract),
            type(uint256).max
        );

        IERC20Upgradeable(address(AlpacaRewardToken)).safeApprove( 
            address(DEX),
            type(uint256).max
        );

        IERC20Upgradeable(address(HoneyToken)).safeApprove(
            address(Referral),
            type(uint256).max
        );
    }

    function isNotPaused() internal {
        require(!paused(), "PS");
    }

    function isPaused() internal {
        require(paused(), "NP");
    }
    uint256[50] private __gap;
}


// File contracts/Strategy/AlpacaStrategy.sol

 

pragma solidity ^0.8.13;
abstract contract AlpacaStrategy is Initializable, BaseConfig {
    using SafeERC20Upgradeable for IERC20Upgradeable;

/// @notice This struct is responsible to track user balances for alpaca investments 
    struct AlpacaStrategyParticipant {
        uint256 amount;
        uint256 lpMask;
        uint256 rewardMask;
        uint256 pendingRewards;
        uint256 totalReinvested;
    }

    uint256 public lpRoundMask;
    uint256 public alpacaStrategyDeposits;

    uint256 public totalHoneyRewards;
    uint256 private honeyRoundMask;

    event AlpacaStrategyClaimHoneyEvent(
        address indexed user,
        uint256 honeyAmount
    );
    event AlpacaStrategyDepositConfirmedEvent(
        address indexed user,
        uint256 depositedAmount
    );

    mapping(address => AlpacaStrategyParticipant) private participantDataAlpaca;

    function __AlpacaStrategy_init() internal initializer { //@todo check if somethings missing
        lpRoundMask = 1;
        honeyRoundMask = 1;
    }

    /// @notice Deposits the desired amount for a Alpaca strategy investor
    /// @dev Pending $ALPACA rewards are rewarded and the investors rewardMask is set again to the current roundMask
    /// @param amount The desired deposit amount for an investor
    function alpacaStrategyDeposit(uint256 amount, address _from) internal {
        updateAlpacaRewardMask(_from);
        uint256 currentDeposit = getAlpacaStrategyBalance(_from); 
        uint256 currentAmount = participantDataAlpaca[_from].amount;

        alpacaStrategyDeposits =
            alpacaStrategyDeposits +
            currentDeposit -
            currentAmount +
            amount;

        participantDataAlpaca[_from].amount = currentDeposit + amount;
        participantDataAlpaca[_from].lpMask = lpRoundMask;
        participantDataAlpaca[_from].totalReinvested +=
            currentDeposit -
            currentAmount;
        
        emit AlpacaStrategyDepositConfirmedEvent(_from, amount); 
    }

    /// @notice Withdraws the desired amount for a alpaca strategy investor
    /// @dev Pending lp rewards are rewarded and the investors rewardMask is set again to the current roundMask
    /// @param amount The desired withdraw amount for an investor
    function alpacaStrategyWithdraw(uint256 amount, address _from) internal {
        require(amount > 0, "TZ");

        updateAlpacaRewardMask(_from);
        uint256 currentDeposit = getAlpacaStrategyBalance(_from);
        uint256 currentAmount = participantDataAlpaca[_from].amount;
        require(amount <= currentDeposit, "SD");

        alpacaStrategyDeposits =
            alpacaStrategyDeposits +
            currentDeposit -
            currentAmount - 
            amount;

        participantDataAlpaca[_from].amount = currentDeposit - amount;
        participantDataAlpaca[_from].lpMask = lpRoundMask;
        participantDataAlpaca[_from].totalReinvested +=
            currentDeposit -
            currentAmount;
    }

    /// @notice Adds global $Alpaca rewards to the contract
    /// @dev The lp roundmask is increased by the share of the rewarded amount such that investors get their share of pending lp rewards
    /// @param amount The amount to be rewarded
    function alpacaStrategyRewardReInvest(uint256 amount) internal {
        if (alpacaStrategyDeposits == 0) return;

        lpRoundMask += (DECIMAL_OFFSET * amount) / alpacaStrategyDeposits;
    }

    /// @notice Gets the current alpaca strategy balance for an investor. Pending lp rewards are included too
    /// @dev Pending rewards are calculated through the difference between the current round mask and the investors rewardMask according to EIP-1973
    /// @return Current alpaca strategy balance
    function getAlpacaStrategyBalance(address _from) public view returns (uint256) {
        if (participantDataAlpaca[_from].lpMask == 0) return 0;

        return
            participantDataAlpaca[_from].amount +
            ((lpRoundMask - participantDataAlpaca[_from].lpMask) *
                participantDataAlpaca[_from].amount) /
            DECIMAL_OFFSET;
    }

    /// @notice Adds global honey rewards to the contract
    /// @dev The honey roundmask is increased by the share of the rewarded amount such that investors get their share of pending honey rewards
    /// @param amount The amount of honey to be rewarded
    function alpacaStrategyRewardHoney(uint256 amount) internal {
        if (alpacaStrategyDeposits == 0) {
            return;
        }
        totalHoneyRewards += amount;
        honeyRoundMask += (DECIMAL_OFFSET * amount) / alpacaStrategyDeposits;
    }

    /// @notice Claims the alpaca strategy investors honey rewards
    /// @dev Can be called static to get the current alpaca strategy honey pending reward
    /// @return The pending rewards transfered to the investor
    function alpacaStrategyClaimHoney() public returns (uint256) {
        isNotPaused();
        updateAlpacaRewardMask(msg.sender);

        uint256 pendingRewards = participantDataAlpaca[msg.sender].pendingRewards;
        participantDataAlpaca[msg.sender].pendingRewards = 0;
        IERC20Upgradeable(address(HoneyToken)).safeTransfer(
            msg.sender,
            pendingRewards
        );
        emit AlpacaStrategyClaimHoneyEvent(msg.sender, pendingRewards);
        return pendingRewards;
    }

    /// @notice Gets the current alpaca strategy honey rewards for an investor. Pending honey rewards are included too
    /// @dev Pending rewards are calculated through the difference between the current round mask and the investors rewardMask according to EIP-1973
    /// @return Current alpaca strategy honey rewards
    function getAlpacaStrategyHoneyRewards(address _from) public view returns (uint256) {
        if (participantDataAlpaca[_from].rewardMask == 0) return 0;

        return
            participantDataAlpaca[_from].pendingRewards +
            ((honeyRoundMask - participantDataAlpaca[_from].rewardMask) *
                participantDataAlpaca[_from].amount) /
            DECIMAL_OFFSET;
    }

    /// @notice Updates the alpaca strategy honey rewards mask
    function updateAlpacaRewardMask(address _from) private { 
        uint256 currentRewardBalance = getAlpacaStrategyHoneyRewards(_from);
        participantDataAlpaca[_from].pendingRewards = currentRewardBalance;
        participantDataAlpaca[_from].rewardMask = honeyRoundMask;
    }

    /// @notice Reads out the participant data
    /// @param participant The address of the participant
    /// @return Participant data
    function getAlpacaStrategyParticipantData(address participant)
        public
        view
        returns (AlpacaStrategyParticipant memory)
    {
        return participantDataAlpaca[participant];
    }

    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/security/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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


// File contracts/AlpacaGrizzly.sol

 
pragma solidity ^0.8.4;
/// @title The AlpacaGrizzly contract for working with Alpaca Finance
/// @notice This contract put together all abstract contracts and is deployed once for each token ("single asset hive" or "SAH"). It allows the user to deposit and withdraw funds to the predefined hive. In addition, rewards can be staked using stakeReward.
/// @dev AccessControl from openzeppelin implementation is used to handle the update of the beeEfficiency Multiplier "BEM".
/// User with DEFAULT_ADMIN_ROLE can grant UPDATER_ROLE to any address.
/// The DEFAULT_ADMIN_ROLE is intended to be a 2 out of 3 multisig wallet in the beginning and then be moved to governance in the future.
/// The Contract uses ReentrancyGuard from openzeppelin for all transactions that transfer bnbs to the msg.sender
contract AlpacaGrizzly is
    Initializable,
    BaseConfig,
    AlpacaStrategy,                            
    ReentrancyGuardUpgradeable
{

    receive() external payable {}

    using SafeERC20Upgradeable for IERC20Upgradeable;


   function initialize(
        address _Admin,
        address _AlpacaStakingContractAddress,
        address _AlpacaDepositContractAddress, 
        address _HoneyTokenAddress,
        address _DevTeamAddress,
        address _ReferralAddress,
        address _AveragePriceOracleAddress,
        address _DEXAddress, 
        uint256 _AlpacaPoolID
    ) public initializer {
        __BaseConfig_init(
            _Admin,
            _AlpacaStakingContractAddress,
            _AlpacaDepositContractAddress, 
            _HoneyTokenAddress,
            _DevTeamAddress,
            _ReferralAddress,
            _AveragePriceOracleAddress,
            _DEXAddress,
            _AlpacaPoolID
        );
        __AlpacaStrategy_init();
        __Pausable_init();
        __ReentrancyGuard_init();


        restakeThreshold = 100000000000; 
        beeEfficiencyMultiplier = (1 ether * 6) / 5; //@todo Should be 1.2 / 1200 // 6/5
    }

    uint256 public beeEfficiencyMultiplier;
    uint256 public totalRewardsClaimed;
    uint256 public totalAlpacaBnbReinvested;        
    uint256 public lastStakeRewardsCall;            
    uint256 public lastStakeRewardsDuration;        
    uint256 public lastStakeRewardsDeposit;     
    uint256 public lastStakeRewardsAlpaca;    
    uint256 public restakeThreshold;


    event DepositEvent(
        address indexed user,
        uint256 lpAmount
        // Strategy indexed currentStrategy
    );
    event WithdrawEvent(
        address indexed user,
        uint256 lpAmount      
    );
    event StakeRewardsEvent(
        address indexed caller,
        uint256 bnbAmount
    );

    event confirmedPubDepositCall(
        address indexed user, 
        uint depositAmount
    );

    /// @notice pause
    /// @dev pause the contract
    function pause() external onlyRole(PAUSER_ROLE) {
        isNotPaused();
        _pause();
    }

    /// @notice unpause
    /// @dev unpause the contract
    function unpause() external onlyRole(PAUSER_ROLE) {
        isPaused();
        _unpause();
    }

    /// @notice The public deposit function
    /// @dev This is a payable function where the user can deposit Target Token (Based on the SAH)
    /// @param referralGiver The address of the account that provided referral
    /// @param amountToken The amount of desired Token the User want's to deposit, can only be equal to TargetToken (e.g. USDC Hive, TargetToken = USDC)
    /// @param deadline The deadline for the transaction
    /// @return The value in iB tokens that was deposited 
    function deposit( 
        address referralGiver,          
        uint256 deadline,
        uint256 amountToken
    ) external payable nonReentrant returns (uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        bool isNative;

        if(address(depositToken) == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c && msg.value > 0 ) {            
            amountToken = msg.value;
            isNative = true;

            } else {
            depositToken.safeTransferFrom(msg.sender, address(this), amountToken);
            isNative = false;

            emit confirmedPubDepositCall(msg.sender, amountToken);
            }
        
            return _deposit(amountToken, referralGiver, isNative);
    }

    /// @notice The internal deposit function
    /// @dev The actual deposit function. SAH Tokens (eg. USDC) are converted to corresponding ib tokens and then staked with alpaca's fairlaunch 
    /// @param amountToken The amount of SAH Token to be deposited
    /// @param referralGiver The address of the account that provided referral
    /// @return The value in ibTokens that was deposited 
    function _deposit(
        uint256 amountToken, 
        address referralGiver, 
        bool isNative
        ) internal returns (uint256) {  
        require(amountToken > 0, "DL");

        uint256 balanceBefore = AlpacaVault.balanceOf(address(this));

        (isNative) ? AlpacaVault.deposit{value: amountToken}(amountToken) : AlpacaVault.deposit(amountToken);

        uint256 balanceAfter = AlpacaVault.balanceOf(address(this));

        uint256 ibAmountToken = balanceAfter - balanceBefore;

        AlpacaStakingContract.deposit(address(this), AlpacaPoolID, ibAmountToken);
        _stakeRewards();

        alpacaStrategyDeposit(ibAmountToken, msg.sender);
    

        Referral.referralDeposit(ibAmountToken, msg.sender, referralGiver);
        emit DepositEvent(msg.sender, ibAmountToken);
        return ibAmountToken;
    }


    /// @notice The public withdraw function
    /// @dev Withdraws the desired amount for the user and transfers the SAH Token to the user by using the call function. Adds a reentrant guard. Input should be converted to ibToken Value
    /// @param amountToken The amount of the SAH token to be withdrawn from the Hive
    /// @param deadline The deadline for the transaction
    /// @return The value in BNB that was withdrawn
    function withdraw(
        uint256 amountToken,
        uint256 deadline
    ) external nonReentrant returns (uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");

        _stakeRewards();

        uint256 amountWithdrawn = _withdraw(amountToken);

        if (
            address(depositToken) == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        ) {
            _transferEth(msg.sender, amountWithdrawn);
        } else {
            depositToken.safeTransfer(msg.sender, amountWithdrawn);
        }
        return amountWithdrawn;
    }

    /// @notice The public withdraw all function
    /// @dev Calculates the total staked amount in the first place and uses that to withdraw all funds. Adds a reentrant guard. ibToken <- -> SAH Token conversion done @Front-End
    /// @param deadline The deadline for the transaction
    /// @return The value in SAH Token that was withdrawn
    function withdrawAll(
        uint256 deadline
    ) external nonReentrant returns (uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        
        _stakeRewards();
        uint256 currentDeposits = 0;

        currentDeposits = getAlpacaStrategyBalance(msg.sender);

        uint256 amountWithdrawn = 0;
        if (currentDeposits > 0) {
            amountWithdrawn = _withdraw(currentDeposits);
            if (
                address(depositToken) == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
            ) {
                _transferEth(msg.sender, amountWithdrawn);
            } else {
                depositToken.safeTransfer(msg.sender, amountWithdrawn);
            }


        }
        return amountWithdrawn;
    }



    /// @notice The internal withdraw function
    /// @dev The actual withdraw function. First the withdrawn from the strategy is performed and then ib tokens are withdrawn/unstakef from fairlaunch, converted into initial TargetToken and returned.
    /// @param amountToken The amount of SAH to be withdrawn (e.g. USDC) 
    /// @return Amount to be withdrawn
    function _withdraw(uint256 amountToken) internal returns (uint256) {

        alpacaStrategyWithdraw(amountToken, msg.sender);
        alpacaStrategyClaimHoney();

        uint256 ibTokenStakedAmount = amountToken; 
        AlpacaStakingContract.withdraw(address(this), AlpacaPoolID, ibTokenStakedAmount);

        uint256 balanceBefore1 = 0;
        if (address(depositToken) == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) {
            balanceBefore1 = address(this).balance;
        } else {
            balanceBefore1 = depositToken.balanceOf(address(this));
        }

        AlpacaVault.withdraw(ibTokenStakedAmount);

        uint256 balanceAfter1 = 0;
                if (address(depositToken) == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) {
            balanceAfter1 = address(this).balance;
        } else {
            balanceAfter1 = depositToken.balanceOf(address(this));
        }
        uint256 returnAmount = balanceAfter1 - balanceBefore1;

        Referral.referralWithdraw(amountToken, msg.sender);
        emit WithdrawEvent(msg.sender, amountToken);

        return returnAmount;
    }

    function _stakeRewards()
        internal 
        returns(uint256 totalBnb) {

        if(alpacaStrategyDeposits == 0) return 0;

        AveragePriceOracle.updateHoneyEthPrice();

        uint256 beforeAmount = AlpacaRewardToken.balanceOf(address(this));  

        AlpacaStakingContract.harvest(AlpacaPoolID);        
        uint256 afterAmount = AlpacaRewardToken.balanceOf(address(this));

        uint256 currentRewards = afterAmount - beforeAmount; 


        if (currentRewards < restakeThreshold) return 0;

        lastStakeRewardsDuration = block.timestamp - lastStakeRewardsCall; 
        lastStakeRewardsCall = block.timestamp; 


        (lastStakeRewardsDeposit, , , ) = AlpacaStakingContract.userInfo(
            AlpacaPoolID, 
            address(this)
        );
        lastStakeRewardsAlpaca = currentRewards;
        totalRewardsClaimed += currentRewards;

        uint256 bnbAmount = DEX.convertTokenToEth(
            currentRewards,
            address(AlpacaRewardToken)
        );

        if (bnbAmount > 100) {
        stakeAlpacaRewards(bnbAmount);
        } 
        emit StakeRewardsEvent(
            msg.sender,
            bnbAmount
        );
        return bnbAmount;
    }

    /// @notice stakeAlpacaRewards stakes rewards only for Alpaca SAH 
    /// @param bnbReward The pending bnb reward to be restaked 
    function stakeAlpacaRewards(uint bnbReward) internal {
        uint256 tokenReInvestShare = (bnbReward * 50) / 100;

        uint256 tokenReInvestAmount = 0;
        if(address(depositToken) != 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) {
            tokenReInvestAmount = DEX.convertEthToToken{value: tokenReInvestShare}(address(depositToken));
        } else {
            tokenReInvestAmount = tokenReInvestShare;
        }

        totalAlpacaBnbReinvested += tokenReInvestShare;

        uint256 balanceBefore = AlpacaVault.balanceOf(address(this));
        if (
            address(depositToken) != 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        ) {
            AlpacaVault.deposit(tokenReInvestAmount);
        } else {
            AlpacaVault.deposit{value: tokenReInvestAmount}(
                tokenReInvestAmount
            );
        }

        uint256 balanceAfter = AlpacaVault.balanceOf(address(this));

        uint256 ibTokenReInvestAmount = balanceAfter - balanceBefore;

        alpacaStrategyRewardReInvest(ibTokenReInvestAmount);

        AlpacaStakingContract.deposit(address(this), AlpacaPoolID, ibTokenReInvestAmount);

        uint256 ghnyBnbPrice = AveragePriceOracle.getAverageHoneyForOneEth();

        uint256 honeyBuybackShare = (bnbReward * 45) / 100;
                uint256 honeyBuybackAmount = DEX.convertEthToToken{value: honeyBuybackShare}(
                    address(HoneyToken)
                );

        IERC20Upgradeable(address(HoneyToken)).safeTransfer(address(0x000000000000000000000000000000000000dEaD), honeyBuybackAmount);

        uint256 ghnyCompensation = (ghnyBnbPrice * (bnbReward * 50) / 100) / (1 ether);
        
        (uint256 mintedHoney, uint256 referralHoney) = mintTokens(
                    ghnyCompensation,
                    beeEfficiencyMultiplier,
                    0
                );
        alpacaStrategyRewardHoney(mintedHoney);

        _transferEth(
            DevTeam,
            bnbReward - tokenReInvestShare - honeyBuybackShare
        );
    }


    /// @notice Mints tokens according to the bee efficiency level
    /// @param _share The share that should be minted in honey
    /// @param _beeEfficiencyMultiplier The bee efficiency multiplier to be set to multiply shares into honey amounts
    /// @param _additionalShare The additional share tokens to be minted
    /// @return tokens The amount minted in honey tokens
    /// @return additionalTokens The additional tokens that were minted
    function mintTokens(
        uint256 _share,
        uint256 _beeEfficiencyMultiplier,
        uint256 _additionalShare
    ) internal returns (
        uint256 tokens, 
        uint256 additionalTokens
        ) {
        tokens = (_share * _beeEfficiencyMultiplier) / (1 ether);
        additionalTokens = (tokens * _additionalShare) / (1 ether);

        HoneyToken.claimTokens(tokens + additionalTokens);
    }

    /// @notice Updates the restake Threshold
    /// @dev only updater role can perform this function
    /// @param _newRestakeThreshold The new restaking Threshold
    function updateRestakeThreshold(uint256 _newRestakeThreshold)
        external
        onlyRole(UPDATER_ROLE) {
        restakeThreshold = _newRestakeThreshold;
    }

    /// @notice Updates the bee efficiency multiplier BEM
    /// @dev only updater role can perform this function
    /// @param _newBeeEfficiencyMultiplier The new bee efficiency multiplier
    function updateBeeEfficiencyMultiplier(uint256 _newBeeEfficiencyMultiplier)
        external
        onlyRole(UPDATER_ROLE) {
        beeEfficiencyMultiplier = _newBeeEfficiencyMultiplier;
    }


    
    /// @notice Used to get the most up-to-date state for caller's deposits. It is intended to be statically called
    /// @dev Calls stakeRewards before reading strategy-specific data in order to get the most up to-date-state
    /// @return deposited - The amount of ibTokens deposited 
    /// @return balance - The sum of deposited ibTokens and reinvested amounts
    /// @return totalReinvested - The total amount reinvested, including unclaimed rewards
    /// @return earnedHoney - The amount of Honey tokens earned
    /// @return earnedBnb - The amount of BNB/SAH earned
    /// @return stakedHoney - The amount of Honey tokens staked in the Staking Pool
    function getUpdatedState()
        external
        returns (
            uint256 deposited,
            uint256 balance,
            uint256 totalReinvested,
            uint256 earnedHoney,
            uint256 earnedBnb,
            uint256 stakedHoney
        ){
        isNotPaused();
        _stakeRewards();
 
        AlpacaStrategyParticipant
            memory participantData = getAlpacaStrategyParticipantData(
                msg.sender
            );

        deposited = participantData.amount;
        balance = getAlpacaStrategyBalance(msg.sender);
        totalReinvested =
            participantData.totalReinvested +
            balance -
            deposited;

        earnedHoney = getAlpacaStrategyHoneyRewards(msg.sender); 
        earnedBnb = 0;
        stakedHoney = 0;
    }

    /// @notice payout function
    /// @dev care about non reentrant vulnerabilities
    function _transferEth(
        address to, 
        uint256 amount
        ) internal {
        (bool transferSuccess, ) = payable(to).call{value: amount}("");
        require(transferSuccess, "TF");
    }
    /// @notice Fund Recovery function
    /// @dev When someone sent coins/tokens directly to this contract or there's a tiny amount left over, we use this function to recover those funds. 
    function recoverFunds()
        external
        nonReentrant
        onlyRole(FUNDS_RECOVERY_ROLE)
    {
        depositToken.safeTransfer(
            msg.sender,
            depositToken.balanceOf(address(this))
        );
        _transferEth(msg.sender, address(this).balance);
    }

    uint256[50] private __gap;
}