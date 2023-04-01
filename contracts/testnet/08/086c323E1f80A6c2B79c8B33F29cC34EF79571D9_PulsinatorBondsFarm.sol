// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
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

pragma solidity >=0.5.0;

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

pragma solidity >=0.6.6;

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
pragma solidity >=0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IPancakeRouter01.sol";


contract PulsinatorBondsFarm is Initializable {
    address payable public OWNER;
    address payable public teamWallet;
    IERC20 public stakedToken;
    IERC20 public rewardToken;

    address APE_ROUTER;
    address TOKEN_WBNB_LP;
    address TOKEN;
    address WETH;

    uint public acceptableSlippage;
    uint public tokenPerBnb;
    bool public tokenBondBonusActive;
    uint public tokenBondBonus;
    uint public tokensForBondsSupply;
    uint public beansFromSoldToken;
    struct UserInfo {
        uint tokenBalance;
        uint bnbBalance;
        uint tokenBonds;
    }
    mapping(address => UserInfo) public addressToUserInfo;
    mapping(address => uint) public userStakedBalance;
    mapping(address => uint) public userPaidRewards;
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public userRewards;
    mapping(address => bool) public userStakeAgain;
    mapping(address => bool) public userStakeIsRefferred;
    mapping(address => address) public userRefferred;
    mapping(address => uint) public refferralRewardCount;

    uint public earlyUnstakeFee; // 20% fee
    uint public poolDuration;
    uint public poolStartTime;
    uint public poolEndTime;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;
    uint private _totalStaked;

    uint public refferralLimit;
    uint public refferralPercentage;

    /* ========== MODIFIERS ========== */

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();
        if (_account != address(0)) {
            userRewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER, "Ownable: caller is not the owner");
        _;
    }

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
    event TokenBondsPurchased(
        address indexed user,
        uint tokenAmount,
        uint wbnbAmount,
        uint lpAmount
    );
    event TokenBondSold(address indexed user, uint tokenAmount, uint wbnbAmount);

    receive() external payable {}

    /* ========== CONSTRUCTOR ========== */

    function initialize() public initializer {
        OWNER = payable(msg.sender);
        teamWallet = payable(0xf3b26aDCFCd03FFB5a1a74afF9e33D582c7402E9);
        stakedToken = IERC20(0x9F6898b3B47B4A1d30b7E36B2F62e9a45F42AA5c);
        rewardToken = IERC20(0xe9Bc3da64eC4CFC045d7A910B10fdD87781D5709);
        APE_ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        TOKEN = 0xe9Bc3da64eC4CFC045d7A910B10fdD87781D5709;
        WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        TOKEN_WBNB_LP = 0x9F6898b3B47B4A1d30b7E36B2F62e9a45F42AA5c;
        acceptableSlippage = 500;
        tokenBondBonusActive = true;
        tokenBondBonus = 1000; // 10% bonus
        earlyUnstakeFee = 2500; // 25% fee
        // poolDuration = 7776000;
        poolDuration = 90 days;
        refferralLimit = 5;
        refferralPercentage = 500;
    }

    /* ========== Token BOND FUNCTIONS ========== */

    function purchaseTokenBond(address _refferralUserAddress) external payable {
        if (userStakeAgain[msg.sender] == false) {
            userStakeAgain[msg.sender] = true;
            if (
                _refferralUserAddress != address(0) &&
                _refferralUserAddress != msg.sender 
            ) {
                userRefferred[msg.sender] = _refferralUserAddress;
                userStakeIsRefferred[msg.sender] = true;
            }
        }

        uint totalBeans = msg.value;
        // if (totalBeans <= 0) revert InvalidAmount();
        require(totalBeans > 0, "Purchase amount must be greater than 0");

        uint beanHalfOfBond = totalBeans / 2;
        uint beanHalfToToken = totalBeans - beanHalfOfBond;
        uint tokenHalfOfBond = _beanToToken(beanHalfToToken);
        // beansFromSoldToken += beanHalfToToken;

       (bool success,) =payable(OWNER).call{value: beanHalfToToken}("");
        require(success, "Failed to send BNB");

        uint tokenMin = _calSlippage(tokenHalfOfBond);
        uint beanMin = _calSlippage(beanHalfOfBond);

        IERC20(WETH).approve(APE_ROUTER, beanHalfOfBond);
        IERC20(TOKEN).approve(APE_ROUTER, tokenHalfOfBond);

        (uint _amountA, uint _amountB, uint _liquidity) = IPancakeRouter01(
            APE_ROUTER
        ).addLiquidityETH{value: beanHalfOfBond}(
            TOKEN,
            tokenHalfOfBond,
            tokenMin,
            beanMin,
            address(this),
            block.timestamp + 500
        );
        
        tokensForBondsSupply-=_amountA;

        UserInfo memory userInfo = addressToUserInfo[msg.sender];
        userInfo.tokenBalance += tokenHalfOfBond;
        userInfo.bnbBalance += beanHalfOfBond;
        userInfo.tokenBonds += _liquidity;

        addressToUserInfo[msg.sender] = userInfo;
        emit TokenBondsPurchased(msg.sender, _amountA, _amountB, _liquidity);
        _stake(_liquidity);
    }

    function redeemTokenBond() external {
        UserInfo storage userInfo = addressToUserInfo[msg.sender];
        uint bnbOwed = userInfo.bnbBalance;
        uint tokenOwed = userInfo.tokenBalance;
        uint tokenBonds = userInfo.tokenBonds;
        require(tokenBonds > 0, "No Tokens to unstake");

        userInfo.bnbBalance = 0;
        userInfo.tokenBalance = 0;
        userInfo.tokenBonds = 0;

        _unstake(tokenBonds);

        uint tokenMin = _calSlippage(tokenOwed);
        uint beanMin = _calSlippage(bnbOwed);

        IERC20(TOKEN_WBNB_LP).approve(APE_ROUTER, tokenBonds);

        (uint _amountA, uint _amountB) = IPancakeRouter01(APE_ROUTER)
            .removeLiquidity(
                TOKEN,
                WETH,
                tokenBonds,
                tokenMin,
                beanMin,
                address(this),
                block.timestamp + 500
            );

        // sending wbnb to the user which recieved from pancakeswap router
        IERC20(WETH).transfer(msg.sender, _amountB);
        IERC20(TOKEN).transfer(msg.sender, tokenOwed);
        tokensForBondsSupply += _amountA;
        emit TokenBondSold(msg.sender, _amountA, _amountB);
    }

    function _calSlippage(uint _amount) private view returns (uint) {
        return (_amount * acceptableSlippage) / 10000;
    }

    function _beanToToken(uint _amount) private returns (uint) {
        uint tokenJuice;
        uint tokenJuiceBonus;

        //confirm token0 & token1 in LP contract
        (uint bnbReserves, uint tokenReserves, ) = IPancakePair(TOKEN_WBNB_LP)
            .getReserves();

        tokenPerBnb = (tokenReserves * 10 ** 18) / bnbReserves;
        tokenPerBnb = tokenPerBnb;
        emit TokenBondsPurchased(msg.sender, tokenReserves, bnbReserves, tokenPerBnb);
        // tokenPerBnb = tokenPerBnb * 10**18;

        if (tokenBondBonusActive) {
            tokenJuiceBonus = (tokenPerBnb * tokenBondBonus) / 10000;
            uint tokenPerBnbDiscounted = tokenPerBnb + tokenJuiceBonus;
            tokenJuice = (_amount * tokenPerBnbDiscounted) / 10 ** 18;
            // } else tokenJuice = _amount * tokenPerBnb;
        } else tokenJuice = (_amount * tokenPerBnb) / 10 ** 18;

        // if (tokenJuice > tokensForBondsSupply) revert InvalidAmount();
        require(tokenJuice <= tokensForBondsSupply, "Not Enough Tokens Supply");

        tokensForBondsSupply -= tokenJuice;
        emit TokenBondsPurchased(msg.sender, tokenJuice, tokenJuice, tokenJuice);
        return tokenJuice;
    }

    function fundTokenBonds(uint _amount) external {
        // if (_amount <= 0) revert InvalidAmount();
        require(_amount > 0, "Invalid Amount");

        tokensForBondsSupply += _amount;
        IERC20(TOKEN).transferFrom(msg.sender, address(this), _amount);
    }


    function defundTokenBonds(uint _amount) external onlyOwner {
        // if (_amount <= 0) revert InvalidAmount();
        require(_amount > 0, "Invalid Amount");

        tokensForBondsSupply -= _amount;
        IERC20(TOKEN).transfer(msg.sender, _amount);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _stake(uint _amount) private updateReward(msg.sender) {
        // if (_amount <= 0) revert InvalidAmount();
        require(_amount > 0, "Invalid Amount");
        userStakedBalance[msg.sender] += _amount;
        _totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }

    function _unstake(uint _amount) private updateReward(msg.sender) {
        // if (block.timestamp < poolEndTime) revert TokensLocked();
        require(block.timestamp >= poolEndTime, "Tokens Locked");
        // if (_amount <= 0) revert InvalidAmount();
        require(_amount > 0, "Invalid Amount");
        // if (_amount > userStakedBalance[msg.sender]) revert InvalidAmount();
        require(
            _amount <= userStakedBalance[msg.sender],
            "Not Enough Lp Tokens To Unstake"
        );

        userStakedBalance[msg.sender] -= _amount;
        _totalStaked -= _amount;
        emit Unstaked(msg.sender, _amount);
    }

    function emergencyUnstake() external updateReward(msg.sender) {
        UserInfo storage userInfo = addressToUserInfo[msg.sender];
        uint bnbOwed = userInfo.bnbBalance;
        uint tokenOwed = userInfo.tokenBalance;
        uint tokenBonds = userInfo.tokenBonds;
        // if (tokenBonds <= 0) revert InvalidAmount();
        require(tokenBonds > 0, "No Tokens to unstake");

        userInfo.bnbBalance = 0;
        userInfo.tokenBalance = 0;
        userInfo.tokenBonds = 0;

        uint amount = userStakedBalance[msg.sender];
        // if (amount <= 0) revert InvalidAmount();
        require(amount > 0, "No LP Tokens to unstake");

        userStakedBalance[msg.sender] = 0;
        _totalStaked -= amount;

        uint fee = (amount * earlyUnstakeFee) / 10000;
        uint tokenBondsAfterFee = amount - fee;
        stakedToken.transfer(teamWallet, fee);

        uint tokenMin = _calSlippage(tokenOwed);
        uint beanMin = _calSlippage(bnbOwed);

        IERC20(TOKEN_WBNB_LP).approve(APE_ROUTER, tokenBondsAfterFee);
        (uint _amountA, uint _amountB) = IPancakeRouter01(APE_ROUTER)
            .removeLiquidity(
                TOKEN,
                WETH,
                tokenBondsAfterFee,
                tokenMin,
                beanMin,
                address(this),
                block.timestamp + 500
            );
        uint wbnbFee = (_amountB * earlyUnstakeFee) / 10000;
        uint bnbOwedAfterFee = _amountB - wbnbFee;
        uint tokenFee=(tokenOwed * earlyUnstakeFee) / 10000;
        uint tokenOwedAfterFee = tokenOwed - tokenFee;

        IERC20(WETH).transfer(msg.sender, bnbOwedAfterFee);
        IERC20(TOKEN).transfer(msg.sender, tokenOwedAfterFee);
        IERC20(WETH).transfer(teamWallet, wbnbFee);
        IERC20(TOKEN).transfer(teamWallet, tokenFee);


        emit Unstaked(msg.sender, amount);
        emit TokenBondSold(msg.sender, _amountA, _amountB);
    }

    function claimRewards() public updateReward(msg.sender) {
        uint rewards = userRewards[msg.sender];
        require(rewards > 0, "No Claim Rewards Yet!");

        userRewards[msg.sender] = 0;
        userPaidRewards[msg.sender] += rewards;
        tokensForBondsSupply -= rewards;
        if (userStakeIsRefferred[msg.sender] == true) {
            if (refferralRewardCount[msg.sender] < refferralLimit) {
                uint refferalReward = (rewards * refferralPercentage) / 10000;
                refferralRewardCount[msg.sender] =
                    refferralRewardCount[msg.sender] +
                    1;
                rewardToken.transfer(userRefferred[msg.sender], refferalReward);
                rewardToken.transfer(msg.sender, rewards - refferalReward);
                emit RewardPaid(userRefferred[msg.sender], refferalReward);
                emit RewardPaid(msg.sender, rewards - refferalReward);
            } else {
                rewardToken.transfer(msg.sender, rewards);
                emit RewardPaid(msg.sender, rewards);
            }
        } else {
            rewardToken.transfer(msg.sender, rewards);
            emit RewardPaid(msg.sender, rewards);
        }
    }

    /* ========== OWNER RESTRICTED FUNCTIONS ========== */

    function setAcceptableSlippage(uint _amount) external onlyOwner {
        // if (_amount > 2000) revert InvalidAmount(); // can't set above 20%
        require(_amount <= 2000, "Can't set above 20%");

        acceptableSlippage = _amount;
    }

    function setTokenBondBonus(uint _amount) external onlyOwner {
        // if (_amount > 2000) revert InvalidAmount(); // can't set above 20%
        require(_amount <= 2000, "Can't set above 20%");

        tokenBondBonus = _amount;
    }

    function setTokenBondBonusActive(bool _status) external onlyOwner {
        tokenBondBonusActive = _status;
    }

    // function withdrawBeansFromSoldToken() external onlyOwner {
    //     uint beans = beansFromSoldToken;
    //     beansFromSoldToken = 0;
    //     (bool success, ) = msg.sender.call{value: beans}("");
    //     require(success, "Transfer failed.");
    // }

    function setPoolDuration(uint _duration) external onlyOwner {
        require(poolEndTime < block.timestamp, "Pool still live");
        poolDuration = _duration;
    }

    function setPoolRewards(
        uint _amount
    ) external onlyOwner updateReward(address(0)) {
        // if (_amount <= 0) revert InvalidAmount();
        require(_amount > 0, "Invalid Reward Amount");

        if (block.timestamp >= poolEndTime) {
            rewardRate = _amount / poolDuration;
        } else {
            uint remainingRewards = (poolEndTime - block.timestamp) *
                rewardRate;
            rewardRate = (_amount + remainingRewards) / poolDuration;
        }
        // if (rewardRate <= 0) revert InvalidAmount();
        require(rewardRate > 0, "Invalid Reward Rate");

        poolStartTime = block.timestamp;
        poolEndTime = block.timestamp + poolDuration;
        updatedAt = block.timestamp;
    }

    function topUpPoolRewards(
        uint _amount
    ) external onlyOwner updateReward(address(0)) {
        uint remainingRewards = (poolEndTime - block.timestamp) * rewardRate;
        rewardRate = (_amount + remainingRewards) / poolDuration;
        require(rewardRate > 0, "reward rate = 0");
        updatedAt = block.timestamp;
    }

    function updateTeamWallet(address payable _teamWallet) external onlyOwner {
        teamWallet = _teamWallet;
    }

    function setAddresses(
        address _router,
        address _tokenWbnbLp,
        address _token,
        address _wbnb
    ) external onlyOwner {
        APE_ROUTER = _router;
        TOKEN_WBNB_LP = _tokenWbnbLp;
        TOKEN = _token;
        WETH = _wbnb;
     }

    function transferOwnership(address _newOwner) external onlyOwner {
        OWNER = payable(_newOwner);
    }

    function setEarlyUnstakeFee(uint _earlyUnstakeFee) external onlyOwner {
        require(_earlyUnstakeFee <= 2500, "the amount of fee is too damn high");
        earlyUnstakeFee = _earlyUnstakeFee;
    }

    function setRefferralPercentage(
        uint _newRefferralPercentage
    ) external onlyOwner {
        require(_newRefferralPercentage >= 0, "Invalid Refferral Percentage");
        refferralPercentage = _newRefferralPercentage;
    }

    function setRefferralLimit(uint _newRefferralLimit) external onlyOwner {
        require(_newRefferralLimit >= 0, "Invalid Refferral Limit");
        refferralLimit = _newRefferralLimit;
    }

    function emergencyRecoverBeans() public onlyOwner {
        uint balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // function emergencyRecoverBEP20(
    //     IERC20 _token,
    //     uint _amount
    // ) public onlyOwner {
    //     if (_token == stakedToken) {
    //         uint recoverAmount = _token.balanceOf(address(this)) - _totalStaked;
    //         _token.transfer(msg.sender, recoverAmount);
    //     } else if (_token == rewardToken) {
    //         uint availRecoverAmount = _token.balanceOf(address(this)) -
    //             tokenForStakingRewards();
    //         require(_amount <= availRecoverAmount, "amount too high");
    //         _token.transfer(msg.sender, _amount);
    //     } else {
    //         _token.transfer(msg.sender, _amount);
    //     }
    // }

    /* ========== VIEW & GETTER FUNCTIONS ========== */

    function viewUserInfo(address _user) public view returns (UserInfo memory) {
        return addressToUserInfo[_user];
    }

    function earned(address _account) public view returns (uint) {
        return
            (userStakedBalance[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) /
            1e18 +
            userRewards[_account];
    }

    function lastTimeRewardApplicable() private view returns (uint) {
        return _min(block.timestamp, poolEndTime);
    }

    function rewardPerToken() private view returns (uint) {
        if (_totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            _totalStaked;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

    function tokenForStakingRewards() public view returns (uint) {
        return rewardToken.balanceOf(address(this)) - tokensForBondsSupply;
    }

    function balanceOf(address _account) external view returns (uint) {
        return userStakedBalance[_account];
    }

    function totalStaked() external view returns (uint) {
        return _totalStaked;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}