// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./SwapWalletFactory.sol";
import "./IWETH.sol";
import "./IUniRouter.sol";
import "./ICurveCrypto.sol";

contract SwapWallet is Initializable, ReentrancyGuardUpgradeable {

    uint128 constant MAX_FACTORY_COINS = 8;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    
    address private _owner;
    address private _pendingOwner;

    SwapWalletFactory private factory;

    IWETH private WETH;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);
    event WithdrawHappened(address indexed assetAddress, uint256 amount, address indexed toAddress);

    function initialize(address owner_, SwapWalletFactory factory_) public initializer{ 
        __SwapWallet_init(owner_, factory_);
    }

    function __SwapWallet_init(address owner_, SwapWalletFactory factory_) internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
        __SwapWallet_init_unchained(owner_, factory_);
    }

    function __SwapWallet_init_unchained(address owner_, SwapWalletFactory factory_) internal onlyInitializing {
        require(owner_ != address(0), "SwapWallet: owner is the zero address");

        _owner = owner_;
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
        (bool success, ) = to.call{ value: value}("");
        require(success, "SwapWallet: transfer eth failed");
    }

    function verifyExchange(address router, address from, address to) internal view {
        (address token0, address token1) = from < to ? (from, to) : (to, from);
        require(factory.whitelistPairToIndex(router, token0, token1) > 0, "SwapWallet: cannot swap non-whitelisted pair");
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

    function swapCurveExchange(
        address pool,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 from,
        uint256 to
    ) external nonReentrant onlyOwner {
        address addr_from = ICurveCrypto(pool).coins(from);
        address addr_to = ICurveCrypto(pool).coins(to);
        verifyExchange(pool, addr_from, addr_to);
        IERC20Upgradeable fromToken = IERC20Upgradeable(addr_from);
        fromToken.safeIncreaseAllowance(address(pool), amountIn);
        int128 from_int = SafeCast.toInt128(SafeCast.toInt256(from));
        int128 to_int = SafeCast.toInt128(SafeCast.toInt256(to));
        ICurveCrypto(pool).exchange(from_int, to_int, amountIn, amountOutMin);
    }

    function swapCurveV2Exchange(
        address pool,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 from,
        uint256 to
    ) external nonReentrant onlyOwner {
        address[MAX_FACTORY_COINS] memory addrs = ICurveFactory(factory.curveFactory()).get_underlying_coins(pool);
        address addr_from = addrs[from];
        address addr_to = addrs[to];
        require(addr_from != address(0) && addr_to != address(0), "SwapWallet: FROM or TO zero address");
        verifyExchange(pool, addr_from, addr_to);
        IERC20Upgradeable(addr_from).safeIncreaseAllowance(address(pool), amountIn);
        int128 from_int = SafeCast.toInt128(SafeCast.toInt256(from));
        int128 to_int = SafeCast.toInt128(SafeCast.toInt256(to));
        ICurveCryptoV2(pool).exchange_underlying(from_int, to_int, amountIn, amountOutMin);
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

    function findPool(address from, address to) external view returns(address) {
        return ICurveFactory(factory.curveFactory()).find_pool_for_coins(from, to);
    }

    function getUnderlyingCoins(address pool) external view returns(address[MAX_FACTORY_COINS] memory) {
        return ICurveFactory(factory.curveFactory()).get_underlying_coins(pool);
    }

    function getUnderlyingDecimals(address pool) external view returns(uint256[MAX_FACTORY_COINS] memory) {
        return ICurveFactory(factory.curveFactory()).get_underlying_decimals(pool);
    }

    function getUnderlyingBalances(address pool) external view returns(uint256[MAX_FACTORY_COINS] memory) {
        return ICurveFactory(factory.curveFactory()).get_underlying_balances(pool);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import './SwapWallet.sol';
import './SwapWalletBeaconProxy.sol';




contract SwapWalletFactory is Initializable, ReentrancyGuardUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address private _owner;
    address private _pendingOwner;

    address public WETH;

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

    address private beaconAddress;

    address public curveFactory;

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
    event BeaconAddressUpdated(address indexed previousImplementation, address indexed newImplementation);
    event CurveFactoryUpdated(address indexed previousFactory, address indexed newFactory);

        
    function initialize(address owner_, address WETH_, uint applyGasLimit_, uint applyGasInterval_) public initializer{
        __SwapWalletFactory_init(owner_, WETH_, applyGasLimit_, applyGasInterval_);
    }

    function __SwapWalletFactory_init(address owner_, address WETH_, uint applyGasLimit_, uint applyGasInterval_) internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
        __SwapWalletFactory_init_unchained(owner_, WETH_, applyGasLimit_, applyGasInterval_);
    }

    function __SwapWalletFactory_init_unchained(address owner_, address WETH_, uint applyGasLimit_, uint applyGasInterval_) internal onlyInitializing {
        require(owner_ != address(0), "SwapWalletFactory: owner is the zero address");
        require(WETH_ != address(0), "SwapWalletFactory: weth is the zero address");
        _owner = owner_;
        WETH = WETH_;
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
        SwapWallet wallet = SwapWallet(payable(new SwapWalletBeaconProxy(beaconAddress, "")));
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
        (bool success, ) = to.call{value: value}("");
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
            applyGasTime[msg.sender] = block.timestamp;
            _safeTransferETH(msg.sender, amount_);
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

    function getBeaconAddress() external view returns (address) {
        return beaconAddress;
    }

    function setBeaconAddress(address newBeaconAddress) external onlyOwner {
        require(newBeaconAddress != address(0), "SwapWalletFactory: zero address");
        require(newBeaconAddress != beaconAddress, "SwapWalletFactory: same address");
        emit BeaconAddressUpdated(beaconAddress, newBeaconAddress);
        beaconAddress = newBeaconAddress;
    }

    function setCurveFactory(address factory) external onlyOwner {
        require(factory != address(0), "SwapWalletFactory: zero address");
        curveFactory = factory;
        emit CurveFactoryUpdated(curveFactory, factory);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface ICurveCrypto {
    function coins(uint256 n) external view returns(address);
    function exchange(int128 from, int128 to, uint256 from_amount, uint256 min_to_amount) external;
}

interface ICurveCryptoV2 {
    function coins(uint256 n) external view returns(address);
    function exchange_underlying(int128 from, int128 to, uint256 from_amount, uint256 min_to_amount) external;
    
}

interface ICurveFactory {
    function find_pool_for_coins(address from, address to) external view returns(address);
    function get_underlying_coins(address pool) external view returns(address[8] memory);
    function get_underlying_decimals(address pool) external view returns(uint256[8] memory);
    function get_underlying_balances(address pool) external view returns(uint256[8] memory);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract SwapWalletBeaconProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) payable {

    }
    receive() override external payable {  // Need this to make convertFromWETH in SwapWallet work
            // React to receiving ether
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}