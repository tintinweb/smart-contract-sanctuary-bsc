/**
 *Submitted for verification at BscScan.com on 2021-08-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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


    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);


    event Unpaused(address account);

    bool private _paused;

 
    constructor() {
        _paused = false;
    }


    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
 
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

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
}

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.8.0;

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
            'SafeBEP20: approve from non-zero to non-zero allowance'
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
            'SafeBEP20: decreased allowance below zero'
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

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

pragma solidity ^0.8.0;
pragma abicoder v2;

/**
 * @title Football
 */
contract Football is Ownable, Pausable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    uint256 public intervalSeconds; // interval in seconds between two prediction rounds

    uint256 public treasuryFee = 500; // treasury rate (e.g. 200 = 2%, 150 = 1.50%)
    uint256 public referralFee = 200;
    uint256 public treasuryAmount; // treasury amount that was not claimed
    uint256 public referralAmount; 

    uint256 public currentEpoch; // current epoch for prediction round
    uint256 constant public DECIMAL = 18;
    uint256 public currentBNBprice;

    uint256 public constant MAX_TREASURY_FEE = 1000; // 10%

    uint256 public random;

    IBEP20 public BUSD;
    IBEP20 public USDT;

    mapping(uint256 => mapping(address => BetInfo)) public ledger;
    mapping(uint256 => Round) public rounds;
    mapping(address => uint256[]) public userRounds;
    mapping(address => address) public referral;

    enum Position {
        None,
        Bull,
        Bear,
        Draw
    }
    enum BetType {
        BNB,
        BUSD,
        USDT
    }

    struct Round {
        uint256 epoch;
        uint256 startTimestamp;
        uint256 closeTimestamp;
        uint256 totalAmount;
        uint256 bullAmount;
        uint256 bearAmount;
        uint256 drawAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        Position result;
        bool oracleCalled;
    }

    struct BetInfo {
        Position position;
        uint256 amount;
        BetType betType;
        uint256 price;
        bool claimed; // default false
    }

    event BetBearWithBNB(address indexed sender, uint256 indexed epoch, uint256 amount);
    event BetBullWithBNB(address indexed sender, uint256 indexed epoch, uint256 amount);
    event BetDrawWithBNB(address indexed sender, uint256 indexed epoch, uint256 amount);
    event BetBearWithToken(address indexed sender, uint256 indexed epoch, uint256 amount, string token);
    event BetBullWithToken(address indexed sender, uint256 indexed epoch, uint256 amount, string token);
    event BetDrawWithToken(address indexed sender, uint256 indexed epoch, uint256 amount, string token);
    event Claim(address indexed sender, uint256 indexed epoch, uint256 amount);
    event EndRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);

    event Pause(uint256 indexed epoch);
    event RewardsCalculated(
        uint256 indexed epoch,
        uint256 rewardBaseCalAmount,
        uint256 rewardAmount,
        uint256 treasuryAmount,
        uint256 referralAmount
    );

    event StartRound(uint256 indexed epoch);
    event TokenRecovery(address indexed token, uint256 amount);
    event TreasuryClaim(uint256 amount);
    event TreasuryClaimBUSD(uint256 amount);
    event TreasuryClaimUSDT(uint256 amount);
    event Unpause(uint256 indexed epoch);
    event NewIntervalSeconds(uint256 intervalSeconds);
    event TokenAddressChanged(address token1, address token2);
    event FeesChanged(uint256 treasuryFee, uint256 referralFee);
    event InjuctFund(uint256 amount);

    
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    constructor(
        uint256 _intervalSeconds
    ) {
        intervalSeconds = _intervalSeconds;
        BUSD = IBEP20(0x802f963c430C6A211046b4d28461A1Ac310dE901);
        USDT = IBEP20(0x13D00E49E43D85e2F4D2E352387a9fA591248714);
    }

    function betBearWithBNB(uint256 epoch, uint256 price, address _referral) external payable whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(msg.value >= 0, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");

        if(_referral == msg.sender) referral[msg.sender] = address(0);
        else referral[msg.sender] = _referral;
        currentBNBprice = price;
        // Update round data
        uint256 amount = (msg.value).mul(price).div(10 ** DECIMAL);  // set bnb price uint not float by multiply 100, amount is 100 times than origin
        Round storage round = rounds[epoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bearAmount = round.bearAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Bear;
        betInfo.amount = amount;
        betInfo.betType = BetType.BNB;
        betInfo.price = price;
        userRounds[msg.sender].push(epoch);

        emit BetBearWithBNB(msg.sender, epoch, amount);
    }
    
    function betBearWithToken(uint256 epoch, uint256 tokenAmount, uint256 price, address _referral, bool isBUSD) external whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(tokenAmount >= 0, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");
        
        if(_referral == msg.sender) referral[msg.sender] = address(0);
        else referral[msg.sender] = _referral;

        if(isBUSD)
            BUSD.safeTransferFrom(address(msg.sender), address(this), tokenAmount);
        else
            USDT.safeTransferFrom(address(msg.sender), address(this), tokenAmount);

        // Update round data
        uint256 amount = tokenAmount.div(10 ** (DECIMAL-2));  // since amount is 100 times than origin, set token price as 100 not 1
        Round storage round = rounds[epoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bearAmount = round.bearAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Bear;
        betInfo.amount = amount;
        betInfo.betType = isBUSD ? BetType.BUSD: BetType.USDT;
        betInfo.price = price;
        userRounds[msg.sender].push(epoch);
        if(isBUSD)
            emit BetDrawWithToken(msg.sender, epoch, tokenAmount, "BUSD");
        else
            emit BetDrawWithToken(msg.sender, epoch, tokenAmount, "USDT");
    }

    function betBullWithBNB(uint256 epoch, uint256 price, address _referral) external payable whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(msg.value >= 0, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");

        if(_referral == msg.sender) referral[msg.sender] = address(0);
        else referral[msg.sender] = _referral;
        currentBNBprice = price;
        // Update round data
        uint256 amount = (msg.value).mul(price).div(10 ** DECIMAL);
        Round storage round = rounds[epoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bullAmount = round.bullAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Bull;
        betInfo.amount = amount;
        betInfo.betType = BetType.BNB;
        betInfo.price = price;
        userRounds[msg.sender].push(epoch);

        emit BetBullWithBNB(msg.sender, epoch, amount);
    }

    
    function betBullWithToken(uint256 epoch, uint256 tokenAmount, uint256 price, address _referral, bool isBUSD) external whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(tokenAmount >= 0, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");

        if(_referral == msg.sender) referral[msg.sender] = address(0);
        else referral[msg.sender] = _referral;
        currentBNBprice = price;
        if(isBUSD)
            BUSD.safeTransferFrom(address(msg.sender), address(this), tokenAmount);
        else
            USDT.safeTransferFrom(address(msg.sender), address(this), tokenAmount);

        // Update round data
        uint256 amount = tokenAmount.div(10 ** (DECIMAL-2));  // since amount is 100 times than origin, set token price as 100 not 1
        Round storage round = rounds[epoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bullAmount = round.bullAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Bull;
        betInfo.amount = amount;
        betInfo.betType = isBUSD ? BetType.BUSD: BetType.USDT;
        betInfo.price = price;
        userRounds[msg.sender].push(epoch);
        if(isBUSD)
            emit BetBullWithToken(msg.sender, epoch, tokenAmount, "BUSD");
        else
            emit BetBullWithToken(msg.sender, epoch, tokenAmount, "USDT");
    }


    function betDrawWithBNB(uint256 epoch, uint256 price, address _referral) external payable whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(msg.value >= 0, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");

        if(_referral == msg.sender) referral[msg.sender] = address(0);
        else referral[msg.sender] = _referral;
        currentBNBprice = price;
        // Update round data
        uint256 amount = (msg.value).mul(price).div(10 ** DECIMAL);
        Round storage round = rounds[epoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.drawAmount = round.drawAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Draw;
        betInfo.amount = amount;
        betInfo.betType = BetType.BNB;
        betInfo.price = price;
        userRounds[msg.sender].push(epoch);

        emit BetDrawWithBNB(msg.sender, epoch, amount);
    }

        
    function betDrawWithToken(uint256 epoch, uint256 tokenAmount, uint256 price, address _referral, bool isBUSD) external whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch, "Bet is too early/late");
        require(_bettable(epoch), "Round not bettable");
        require(tokenAmount >= 0, "Bet amount must be greater than minBetAmount");
        require(ledger[epoch][msg.sender].amount == 0, "Can only bet once per round");
        currentBNBprice = price;
        if(_referral == msg.sender) referral[msg.sender] = address(0);
        else referral[msg.sender] = _referral;

        if(isBUSD)
            BUSD.safeTransferFrom(address(msg.sender), address(this), tokenAmount);
        else
            USDT.safeTransferFrom(address(msg.sender), address(this), tokenAmount);

        // Update round data
        uint256 amount = tokenAmount.div(10 ** (DECIMAL-2));  // since amount is 100 times than origin, set token price as 100 not 1
        Round storage round = rounds[epoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.drawAmount = round.drawAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Draw;
        betInfo.amount = amount;
        betInfo.betType = isBUSD ? BetType.BUSD: BetType.USDT;
        betInfo.price = price;
        userRounds[msg.sender].push(epoch);
        if(isBUSD)
            emit BetBearWithToken(msg.sender, epoch, tokenAmount, 'BUSD');
        else
            emit BetBearWithToken(msg.sender, epoch, tokenAmount, 'USDT');
    }


    function claim(uint256 epochs) external nonReentrant notContract {
        uint256 reward; // Initializes reward
        uint256 referralReward; //Initializes referral reward

        require(rounds[epochs].startTimestamp != 0, "Round has not started");
        require(block.timestamp > rounds[epochs].closeTimestamp, "Round has not ended");

        // Round valid, claim rewards
        if (rounds[epochs].oracleCalled) {
            require(claimable(epochs, msg.sender), "Not eligible for claim");
            Round memory round = rounds[epochs];
            reward = (ledger[epochs][msg.sender].amount * round.rewardAmount) / round.rewardBaseCalAmount;
            referralReward = (ledger[epochs][msg.sender].amount * referralAmount) / round.rewardBaseCalAmount;
        }
        // Round invalid, refund bet amount
        
        if (reward > 0) {
            if(ledger[epochs][msg.sender].betType == BetType.BNB) {
                _safeTransferBNB(address(msg.sender), reward.mul(10 ** DECIMAL).div(ledger[epochs][msg.sender].price));
                if(referral[msg.sender] != address(0)) 
                    _safeTransferBNB(address(referral[msg.sender]), referralReward.mul(10 ** DECIMAL).div(ledger[epochs][msg.sender].price));
            }
                
            else if(ledger[epochs][msg.sender].betType == BetType.BUSD) {
                BUSD.safeTransfer(address(msg.sender), reward.mul(10 ** (DECIMAL - 2)));
                if(referral[msg.sender] != address(0))
                    BUSD.safeTransfer(address(referral[msg.sender]), referralReward.mul(10 ** (DECIMAL - 2)));
            }
                
            else {
                USDT.safeTransfer(address(msg.sender), reward.mul(10 ** (DECIMAL - 2)));
                if(referral[msg.sender] != address(0))
                    USDT.safeTransfer(address(referral[msg.sender]), referralReward.mul(10 ** (DECIMAL - 2)));
            }
        }

        ledger[epochs][msg.sender].claimed = true;

        emit Claim(msg.sender, epochs, reward);
    }

    function startRound(uint256 epoch) external onlyOwner whenNotPaused nonReentrant notContract {
        require(epoch == currentEpoch + 1, "Round is not correct");
        if(epoch > 3) require(rounds[epoch-2].oracleCalled, "Last Lottery not Over");
        currentEpoch = epoch;
        _startRound(epoch);
    }

    function executeRound(uint256 epoch) external whenNotPaused nonReentrant onlyOwner {
        require(block.timestamp >= rounds[epoch].closeTimestamp, "Lottery not over");
        require(!rounds[epoch].oracleCalled, "Already executed");
        Round storage round = rounds[epoch];

        random = getRandom() % 100;
        // uint32 finalNumber = random(round)
        if(random < 45) round.result = Position.Bear;
        else if(random >= 45 && random < 55) round.result = Position.Draw;
        else round.result = Position.Bull;
        round.oracleCalled = true;
        _calculateRewards(epoch);
    }
    
    function getRandom() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
        block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
        block.gaslimit + 
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
        block.number
        ))); 
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
        emit Pause(currentEpoch);
    }

    function claimTreasuryInBNB() external nonReentrant onlyOwner {
        require(treasuryAmount > 0, "Treasury is empty");
        uint256 currentTreasuryAmountInWei = treasuryAmount.mul(10 ** DECIMAL).div(currentBNBprice);

        if(address(this).balance < currentTreasuryAmountInWei)
            currentTreasuryAmountInWei = address(this).balance;

        treasuryAmount = treasuryAmount.sub(currentTreasuryAmountInWei.mul(currentBNBprice).div(10 ** DECIMAL));
        _safeTransferBNB(msg.sender, currentTreasuryAmountInWei);
        emit TreasuryClaim(currentTreasuryAmountInWei);
    }
    function claimTreasuryInBUSD() external nonReentrant onlyOwner {
        require(treasuryAmount > 0, "Treasury is empty");
        uint256 currentTreasuryAmount = treasuryAmount.mul(10 ** (DECIMAL - 2));
        if(BUSD.balanceOf(address(this)) < currentTreasuryAmount)
            currentTreasuryAmount = BUSD.balanceOf(address(this));
        
        treasuryAmount = treasuryAmount.sub(currentTreasuryAmount.div(10 ** (DECIMAL - 2)));
        BUSD.safeTransfer(msg.sender, currentTreasuryAmount);
        emit TreasuryClaimBUSD(currentTreasuryAmount);
    }
    function claimTreasuryInUSDT() external nonReentrant onlyOwner {
        require(treasuryAmount > 0, "Treasury is empty");
        uint256 currentTreasuryAmount = treasuryAmount.mul(10 ** (DECIMAL - 2));
        if(USDT.balanceOf(address(this)) < currentTreasuryAmount)
            currentTreasuryAmount = USDT.balanceOf(address(this));
        
        treasuryAmount = treasuryAmount.sub(currentTreasuryAmount.div(10 ** (DECIMAL - 2)));
        USDT.safeTransfer(msg.sender, currentTreasuryAmount);
        emit TreasuryClaimUSDT(currentTreasuryAmount);
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();

        emit Unpause(currentEpoch);
    }

    function setBufferAndIntervalSeconds(uint256 _intervalSeconds)
        external
        whenPaused
        onlyOwner
    {
        intervalSeconds = _intervalSeconds;
        emit NewIntervalSeconds(_intervalSeconds);
    }

    function recoverToken(address _token, uint256 _amount) external onlyOwner {
        IBEP20(_token).safeTransfer(address(msg.sender), _amount);

        emit TokenRecovery(_token, _amount);
    }

    function getUserRounds(
        address user,
        uint256 cursor,
        uint256 size
    )
        external
        view
        returns (
            uint256[] memory,
            BetInfo[] memory,
            uint256
        )
    {
        uint256 length = size;

        if (length > userRounds[user].length - cursor) {
            length = userRounds[user].length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        BetInfo[] memory betInfo = new BetInfo[](length);

        for (uint256 i = 0; i < length; i++) {
            values[i] = userRounds[user][cursor + i];
            betInfo[i] = ledger[values[i]][user];
        }

        return (values, betInfo, cursor + length);
    }

    function getUserRoundsLength(address user) external view returns (uint256) {
        return userRounds[user].length;
    }

    function claimable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Round memory round = rounds[epoch];
        
        return
            round.oracleCalled &&
            betInfo.amount != 0 &&
            !betInfo.claimed &&
            ((round.result == betInfo.position));
    }

    function _calculateRewards(uint256 epoch) internal {
        require(rounds[epoch].rewardBaseCalAmount == 0 && rounds[epoch].rewardAmount == 0, "Rewards calculated");
        Round storage round = rounds[epoch];
        uint256 rewardBaseCalAmount;
        uint256 treasuryAmt;
        uint256 referralAmt;
        uint256 rewardAmount;

        // Bull wins
        if (round.result == Position.Bull) {
            rewardBaseCalAmount = round.bullAmount;
            treasuryAmt = (round.totalAmount * treasuryFee) / 10000;
            referralAmt = (round.totalAmount * referralFee) / 10000;
            rewardAmount = round.totalAmount - treasuryAmt- referralAmt;
        }
        // Bear wins
        else if (round.result == Position.Bear) {
            rewardBaseCalAmount = round.bearAmount;
            treasuryAmt = (round.totalAmount * treasuryFee) / 10000;
            referralAmt = (round.totalAmount * referralFee) / 10000;
            rewardAmount = round.totalAmount - treasuryAmt- referralAmt;
        }
        // Draw wins
        else {
            rewardBaseCalAmount = round.drawAmount;
            treasuryAmt = (round.totalAmount * treasuryFee) / 10000;
            referralAmt = (round.totalAmount * referralFee) / 10000;
            rewardAmount = round.totalAmount - treasuryAmt- referralAmt;
        }
        round.rewardBaseCalAmount = rewardBaseCalAmount;
        round.rewardAmount = rewardAmount;

        // Add to treasury
        treasuryAmount += treasuryAmt;
        referralAmount += referralAmt;

        emit RewardsCalculated(epoch, rewardBaseCalAmount, rewardAmount, treasuryAmt, referralAmt);
    }

    function changeTokenAddress(address _first, address _second) external whenPaused onlyOwner {
        require(
            _first != address(0) || _second != address(0),
            "Token address cannot be 0"
        );
        BUSD = IBEP20(_first);
        USDT = IBEP20(_second);
        emit TokenAddressChanged(_first, _second);
    }

    function injuctFund() external payable onlyOwner {
        // treasuryAmount += msg.value;
        emit InjuctFund(msg.value);
    }

    function changeTreasuryAndReferralFees(uint256 _treasuryFee, uint256 _referralFee) external whenPaused onlyOwner {
        require(_treasuryFee <= 10000 || _referralFee <= 10000, "Fees must be less than 10000");
        require(_treasuryFee > 0 || _referralFee > 0, "Fees must be greater than 0");
        treasuryFee = _treasuryFee;
        referralFee = _referralFee;
        emit FeesChanged(treasuryFee, referralFee);
    }


    function _safeTransferBNB(address to, uint256 value) internal {
        if(address(this).balance < value)
            value = address(this).balance;
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function _startRound(uint256 epoch) internal {
        Round storage round = rounds[epoch];
        round.startTimestamp = block.timestamp;
        round.closeTimestamp = block.timestamp + (intervalSeconds);
        round.epoch = epoch;
        round.result = Position.None;
        round.totalAmount = 0;
        round.bearAmount = 0;
        round.bullAmount = 0;
        round.drawAmount = 0;
        
        emit StartRound(epoch);
    }

    function _bettable(uint256 epoch) internal view returns (bool) {
        return
            rounds[epoch].startTimestamp != 0 &&
            block.timestamp > rounds[epoch].startTimestamp &&
            block.timestamp < rounds[epoch].closeTimestamp - 20;
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function viewCurrentLotteryId() external view returns (uint256) {
        return currentEpoch;
    }
}