/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;
// File @openzeppelin/contracts/utils/[email protected]
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// File @openzeppelin/contracts/access/[email protected]
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
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


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]
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


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]
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


// File @openzeppelin/contracts/token/ERC20/[email protected]
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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


// File @openzeppelin/contracts/utils/[email protected]
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)
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


// File @uniswap/v2-core/contracts/interfaces/[email protected]
interface IUniswapV2ERC20 {
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
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]
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


// File @openzeppelin/contracts/security/[email protected]
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)
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
}


// File contracts/utility/Permissions.sol
/**
 * @title A generic permissions-management contract for Hello.
 *
 */
contract Permissions is Context, Ownable {
    /// Accounts permitted to modify rules.
    mapping(address => bool) public appAddresses;

    modifier onlyApp() {
        require(appAddresses[_msgSender()] == true, "Caller is not admin");
        _;
    }

    constructor() {}

    function setPermission(address account, bool permitted)
        external
        onlyOwner
    {
        appAddresses[account] = permitted;
    }
}


// File contracts/inventory/Bugs.sol
/**
 * @title An ERC-20 contract for Hello.
 *
 * @dev All token amounts in Wei.
 *
 */
contract Hello is IERC20, Permissions {
    using Address for address;

    address private _token;

    ////
    //// ERC20
    ////

    string public name;
    string public symbol;

    uint8 public decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /// Emitted when new tokens are minted.
    event Mint(address indexed account, uint256 indexed amount);

    ////
    //// LP
    ////

    /// @dev Used for approval.
    IUniswapV2Router02 public router;
    /// @dev Used for transfer.
    address public pair;

    /// Prevents collision of multiple concurrent calls to swap and liquify.
    uint256 public swapAndLiquifyTrigger;
    bool private _inSwapAndLiquify;
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    /// Token and ETH added to LP.
    event SwapAndLiquify(uint256 tokenIntoLiquidity, uint256 ethIntoLiquidity);

    ////
    //// TOKENOMICS: LIMITS
    ////

    /// @dev Amount of tokens, in Wei.
    uint256 public maxTransfer;
    /// @dev Amount of tokens, in Wei.
    uint256 public maxWallet;

    address[] public maxExempt;
    mapping(address => bool) public _isMaxExempt;

    ////
    //// TOKENOMICS: FEES
    ////

    address[] public feePayers;
    mapping(address => bool) public isFeePayer;

    address[] public feeReceivers;
    mapping(address => uint8) private _feeReceiversAndRates;

    address public stablecoin;
    mapping(address => bool) public receivesStablecoin;

    ////
    //// WHITELIST
    ////

    bool public whitelistEnabled;
    mapping(address => uint256) public whitelistBalance;

    ////
    //// BLACKLIST
    ////

    address[] public blacklist;
    mapping(address => bool) public isBlacklisted;

    ////
    //// INIT
    ////

    /**
     * Deploy contract.
     */
    constructor() {
        _token = address(this);

        // ERC20.

        name = "Hello";
        symbol = "Hello";
        decimals = 18;
        _totalSupply = 10000000 * (10 ** decimals); // 10m

        // LP.

        // router = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506); // Arbitrum One SushiSwap router.
        // router = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506); // Goerli SushiSwap router.
        router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // BSC Testnet Pancakeswap router.
        // router = IUniswapV2Router02(0xab7664500b19a7a2362Ab26081e6DfB971B6F1B0); // Arbitrum Goerli
        pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        swapAndLiquifyTrigger = _totalSupply / 1000;

        // Tokenomics: limits.

        maxTransfer = _totalSupply / 100;
        maxWallet = _totalSupply / 100;

        // Tokenomics: fees.

        // stablecoin = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8; // Arbitrum One USDC
        // stablecoin = 0x55a309598ABf543bF76FbB22859938ba2F29C2eA; // Goerli DAI
        stablecoin = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // BSC Testnet BUSD
        // stablecoin = 0x42437026bD32BC07914dc1FB35B8009805277915; // Arbitrum Goerli

        // Whitelist.
        whitelistEnabled = true;

        // Initial mint.

        _balances[owner()] += _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    ////
    //// ERC20
    ////

    /**
     * Get current supply of tokens, in Wei.
     *
     * @return uint256 of _totalSupply.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * Get amount of tokens owned by `account`, in Wei.
     *
     * @param account as address to check.
     * @return uint256 as the amount of tokens.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * Standardized mint wrapper for App's yielding contracts.
     *
     * @dev id param is included so app contracts have consistent mint interface,
     * @dev regardless of whether minted token is ERC20 or ERC1155.
     *
     * @param to as the address to assign the tokens to.
     * @param id not applicable here, as ERC20 has no ID.
     * @param amount of tokens to mint.
     */
    function mint(address to, uint256 id, uint256 amount)
        external
        onlyApp
    {
        _mint(to, amount);
    }

    /**
     * Mint `amount` of tokens to `account`.
     *
     * @param account as the address to assign the tokens to.
     * @param amount as the amount of tokens to create.
     */
    function _mint(address account, uint256 amount) private {
        require(account != address(0), "Invalid account");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Mint(account, amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * Burn `amount` of `account`'s tokens.
     *
     * @dev Only authorized callers.
     *
     * @param account as the address to burn from.
     * @param amount of tokens to burn.
     */
    function burn(address account, uint256 amount) external onlyApp {
        _burn(account, amount);
    }

    /**
     * Transfers `amount` of tokens from `account` to the zero address.
     *
     * @param account as the address to take the tokens from.
     * @param amount as the amount of tokens to burn.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "Invalid account");

        require(_balances[account] >= amount, "Insufficient balance");
        unchecked {
            _balances[account] -= amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    ////
    //// ALLOWANCES
    ////

    /**
     * Get max amount of `owner` tokens that `spender` can move with transferFrom.
     *
     * @param owner as address of account owning tokens.
     * @param spender as address of account moving tokens.
     *
     * @return uint256 as max amount of tokens able to be transferred.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * Set max amount of caller's tokens that `spender` can move with transferFrom.
     *
     * @param spender as address of account moving tokens.
     * @param amount as the amount of tokens allowed to be transferred.
     *
     * @return bool on success.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * Set max amount of `owner` tokens that `spender` can move with transferFrom.
     *
     * @param owner as address of token owner.
     * @param spender as address of account moving tokens.
     * @param amount as the amount of tokens allowed to be transferred.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * Update `owner`'s allowance for `spender` based on spent `amount`.
     *
     * @dev Does not update the allowance amount in case of infinite allowance.
     * @dev Revert if not enough allowance is available.
     *
     * @param owner as address of token owner.
     * @param spender as address of account moving tokens.
     * @param amount as the amount of tokens allowed to be transferred.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    ////
    //// TRANSFERS
    ////

    /**
     * Transfer tokens from caller to `to`.
     *
     * @param to as address of receiver.
     * @param amount of tokens.
     *
     * @return bool on success.
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * Transfer `amount` of tokens from `from` to `to`.
     *
     * @dev `from` has to have approved caller to spend `amount`.
     *
     * @param from as address of sender.
     * @param to as address of receiver.
     * @param amount of tokens.
     *
     * @return bool on success.
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * Determine the context of this transfer.
     *
     * @param from address of sender.
     * @param to address of receiver.
     * @param amount tokens being transferred.
     */
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0) && to != address(0), "Transfer with zero address");
        require(amount <= _balances[from], "Insufficient funds");
        require(!isBlacklisted[from] && !isBlacklisted[to], "Blacklisted account");

        // Check max limits.
        if (!_isMaxExempt[from]) { // Non-exempt senders cannot send more than maxTransfer.
            require(amount <= maxTransfer, "Exceeds max tx");
        }
        if (!_isMaxExempt[to]) { // Non-exempt receivers cannot exceed maxWallet if the sender is non-exempt too.
            require(_balances[to] + amount <= maxWallet, "Exceeds max wallet");
        }

        // Check whitelist.
        if (whitelistEnabled) {
            require(from == pair, "Only LP can send during whitelist");
            require(whitelistBalance[to] > 0, "No whitelist balance available");
            whitelistBalance[to] -= amount;
        }

        // Check LP contribution.
        if (!_inSwapAndLiquify // Avoid circular liquidity event.
            && isFeePayer[to] // Only on token sales.
            && swapAndLiquifyTrigger > 0 // Swap and liquify enabled.
            && _balances[_token] >= swapAndLiquifyTrigger // Contract's balance of token > trigger.
        ) {
            _swapAndLiquify(swapAndLiquifyTrigger);
        }

        // Check fee requirement, then transfer.
        if (from != _token && (isFeePayer[from] || isFeePayer[to])) {
            _transferWithFees(from, to, amount);
        }
        else {
            _transferWithoutFees(from, to, amount);
        }
    }

    /**
     * Transfer tokens and take fees.
     *
     * @dev Balance changes are checked in _transfer.
     *
     * @param from address of sender.
     * @param to address of receiver.
     * @param amount of tokens being transferred.
     */
    function _transferWithFees(address from, address to, uint256 amount) private {
        uint256 amountMinusFees = _takeFees(from, to, amount);
        unchecked {
            _balances[from] -= amountMinusFees;
            _balances[to] += amountMinusFees;
        }
        emit Transfer(from, to, amountMinusFees);
    }

    /**
     * Transfer tokens and don't take fees.
     *
     * @dev Balance changes are checked in _transfer.
     *
     * @param from address of sender.
     * @param to address of receivers.
     * @param amount of tokens being transferred.
     */
    function _transferWithoutFees(address from, address to, uint256 amount) private {
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    /**
     * Move fees from transferred amount to fee receivers.
     *
     * @param from address of sender.
     * @param to address of receiver.
     * @param amount quantity of tokens being transferred.
     *
     * @return uint256 amount to transfer after fees.
     */
    function _takeFees(address from, address to, uint256 amount) private returns (uint256) {
        uint256 amountMinusFees = amount;
        uint256 feeReceiversLength = feeReceivers.length;

        for (uint8 i = 0; i < feeReceiversLength; i++) {
            uint256 fee = amount * _feeReceiversAndRates[feeReceivers[i]] / 100;
            amountMinusFees -= fee;
            _balances[from] -= fee;

            // Stablecoin receiver gets stablecoin on token sale.
            if (receivesStablecoin[feeReceivers[i]] && isFeePayer[to]) {
                uint256 eth = _swapTokenForETH(fee);
                _swapETHForToken(eth, stablecoin, feeReceivers[i]);
            }
            else { // Otherwise fee is in token.
                _balances[feeReceivers[i]] += fee;
                emit Transfer(from, feeReceivers[i], fee);
            }
        }

        return amountMinusFees;
    }

    ////
    //// LP
    ////

    /**
     * Add liquidity to the LP pool.
     *
     * @dev approve is called to ensure that the router is able to call transferFrom.
     *
     * @param tokenAmount quantity of token to transfer.
     * @param ethAmount quantity of ETH to transfer.
     */
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(_token, address(router), tokenAmount);

        router.addLiquidityETH{value: ethAmount}(
            _token,         // address token
            tokenAmount,    // uint amountTokenDesired
            0,              // uint amountTokenMin
            0,              // uint amountETHMin
            owner(),        // address to
            block.timestamp // uint deadline
        );
    }

    /**
     * Set the quantity of token at which _swapAndLiquify should be called.
     *
     * @dev Disable swap and liquify by setting trigger to 0.
     *
     * @param trigger quantity of token at which to swap and liquify.
     */
    function setSwapAndLiquifyTrigger(uint256 trigger) external onlyOwner {
        require(trigger > 0 && trigger < _totalSupply, "Set from 0 to totalSupply");
        swapAndLiquifyTrigger = trigger;
    }

    /**
     * Sell half of the contract's token for ETH, and add both to the LP pool.
     *
     * @param amount of token to split, swap half of, and add to LP pool.
     */
    function _swapAndLiquify(uint256 amount) private lockTheSwap {
        uint256 tokenHalf = amount / 2;
        uint256 ethHalf = amount - tokenHalf;
        uint256 ethReceived = _swapTokenForETH(ethHalf);
        _addLiquidity(tokenHalf, ethReceived);
        emit SwapAndLiquify(tokenHalf, ethReceived);
    }

    /**
     * Sell ETH to buy ERC20 token.
     *
     * @param ethAmount quantity of ETH to sell.
     * @param token address of token to buy.
     * @param receiver address to send the token to.
     */
    function _swapETHForToken(uint256 ethAmount, address token, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = token;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // uint amountOutMin
            path, // address[] path
            receiver, // address to
            block.timestamp + 300 // uint deadline
        );
    }

    /**
     * Sell token to buy ETH.
     *
     * @param tokenAmount quantity of token to sell.
     *
     * @return uint256 amount of ETH from swap.
     */
    function _swapTokenForETH(uint256 tokenAmount) private returns (uint256) {
        uint256 initBalance = _token.balance;
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = router.WETH();

        _approve(_token, address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, // uint amountIn
            0, // uint amountOutMin
            path, // address[] path
            _token, // address to
            block.timestamp // uint deadline
        );

        return _token.balance - initBalance;
    }

    ////
    //// Tokenomics: limits
    ////

    /**
     * Set token transfer and ownership limits.
     *
     * @dev Set exemptions from these limits with setMaxLimitsExempt.
     *
     * @param maxTransfer_ max amount of transferrable tokens.
     * @param maxWallet_ max amount of tokens in an account.
     */
    function setMaxLimits(uint256 maxTransfer_, uint256 maxWallet_) external onlyOwner {
        require(
            maxTransfer_ >= 0
            && maxTransfer_ <= totalSupply()
            && maxWallet_ >= 0
            && maxWallet_ <= totalSupply(),
            "Set from 0 to total supply."
        );
        maxTransfer = maxTransfer_;
        maxWallet = maxWallet_;
    }

    /**
     * Set list of addresses exempt from the max transfer and wallet limits.
     *
     * @dev Overwrites existing exemptions.
     *
     * @param accounts list of exempt accounts.
     */
    function setMaxLimitsExempt(address[] memory accounts) external onlyOwner {
        // Clear current exemptions mapping.
        for (uint8 i = 0; i < maxExempt.length; i++)
            _isMaxExempt[maxExempt[i]] = false;
        // Update exemptions list.
        maxExempt = accounts;
        // Set new exemptions mapping.
        for (uint8 i = 0; i < accounts.length; i++)
            _isMaxExempt[accounts[i]] = true;
    }

    ////
    //// Tokenomics: fees ///
    ////

    /**
     * Get the fee rate for a given fee receiver.
     *
     * @param receiver address of receiver to query.
     *
     * @return uint8 percent fee rate.
     */
    function getFeeRate(address receiver) external view returns (uint8) {
        return _feeReceiversAndRates[receiver];
    }

    /**
     * Set fee receivers and rates for fee-paying transfers.
     *
     * @dev Address at feeReceivers[i] receives rate at feeRates[i]).
     * @dev Overwrites existing fee receivers and rates.
     *
     * @param feeReceivers_ addresses of fee-receivers.
     * @param feeRates percent fees for each receiver.
     */
    function setFeeReceiversAndRates(address payable[] memory feeReceivers_, uint8[] memory feeRates) external onlyOwner {
        require(feeReceivers_.length == feeRates.length, "Array lengths must match");
        // Clear current receivers mapping.
        for (uint8 i = 0; i < feeReceivers.length; i++)
            _feeReceiversAndRates[feeReceivers[i]] = 0;
        // Update receivers list.
        feeReceivers = feeReceivers_;
        // Count new fees.
        uint8 totalFees = 0;
        // Set new receivers mapping.
        for (uint8 i = 0; i < feeReceivers_.length; i++) {
            require(feeReceivers_[i] != address(0), "Transfer to address(0)");
            _feeReceiversAndRates[feeReceivers_[i]] = feeRates[i];
            totalFees += feeRates[i];
        }
        // Check validity of new fees.
        require(totalFees >= 0 && totalFees <= 100, "Set fees from 0 to 100");
    }

    /**
     * Set ERC20 token to be used for stablecoin fee receivers.
     *
     * @param stablecoin_ address of ERC20 token.
     */
    function setStablecoin(address stablecoin_) external onlyOwner {
        stablecoin = stablecoin_;
    }

    /**
     * Set whether an account should receive fees in stablecoins.
     *
     * @dev account must already be a fee receiver.
     *
     * @param account address of fee receiver.
     * @param _receivesStablecoin true for stablecoin, false for token.
     */
    function setStablecoinReceiver(address account, bool _receivesStablecoin) external onlyOwner {
        require(_feeReceiversAndRates[account] != 0, "Not a fee receiver");
        receivesStablecoin[account] = _receivesStablecoin;
    }

    /**
     * Set the fee payers.
     *
     * @dev Overwrites existing fee-payer list.
     *
     * @param accounts list of fee-paying addresses.
     */
    function setFeePayers(address[] memory accounts) external onlyOwner {
        // Clear current payers mapping.
        for (uint8 i = 0; i < feePayers.length; i++)
            isFeePayer[feePayers[i]] = false;
        // Update payers list.
        feePayers = accounts;
        // Set new payers mapping.
        for (uint8 i = 0; i < accounts.length; i++)
            isFeePayer[accounts[i]] = true;
    }

    ////
    //// WHITELIST
    ////

    /**
     * Enable or disable whitelist check before allowing a transfer.
     */
    function toggleWhitelist() external onlyOwner {
        whitelistEnabled = !whitelistEnabled;
    }

    /**
     * Toggle  an account to the transfer whitelist.
     *
     * @param account as address.
     */
    function addToWhitelist(address account) external onlyApp {
        whitelistBalance[account] = maxWallet;
    }

    ////
    //// BLACKLIST
    ////

    /**
     * Set list of accounts blocked from transfers.
     * @dev Overwrites existing blacklist.
     * @param accounts addresses to blacklist.
     */
    function setBlacklist(address[] memory accounts) external onlyOwner {
        // Clear current blacklist mapping.
        for (uint8 i = 0; i < blacklist.length; i++)
            isBlacklisted[blacklist[i]] = false;
        // Update blacklist list.
        blacklist = accounts;
        // Set new blacklist mapping.
        for (uint8 i = 0; i < accounts.length; i++)
            isBlacklisted[accounts[i]] = true;
    }

    ////
    //// INTERNAL BALANCES
    ////

    /**
     * Fallback function.
     *
     * @dev Receives ETH from router when swapping.
     */
    receive() external payable {}

    /**
     * Withdraw ETH to owner.
     *
     * @param amount quantity of ETH to withdraw.
     */
    function recoverETH(uint256 amount) external payable onlyOwner {
        (bool success, ) = payable(owner()).call{value: amount}('');
        require(success, 'Transfer failed.');
    }

    /**
     * Withdraw ERC20 token to owner.
     *
     * @param token address of token to withdraw.
     * @param amount of tokens to withdraw.
     */
    function recoverToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }
}