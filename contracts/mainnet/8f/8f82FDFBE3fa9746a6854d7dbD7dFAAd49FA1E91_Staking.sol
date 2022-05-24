// SPDX-License-Identifier: MIT
pragma solidity ^0.8; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./utils/ArrayUtils.sol";
import "./utils/AccessControllable.sol";
import "./utils/Withdrawable.sol";

contract Staking is Ownable, AccessControllable, Withdrawable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    uint256 public stakingMinAmount;
    uint256 public stakingMaxAmount;
    uint256 public withdrawLockPeriod; // units = seconds
    uint256 public rewardRate;
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 private _stakingTotalSupply;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    
    struct AddressList {
        address[] values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    AddressList internal addressList;
    mapping(address => uint) private userRewardPerTokenPaid;
    mapping(address => uint) private rewards;

    struct Stake {
        uint256 balance;
        uint256 stakeDate;
    }

    mapping(address => Stake) private _stakes;
    event Staked(address account, uint256 amount);
    event StakingWithdrawn(address account, uint256 amount);
    event Claimed(address account, uint256 amount);

    constructor(address _stakingToken, 
    address _rewardToken, 
    uint256 _stakingMinAmount, 
    uint256 _stakingMaxAmount,
    uint256 _withdrawLockPeriod,
    uint256 _rewardRate) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        stakingMinAmount = _stakingMinAmount;
        stakingMaxAmount = _stakingMaxAmount;
        withdrawLockPeriod = _withdrawLockPeriod;
        rewardRate = _rewardRate;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function getStakingTokenAddress() public view returns (address) {
        return address(stakingToken);
    }

    function getRewardTokenAddress() public view returns (address) {
        return address(rewardToken);
    }

    /**
     * @notice it calculates the reward per token
     */
    function rewardPerToken() public view returns (uint) {
        if (_stakingTotalSupply == 0) {
            return 0;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _stakingTotalSupply);
    }

    /**
     * @notice it returns to the sender the amount of the rewards enarned
     */
    function getRewardsEarned() public view returns (uint) {
         return earned(msg.sender);
    }

    /**
     * @notice it returns the amount earned for a specific account
     * @param account the address of the account.
     */
    function earned(address account) internal view returns (uint256) {
        uint256 _rewardPerToken = rewardPerToken();
        if(_rewardPerToken < userRewardPerTokenPaid[account]) {
            return rewards[account];
        } 
         return
            ((_stakes[account].balance *
                (_rewardPerToken - userRewardPerTokenPaid[account])) / 1e18) + rewards[account];
    }

    /**
     * @notice it updates the reward amount for a specific account
     * @param account the address of the account.
     */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) { 
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /**
     * @notice the stakes function for the sender to deposit
     * @param amount The amount to stake.
     */
    function stake(uint256 amount) external whenNotPaused  updateReward(msg.sender) returns (bool) {
        require(amount > stakingMinAmount, 'stake: STAKING_AMOUNT_TOO_LOW');
        require(stakingToken.balanceOf(msg.sender) >= amount, 'stake: INSUFFICIENT_USER_BALANCE');

        _stakingTotalSupply += amount;
        
        Stake memory _stake = _stakes[msg.sender];

        if(_stake.stakeDate == 0) { // if the the stake is not yet created, register the sender address in the address list
            _setAddress(msg.sender);
        }
         _stake.balance += amount;
        _stake.stakeDate = block.timestamp;
        _stakes[msg.sender] = _stake;

        //TRANSFER AMOUNT TO THE CONTRACT
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
        return true;
    }

    /**
    * @notice the function for the user to withdraw the entire stake amount or a partial amount
    * @param amount The amount to widthdraw
    */
    function withdraw(uint256 amount) public nonReentrant whenNotPaused updateReward(msg.sender) returns (bool) {
        require(_stakes[msg.sender].stakeDate > 0, 'withdraw: STAKE_NOT_FOUND');
        require((block.timestamp - _stakes[msg.sender].stakeDate) > withdrawLockPeriod, 'withdraw: TOO_SOON_TO_WITHDRAW');
        require(amount > 0, 'withdraw: AMOUNT_TOO_LOW');
        require(_stakes[msg.sender].balance >= amount, 'withdraw: INSUFFICIENT_STAKE_BALANCE');
        
        _stakingTotalSupply -= amount;
        _stakes[msg.sender].balance -= amount;

        //TRANSFER AMOUNT TO THE USER
        stakingToken.safeTransfer(msg.sender, amount);
        
        if(_stakes[msg.sender].balance == 0) {
            delete _stakes[msg.sender];
            _deleteAddress(msg.sender);
        }
        emit StakingWithdrawn(msg.sender, amount);
        return true;
    }
    
    /**
     * @notice It transfer all the rewards earned of the sender to himself
     */
    function claimRewards() public nonReentrant whenNotPaused updateReward(msg.sender) returns (bool) {
        require(rewardToken.balanceOf(address(this)) > 0, 'claimReward: REWARD TOKEN CONTRACT BALANCE IS 0');
        uint reward = rewards[msg.sender];
        require(reward > 0, 'claimReward: REWARD BALANCE IS 0');
        rewards[msg.sender] = 0;
        rewardToken.safeTransfer(msg.sender, reward);
        if(rewards[msg.sender] == 0) {
            delete rewards[msg.sender];
        }
        emit Claimed(msg.sender, reward);
        return true;
    }

    /**
     * @notice It performs withdraw and getRewards in one transaction
     */
    function withdrawAndClaim() external whenNotPaused returns (bool) {
        withdraw(_stakes[msg.sender].balance);
        uint reward = rewards[msg.sender];
        if(reward > 0) {
            claimRewards();
        }
        return true;
    }

    /**
     * @notice It returns the total supply for the staking token
     */
    function getStakingTotalSupply() view external returns (uint256) {
        return _stakingTotalSupply;
    }

    /**
     * @notice It returns the stake info for the sender
     */
    function _getStakeInfo(address _address) view private returns (uint256 balance, uint256 stakeDate) {
        require(_stakes[_address].stakeDate > 0, 'getStake: NO_STAKE_FOUND');
        Stake memory _stake = _stakes[_address];
        return (_stake.balance, _stake.stakeDate);
    }

    /**
     * @notice It returns the stake info for the sender
     */
    function getStakeInfo() view external returns (uint256 balance, uint256 stakeDate) {
        return _getStakeInfo(msg.sender);
    }

    /**
     * @notice it sets the value of the minimum amount required for the stake
     * @param amount the amount to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setStakingMinAmount(uint256 amount) onlyAdminOrMigrator public returns (bool) {
         require(amount > 0, 'setStakingMinAmount: AMOUNT_IS_0');
         require(amount != stakingMinAmount, 'setStakingMinAmount: SAME_VALUE');
         stakingMinAmount = amount;
         return true;
    }

    /**
     * @notice it sets the value of the maximum amount allowed for the stake
     * @param amount the amount to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setStakingMaxAmount(uint256 amount) onlyAdminOrMigrator public returns (bool) {
         require(amount > 0, 'setStakingMaxAmount: AMOUNT_IS_0');
         require(amount != stakingMaxAmount, 'setStakingMaxAmount: SAME_VALUE');
         stakingMaxAmount = amount;
         return true;
    }

    /**
     * @notice it sets the amount of time the user have to wait to withdraw
     * @param time the amount of time expressed in seconds.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setWithdrawLockPeriod(uint256 time) onlyAdminOrMigrator public returns (bool) {
         require(time != withdrawLockPeriod, 'setWithdrawLockPeriod: SAME_VALUE');
         withdrawLockPeriod = time;
         return true;
    }

    /**
     * @notice it sets the value for the reward rate
     * @param value the value to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setRewardRate(uint256 value) onlyAdminOrMigrator public returns (bool) {
         require(value > 0, 'setRewardRate: VALUE_IS_0');
         require(value != rewardRate, 'setRewardRate: SAME_VALUE');
         rewardRate = value;
         return true;
    }

    /**
     * @notice it sets the address for the stakingToken
     * @param _stakingToken new address for the token.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setStakingToken(address _stakingToken) onlyAdminOrMigrator public returns (bool) {
        require(address(stakingToken) != _stakingToken, 'setStakingToken: SAME_ADDRESS');
        stakingToken = IERC20(_stakingToken);
        return true;
    }

    /**
     * @notice it sets the address for the rewardToken
     * @param _rewardToken new address for the token.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setRewardToken(address _rewardToken) onlyAdminOrMigrator public returns (bool) {
        require(address(rewardToken) != _rewardToken, 'setRewardToken: SAME_ADDRESS');
        rewardToken = IERC20(_rewardToken);
        return true;
    }

    modifier onlyAdminOrMigrator() {
        require(isAdmin() || isMigrator(), 'ERROR: ROLE_NOT_ALLOWED');
        _;
    }

    /**
     * @notice it save the sender address for migration purpose
     * @param _address the address to set.
     * @dev This function has private access.
     */
    function _setAddress(address _address) private {

         // save the new address if it's not present
        if(!addressList.inserted[_address]) {
            addressList.indexOf[_address]  = addressList.values.length;
            addressList.values.push(_address);
            addressList.inserted[_address] = true;
        }
    }

    /**
     * @notice it deletes the address from the addressList
     * @param _address the address to delete.
     * @dev This function has private access.
     */
    function _deleteAddress(address _address) private {
        if(!addressList.inserted[_address]) {
            return;
        }

        uint256 lastIndex   = addressList.values.length -1;
        address lastValue   = addressList.values[lastIndex];
        uint256 index       = addressList.indexOf[_address];

        // delete from the values array
        ArrayUtils.deleteFromAddressArray(addressList.values, index);

        // set the new index
        addressList.indexOf[lastValue] = index;

        // delete from mappings
        delete addressList.indexOf[_address];
        delete addressList.inserted[_address];
    }

    /**
     * @notice It allows the admin to pause the contract
     * @dev This function is only callable by admin or the contract migrator.
     */
    function pauseContract() public onlyAdminOrMigrator {
        _pause();
    }

    /**
     * @notice It allows the admin to unpause the contract
     * @dev This function is only callable by admin or the contract migrator.
     */
    function unpauseContract() public onlyAdminOrMigrator {
        _unpause();
    }

    // MIGRATION HELP FUNCTIONS --------------------------------------------------
    /**
     * @notice it returns the addresses list
     * @dev This function is only callable by admin or the contract migrator.
     */
    function getAddresses() onlyAdminOrMigrator public view returns (address[] memory addresses) {
         return addressList.values;
    }

    /**
     * @notice it calls the privae _setAddress function
     * @param _address the address to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setAddress(address _address) public onlyAdminOrMigrator whenPaused returns (bool) {
        _setAddress(_address);
        return true;
    }

    /**
     * @notice it sets the value for the _stakingTotalSupply state variable
     * @param value the value to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setStakingTotalSupply(uint256 value) onlyAdminOrMigrator whenPaused public returns (bool) {
         _stakingTotalSupply = value;
         return true;
    }

    /**
     * @notice it sets the value for the lastUpdateTime state variable
     * @param value the value to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setLastUpdateTime(uint256 value) onlyAdminOrMigrator whenPaused public returns (bool) {
         lastUpdateTime = value;
         return true;
    }

    /**
     * @notice it sets the value for the rewardPerTokenStored state variable
     * @param value the value to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setRewardPerTokenStored(uint256 value) onlyAdminOrMigrator whenPaused public returns (bool) {
         rewardPerTokenStored = value;
         return true;
    }

    /**
     * @notice it gets the value for the userRewardPerTokenPaid state variable
     * @param _address the address of the account.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function getUserRewardPerTokenPaid(address _address) onlyAdminOrMigrator public view returns (uint) {
         return userRewardPerTokenPaid[_address];
    }

    /**
     * @notice it sets the value for the userRewardPerTokenPaid state variable
     * @param value the value to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setUserRewardPerTokenPaid(address _address, uint value) onlyAdminOrMigrator whenPaused public returns (bool) {
         userRewardPerTokenPaid[_address] = value;
         return true;
    }

    /**
     * @notice it get the value for the rewards state variable
     * @param _address the address of the account.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function getRewards(address _address) onlyAdminOrMigrator public view returns (uint) {
         return rewards[_address];
    }

    /**
     * @notice it sets the value for the rewards state variable
     * @param value the value to set.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setRewards(address _address, uint value) onlyAdminOrMigrator whenPaused public returns (bool) {
         rewards[_address] = value;
         return true;
    }

    /**
     * @notice it get a stake by address
     * @param _address the address of the account.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function getStake(address _address) onlyAdminOrMigrator public view returns  (uint256 balance, uint256 stakeDate) {
         return _getStakeInfo(_address);
    }

    /**
     * @notice it sets the value for the stakes state variable
     * @param _address the address of the account.
     * @param balance balance for the stake.
     * @param stakeDate the date timestamp when the stak was created.
     * @dev This function is only callable by admin or the contract migrator.
     */
    function setStake(address _address, uint256 balance, uint256 stakeDate) onlyAdminOrMigrator whenPaused public returns (bool) {
         Stake memory _stake;
         _stake.balance = balance;
         _stake.stakeDate = stakeDate;
         _stakes[_address] = _stake;
         return true;
    }

    /**
     * @notice It allows the admin to recover ethers stored in the contract
     * @param to: the address of the wallett to receive the tokens
     * @dev This function is only callable by admin or the contract migrator.
     */
    function withdrawEthers(address to) public onlyAdminOrMigrator whenPaused {
        super._withdrawEthers(to);
    }

    /**
     * @notice It allows the admin to recover all the ERC20 tokens sent accidentally to the contract
     * @param _token: the address of the token to recover
     * @param to: the address of the wallett to receive the tokens
     * @dev This function is only callable by admin or the contract migrator.
     */
    function withdrawTokenAll(address _token, address to) public onlyAdminOrMigrator whenPaused returns (bool) {
        return super._withdrawTokenAll(_token, to);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library ArrayUtils {
    function deleteFromBytes32Array(bytes32[] storage array, uint256 index) internal {
        // Move the last element into the place to delete
        if(array.length == 0) {
            return;
        }
        array[index] = array[array.length-1];
        
        // Remove the last element
        array.pop();
    }

    function deleteFromAddressArray(address[] storage array, uint256 index) internal {
        // Move the last element into the place to delete
        if(array.length == 0) {
            return;
        }
        array[index] = array[array.length-1];
        
        // Remove the last element
        array.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract AccessControllable is AccessControl {
    
    bytes32 public constant MIGRATOR    = keccak256("MIGRATOR");

    function isMigrator() public view returns(bool) {
        return hasRole(MIGRATOR, msg.sender);
    }

    function isAdmin() public view returns(bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyMigrator() {
        require(hasRole(MIGRATOR, msg.sender), "ERROR: CALLER_IS_NOT_MIGRATOR");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "ERROR: CALLER_IS_NOT_ADMIN");
        _;
    }

    function transferAdminrRole(address _address) public virtual onlyAdmin {
        require(_address != msg.sender, "ERROR: SAME ADDRESS");
        grantRole(DEFAULT_ADMIN_ROLE, _address);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setAsMigratorRole(address _address) public virtual {
        grantRole(MIGRATOR, _address);
    }

    function removeFromMigratorRole(address _address) public virtual {
        revokeRole(MIGRATOR, _address);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Withdrawable {
    event Withdrawn(address from, address to, uint256 amount);

    receive() external payable {}

    /// @dev Allow the owner to transfer Ether
    function _withdrawEthers(address to) internal virtual {
        uint256 amount = address(this).balance;
        payable(to).transfer(amount);
        emit Withdrawn(msg.sender, to, amount);
    }
    
    /// @dev Allow the owner to transfer tokens
    function _withdrawTokenAll(address token, address to) internal virtual returns (bool) {
        IERC20 foreignToken = IERC20(token);
        uint256 amount      = foreignToken.balanceOf(address(this));
        bool result         = foreignToken.transfer(to, amount);
        if(result) {
            emit Withdrawn(msg.sender, to, amount);
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}