/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;



// Part: IReferralManagerV4

interface IReferralManagerV4 {

    function BASIS_POINTS_DENOM() external view returns (uint256);

    function staticReferrerPercent() external view returns (uint256);
    function staticReferreePercent() external view returns (uint256);

    function calculateReferralAmounts(
        address _referrer, 
        uint256 _referrerStartTime, 
        address _referree, 
        uint256 _referreeStartTime, 
        uint256 _pid, 
        uint256 _amount
    ) external returns (uint256 referrerAmount, uint256 referreeAmount);

    function canCollectReferrals(address _referrer, address _referree, uint256 _pid) external returns (bool);

    function setUpline(address _user, address _upline) external;

    function referreeACCashbackAllowed(
        address _referrer,
        address _referree,
        uint256 _pid
    ) external view returns (bool _referreeCashbackAllowed);

    function calculateACReferralAmounts(
        address _user,
        uint256 _pid,
        uint256 _amount
    ) external returns (address _upline, uint256 _referrerAmount, uint256 _referreeAmount);

}

// Part: IVaultStrategy

interface IVaultStrategy {
    function stakeToken() external view returns (address);

    function userShares(address _user) external view returns(uint256, uint256, uint256);

    function userStakedTokens(address _user) external view returns (uint256);

    function totalStakeTokens() external view returns (uint256);

    function sharesTotal() external view returns (uint256);

    function deposit(uint256 _depositAmount, address _recipient) external returns (uint256);

    function earn(address _bountyHunter) external returns (uint256);

    function withdraw(uint256 _withdrawAmount, address _user) external returns (uint256);

    function getVestedShares(address _user) external view returns(uint256 vestedAmount);

    function setSwapRouter(address _router) external;

    function setSwapPath(
        address _token0,
        address _token1,
        address[] calldata _path
    ) external;

    function removeSwapPath(address _token0, address _token1) external;

    function setExtraEarnTokens(address[] calldata _extraEarnTokens) external;

    function addBurnToken(
        address _token, 
        uint256 _weight, 
        address _burnAddress, 
        address[] calldata _earnToBurnPath,
        address[] calldata _burnToEarnPath
    ) external; 

    function removeBurnToken(uint256 _index) external;  

    function setBurnToken(
        address _token,
        uint256 _weight,
        address _burnAddress,
        uint256 _index
    ) external;

    function setBaselineTaxRate(uint256 _baselineTaxRate) external;
    
    function setTaxWallet(address _taxWallet) external;

    function transferOwnership(address _owner) external;

    function userVestedTokens(address _user) external view returns (uint256);

    function pendingUserRewards(address _user) external view returns (uint256);

    function pendingVaultRewards() external view returns (uint256);

    function baselineTaxRate() external view returns (uint256);

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

// Part: openzeppelin/[email protected]/ReentrancyGuard

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

// Part: StrategyManager

contract StrategyManager is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    // using EnumerableSet for EnumerableSet.UintSet;

    //*=============== User Defined Complex Types ===============*//

    struct PoolInfo {
        IERC20 stakeToken; // address of the token staked on the underlying farm
        IVaultStrategy strategy; // address of the strategy for the pool
    }

    //*=============== State Variables. ===============*//

    //Strategy manager operators.
    mapping(address => bool) public operators;

    //Farm & Pool info.
    PoolInfo[] public poolInfo;
    // mapping(address => EnumerableSet.UintSet) private userStakedPools;

    //Map used to ensure strategies cannot be added twice
    mapping(address => bool) public strategyExists; // 

    //Performance fee 
    uint256 constant PERFORMANCE_FEE_CAP = 500;
    uint256 public performanceFee = 400;
    uint256 public performanceFeeBountyPct = 2_500;

    //*=============== Events. ===============*//

    event Add(IERC20 stakeToken, IVaultStrategy strategy);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 timeStamp);
    event ResetHistory(address indexed user, uint256 indexed pid, uint256 timeStamp);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 timeStamp);
    event Earn(address indexed user, uint256 indexed pid, uint256 bountyReward);
    event SetOperator(address addr, bool isOperator);
    event SetPerformanceFee(uint256 performanceFee);
    event SetPerformanceFeeBountyPct(uint256 performanceFeeBountyPct);
    event SetStrategyRouter(IVaultStrategy strategy, address router);
    event SetStrategySwapPath(IVaultStrategy _strategy, address _token0, address _token1, address[] _path);
    event RemoveStrategySwapPath(IVaultStrategy _strategy, address _token0, address _token1);
    event SetStrategyExtraEarnTokens(IVaultStrategy _strategy, address[] _extraEarnTokens);
    event AddStrategyBurnToken(IVaultStrategy _strategy, address _token, uint256 _weight, address _burnAddress);
    event SetStrategyBurnToken(IVaultStrategy _strategy, address _token, uint256 _weight, address _burnAddress, uint256 _index);
    event RemoveStrategyBurnToken(IVaultStrategy _strategy, uint256 _index);

    //*=============== Modifiers. ===============*//
    modifier onlyOperator() {
        require(operators[msg.sender], "Error StrategyManager: onlyOperator, NOT_ALLOWED");
        _;
    }

    //*=============== Constructor/Initializer. ===============*//

    constructor() {
        operators[msg.sender] = true;
    }
    //*=============== Functions. ===============*//

    //Default receive function. Handles native token pools.
    receive() external payable {}

    function resetHistory(uint256 _pid) external {
        emit ResetHistory(msg.sender, _pid, block.timestamp);
    }

    //Vault property functions.
    function setOperator(address _addr, bool _isOperator) external onlyOwner {
        operators[_addr] = _isOperator;
        emit SetOperator(_addr, _isOperator);
    }

    function setPerformanceFee(uint256 _performanceFee) external onlyOwner {
        require(_performanceFee <= PERFORMANCE_FEE_CAP, "Error: Performance fee cap exceeded");
        performanceFee = _performanceFee;
        emit SetPerformanceFee(_performanceFee);
    }

    function setPerformanceFeeBountyPct(uint256 _performanceFeeBountyPct) external onlyOwner {
        require(_performanceFeeBountyPct <= 10_000, "Error: Performance fee bounty precentage cap exceeded");
        performanceFeeBountyPct = _performanceFeeBountyPct;
        emit SetPerformanceFeeBountyPct(_performanceFeeBountyPct);
    }

    // //User staked pool functions.
    // function userStakedPoolLength(address _user) external view returns (uint256) {
    //     return userStakedPools[_user].length();
    // }

    // function userStakedPoolAt(address _user, uint256 _index) external view returns (uint256) {
    //     return userStakedPools[_user].at(_index);
    // }

    function userStakedTokens(uint256 _pid, address _user) external view returns (uint256) {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        return strategy.userStakedTokens(_user);
    }

    function userStakedShares(uint256 _pid, address _user) external view returns (uint256 userSharesAmount) {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        (userSharesAmount,,) = strategy.userShares(_user);
    }

    function userVestedShares(uint256 _pid, address _user) external view returns (uint256 userVestedSharesAmount) {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        userVestedSharesAmount = strategy.getVestedShares(_user);
    }

    function userVestedTokens(uint256 _pid, address _user) external view returns (uint256 userVestedTokensAmount) {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        userVestedTokensAmount = strategy.userVestedTokens(_user);
    }

    function userPendingRewards(uint256 _pid, address _user) external view returns(uint256 userPendingRewardsAmount) {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        userPendingRewardsAmount = strategy.pendingUserRewards(_user);
    }

    function strategyPendingRewards(uint256 _pid) external view returns(uint256 strategyRewardsAmount) {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        strategyRewardsAmount = strategy.pendingVaultRewards();
    }



    //Vault Manager functions
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(
        IVaultStrategy _strategy
    ) public onlyOperator {
        require(!strategyExists[address(_strategy)], "Error: Strategy already exists");
        IERC20 stakeToken = IERC20(_strategy.stakeToken());
        poolInfo.push(PoolInfo({stakeToken: stakeToken, strategy: _strategy}));
        strategyExists[address(_strategy)] = true;
        emit Add(stakeToken, _strategy);
    }

    //Individual strategy functions.
    function setStrategyRouter(
        IVaultStrategy _strategy,
        address _router
    ) external onlyOwner {
        _strategy.setSwapRouter(_router);
        emit SetStrategyRouter(_strategy, _router);
    }

    function setStrategySwapPath(
        IVaultStrategy _strategy,
        address _token0,
        address _token1,
        address[] calldata _path
    ) external onlyOwner {
        _strategy.setSwapPath(_token0, _token1, _path);
        emit SetStrategySwapPath(_strategy, _token0, _token1, _path);
    }

    function removeStrategySwapPath(
        IVaultStrategy _strategy,
        address _token0,
        address _token1
    ) external onlyOwner {
        _strategy.removeSwapPath(_token0, _token1);
        emit RemoveStrategySwapPath(_strategy, _token0, _token1);
    }

    function setStrategyExtraEarnTokens(
        IVaultStrategy _strategy, 
        address[] calldata _extraEarnTokens
    ) external onlyOwner {
        require(_extraEarnTokens.length <= 5, "Error: Extra tokens set cap excluded");

        //Sanity check for all being tokens.
        for (uint256 i; i < _extraEarnTokens.length; i++) {
            IERC20(_extraEarnTokens[i]).balanceOf(address(this));
        }

        _strategy.setExtraEarnTokens(_extraEarnTokens);
        emit SetStrategyExtraEarnTokens(_strategy, _extraEarnTokens);
    }

    function addStrategyBurnToken(
        IVaultStrategy _strategy,
        address _token, 
        uint256 _weight, 
        address _burnAddress, 
        address[] calldata _earnToBurnPath, 
        address[] calldata _burnToEarnPath
    ) external onlyOwner {
        _strategy.addBurnToken(_token, _weight, _burnAddress, _earnToBurnPath, _burnToEarnPath);
        emit AddStrategyBurnToken(_strategy, _token, _weight, _burnAddress);
    } 

    function setStrategyBurnToken(
        IVaultStrategy _strategy,
        address _token,
        uint256 _weight,
        address _burnAddress,
        uint256 _index
    ) external  onlyOwner {
        _strategy.setBurnToken(_token, _weight, _burnAddress, _index);
        emit SetStrategyBurnToken(_strategy, _token, _weight, _burnAddress, _index);
    }  

    function removeStrategyBurnToken(
        IVaultStrategy _strategy,
        uint256 _index
    ) external  onlyOwner {
        _strategy.removeBurnToken(_index);
        emit RemoveStrategyBurnToken(_strategy, _index);
    } 
    
    //Deposit functions.
    function _deposit(
        uint256 _pid,
        uint256 _depositAmount,
        address _for,
        address _origin
    ) internal virtual returns (uint256 sharesAdded) {
        require(_depositAmount > 0, "Error: Deposit amount must be greater than 0");
        PoolInfo memory pool = poolInfo[_pid];

        //Earn on behalf of protocol.
        if (pool.strategy.sharesTotal() > 0) { _protocolEarn(pool.strategy); }

        //Account for transfer tax.
        uint256 balanceBefore = pool.stakeToken.balanceOf(address(pool.strategy));
        pool.stakeToken.safeTransferFrom(_origin, address(pool.strategy), _depositAmount);
        _depositAmount = pool.stakeToken.balanceOf(address(pool.strategy)) - balanceBefore;
        
        //Deposit and add shares on behalf of user & log shares.
        sharesAdded = pool.strategy.deposit(_depositAmount, _for);
        // userStakedPools[_for].add(_pid);

        emit Deposit(_for, _pid, _depositAmount, block.timestamp);
    }

    function deposit(
        uint256 _pid, 
        uint256 _depositAmount
    ) external nonReentrant {
        _deposit(_pid, _depositAmount, msg.sender, msg.sender);
    }

    function depositFor(
        uint256 _pid,
        uint256 _depositAmount,
        address _for
    ) external nonReentrant {
        _deposit(_pid, _depositAmount, _for, msg.sender);
    }

    //Withdraw functions.
    //_user is used to calculate the # of shares available and therefore is the accounts contributions that are affected.
    function _withdraw(
        address _user,
        uint256 _pid,
        uint256 _withdrawAmount
    ) internal  virtual {
        require(_withdrawAmount > 0, "Error: Deposit amount must be greater than 0");
        IVaultStrategy strategy = poolInfo[_pid].strategy;

        //Get the total amount of shares & earn on behalf of protocol.
        (uint256 userShares,,) = strategy.userShares(_user);
        uint256 sharesTotal = strategy.sharesTotal();
        require(userShares > 0 && sharesTotal > 0, 'Error: No shares to withdraw.');
        _protocolEarn(strategy);

        //Withdraw and remove shares for the user.
        uint256 sharesRemoved = strategy.withdraw(_withdrawAmount, _user);

        //Remove the pool for the user if they have no balance.
        userShares = userShares > sharesRemoved ? userShares - sharesRemoved : 0;
        // if (userShares == 0) { userStakedPools[_user].remove(_pid); }

        emit Withdraw(_user, _pid, _withdrawAmount, block.timestamp);
        if (userShares == 0) { emit ResetHistory(_user, _pid, block.timestamp); }
    }

    function withdraw(uint256 _pid, uint256 _withdrawAmount) external nonReentrant {
        _withdraw(msg.sender, _pid, _withdrawAmount);
    }

    function withdrawVestedAmount(uint256 _pid) external nonReentrant {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        _withdraw(msg.sender, _pid, strategy.userVestedTokens(msg.sender));
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        _withdraw(msg.sender, _pid, type(uint256).max);
    }

    //Earn functions...
    function _earn(uint256 _pid) internal nonReentrant returns (uint256 bountyRewarded) {
        bountyRewarded = poolInfo[_pid].strategy.earn(msg.sender);
        emit Earn(msg.sender, _pid, bountyRewarded);
    }

    function earn(uint256 _pid) external returns (uint256) {
        return _earn(_pid);
    }

    function earnMany(uint256[] calldata _pids) external {
        for (uint256 i; i < _pids.length; i++) {
            _earn(_pids[i]);
        }
    }    

    //Earn with all fees going towards the protocol.
    function _protocolEarn(IVaultStrategy _strategy) internal {
        try _strategy.earn(address(0)) {} catch {} 
    }

    // ===================== HELPER FUNCTIONS ===================== // 

    //TVL helper function.
    function vaultStakedTokens(uint256 _pid) public view returns (uint256) {
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        return strategy.totalStakeTokens();
    }

    function transferStrategyOwnership(address _strategy, address _owner) external onlyOwner {
        IVaultStrategy(_strategy).transferOwnership(_owner);
    }

}

// File: StrategyManagerV4.sol

contract StrategyManagerV4 is StrategyManager {
    using SafeERC20 for IERC20;

    event ReferrerDeposit(address indexed referrer, address indexed referree, uint256 indexed pid, uint256 amount, uint256 timeStamp);
    event ReferreeCashback(address indexed referrer, address indexed referree, uint256 amount, uint256 timeStamp);

    //*=============== User Defined Complex Types ===============*//

    struct UserPoolInfo {
        uint256 amountDeposited; //Amount of tokens deposited.
        uint256 amountWithdrawn; //Amount of tokens withdrawn.
        uint256 referralAmount; //Referral amount added.
        uint256 referralCashbackAmount; //Referral amount given as cashback.
        uint256 lastWithdrawalTime; //Time of last deposit.
    }

    //*=============== State Variables ===============*//

    mapping(address => mapping(uint256 => UserPoolInfo)) public userPoolInfo;

    IReferralManagerV4 public referralManager;

    uint256 public constant BASIS_POINTS_DENOM = 10_000;
    bool public onlyUseBaselineTax = false;
    bool public requireNetStatusAcrossPids = true;

    //*=============== Helper Functions ===============*//

    function isNetPositive(address _account, uint256 _pid) public view returns (bool netPositive) {
        netPositive = true;
        if (requireNetStatusAcrossPids == true){
            for (uint8 iter_pid = 0; iter_pid < poolInfo.length; iter_pid++) {
                if (userPoolInfo[_account][iter_pid].amountDeposited > 0) {
                    netPositive = netPositive && (userPoolInfo[_account][iter_pid].amountDeposited >= userPoolInfo[_account][iter_pid].amountWithdrawn);
                }
            }
        } else {
            netPositive = netPositive && (userPoolInfo[_account][_pid].amountDeposited >= userPoolInfo[_account][_pid].amountWithdrawn);
        }
        
    }

    function sumOfDeposits(address _account) public view returns (uint256 depositSum) {
        for (uint8 _pid = 0; _pid < poolInfo.length; _pid++) {
            depositSum += userPoolInfo[_account][_pid].amountDeposited;
        }
    }

    //*=============== Main Functions ===============*//

    //Deposit function.
    function _deposit(
        uint256 _pid,
        uint256 _depositAmount,
        address _user,
        address _origin
    ) internal override returns (uint256 sharesAdded) {
        require(_depositAmount > 0, "Error: Deposit amount must be greater than 0");
        PoolInfo memory pool = poolInfo[_pid];

        //Earn on behalf of protocol.
        if (pool.strategy.sharesTotal() > 0 && _origin != address(this)) { _protocolEarn(pool.strategy); }

        //Account for transfer tax.
        uint256 balanceBefore = pool.stakeToken.balanceOf(address(pool.strategy));
        pool.stakeToken.safeTransferFrom(_origin, address(pool.strategy), _depositAmount);
        _depositAmount = pool.stakeToken.balanceOf(address(pool.strategy)) - balanceBefore;
        
        //Deposit and add shares on behalf of user & log shares.
        sharesAdded = pool.strategy.deposit(_depositAmount, _user);        
        emit Deposit(_user, _pid, _depositAmount, block.timestamp);

        //Update Variables.
        userPoolInfo[_user][_pid].amountDeposited += _depositAmount;
        if (userPoolInfo[_user][_pid].lastWithdrawalTime == 0) {
            userPoolInfo[_user][_pid].lastWithdrawalTime = block.timestamp;
        }
    }

    function depositWReferral(
        uint256 _pid, 
        uint256 _depositAmount,
        address _upline
    ) external nonReentrant {
        referralManager.setUpline(msg.sender, _upline);
        _deposit(_pid, _depositAmount, msg.sender, msg.sender);
    }

    //Withdrawal function.
    function _withdraw(
        address _user,
        uint256 _pid,
        uint256 _withdrawAmount
    ) internal  override {
        require(_withdrawAmount > 0, "Error: Deposit amount must be greater than 0");
        IVaultStrategy strategy = poolInfo[_pid].strategy;
        IERC20 depositToken = poolInfo[_pid].stakeToken;

        //Get the total amount of shares & earn on behalf of protocol.
        (uint256 userShares,,) = strategy.userShares(_user);
        uint256 sharesTotal = strategy.sharesTotal();
        require(userShares > 0 && sharesTotal > 0, 'Error: No shares to withdraw.');
        _protocolEarn(strategy);

        //Initialise the amount withdrawn by getting the balances of the user and this address both before and after.
        uint256 taxedAmount = depositToken.balanceOf(address(this));
        uint256 amountWithdrawn = depositToken.balanceOf(_user); 

        //Withdraw and remove shares for the user.
        uint256 sharesRemoved = strategy.withdraw(_withdrawAmount, _user);

        //Remove the pool for the user if they have no balance.
        userShares = userShares > sharesRemoved ? userShares - sharesRemoved : 0;        

        //Caluculate the amount withdrawn by subtracting the balance before from the balance after.
        taxedAmount = depositToken.balanceOf(address(this)) - taxedAmount;
        amountWithdrawn = depositToken.balanceOf(_user) - amountWithdrawn + taxedAmount;

        //Emit the an event for withdrawals.
        emit Withdraw(_user, _pid, amountWithdrawn, block.timestamp);
        if (userShares == 0) { emit ResetHistory(_user, _pid, block.timestamp); }

        //Update the variables.
        userPoolInfo[_user][_pid].amountWithdrawn += amountWithdrawn;
        userPoolInfo[_user][_pid].lastWithdrawalTime = block.timestamp;

        //Alter taxed amount if we are only to take from the baseline tax. (Truncates balances also)
        if (onlyUseBaselineTax == true) {
            uint256 tempTaxedAmount = amountWithdrawn * strategy.baselineTaxRate() / BASIS_POINTS_DENOM;
            taxedAmount = (tempTaxedAmount <= taxedAmount) ? tempTaxedAmount : taxedAmount;
        }

        //Perform ref payout option.
        _refPayout(_user, taxedAmount, _pid);

    }

    function _refPayout(
        address _user,
        uint256 _amount,
        uint256 _pid
    ) internal {
        
        //Calculate the referral amount and the referree amount.
        (address _upline, uint256 referrerAmount, uint256 referreeAmount) = referralManager.calculateACReferralAmounts(
            _user,
            _pid,
            _amount
        );

        //Handle referrerAmount;
        IERC20 depositToken = poolInfo[_pid].stakeToken;
        if (_upline != address(0) && referrerAmount > 0) {
            userPoolInfo[_upline][_pid].referralAmount += referrerAmount;
            IERC20(depositToken).safeIncreaseAllowance(address(this), referrerAmount);
            _deposit(
                _pid, //_pid.
                referrerAmount, //_depositAmount.
                _upline, //_user.
                address(this) //_origin.
            );
            emit ReferrerDeposit(_upline, _user, _pid, referrerAmount, block.timestamp);
        }

        //Transfer remaining tokens tokens to the referree.
        if (referreeAmount > 0) {
            if ( referralManager.referreeACCashbackAllowed(_upline, _user, _pid) ){
                depositToken.safeTransfer(_user, referreeAmount);
                userPoolInfo[_upline][_pid].referralCashbackAmount += referreeAmount;
                emit ReferreeCashback(_upline, _user, referreeAmount, block.timestamp);
            }
        }
        
    }

    //*=============== Owner Functions ===============*//

    function ownerWithdraw(address _token, address _recipient, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(_recipient, _amount);
    }

    function setReferralManager(address _referralManager) external onlyOwner {
        referralManager = IReferralManagerV4(_referralManager);
    }

    function setOnlyUseBaselineTax(bool _onlyUseBaselineTax) external onlyOwner {
        onlyUseBaselineTax = _onlyUseBaselineTax;
    }

    function setRequireNetStatusAcrossPids(bool _requireNetStatusAcrossPids) external onlyOwner {
        requireNetStatusAcrossPids = _requireNetStatusAcrossPids;
    }

    function setUserPoolInfo(
        address _user,
        uint256 _pid,
        uint256 _amountDeposited,
        uint256 _amountWithdrawn,
        uint256 _referralAmount,
        uint256 _referralCashbackAmount,
        uint256 _lastWithdrawalTime
    ) external onlyOwner {
        userPoolInfo[_user][_pid] = UserPoolInfo({
            amountDeposited: _amountDeposited,
            amountWithdrawn: _amountWithdrawn,
            referralAmount: _referralAmount,
            referralCashbackAmount: _referralCashbackAmount,
            lastWithdrawalTime: _lastWithdrawalTime
        });
    }

    function setUserDepositTrackingInfoPt1(
        uint256 _pid,
        address[] calldata _users,
        uint256[] calldata _deposits,
        uint256[] calldata _withdrawals,
        uint256[] calldata _referralAmounts
    ) external onlyOwner {
        for (uint8 idx; idx < _users.length; idx++) {
            userPoolInfo[_users[idx]][_pid].amountDeposited = _deposits[idx];
            userPoolInfo[_users[idx]][_pid].amountWithdrawn = _withdrawals[idx];
            userPoolInfo[_users[idx]][_pid].referralAmount = _referralAmounts[idx];
        }
    }

    function setUserDepositTrackingInfoPt2(
        uint256 _pid,
        address[] calldata _users,
        uint256[] calldata _referralCashbackAmounts,
        uint256[] calldata _lastWithdrawalTimes
    ) external onlyOwner {
        for (uint8 idx; idx < _users.length; idx++) {
            userPoolInfo[_users[idx]][_pid].referralCashbackAmount = _referralCashbackAmounts[idx];
            userPoolInfo[_users[idx]][_pid].lastWithdrawalTime = _lastWithdrawalTimes[idx];
        }
    }
}