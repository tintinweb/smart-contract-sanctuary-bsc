/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9;
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
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

 library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransferSend(IERC20 token, address to, uint256 value) internal {
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
interface IERC20 {
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
contract TripleVaultSale {
     using SafeMath for uint256;
    using SafeERC20 for IERC20;
   
     
    uint256 public maxBuy; // Max Contribution
    uint256 public minBuy; // Min Contribution
    uint8 public currentRound; //What round are we on?
     
    uint256 public runningTotalOfSold; // Tokens that have been sold / sent out


    uint256 private tokenDecimals; //Decimals in the token held
    uint256 private paymentDecimals;

    IERC20 public presaleToken; //Token that is being sold
    IERC20 public paymentToken; //Token to be used for payment


    uint256 public remainingTokens;
    uint256 public allocatedTokens;
    uint256 public allTotalContributed;
    uint256 public totalReferalTokensSent;
    uint randNonce = 0;
    address[] public contributors;
    address payable public owner; // Holds the owner of the token
    bool public privateOpen;

    bool public paused;
    bool public isinitialized;
    bool public finished;
    mapping (address => uint256) public _allocatedTokens;
    mapping (address => uint256) public _allocatedReferalTokens;
    mapping (address => uint256) public _paymentContributed;
    mapping (address => bool) public _hasreferal;
    mapping (address => uint256) public _refercode;
    mapping(uint256=> address) private _referalAddress;
    mapping(uint256=> uint256) private _referalCode;
     

    struct rounds {
        uint8 roundId;
        uint256 tokensAvailable;
        uint256 tokensSold;
        uint256 busdRaised;
        uint256 rate;
        uint256 contributions;
         
    }
    rounds[] public round;
    /* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);
 event Received(address, uint);
    constructor() {
   
        owner = payable(address(msg.sender));
        paused = true;
        isinitialized = false;
        finished = false;
        round.push(rounds(0,500000000000000000000000, 0,0,6250000000000000000, 0));
        round.push(rounds(1,500000000000000000000000, 0,0,6250000000000000000, 0));
        round.push(rounds(2,450000000000000000000000, 0,0,5625000000000000000, 0));
        round.push(rounds(3,405000000000000000000000, 0,0,5062500000000000000, 0));
        round.push(rounds(4,364500000000000000000000, 0,0,4556250000000000000, 0));

        
    }
   function addRound (uint256 _tokensAvailable, uint256 _rate) external{
     require (msg.sender == owner, "Operation unauthorised");
     _tokensAvailable = _tokensAvailable * (10 ** tokenDecimals);
   require (_tokensAvailable > 0, "Need to set how many tokens are availabile");
   require (_rate > 0, "Need to set how many tokens given per 1 payment Token");
         uint8 _roundId = uint8(round.length + 1);
         round.push(rounds(_roundId,_tokensAvailable, 0,0,_rate, 0));
    }  
function initialize (IERC20 _paymentToken, uint8 _paymentDecimals, IERC20 _presaleToken, uint8 _presaleDecimals, uint256 _minBuy, uint256 _MaxBuy) public {
     require (msg.sender == owner, "Operation unauthorised");
      require (isinitialized == false, "Contract already initialized");
     
        require (_minBuy < _MaxBuy, "Min buy should be less than max buy");
    currentRound = 2;
    paymentToken = _paymentToken;
    paymentDecimals = _paymentDecimals;
    presaleToken = _presaleToken;
    _presaleDecimals = _presaleDecimals;
    minBuy = _minBuy * (10**paymentDecimals);
    maxBuy = _MaxBuy * (10**paymentDecimals);
    isinitialized = true;
}


function getTokenBalance () public view returns (uint256) {
 
    return presaleToken.balanceOf(address(this));
}
 function getOwner() public view returns (address) {
        return owner;
    }

    function changeRound(uint8 _round) external{
        require(msg.sender == owner, "Operation unauthorised");
        require (_round < round.length, "Round doesn't exist");
        require(privateOpen == true, "Sale not open");
        currentRound = _round;
         
    }
    function nextRound() external{
        require(msg.sender == owner, "Operation unauthorised");
       
        currentRound = currentRound + 1;
         
    }
    function openPresale() external{
        require(msg.sender == owner, "Operation unauthorised");
        require (isinitialized == true, "Not initialized");
        require (finished == false, "Already been finished");
        require(privateOpen == false, "Sale already open");
        
        privateOpen = true;
        paused = false;
    }
        function finishPresale() external {
        require(msg.sender == owner, "Operation unauthorised");
         
        require(privateOpen == true, "Sale not open");
         
        privateOpen = false;
         finished = true;
        paused = true;
    }
        function withdrawBNB() external {
         require(msg.sender == owner, "Operation unauthorised");
          require(privateOpen == false, "Pre-sale not finished");
         uint256 bnbBalance = address(this).balance;
         require (bnbBalance > 0, "No BNB to withdraw");
        owner.transfer(bnbBalance);
        }

        function updatePaused (bool _paused) external {
             require (msg.sender == owner, "Operation unauthorised");
             paused = _paused;
        }
  function updateRoundRate(uint256 newRate, uint8 _roundlvl) external {
      require (msg.sender == owner, "Operation unauthorised");
      require (_roundlvl < round.length, "Round not found");
      require (currentRound < _roundlvl, "This round must be in the future");
      
       rounds storage _round = round[_roundlvl];
        _round.rate = newRate * (10**tokenDecimals);
       

  }

  function transferOwner(address newOwner) external {
       require (msg.sender == owner, "Operation unauthorised");
      owner = payable(newOwner);

  }
    function updateRound(uint256 _rate, uint8 _roundlvl, uint256 _tokensAvailable) external {
      require (msg.sender == owner, "Operation unauthorised");
      require (_roundlvl < round.length, "Round not found");
      require (currentRound < _roundlvl, "This round must be in the future");
      
       rounds storage _round = round[_roundlvl];
        _round.rate = _rate * (10**tokenDecimals);
        _round.tokensAvailable = _tokensAvailable * (10**tokenDecimals);
 



  }
      function updateRoundTokensAvailable(uint8 _roundlvl, uint256 _tokensAvailable) external {
      require (msg.sender == owner, "Operation unauthorised");
      require (_roundlvl < round.length, "Round not found");
      
      
       rounds storage _round = round[_roundlvl];
       
        _round.tokensAvailable = _tokensAvailable * (10**tokenDecimals);
 



  }

  function updateMinBuy(uint256 minRate) external {
      require (msg.sender == owner, "Operation unauthorised");
      require (minRate < maxBuy, "Minimum buy must be less than Max Buy");
        minBuy = minRate  * (10**paymentDecimals);   

  }
     function updateMaxBuy(uint256 maxRate) external {
      require (msg.sender == owner, "Operation unauthorised");
       require (maxRate >minBuy, "Max buy must be more than Min Buy");
     maxBuy = maxRate  * (10**paymentDecimals);   

  }
 function getAllAddresses ()  public view returns (address[] memory){
     return contributors;
 }
 
 
 
    function withdrawPayments(uint256 amount) external {
         require(msg.sender == owner, "Operation unauthorised");
         require(privateOpen == false, "Pre-sale not finished");
         amount = amount * (10**paymentDecimals); 
        IERC20(paymentToken).transfer(owner, amount);
    }
    function withdrawTokens(uint256 amount) external {
         require(msg.sender == owner, "Operation unauthorised");
        require(privateOpen == false, "Pre-sale not finished");
         amount = amount * (10**tokenDecimals); 
        IERC20(presaleToken).transfer(owner, amount);
    }
    function adminRescueTokensWEI(address token, uint256 amount) external {
         require(msg.sender == owner, "Operation unauthorised");
         require(privateOpen == false, "Pre-sale not finished");
        IERC20(token).transfer(owner, amount);
    }

 

  function contribute(uint256 amount, uint256 refcode) public payable returns (bool success) {
        uint256 senderContributed = _paymentContributed[msg.sender];
        uint256 senderAllocation = _allocatedTokens[msg.sender];
        uint256 sentValue = amount;
        uint256 totalContributed = senderContributed + sentValue;
        bool referal;

        if (_referalCode[refcode] == 0) {
            referal = false;
        }else{
            referal = true;
        }
        require (privateOpen == true, "Sale not open");
        require (paused == false, "Sale is paused");
       
        require (sentValue >= minBuy, "Minimum contribution required");
        require (totalContributed <= maxBuy, "Maximum contribution reached for this wallet; Try a lower value if allowed");

        uint256 newlyAllocated = (sentValue /  (10**paymentDecimals)) * round[currentRound].rate ; // how many allocated on this transaction
        allocatedTokens = allocatedTokens + newlyAllocated;
        require (newlyAllocated <= round[currentRound].tokensAvailable, "Not enough tokens in this round");
        require((newlyAllocated) <= getTokenBalance(), "Not enough token balance to cover this purchase");
        paymentToken.safeTransferFrom(msg.sender, address(this), amount);
        sendTokens(newlyAllocated, msg.sender);
        runningTotalOfSold = runningTotalOfSold + newlyAllocated;
        _allocatedTokens[msg.sender] = senderAllocation + newlyAllocated;
        _paymentContributed[msg.sender] = totalContributed;
        
        allTotalContributed = allTotalContributed + sentValue;
        contributors.push(msg.sender);
        round[currentRound].busdRaised = round[currentRound].busdRaised + sentValue;
        round[currentRound].tokensSold = round[currentRound].tokensSold + newlyAllocated;
        round[currentRound].contributions = round[currentRound].contributions + 1;
        //round[currentRound].tokensAvailable = round[currentRound].tokensAvailable - newlyAllocated;

        if (!_hasreferal[msg.sender] == true) {
        genReferal(msg.sender, newlyAllocated);

        }
        if (referal == true) {
          address receiver = _referalAddress[refcode];
            if (receiver == msg.sender) {
             
          
            }else{
                     
            uint256 reward = (newlyAllocated / 10);
            sendTokens(reward, receiver);
            _allocatedReferalTokens[receiver] = _allocatedReferalTokens[receiver] + reward;
            totalReferalTokensSent = totalReferalTokensSent + reward;
            
            }

        }
       

        
        return true;
 
         
   // mapping (address => uint256) public _allocatedReferalTokens;
     
    //mapping(string=> address) private _referalAddress;
    //mapping(string=> string) private _referalCode;
    }
     function sendTokens (uint256 amount, address to) internal {
        presaleToken.approve(address(this), amount);
        uint256 presaleTokenBalance = IERC20(presaleToken).balanceOf(address(this)); 
        require (presaleTokenBalance >= amount, "Not even tokens in contract to send");
        require ((round[currentRound].tokensAvailable - round[currentRound].tokensSold)  >= amount, "Not enough tokens in this round");
         //safeTransferFrom(tokentosendaddress(to), address(this), amount);
  
        presaleToken.safeTransferSend(address(to), amount);
          
    }


function genReferal(address requester, uint256 amount) public returns (uint256) {
    bool clean = false;
    uint256 ts = 0;
    uint256 multiplier = 1020309;
     
    if (!_hasreferal[requester] == true) {
       ts = (block.timestamp + (amount / multiplier));
    
       do {
        multiplier = multiplier + 1;
         if (_referalCode[ts] == ts) {
             ts = block.timestamp + (amount / multiplier);
         }else{
             clean = true;
         }
     }while (clean == false);

    _hasreferal[requester] = true;
    _referalAddress[ts] = requester;
    _referalCode[ts] = ts;
    _refercode[requester] = ts;
    return ts;
      }else{
          return 0;
      }
}

 
 

}