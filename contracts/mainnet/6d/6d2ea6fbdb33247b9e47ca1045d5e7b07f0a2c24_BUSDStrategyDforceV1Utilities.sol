/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.2;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.6.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.6.0;

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
contract Ownable is Context {
    address private _governance;

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _governance = msgSender;
        emit GovernanceTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function governance() public view returns (address) {
        return _governance;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyGovernance() {
        require(_governance == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferGovernance(address newOwner) internal virtual onlyGovernance {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit GovernanceTransferred(_governance, newOwner);
        _governance = newOwner;
    }
}

// File: contracts/strategies/BUSDStrategyDforceV1Utilities.sol

pragma solidity =0.6.6;

interface TradeRouter {
    function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory); // For a value in, it calculates value out
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface DodoPool{
    function getVaultReserve() external view returns (uint256 baseReserve, uint256 quoteReserve);
    function totalSupply() external view returns (uint256);
    function querySellBase(address trader, uint256 payBaseAmount)
        external
        view
        returns (
            uint256 receiveQuoteAmount
        );
    function querySellQuote(address trader, uint256 payQuoteAmount)
        external
        view
        returns (
            uint256 receiveBaseAmount
        );
    function _BASE_TOKEN_() external view returns (address);
}

interface DForceController{
    function hasEnteredMarket(address _account, address _iToken) external view returns (bool);
    function enterMarkets(address[] calldata _iTokens) external returns (bool[] memory _results);
    function claimRewards(address[] calldata _holders, address[] calldata _suppliediTokens, address[] calldata _borrowediTokens) external;
    function updateReward(address _iToken, address account, bool isBorrow) external;
    function reward(address _account) external view returns (uint256);
    function calcAccountEquity(address _account) external view returns (uint256, uint256 short, uint256 collat, uint256 borrowed);
}

interface DForceLPFarm{
    function balanceOf(address account) external view returns (uint256); // LP token staked
    function earned(address _account) external view returns (uint256); // Of DF token
    function getReward() external;
    function exit() external;
    function stake(uint256 _amount) external;
    function withdraw(uint256 _amount) external; // This does not autoclaim reward
}

interface DforceToken{
    function exchangeRateCurrent() external returns (uint256);
    function borrowBalanceCurrent(address _account) external returns (uint256);
    function exchangeRateStored() external view returns (uint256);
    function borrowBalanceStored(address _account) external view returns (uint256);
    function mint(address _recipient, uint256 _mintAmount) external; // Used for depositing
    function redeem(address _from, uint256 _redeemiToken) external; // Used for withdraws
    function borrow(uint256 _borrowAmount) external; // Used to borrow
    function repayBorrow(uint256 _repayAmount) external; // Used to repay
}

interface StabilizeStrategy{
    function rewardTokenAddress(uint256 _pos) external view returns (address);
    function usxSetPrice() external view returns (uint256);
    function percentStakeDepositor() external view returns (uint256);
    function usxSlippage() external view returns (uint256);
    function minHealthRatio() external view returns (uint256);
    function usxBorrowPercent() external view returns (uint256);
}

// This is a utility contract for the Dforce strategy (since that contract is too big) that contains calculations pertinent to the main contract
contract BUSDStrategyDforceV1Utilities is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 constant DIVISION_FACTOR = 100000;
    uint256 public collateralRatio = 85000; // Governance can change
    
    // Strategy specific variables
    address constant WBNB_ADDRESS = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // WBNB address
    address constant DF_ADDRESS = address(0x4A9A2b2b04549C3927dd2c9668A5eF3fCA473623);
    address constant USX_ADDRESS = address(0xB5102CeE1528Ce2C760893034A4603663495fD72);
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Pools
    address constant DODO_DF_USX_POOL = address(0xB69fdC6531e08B366616aB30b8481bf4148786cB);
    address constant DODO_USX_BUSD_POOL = address(0xb19265426ce5bC1E015C0c503dFe6EF7c407a406);
    address constant DFORCE_LP_FARM = address(0x8d61b71958dD9Df6eAA670c0476CcE7e25e98707);
    address constant DFORCE_IBUSD_POOL = address(0x5511b64Ae77452C7130670C79298DEC978204a47);
    address constant DFORCE_IUSX_POOL = address(0x7B933e1c1F44bE9Fb111d87501bAADA7C8518aBe);
    address constant DFORCE_LENDING_MARKETS = address(0x0b53E608bD058Bb54748C35148484fD627E6dc0A);
    address constant DFORCE_INCENTIVE_CONTRACT = address(0x6fC21a5a767212E8d366B3325bAc2511bDeF0Ef4);

    constructor() public {

    }

    // Only contains read functions

    /*
    function dodoGetLiquidityAmount(address _dodoPool, uint256 _baseAmount, uint256 _quoteAmount) public view returns (uint256, uint256) {
        (uint256 baseReserve, uint256 quoteReserve) = DodoPool(_dodoPool).getVaultReserve();
        if(baseReserve == 0 && quoteReserve == 0){
            return (_baseAmount.div(2), _quoteAmount.div(2));
        }else{
            uint256 baseIncreaseRatio = _baseAmount.mul(1e18).div(baseReserve);
            uint256 quoteIncreaseRatio = _quoteAmount.mul(1e18).div(quoteReserve);
            uint256 baseAdjustedInAmount = 0;
            uint256 quoteAdjustedInAmount = 0;
            if (baseIncreaseRatio <= quoteIncreaseRatio) {
                baseAdjustedInAmount = _baseAmount;
                quoteAdjustedInAmount = quoteReserve.mul(baseIncreaseRatio).div(1e18);
            } else {
                quoteAdjustedInAmount = _quoteAmount;
                baseAdjustedInAmount = baseReserve.mul(quoteIncreaseRatio).div(1e18);
            }
            return (baseAdjustedInAmount, quoteAdjustedInAmount);
        }
    }
    */
    
    function getNormalizedTotalBalance(address _contract) public returns (uint256) {
        // Get the balance of the tokens at this address
        // To calculate this, we must obtain BUSD at this address
        // Then add BUSD calculated from staked Dodo LP
        // Then add BUSD equivalent supplied in Dforce pool (via iTokens)

        // Then add USX (in BUSD units) at this address
        // Then add USX (in BUSD units) calculated from staked Dodo LP
        // Then subtract USX owed (in BUSD units)
        address mainToken = StabilizeStrategy(_contract).rewardTokenAddress(0);
        uint256 _balance = IERC20(mainToken).balanceOf(_contract); // BUSD and USX are both already normalized
        {
            uint256 _stakeBalance = 0;
            DForceLPFarm farm = DForceLPFarm(DFORCE_LP_FARM);
            _stakeBalance = farm.balanceOf(_contract);
            if(_stakeBalance > 0){
                DodoPool pool = DodoPool(DODO_USX_BUSD_POOL); // USX is the base token, BUSD is the quote
                (, uint256 quoteAmount) = pool.getVaultReserve();
                uint256 _amount = _stakeBalance.mul(quoteAmount).div(pool.totalSupply());
                _balance = _balance.add(_amount);
            }
        }
        {
            uint256 _amount = IERC20(DFORCE_IBUSD_POOL).balanceOf(_contract); // Check the token balance
            if(_amount > 0){
                _amount = _amount.mul(DforceToken(DFORCE_IBUSD_POOL).exchangeRateCurrent()).div(1e18);
                _balance = _balance.add(_amount);
            }
        }

        // Now do the same for USX
        {
            uint256 _amount = IERC20(USX_ADDRESS).balanceOf(_contract);
            if(_amount > 0){
                _balance = _balance.add(getUSXInBUSDUnits(_contract, _amount));
            }
        }
        {
            uint256 _stakeBalance = 0;
            DForceLPFarm farm = DForceLPFarm(DFORCE_LP_FARM);
            _stakeBalance = farm.balanceOf(_contract);
            if(_stakeBalance > 0){
                DodoPool pool = DodoPool(DODO_USX_BUSD_POOL); // USX is the base token, BUSD is the quote
                (uint256 baseAmount, ) = pool.getVaultReserve();
                uint256 _amount = _stakeBalance.mul(baseAmount).div(pool.totalSupply());
                _balance = _balance.add(getUSXInBUSDUnits(_contract, _amount));
            }
        }
        // Finally subtract the borrowed USX
        {
            uint256 _amount = DforceToken(DFORCE_IUSX_POOL).borrowBalanceCurrent(_contract); // Shows us the amount of USX owed
            if(_amount > 0){
                _amount = getUSXInBUSDUnits(_contract, _amount); // Convert to BUSD
                if(_amount > _balance){
                    revert("Owed is greater than available");
                }else{
                    _balance = _balance.sub(_amount);
                }
            }
        }
        return _balance;
    }

    function getUSXInBUSDUnits(address _contract, uint256 _amount) public view returns (uint256) {
        _amount = _amount.mul(StabilizeStrategy(_contract).usxSetPrice()).div(1e18);
        return _amount;
    }

    function getBUSDInUSXUnits(address _contract, uint256 _amount) public view returns (uint256) {
        _amount = _amount.mul(1e18).div(StabilizeStrategy(_contract).usxSetPrice());
        return _amount;
    }
    
    function calculateRewards(address _contract) public returns (uint256) {
        // This will return the expected WBNB gain for payouts
        address mainToken = StabilizeStrategy(_contract).rewardTokenAddress(0);
        uint256 _earned = IERC20(DF_ADDRESS).balanceOf(_contract);
        DForceLPFarm farm = DForceLPFarm(DFORCE_LP_FARM);
        _earned = farm.earned(_contract).add(_earned);

        {
            // Check reward
            DForceController controller = DForceController(DFORCE_INCENTIVE_CONTRACT);
            controller.updateReward(DFORCE_IBUSD_POOL, _contract, false);
            controller.updateReward(DFORCE_IUSX_POOL, _contract, true);
            _earned = controller.reward(_contract).add(_earned);
        }

        if(_earned == 0){return 0;}

        _earned = calculateDodoReturn(DODO_DF_USX_POOL, DF_ADDRESS, USX_ADDRESS, _earned);

        _earned = _earned.mul(DIVISION_FACTOR.sub(StabilizeStrategy(_contract).percentStakeDepositor())).div(DIVISION_FACTOR);
        _earned = calculateDodoReturn(DODO_USX_BUSD_POOL, USX_ADDRESS, mainToken, _earned);

        address[] memory path;
        uint256[] memory estimates;
        path = new address[](2);
        path[0] = mainToken;
        path[1] = WBNB_ADDRESS;
        TradeRouter router = TradeRouter(PANCAKE_ROUTER);
        estimates = router.getAmountsOut(_earned, path);
        _earned = estimates[estimates.length - 1];
        return _earned.add(IERC20(WBNB_ADDRESS).balanceOf(_contract));
    }

    function acceptableMinOutput(address _contract, address inputAddress, uint256 _amount) public view returns (uint256) {
        // TODO: Returns the min amount that is acceptable for an output. Needed to prevent frontrunning/sandwich
        address mainToken = StabilizeStrategy(_contract).rewardTokenAddress(0);
        uint256 maxSlip = StabilizeStrategy(_contract).usxSlippage();
        if(maxSlip >= DIVISION_FACTOR){ return 1; } // No slip limit
        if(inputAddress == mainToken){
            return getBUSDInUSXUnits(_contract, _amount).mul(DIVISION_FACTOR.sub(maxSlip)).div(DIVISION_FACTOR);
        }else{
            return getUSXInBUSDUnits(_contract, _amount).mul(DIVISION_FACTOR.sub(maxSlip)).div(DIVISION_FACTOR);
        }
    }

    function withdrawAvailable(address _contract, uint256 _share, uint256 _total) public returns (bool) {
        uint256 totalBUSD = getNormalizedTotalBalance(_contract);
        if(totalBUSD == 0){return false;}
        uint256 busdNeeded = totalBUSD.mul(_share).div(_total);
        if(_share == _total){
            busdNeeded = totalBUSD;
        }
        address mainToken = StabilizeStrategy(_contract).rewardTokenAddress(0);
        uint256 _busdBal = IERC20(mainToken).balanceOf(address(this));

        if(busdNeeded <= _busdBal){
            return true;
        }

        busdNeeded = busdNeeded.sub(_busdBal);
        uint256 proportionNeeded = 0;
        {
            uint256 _supplied = IERC20(DFORCE_IBUSD_POOL).balanceOf(_contract); // Check the token balance
            if(_supplied > 0){
                _supplied = _supplied.mul(DforceToken(DFORCE_IBUSD_POOL).exchangeRateCurrent()).div(1e18);
            }
            proportionNeeded = busdNeeded.mul(1e18).div(_supplied);
            if(_share == _total){
                proportionNeeded = 1e18;
            }
        }

        return stakeLpPositiveLiquidity(_contract, proportionNeeded);
    }

    function stakeLpPositiveLiquidity(address _contract, uint256 proportionNeeded) internal returns (bool) {
        // Checks whether a certain amount of user's staked LP is enough to cover the cost of the decreasing loan
        address mainToken = StabilizeStrategy(_contract).rewardTokenAddress(0);
        DForceLPFarm farm = DForceLPFarm(DFORCE_LP_FARM);
        uint256 _stakeBalance = farm.balanceOf(_contract);
        if(proportionNeeded < 1e18){
            _stakeBalance = _stakeBalance.mul(proportionNeeded).div(1e18);
            //_stakeBalance = _stakeBalance.mul(DIVISION_FACTOR.add(StabilizeStrategy(_contract).usxSlippage().div(10))).div(DIVISION_FACTOR); // Remove slightly more than the proportion
            if(_stakeBalance >= farm.balanceOf(_contract)){
                _stakeBalance = farm.balanceOf(_contract);
                proportionNeeded = 1e18;
            }
        }
        if(_stakeBalance > 0){
            uint256 usxAmount = 0;
            
            {
                DodoPool pool = DodoPool(DODO_USX_BUSD_POOL); // USX is the base token, BUSD is the quote
                (uint256 baseAmount, uint256 quoteAmount) = pool.getVaultReserve();
                usxAmount = _stakeBalance.mul(baseAmount).div(pool.totalSupply()).add(IERC20(USX_ADDRESS).balanceOf(_contract));
                uint256 busdAmount = _stakeBalance.mul(quoteAmount).div(pool.totalSupply());
                usxAmount = usxAmount.add(calculateDodoReturn(DODO_USX_BUSD_POOL, mainToken, USX_ADDRESS, busdAmount));
            }

            // Also calculate from pending DF rewards
            {
                uint256 _earned = IERC20(DF_ADDRESS).balanceOf(_contract);
                _earned = farm.earned(_contract).add(_earned);

                {
                    // Check reward
                    DForceController controller = DForceController(DFORCE_INCENTIVE_CONTRACT);
                    controller.updateReward(DFORCE_IBUSD_POOL, _contract, false);
                    controller.updateReward(DFORCE_IUSX_POOL, _contract, true);
                    _earned = controller.reward(_contract).add(_earned);
                }

                if(_earned > 0){
                    _earned = _earned.mul(DIVISION_FACTOR.sub(StabilizeStrategy(_contract).percentStakeDepositor())).div(DIVISION_FACTOR);
                    usxAmount = usxAmount.add(calculateDodoReturn(DODO_DF_USX_POOL, DF_ADDRESS, USX_ADDRESS, _earned));
                }
            }

            if(usxAmount == 0){return false;}

            if(proportionNeeded == 1e18){
                if(usxAmount < DforceToken(DFORCE_IUSX_POOL).borrowBalanceCurrent(_contract)){
                    return false;
                }
            }else if(usxAmount < DforceToken(DFORCE_IUSX_POOL).borrowBalanceCurrent(_contract)){
                // Now check if the ratio is still healthy after future changes
                uint256 newRatio = checkFutureLendRatio(_contract, IERC20(DFORCE_IBUSD_POOL).balanceOf(_contract).mul(proportionNeeded).div(1e18), usxAmount);
                if(newRatio < StabilizeStrategy(_contract).minHealthRatio()){
                    return false;
                }
            }
        }
        return true;
    }

    // Dodo specific functions
    function calculateDodoReturn(address dodoAddress, address inputAddress, address outputAddress, uint256 _amount) public view returns (uint256)
    {
        if(outputAddress==inputAddress){}
        // First determine which one is the quote
        uint256 direction = 0; // Selling base
        DodoPool pool = DodoPool(dodoAddress);
        if(pool._BASE_TOKEN_() != inputAddress){
            direction = 1; // We are selling quote token
        }
        if(direction == 1){
            // Selling quote
            return pool.querySellQuote(_msgSender(), _amount);
        }else{
            return pool.querySellBase(_msgSender(), _amount);
        }
    }

    function checkLendRatio(address _contract) public view returns (uint256) {
        DForceController controller = DForceController(DFORCE_LENDING_MARKETS);
        (,,uint256 col, uint256 bor) = controller.calcAccountEquity(_contract);
        if(bor == 0){return 0;}
        return col.mul(DIVISION_FACTOR).div(bor);
    }

    function checkFutureLendRatio(address _contract, uint256 _lessIBUSD, uint256 _lessUSX) public view returns (uint256) {
        // Calculate the future ratio
        uint256 _busdValue = IERC20(DFORCE_IBUSD_POOL).balanceOf(_contract); // Check the token balance
        require(_lessIBUSD <= _busdValue, "Cannot remove more than what we have");
        _busdValue = _busdValue.sub(_lessIBUSD);
        _busdValue = _busdValue.mul(DforceToken(DFORCE_IBUSD_POOL).exchangeRateStored()).div(1e18);
        _busdValue = _busdValue.mul(collateralRatio).div(DIVISION_FACTOR);
        uint256 _usxValue = DforceToken(DFORCE_IUSX_POOL).borrowBalanceStored(_contract);
        require(_lessUSX <= _usxValue, "Cannot return more than what we borrowed");
        _usxValue = _usxValue.sub(_lessUSX);
        _usxValue = getUSXInBUSDUnits(_contract, _usxValue);
        return _busdValue.mul(DIVISION_FACTOR).div(_usxValue);
    }

    // Used to update collateral ratio

    function updateCollateralRatio(uint256 _newRatio) external onlyGovernance {
        collateralRatio = _newRatio;
    }
    // --------------------
}