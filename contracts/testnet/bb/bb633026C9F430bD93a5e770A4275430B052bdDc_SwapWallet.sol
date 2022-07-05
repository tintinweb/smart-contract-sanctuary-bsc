// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./SwapWalletFactory.sol";
import "./IWETH.sol";
import "./IUniRouter.sol";

contract SwapWallet is Initializable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    
    address private _owner;
    address private _pendingOwner;

    SwapWalletFactory private factory;
    uint256 private safeMinGas;

    IWETH private WETH;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);
    event WithdrawHappened(address indexed assetAddress, uint256 amount, address indexed toAddress);

    function initialize(address owner_, SwapWalletFactory factory_) public initializer{ 
        require(owner_ != address(0), "SwapWallet: owner is the zero address");

        _owner = owner_;
        safeMinGas = 2300;
        factory = factory_;
        WETH = IWETH(factory_.WETH());
    }


    receive() external payable {
            // React to receiving ether
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function getFactory() external view returns (address) {
        return address(factory);
    }

    function getWETH() external view returns (address) {
        return address(WETH);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "SwapWallet: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "SwapWallet: new owner is the zero address");
        require(newOwner != _owner, "SwapWallet: new owner is the same as the current owner");

        emit OwnershipTransferred(_owner, newOwner);
        _pendingOwner = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == _pendingOwner, "SwapWallet: invalid new owner");
        emit OwnershipAccepted(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }

    function withdraw(address assetAddress_, uint256 amount_, address toAddress_) external nonReentrant {
        require(amount_ > 0, "SwapWallet: ZERO_AMOUNT");
        require(msg.sender == _owner || msg.sender == factory.owner(), "SwapWallet: only owner or factory owner can withdraw");
        bool isWhitelistAddress = factory.whitelistAddressToIndex(toAddress_) > 0 || toAddress_ == address(factory);
        require(isWhitelistAddress, "SwapWallet: withdraw to non whitelist address");
        if (assetAddress_ == address(0)) {
            address self = address(this);
            uint256 assetBalance = self.balance;
            require(assetBalance >= amount_, "SwapWallet: not enough balance");
            _safeTransferETH(toAddress_, amount_);
            emit WithdrawHappened(assetAddress_, amount_, toAddress_);
        } else {
            IERC20Upgradeable token = IERC20Upgradeable(assetAddress_);
            uint256 assetBalance = token.balanceOf(address(this));
            require(assetBalance >= amount_, "SwapWallet: not enough balance");
            token.safeTransfer(toAddress_, amount_);
            emit WithdrawHappened(assetAddress_, amount_, toAddress_);
        }
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: safeMinGas, value: value}("");
        require(success, "SwapWallet: transfer eth failed");
    }

    function verifySwapPath(address router, address[] calldata path) internal view{
        require(path.length > 1, "SwapWallet: path should contain at least two tokens");
        uint len = path.length - 1;
        for (uint i; i < len;  ++i) {
            address tokenA = path[i];
            address tokenB = path[i + 1];
            (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
            require(factory.whitelistPairToIndex(router, token0, token1) > 0, "SwapWallet: cannot swap non-whitelisted pair");
        }
    }

    function swapExactTokensForTokens(
        address router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        IUniRouter(router).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), deadline);
    }

    function swapTokensForExactTokens(
        address router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        uint deadline
    ) external nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);
        IUniRouter(router).swapTokensForExactTokens(amountOut, amountInMax , path, address(this), deadline);
    }

    function swapTokensForExactETH(
        address router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        uint deadline
    ) external nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);
        IUniRouter(router).swapTokensForExactETH(amountOut, amountInMax, path, address(this), deadline);
    }

    function swapExactTokensForETH(
        address router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        IUniRouter(router).swapExactTokensForETH(amountIn, amountOutMin, path, address(this), deadline);
    }

    function swapExactETHForTokens(
        address router,
        uint amountOutMin, 
        address[] calldata path, 
        uint deadline) external payable nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IUniRouter(router).swapExactETHForTokens{value: msg.value}(amountOutMin, path, address(this), deadline);
    }

    function swapETHForExactTokens(
        address router,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external payable nonReentrant onlyOwner{
        verifySwapPath(router, path);
        IUniRouter(router).swapETHForExactTokens{value: msg.value}(amountOutMin, path, address(this), deadline);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        IUniRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address router,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external payable nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IUniRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(amountOutMin, path, address(this), deadline);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external nonReentrant onlyOwner {
        verifySwapPath(router, path);
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        IUniRouter(router).swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);
    }

    function convertToWETH(uint amountETH) external onlyOwner {
        require(amountETH > 0, "SwapWallet: ZERO_AMOUNT");
        address self = address(this);
        uint256 assetBalance = self.balance;
        if (assetBalance >= amountETH) {
            WETH.deposit{value: amountETH}();
        }
    }

    function convertFromWETH(uint amountWETH) external onlyOwner {
        require(amountWETH > 0, "SwapWallet: ZERO_AMOUNT");
        uint256 assetBalance = WETH.balanceOf(address(this));
        if (assetBalance > amountWETH) {
            WETH.withdraw(amountWETH);
        }
    }

}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import './SwapWallet.sol';


contract SwapWalletFactory is Initializable, ReentrancyGuardUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address private _owner;
    address private _pendingOwner;

    address public WETH;
    uint256 private safeMinGas;

    mapping(address => uint256) public whitelistAddressToIndex;
    address[] public whitelistAddresses;

    mapping(address => uint256) public walletToIndex;
    address[] public wallets;
    mapping(address => uint256) public walletOwnerToIndex;
    address[] public walletOwners;
    mapping(address => address) public walletOwnerToWallet;
    mapping(address => address) public walletToWalletOwner;

    mapping(address => mapping(address => mapping(address => uint256))) public whitelistPairToIndex;
    address[3][] public whitelistPairs;

    mapping(address => uint256) public applyGasTime;
    uint256 public applyGasLimit;
    uint256 public applyGasInterval;

    address private walletImplementationAddress;

    event SwapWalletCreated(address indexed wallet, address indexed walletOwner);
    event SwapWalletAdded(address indexed wallet, address indexed walletOwner);
    event SwapWalletDeleted(address indexed wallet, address indexed walletOwner);
    event SwapWalletUpdated(address indexed wallet, address indexed oldWalletOwner, address indexed newWalletOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);
    event WithdrawWhiteListAdded(address indexed addedAddress);
    event WithdrawWhiteListDeleted(address indexed deletedAddress);
    event PairWhiteListAdded(address indexed router, address indexed token0, address indexed token1);
    event PairWhiteListDeleted(address indexed router, address indexed token0, address indexed token1);
    event WithdrawHappened(address indexed assetAddress, uint256 amount, address indexed toAddress);
    event ApplyGasLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event ApplyGasIntervalUpdated(uint256 oldInterval, uint256 newInterval);
    event WalletImplementationAddressUpdated(address indexed previousImplementation, address indexed newImplementation);

    function initialize(address owner_, address WETH_, uint applyGasLimit_, uint applyGasInterval_) public initializer{
        require(owner_ != address(0), "SwapWalletFactory: owner is the zero address");
        require(WETH_ != address(0), "SwapWalletFactory: weth is the zero address");
        _owner = owner_;
        WETH = WETH_;
        safeMinGas = 2300;
        applyGasLimit = applyGasLimit_;
        applyGasInterval = applyGasInterval_;
    }

    receive() external payable {
            // React to receiving ether
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function whitelistAddressesLength() external view returns (uint) {
        return whitelistAddresses.length;
    }

    function whitelistPairsLength() external view returns (uint) {
        return whitelistPairs.length;
    }

    function walletsLength() external view returns (uint) {
        return wallets.length;
    }

    function walletOwnersLength() external view returns (uint) {
        return walletOwners.length;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "SwapWalletFactory: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "SwapWalletFactory: new owner is the zero address");
        require(newOwner != _owner, "SwapWalletFactory: new owner is the same as the current owner");

        emit OwnershipTransferred(_owner, newOwner);
        _pendingOwner = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == _pendingOwner, "SwapWalletFactory: invalid new owner");
        emit OwnershipAccepted(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }

    function createWallet(address walletOwner) external onlyOwner returns (address) {
        require(walletOwner != address(0), "SwapWalletFactory: wallet owner is the zero address");
        require(walletOwnerToIndex[walletOwner] == 0, "SwapWalletFactory: wallet owner already exists");
        SwapWallet wallet = SwapWallet(payable(ClonesUpgradeable.clone(walletImplementationAddress)));
        wallet.initialize(walletOwner, this);
        wallets.push(address(wallet));
        walletToIndex[address(wallet)] = wallets.length;
        walletOwners.push(walletOwner);
        walletOwnerToIndex[walletOwner] = walletOwners.length;
        walletOwnerToWallet[walletOwner] = address(wallet);
        walletToWalletOwner[address(wallet)] = walletOwner;
        emit SwapWalletCreated(address(wallet), walletOwner);
        return address(wallet);
    }

    function addWallet(address payable wallet, address walletOwner) external onlyOwner {
        require(walletOwner != address(0), "SwapWalletFactory: wallet owner is the zero address");
        require(wallet != address(0), "SwapWalletFactory: wallet is the zero address");
        require(walletToIndex[wallet] == 0, "SwapWalletFactory: wallet already exist");
        require(walletOwnerToIndex[walletOwner] == 0, "SwapWalletFactory: wallet owner already exist");
    
        SwapWallet walletContract = SwapWallet(wallet);
        require(walletContract.getFactory() == address(this), "SwapWalletFactory: wallet is not created from this factory");

        wallets.push(wallet);
        walletToIndex[wallet] = wallets.length;
        walletOwners.push(walletOwner);
        walletOwnerToIndex[walletOwner] = walletOwners.length;
        walletToWalletOwner[wallet] = walletOwner;
        walletOwnerToWallet[walletOwner] = wallet;
        emit SwapWalletAdded(address(wallet), walletOwner);
    }

    function  deleteWallet(address payable wallet) external onlyOwner {
        uint256 index = walletToIndex[wallet];
        require(index != 0, "SwapWalletFactory: wallet is not in the walletList");
        if (index != wallets.length) {
            wallets[index - 1] = wallets[wallets.length - 1];
            walletToIndex[wallets[index - 1]] = index;
        }
        wallets.pop();
        delete(walletToIndex[wallet]);
        address walletOwner = walletToWalletOwner[wallet];
        uint256 ownerIndex = walletOwnerToIndex[walletOwner];
        if (ownerIndex != walletOwners.length) {
            walletOwners[ownerIndex - 1] = walletOwners[walletOwners.length - 1];
            walletOwnerToIndex[walletOwners[ownerIndex - 1]] = ownerIndex;
        }
        walletOwners.pop();
        delete(walletOwnerToIndex[walletOwner]);
        delete(walletToWalletOwner[wallet]);
        delete(walletOwnerToWallet[walletOwner]);
        emit SwapWalletDeleted(wallet, walletOwner);
    }

    function updateWallet(address payable wallet, address newWalletOwner) external onlyOwner {
        require(newWalletOwner != address(0), "SwapWalletFactory: newWalletOwner is the zero address");
        require(walletOwnerToIndex[newWalletOwner] == 0, "SwapWalletFactory: newWalletOwner already exists");
        address oldWalletOwner = walletToWalletOwner[wallet];
        require(oldWalletOwner != address(0), "SwapWalletFactory: wallet doesn't exist");
        delete(walletOwnerToWallet[oldWalletOwner]);

        uint oldOwnerIndex = walletOwnerToIndex[oldWalletOwner];
        walletOwners[oldOwnerIndex - 1] = newWalletOwner;
        walletOwnerToIndex[newWalletOwner] = oldOwnerIndex;

        walletToWalletOwner[wallet] = newWalletOwner;
        walletOwnerToWallet[newWalletOwner] = wallet;
        emit SwapWalletUpdated(wallet, oldWalletOwner, newWalletOwner);
    }

    function addWithdrawWhitelist(address addressToAdd) external onlyOwner returns(uint256) {
        require(addressToAdd != address(0), "SwapWalletFactory: new address is the zero address");
        uint256 index = whitelistAddressToIndex[addressToAdd];
        require(index == 0, "SwapWalletFactory: address is already in the whitelist");
        whitelistAddresses.push(addressToAdd);
        whitelistAddressToIndex[addressToAdd] = whitelistAddresses.length;
        emit WithdrawWhiteListAdded(addressToAdd);
        return whitelistAddresses.length;
    }

    function deleteWithdrawWhitelist(address addressToDelete) external onlyOwner returns(uint256) {
        uint256 index = whitelistAddressToIndex[addressToDelete];
        require(index != 0, "SwapWalletFactory: address is not in the whitelist");
        if (index != whitelistAddresses.length) {
            whitelistAddresses[index - 1] = whitelistAddresses[whitelistAddresses.length - 1];
            whitelistAddressToIndex[whitelistAddresses[index - 1]] = index;
        }
        whitelistAddresses.pop();
        delete whitelistAddressToIndex[addressToDelete];
        emit WithdrawWhiteListDeleted(addressToDelete);
        return index;
    }

    function addPairWhitelist(address[3][] calldata pairs) external onlyOwner returns(uint256) {
        uint len = pairs.length;
        for(uint i; i < len; ++i) {
            address router = pairs[i][0];
            address tokenA = pairs[i][1];
            address tokenB = pairs[i][2];
            require(tokenA != tokenB, 'SwapWalletFactory: identical addresses');
            (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
            require(router != address(0), 'SwapWalletFactory: zero address');
            require(token0 != address(0), 'SwapWalletFactory: zero address');
            require(token1 != address(0), 'SwapWalletFactory: zero address');
            require(whitelistPairToIndex[router][token0][token1] == 0, 'SwapWalletFactory: pair exists'); // single check is sufficient
            
            whitelistPairs.push([router, token0, token1]);
            whitelistPairToIndex[router][token0][token1] = whitelistPairs.length;
            emit PairWhiteListAdded(router, token0, token1);
        }
       
        return whitelistPairs.length;
    }

    function deletePairWhitelist(address[3][] calldata pairs) external onlyOwner returns(uint256) {
        uint len = pairs.length;
        for(uint i; i < len; ++i) {
            address router = pairs[i][0];
            address tokenA = pairs[i][1];
            address tokenB = pairs[i][2];
            require(tokenA != tokenB, 'SwapWalletFactory: identical addresses');
            (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
            uint256 index = whitelistPairToIndex[router][token0][token1];
            require(index != 0, 'SwapWalletFactory: pair not exists'); // single check is sufficient
            
            if (index != whitelistPairs.length) {
                whitelistPairs[index - 1] = whitelistPairs[whitelistPairs.length - 1];
                address router_ =  whitelistPairs[index - 1][0];
                address token0_ =  whitelistPairs[index - 1][1];
                address token1_ =  whitelistPairs[index - 1][2];
                whitelistPairToIndex[router_][token0_][token1_] = index;
            }
            whitelistPairs.pop();
            delete whitelistPairToIndex[router][token0][token1];
            emit PairWhiteListDeleted(router, token0, token1);
        }
        return whitelistPairs.length;
    }

    function withdraw(address assetAddress_, uint256 amount_, address toAddress_) external nonReentrant {
        require(amount_ > 0, "SwapWalletFactory: ZERO_AMOUNT");
        bool isWhitelistAddress = whitelistAddressToIndex[toAddress_] > 0 || walletToIndex[toAddress_] > 0;
        require(isWhitelistAddress, "SwapWalletFactory: withdraw to non whitelist address");
        bool hasPermission = msg.sender == _owner || walletOwnerToWallet[msg.sender] != address(0);
        require(hasPermission, "SwapWalletFactory: withdraw no permission");
        if (assetAddress_ == address(0)) {
            address self = address(this);
            uint256 assetBalance = self.balance;
            require(assetBalance >= amount_, "SwapWalletFactory: not enough balance");
            _safeTransferETH(toAddress_, amount_);
            emit WithdrawHappened(assetAddress_, amount_, toAddress_);
        } else {
            uint256 assetBalance = IERC20Upgradeable(assetAddress_).balanceOf(address(this));
            require(assetBalance >= amount_, "SwapWalletFactory: not enough balance");
            IERC20Upgradeable(assetAddress_).safeTransfer(toAddress_, amount_);
            emit WithdrawHappened(assetAddress_, amount_, toAddress_);
        }
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: safeMinGas, value: value}("");
        require(success, "SwapWalletFactory: transfer eth failed");
    }

    function applyGas(uint256 amount_) external nonReentrant {
        require(walletOwnerToWallet[msg.sender] != address(0), "SwapWalletFactory: apply gas from non wallet owner");
        require(amount_ <= applyGasLimit, "SwapWalletFactory: apply gas limit");
        require(amount_ > 0, "SwapWalletFactory: ZERO_AMOUNT");
        uint256 lastApplyTime = applyGasTime[msg.sender];
        require(lastApplyTime == 0 || block.timestamp - lastApplyTime > applyGasInterval, "SwapWalletFactory: apply gas interval");
        address self = address(this);
        uint256 assetBalance = self.balance;
        if (assetBalance >= amount_) {
            _safeTransferETH(msg.sender, amount_);
            applyGasTime[msg.sender] = block.timestamp;
            emit WithdrawHappened(address(0), amount_, msg.sender);
        }
    }

    function setApplyGasLimit(uint256 applyGasLimit_) external onlyOwner {
        require(applyGasLimit_ <= 10000000000000000000, "SwapWalletFactory: TOO_LARGE");
        uint256 oldLimit = applyGasLimit;
        applyGasLimit = applyGasLimit_;
        emit ApplyGasLimitUpdated(oldLimit, applyGasLimit_);

    }

    function setApplyGasInterval(uint256 applyGasInterval_) external onlyOwner {
        require(applyGasInterval_ >= 3600, "SwapWalletFactory: TOO_SMALL");
        require(applyGasInterval_ <= 604800, "SwapWalletFactory: TOO_LARGE");
        uint256 oldInterval = applyGasInterval;
        applyGasInterval = applyGasInterval_;
        emit ApplyGasIntervalUpdated(oldInterval, applyGasInterval_);
    }

    function getWalletImplementationAddress() external view returns (address) {
        return walletImplementationAddress;
    }

    function setWalletImplementationAddress(address newWalletImplementationAddress) external onlyOwner {
        require(newWalletImplementationAddress != address(0), "SwapWalletFactory: zero address");
        emit WalletImplementationAddressUpdated(walletImplementationAddress, newWalletImplementationAddress);
        walletImplementationAddress = newWalletImplementationAddress;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IUniRouter {
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}