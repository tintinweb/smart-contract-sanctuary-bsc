//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
  @title Reflex Farming contract which helps to Deposit & Reward tokens
  @author RubanRubi
  @notice Add LP's, Deposit Token in LP's, Withdraw LP Tokens, Withdraw reward tokens,
 */
contract ReflexFarming is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    string public constant name = "Reflex - Farming";
    
    // Total amount deposited on pool
    mapping(uint256 => uint256) public totalDepositAmountInPool;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // LP Pair already created or not.
    mapping (IERC20Upgradeable => mapping(IERC20Upgradeable => bool)) public hasLPPair;

    // Info of each user.
    struct UserInfo {
        uint256 amount;           // How many LP tokens the user has provided.
        uint256 depositStartTime; // Deposit start time in pool
        bool hasDeposited;        // check is account Deposited
        bool isDeposited;         // check is account currently deposited
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20Upgradeable lpToken;                 // Address of LP token contract.
        IERC20Upgradeable rewardToken;             // Address of Reward token contract
        uint256 startTime;              // Lp's start time
        uint256 endTime;                // Lp's end time
        uint256 rewardInterval;         // reward interval in seconds
        uint256 rewardRate;             // reward rate in percentage (APR %)
        uint256 precision;              // how many points after dot in reward rate.if the APR is whole number need to give 0

    }

    event Reward(address indexed from, address indexed to, uint256 amount);
	event Deposit(address indexed from, address indexed to, uint256 amount);
    event UpdateDepositEndTime(uint256 endTime);
    event WithdrawAll(address indexed user, uint256 pid, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}
    function initialize() public virtual initializer {
        // initializing
        __Pausable_init();
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
    }

    /**
       @dev get pool length
       @return current pool length
    */
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /**
       @dev get current block timestamp
       @return current block timestamp
    */
    function getCurrentBlockTimestamp() external view returns(uint256){
        return block.timestamp;
    }

    /**
       @dev setting deposit pool end time
       @param _pid index of the array i.e pool id
       @param _endTime when deposit pool ends
    */
    function setPoolDepositEndTime(uint256 _pid, uint256 _endTime) external virtual onlyOwner whenNotPaused {
        poolInfo[_pid].endTime = _endTime;
        emit UpdateDepositEndTime(_endTime);
    }

    /** 
       @dev returns the total deposited tokens in pool and it is independent of the total tokens in pool keeps
       @param _pid index of the array i.e pool id
       @return total deposited amount in pool
    */
    function getTotalTokensDepositedInPool(uint256 _pid) external view returns (uint256) {
        return totalDepositAmountInPool[_pid];
    }

    /** 
       @dev returns the total depsited user tokens in pool and it is independent of the total tokens in pool keeps
       @param _pid index of the array i.e pool id
       @return user deposited balance in particular pool
    */
    function getUserDepositedTokensInPool(uint256 _pid) external view returns (uint256) {
        return userInfo[_pid][msg.sender].amount;
    }

    /**
       @dev Add a new lp to the pool. Can only be called by the owner.
       @param _lpToken user deposit token
       @param _rewardToken user rewarded token
       @param _startTime when pool starts
       @param _endTime when pool ends
       @param _rewardInterval reward interval between this reward interval in seconds
       @param _rewardRate (APR) in %
       @param _precision how many points after dot in reward rate if APR is without floating point percentage means give 0 in precision.
    */
    function addPool(IERC20Upgradeable _lpToken, IERC20Upgradeable _rewardToken, uint256 _startTime, uint256 _endTime, uint256 _rewardInterval, uint256 _rewardRate, uint256 _precision) public onlyOwner whenNotPaused {
        _beforeAddPool(_lpToken, _rewardToken, _startTime, _endTime, _rewardRate);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            rewardToken: _rewardToken,
            startTime: _startTime,
            endTime: _endTime,
            rewardInterval: _rewardInterval,
            rewardRate: _rewardRate,
            precision: _precision
        }));
        hasLPPair[_lpToken][_rewardToken] = true;
    }

    /**
       @dev AddPool validations.
       @param _lpToken user deposit token
       @param _rewardToken user rewarded token
       @param _startTime when pool starts
       @param _endTime when pool ends
       @param _rewardRate (APR) in %
    */
    function _beforeAddPool(IERC20Upgradeable _lpToken, IERC20Upgradeable _rewardToken, uint256 _startTime, uint256 _endTime, uint256 _rewardRate) internal virtual {
        require(block.timestamp >= _startTime, "Add Pool: Start Block has not reached");
        require(block.timestamp <= _endTime, "Add Pool: Has Ended");
        require(_rewardRate > 0, "Add Pool : Reward Rate(APR) in % Must be greater than 0");
        require(!hasLPPair[_lpToken][_rewardToken], "Add Pool: Pair already created");
    }

    /**
       @dev Deposit LP token's.
       @param _pid index of the array i.e pool id
       @param _amount deposit amount
    */
    function deposit(uint256 _pid, uint256 _amount) external virtual whenNotPaused {
        _beforeDeposit(_pid, _amount);
        UserInfo storage user = userInfo[_pid][msg.sender];
        bool transferStatus = poolInfo[_pid].lpToken.transferFrom(msg.sender, address(this), _amount);
        if (transferStatus) {
            // update user deposit balance in particular pool
            user.amount = user.amount + _amount;
            // update Contract deposit balance in pool
            totalDepositAmountInPool[_pid] += _amount;
            // save the time when they started staking in particular pool
            user.depositStartTime = block.timestamp;
            // update staking status in particular pool
            user.hasDeposited = true;
            user.isDeposited = true;
            emit Deposit(msg.sender, address(this), _amount);
        }  
    }

    /**
       @dev Deposit validations.
       @param _pid index of the array i.e pool id
       @param _amount deposit amount
    */
    function _beforeDeposit(uint256 _pid, uint256 _amount) internal virtual {
        require(_amount > 0, "Deposit: Amount cannot be 0");
        require(_pid <= poolInfo.length , "Deposit: Pool not exist");
        require(poolInfo[_pid].lpToken.balanceOf(msg.sender) >= _amount, "Deposit: Insufficient deposit token balance");
    }

    /**
       @dev calculateReward() function returns the reward of the caller of this function
       @param _pid index of the array i.e pool id
       @param _rewardAddress find how much reward in this address
       @return rewards and timedifference
    */
    function calculateReward(uint256 _pid, address _rewardAddress) public view returns(uint256, uint256){
        UserInfo storage user = userInfo[_pid][_rewardAddress];
        uint balances = user.amount;
		uint256 rewards = 0;
        uint256 timeDifferences;
		if(balances > 0){
            if(poolInfo[_pid].endTime > 0){
                if(block.timestamp > poolInfo[_pid].endTime){
                    timeDifferences = poolInfo[_pid].endTime - user.depositStartTime;
                }
                else{
                    timeDifferences = block.timestamp - user.depositStartTime;
                }
            }
            else {
                timeDifferences = block.timestamp - user.depositStartTime;
            }
            uint256 timeFactor = timeDifferences / poolInfo[_pid].rewardInterval;

            rewards = ((user.amount * poolInfo[_pid].rewardRate * timeFactor) / (100 * 10 ** poolInfo[_pid].precision));

		}
		return (rewards, timeDifferences);
    }

    /**
       @dev function used to claim only the reward for the caller of the method
       @param _pid index of the array i.e pool id
    */
    function claimMyReward(uint256 _pid) external nonReentrant whenNotPaused {
        require(_pid <= poolInfo.length , "Withdraw: Pool not exist");
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.timestamp >= user.depositStartTime , "Withdraw: Withdraw reward tokens after next Reward Interval");
        require(user.isDeposited, "Withdraw: No deposited token balance available");
        uint balance = user.amount;
        require(balance > 0, "Withdraw: Balance cannot be 0");
        (uint256 reward, uint256 timeDifferences) = calculateReward(_pid, msg.sender);
        require(reward > 0, "Withdraw: Calculated Reward zero");
        require(timeDifferences/poolInfo[_pid].rewardInterval >= 1, "Withdraw: Can be claimed only after the interval");
        uint256 rewardTokens = poolInfo[_pid].rewardToken.balanceOf(address(this));
        require(rewardTokens > reward, "Withdraw: Not Enough Reward Balance");
        bool rewardSuccessStatus = SendRewardTo(_pid, reward, msg.sender);
		//depositStartTime (set to current time)
        require(rewardSuccessStatus, "Withdraw: Claim Reward Failed");
        user.depositStartTime = block.timestamp + poolInfo[_pid].rewardInterval;
	}

    /**
       @dev check if the reward token is same as the deposited token
         If deposited token and reward token is same then -
         Contract should always contain more or equal tokens than deposited tokens
       @param _pid index of the array i.e pool id
       @param calculatedReward reward send to caller
       @param _toAddress caller address got reward
    */
    function SendRewardTo(uint256 _pid, uint256 calculatedReward, address _toAddress) internal virtual returns(bool){
        PoolInfo storage pool = poolInfo[_pid];
        require(_toAddress != address(0), 'Withdraw: Address cannot be zero');
        require(pool.rewardToken.balanceOf(address(this)) >= calculatedReward, "Withdraw: Not enough reward balance");
            if(pool.lpToken == pool.rewardToken){
                if((pool.rewardToken.balanceOf(address(this)) - calculatedReward) < totalDepositAmountInPool[_pid]){
                    calculatedReward = 0;
                }
            }
            bool successStatus = false;
            if(calculatedReward > 0){
                bool transferStatus = pool.rewardToken.transfer(_toAddress, calculatedReward);
                require(transferStatus, "Withdraw: Transfer Failed");
                if(userInfo[_pid][_toAddress].amount == 0) {
                  userInfo[_pid][_toAddress].isDeposited = false;
                } 
                // oldReward[_toAddress] = 0;
                emit Reward(address(this), _toAddress, calculatedReward);
                successStatus = true;
            }
        return successStatus;
    }

    /**
       @dev Emergency withdraw all deposited tokens and reward tokens
       @param _pid index of the array i.e pool id
     */
    function withdrawAll(uint256 _pid) external whenNotPaused {
        require(_pid <= poolInfo.length , "WithdrawAll: Pool not exist");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.timestamp >= user.depositStartTime , "Withdraw: Withdraw reward tokens after next Reward Interval");
        require(user.amount > 0, "WithdrawAll: Not enough reward balance");
        (uint256 reward,) = calculateReward(_pid, msg.sender);
        if(reward > 0) {
            uint256 rewardTokens = poolInfo[_pid].rewardToken.balanceOf(address(this));
            require(rewardTokens > reward, "WithdrawAll: Not Enough Reward Balance");
            bool rewardSuccessStatus = SendRewardTo(_pid, reward, msg.sender);
            require(rewardSuccessStatus, "WithdrawAll: Claim Reward Failed");
        }
        uint256 amount = user.amount;
        user.amount = 0;
        pool.lpToken.transfer(address(msg.sender), amount);
        emit WithdrawAll(msg.sender, _pid, amount); 
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}