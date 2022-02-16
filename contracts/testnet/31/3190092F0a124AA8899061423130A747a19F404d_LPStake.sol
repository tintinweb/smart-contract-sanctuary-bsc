//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./Ownable.sol";

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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
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
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
        target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
    {
        return
        functionStaticCall(
            target,
            data,
            "Address: low-level static call failed"
        );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return
        functionDelegateCall(
            target,
            data,
            "Address: low-level delegate call failed"
        );
    }

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
            if (returndata.length > 0) {
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata =
        address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }


    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }


    function paused() external view returns (bool) {
        return _paused;
    }


    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }


    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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

contract LPStake is Ownable, ReentrancyGuard, Pausable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    address public immutable lpAddress;
    address public immutable stAddress;

    uint256 constant BLOCKS_PER_MONTH = 864000;
    uint256 constant NUMBER_DIVISOR = 10;
    uint256 constant REWARD_SHARE_MULTIPLIER = 1e12;

    uint256 public immutable initRewardBlock;  // Initial block number that Token distribution occurs.
    uint256 public lastStakeBlock;  // Last block number that Token distribution occurs.
    uint256 public accRewardTokenPerShare;  // Accumulated Token per share, times 1e12. See below.

    uint256 public lpLockedTotal; //lp amount locked
    uint256 public stRewardTotal; //STONE reward total

    struct User {
	    uint256 amount;	// How many LP the user has provided.
            uint256 rewardDebt; // Reward debt. See explanation below.
            uint256 rewardTotal; // Reward total.
            uint256 rewardPayout; // Reward payout.
	    bool isUsed;          // flag
        //
        // We do some fancy math here. Basically, any point in time, the amount of tokens 
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRewardTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP to a pool. Here's what happens:
        //   1. The pool's `accRewardTokenPerShare` (and `lastStakeBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.

    }
    mapping (address => User) private users;
    uint256 [] reward_tiers = [100,90,80,70,60,50,40,30,20,10,9,8,7,6,5,4];

    event LPStaked(address indexed account, uint256 amount);
    event LPUnstaked(address indexed account, uint256 amount);
    event RewardClaimed(address indexed account, uint256 amount);
    event SystemPaused(address indexed owner);
    event SystemUnpaused(address indexed owner);

    constructor(
        address _stAddress,
        address _lpAddress,
	address _init_owner
    ) Ownable (_init_owner){
        lpAddress = _lpAddress;
	stAddress = _stAddress;
	lpLockedTotal = 0;
	stRewardTotal = 0;
	initRewardBlock = block.number;
	lastStakeBlock = block.number;
    }

    //get acc reward from last reward block 
    function getAccReward() internal view returns (uint256)
    {
	uint256 accReward = 0;
	uint i = (lastStakeBlock - initRewardBlock)/BLOCKS_PER_MONTH;
	uint j = (block.number - initRewardBlock)/BLOCKS_PER_MONTH;
	require(j>=i, "i is greater than j");
	uint len = reward_tiers.length;
	if(i == j)
	{
		//i == j
		if(i < len)
		{
			accReward = (block.number - lastStakeBlock)*reward_tiers[i]*1e18/NUMBER_DIVISOR;	
		}else if(i >= len)
		{
			accReward = (block.number - lastStakeBlock)*reward_tiers[15]*1e18/NUMBER_DIVISOR;	
		}
	}else
	{
		//i < j
		if(j < len)
		{
			accReward = ((i+1)*BLOCKS_PER_MONTH + initRewardBlock)*reward_tiers[i]*1e18/NUMBER_DIVISOR;
                        for(uint m=i+1; m<j; m++)                                              
                                accReward = accReward + BLOCKS_PER_MONTH*reward_tiers[m]*1e18/NUMBER_DIVISOR;
                        accReward = accReward + (block.number - j*BLOCKS_PER_MONTH - initRewardBlock)*reward_tiers[j]*1e18/NUMBER_DIVISOR;
		}else if(i<len)
		{
			accReward = ((i+1)*BLOCKS_PER_MONTH + initRewardBlock - lastStakeBlock)*reward_tiers[i]*1e18/NUMBER_DIVISOR;
                        for(uint n=i+1; n<len; n++)                      
                                accReward = accReward + BLOCKS_PER_MONTH*reward_tiers[n]*1e18/NUMBER_DIVISOR;
			accReward = accReward + (block.number - len*BLOCKS_PER_MONTH)*reward_tiers[15]*1e18/NUMBER_DIVISOR;
		}else if(i>=len)
		{
			accReward = (block.number - lastStakeBlock)*reward_tiers[15]*1e18/NUMBER_DIVISOR;	
		}
	}
	return accReward;
    }

    //stake LP
    function stake(uint256 _lpAmt)
    external
    whenNotPaused
    nonReentrant
    returns (uint256)
    {
	require(_lpAmt>0, "_lpAmt is 0");
        IERC20(lpAddress).safeTransferFrom(
            address(msg.sender),
            address(this),
            _lpAmt
        );

	uint256 accReward = getAccReward();
        lpLockedTotal = lpLockedTotal.add(_lpAmt);
	accRewardTokenPerShare = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));

	emit LPStaked(msg.sender, _lpAmt);

	User storage user = users[msg.sender];
	if(user.isUsed == true)
	{
		uint256 reward = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
		user.rewardTotal = user.rewardTotal.add(reward);
		user.amount = user.amount.add(_lpAmt);
		user.rewardDebt = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER);
		lastStakeBlock = block.number;
	}else
		addUser(msg.sender, _lpAmt);
	return accReward;
    }
    //unstake LP
    function unstake(uint256 _lpAmt)
    external
    whenNotPaused
    nonReentrant
    returns (uint256)
    {
	User storage user = users[msg.sender];
	require(user.isUsed == true, "account no exists.");
	require(user.amount >= _lpAmt, "invalid lpAmt");
	require(_lpAmt > 0, "_lpAmt is 0");


	uint256 accReward = getAccReward();
	if(lpLockedTotal > 0)
		accRewardTokenPerShare = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
	user.rewardTotal = user.rewardTotal.add(reward);

        lpLockedTotal = lpLockedTotal.sub(_lpAmt);
	user.amount = user.amount.sub(_lpAmt);
	user.rewardDebt = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER);
	IERC20(lpAddress).transfer(msg.sender, _lpAmt);

        lastStakeBlock = block.number;

	emit LPUnstaked(msg.sender, _lpAmt);
	if(user.amount == 0 && user.rewardPayout == user.rewardTotal)
		removeUser(msg.sender);
        return accReward;
    }

    //claim STONE
    function claimReward()
    external
    nonReentrant
    returns (uint256)
    {
	User storage user = users[msg.sender];
	require(user.isUsed == true, "account no exists.");
	uint256 accReward = getAccReward();
	if(lpLockedTotal > 0)
		accRewardTokenPerShare = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
	user.rewardDebt = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER);
	user.rewardTotal = user.rewardTotal.add(reward);

	uint256 realReward = user.rewardTotal.sub(user.rewardPayout);
        uint256 stAmt = IERC20(stAddress).balanceOf(address(this));
        if (realReward> stAmt) {
            realReward = stAmt;
        }
	stRewardTotal = stRewardTotal.add(realReward);

        IERC20(stAddress).transfer(msg.sender, realReward);
	user.rewardPayout = user.rewardPayout.add(realReward);
	emit RewardClaimed(msg.sender, realReward);
	if(user.amount == 0 && user.rewardPayout == user.rewardTotal)
		removeUser(msg.sender);

        return realReward;
    }

    function addUser(address _account, uint256 _lpAmt) internal {
    	User memory user = users[_account];
	require(user.isUsed == false, "account already exists");
	require(_lpAmt > 0, "_lpAmt is 0");
	uint256 rewardDebt = _lpAmt.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER);
	users[_account] = User(_lpAmt, rewardDebt, 0, 0,  true);
	lastStakeBlock = block.number;
    }

    function removeUser(address account) internal {
    	User memory user = users[account];
	require(user.isUsed == true, "account no exists");
	delete users[account];
    }

    function pause() external onlyOwner {
        _pause();
	emit SystemPaused(msg.sender);
    }

    function unpause() external onlyOwner {
        _unpause();
	emit SystemUnpaused(msg.sender);
    }


    //call functions
    function getTotalLockedLP() external view returns (uint256){
    	return lpLockedTotal;
    }

    // Reward available
    function getPendingReward(address account) external view returns (uint256){
	User memory user = users[account];
	require(user.isUsed == true, "account no exists.");
	uint256 accReward = getAccReward();
	if(lpLockedTotal == 0)
		return user.rewardTotal.sub(user.rewardPayout);

	uint256 accr = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accr).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
    	return user.rewardTotal.add(reward).sub(user.rewardPayout);
    }
 
    // Reward mined
    function getTotalReward(address account) external view returns (uint256){
	User memory user = users[account];
	require(user.isUsed == true, "account no exists.");
	uint256 accReward = getAccReward();
	if(lpLockedTotal == 0)
		return user.rewardTotal;
	uint256 accr = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accr).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
    	return user.rewardTotal.add(reward);
    }
 
    // UserInfo
    function getUserInfo(address account) external view returns(uint256, uint256, uint256){
	    User memory user = users[account];
	    require(user.isUsed == true, "account no exists.");
	    return(user.amount, user.rewardTotal, user.rewardPayout);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
    constructor(address init_owner) {
	_owner = init_owner;
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
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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