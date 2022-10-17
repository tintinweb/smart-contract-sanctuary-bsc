// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../v1/SaverVault.sol";

/// @title SaverEarn
contract SaverEarnV2 is Ownable {
    IERC20 public immutable stakingToken;
    uint256 public totalStaked;
    uint256 public totalRewardsPaid;
    mapping(address => Staker) public stakers;
    /// track rates key
    uint256[] public rateKeys;
    /// Rate information, where the key is increments of 1 tracked by rateKeys
    mapping(uint256 => RateMultiplier) public rates;
    /// Withdrawal rate per day
    uint256 public withdrawRate;
    uint256 public constant MAX_INT_TYPE = type(uint256).max;
    /// Withdrawal tax fee in basis points
    uint256 public withdrawalTax;
    /// Exit Tax in basis points
    uint256 public exitTax;
    /// referral system
    mapping(address => address) public upline;
    mapping(address => UplineReward) public uplineReward;
    uint256 public minUplineReward;
    uint256 public maxUplineReward;
    address defaultReferralAddress;
    SaverVault public immutable vault;
    address public protocolVaultReceiverAddress;
    mapping(address => uint256) public protocolVaultReceiverRewards;

    struct RateMultiplier {
        uint256 rate;
        uint256 effectiveAt;
    }

    struct Staker {
        uint256 balance;
        uint256 stakedTime;
        /// total rewards claimed
        uint256 totalRewardsClaimed;
        ///track the current rate applicable to this user
        uint256 rateId;
    }

    struct UplineReward {
        uint256 accumulatedReward;
        uint256 claimableRewards;
        uint256 claimedRewards;
    }

    event Stake(address indexed user, uint256 indexed amount);
    event Unstake(address indexed user, uint256 indexed amount, uint256 indexed rewards);
    event ClaimRewards(address indexed user, uint256 indexed rewards);
    event Compound(address indexed user);
    event CloseAccount(address indexed user, uint256 indexed amount, uint256 indexed rewards);

    /**
     * @notice Initialize the staking token, rate and withdrawal rate
     * @param _stakingToken The staking token. This is also the token that is earned by the user
     * @param _rate The base rate which can be changed by the `owner`
     * @param _withdrawalRate The base withdrawal rate which can be changed by the `owner`
     */
    constructor(
        address _stakingToken,
        uint256 _rate,
        uint256 _withdrawalRate,
        uint256 _withdrawalTax,
        uint256 _exitTax,
        address _defaultReferralAddress,
        address _vault,
        address _protocolVaultReceiverAddress
    ) {
        stakingToken = IERC20(_stakingToken);
        createNewRate(_rate);
        withdrawRate = _withdrawalRate;
        withdrawalTax = _withdrawalTax;
        exitTax = _exitTax;
        defaultReferralAddress = _defaultReferralAddress;
        vault = SaverVault(_vault);
        protocolVaultReceiverAddress = _protocolVaultReceiverAddress;
    }

    /// ********** EXTERNAL FUNCTIONS **********

    /**
     * @notice Update the Rate % for rewards calculation
     * @param _rate New rate to be set in basis points
     * @dev 10000 = 100%, 1000 = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
     */
    function updateRate(uint256 _rate) external onlyOwner {
        require(_rate >= 1 && _rate <= 10000, "Percentage must be a value >=1 and <= 10000");
        createNewRate(_rate);
    }

    /**
     * @notice Update the rate of which a user can withdraw per day
     * @param _withdrawRate New withdrawal rate to be set in basis points
     * @dev 10000 = 100%, 1000 = 10%, 100 = 1%, 1 = 0.01%
     */
    function updateWithdrawRate(uint256 _withdrawRate) external onlyOwner {
        require(_withdrawRate >= 0 && _withdrawRate <= 10000, "Percentage must be a value >=0 and <= 10000");
        withdrawRate = _withdrawRate;
    }

    /**
     * @notice Update the withdrawal tax
     * @param _withdrawalTax New withdrawal tax to be set in basis points
     * @dev 10000 = 100%, 1000 = 10%, 100 = 1%, 1 = 0.01%
     */
    function updateWithdrawTax(uint256 _withdrawalTax) external onlyOwner {
        require(_withdrawalTax >= 0 && _withdrawalTax <= 10000, "Percentage must be a value >=0 and <= 10000");
        withdrawalTax = _withdrawalTax;
    }

    /**
     * @notice Update the withdrawal tax
     * @param _exitTax New withdrawal tax to be set in basis points
     * @dev 10000 = 100%, 1000 = 10%, 100 = 1%, 1 = 0.01%
     */
    function updateExitTax(uint256 _exitTax) external onlyOwner {
        require(_exitTax >= 0 && _exitTax <= 10000, "Percentage must be a value >=0 and <= 10000");
        exitTax = _exitTax;
    }

    function updateProtocolVaultReceiverAddress(address _protocolVaultReceiverAddress) external onlyOwner {
        protocolVaultReceiverAddress = _protocolVaultReceiverAddress;
    }

    function updateDefaultReferralAddress(address _defaultReferralAddress) external onlyOwner {
        defaultReferralAddress = _defaultReferralAddress;
    }

    /**
     * @notice Allows the `owner` to withdraw staked tokens to be invested to other projects
     * and pay out the rewards to the stakers
     * @param _amount The amount to be withdrawn
     * @param _to Address to send the funds to
     */
    function withdrawFunds(uint256 _amount, address _to) external onlyOwner {
        require(_amount <= getContractBalance(), "Contract does not have enough balance");
        stakingToken.transfer(_to, _amount);
    }

    /**
     * @notice Allows the `owner` to withdraw any erc20 tokens sent to this contract
     * @param token The erc20 token address
     * @param _to Address to send tokens to
     */
    function recover(IERC20 token, address _to) external onlyOwner {
        SafeERC20.safeTransfer(token, _to, token.balanceOf(address(this)));
    }

    /**
     *  @notice Allows the `owner` to update min and max upline reward in basis points
     */
    function setUplineRewardRate(uint256 _min, uint256 _max) external onlyOwner {
        require(_min >= 0 && _min <= 10000);
        require(_max > 0 && _max <= 10000);
        minUplineReward = _min;
        maxUplineReward = _max;
    }

    /**
     * @notice Stake a token to this contract and earn rewards base on the current rate
     * @param _amount The amount to be staked
     * @dev Calls `getEarnedRewards` to perform auto compound
     *
     */
    function stake(uint256 _amount) external {
        require(_amount >= 1 ether, "Minimum stake amount is 1 Saver Token");
        require(_amount < (MAX_INT_TYPE / 10000), "Maximum amount must be smaller, please try again");
        emit Stake(msg.sender, _amount);

        // bind defaultReferralAddress to this user
        if (upline[msg.sender] == address(0)) {
            upline[msg.sender] = defaultReferralAddress;
        }
        reinvest(_amount);
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice Compounds the user's earned rewards
     */
    function compound() external {
        uint256 earnedRewards = getEarnedRewards(msg.sender);
        require(earnedRewards >= 0.05 ether, "Compound failed, rewards must be >= 0.05 eth");
        emit Compound(msg.sender);
        reinvest(0);
    }

    /**
     * @notice Claim earned rewards
     */
    function claimRewards() external {
        uint256 earnedRewards = getEarnedRewards(msg.sender);
        stakers[msg.sender].totalRewardsClaimed += earnedRewards;
        totalRewardsPaid += earnedRewards;
        emit ClaimRewards(msg.sender, earnedRewards);
        stakingToken.transfer(msg.sender, earnedRewards);
    }

    /**
     * @notice Unstakes the specified amount
     * @param _amount Amount to be unstaked
     * @dev Rewards earned are also sent to the user.
     */
    function unstake(uint256 _amount) external {
        require(_amount >= 1 ether, "Minimum unstake amount is 1 saver token");
        require(stakers[msg.sender].balance >= _amount, "Insufficient balance");
        require(stakers[msg.sender].balance - _amount >= 1 ether, "Account must have a maintaining balance of 1 saver token");
        require(withdrawalLimit(msg.sender) >= _amount, "Exceeds withdrawal limit");
        require(_amount < (MAX_INT_TYPE / 10000), "Maximum amount must be smaller, please try again");

        /// claim rewards + transfer _amount to the user
        /// track user's last withdrawal
        uint256 earnedRewards = getEarnedRewards(msg.sender);
        stakers[msg.sender].stakedTime = block.timestamp;
        stakers[msg.sender].balance -= _amount;
        stakers[msg.sender].totalRewardsClaimed += earnedRewards;
        totalStaked -= _amount;
        totalRewardsPaid += earnedRewards;

        /// Withdrawal tax (subtracted from the _amount to be withdrawn)
        uint256 taxFee = (_amount * withdrawalTax) / 10000;
        uint256 _amountOut = _amount - taxFee;
        emit Unstake(msg.sender, _amountOut, earnedRewards);
        stakingToken.transfer(msg.sender, _amountOut + earnedRewards);
    }

    /**
     * @notice Allow users to close their account (unstake all / emergency unstake)
     */
    function closeAccount() external {
        /// Close account tax (subtracted from the _amount to be withdrawn)
        /// Compute for the tax first
        uint256 taxFee = (stakers[msg.sender].balance * exitTax) / 10000;
        uint256 _amountOut = stakers[msg.sender].balance - taxFee;
        /// Update and zero out user account
        uint256 earnedRewards = getEarnedRewards(msg.sender);
        /// Update stats first
        totalStaked -= stakers[msg.sender].balance;
        totalRewardsPaid += earnedRewards;
        /// Zero out sender account
        stakers[msg.sender].stakedTime = block.timestamp;
        stakers[msg.sender].balance -= stakers[msg.sender].balance;
        stakers[msg.sender].totalRewardsClaimed += earnedRewards;
        emit CloseAccount(msg.sender, _amountOut, earnedRewards);
        stakingToken.transfer(msg.sender, _amountOut + earnedRewards);
    }

    // Update upline address for referral bonus
    function updateUpline(address _upline) external {
        require(msg.sender != _upline, "Cannot refer self");
        require(upline[msg.sender] == address(0), "Cannot Change Upline");
        upline[msg.sender] = _upline;
    }

    /// ********** INTERNAL FUNCTIONS **********

    /**
     * @notice Creates a new rate
     * @param _rate value of the rate in % value. example 10% is passed as 10 lowest value is 1
     */
    function createNewRate(uint256 _rate) internal {
        uint256 rateId = rateKeys.length + 1;
        rateKeys.push(rateId);
        rates[rateId].rate = _rate;
        rates[rateId].effectiveAt = block.timestamp;
    }

    /**
     * @notice Update's the user's staked data and contract total staked balance
     * @param _amount Amount to be staked
     * @dev Function that is used for stake and compound
     */
    function reinvest(uint256 _amount) internal {
        uint256 earnedRewards = getEarnedRewards(msg.sender);
        if (earnedRewards > 0.05 ether) {
            // 1: Stake $100 with 0.05 rewards does auto compound
            // 2: Compound with min of earnedRewards >= 0.05
            stakers[msg.sender].balance += _amount + earnedRewards;
            totalRewardsPaid += earnedRewards;
            stakers[msg.sender].stakedTime = block.timestamp;
            stakers[msg.sender].rateId = getCurrentRateId();
            stakers[msg.sender].totalRewardsClaimed += earnedRewards;
            totalStaked += _amount + earnedRewards;
            uplineRewards(earnedRewards);
        } else {
            // 3: Stake $100 with 0.001 rewards, no rewards are paid-out
            // only for stake function
            stakers[msg.sender].balance += _amount;
            stakers[msg.sender].stakedTime = block.timestamp;
            stakers[msg.sender].rateId = getCurrentRateId();
            totalStaked += _amount;
        }
    }

    function uplineRewards(uint256 earnedRewards) internal {
        address _upline = upline[msg.sender];
        if (_upline == address(0) && defaultReferralAddress != address(0)) {
            _upline = defaultReferralAddress;
        }
        if (_upline != address(0) && earnedRewards >= 0.05 ether) {
            uplineReward[_upline].accumulatedReward += earnedRewards;
            uint256 bonusPercent = computeReferralBonus(_upline);
            // reward upline
            uint256 reward = (earnedRewards * bonusPercent) / 10000;
            uplineReward[_upline].claimableRewards += reward;
            // send remaining % to vault wallet, if any % remains
            uint256 remainingPercentToVaultWallet = maxUplineReward - bonusPercent;
            if (remainingPercentToVaultWallet > 0 && protocolVaultReceiverAddress != address(0)) {
                uint256 protocolVaultReceiverAddressReward = (earnedRewards * remainingPercentToVaultWallet) / 10000;
                protocolVaultReceiverRewards[protocolVaultReceiverAddress] += protocolVaultReceiverAddressReward;
            }
        }
    }

    function computeReferralBonus(address _upline) public view returns (uint256) {
        uint256 sharesValue = vault.sharesValueOfAddress(_upline);
        // sharesValue / accumulatedReward, in basis points.
        uint256 vaultPercent = (sharesValue * 10000) / uplineReward[_upline].accumulatedReward;
        uint256 bonusPercent = vaultPercent;
        if (vaultPercent <= minUplineReward) {
            bonusPercent = minUplineReward;
        }
        if (vaultPercent >= maxUplineReward) {
            bonusPercent = maxUplineReward;
        }
        return bonusPercent;
    }

    function claimUplineRewards() external {
        uint256 availableRewards = uplineReward[msg.sender].claimableRewards;
        require(availableRewards > 0, "No claimable rewards");
        uplineReward[msg.sender].claimedRewards += availableRewards;
        uplineReward[msg.sender].claimableRewards = 0;
        stakingToken.transfer(msg.sender, availableRewards);
    }

    function claimProtocolVaultReceiverRewards() external {
        uint256 rewards = protocolVaultReceiverRewards[msg.sender];
        require(rewards > 0, "No protocol vault receiver rewards");
        protocolVaultReceiverRewards[msg.sender] = 0;
        stakingToken.transfer(msg.sender, rewards);
    }

    /// ********** VIEW & PURE FUNCTIONS **********
    /**
     * @notice Computes the reward per second base on princial and rate
     * @param principal Reflects the staker's staked balance
     * @param rate The reward rate
     */
    function computeRewardPerSecond(uint256 principal, uint256 rate) public pure returns (uint256) {
        uint256 maxReward = (principal * rate) / 10000;
        uint256 rewardPerSecond = maxReward / 365 days;
        return rewardPerSecond;
    }

    /**
     * @notice Compute user's total rewards base on his last staked and all applicable rates
     * @dev This does not take into account unclaimed rewards.
     */
    function getEarnedRewards(address _address) public view returns (uint256) {
        uint256 totalRewards;
        // Case 1: user already has the lastest rate
        if (stakers[_address].rateId == rateKeys.length) {
            uint256 stakeDuration = block.timestamp - stakers[_address].stakedTime;
            totalRewards += computeRewardPerSecond(stakers[_address].balance, rates[stakers[_address].rateId].rate) * stakeDuration;
            return totalRewards;
        }
        /// Case 2: rates changed and user's current rate id is not yet updated (not claimed)
        /// loop thru all the indexes, starting at the last staker index and calculate past rewards base on past rates
        bool firstIteration = true;
        for (uint256 i = stakers[_address].rateId; i <= rateKeys.length; i++) {
            uint256 stakeDuration = 0;
            if (i == rateKeys.length) {
                // last iteration, this means that this is the latest reward!
                stakeDuration = block.timestamp - rates[i].effectiveAt;
            } else {
                if (firstIteration) {
                    stakeDuration = rates[i + 1].effectiveAt - stakers[_address].stakedTime;
                    firstIteration = false;
                } else {
                    stakeDuration = rates[i + 1].effectiveAt - rates[i].effectiveAt;
                }
            }
            totalRewards += computeRewardPerSecond(stakers[_address].balance, rates[i].rate) * stakeDuration;
        }
        return totalRewards;
    }

    /**
     * @notice Computes the withdrawal limit of user
     * @param _address Address of the user
     * @dev withdrawal limit is computed per second and withdrawal rate set by the owner
     */
    function withdrawalLimit(address _address) public view returns (uint256) {
        if (withdrawRate == 0) return stakers[_address].balance;
        uint256 withdrawableLimitPerDay = (stakers[_address].balance * withdrawRate) / 10000;
        uint256 timeStaked = block.timestamp - stakers[_address].stakedTime;
        uint256 limit = (withdrawableLimitPerDay * timeStaked) / 1 days;
        if (limit > stakers[_address].balance) return stakers[_address].balance;
        return limit;
    }

    /**
     * @notice Gets the latest rate % implemented
     */
    function getRate() public view returns (uint256) {
        return rates[rateKeys[getCurrentRateId() - 1]].rate;
    }

    function getCurrentRateId() public view returns (uint256) {
        return rateKeys.length;
    }

    function getUserTotalRewardsClaimed(address _address) public view returns (uint256) {
        return stakers[_address].totalRewardsClaimed;
    }

    function getUserStakedBalance(address _address) public view returns (uint256) {
        return stakers[_address].balance;
    }

    function getUserLastStakedTime(address _address) public view returns (uint256) {
        return stakers[_address].stakedTime;
    }

    function getContractBalance() public view returns (uint256) {
        return stakingToken.balanceOf(address(this));
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SaverVault is Ownable {
    IERC20 public immutable token;
    uint256 public totalSupply;
    mapping(address => uint256) public ownedShares;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint256 _shares) private {
        totalSupply += _shares;
        ownedShares[_to] += _shares;
    }

    function _burn(address _from, uint256 _shares) private {
        totalSupply -= _shares;
        ownedShares[_from] -= _shares;
    }

    function deposit(uint256 _amount) external {
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint256 shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _shares) external {
        require(_shares <= ownedShares[msg.sender], "Not enough shares");
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */
        uint256 amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }

    /**
     * @notice Allows the `owner` to withdraw staked tokens to be invested to other projects
     * and pay out the rewards to the stakers
     * @param _amount The amount to be withdrawn
     * @param _to Address to send the funds to
     */
    function withdrawFunds(uint256 _amount, address _to) external onlyOwner {
        require(_amount <= getContractBalance(), "Contract does not have enough balance");
        token.transfer(_to, _amount);
    }

    /**
     * @notice Allows the `owner` to withdraw any erc20 tokens sent to this contract
     * @param _token The erc20 token address
     * @param _to Address to send tokens to
     */
    function recover(IERC20 _token, address _to) external onlyOwner {
        SafeERC20.safeTransfer(_token, _to, token.balanceOf(address(this)));
    }

    function sharesValue(uint256 _shares) external view returns (uint256) {
        if (totalSupply == 0) return 0;
        uint256 amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        return amount;
    }

    function sharesValueOfAddress(address _account) external view returns (uint256) {
        if (totalSupply == 0) return 0;
        return (ownedShares[_account] * token.balanceOf(address(this))) / totalSupply;
    }

    function getContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}