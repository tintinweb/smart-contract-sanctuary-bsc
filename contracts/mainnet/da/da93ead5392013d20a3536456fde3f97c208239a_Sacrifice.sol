/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an admin) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the admin account will be the one that deploys the contract. This
 * can later be changed with {transferAdminRole}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyAdmin`, which can be applied to your functions to restrict their use to
 * the admin.
 */
abstract contract Administration is Context {
    address private _admin;

    event AdminRoleTransferred(address indexed previousAdmin, address indexed newAdmin);

    /**
     * @dev Initializes the contract setting the deployer as the initial admin.
     */
    constructor () {
        address msgSender = _msgSender();
        _admin = msgSender;
        emit AdminRoleTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current admin.
     */
    function admin() public view virtual returns (address) {
        return _admin;
    }

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(admin() == _msgSender(), "Administration: caller is not the admin");
        _;
    }

    /**
     * @dev Leaves the contract without admin. It will not be possible to call
     * `onlyAdmin` functions anymore. Can only be called by the current admin.
     *
     * NOTE: Renouncing admin role will leave the contract without an admin,
     * thereby removing any functionality that is only available to the admin.
     */
    function renounceAdminRole() public virtual onlyAdmin {
        emit AdminRoleTransferred(_admin, address(0));
        _admin = address(0);
    }

    /**
     * @dev Transfers admin role of the contract to a new account (`newAdmin`).
     * Can only be called by the current admin.
     */
    function transferAdminRole(address newAdmin) public virtual onlyAdmin {
        require(newAdmin != address(0), "Administration: new admin is the zero address");
        emit AdminRoleTransferred(_admin, newAdmin);
        _admin = newAdmin;
    }
}


/**
 * @title FinalizableSacrifice
 * @dev Extension of Sacrifice where an admin can do extra work
 * after finishing.
 */
contract FinalizableSacrifice is Administration {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after sacrifice ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyAdmin public {
    require(!isFinalized);
    
    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }

}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// 
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// 
/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract Sacrifice is Administration {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;
    
    IBEP20 public newtoken;
    uint8 public newtokenDecimals = 9;
    uint256 public newTokenSupply = 1000000000 * 10**9; // 1 billion
    uint256 public unlockTime = 9999999999;

    address public devWallet = 0x6e96b5f23ab2e556551b5D2f88a073d955988168;
    bool public finalized = false;
    bool sacrificeOpen = false;

    event AddedRateUpdated(address indexed operator, uint256 previousRate, uint256 newRate);
    event NewTokenTransfered(address indexed operator, uint256 sendAmount);

          /**
       * @dev Override to extend the way in which ether is converted to tokens.
       * @param _contAmount Value in wei to be converted into tokens
       * @return Number of tokens that can be purchased with the specified _contAmount
       */
      function _getTokenAmount(uint256 _contAmount)
        internal view returns (uint256)
      {
        return _contAmount.mul(rate);
      }

        // Track sacrificer sacrifices
        uint256 public sacrificerMinCap = 100000000000000000; // .01 bnb
        uint256 public sacrificerMaxCap = 1000000000000000000; // 1 bnb
        uint256 public sacrificerHardCap = 10000000000000000000; // 10 bnb
        mapping(address => uint256) public sacrifices;
        mapping(address => uint256) public unclaimed;

      constructor(
        uint256 _cap, 
        uint256 _rate
       ) 
        {
            require(_cap > 0);
            cap = _cap;
            require(_rate > 0);
            rate = _rate;
        }

    // Update tokens
    function updateTokens(address _newtoken, uint8 _newtokenDecimals) external onlyAdmin {
        newtoken = IBEP20(_newtoken);
        newtokenDecimals = _newtokenDecimals;
    }

    // Update Caps
    function updateCap(uint256 _sacrificerMinCap, uint256 _sacrificerMaxCap, uint256 _sacrificerHardCap, uint256 _cap) external onlyAdmin {
        sacrificerMinCap = _sacrificerMinCap;
        sacrificerMaxCap = _sacrificerMaxCap;
        sacrificerHardCap = _sacrificerHardCap;
        cap = _cap;
    }

    // Update dev wallet
    function updateDevAddress(address _devWallet) external onlyAdmin {
        devWallet = _devWallet;
    }

    // Finalize Sacrifice
    function finalizeSacrifice(bool _finalized) external onlyAdmin {
        finalized = _finalized;
    }

    // Update total supply of old and new token
    function updateTokensSupply(uint256 _newTokenSupply) external onlyAdmin {
        newTokenSupply = _newTokenSupply;
    }

    uint256 public cap;
    
      /**
       * @dev Checks whether the cap has been reached.
       * @return Whether the cap was reached
       */
      function capReached() public view returns (bool) {
        return bnbRaised >= cap;
      }

      // How many token units a buyer gets per wei.
      // The rate is the conversion between wei and the smallest and indivisible token unit.
      // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
      // 1 wei will give you 1 unit, or 0.001 TOK.
      uint256 public rate;

      // Amount of wei raised
      uint256 public bnbRaised;

      /**
       * Event for token purchase logging
       * @param purchaser who paid for the tokens
       * @param beneficiary who got the tokens
       * @param contAmount bnb paid for purchase
       * @param amount amount of tokens purchased
       */
      event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 contAmount,
        uint256 amount
      );

      // -----------------------------------------
      // Sacrifice external interface
      // -----------------------------------------


      /**
       * @dev low level token purchase ***DO NOT OVERRIDE***
       * @param _beneficiary Address performing the token purchase
       */
      function processContribute(address _beneficiary) public payable returns (uint256 _allowCont) {
          require(block.timestamp >= unlockTime, "Sacrifice has not started yet.");
         _allowCont = sacrificerMaxCap;
        
        uint256 contAmount = msg.value;
        _preValidatePurchase(_beneficiary, contAmount, _allowCont);

        // update state
        bnbRaised = bnbRaised.add(contAmount);

        return _allowCont;
        
      }

    function processClaim(address _beneficiary) public {
        
        // calculate token amount to be created
        uint256 amtClaimable = unclaimed[_beneficiary] ;
        uint256 tokens = amtClaimable * (10 ** newtokenDecimals) / 10**18 * rate;
        uint256 totContAmount = sacrifices[_beneficiary];

        require(finalized == true);
        require(msg.sender == _beneficiary);
            _beneficiary = msg.sender; 
            _processPurchase(_beneficiary, tokens);
            emit TokenPurchase(
              msg.sender,
              _beneficiary,
              totContAmount,
              tokens
            );
    }

      // -----------------------------------------
      // Internal interface (extensible)
      // -----------------------------------------

      /**
       * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
       * @param _beneficiary Address performing the token purchase
       * @param _contAmount Value in wei involved in the purchase
       */

      function _preValidatePurchase(
        address _beneficiary,
        uint256 _contAmount,
        uint256 _allowCont
      )
        internal
      {
        
        require(msg.sender == _beneficiary);
        require(_contAmount != 0);
        require(_allowCont != 0);
        uint256 _existingContribution = sacrifices[_beneficiary];
        uint256 _allowedContribution = _allowCont;
        uint256 _newContribution = _existingContribution.add(_contAmount);
        uint256 _newTotalContribution = bnbRaised.add(_contAmount);
        require(_newContribution >= sacrificerMinCap && _newContribution <= _allowedContribution && _newTotalContribution <= sacrificerHardCap);
        sacrifices[_beneficiary] = _newContribution;
        unclaimed[_beneficiary] = _newContribution;
      }

      /**
       * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
       * @param _beneficiary Address performing the token purchase
       * @param _contAmount Value in wei involved in the purchase
       */
      function _postValidatePurchase(
        address _beneficiary,
        uint256 _contAmount
      )
        internal
      {
        // optional override
      }

      /**
       * @dev Source of tokens. Override this method to modify the way in which the sacrifice ultimately gets and sends its tokens.
       * @param _beneficiary Address performing the token purchase
       * @param _tokenAmount Number of tokens to be emitted
       */
      function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
      )
        internal
      {
        require(msg.sender == _beneficiary);
        newtoken.safeTransfer(_beneficiary, _tokenAmount);
        unclaimed[_beneficiary] = 0;
      }

      /**
       * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
       * @param _beneficiary Address receiving the tokens
       * @param _tokenAmount Number of tokens to be purchased
       */
      function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
      )
        internal
      {
        _deliverTokens(_beneficiary, _tokenAmount);
      }

      /**
       * @dev Override for extensions that require an internal state to check for validity (current user sacrifices, etc.)
       * @param _beneficiary Address receiving the tokens
       * @param _contAmount Value in wei involved in the purchase
       */
      function _updatePurchasingState(
        address _beneficiary,
        uint256 _contAmount
      )
        internal
      {
        // optional override
      }




    /**
    * @dev Returns the amount contributed so far by a sepecific user.
    * @param _beneficiary Address of contributor
    * @return User contribution so far
    */
    function getUserContribution(address _beneficiary)
        public view returns (uint256)
      {
        return sacrifices[_beneficiary];
      }

    /**
    * @dev Returns the amount contributed and unclaimed so far by a sepecific user.
    * @param _beneficiary Address of contributor
    * @return User unclaimed so far
    */
    function getUnclaimed(address _beneficiary)
        public view returns (uint256)
      {
        return unclaimed[_beneficiary];
      }



      /**
    * @dev Returns the amount of newtoken allocated so far to a sepecific user.
    * @param _beneficiary Address of contributor
    * @return User contribution so far
    */
    function getTokensAllocated(address _beneficiary)
        public view returns (uint256)
      {
        uint256 amtClaimable = unclaimed[_beneficiary] ;
        uint256 tokens = amtClaimable * (10 ** newtokenDecimals) / 10**18 * rate;
        return tokens;
      }

    function getAllowedContribution() 
         public view returns (uint256 _allowCont)
       {
        _allowCont = sacrificerMaxCap;
        return  _allowCont;
      }


    // Withdraw bnb sacrifices to devwallet
    function sweepBNB(uint256 amount) external onlyAdmin{
        payable(msg.sender).transfer(amount);
      }

    // Withdraw rest or wrong tokens that are sent here by mistake
    function drainBEP20Token(IBEP20 token, uint256 amount, address to) external onlyAdmin {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.safeTransfer(to, amount);
    }

    // Enter a unix timestamp that will act as the start time for the sacrifice
    function beginSacrifice(uint256 _unlockTime) external onlyAdmin {
        require(!sacrificeOpen);
        unlockTime = _unlockTime;
        sacrificeOpen = true;
    }
}