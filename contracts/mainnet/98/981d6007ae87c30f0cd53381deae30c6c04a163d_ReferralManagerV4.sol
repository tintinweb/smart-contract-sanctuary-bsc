/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;



// Part: IStrategyManager

interface IStrategyManager {
    function operators(address addr) external returns (bool);

    function performanceFee() external returns (uint256);

    function performanceFeeBountyPct() external returns (uint256);

    function stakedTokens(uint256 pid, address user) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _depositAmount) external; 

    function depositFor(uint256 _pid, uint256 _depositAmount, address _for) external;
    
}

// Part: openzeppelin/[email protected]/Address

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

// Part: openzeppelin/[email protected]/Context

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

// Part: openzeppelin/[email protected]/IERC20

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

// Part: IStrategyManagerV4

interface IStrategyManagerV4 is IStrategyManager {

    function isNetPositive(address _account, uint256 _pid) external view returns (bool netPositive);

    function sumOfDeposits(address _account) external view returns (uint256 depositSum);
    
}

// Part: openzeppelin/[email protected]/Ownable

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

// Part: openzeppelin/[email protected]/SafeERC20

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

// Part: MultipleOperator

contract MultipleOperator is Ownable {
    mapping(address => bool) private _operator;

    event OperatorStatusChanged(address indexed _operator, bool _operatorStatus);

    constructor() {
        _operator[_msgSender()] = true;
        _operator[address(this)] = true;
        emit OperatorStatusChanged(_msgSender(), true);
    }

    modifier onlyOperator() {
        require(_operator[msg.sender] == true, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _operator[_msgSender()];
    }

    function isOperator(address _account) public view returns (bool) {
        return _operator[_account];
    }

    function setOperatorStatus(address _account, bool _operatorStatus) public onlyOwner {
        _setOperatorStatus(_account, _operatorStatus);
    }

    function setOperatorStatus(address[] memory _accounts, bool _operatorStatus) external onlyOperator {
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            _setOperatorStatus(_accounts[idx], _operatorStatus);
        }
    }

    function setShareTokenWhitelistType(address[] memory _accounts, bool[] memory _operatorStatuses) external onlyOperator {
        require(_accounts.length == _operatorStatuses.length, "Error: Account and OperatorStatuses lengths not equal");
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            _setOperatorStatus(_accounts[idx], _operatorStatuses[idx]);
        }
    }

    function _setOperatorStatus(address _account, bool _operatorStatus) internal {
        _operator[_account] = _operatorStatus;
        emit OperatorStatusChanged(_account, _operatorStatus);
    }
}

// File: ReferralManagerV4.sol

contract ReferralManagerV4 is MultipleOperator {
    using SafeERC20 for IERC20;

    event AddReferral(address indexed referrer, address indexed referree, uint256 timeStamp); 
    event RemoveReferral(address indexed referrer, address indexed referree, uint256 timeStamp); 
    event CalculateReferralAmounts(address indexed _referrer, address indexed _referee, uint256 _amount);

    //*=============== User Defined Complex Types ===============*//

    struct UserInfo {
        address upline; //Address of referrer
        uint256 firstReferralTime; //Time of first referral.
        uint256 setReferralTime; //Time of first referral.
        uint256 referrals; //Number of referrals for user.
        bool cantCollectReferrals; //If user can collect referrals.
    }

    //*=============== State Variables ===============*//

    uint8 public referralDepth = 8;
    mapping(address => UserInfo) public userInfo;

    uint256 public constant BASIS_POINTS_DENOM = 10_000;

    uint256 public staticACReferrerWeight = 2_000;
    uint256 public staticACReferreeWeight = 1_000;

    uint256 public staticTaxOfficeReferrerWeight = 4_000;
    uint256 public staticTaxOfficeReferreeWeight = 0;

    IStrategyManagerV4 public strategyManager;

    //*=============== Constructor ===============*//

    constructor(
        address _strategyManager
    ) public {
        strategyManager = IStrategyManagerV4(_strategyManager);
    }

    //*===============  Referrals functions ===============*//

    function _setUpline(address _user, address _upline) internal {
        if( userInfo[_user].upline == address(0) && strategyManager.sumOfDeposits(_upline) > 0 ) {
            userInfo[_user].upline = _upline;
            userInfo[_upline].referrals++;
            if (userInfo[_upline].firstReferralTime == 0) {
                userInfo[_upline].firstReferralTime = block.timestamp;
            }
            if (userInfo[_user].setReferralTime == 0) {
                userInfo[_user].setReferralTime = block.timestamp;
            }
            emit AddReferral(_upline, _user, block.timestamp);
        }
    }

    function setUpline(address _upline) external {
        _setUpline(msg.sender, _upline);
    }

    //*=============== AC Referrals ===============*//

    function calculateACReferralAmounts(
        address _user,
        uint256 _pid,
        uint256 _amount
    ) external returns (address _upline, uint256 _referrerAmount, uint256 _referreeAmount) {

        //Set upline address.
        _upline = userInfo[_user].upline;

        //Go up the chain up to referral depth.
        for(uint8 i = 0; i < referralDepth; i++) {

            //If we have reached the top of the chain then exit.
            if(_upline == address(0)){
                break;
            }

            //Check net positive conditions across all pools.
            if (!strategyManager.isNetPositive(_upline, _pid)) { 
                _upline = (i == referralDepth-1) ? address(0) : userInfo[_upline].upline;
                continue; 
            }

            //Check if a user can collect referrals.
            if (!canCollectReferrals(_upline, _user, _pid)) { 
                _upline = (i == referralDepth-1) ? address(0) : userInfo[_upline].upline;
                continue; 
            }

            //Exit loop if found referrer
            break; 
        
        }
        
        //Calculate the referral amount and the referree amount.
        (_referrerAmount, _referreeAmount) = _calculateACReferralAmounts(
            _upline,
            _user,
            _pid,
            _amount
        );

    }

    function _calculateACReferralAmounts(
        address _referrer,
        address _referree,
        uint256 _pid,
        uint256 _amount
    ) public returns (uint256 referrerAmount, uint256 referreeAmount) {

        if (staticACReferrerWeight > 0) {
            referrerAmount = _amount * staticACReferrerWeight / BASIS_POINTS_DENOM;
        }
        if (staticACReferreeWeight > 0) {
            referreeAmount = _amount * staticACReferreeWeight / BASIS_POINTS_DENOM;
        } 

        emit CalculateReferralAmounts(_referrer, _referree, _amount);
    }

    function referreeACCashbackAllowed(
        address _referrer,
        address _referree,
        uint256 _pid
    ) external view returns (bool _referreeCashbackAllowed) {
        address _directReferrer = userInfo[_referree].upline;
        _referreeCashbackAllowed = _referrer != address(0) || (_referree != _directReferrer && _directReferrer != address(0));
    }

    //*=============== Tax Referrals ===============*//

    function calculateTaxOfficeReferralWeights(
        address _user,
        uint256 _pid,
        uint256 _amount
    ) external returns (address _upline, uint256 _referrerWeight, uint256 _referreeWeight) {

        //Set upline address.
        _upline = userInfo[_user].upline;

        //Go up the chain up to referral depth.
        for(uint8 i = 0; i < referralDepth; i++) {

            //If we have reached the top of the chain then exit.
            if(_upline == address(0)){
                break;
            }

            //Check net positive conditions across all pools.
            if (!strategyManager.isNetPositive(_upline, _pid)) { 
                _upline = (i == referralDepth-1) ? address(0) : userInfo[_upline].upline;
                continue; 
            }

            //Check if a user can collect referrals.
            if (!canCollectReferrals(_upline, _user, _pid)) { 
                _upline = (i == referralDepth-1) ? address(0) : userInfo[_upline].upline;
                continue; 
            }

            //Exit loop if found referrer
            break; 
        
        }
        
        //Calculate the referral amount and the referree amount.
        (_referrerWeight, _referreeWeight) = _calculateTaxOfficeReferralWeights(
            _upline,
            _user,
            _pid,
            _amount
        );

    }

    function _calculateTaxOfficeReferralWeights(
        address _referrer,
        address _referree,
        uint256 _pid,
        uint256 _amount
    ) public returns (uint256 referrerWeight, uint256 referreeWeight) {

        referrerWeight = staticTaxOfficeReferrerWeight;
        referreeWeight = staticTaxOfficeReferreeWeight;
        
        emit CalculateReferralAmounts(_referrer, _referree, _amount);
    }

    //*=============== Helper functions ===============*//
    
    function canCollectReferrals(
        address _referrer,
        address _referree,
        uint256 _pid
    ) public view returns (bool) {
        return _referrer != _referree && !userInfo[_referrer].cantCollectReferrals;
    }

    //*=============== Restricted Functions ===============*//

    function setStaticACWeights(
        uint256 _staticACReferrerWeight,
        uint256 _staticACReferreeWeight
    ) external onlyOperator {
        staticACReferrerWeight = _staticACReferrerWeight;
        staticACReferreeWeight = _staticACReferreeWeight;
    }

    function setStaticTaxOfficeWeights(
        uint256 _staticTaxOfficeReferrerWeight,
        uint256 _staticTaxOfficeReferreeWeight
    ) external onlyOperator {
        staticTaxOfficeReferrerWeight = _staticTaxOfficeReferrerWeight;
        staticTaxOfficeReferreeWeight = _staticTaxOfficeReferreeWeight;
    }

    function setStrategyManager(
        address _strategyManager
    ) external onlyOperator {
        strategyManager = IStrategyManagerV4(_strategyManager);
    }

    function setCanCollectReferrals(address _account, bool _canCollectReferrals) external onlyOperator {
        userInfo[_account].cantCollectReferrals = !_canCollectReferrals;
    }

    function setReferralDepth(uint8 _referralDepth) external onlyOperator {
        referralDepth = _referralDepth;
    }

    function setUserUpline(address _user, address _upline) external onlyOperator {
        //Remove upline.
        if (userInfo[_user].upline != address(0)) {
            userInfo[userInfo[_user].upline].referrals--;
            emit RemoveReferral(userInfo[_user].upline, _user, block.timestamp);
        }

        //Set new upline.
        userInfo[_user].upline = _upline;

        //Increase referral count.
        if (_upline != address(0)) {
            userInfo[_upline].referrals++;
            if (userInfo[_upline].firstReferralTime == 0) {
                userInfo[_upline].firstReferralTime = block.timestamp;
            }
            if (userInfo[_user].setReferralTime == 0) {
                userInfo[_user].setReferralTime = block.timestamp;
            }
            emit AddReferral(_upline, _user, block.timestamp);
        }
        
    }

    function setUserInfo(
        address _user,
        address _upline,
        uint256 _firstReferralTime,
        uint256 _setReferralTime,
        uint256 _referrals,
        bool _cantCollectReferrals
    ) external onlyOperator {
        userInfo[_user] = UserInfo({
            upline: _upline,
            firstReferralTime: _firstReferralTime,
            setReferralTime: _setReferralTime,
            referrals: _referrals,
            cantCollectReferrals: _cantCollectReferrals
        });
    }

    function setReferralTrackingInfo(
        address[] calldata _users,
        address[] calldata _uplines,
        uint256[] calldata _firstReferralTimes,
        uint256[] calldata _setReferralTimes,
        uint256[] calldata _numReferrals
    ) external onlyOwner {
        uint256 length = (_users.length);
        for (uint8 idx; idx < length; idx++) {
            userInfo[_users[idx]] = UserInfo({
                upline: _uplines[idx],
                firstReferralTime: _firstReferralTimes[idx],
                setReferralTime: _setReferralTimes[idx],
                referrals: _numReferrals[idx],
                cantCollectReferrals: false
            });
        }
    }

    function withdraw(address _token, address _recipient, uint256 _amount) external onlyOperator {
        IERC20(_token).transfer(_recipient, _amount);
    }   

}