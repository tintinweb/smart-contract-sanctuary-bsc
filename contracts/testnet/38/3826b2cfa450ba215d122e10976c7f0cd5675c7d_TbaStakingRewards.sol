/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-02
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



abstract contract  RewardsDistributionRecipient is Ownable {

    address public rewardsDistribution;

    function notifyRewardAmount(uint256 lpStakeReward, uint256 seutStakeReward) external virtual;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}

// interface IStakingRewards {
//     // Views

//     function balanceOf(address account) external view returns (uint256);

//     function earned(address account) external view returns (uint256);

//     function getRewardForDuration() external view returns (uint256);

//     function lastTimeRewardApplicable() external view returns (uint256);

//     function rewardPerToken() external view returns (uint256);

//     function totalSupply() external view returns (uint256);

//     // Mutative

//     function exit() external;

//     function getReward() external;

//     function stake(uint256 amount) external;

//     function withdraw(uint256 amount) external;
// }

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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



contract TbaStakingRewards is RewardsDistributionRecipient {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20[2] public stakingToken;

    uint256 public periodFinish = 0;
    uint256[2] public rewardRate;
    uint256 public rewardsDuration = 2 hours;
    uint256 public lastUpdateTime;
    uint256[2] public rewardPerTokenStored;

    mapping(address => uint256[2]) public userRewardPerTokenPaid;
    mapping(address => uint256[2]) public rewards;

    uint256[2] private _totalSupply;
    mapping(address => uint256[2]) private _balances;

    uint[2] withdrawCycle = [10 minutes, 20 minutes];
    mapping(address => uint256[2]) public withdrawTime;

    uint[] getRewardCycle = [0, 20 minutes];
    mapping(address => uint256[2]) public getRewardTime;

    mapping(address => uint256[2]) public userRewarded;



    uint[3] rate = [30, 6, 4];

    address[] others;

    address public defaultRecommender;
    mapping(address => address) public recommender;

    uint all = 100;

    mapping(address => bool) public whiteAddress;


    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsDistribution,
        address _rewardsToken,
        address[] memory _stakingToken
    ) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = [IERC20(_stakingToken[0]), IERC20(_stakingToken[1])];
        rewardsDistribution = _rewardsDistribution;
    }




    /* ========== VIEWS ========== */

    function totalSupply() external  view returns (uint256[2] memory) {
        return _totalSupply;
    }

    function balanceOf(address account) external  view returns (uint256[2] memory) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view  returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view  returns (uint256[2] memory) {
        return [
            0 == _totalSupply[0] ? rewardPerTokenStored[0] : rewardPerTokenStored[0].add(lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate[0]).mul(1e18).div(_totalSupply[0])),
            0 == _totalSupply[1] ? rewardPerTokenStored[1] : rewardPerTokenStored[1].add(lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate[1]).mul(1e18).div(_totalSupply[1]))
        ];
    }

    function earned(address account) public view returns (uint256[2] memory) {
        uint256[2] memory _rewardPerToken = rewardPerToken();
        return [
            _balances[account][0].mul(_rewardPerToken[0].sub(userRewardPerTokenPaid[account][0])).div(1e18).add(rewards[account][0]),
            _balances[account][1].mul(_rewardPerToken[1].sub(userRewardPerTokenPaid[account][1])).div(1e18).add(rewards[account][1])
        ];
    }

    function getEarned(address account) external view returns (uint256[2] memory) {
        uint256[2] memory _earned = earned(account);

        address fistRecommender = recommender[account];
        uint[2] memory fistRecommenderBalance = _balances[fistRecommender];
        uint firstRateLp = 0 < fistRecommenderBalance[0] ? rate[1] : 0;
        uint firstRateToken = 0 < fistRecommenderBalance[1] ? rate[1] : 0;

        address secondRecommender = recommender[fistRecommender];
        uint[2] memory secondRecommenderBalance = _balances[secondRecommender];
        uint secondRateLp = 0 < secondRecommenderBalance[0] ? rate[2] : 0;
        uint secondRateToken = 0 < secondRecommenderBalance[1] ? rate[2] : 0;

        return [
            _earned[0].mul(all.sub(rate[0]).sub(firstRateLp).sub(secondRateLp)).div(100),
            _earned[1].mul(all.sub(rate[0]).sub(firstRateToken).sub(secondRateToken)).div(100)
        ];
    }

    function getRewardForDuration() external view returns (uint256[2] memory) {
        return [
            rewardRate[0].mul(rewardsDuration),
            rewardRate[1].mul(rewardsDuration)
        ];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amountLp, uint256 amountSeut) external updateReward(msg.sender) {
        require(amountLp > 0 || amountSeut > 0, "Cannot stake 0");
        if(0 < amountLp){
            _totalSupply[0] = _totalSupply[0].add(amountLp);
            _balances[msg.sender][0] = _balances[msg.sender][0].add(amountLp);
            stakingToken[0].safeTransferFrom(msg.sender, address(this), amountLp);
            emit Staked(msg.sender, amountLp);
            withdrawTime[msg.sender][0] = block.timestamp.add(withdrawCycle[0]);
        }

        if(0 < amountSeut){
            _totalSupply[1] = _totalSupply[1].add(amountSeut);
            _balances[msg.sender][1] = _balances[msg.sender][1].add(amountSeut);
            stakingToken[1].safeTransferFrom(msg.sender, address(this), amountSeut);
            emit Staked(msg.sender, amountSeut);
            withdrawTime[msg.sender][1] = block.timestamp.add(withdrawCycle[1]);
        }
    }



    function withdraw(uint256 amountLp, uint256 amountSeut) public updateReward(msg.sender) {
        require(amountLp > 0 || amountSeut > 0, "Cannot withdraw 0");

        if(0 < amountLp){
            require(amountLp <= _balances[msg.sender][0], "Cannot withdraw: amount must less or equals stake amount");
            if(!whiteAddress[msg.sender]){
                require(block.timestamp> withdrawTime[msg.sender][0], 'It is not time to release the pledge');
            }
            _totalSupply[0] = _totalSupply[0].sub(amountLp);
            _balances[msg.sender][0] = _balances[msg.sender][0].sub(amountLp);
            stakingToken[0].safeTransfer(msg.sender, amountLp);
            emit Withdrawn(msg.sender, amountLp);
        }

        if(0 < amountSeut){
            require(amountSeut <= _balances[msg.sender][1], "Cannot withdraw: amount must less or equals stake amount");
            if(!whiteAddress[msg.sender]){
                require(block.timestamp> withdrawTime[msg.sender][1], 'It is not time to release the pledge');
            }
            _totalSupply[1] = _totalSupply[1].sub(amountSeut);
            _balances[msg.sender][1] = _balances[msg.sender][1].sub(amountSeut);
            stakingToken[1].safeTransfer(msg.sender, amountSeut);
            emit Withdrawn(msg.sender, amountSeut);
        }

    }

    function getReward(uint i) public  updateReward(msg.sender) {
        require(0 == i || 1 == i, 'The i must be zero or one');
        require(block.timestamp > getRewardTime[msg.sender][i], 'It is not time to getReward the pledge');
        uint256 reward = rewards[msg.sender][i];
        if (reward > 0) {
            rewards[msg.sender][i] = 0;

            uint rewardOthersAmount = 0;
            if(!isOthers(msg.sender)){
                rewardOthersAmount = rewardOthers(i, reward);

                address fistRecommender = recommender[msg.sender];
                if(0 < _balances[fistRecommender][i]){
                    uint firstReward = reward.mul(rate[1]).div(100);
                    rewardOthersAmount = rewardOthersAmount.add(firstReward);
                    rewards[fistRecommender][i] = rewards[fistRecommender][i].add(firstReward);
                }


                address secondRecommender = recommender[fistRecommender];
                if(0 < _balances[secondRecommender][i]){
                    uint secondReward = reward.mul(rate[2]).div(100);
                    rewardOthersAmount = rewardOthersAmount.add(secondReward);
                    rewards[secondRecommender][i] = rewards[secondRecommender][i].add(secondReward);
                }
            }
            
           
            uint userRewardleft = reward.sub(rewardOthersAmount);
            rewardsToken.safeTransfer(msg.sender, userRewardleft);

            userRewarded[msg.sender][i] = userRewarded[msg.sender][i].add(userRewardleft);
            
            emit RewardPaid(msg.sender, userRewardleft);

            if(0 < getRewardCycle[i]){
                 getRewardTime[msg.sender][i] = block.timestamp.add(getRewardCycle[i]);
            }
        }
    }




    function exit(uint i) external {
        require(0 == i || 1 == i, 'The i must be zero or one');
        if(0 == i){
            withdraw(_balances[msg.sender][i], 0);
        }
        if(1 == i){
            withdraw(0, _balances[msg.sender][i]);
        }
        getReward(i);
    }


    function resetRewardPerTokenStored() external onlyOwner {
        rewardPerTokenStored = [0, 0];
    }

    function resetOthers(address[] memory _address) external onlyOwner {
        others = _address;
    }

    function resetWhite(address _address) external onlyOwner {
        whiteAddress[_address] = !whiteAddress[_address];
    }

    function rewardOthers(uint tokenNum, uint _earned) private returns(uint) {
        if(0 < others.length){
            uint rewardAmounts = _earned.mul(rate[0]).div(100);
            uint rewardAmount = rewardAmounts.div(others.length);
            for(uint i = 0; i < others.length; i++){
                rewards[others[i]][tokenNum] = rewards[others[i]][tokenNum].add(rewardAmount);
            }

            return rewardAmounts;
        }

        return 0;
    }


    function isOthers(address account) public view returns(bool) {
        for(uint i = 0; i < others.length; i++){
            if(account == others[i]){
                return true;
            }
        }

        return false;
    }


    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 lpStakeReward, uint256 seutStakeReward) external override onlyRewardsDistribution updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
            rewardRate = [
                lpStakeReward.div(rewardsDuration),
                seutStakeReward.div(rewardsDuration)
            ];
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 lpStakeLeftover = remaining.mul(rewardRate[0]);
            uint256 seutStakeLeftover = remaining.mul(rewardRate[1]);
            rewardRate = [
                lpStakeReward.add(lpStakeLeftover).div(rewardsDuration),
                seutStakeReward.add(seutStakeLeftover).div(rewardsDuration)
            ];
        }

        uint balance = rewardsToken.balanceOf(address(this));
        require(rewardRate[0].add(rewardRate[1]) <= balance.div(rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(lpStakeReward);
        emit RewardAdded(seutStakeReward);
    }


    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        // require(tokenAddress != address(stakingToken), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }






    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }





    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);

}