/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// File: interfaces/ILaunchPadFactory.sol

pragma solidity =0.8.4;

interface ILaunchPadFactory {
    
    event feeReceiverChanged(address indexed previousFeeReceiver, address indexed newFeeReceiver);
    event presaleCreated(
        address _token,
        uint256 _buyLimit, 
        uint256 _hardCap, 
        uint256 _tokensPerEth, 
        uint256 _durationTime, 
        bool _referrals, 
        string _presaleInfo
    );
    event presaleAborted(address _presale, uint256 _timestamp);
    event presaleWhitelisted(address _presale);

    function feeReceiver() external view returns (address);
    function router() external view returns (address);  
    function factory() external view returns (address);  
    function weth() external view returns (address);  

    function getPresaleOwner(address _presale) external view returns (address owner);
    function isWhiteListed(address _presale) external view returns (bool whitelisted);
    function getPresales(address _owner, uint256 _index) external view returns  (address presales);
    function getPresalesLenght(address _owner) external view returns (uint256 length);
    function getPresaleNonce(address _token) external view returns  (uint16 nonce);

    function allPresales(uint256) external view returns (address presale);
    function allPresalesLength() external view returns (uint256);


    function abortPresale(address payable _presale) external;
    function emergencyAbort(address payable _presale) external;    
    function changePresaleInfo(address payable _presale, string memory _presaleInfo) external;
    function setFeeReceiver(address _feeReceiver) external;
    function whiteListPresale(address _presale) external;

    function setMinimumHardCap(uint256 _minimumHardCap) external;
    function getNextPresaleAddress(address _token) external view returns (address _address);
    function calculatePresaleAddress(address _token, uint16 _nonce) external view returns (address _address);

    function createPresale(
        address _token, 
        uint256 _buyLimit,
        uint256 _hardCap, 
        uint256 _tokensPerEth,
        uint256 _durationTime, 
        bool _referrals,
        string memory _presaleInfo
    ) external;
}





// File: interfaces/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
// File: interfaces/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// File: interfaces/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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

// File: LaunchPadDPLP.sol

pragma solidity ^0.8.0;






contract LaunchPadDPLP {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier hasDripped {
        if (dividendPool > 0) {
          uint256 secondsPassed = SafeMath.sub(block.timestamp, lastDripTime);
          uint256 dividends = secondsPassed.mul(dividendPool).div(dailyRate);

          if (dividends > dividendPool) {
            dividends = dividendPool;
          }

          profitPerShare = SafeMath.add(profitPerShare, (dividends * magnitude) / tokenSupply);
          dividendPool = dividendPool.sub(dividends);
          lastDripTime = block.timestamp;
        }
        _;
    }

    modifier onlyTokenHolders {
        require(myShares() > 0);
        _;
    }

    modifier onlyDivis {
        require(myRewards() > 0);
        _;
    }

    event onDonation(
        address indexed userAddress,
        uint256 tokens
    );

    event onStake(
        address indexed userAddress,
        uint256 incomingTokens,
        uint256 timestamp
    );

    event onUnstake(
        address indexed customerAddress,
        uint256 tokenRemoved,
        uint256 timestamp
    );

    event onReinvest(
        address indexed customerAddress,
        uint256 tokensReinvested
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 tokensWithdrawn
    );

    uint256 constant private magnitude = 2 ** 64;
    uint32 constant private dailyRate = 11520000; //0.75% a day
    uint8 constant private buyInFee = 75;
    uint8 constant private sellOutFee = 75;
    uint8 constant private vaultFee = 25;

    mapping(address => uint256) private tokenBalanceLedger;
    mapping(address => int256) private payoutsTo;

    uint256 public dividendPool = 0;
    uint256 public lastDripTime = block.timestamp;
    uint256 public totalDonation = 0;
    uint256 public totalVaultFundReceived = 0;
    uint256 public totalVaultFundCollected = 0;

    uint256 private tokenSupply = 0;
    uint256 private profitPerShare = 0;

    IERC20 public pair;
    ILaunchPadFactory launchPadFactory;

    constructor(address _launchPadFactory, address _pair) {
        launchPadFactory= ILaunchPadFactory(_launchPadFactory);
        pair = IERC20(_pair);
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }

    function donateToPool(uint256 _amount) public {
        require(_amount > 0 && tokenSupply > 0, "must be a positive value and have supply");
        pair.safeTransferFrom(msg.sender, address(this), _amount);
        totalDonation += _amount;
        dividendPool = dividendPool.add(_amount);
        emit onDonation(msg.sender, _amount);
    }

    function payVault() public {
        uint256 _tokensToPay = tokensToPay();
        require(_tokensToPay > 0);
        pair.safeTransfer(launchPadFactory.feeReceiver(), _tokensToPay);
        totalVaultFundReceived = totalVaultFundReceived.add(_tokensToPay);
    }

    function reinvest() hasDripped onlyDivis public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myRewards();
        payoutsTo[_customerAddress] +=  (int256) (_dividends.mul(magnitude));
        uint256 _tokens = purchaseTokens(_customerAddress, _dividends);
        emit onReinvest(_customerAddress, _tokens);
    }

    function withdraw() hasDripped onlyDivis public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myRewards();
        payoutsTo[_customerAddress] += (int256) (_dividends.mul(magnitude));
        pair.safeTransfer(_customerAddress, _dividends);
        emit onWithdraw(_customerAddress, _dividends);
    }

    function deposit(uint256 _amount) hasDripped public returns (uint256) {
        pair.safeTransferFrom(msg.sender, address(this), _amount);
        return purchaseTokens(msg.sender, _amount);
    }

    function _purchaseTokens(address _customerAddress, uint256 _incomingTokens) private returns(uint256) {
        uint256 _amountOfTokens = _incomingTokens;

        require(_amountOfTokens > 0 && _amountOfTokens.add(tokenSupply) > tokenSupply);

        tokenSupply = tokenSupply.add(_amountOfTokens);
        tokenBalanceLedger[_customerAddress] =  tokenBalanceLedger[_customerAddress].add(_amountOfTokens);

        int256 _updatedPayouts = (int256) (profitPerShare.mul(_amountOfTokens));
        payoutsTo[_customerAddress] += _updatedPayouts;

        return _amountOfTokens;
    }

    function purchaseTokens(address _customerAddress, uint256 _incomingTokens) private returns (uint256) {
        require(_incomingTokens > 0);

        uint256 _dividendFee = _incomingTokens.mul(buyInFee).div(1000);

        uint256 _vaultFee = _incomingTokens.mul(vaultFee).div(1000);

        uint256 _entryFee = _incomingTokens.mul(100).div(1000);
        uint256 _taxedTokens = _incomingTokens.sub(_entryFee);

        uint256 _amountOfTokens = _purchaseTokens(_customerAddress, _taxedTokens);

        dividendPool = dividendPool.add(_dividendFee);
        totalVaultFundCollected = totalVaultFundCollected.add(_vaultFee);

        emit onStake(_customerAddress, _amountOfTokens, block.timestamp);

        return _amountOfTokens;
    }

    function remove(uint256 _amountOfTokens) hasDripped onlyTokenHolders public {
        address _customerAddress = msg.sender;
        require(_amountOfTokens > 0 && _amountOfTokens <= tokenBalanceLedger[_customerAddress]);

        uint256 _dividendFee = _amountOfTokens.mul(sellOutFee).div(1000);
        uint256 _vaultFee = _amountOfTokens.mul(vaultFee).div(1000);
        uint256 _taxedTokens = _amountOfTokens.sub(_dividendFee).sub(_vaultFee);

        tokenSupply = tokenSupply.sub(_amountOfTokens);
        tokenBalanceLedger[_customerAddress] = tokenBalanceLedger[_customerAddress].sub(_amountOfTokens);

        int256 _updatedPayouts = (int256) ((profitPerShare.mul(_amountOfTokens)).add(_taxedTokens.mul(magnitude)));
        payoutsTo[_customerAddress] -= _updatedPayouts;

        dividendPool = dividendPool.add(_dividendFee);
        totalVaultFundCollected = totalVaultFundCollected.add(_vaultFee);
          
        emit onUnstake(_customerAddress, _taxedTokens, block.timestamp);
    }

    function totalTokenBalance() public view returns (uint256) {
        return pair.balanceOf(address(this));
    }

    function totalSupply() public view returns(uint256) {
        return tokenSupply;
    }

    function myShares() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return sharesOf(_customerAddress);
    }

    function myEstimateRewards() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return estimateRewardsOf(_customerAddress);
    }

    function estimateRewardsOf(address _customerAddress) public view returns (uint256) {
        uint256 _profitPerShare = profitPerShare;

        if (dividendPool > 0) {
          uint256 secondsPassed = 0;
       
          secondsPassed = SafeMath.sub(block.timestamp, lastDripTime);

          uint256 dividends = secondsPassed.mul(dividendPool).div(dailyRate);

          if (dividends > dividendPool) {
            dividends = dividendPool;
          }

          _profitPerShare = SafeMath.add(_profitPerShare, (dividends * magnitude) / tokenSupply);
        }

        return (uint256) ((int256) (_profitPerShare * tokenBalanceLedger[_customerAddress]) - payoutsTo[_customerAddress]) / magnitude;
    }

    function myRewards() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return rewardsOf(_customerAddress) ;
    }

    function rewardsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare * tokenBalanceLedger[_customerAddress]) - payoutsTo[_customerAddress]) / magnitude;
    }

    function sharesOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger[_customerAddress];
    }

    function tokensToPay() public view returns(uint256) {
        return totalVaultFundCollected.sub(totalVaultFundReceived);
    }
}