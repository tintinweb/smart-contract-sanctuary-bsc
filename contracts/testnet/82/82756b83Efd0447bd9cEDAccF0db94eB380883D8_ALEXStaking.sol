/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

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

    function decimals() external view returns (uint256);
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

contract ALEXStaking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(uint256 => PoolInfo) public poolInfo;
    mapping(uint256 => FeeInfo) public feeInfo;

    mapping(address=>bytes32) public whoReferralCodes;
    mapping(bytes32 => ReferralInfo) public referralCodes;
    mapping(address => ExcludeFromFee) private isExcludedFee;
    struct PoolInfo {
        bool  hasUserLimit;
        bool  HarvestEnabled;
        uint256  accTokenPerShare;
        uint256  bonusEndBlock;
        uint256  startBlock;
        uint256  lastRewardBlock;
        uint256  poolLimitPerUser;
        uint256  rewardPerBlock;
        uint256  PRECISION_FACTOR;
        IERC20  rewardToken;
        IERC20  stakedToken;
        uint256  withdrawLockPeriod;
        bool isInitizilated;   
    }

    struct FeeInfo {
        uint256 depositFee; 
        uint256 withdrawalFee;
        uint256 emergencyWithdrawalFee;
        uint marketingShareForEmergency;
        uint marketingShareForDeposit;
        address markettingWallet; 
    }

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt        uint256 rewardLockedUp; 
        uint256 rewardLockedUp; // Reward locked up.
        uint256 lastDepositTime; // when user deposited
        bool isInitizilated; 
    }

    struct ReferralInfo{
        address own;
        uint256 Totalamount;
        uint256 count;
    }
    struct ExcludeFromFee{
        bool isExclude;
        bytes32 referralCode;
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);

    constructor(PoolInfo memory arg1) {   
        poolInfo[0].isInitizilated=true;
        poolInfo[0].withdrawLockPeriod = arg1.withdrawLockPeriod;
        poolInfo[0].stakedToken = arg1.stakedToken;
        poolInfo[0].rewardToken = arg1.rewardToken;
        poolInfo[0].rewardPerBlock = arg1.rewardPerBlock;
        poolInfo[0].startBlock = arg1.startBlock;
        poolInfo[0].bonusEndBlock = arg1.bonusEndBlock;
        if (arg1.poolLimitPerUser > 0) {
            poolInfo[0].hasUserLimit = true;
            poolInfo[0].poolLimitPerUser = arg1.poolLimitPerUser;
        }
    
        uint256 decimalsRewardToken = uint256(arg1.rewardToken.decimals());
        require(decimalsRewardToken < 30, "Should be inferio to 30");

        poolInfo[0].PRECISION_FACTOR = uint256(10**(30 - decimalsRewardToken));
        poolInfo[0].lastRewardBlock = poolInfo[0].startBlock;
    }

    function getLenghtPool() public view returns(uint256){
        uint256 limit=~uint256(0);
        uint256 count=0;
        for(uint256 i=0; i<limit;++i){
            if(!poolInfo[i].isInitizilated)
                return count;
            count+=1;
        }
        return ~uint256(0);//Error
    }

    function canWithdraw(uint256 _poolId, address _user) public view returns (bool) {
        UserInfo storage user = userInfo[_poolId][_user];
        
        PoolInfo storage pool = poolInfo[_poolId];
        require(pool.isInitizilated , "First to Initilaze for Pool");
        return  (block.timestamp > user.lastDepositTime + pool.withdrawLockPeriod) && (block.timestamp > pool.bonusEndBlock * 3);
    }

    function getReferralCode(address _address) external view returns (ReferralInfo memory){
         return referralCodes[whoReferralCodes[_address]];
    }

    function transferPoolForHolder(uint256 _poolId,address _user,uint256 _newPoolId) external nonReentrant{//Think
        require(_poolId!= _newPoolId, "Already That Pool");

        UserInfo storage user = userInfo[_poolId][_user];
        
        require(user.isInitizilated, "First Be Initizilated");

        PoolInfo storage pool = poolInfo[_newPoolId];

        require(pool.isInitizilated , "First to Initilaze for Pool");//Staked Token ayni olmali
        require(pool.rewardToken == poolInfo[_poolId].rewardToken && pool.stakedToken == poolInfo[_poolId].stakedToken , "First to Initilaze for Pool");
        UserInfo storage newUser = userInfo[_newPoolId][_user];
        //*************************************
        //It may need another process
        //*************************************
        newUser.amount += user.amount;
        newUser.rewardDebt += user.rewardDebt;
        newUser.isInitizilated = true;

        user.amount = 0;
        user.rewardDebt = 0;
        newUser.lastDepositTime = block.timestamp;
    } 

    function pendingReward(uint256 _poolId,address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_poolId][_user];
        PoolInfo storage pool = poolInfo[_poolId];

        require(pool.isInitizilated , "First to Initilaze for Pool");

        uint256 stakedTokenSupply = pool.stakedToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(_poolId, pool.lastRewardBlock, block.number);
            uint256 tokenReward = multiplier * pool.rewardPerBlock;
            uint256 adjustedTokenPerShare =
                pool.accTokenPerShare + ((tokenReward * pool.PRECISION_FACTOR) / stakedTokenSupply);
            return ((user.amount * adjustedTokenPerShare) / pool.PRECISION_FACTOR) - user.rewardDebt;
        } else {
            return ((user.amount * pool.accTokenPerShare) / pool.PRECISION_FACTOR) - user.rewardDebt;
        }
    }

    function firstDeposit(uint256 _poolId,uint256 _amount, bytes32 _referallCode) external nonReentrant returns (bytes32){

        UserInfo storage user = userInfo[_poolId][msg.sender];
        PoolInfo storage pool = poolInfo[_poolId];
        FeeInfo storage fees = feeInfo[_poolId];
        require(pool.isInitizilated , "First to Initilaze for Pool");
        if (pool.hasUserLimit) {
            require((_amount + user.amount) <= pool.poolLimitPerUser , "User amount above limit");
        }
        
        if (!isExcludedFee[msg.sender].isExclude && referralCodes[_referallCode].own!=address(0)) {

            isExcludedFee[address(referralCodes[_referallCode].own)].isExclude=true;// should owner of refferalCode be excluded from fee? 
            isExcludedFee[address(msg.sender)].isExclude=true;

            isExcludedFee[msg.sender].referralCode=_referallCode;
        }
        _updatePool(_poolId);

        if (_amount > 0 && user.amount == 0) {
            pool.stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(fees.depositFee > 0) {
                uint256 _depositfee = fees.depositFee;
                uint256 referralReward;
                if(isExcludedFee[msg.sender].isExclude && isExcludedFee[msg.sender].referralCode!=bytes32(0)){
                    _depositfee = (2*_depositfee)/4;
                    referralReward = (( _amount * _depositfee ) / 10000 ) / 2 ;
                    pool.stakedToken.safeTransfer(address(referralCodes[isExcludedFee[msg.sender].referralCode].own), referralReward ); 
                    referralCodes[isExcludedFee[msg.sender].referralCode].Totalamount+=referralReward;
                    referralCodes[isExcludedFee[msg.sender].referralCode].count+=1;

                }else if(isExcludedFee[msg.sender].isExclude){
                        _depositfee = (3*_depositfee)/4;
                }
                    uint256 fee = ( _amount * _depositfee )/ 10000;
                    
                    _amount = _amount - (fee + referralReward);//
                    uint256 marketing = (fee * fees.marketingShareForDeposit) / 10;

                    pool.stakedToken.safeTransfer(fees.markettingWallet, marketing);
            }

            user.lastDepositTime = block.timestamp;
            user.amount = user.amount + _amount;
            user.isInitizilated = true;
            
        }
        bytes32 refferalCode;//Same Referral Code

        if(referralCodes[whoReferralCodes[address(msg.sender)]].own==address(0)){
            refferalCode = keccak256(abi.encodePacked(address(msg.sender), block.timestamp));
            whoReferralCodes[address(msg.sender)]=refferalCode;
            referralCodes[refferalCode].own=address(msg.sender);
        }

        return refferalCode;
    }

    function deposit(uint256 _poolId,uint256 _amount) external nonReentrant { //_amount==0 harvest
        UserInfo storage user = userInfo[_poolId][msg.sender];
        PoolInfo storage pool = poolInfo[_poolId];
        FeeInfo storage fees = feeInfo[_poolId];
        require(user.isInitizilated , "First to Initilaze for User");
        require(pool.isInitizilated , "First to Initilaze for Pool");
        if (pool.hasUserLimit) {
            require((_amount + user.amount) <= pool.poolLimitPerUser , "User amount above limit");
        }

        _updatePool(_poolId);
        if (_amount==0 && 
            user.amount > 0 &&
            pool.HarvestEnabled) {
            uint256 pending = ((user.amount * pool.accTokenPerShare) / pool.PRECISION_FACTOR) - user.rewardDebt;
            user.rewardDebt = (user.amount * pool.accTokenPerShare ) / pool.PRECISION_FACTOR;
            if (pending > 0) {
                pool.rewardToken.safeTransfer(address(msg.sender), pending);
            }   
        }
        
        if (_amount > 0 ) {
            pool.stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(fees.depositFee > 0) {
                uint256 _depositfee = fees.depositFee;
                uint256 referralReward;
                ExcludeFromFee memory isExcluded = isExcludedFee[msg.sender];
                if(isExcluded.isExclude && isExcluded.referralCode!=bytes32(0)){// should owner of refferalCode be excluded from fee? 
                    _depositfee = (2*_depositfee)/4;
                    referralReward = (( _amount * _depositfee ) / 10000 ) / 2 ;
                    pool.stakedToken.safeTransfer(address(referralCodes[isExcluded.referralCode].own), referralReward ); 
                    referralCodes[isExcluded.referralCode].Totalamount+=referralReward;
                    referralCodes[isExcluded.referralCode].count+=1;// it may be problem this line need to be deleted ?
                }else if(isExcludedFee[msg.sender].isExclude){
                        _depositfee = (3*_depositfee)/4;
                }
                uint256 fee = ( _amount * _depositfee )/ 10000;
                _amount = _amount - (fee + referralReward);
                
                uint256 marketing = ( fee * fees.marketingShareForDeposit) / 10 ;//change
                pool.stakedToken.safeTransfer(fees.markettingWallet, marketing);//change
            }
            user.lastDepositTime = block.timestamp;
            user.amount = user.amount + _amount;
        }
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _poolId,uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[_poolId][msg.sender];
        PoolInfo storage pool = poolInfo[_poolId];
        FeeInfo storage fees = feeInfo[_poolId];
        require(user.amount >= _amount, "Amount to withdraw too high");
        
        require(canWithdraw(_poolId,address(msg.sender)),"Can't yet Withdraw");

        _updatePool(_poolId);

        if (_amount > 0) {
             if(pool.withdrawLockPeriod > 0 && block.timestamp > pool.bonusEndBlock * 3) {
                bool isLocked = block.timestamp < user.lastDepositTime + pool.withdrawLockPeriod;
                require( isLocked == false, "withdraw still locked" );
             }
            if (fees.withdrawalFee > 0 ) {
              _amount -=  (_amount * fees.withdrawalFee) / 10000;
              user.amount -=  _amount;
            }
            pool.stakedToken.safeTransfer(address(msg.sender), _amount);
        }
        uint256 pending = ((user.amount * pool.accTokenPerShare) / pool.PRECISION_FACTOR) - user.rewardDebt;

        if (pending > 0) {
            user.rewardDebt =( user.amount * pool.accTokenPerShare ) / pool.PRECISION_FACTOR;
            pool.rewardToken.safeTransfer(address(msg.sender), pending);
            
        }
        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw(uint256 _poolId) external nonReentrant {
        UserInfo storage user = userInfo[_poolId][msg.sender];
        PoolInfo storage pool = poolInfo[_poolId];
        FeeInfo storage fees = feeInfo[_poolId];    

        uint256 amountToTransfer = user.amount;

        user.amount = 0;
        user.rewardDebt = 0;

        if (amountToTransfer > 0) {
            if(pool.withdrawLockPeriod > 0) {
                uint fee = ( amountToTransfer * fees.emergencyWithdrawalFee ) / 10000;
                amountToTransfer = amountToTransfer - fee;
                uint256 marketing = (fee * fees.marketingShareForEmergency )/ 10;//change
                pool.stakedToken.safeTransfer(fees.markettingWallet, marketing);//change
            }
            pool.stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
        }
        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    function _updatePool(uint256 _poolId) internal {
        PoolInfo storage pool = poolInfo[_poolId];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 stakedTokenSupply = pool.stakedToken.balanceOf(address(this));
        if (stakedTokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = _getMultiplier(_poolId, pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier * pool.rewardPerBlock;
        pool.accTokenPerShare = pool.accTokenPerShare + ((tokenReward * pool.PRECISION_FACTOR)/ stakedTokenSupply);
        pool.lastRewardBlock = block.number;
    }

    function _getMultiplier(uint256 _poolId,uint256 _from, uint256 _to) internal view returns (uint256) {
        PoolInfo storage pool = poolInfo[_poolId];

        if (_to <= pool.bonusEndBlock) {
            return _to - _from;
        } else if (_from >= pool.bonusEndBlock) {
            return 0;
        } else {
            return pool.bonusEndBlock - _from;
        }
    }

    function addPool(PoolInfo memory arg1) external onlyOwner {
        uint256 _poolId=getLenghtPool();
        poolInfo[_poolId].isInitizilated=true;
        poolInfo[_poolId].withdrawLockPeriod = arg1.withdrawLockPeriod;
        poolInfo[_poolId].stakedToken = arg1.stakedToken;
        poolInfo[_poolId].rewardToken = arg1.rewardToken;
        poolInfo[_poolId].rewardPerBlock = arg1.rewardPerBlock;
        poolInfo[_poolId].startBlock = arg1.startBlock;
        poolInfo[_poolId].bonusEndBlock = arg1.bonusEndBlock;
        if (arg1.poolLimitPerUser > _poolId) {
            poolInfo[_poolId].hasUserLimit = true;
            poolInfo[_poolId].poolLimitPerUser = arg1.poolLimitPerUser;
        }
    
        uint256 decimalsRewardToken = uint256(arg1.rewardToken.decimals());
        require(decimalsRewardToken < 30, "Should be inferio to 30");

        poolInfo[_poolId].PRECISION_FACTOR = uint256(10**( 30 - decimalsRewardToken));
        poolInfo[_poolId].lastRewardBlock = poolInfo[_poolId].startBlock;
    }
    
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function recoverBNB(uint256 amount) public onlyOwner {
            payable(msg.sender).transfer(amount);
    }

    function stopReward(uint256 _poolId) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.bonusEndBlock = block.number;
    }

    function updatePoolLimitPerUser(uint256 _poolId, bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        require(pool.hasUserLimit, "Must be set");
        
        if (_hasUserLimit) {
            require(_poolLimitPerUser > pool.poolLimitPerUser, "New limit must be higher");
            pool.poolLimitPerUser = _poolLimitPerUser;
        } else {
            pool.hasUserLimit = _hasUserLimit;
            pool.poolLimitPerUser = 0;
        }
        emit NewPoolLimit(pool.poolLimitPerUser);
    }

    function updateRewardPerBlock(uint256 _poolId,uint256 _rewardPerBlock) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        require(block.number < pool.startBlock, "Pool has started");
        pool.rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    function updateStartAndEndBlocks(uint256 _poolId,uint256 _startBlock, uint256 _bonusEndBlock) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        require(block.number < pool.startBlock, "Pool has started");
        require(_startBlock < _bonusEndBlock, "New startBlock must be lower than new endBlock");
        require(block.number < _startBlock, "New startBlock must be higher than current block");
        pool.startBlock = _startBlock;
        pool.bonusEndBlock = _bonusEndBlock;
        pool.lastRewardBlock = pool.startBlock;
        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }

    function setDepositFee(uint256 _poolId,uint depFee) external onlyOwner {
        FeeInfo storage fees = feeInfo[_poolId]; 
        require(depFee < 500 && depFee % 4 ==0 , "DeposiFee should be < 5 and %4 ==0 because 1/4 may send own of referralCode");
        fees.depositFee = depFee;
    }

    function setEmergencyFee(uint256 _poolId,uint emFee) external onlyOwner {
        FeeInfo storage fees = feeInfo[_poolId]; 
        require(emFee <= 1500, "EmergencyWithdrawFee should be <= 15");
        fees.emergencyWithdrawalFee = emFee;
    }    

    function setWithdrawFee(uint256 _poolId,uint wFee) external onlyOwner {
        FeeInfo storage fees = feeInfo[_poolId]; 
        require(wFee < 500, "WithdrawFee should be < 5");
        fees.withdrawalFee = wFee;
    }

    function setMarkettingWallet(uint256 _poolId, address _marketingWallet) external onlyOwner {
        FeeInfo storage fees = feeInfo[_poolId]; 
        fees.markettingWallet = _marketingWallet;
    }

    function setShareFee(uint256 _poolId,uint _poolForEmergency,uint _poolForDeposit,uint _marketingForEmergency,uint _marketingForDeposit) external onlyOwner {
        FeeInfo storage fees = feeInfo[_poolId]; 
        require(_poolForEmergency + _marketingForEmergency == 10, "poolForEmergency + marketingForEmergency should be == 10");
        require(_poolForDeposit + _marketingForDeposit == 10, "poolForEmergency + marketingForEmergency should be == 10");
        fees.marketingShareForEmergency = _marketingForEmergency;
        fees.marketingShareForDeposit = _marketingForDeposit; 
    } 

}