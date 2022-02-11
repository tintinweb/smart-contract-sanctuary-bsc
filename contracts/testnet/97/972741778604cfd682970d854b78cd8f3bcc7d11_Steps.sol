/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: UNLICENSED & MIT

// File: contracts/interfaces/IBEP20.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the BEP20 standard.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// File: contracts/interfaces/IBEP20Metadata.sol

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the BEP20 standard.
 */
interface IBEP20Metadata is IBEP20 {
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

// File: contracts/interfaces/ApproveAndCallFallBack.sol

pragma solidity ^0.8.0;

interface ApproveAndCallFallBack {
    function receiveApproval(address _from, uint256 _amount, bytes calldata _data) external;
}

// File: openzeppelin-solidity/contracts/utils/Context.sol

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

// File: contracts/libraries/SafeMath.sol

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/utils/Address.sol

// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// File: openzeppelin-solidity/contracts/access/Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
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

// File: openzeppelin-solidity/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
        return !Address.isContract(address(this));
    }
}

// File: contracts/interfaces/IPancakeV2Factory.sol

pragma solidity ^0.8.0;

interface IPancakeV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// File: contracts/interfaces/IPancakeV2Router.sol

pragma solidity ^0.8.0;

interface IPancakeV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: contracts/Steps.sol

pragma solidity ^0.8.0;







//import 'openzeppelin-solidity/contracts/security/Pausable.sol';




abstract contract Manageable is Context {
    address private _manager;

    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    constructor() {
        address msgSender = _msgSender();
        _manager = msgSender;

        emit ManagementTransferred(address(0), msgSender);
    }

    function manager() public view returns (address) {
        return _manager;
    }

    modifier onlyManager() {
        require(_manager == _msgSender(), "Manageable: caller is not the manager");
        _;
    }

    function transferManagement(address newManager) external virtual onlyManager {
        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;
    }
}

/**
 * @dev This defines the `Tokenomics` and we need to set and configure the actual name of the contract
 * `StepsTokenV1` at the very bottom **and** the `environment` into which we are deploying the contract
 * `StepsToken(Env.Testnet)` or `StepsToken(Env.MainnetV2)` etc.
 *
 * To disable a particular tax/fee just set it to zero (or comment it out/remove it).
 *
 * You can add (in theory) as many custom taxes/fees with dedicated wallet addresses if you want.
 * Nevertheless, I do not recommend using more than a few as the contract has not been tested
 * for more than the original number of taxes/fees, which is 6 (liquidity, redistribution, burn,
 * marketing, charity & tip to the dev). Furthermore, exchanges may impose a limit on the total
 * transaction fee (so that, for example, you cannot claim 100%). Usually this is done by limiting the
 * max value of slippage, for example, PancakeSwap max slippage is 49.9% and the fees total of more than
 * 35% will most likely fail there.
 */
abstract contract Tokenomics {
    using SafeMath for uint256;

    // --------------------- Token Configuration Settings ------------------- //
    string internal constant NAME = "12Steps";
    string internal constant SYMBOL = "STEPS";

    uint16 internal constant FEES_DIVISOR = 10 ** 3;
    uint8 internal constant DECIMALS = 18;
    uint256 internal constant ZEROES = 10 ** DECIMALS;

    bool internal constant MINTABLE = true;

    uint256 private constant MAX = ~uint256(0);
    uint256 internal constant TOTAL_SUPPLY = 1278377046 * ZEROES;
    uint256 internal _reflectedSupply = (MAX - (MAX % TOTAL_SUPPLY));

    /**
     * @dev Set the maximum transaction amount allowed in a transfer.
     *
     * The default value is 1% of the total supply.
     *
     * NOTE: set the value to `TOTAL_SUPPLY` to have an unlimited max, i.e.
     * `maxTransactionAmount = TOTAL_SUPPLY;`.
     */
    uint256 internal constant maxTransactionAmount = TOTAL_SUPPLY / 1000; // 0.1% of the total supply

    /**
     * @dev Set the maximum allowed balance in a wallet.
     *
     * The default value is 2% of the total supply.
     *
     * NOTE: set the value to 0 to have an unlimited max.
     *
     * IMPORTANT: This value MUST be greater than `numberOfTokensToSwapToLiquidity` set below,
     * otherwise the liquidity swap will never be executed.
     */
    uint256 internal constant maxWalletBalance = TOTAL_SUPPLY / 50; // 2% of the total supply

    /**
     * @dev Set the number of tokens to swap and add to liquidity.
     *
     * Whenever the contract's balance reaches this number of tokens, swap & liquify will be
     * executed in the very next transfer (via the `_beforeTokenTransfer`)
     *
     * If the `FeeType.Liquidity` is enabled in `FeesSettings`, the given % of each transaction will be first
     * sent to the contract address. Once the contract's balance reaches `numberOfTokensToSwapToLiquidity` the
     * `swapAndLiquify` of `Liquifier` will be executed. Half of the tokens will be swapped for ETH
     * (or BNB on BSC) and together with the other half converted into a Token-ETH/Token-BNB LP Token.
     *
     * See: `Liquifier`
     */
    uint256 internal constant numberOfTokensToSwapToLiquidity = TOTAL_SUPPLY / 10000; // 0.01% of the total supply

    // --------------------- Fee Settings ------------------- //

    /**
     * @dev Owner and Proxy Admin wallet addresses.
     */
    address internal ownerAddress = 0xD3bA7ae4132683b4084526c5E26A0f2e7AA190bc;
    address internal proxyAddress = 0x2cd461d44877D89AE00e4d414931C3CA78C4f4a3;

    /**
     * @dev Marketing and Charity wallet addresses.
     */
    address internal charityAddress = 0xB285fA21D7eCC82988809B95f44b998722B3B9E3;
    address internal marketingAddress = 0x616645d986d7EEe64eC7b45D379D87e95817Ef56;

    /**
     * @dev This collects tips for the development team to be used for the
     * ongoing development of the project. We will also be tipping the
     * original developer who rewrote this smart contract to his address,
     * 0x2d67D0A35192EB8cE9DF4988686553360A6E424f, when we have some funds
     * to make a meaningful contribution.
     */
    address internal devWallet = 0xcb5528e27D49eA5576936978dF8D838292633a47;

    /**
     * @dev You can change the value of the burn address to pretty much anything
     * that's (clearly) a non-random address, i.e. for which the probability of
     * someone having the private key is (virtually) 0. For example, 0x00.....1,
     * 0x111...111, 0x12345.....12345, etc.
     *
     * NOTE: This does NOT need to be the zero address, address(0) = 0x000...000;
     *
     * Transferring tokens to the burn address is good for optics/marketing. Nevertheless
     * if the burn address is excluded from rewards (unlike in Safemoon), sending tokens
     * to the burn address actually improves redistribution to holders as they will
     * have a larger % of tokens in non-excluded accounts.
     *
     * The address below is the speed of light in vacuum in m/s (expressed in decimals),
     * the hex value is 0x0000000000000000000000000000000011dE784A.
     *
     * Here are the values of some other fundamental constants to use:
     * 0x0000000000000000000000000000000602214076 (Avogardo constant)
     * 0x0000000000000000000000000000000001380649 (Boltzmann constant)
     * 0x2718281828459045235360287471352662497757 (e)
     * 0x0000000000000000000000000000001602176634 (elementary charge)
     * 0x0000000000000000000000000200231930436256 (electron g-factor)
     * 0x0000000000000000000000000000091093837015 (electron mass)
     * 0x0000000000000000000000000000137035999084 (fine structure constant)
     * 0x0577215664901532860606512090082402431042 (Euler-Mascheroni constant)
     * 0x1618033988749894848204586834365638117720 (golden ratio)
     * 0x0000000000000000000000000000009192631770 (hyperfine transition fq)
     * 0x0000000000000000000000000000010011659208 (muom g-2)
     * 0x3141592653589793238462643383279502884197 (pi)
     * 0x0000000000000000000000000000000662607015 (Planck's constant)
     * 0x0000000000000000000000000000001054571817 (reduced Planck's constant)
     * 0x1414213562373095048801688724209698078569 (sqrt(2))
     */
    address internal burnAddress = 0x0000000000000000000000000000000299792458;

    enum FeeType {Antiwhale, Burn, Liquidity, Rfi, External, ExternalToETH}
    struct Fee {
        FeeType name;
        uint256 value;
        address recipient;
        uint256 total;
    }

    Fee[] internal fees;
    uint256 internal sumOfFees;

    constructor() {
        _addFees();
    }

    function _addFee(FeeType name, uint256 value, address recipient) private {
        fees.push(Fee(name, value, recipient, 0));
        sumOfFees += value;
    }

    function _addFees() private {
        /**
         * The RFI recipient is ignored but we need to give a valid address value.
         *
         * The value of fees is given in part per 1000 (based on the value of FEES_DIVISOR),
         * e.g. for 5% use 50, for 3.5% use 35, etc.
         */
        _addFee(FeeType.Rfi, 40, address(this));
        _addFee(FeeType.Burn, 10, burnAddress);
        _addFee(FeeType.Liquidity, 50, address(this));
        _addFee(FeeType.External, 20, charityAddress);
        _addFee(FeeType.External, 30, marketingAddress);
        // 0.1% as a tip to the dev.
        _addFee(FeeType.ExternalToETH, 1, devWallet);
    }

    function _getFeesCount() internal view returns (uint256) {
        return fees.length;
    }

    function _getFeeStruct(uint256 index) private view returns (Fee storage) {
        require(index >= 0 && index < fees.length, "_getFeeStruct: Index out of bounds");
        return fees[index];
    }

    function _getFee(uint256 index) internal view returns (FeeType, uint256, address, uint256) {
        Fee memory fee = _getFeeStruct(index);
        return (fee.name, fee.value, fee.recipient, fee.total);
    }

    function _addFeeCollectedAmount(uint256 index, uint256 amount) internal {
        Fee storage fee = _getFeeStruct(index);
        fee.total = fee.total.add(amount);
    }

    // function getCollectedFeeTotal(uint256 index) external view returns (uint256) {
    function getCollectedFeeTotal(uint256 index) internal view returns (uint256) {
        Fee memory fee = _getFeeStruct(index);
        return fee.total;
    }
}

abstract contract Presaleable is Manageable {
    bool internal isInPresale;

    function setPresaleableEnabled(bool value) external onlyManager {
        isInPresale = value;
    }
}

abstract contract BaseRfiToken is IBEP20, IBEP20Metadata, Ownable, Presaleable, Tokenomics, Initializable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) internal _reflectedBalances;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    mapping(address => bool) internal _isExcludedFromFee;
    mapping(address => bool) internal _isExcludedFromRewards;
    address[] private _excluded;

//    constructor() {
//        _reflectedBalances[owner()] = _reflectedSupply;
//
//        // Exclude owner and this contract from fee.
//        _isExcludedFromFee[owner()] = true;
//        _isExcludedFromFee[address(this)] = true;
//
//        // Exclude the owner and this contract from rewards.
//        _exclude(owner());
//        _exclude(address(this));
//
//        emit Transfer(address(0), owner(), TOTAL_SUPPLY);
//    }
    /**
     * @dev sets initials supply and the owner
     */
    function initialize() public initializer virtual {
//    function initialize(string memory name, string memory symbol, uint8 decimals, uint256 amount, bool mintable, address owner, uint256 _reflectedBalances, bool _isExcludedFromFee) public initializer {
//        _owner = owner;
//        _name = name;
//        _symbol = symbol;
//        _decimals = decimals;
//        _mintable = mintable;
//        _mint(owner, amount);

        // ADDED
        _reflectedBalances[owner()] = _reflectedSupply;

        // Exclude owner and this contract from fee.
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // Exclude the owner and this contract from rewards.
        _exclude(owner());
        _exclude(address(this));

        emit Transfer(address(0), owner(), TOTAL_SUPPLY);
    }

    /**
     * @dev Returns the token name.
     */
    function name() external pure override returns (string memory) {
        return NAME;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external pure override returns (string memory) {
        return SYMBOL;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external pure override returns (uint8) {
        return DECIMALS;
    }

    /**
     * @dev Returns if the token is mintable or not
     */
    function mintable() external pure returns (bool) {
        return MINTABLE;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external pure override returns (uint256) {
        return TOTAL_SUPPLY;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromRewards[account]) return _balances[account];
        return tokenFromReflection(_reflectedBalances[account]);
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    /**
    * @dev
    * @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    * its behalf, and then a function is triggered in the contract that is
    * being approved, `_spender`. This allows users to use their tokens to
    * interact with contracts in one function call instead of two
    *
    * Requirements:
    *
    * - `spender` The address of the contract able to transfer the tokens
    * - `_amount` The amount of tokens to be approved for transfer
    * - `_extraData` The raw data for call another contract
    * - return True if the function call was successful
    */
    function approveAndCall(ApproveAndCallFallBack _spender, uint256 _amount, bytes calldata _extraData) external returns (bool success) {
        _approve(_msgSender(), address(_spender), _amount);

        _spender.receiveApproval(
            msg.sender,
            _amount,
            _extraData
        );

        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));

        return true;
    }

    /**
     * @dev this is really a "soft" burn (total supply is not reduced). RFI holders
     * get two benefits from burning tokens:
     *
     * 1) Tokens in the burn address increase the % of tokens held by holders not
     *    excluded from rewards (assuming the burn address is excluded)
     * 2) Tokens in the burn address cannot be sold (which in turn drains the
     *    liquidity pool)
     *
     *
     * In RFI holders already get % of each transaction so the value of their tokens
     * increases (in a way). Therefore there is really no need to do a "hard" burn
     * (reduce the total supply). What matters (in RFI) is to make sure that a large
     * amount of tokens cannot be sold = draining the liquidity pool = lowering the
     * value of tokens holders own. For this purpose, transferring tokens to a (vanity)
     * burn address is the most appropriate way to "burn".
     *
     * There is an extra check placed into the `transfer` function to make sure the
     * burn address cannot withdraw the tokens is has (although the chance of someone
     * having/finding the private key is virtually zero).
     */
    function burn(uint256 amount) external {
        address sender = _msgSender();
        require(sender != address(0), "BaseRfiToken: burn from the zero address");
        require(sender != address(burnAddress), "BaseRfiToken: burn from the burn address");

        uint256 balance = balanceOf(sender);
        require(balance >= amount, "BaseRfiToken: burn amount exceeds balance");

        uint256 reflectedAmount = amount.mul(_getCurrentRate());

        // Remove the amount from the sender's balance first.
        _reflectedBalances[sender] = _reflectedBalances[sender].sub(reflectedAmount);
        if (_isExcludedFromRewards[sender])
            _balances[sender] = _balances[sender].sub(amount);

        _burnTokens(sender, amount, reflectedAmount);
    }

    /**
     * @dev "Soft" burns the specified amount of tokens by sending them
     * to the burn address.
     */
    function _burnTokens(address sender, uint256 tBurn, uint256 rBurn) internal {
        /**
         * @dev Do not reduce _totalSupply and/or _reflectedSupply. (soft) burning by sending
         * tokens to the burn address (which should be excluded from rewards) is sufficient
         * in RFI.
         */
        _reflectedBalances[burnAddress] = _reflectedBalances[burnAddress].add(rBurn);
        if (_isExcludedFromRewards[burnAddress])
            _balances[burnAddress] = _balances[burnAddress].add(tBurn);

        /**
         * @dev Emit the event so that the burn address balance is updated (on bscscan).
         */
        emit Transfer(sender, burnAddress, tBurn);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Decreased allowance below zero"));

        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromRewards[account];
    }

    /**
     * @dev Calculates and returns the reflected amount for the given amount with or without
     * the transfer fees (deductTransferFee true/false).
     */
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns (uint256) {
        require(tAmount <= TOTAL_SUPPLY, "Amount must be less than supply");

        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount, 0);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount, _getSumOfFees(_msgSender(), tAmount));
            return rTransferAmount;
        }
    }

    /**
     * @dev Calculates and returns the amount of tokens corresponding to the given reflected amount.
     */
    function tokenFromReflection(uint256 rAmount) internal view returns (uint256) {
        require(rAmount <= _reflectedSupply, "Amount must be less than total reflections");
        uint256 currentRate = _getCurrentRate();

        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcludedFromRewards[account], "Account is not included");
        _exclude(account);
    }

    function _exclude(address account) internal {
        if (_reflectedBalances[account] > 0) {
            _balances[account] = tokenFromReflection(_reflectedBalances[account]);
        }

        _isExcludedFromRewards[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromRewards[account], "Account is not excluded");

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balances[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excluded.pop();

                break;
            }
        }
    }

    function setExcludedFromFee(address account, bool value) external onlyOwner {
        _isExcludedFromFee[account] = value;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BaseRfiToken: approve from the zero address");
        require(spender != address(0), "BaseRfiToken: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _isUnlimitedSender(address account) internal view returns (bool) {
        // The owner should be the only whitelisted sender.
        return (account == owner());
    }

    function _isUnlimitedRecipient(address account) internal view returns (bool) {
        // The owner should be a white-listed recipient
        // and anyone should be able to burn as many tokens as
        // he/she wants.
        return (account == owner() || account == burnAddress);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BaseRfiToken: transfer from the zero address");
        require(recipient != address(0), "BaseRfiToken: transfer to the zero address");
        require(sender != address(burnAddress), "BaseRfiToken: transfer from the burn address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Indicates whether or not fee should be deducted from the transfer.
        bool takeFee = true;

        if (isInPresale) {
            takeFee = false;
        } else {
            /**
            * Check the amount is within the max allowed limit as long as an
            * unlimited sender/recipient is not involved in the transaction.
            */
            if (amount > maxTransactionAmount && !_isUnlimitedSender(sender) && !_isUnlimitedRecipient(recipient)) {
                revert("Transfer amount exceeds the maxTxAmount.");
            }

            /**
            * The pair needs to excluded from the max wallet balance check;
            * selling tokens is sending them back to the pair (without this
            * check, selling tokens would not work if the pair's balance
            * was over the allowed max).
            *
            * Note: This does NOT take into account the fees which will be deducted
            *       from the amount. As such it could be a bit confusing.
            */
            if (maxWalletBalance > 0 && !_isUnlimitedSender(sender) && !_isUnlimitedRecipient(recipient) && !_isV2Pair(recipient)) {
                uint256 recipientBalance = balanceOf(recipient);
                require(recipientBalance + amount <= maxWalletBalance, "New balance would exceed the maxWalletBalance");
            }
        }

        // If any account belongs to _isExcludedFromFee account then remove the fee.
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {takeFee = false;}

        _beforeTokenTransfer(sender, recipient, amount, takeFee);
        _transferTokens(sender, recipient, amount, takeFee);
    }

    function _transferTokens(address sender, address recipient, uint256 amount, bool takeFee) private {
        /**
         * We don't need to know anything about the individual fees here
         * (like Safemoon does with `_getValues`). All that is required
         * for the transfer is the sum of all fees to calculate the % of the total
         * transaction amount which should be transferred to the recipient.
         *
         * The `_takeFees` call will/should take care of the individual fees.
         */
        uint256 sumOfFees = _getSumOfFees(sender, amount);
        if (!takeFee) {
            sumOfFees = 0;
        }

        (uint256 rAmount, uint256 rTransferAmount, uint256 tAmount, uint256 tTransferAmount, uint256 currentRate) = _getValues(amount, sumOfFees);

        /**
         * Sender's and Recipient's reflected balances must be always updated regardless of
         * whether they are excluded from rewards or not.
         */
        _reflectedBalances[sender] = _reflectedBalances[sender].sub(rAmount);
        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rTransferAmount);

        /**
         * Update the true/nominal balances for excluded accounts.
         */
        if (_isExcludedFromRewards[sender]) {
            _balances[sender] = _balances[sender].sub(tAmount);
        }

        if (_isExcludedFromRewards[recipient]) {
            _balances[recipient] = _balances[recipient].add(tTransferAmount);
        }

        _takeFees(amount, currentRate, sumOfFees);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeFees(uint256 amount, uint256 currentRate, uint256 sumOfFees) private {
        if (sumOfFees > 0 && !isInPresale) {
            _takeTransactionFees(amount, currentRate);
        }
    }

    function _getValues(uint256 tAmount, uint256 feesSum) internal view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 tTotalFees = tAmount.mul(feesSum).div(FEES_DIVISOR);
        uint256 tTransferAmount = tAmount.sub(tTotalFees);
        uint256 currentRate = _getCurrentRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTotalFees = tTotalFees.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rTotalFees);

        return (rAmount, rTransferAmount, tAmount, tTransferAmount, currentRate);
    }

    function _getCurrentRate() internal view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();

        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() internal view returns (uint256, uint256) {
        uint256 rSupply = _reflectedSupply;
        uint256 tSupply = TOTAL_SUPPLY;

        /**
         * The code below removes balances of addresses excluded from rewards from
         * rSupply and tSupply, which effectively increases the % of transaction fees
         * delivered to non-excluded holders.
         */
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_reflectedBalances[_excluded[i]] > rSupply || _balances[_excluded[i]] > tSupply) return (_reflectedSupply, TOTAL_SUPPLY);
            rSupply = rSupply.sub(_reflectedBalances[_excluded[i]]);
            tSupply = tSupply.sub(_balances[_excluded[i]]);
        }

        if (tSupply == 0 || rSupply < _reflectedSupply.div(TOTAL_SUPPLY)) return (_reflectedSupply, TOTAL_SUPPLY);

        return (rSupply, tSupply);
    }

    /**
     * @dev Hook that is called before any transfer of tokens.
     */
    function _beforeTokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) internal virtual;

    /**
     * @dev Returns the total sum of fees to be processed in each transaction.
     *
     * To separate concerns this contract (class) will take care of ONLY handling RFI, i.e.
     * changing the rates and updating the holder's balance (via `_redistribute`).
     * It is the responsibility of the dev/user to handle all other fees and taxes
     * in the appropriate contracts (classes).
     */
    function _getSumOfFees(address sender, uint256 amount) internal view virtual returns (uint256);

    /**
     * @dev A delegate which should return true if the given address is the V2 Pair and false otherwise.
     */
    function _isV2Pair(address account) internal view virtual returns (bool);

    /**
     * @dev Redistributes the specified amount among the current holders via the reflect.finance
     * algorithm, i.e. by updating the _reflectedSupply (_rSupply) which ultimately adjusts the
     * current rate used by `tokenFromReflection` and, in turn, the value returns from `balanceOf`.
     * This is the bit of clever math which allows rfi to redistribute the fee without
     * having to iterate through all holders.
     */
    function _redistribute(uint256 amount, uint256 currentRate, uint256 fee, uint256 index) internal {
        uint256 tFee = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rFee = tFee.mul(currentRate);

        _reflectedSupply = _reflectedSupply.sub(rFee);
        _addFeeCollectedAmount(index, tFee);
    }

    /**
     * @dev Hook that is called before the `Transfer` event is emitted if fees are enabled for the transfer.
     */
    function _takeTransactionFees(uint256 amount, uint256 currentRate) internal virtual;
}

abstract contract Liquifier is Ownable, Manageable {
    using SafeMath for uint256;

    uint256 private withdrawableBalance;

    enum Env {Testnet, MainnetV1, MainnetV2}
    Env private _env;

    // PancakeSwap V1
    address private _mainnetRouterV1Address = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
    // PancakeSwap V2
    address private _mainnetRouterV2Address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Testnet
    // address private _testnetRouterAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // PancakeSwap Testnet = https://pancake.kiemtienonline360.com/
    address private _testnetRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    IPancakeV2Router internal _router;
    address internal _pair;

    bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled = true;

    uint256 private maxTransactionAmount;
    uint256 private numberOfTokensToSwapToLiquidity;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event RouterSet(address indexed router);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event LiquidityAdded(uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity);

    receive() external payable {}

    function initializeLiquiditySwapper(Env env, uint256 maxTx, uint256 liquifyAmount) internal {
        _env = env;
        if (_env == Env.MainnetV1) {_setRouterAddress(_mainnetRouterV1Address);}
        else if (_env == Env.MainnetV2) {_setRouterAddress(_mainnetRouterV2Address);}
        else if (_env == Env.Testnet) {_setRouterAddress(_testnetRouterAddress);}

        maxTransactionAmount = maxTx;
        numberOfTokensToSwapToLiquidity = liquifyAmount;
    }

    /**
     * @dev Passing the `contractTokenBalance` here is preferred to creating `balanceOfDelegate`.
     */
    function liquify(uint256 contractTokenBalance, address sender) internal {
        if (contractTokenBalance >= maxTransactionAmount) contractTokenBalance = maxTransactionAmount;
        bool isOverRequiredTokenBalance = (contractTokenBalance >= numberOfTokensToSwapToLiquidity);

        /**
         * - First check if the contract has collected enough tokens to swap and liquify
         * - Then check swap and liquify is enabled
         * - Then make sure not to get caught in a circular liquidity event
         * - Finally, don't swap & liquify if the sender is the Pancakeswap pair
         */
        if (isOverRequiredTokenBalance && swapAndLiquifyEnabled && !inSwapAndLiquify && (sender != _pair)) {
            // TODO: check if the `(sender != _pair)` is necessary because that basically stops swap and liquify for all "buy" transactions.
            _swapAndLiquify(contractTokenBalance);
        }
    }

    /**
     * @dev Sets the router address and created the router, factory pair to enable
     * swapping and liquifying (contract) tokens.
     */
    function _setRouterAddress(address router) private {
        IPancakeV2Router _newPancakeRouter = IPancakeV2Router(router);
        _pair = IPancakeV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        _router = _newPancakeRouter;

        emit RouterSet(router);
    }

    function _swapAndLiquify(uint256 amount) private lockTheSwap {
        // Split the contract balance into halves.
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);

        // Capture the contract's current ETH balance.
        // This is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract.
        uint256 initialBalance = address(this).balance;

        // Swap tokens for ETH.
        _swapTokensForEth(half);
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // How much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // Add liquidity to Pancakeswap.
        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        // Generate the Pancakeswap pair path of token -> wbnb.
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approveDelegate(address(this), address(_router), tokenAmount);

        // Make the swap.
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
        // The minimum amount of output tokens that must be received for the transaction not to revert.
        // 0 = accept any amount (slippage is inevitable).
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Approve token transfer to cover all possible scenarios.
        _approveDelegate(address(this), address(_router), tokenAmount);

        // Add the liquidity.
        (uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity) = _router.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
        // Bounds the extent to which the WETH/token price can go up before the transaction reverts.
        // Must be <= amountTokenDesired; 0 = accept any amount (slippage is inevitable).
            0,
        // Bounds the extent to which the token/WETH price can go up before the transaction reverts.
        // 0 = accept any amount (slippage is inevitable).
            0,
        // This is a centralised risk if the owner's account is ever compromised (see Certik SSL-04).
            owner(),
            block.timestamp
        );

        // Fix the forever locked BNBs as per the Certik's audit!
        /**
         * The swapAndLiquify function converts half of the contractTokenBalance SafeMoon tokens to BNB.
         * For every swapAndLiquify function call, a small amount of BNB remains in the contract.
         * This amount grows over time with the swapAndLiquify function being called throughout the life
         * of the contract. The Safemoon contract does not contain a method to withdraw these funds,
         * and the BNB will be locked in the Safemoon contract forever.
         */
        withdrawableBalance = address(this).balance;

        emit LiquidityAdded(tokenAmountSent, ethAmountSent, liquidity);
    }


    /**
    * @dev Sets the PancakeswapV2 pair (router & factory) for swapping and liquifying tokens.
    */
    function setRouterAddress(address router) external onlyManager() {
        _setRouterAddress(router);
    }

    /**
     * @dev Sends the swap and liquify flag to the provided value. If set to `false` tokens collected in the
     * contract will NOT be converted into liquidity.
     */
    function setSwapAndLiquifyEnabled(bool enabled) external onlyManager {
        swapAndLiquifyEnabled = enabled;

        emit SwapAndLiquifyEnabledUpdated(swapAndLiquifyEnabled);
    }

    /**
     * @dev The owner can withdraw ETH(BNB) collected in the contract from `swapAndLiquify`
     * or if someone (accidentally) sends ETH/BNB directly to the contract.
     *
     * Note: This addresses the contract flaw pointed out in the Certik Audit of Safemoon (SSL-03):
     *
     * The swapAndLiquify function converts half of the contractTokenBalance SafeMoon tokens to BNB.
     * For every swapAndLiquify function call, a small amount of BNB remains in the contract.
     * This amount grows over time with the swapAndLiquify function being called
     * throughout the life of the contract. The Safemoon contract does not contain a method
     * to withdraw these funds, and the BNB will be locked in the Safemoon contract forever.
     * https://www.certik.org/projects/safemoon
     */
    function withdrawLockedEth(address payable recipient) external onlyManager() {
        require(recipient != address(0), "Cannot withdraw the ETH balance to the zero address");
        require(withdrawableBalance > 0, "The ETH balance must be greater than 0");

        // Prevent re-entrancy attacks.
        uint256 amount = withdrawableBalance;
        withdrawableBalance = 0;
        recipient.transfer(amount);
    }

    /**
     * @dev Use this delegate instead of having (unnecessarily) extend `BaseRfiToken` to gained access
     * to the `_approve` function.
     */
    function _approveDelegate(address owner, address spender, uint256 amount) internal virtual;
}

/**
 * @dev TODO: Anti-whale contract mechanism needs to be implemented.
 *
 * If you wish to modify the anti-whale method (progressive taxation) it will require a bit of coding.
 * I tried to make the integration as simple as possible via the `Antiwhale` contract, so the devs
 * know exactly where to look and what/how to make the necessary changes. There are many possibilities,
 * such as modifying the fees based on the tx amount (as % of TOTAL_SUPPLY), or sender's wallet balance
 * (as % of TOTAL_SUPPLY), including (but not limited to):
 * - Progressive taxation by tax brackets (e.g <1%, 1-2%, 2-5%, 5-10%)
 * - Progressive taxation by the % over a threshold (e.g. 1%)
 * - Extra fee (e.g. double) over a threshold
 */
abstract contract Antiwhale is Tokenomics {
    /**
     * @dev Returns the total sum of fees (in percents / per-mille - this depends on the FEES_DIVISOR value)
     *
     * NOTE: Currently this is just a placeholder. The parameters passed to this function are the
     *      sender's token balance and the transfer amount. An *antiwhale* mechanics can use these
     *      values to adjust the fees total for each tx.
     */
    // function _getAntiwhaleFees(uint256 sendersBalance, uint256 amount) internal view returns (uint256) {
    function _getAntiwhaleFees(uint256, uint256) internal view returns (uint256) {
        return sumOfFees;
    }
}

abstract contract StepsToken is BaseRfiToken, Liquifier, Antiwhale {
    using SafeMath for uint256;

    // constructor(string memory _name, string memory _symbol, uint8 _decimals) {
    // constructor(Env _env) {
    //    initializeLiquiditySwapper(_env, maxTransactionAmount, numberOfTokensToSwapToLiquidity);

        // Exclude the pair address from rewards - we don't want to redistribute tx fees to these two;
        // redistribution is only for token holders.
    //    _exclude(_pair);
    //    _exclude(burnAddress);
    //}

    //constructor() initializer {}

    function initialize() initializer public override virtual {
        initializeLiquiditySwapper(Env.Testnet, maxTransactionAmount, numberOfTokensToSwapToLiquidity);

        // Exclude the pair address from rewards - we don't want to redistribute tx fees to these two;
        // redistribution is only for token holders.
        _exclude(_pair);
        _exclude(burnAddress);
        // string owner = '0xd3ba7ae4132683b4084526c5e26a0f2e7aa190bc';
        //_approve(msg.sender, address(_router), ~uint256(0));
    }

    function _isV2Pair(address account) internal view override returns (bool) {
        return (account == _pair);
    }

    function _getSumOfFees(address sender, uint256 amount) internal view override returns (uint256) {
        return _getAntiwhaleFees(balanceOf(sender), amount);
    }

//    function pause() public onlyOwner {
//        _pause();
//    }
//
//    function unpause() public onlyOwner {
//        _unpause();
//    }

    //function _beforeTokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) internal whenNotPaused override {
    function _beforeTokenTransfer(address sender, address, uint256, bool) internal override {
        //super._beforeTokenTransfer(sender, recipient, amount, takeFee);
        if (!isInPresale) {
            uint256 contractTokenBalance = balanceOf(address(this));
            liquify(contractTokenBalance, sender);
        }
    }

    function _takeTransactionFees(uint256 amount, uint256 currentRate) internal override {
        if (isInPresale) {
            return;
        }

        uint256 feesCount = _getFeesCount();
        for (uint256 index = 0; index < feesCount; index++) {
            (FeeType name, uint256 value, address recipient,) = _getFee(index);
            // No need to check value < 0 as the value is uint (i.e. from 0 to 2^256-1).
            if (value == 0) continue;

            if (name == FeeType.Rfi) {
                _redistribute(amount, currentRate, value, index);
            }
            else if (name == FeeType.Burn) {
                _burn(amount, currentRate, value, index);
            }
            else if (name == FeeType.Antiwhale) {
                // TODO: Need an Antiwhale mechanism here.
            }
            else if (name == FeeType.ExternalToETH) {
                _takeFeeToETH(amount, currentRate, value, recipient, index);
            }
            else {
                _takeFee(amount, currentRate, value, recipient, index);
            }
        }
    }

    function _burn(uint256 amount, uint256 currentRate, uint256 fee, uint256 index) private {
        uint256 tBurn = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rBurn = tBurn.mul(currentRate);

        _burnTokens(address(this), tBurn, rBurn);
        _addFeeCollectedAmount(index, tBurn);
    }

    function _takeFee(uint256 amount, uint256 currentRate, uint256 fee, address recipient, uint256 index) private {
        uint256 tAmount = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rAmount = tAmount.mul(currentRate);

        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rAmount);
        if (_isExcludedFromRewards[recipient])
            _balances[recipient] = _balances[recipient].add(tAmount);

        _addFeeCollectedAmount(index, tAmount);
    }

    /**
     * @dev When implemented this will convert the fee amount of tokens into ETH/BNB
     * and send to the recipient's wallet. Note that this reduces liquidity so it
     * might be a good idea to add a % into the liquidity fee for % you take our through
     * this method (just a suggestion).
     */
    function _takeFeeToETH(uint256 amount, uint256 currentRate, uint256 fee, address recipient, uint256 index) private {
        _takeFee(amount, currentRate, fee, recipient, index);
    }

    function _approveDelegate(address owner, address spender, uint256 amount) internal override {
        _approve(owner, spender, amount);
    }
}

contract Steps is Initializable, StepsToken {

    // constructor() StepsToken(Env.Testnet) {
    //     _approve(owner(), address(_router), ~uint256(0));
    // }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public override {
        // __ERC20_init("12 Steps", "STEPS");
        // __ERC20Burnable_init();
        // __Pausable_init();
        // __Ownable_init();
        // __ERC20Permit_init("12 Steps");

        // _mint(msg.sender, 1278377046 * 10 ** decimals());
        // string owner = '0xd3ba7ae4132683b4084526c5e26a0f2e7aa190bc';
        // _approve(msg.sender, address(_router), ~uint256(0));
        _approve(owner(), address(_router), ~uint256(0));
    }
}