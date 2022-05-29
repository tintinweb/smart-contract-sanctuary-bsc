/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: usdt_game/Pool.sol


pragma solidity ^0.8.0;






pragma solidity ^0.8.0;

interface Inviter {
    struct InviteUserInfo {
        address     upper;
        LowerInfo[]   lowers;
        uint256     invitePower;
    }

    struct LowerInfo {
        address lower;
        bool    hasAcc;   
    }
    
  

    event  LogInvite(address indexed owner, address indexed inviter, uint256 invitePower, uint256 indexed height);  // 被邀请人，邀请人，增加邀请算力， 块高

    function getMaxUserInvitePower() external view returns (uint256);
    function updateUpper(address _owner) external ;
    function inviteCount()  external view returns (uint256);
    function  getUpper(address _owneraddress) external view returns (address);
    function  getLowers(address _owneraddress) external view returns (LowerInfo[] memory);
    function getInvitePower(address _owneraddress) external view returns (uint256);
    
}

contract Pool is Ownable {

    using SafeERC20 for IERC20;

    //address public mTokenAddress = address(0xd56B1B54DfD4A9534B1C5eb58c8e9Bb2dBe3C72B);     //usdt
    IERC20 public mTokenAddress;
    Inviter public inviterAddress;

    uint256 constant  poolLockBlockCount = 30 * 24 * 60 * 20;
    uint256 public  minDepositAmount = 10 * 10 ** 6;
    // 10 / 100
    uint256 public  perDayRewardRate = 10;
    address private  inviteAddressDefault = address(0x4789fA23bF3f03b536d34C3B597FB907C44bD210);
    uint256 public  totalDeposited = 0;

    // operateType: 1:deposit, 2:withdraw
      struct DepositRecord {
        int operateType;
        address userAddress;
        uint256 startBlockNumber;
        uint256 endBlockNumber;
        uint256 userDepositAmount;
        uint256 lastRewardBlock;
    }

    struct UserInfo {
        uint256 balance;
        uint256 pendingReward;
        uint256 recievedReward;
        uint256 lastRewardBlock;
        uint256 teamId;
        uint256 invitedReward;
    }

    struct Team {
        uint256 teamId;
        uint256 totalDeposit;
        uint256 memberCount;
    }

    mapping (address => UserInfo) public userInfoList;
    mapping (address => DepositRecord[]) public userDepositRecordList;
    Team[] public teamList;

    event LogDeposit(address userAddress, uint256 depositAmount, uint256 lastBlock);
    event LogHarvestCurrentEarn(address userAddress, uint256 indexed depositRecordId, uint256 lastBlock, uint256 reward);

    event LogWithdrawEarnExtern(address owner, uint256 lastBlock, uint256  rewardAmount);  

    constructor(address _mTokenAddress, address _InviterAddress) {
        mTokenAddress = IERC20(_mTokenAddress);
        inviterAddress = Inviter(_InviterAddress);
        teamList.push(
            Team({
               teamId: 0,
               totalDeposit: 0,
               memberCount: 0
            })
        );
    } 

    function setMTokenAddress(address _mTokenAddress) public onlyOwner {
        mTokenAddress = IERC20(_mTokenAddress);
    }

    function deposit(uint256 _depositAmount) public {
        uint256 lastBlock = block.number;
        require(_depositAmount >= minDepositAmount, "Insufficient amount of deposit");
        require(mTokenAddress.transferFrom(msg.sender, address(this), _depositAmount));

        UserInfo storage user = userInfoList[msg.sender];
        user.balance = user.balance + _depositAmount;

        userDepositRecordList[msg.sender].push(
            DepositRecord({
                operateType: 1,
                userAddress: msg.sender,
                startBlockNumber: lastBlock,
                endBlockNumber: lastBlock + poolLockBlockCount,
                userDepositAmount: _depositAmount,
                lastRewardBlock: lastBlock
            })
        );

        emit LogDeposit(msg.sender, _depositAmount, lastBlock);
        // inviterAddress.updateUpper(msg.sender);
         uint256 upperTeamId = updateUpperPenddingReward(msg.sender, _depositAmount);
        if (user.teamId == 0) {
            user.teamId = upperTeamId;
        }
        updateTeamDeposit(user.teamId, _depositAmount);
        totalDeposited = totalDeposited + _depositAmount;
    }

    //待收益复投
    function reDeposit() public {
        //先收割到pendding余额
        harvestAllEarn();
        uint256 lastBlock = block.number;
        
        UserInfo storage user = userInfoList[msg.sender];
        uint256 penddingAmount = user.pendingReward;
        user.balance = user.balance + penddingAmount;
        user.pendingReward = 0;

        userDepositRecordList[msg.sender].push(
            DepositRecord({
                operateType: 1,
                userAddress: msg.sender,
                startBlockNumber: lastBlock,
                endBlockNumber: lastBlock + poolLockBlockCount,
                userDepositAmount: penddingAmount,
                lastRewardBlock: lastBlock
            })
        );

        emit LogDeposit(msg.sender, penddingAmount, lastBlock);
        // inviterAddress.updateUpper(msg.sender);
        uint256 upperTeamId = updateUpperPenddingReward(msg.sender, penddingAmount);
        if (user.teamId == 0) {
            user.teamId = upperTeamId;
        }
        updateTeamDeposit(user.teamId, penddingAmount);
        totalDeposited = totalDeposited + penddingAmount;
    }

    //注册团队
    function addTeam(address _teamLeader) public onlyOwner returns (uint256) {
        UserInfo storage user = userInfoList[_teamLeader];
        require(user.teamId == 0, "address has already join a team!");
        uint256 currentId = teamList.length;
        teamList.push(
            Team({
               teamId: currentId,
               totalDeposit: 0,
               memberCount: 0
            })
        );
        user.teamId = currentId;
        return currentId;
    }

    //更新团队数据
    function updateTeamDeposit(uint256 _teamId, uint256 _amount) internal {
        Team storage tm = teamList[_teamId];
        tm.memberCount = tm.memberCount + 1;
        tm.totalDeposit = tm.totalDeposit + _amount;
    }

    //用户邀请返现
    function updateUpperPenddingReward(address _address, uint256 _amount) internal returns ( uint256) {
        address upper = inviterAddress.getUpper(_address);
        // uint256 addAmount1 = 0;
        if (upper == address(0)) {
            return 0;
        }
        UserInfo storage upperInfo = userInfoList[upper];
        uint256 addAmount = 20 * _amount / 100;    //20% reward
        upperInfo.pendingReward = upperInfo.pendingReward + addAmount;
        upperInfo.invitedReward = upperInfo.invitedReward + addAmount;
        uint256 tid = upperInfo.teamId;
        return tid;
    }

    function getUserBalance (address _owner) public view returns (uint256) {
        return userInfoList[_owner].balance;
    }

    function getCurrentPerBlockReward(address _owner) public view returns (uint256) {
        UserInfo storage user = userInfoList[_owner];
        uint256 balance = user.balance;
        uint256 perBlockRewardUsdt = perDayRewardRate * balance / (100 * 24 * 60 * 20);
        return perBlockRewardUsdt;
    }

    function  pendingHarvestEarn(address _userAddress, uint256 _depositRecordId)  public view returns (uint256) {
        DepositRecord  storage userDepositRecord = userDepositRecordList[_userAddress][_depositRecordId];
        uint256 lastBlock = block.number;
        uint256 reward = 0;
        if (userDepositRecord.operateType == 2 ||
            userDepositRecord.startBlockNumber >= lastBlock ||
            userDepositRecord.lastRewardBlock >= lastBlock
        ) return reward;

        uint256 blockNums = lastBlock - userDepositRecord.lastRewardBlock;
        //invite power 10% highest
        reward = getCurrentPerBlockReward(_userAddress) * blockNums;
        return reward;
    }

    function harvestCurrentEarn(uint256 _depositRecordId) public {
        DepositRecord storage userDepositRecord = userDepositRecordList[msg.sender][_depositRecordId];
        uint256 lastBlock = block.number;
        UserInfo storage user = userInfoList[msg.sender];
        uint256 reward = pendingHarvestEarn(msg.sender, _depositRecordId);
        user.pendingReward = user.pendingReward + reward;

        userDepositRecord.lastRewardBlock = lastBlock;
    
        emit LogHarvestCurrentEarn(msg.sender, _depositRecordId, userDepositRecord.lastRewardBlock, reward);
        return;

    }

    function veiwPenddingAmount() public view returns (uint256) {
        uint256 totalPendding = 0;
        uint256 recordNums = userDepositRecordList[msg.sender].length;
        for (uint256 i = 0; i < recordNums ; i++) {
            uint256 currentPendding = pendingHarvestEarn(msg.sender, i);
            totalPendding = totalPendding + currentPendding;
        }
        return totalPendding;
    }

    function harvestAllEarn() public {
        DepositRecord[] storage userDepositRecord = userDepositRecordList[msg.sender];
        uint256 recordNums = userDepositRecord.length;
        for (uint256 i = 0; i < recordNums ; i++) {
            harvestCurrentEarn(i);
        }
    }

    function withdrawEarnExtern() public {
    
        uint256 lastBlock = block.number;
        UserInfo storage user = userInfoList[msg.sender];
        uint256 currentReward = user.pendingReward;
        uint256 balanceT = IERC20(address(mTokenAddress)).balanceOf(address(this));
        require(balanceT > 0, "The reward token is not enough");
        if(balanceT <= currentReward) {
            user.pendingReward = balanceT;
            currentReward = user.pendingReward;
        }
        require(balanceT >= user.pendingReward, "Pool's total reward num is not enough ");
        require(user.pendingReward > 0, "user's pending Reward must > 0");
        IERC20(address(mTokenAddress)).safeTransfer(msg.sender, user.pendingReward);
        user.recievedReward = user.recievedReward + user.pendingReward;
        user.pendingReward =  user.pendingReward - user.pendingReward;
        user.lastRewardBlock = lastBlock;

        emit LogWithdrawEarnExtern(msg.sender, user.lastRewardBlock, currentReward);
        return;

    }

    function withdrawByOwner() public onlyOwner {
         uint256 balanceT = IERC20(address(mTokenAddress)).balanceOf(address(this));
         IERC20(address(mTokenAddress)).safeTransfer(msg.sender, balanceT);
    }


}