// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Helper.sol";

/**
 * @title Launchpad
 * @dev 4 rounds : 0 = not open, 1 = guaranty round, 2 = fcfs, 3 = sale finished
 */
contract Launchpad is Ownable {
    using SafeERC20 for IERC20;

    error FunctionInvalidAtThisRound(uint8 currentRound, uint8 requiredRound);
    error UsersAndAllocationsArrayNeedToBeSameLength();
    error NotWhitelistedOrAlreadyFullyParticipated();
    error CannotMatchTiersToAllowances();
    error AmountTooHigh();
    error SaleDateCannotBeInThePast();
    error SaleAlreadyEnded();
    error SaleHasNotEnded();
    error SoldOut();
    error MustNotBeZero(string param);
    error NoZeroAddress(string param);

    uint16 public round2Multiplier;
    uint256 public saleStartDate;
    uint256 public immutable tokenTarget;
    uint256 public immutable stableTarget;
    uint256 public immutable multiplier; // ratio between tokenTarget and stableTarget * 10000
    uint256 public immutable round1Duration = 2 hours;
    bool public endUnlocked;
    uint256 public totalOwed;
    uint256 public stableRaised;

    IERC20 public immutable stablecoin;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) private userAllocation;
    mapping(address => bool) public hasParticipated;
    mapping(address => uint256) public contributedRound1;
    mapping(address => uint256) public contributedRound2;
    address[] public participants;
    mapping(address => bool) public admins;

    event SaleWillStart(uint256 startTimestamp);
    event SaleEnded(uint256 endTimestamp);
    event PoolProgress(uint256 stableRaised, uint256 stableTarget);
    event Round2MultiplierChanged(uint16 round2Multiplier);

    modifier atRound(uint8 requiredRound) {
        uint8 currentRound = roundNumber();
        if (currentRound != requiredRound) {
            revert FunctionInvalidAtThisRound(currentRound, requiredRound);
        }
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Caller is not the admin");
        _;
    }

    constructor(
        uint256 _tokenTarget,
        uint256 _stableTarget,
        uint256 _saleStartDate,
        uint16 _round2Multiplier,
        IERC20 _stableCoinAddress,
        address[] memory _admins
    ) {
        if (_stableTarget == 0) revert MustNotBeZero("_stableTarget");
        if (_tokenTarget == 0) revert MustNotBeZero("_tokenTarget");
        if (_round2Multiplier == 0) revert MustNotBeZero("_round2Multiplier");
        if (address(_stableCoinAddress) == address(0)) {
            revert NoZeroAddress("_stableCoinAddress");
        }

        tokenTarget = _tokenTarget;
        stableTarget = _stableTarget;
        saleStartDate = _saleStartDate;
        round2Multiplier = _round2Multiplier;
        multiplier = (tokenTarget * 10000) / stableTarget;
        stablecoin = _stableCoinAddress;

        admins[msg.sender] = true;
        for (uint256 i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }

    function addAdmin(address user) external onlyOwner {
        admins[user] = true;
    }

    function isAdmin(address user) external view returns (bool isUserAdmin) {
        isUserAdmin = admins[user];
    }

    function setRound2Multiplier(uint16 _round2Multiplier) external onlyOwner {
        round2Multiplier = _round2Multiplier;

        emit Round2MultiplierChanged(_round2Multiplier);
    }

    function setSaleStartDate(uint256 _saleStartDate)
        external
        onlyOwner
        atRound(0)
    {
        if (block.timestamp - 60 > _saleStartDate) {
            revert SaleDateCannotBeInThePast();
        }

        saleStartDate = _saleStartDate;

        emit SaleWillStart(block.timestamp);
    }

    function finishSale() external onlyOwner {
        if (endUnlocked) revert SaleAlreadyEnded();

        endUnlocked = true;
        emit SaleEnded(block.timestamp);
    }

    // whitelisting
    function addWhitelistedAddress(address user, uint256 allocation)
        external
        onlyAdmin
    {
        _addWhitelistedAddress(user, allocation);
    }

    function addMultipleWhitelistedAddresses(
        address[] calldata users,
        uint256[] calldata allocations
    ) external onlyAdmin {
        if (users.length != allocations.length) {
            revert UsersAndAllocationsArrayNeedToBeSameLength();
        }

        for (uint256 i = 0; i < users.length; i++) {
            _addWhitelistedAddress(users[i], allocations[i]);
        }
    }

    function _addWhitelistedAddress(address user, uint256 allocation) private {
        whitelist[user] = true;
        userAllocation[user] = allocation;
    }

    function removeWhitelistedAddress(address user) external onlyOwner {
        whitelist[user] = false;
        userAllocation[user] = 0;
    }

    function withdrawStable() external onlyOwner {
        if (!endUnlocked) revert SaleHasNotEnded();

        stablecoin.safeTransfer(
            msg.sender,
            stablecoin.balanceOf(address(this))
        );
    }

    function getUserContribution(address user)
        external
        view
        returns (uint256 contributedStable, uint256 tokensToReceive)
    {
        contributedStable = contributedRound1[user] + contributedRound2[user];
        tokensToReceive = (contributedStable * multiplier) / 10000;
    }

    // @notice rescue any token accidentally sent to this contract
    function emergencyWithdrawToken(IERC20 token)
        external
        onlyOwner
        atRound(3)
    {
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function buyRound1(uint256 stableAmount) external atRound(1) {
        uint256 allowance = round1Allowance(msg.sender);

        _checkAllowance(allowance, stableAmount);

        _registerParticipation(msg.sender);

        contributedRound1[msg.sender] += stableAmount;

        _buy(stableAmount);
    }

    function buyRound2(uint256 stableAmount) external atRound(2) {
        uint256 allowance = round2Allowance(msg.sender);

        _checkAllowance(allowance, stableAmount);

        _registerParticipation(msg.sender);

        contributedRound2[msg.sender] += stableAmount;

        _buy(stableAmount);
    }

    function _checkAllowance(uint256 allowance, uint256 amount) private pure {
        if (allowance == 0) revert NotWhitelistedOrAlreadyFullyParticipated();

        if (amount > allowance) revert AmountTooHigh();
    }

    function _registerParticipation(address user) private {
        if (!hasParticipated[user]) {
            hasParticipated[user] = true;
            participants.push(user);
        }
    }

    function _buy(uint256 stableAmount) private {
        stablecoin.safeTransferFrom(msg.sender, address(this), stableAmount);

        uint256 tokenAmount = (stableAmount * multiplier) / 10000;

        totalOwed += tokenAmount;
        if (totalOwed > tokenTarget) {
            revert SoldOut();
        }

        stableRaised += stableAmount;

        if (stableRaised > stableTarget) {
            revert SoldOut();
        }

        emit PoolProgress(stableRaised, stableTarget);

        if (stableRaised == stableTarget) {
            endUnlocked = true;
            emit SaleEnded(block.timestamp);
        }
    }

    function roundNumber() public view returns (uint8 _roundNumber) {
        if (endUnlocked) return 3;

        if (block.timestamp < saleStartDate || saleStartDate == 0) {
            return 0;
        }

        if (
            block.timestamp >= saleStartDate &&
            block.timestamp < saleStartDate + round1Duration
        ) {
            return 1;
        }

        if (block.timestamp >= (saleStartDate + round1Duration)) {
            return 2;
        }
    }

    function getNumberOfParticipants() public view returns (uint256) {
        return participants.length;
    }

    function isWhitelisted(address user) public view returns (bool) {
        return whitelist[user];
    }

    function round1Allowance(address user) public view returns (uint256) {
        if (!whitelist[user]) return 0;

        return userAllocation[user] - contributedRound1[user];
    }

    function round2Allowance(address user) public view returns (uint256) {
        if (!whitelist[user]) return 0;

        return
            (userAllocation[user] * round2Multiplier) - contributedRound2[user];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Staking.sol";

struct Tier {
    string name;
    uint256 amountNeeded;
    uint16 weight;
}

struct UserTokensToReceive {
    address user;
    uint256 tokens;
}

interface ILaunchpad {
    function getUserContribution(address)
        external
        view
        returns (uint256, uint256);

    function hasParticipated(address) external view returns (bool);
}

contract Helper is Ownable {
    using SafeERC20 for IERC20;
    error TiersShouldBeOrderByAmountNeeded();
    error NoZeroLaunchPadAddress();
    error LaunchpadVestingPairAlreadyExists();
    error LaunchpadDoesNotExists();
    error WrongOffset();

    Staking[] public stakingContracts;
    Tier[] public tiers;

    mapping(string => Tier) public tiersMap;

    /**
     * @dev Tiers should be ordered asc by amountNeeded
     * @param _stakingContracts Array of all of staking contracts deployed
     * @param _tiers Array of all staking tiers
     */
    constructor(Staking[] memory _stakingContracts, Tier[] memory _tiers) {
        for (uint8 i = 0; i < _stakingContracts.length; i++) {
            stakingContracts.push(_stakingContracts[i]);
        }

        Tier memory noneTier = Tier("NONE", 0, 0);
        tiers.push(noneTier);
        tiersMap["NONE"] = noneTier;

        Tier memory prevTier = tiers[0];
        for (uint256 i = 0; i < _tiers.length; i++) {
            if (prevTier.amountNeeded >= _tiers[i].amountNeeded) {
                revert TiersShouldBeOrderByAmountNeeded();
            }
            tiers.push(_tiers[i]);
            tiersMap[_tiers[i].name] = _tiers[i];

            prevTier = _tiers[i];
        }
    }

    /**
     * @notice Returns array of all possible tiers including "NONE"
     */
    function getTiersData() external view returns (Tier[] memory) {
        return tiers;
    }

    /**
     * @notice Aggregates data from all staking contracts to determine user tier
     * @param user  Address of the staker
     */
    function getUserStakingData(address user)
        public
        view
        returns (
            string memory tierName,
            uint256 totalAmount,
            Deposit[] memory userDeposits
        )
    {
        userDeposits = new Deposit[](stakingContracts.length);

        for (uint256 i = 0; i < stakingContracts.length; i++) {
            userDeposits[i] = stakingContracts[i].getUserDeposit(user);

            if (
                !userDeposits[i].paid &&
                // wait for at least one block before validating user deposit
                block.timestamp > userDeposits[i].depositTime
            ) {
                totalAmount += userDeposits[i].depositAmount;
            }
        }

        for (uint256 j = tiers.length - 1; j >= 0; j--) {
            if (totalAmount >= tiers[j].amountNeeded) {
                tierName = tiers[j].name;
                break;
            }
        }

        return (tierName, totalAmount, userDeposits);
    }

    /**
     * @notice Aggregates contract info from all staking contracts to make things easier on FE
     */
    function getStakingContractsInfo()
        external
        view
        returns (StakingContractInfo[] memory stakingContractsInfo)
    {
        stakingContractsInfo = new StakingContractInfo[](
            stakingContracts.length
        );

        for (uint256 i = 0; i < stakingContracts.length; i++) {
            stakingContractsInfo[i] = stakingContracts[i].getContractInfo();
        }

        return stakingContractsInfo;
    }

    // @notice rescue any token accidentally sent to this contract
    function emergencyWithdrawToken(IERC20 token) external onlyOwner {
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    // @dev used for snapshot before IDO
    function getUsersWeights(address[] calldata users)
        external
        view
        returns (uint16[] memory userWeights, uint256 blockNumber)
    {
        userWeights = new uint16[](users.length);

        for (uint256 i = 0; i < users.length; i++) {
            (string memory tier, , ) = getUserStakingData(users[i]);
            userWeights[i] = tiersMap[tier].weight;
        }

        return (userWeights, block.number);
    }

    // @dev get user tokens to receive
    function getUserTokensToReceive(
        address[] calldata users,
        ILaunchpad launchpad
    )
        external
        view
        returns (UserTokensToReceive[] memory usersTokensToReceive)
    {
        usersTokensToReceive = new UserTokensToReceive[](users.length);

        for (uint256 i = 0; i < users.length; i++) {
            (, uint256 tokensToReceive) = launchpad.getUserContribution(
                users[i]
            );
            usersTokensToReceive[i] = UserTokensToReceive(
                users[i],
                tokensToReceive
            );
        }

        return usersTokensToReceive;
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
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 *  @dev Structs to store user staking data.
 */
struct Deposit {
    uint256 depositAmount;
    uint256 depositTime;
    uint256 endTime;
    uint32 rate;
    bool paid;
}

/**
 *  @dev Structs to store staking contract basic information
 */
struct StakingContractInfo {
    string name;
    address addr;
    uint32 lockDuration; // in hours
    uint32 rate;
    uint8 withdrawFeePercent;
}

contract Staking is Ownable {
    using SafeERC20 for IERC20;

    error AllowanceTooLow(uint256 current, uint256 required);
    error InsufficientRewardsPleaseAddRewardsOrUseEmergencyExit(
        uint256 available,
        uint256 required
    );
    error MustNotBeZero(string param);
    error NoStakeFoundForUser(address user);
    error NoZeroAddress(string param);
    error MaturityDateExpiredPleaseWithdraw();
    error StakingIsPaused();
    error MustBeLessOrEqual100();

    mapping(address => Deposit) private deposits;
    mapping(address => bool) private hasStaked;

    StakingContractInfo internal contractInfo;
    IERC20 public tokenAddress;
    address public treasury;
    uint256 public stakedBalance;
    uint256 public rewardBalance;
    uint256 public totalParticipants;
    bool public isStopped;
    uint256 public constant INTEREST_RATE_CONVERTER = 100;
    uint256 public constant YEAR_IN_SECONDS = 31536000;

    /**
     *  @notice Emitted when user stakes new value of tokens
     */
    event Staked(
        address indexed token,
        address indexed staker,
        uint256 stakedAmount
    );

    /**
     *  @notice Emitted when user withdraws his deposit
     */
    event PaidOut(
        address indexed token,
        address indexed staker,
        uint256 amount,
        uint256 reward
    );

    /**
     *  @notice Emitted when user withdraws his deposit
     */
    event RateAndLockdurationChanged(
        uint32 newRate,
        uint32 lockDuration,
        uint256 time
    );

    /**
     *  @notice Emitted when new amount of rewards is added to contract
     */
    event RewardsAdded(uint256 amount, uint256 time);

    /**
     *  @notice Emitted when contract is paused/unpaused
     */
    event StakingStatusChanged(bool status, uint256 time);

    /**
     *  @notice Emitted when owner changes withdraw fee
     */
    event WithdrawFeeChanged(uint8 newFee, uint256 time);

    modifier withdrawCheck(address from) {
        if (!hasStaked[from]) revert NoStakeFoundForUser(from);
        _;
    }

    modifier hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        uint256 ourAllowance = tokenAddress.allowance(allower, address(this));

        if (amount > ourAllowance) revert AllowanceTooLow(ourAllowance, amount);
        _;
    }

    /**
     *   @param name name of the contract
     *   @param tokenAddress_ contract address of the token
     *   @param rate percentage
     *   @param lockDuration duration in hours
     */
    constructor(
        string memory name,
        IERC20 tokenAddress_,
        uint32 rate,
        uint32 lockDuration,
        uint8 withdrawFeePercent,
        address treasury_
    ) {
        if (withdrawFeePercent > 100) revert MustBeLessOrEqual100();
        if (address(tokenAddress_) == address(0)) {
            revert NoZeroAddress("tokenAddress_");
        }
        if (address(treasury_) == address(0)) {
            revert NoZeroAddress("treasury_");
        }

        contractInfo = StakingContractInfo(
            name,
            address(this),
            lockDuration,
            rate,
            withdrawFeePercent
        );

        tokenAddress = tokenAddress_;
        treasury = treasury_;
    }

    /**
     *  @notice owner can change current withdraw fee for stakers
     *  @param percent withdraw fee percentage
     */
    function setWithdrawFee(uint8 percent) external onlyOwner {
        if (percent > 100) revert MustBeLessOrEqual100();

        contractInfo.withdrawFeePercent = percent;

        emit WithdrawFeeChanged(percent, block.timestamp);
    }

    /**
     *  @notice to set new interest rates and lock duration
     *  @param rate New effective interest rate
     *  @param lockDuration Duration of lock for new deposits in hours
     *  @dev lockduration is in hours
     */
    function setRateAndLockduration(uint32 rate, uint32 lockDuration)
        external
        onlyOwner
    {
        contractInfo.rate = rate;
        contractInfo.lockDuration = lockDuration;

        emit RateAndLockdurationChanged(rate, lockDuration, block.timestamp);
    }

    /**
     *  @dev if _status is false contract will be "stopped" and
     *  no new deposits will be allowed
     */
    function changeStakingStatus(bool _status) external onlyOwner {
        isStopped = _status;

        emit StakingStatusChanged(_status, block.timestamp);
    }

    /**
     *  @param amount Amount to be staked
     *  @dev to stake 'amount' value of tokens
     *  once the user has given allowance to the staking contract
     */
    function stake(uint256 amount) external hasAllowance(msg.sender, amount) {
        if (amount == 0) revert MustNotBeZero("amount");
        if (isStopped) revert StakingIsPaused();

        address from = msg.sender;
        if (hasStaked[from] && (block.timestamp >= deposits[from].endTime)) {
            revert MaturityDateExpiredPleaseWithdraw();
        }

        uint256 newAmount;
        if (hasStaked[from]) {
            newAmount =
                amount +
                deposits[from].depositAmount +
                _calculate(from, block.timestamp);
        } else {
            hasStaked[from] = true;

            newAmount = amount;
            totalParticipants += 1;
        }

        deposits[from] = Deposit({
            depositAmount: newAmount,
            depositTime: block.timestamp,
            endTime: block.timestamp +
                uint256(contractInfo.lockDuration) *
                3600,
            rate: contractInfo.rate,
            paid: false
        });

        stakedBalance = stakedBalance + amount;
        tokenAddress.safeTransferFrom(from, address(this), amount);

        emit Staked(address(tokenAddress), from, amount);
    }

    function getUserDeposit(address _userAddress)
        external
        view
        returns (Deposit memory)
    {
        return deposits[_userAddress];
    }

    function getContractInfo()
        public
        view
        returns (StakingContractInfo memory)
    {
        return contractInfo;
    }

    /**
     * @notice Calcule withdraw penalty for user if deposit is withdrawn now
     *
     */
    function calculateWithdrawFee(address user) public view returns (uint256) {
        Deposit storage userDeposit = deposits[user];

        if (block.timestamp > userDeposit.endTime) {
            return 0;
        }

        return
            (userDeposit.depositAmount * contractInfo.withdrawFeePercent) / 100;
    }

    /**
     *  @param rewardAmount rewards to be added to the staking contract
     *  @dev to add rewards to the staking contract
     *  once the allowance is given to this contract for 'rewardAmount' by the user
     */
    function addReward(uint256 rewardAmount)
        external
        hasAllowance(msg.sender, rewardAmount)
    {
        if (rewardAmount == 0) revert MustNotBeZero("rewardAmount");

        rewardBalance = rewardBalance + rewardAmount;

        tokenAddress.safeTransferFrom(msg.sender, address(this), rewardAmount);

        emit RewardsAdded(rewardAmount, block.timestamp);
    }

    function withdraw() external withdrawCheck(msg.sender) {
        address from = msg.sender;
        uint256 endTime = Math.min(block.timestamp, deposits[from].endTime);
        uint256 reward = _calculate(from, endTime);

        if (rewardBalance < reward) {
            revert InsufficientRewardsPleaseAddRewardsOrUseEmergencyExit(
                rewardBalance,
                reward
            );
        }

        _withdraw(from, reward);
    }

    function _withdraw(address from, uint256 reward) private {
        uint256 penalty = calculateWithdrawFee(from);
        uint256 amount = deposits[from].depositAmount;
        uint256 amountAfterPenalty = amount - penalty;

        stakedBalance = stakedBalance - amount;
        rewardBalance = rewardBalance - reward;

        deposits[from].paid = true;
        hasStaked[from] = false;
        totalParticipants -= 1;

        // send user his deposit
        tokenAddress.safeTransfer(from, amountAfterPenalty + reward);
        if (penalty > 0) {
            // send any penalty to treasury wallet
            tokenAddress.safeTransfer(treasury, penalty);
        }

        emit PaidOut(address(tokenAddress), from, amountAfterPenalty, reward);
    }

    /**
     * @notice in case contract runs out of rewards and user is impatient
     */
    function emergencyWithdraw() external withdrawCheck(msg.sender) {
        _withdraw(msg.sender, 0);
    }

    /**
     * @param user User wallet address
     * @return totalRewards Rewards from staking if user waits for maturity/end date
     * @return currentRewards Rewards from staking if user decide to withdraw right now
     */
    function calculateRewards(address user)
        external
        view
        returns (uint256 totalRewards, uint256 currentRewards)
    {
        totalRewards = _calculate(user, deposits[user].endTime);
        currentRewards = _calculate(
            user,
            Math.min(block.timestamp, deposits[user].endTime)
        );
    }

    function _calculate(address from, uint256 endTime)
        private
        view
        returns (uint256 interest)
    {
        if (!hasStaked[from]) return 0;

        Deposit memory deposit = deposits[from];

        uint256 time = endTime - deposit.depositTime;

        interest =
            (deposit.depositAmount * deposit.rate * time) /
            (YEAR_IN_SECONDS * INTEREST_RATE_CONVERTER);

        return interest;
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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