// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Game is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public USDT;
    IERC20 public MBQ;
    
    struct PackageInfo {
        uint256 subscribeAmount;
        uint256 registrationFee;
        uint256 renewalFee;
    }

    struct UserInfo {
        uint256 package;
        uint256 cycle;
        uint256 daysPerCycle;
        uint256 subscribeTimestamp;
        uint256 renewTimestamp;
        uint256 expiryTimestamp;
    }

    PackageInfo[] public packageInfo;
    mapping(address => mapping (uint256 => UserInfo)) public userPackageInfo;
    mapping (address => uint256) private userPackageInfoLength;
    mapping (address => bool) private operator;
    mapping (address => bool) private activated;

    uint256 private constant DENOM = 10000;
    uint256 public subscriptionTax = 500;
    uint256 public renewalTax = 50;
    uint256 public interestRate = 735;
    uint256 public cycleDivider = 3;
    uint256 public initialDaysPerCycle = 7;
    uint256 public maxDaysPerCycle = 21;
    uint256 public secondsPerDay = 60;
    uint256 public quotaAmount;
    uint256 public totalSubscriptionAmount;
    address public taxReceiver;
    uint256 public activationFee = 10 * (10**18);
    address public feeReceiver;

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    constructor(address _usdt, address _mbq, address _taxReceiver, address _feeReceiver, uint256 _quotaAmount) {
        USDT = IERC20(_usdt);
        MBQ = IERC20(_mbq);
        taxReceiver = _taxReceiver;
        quotaAmount = _quotaAmount;
        feeReceiver = _feeReceiver;

        operator[msg.sender] = true;
    }

    function activate() external nonReentrant {
        require(MBQ.balanceOf(msg.sender) >= activationFee, "Insufficient MBQ");
        MBQ.safeTransferFrom(msg.sender, feeReceiver, activationFee);

        activated[msg.sender] = true;

        emit Activate(msg.sender, activationFee);
    }

    function subscribe(uint256 _pid) external nonReentrant {
        require(_pid < packageInfo.length, "Invalid package ID");
        require(isActivated(msg.sender), "Account not activated");
        require(totalSubscriptionAmount + packageInfo[_pid].subscribeAmount <= quotaAmount, "Quota limit reached");
        require(USDT.balanceOf(msg.sender) >= packageInfo[_pid].subscribeAmount, "Insufficient USDT tokens");
        require(MBQ.balanceOf(msg.sender) >= packageInfo[_pid].registrationFee, "Insufficient MBQ tokens");
        
        // Take tax
        uint256 _tax = packageInfo[_pid].subscribeAmount * subscriptionTax / DENOM;
        USDT.safeTransferFrom(msg.sender, taxReceiver, _tax);

        // Take funds
        USDT.safeTransferFrom(msg.sender, address(this), packageInfo[_pid].subscribeAmount - _tax);

        // Take registration fee
        MBQ.safeTransferFrom(msg.sender, feeReceiver, packageInfo[_pid].registrationFee);

        // Create new package profile
        UserInfo storage _userPackageInfo = userPackageInfo[msg.sender][userPackageInfoLength[msg.sender]];
        _userPackageInfo.package = _pid;
        _userPackageInfo.cycle = 1;
        _userPackageInfo.daysPerCycle = initialDaysPerCycle;
        _userPackageInfo.subscribeTimestamp = block.timestamp;
        _userPackageInfo.renewTimestamp = block.timestamp;
        _userPackageInfo.expiryTimestamp = block.timestamp + (initialDaysPerCycle * secondsPerDay) + secondsPerDay;

        // Update user package count
        userPackageInfoLength[msg.sender]++;

        // Update subscription 
        totalSubscriptionAmount += packageInfo[_pid].subscribeAmount;

        emit Subscribe(msg.sender, _pid, packageInfo[_pid].subscribeAmount);
    }

    function renew(uint256 _sid) external nonReentrant {
        UserInfo storage _userPackageInfo = userPackageInfo[msg.sender][_sid];

        if(_sid != 0)
            require(_sid < userPackageInfoLength[msg.sender], "Invalid package ID");
        require(isActivated(msg.sender), "Account not activated");
        require(USDT.balanceOf(msg.sender) >= packageInfo[_userPackageInfo.package].subscribeAmount, "Insufficient USDT tokens");
        require(MBQ.balanceOf(msg.sender) >= packageInfo[_userPackageInfo.package].renewalFee, "Insufficient MBQ tokens");
        require(isRenewable(msg.sender, _sid), "Cannot renew now");
        require(_userPackageInfo.expiryTimestamp > block.timestamp, "Expired");
        
        // Take tax
        uint256 _tax = packageInfo[_userPackageInfo.package].subscribeAmount * renewalTax / DENOM;
        USDT.safeTransferFrom(msg.sender, taxReceiver, _tax);
        // Take funds
        USDT.safeTransferFrom(msg.sender, address(this), packageInfo[_userPackageInfo.package].subscribeAmount - _tax);
        // Take renewal fee
        MBQ.safeTransferFrom(msg.sender, address(this), packageInfo[_userPackageInfo.package].renewalFee);

        // Calculate principal + interest, based on their previous staked amount
        uint256 _rewards = getPendingRewards(msg.sender, _sid);

        // Update user details
        _userPackageInfo.daysPerCycle = calculateDaysPerCycle(msg.sender, _sid);
        _userPackageInfo.cycle += 1;
        _userPackageInfo.renewTimestamp = block.timestamp;
        _userPackageInfo.expiryTimestamp = block.timestamp + (_userPackageInfo.daysPerCycle * secondsPerDay) + secondsPerDay;

        // Transfer rewards to user
        USDT.safeTransfer(msg.sender, _rewards);

        emit Renew(msg.sender, _sid, packageInfo[_userPackageInfo.package].subscribeAmount, _rewards);
    }

    function adjustUserExpiry(address _userAddress, uint256 _sid, uint256 _expiryTimestamp) external nonReentrant {
        UserInfo storage _userPackageInfo = userPackageInfo[_userAddress][_sid];
        _userPackageInfo.expiryTimestamp = _expiryTimestamp;

        emit AdjustUserExpiry(_userAddress, _sid, _expiryTimestamp);
    }

    function registerPackageInfo(uint256 _subscribeAmount, uint256 _registrationFee, uint256 _renewalFee) external onlyOwner {
   
        packageInfo.push(PackageInfo({
            subscribeAmount : _subscribeAmount,
            registrationFee : _registrationFee,
            renewalFee : _renewalFee
        }));

        emit RegisterPackageInfo(_subscribeAmount, _registrationFee, _renewalFee);
    }

    function updatePackageInfo(uint256 _pid, uint256 _subscribeAmount, uint256 _registrationFee, uint256 _renewalFee) external onlyOwner {
        
        PackageInfo storage _packageInfo = packageInfo[_pid];
        _packageInfo.subscribeAmount = _subscribeAmount;
        _packageInfo.registrationFee = _registrationFee;
        _packageInfo.renewalFee = _renewalFee;
        

        emit UpdatePackageInfo(_pid, _subscribeAmount, _registrationFee, _renewalFee);
    }

    function claimBonus(address _to, uint256 _amount) external onlyOperator {
        uint256 _contractBalance = USDT.balanceOf(address(this));
        require(_amount <= _contractBalance, "Insufficient USDT");

        USDT.transfer(_to, _amount);

        emit ClaimBonus(_to, _amount);
    }

    function rescueToken(address _token, address _to, uint256 _amount) external onlyOwner {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        require(_amount <= _contractBalance, "Insufficient token");

        IERC20(_token).transfer(_to, _amount);

        emit RescueToken(_token, _to, _amount);
    }

    // ===================================================================
    // GETTERS
    // ===================================================================

    function isOperator(address _userAddress) public view returns(bool) {
        return operator[_userAddress];
    }

    function isActivated(address _userAddress) public view returns(bool) {
        return activated[_userAddress];
    }

    function getPendingRewards(address _userAddress, uint256 _sid) public view returns(uint256) {
        UserInfo storage _userPackageInfo = userPackageInfo[_userAddress][_sid];
        if(!isRenewable(_userAddress, _sid))
            return 0;

        uint256 _amount = packageInfo[_userPackageInfo.package].subscribeAmount;
        uint256 _interest = packageInfo[_userPackageInfo.package].subscribeAmount * interestRate / DENOM;

        return _amount + _interest;
    }

    function calculateDaysPerCycle(address _userAddress, uint256 _sid) internal view returns(uint256) {
        UserInfo storage _userPackageInfo = userPackageInfo[_userAddress][_sid];

        uint256 _daysPerCycle = initialDaysPerCycle + ((_userPackageInfo.cycle) / cycleDivider);
        if(_daysPerCycle >= maxDaysPerCycle)
            return maxDaysPerCycle;
        else 
            return _daysPerCycle;
    }

    function isRenewable(address _userAddress, uint256 _sid) public view returns(bool) {
        UserInfo storage _userPackageInfo = userPackageInfo[_userAddress][_sid];

        // Return false if no subscribe record under this pid
        if(_userPackageInfo.renewTimestamp == 0)
            return false;

        uint256 _daysPerCycleInSeconds = _userPackageInfo.daysPerCycle * secondsPerDay;

        return block.timestamp > _userPackageInfo.renewTimestamp + _daysPerCycleInSeconds;
    }

    function getUserNextRenewTimestamp(address _userAddress, uint256 _sid) external view returns(uint256) {
        UserInfo storage _userPackageInfo = userPackageInfo[_userAddress][_sid];
        uint256 _daysPerCycleInSeconds = _userPackageInfo.daysPerCycle * secondsPerDay;

        return _userPackageInfo.renewTimestamp + _daysPerCycleInSeconds;
    }

    function getPackageInfoLength() external view returns(uint256) {
        return packageInfo.length;
    }

    function getUserPackageInfoLength(address _userAddress) external view returns(uint256) {
        return userPackageInfoLength[_userAddress];
    }

    // ===================================================================
    // SETTERS
    // ===================================================================

    function setMBQAddress(address _mbq) external onlyOwner {
        require(_mbq != address(0), "Address zero");
        MBQ = IERC20(_mbq);

        emit SetMBQAddress(_mbq);
    }

    function setActivationFee(uint256 _activationFee) external onlyOwner {
        require(_activationFee > 0, "value must be larger than zero");
        activationFee = _activationFee;

        emit SetActivationFee(_activationFee);
    }

    function setInterestRate(uint256 _interestRate) external onlyOwner {
        require(_interestRate > 0, "value must be larger than zero");
        interestRate = _interestRate;

        emit SetInterestRate(_interestRate);
    }

    function setCycleDivider(uint256 _cycleDivider) external onlyOwner {
        require(_cycleDivider > 0, "value must be larger than zero");
        cycleDivider = _cycleDivider;

        emit SetCycleDivider(_cycleDivider);
    }

    function setMaxDaysPerCycle(uint256 _maxDaysPerCycle) external onlyOwner {
        require(_maxDaysPerCycle > 0, "value must be larger than zero");
        maxDaysPerCycle = _maxDaysPerCycle;

        emit SetMaxDaysPerCycle(_maxDaysPerCycle);
    }

    function setQuotaAmount(uint256 _quotaAmount) external onlyOwner {
        require(_quotaAmount > 0, "value must be larger than zero");
        quotaAmount = _quotaAmount;

        emit SetQuotaAmount(_quotaAmount);
    }

    function setSubscriptionTax(uint256 _subscriptionTax) external onlyOwner {
        require(_subscriptionTax > 0, "value must be larger than zero");
        subscriptionTax = _subscriptionTax;

        emit SetSubscriptionTax(_subscriptionTax);
    }

    function setRenewalTax(uint256 _renewalTax) external onlyOwner {
        require(_renewalTax > 0, "value must be larger than zero");
        renewalTax = _renewalTax;

        emit SetRenewalTax(_renewalTax);
    }

    function setTaxReceiver(address _taxReceiver) external onlyOwner {
        require(_taxReceiver != address(0), "address zero");
        taxReceiver = _taxReceiver;

        emit SetTaxReceiver(_taxReceiver);
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        require(_feeReceiver != address(0), "address zero");
        feeReceiver = _feeReceiver;

        emit SetFeeReceiver(_feeReceiver);
    }

    function setOperator(address _userAddress, bool _bool) external onlyOwner {
        require(_userAddress != address(0), "Address zero");
        operator[_userAddress] = _bool;

        emit SetOperator(_userAddress, _bool);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================
    event Activate(address userAddress, uint256 activationFee);
    event Subscribe(address userAddress, uint256 pid, uint256 amount);
    event Renew(address userAddress, uint256 sid, uint256 amount, uint256 rewards);
    event AdjustUserExpiry(address userAddress, uint256 sid, uint256 expiryTimestamp);
    event RegisterPackageInfo(uint256 subscribeAmount, uint256 registrationFee, uint256 renewalFee);
    event UpdatePackageInfo(uint256 pid, uint256 subscribeAmount, uint256 registrationFee, uint256 renewalFee);
    event ClaimBonus(address to, uint256 amount);
    event RescueToken(address token, address to, uint256 amount);

    // SETTERS
    event SetMBQAddress(address mbq);
    event SetActivationFee(uint256 activationFee);
    event SetInterestRate(uint256 interestRate);
    event SetCycleDivider(uint256 cycleDivider);
    event SetMaxDaysPerCycle(uint256 maxDayPerCycle);
    event SetQuotaAmount(uint256 quotaAmount);
    event SetSubscriptionTax(uint256 subscriptionTax);
    event SetRenewalTax(uint256 renewalTax);
    event SetTaxReceiver(address taxReceiver);
    event SetFeeReceiver(address activationFeeReceiver);
    event SetOperator(address userAddress, bool _bool);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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