/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
   
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract SmartChef is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20Metadata;

    address public FEETOKEN = address(0x0D0302925ed17743778B0F06BaaB84cB459eF002);
    address public FEETO = address(0xd2e8a469Db672dA6Fac5e7c1D945272a834BDe0C);
    uint256 public FEE = 10000000000;

     struct PoolInfo {
         uint256 accTokenPerShare;
         uint256 bonusEndBlock;
         uint256 startBlock;
         uint256 lastRewardBlock;
         uint256 rewardPerBlock;
         uint256 PRECISION_FACTOR;
         IERC20Metadata rewardToken;
         IERC20Metadata stakedToken;
         uint256 stakedTS;
         bool isAdd;
    }

    mapping (uint256 => PoolInfo) public poolInfo;
    uint256 public poolInfoSize;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
    }

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    modifier poolSizeAdd() {
        _;
        poolInfoSize += 1;
    }

    //设置手续费
    function setFee(address _feeAddress, address _feeTo, uint256 _fee) public onlyOwner{
        FEETOKEN = _feeAddress;
        FEETO = _feeTo;
        FEE = _fee;
    }

    //获取当前链区块
    function getNowBlock() public view returns(uint256){
        return block.number;
    }

    //判断池子是否存在
    function hasPoolExist(uint256 pId) internal  view returns(bool){
        return poolInfo[pId].isAdd;
    }

    //添加池子
    function addPool(IERC20Metadata _stakedToken, IERC20Metadata _rewardToken, uint256 _rewardPerBlock, uint256 _startBlock, uint256 _bonusEndBlock) public poolSizeAdd{
        require(_startBlock > block.number && _bonusEndBlock > _startBlock, "block error");
        IERC20Metadata W3 = IERC20Metadata(FEETOKEN);
        require(W3.transferFrom(msg.sender, FEETO, FEE), "fee error");

        uint256 rewardAmout =  _rewardPerBlock * (_bonusEndBlock - _startBlock);
        IERC20Metadata RW = IERC20Metadata(_rewardToken);
        require(RW.transferFrom(msg.sender, address(this), rewardAmout), "rewardAmout error");

        poolInfo[poolInfoSize].stakedToken = _stakedToken;
        poolInfo[poolInfoSize].rewardToken = _rewardToken;
        poolInfo[poolInfoSize].rewardPerBlock = _rewardPerBlock;
        poolInfo[poolInfoSize].startBlock = _startBlock;
        poolInfo[poolInfoSize].bonusEndBlock = _bonusEndBlock;
        uint256 decimalsRewardToken = uint256(_rewardToken.decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        uint256 _PRECISION_FACTOR = uint256(10**(uint256(30) - decimalsRewardToken));
        uint256 _lastRewardBlock = _startBlock;
        poolInfo[poolInfoSize].PRECISION_FACTOR = _PRECISION_FACTOR;
        poolInfo[poolInfoSize].lastRewardBlock = _lastRewardBlock;
        poolInfo[poolInfoSize].isAdd = true;
    }


    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _pId, uint256 _amount) external nonReentrant {
        require(hasPoolExist(_pId),'Pool not Exist');
        UserInfo storage user = userInfo[_pId][msg.sender];

        _updatePool(_pId);

        if (user.amount > 0) {
            uint256 pending = (user.amount * poolInfo[_pId].accTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                poolInfo[_pId].rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }

        if (_amount > 0) {
            user.amount = user.amount + _amount;
            poolInfo[_pId].stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            poolInfo[_pId].stakedTS += _amount;
        }

        user.rewardDebt = (user.amount * poolInfo[_pId].accTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR;

        emit Deposit(msg.sender, _amount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _pId, uint256 _amount) external nonReentrant {
        require(hasPoolExist(_pId),'Pool not Exist');
        UserInfo storage user = userInfo[_pId][msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _updatePool(_pId);

        uint256 pending = (user.amount * poolInfo[_pId].accTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR - user.rewardDebt;

        if (_amount > 0) {
            user.amount = user.amount - _amount;
            poolInfo[_pId].stakedToken.safeTransfer(address(msg.sender), _amount);
            poolInfo[_pId].stakedTS += _amount;
        }

        if (pending > 0) {
            poolInfo[_pId].rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = (user.amount * poolInfo[_pId].accTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR;

        emit Withdraw(msg.sender, _amount);
    }

    function getReward(uint256 _pId) external nonReentrant{
        require(hasPoolExist(_pId),'Pool not Exist');
         UserInfo storage user = userInfo[_pId][msg.sender];
         _updatePool(_pId);

        uint256 pending = (user.amount * poolInfo[_pId].accTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR - user.rewardDebt;

        if (pending > 0) {
            poolInfo[_pId].rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = (user.amount * poolInfo[_pId].accTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR;
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw(uint256 _pId) external nonReentrant {
        require(hasPoolExist(_pId),'Pool not Exist');
        UserInfo storage user = userInfo[_pId][msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        if (amountToTransfer > 0) {
            poolInfo[_pId].stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(uint256 _pId, address _user) external view returns (uint256) {
        require(hasPoolExist(_pId),'Pool not Exist');
        UserInfo storage user = userInfo[_pId][_user];
        uint256 stakedTokenSupply = poolInfo[_pId].stakedTS;
        if (block.number > poolInfo[_pId].lastRewardBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(_pId, poolInfo[_pId].lastRewardBlock, block.number);
            uint256 cakeReward = multiplier * poolInfo[_pId].rewardPerBlock;
            uint256 adjustedTokenPerShare = poolInfo[_pId].accTokenPerShare + (cakeReward * poolInfo[_pId].PRECISION_FACTOR) / stakedTokenSupply;
            return (user.amount * adjustedTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR - user.rewardDebt;
        } else {
            return (user.amount * poolInfo[_pId].accTokenPerShare) / poolInfo[_pId].PRECISION_FACTOR - user.rewardDebt;
        }
    }

    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool(uint256 _pId) internal {
        if (block.number <= poolInfo[_pId].lastRewardBlock) {
            return;
        }

        uint256 stakedTokenSupply = poolInfo[_pId].stakedTS;

        if (stakedTokenSupply == 0) {
            poolInfo[_pId].lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(_pId, poolInfo[_pId].lastRewardBlock, block.number);
        uint256 cakeReward = multiplier * poolInfo[_pId].rewardPerBlock;
        poolInfo[_pId].accTokenPerShare = poolInfo[_pId].accTokenPerShare + (cakeReward * poolInfo[_pId].PRECISION_FACTOR) / stakedTokenSupply;
        poolInfo[_pId].lastRewardBlock = block.number;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _pId, uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= poolInfo[_pId].bonusEndBlock) {
            return _to - _from;
        } else if (_from >= poolInfo[_pId].bonusEndBlock) {
            return 0;
        } else {
            return poolInfo[_pId].bonusEndBlock - _from;
        }
    }

}