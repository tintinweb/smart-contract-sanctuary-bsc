// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IHappyMonkey{
    function getNftLevel(uint256 tokenId) external view returns(uint256);
}

contract Staking is Ownable, ReentrancyGuard{

    mapping(uint256 => CycleInfo) cycleInfo; // calculate this at the end of each cycle
    mapping(uint256 => uint256) multiplierPerLevel;
    mapping(uint256 => StakeInfo) stakeInfo;
    mapping(address => UserStakes) userStakes;

    struct UserStakes {
        uint256 numberOfStakes;
        uint256[] idStaked;
    }

    struct CycleInfo {
        uint256 endTimestamp;
        uint256[5] rewards;
    }

    struct StakeInfo {
        uint256 cycle;
        uint256 stakeTimestamp;
        uint256 lastClaimTimestamp;
        uint256 rewardsClaimed;
        uint256 index;
        address staker;
    }

    bool public stakingEnabled;

    address public HAPPY_COIN;
    address public HAPPY_MONKEY;

    uint256 public MIN_HAPPY_BALANCE;
    uint256[5] public rewardsRatesPerSecond; // 0: common, 1: uncommon, 2: rare, 3: epic, 4: legendary

    uint256 public startTimestamp;
    uint256 public lastRatesUpdateTime;
    uint256 public currentCycle;

    event StakingEnabled(bool state);
    event Stake(address indexed staker, uint256 indexed tokenId, uint256 stakeTimestamp);
    event Unstake(address indexed staker, uint256 indexed tokenId, uint256 unstakeTimestamp);
    event RewardsRatesUpdated(uint256[5] newRates, uint256 time);
    event HappyCoinAddressUpdated(address newAddress);
    event HappyMonkeyAddressUpdated(address newAddress);
    event MinHappyBalanceUpdated(uint256 newBalance);
    event MultiplierPerLevelUpdated(uint256 level, uint256 newMultiplier);
    event RewardsClaimed(uint256 indexed tokenId, uint256 rewards);
    event AllRewardsClaimed(uint256 rewards);


    constructor(address _HAPPY_COIN, address _HAPPY_MONKEY) {
        HAPPY_COIN = _HAPPY_COIN;
        HAPPY_MONKEY = _HAPPY_MONKEY;
        MIN_HAPPY_BALANCE = 5_000_000 * 10**18;
        multiplierPerLevel[0] = 100;
        rewardsRatesPerSecond = [0.0578703703703704 * 10 ** 18 , 0.1157407407407410 * 10 ** 18, 0.1543171296296300 * 10 ** 18, 0.2314814814814810 * 10 ** 18, 0.5787037037037040 * 10 ** 18];
    }

    function _stake(address staker, uint256 tokenId) internal {
        IERC721(HAPPY_MONKEY).transferFrom(staker, address(this), tokenId);
        stakeInfo[tokenId] = StakeInfo(currentCycle, block.timestamp, 0, 0, userStakes[staker].numberOfStakes, staker);
        userStakes[staker].idStaked.push(tokenId);
        userStakes[staker].numberOfStakes++;
        emit Stake(staker, tokenId, block.timestamp);
    }

    function _unstake(address staker, uint256 tokenId) internal returns(uint256) {
        require(staker == stakeInfo[tokenId].staker, "Only the staker can unstake");
        uint256 pendingRewards = getPendingRewardsById(tokenId);
        uint256 lastIndex = userStakes[staker].numberOfStakes - 1;
        uint256 lastTokenId = userStakes[staker].idStaked[lastIndex];
        if (lastTokenId != tokenId) {
            uint256 indexToReplace = stakeInfo[tokenId].index;
            stakeInfo[lastTokenId].index = indexToReplace;
            userStakes[staker].idStaked[indexToReplace] = lastTokenId;
        }
        delete stakeInfo[tokenId];
        userStakes[staker].idStaked.pop();
        userStakes[staker].numberOfStakes--;
        IERC721(HAPPY_MONKEY).transferFrom(address(this), staker, tokenId);
        emit Unstake(staker, tokenId, block.timestamp);
        return pendingRewards;
    }

    function stake(uint256 tokenId) external nonReentrant{
        require(stakingEnabled, "Stake is not enabled");
        require(IERC20(HAPPY_COIN).balanceOf(msg.sender) >= MIN_HAPPY_BALANCE, "Not enough HAPPY!");
        _stake(msg.sender, tokenId);
    }

    function multiStake(uint256[] memory tokenIds) external nonReentrant{
        require(stakingEnabled, "Stake is not enabled");
        require(IERC20(HAPPY_COIN).balanceOf(msg.sender) >= MIN_HAPPY_BALANCE, "Not enough HAPPY!");
        uint256 size = tokenIds.length;
        uint256 i;
        for(i; i < size;){
            _stake(msg.sender, tokenIds[i]);
            unchecked {++i;}
        }
    }

    function unstake(uint256 tokenId) external nonReentrant{
        require(stakingEnabled, "Stake is not enabled"); 
        require(IERC20(HAPPY_COIN).balanceOf(msg.sender) >= MIN_HAPPY_BALANCE, "Not enough HAPPY!");
        uint256 pendingRewards = _unstake(msg.sender, tokenId);
        if(pendingRewards > 0) IERC20(HAPPY_COIN).transfer(msg.sender, pendingRewards);
    }

    function multiUnstake(uint256[] memory tokenIds) external nonReentrant{
        require(stakingEnabled, "Stake is not enabled");
        require(IERC20(HAPPY_COIN).balanceOf(msg.sender) >= MIN_HAPPY_BALANCE, "Not enough HAPPY!");
        uint256 size = tokenIds.length;
        uint256 pendingRewards;
        uint256 i;
        for(i; i < size;){
            pendingRewards = _unstake(msg.sender, tokenIds[i]);
            unchecked {++i;}
        }
        if(pendingRewards > 0) IERC20(HAPPY_COIN).transfer(msg.sender, pendingRewards);
    }

    function _manageClaim(uint256 tokenId) internal returns(uint256){
        uint256 pendingRewards = getPendingRewardsById(tokenId);
        if(pendingRewards == 0) return 0;
        stakeInfo[tokenId].lastClaimTimestamp = block.timestamp;
        stakeInfo[tokenId].rewardsClaimed += pendingRewards;
        return pendingRewards;
    }

    function claimById(uint256 tokenId) external nonReentrant{
        require(stakeInfo[tokenId].staker == msg.sender, "You can only claim your own stakes");
        uint256 pendingRewards = _manageClaim(tokenId);
        require(pendingRewards > 0, "No pending rewards");
        IERC20(HAPPY_COIN).transfer(msg.sender, pendingRewards);
        emit RewardsClaimed(tokenId, pendingRewards);
    }

    function claimAll() external nonReentrant{
        require(userStakes[msg.sender].numberOfStakes > 0, "No stakes to claim");
        uint256 size = userStakes[msg.sender].numberOfStakes;
        uint256 i;
        uint256 pendingRewards;
        for (i; i < size; ){
            pendingRewards += _manageClaim(userStakes[msg.sender].idStaked[i]);
            unchecked {++i;}
        }
        require(pendingRewards > 0, "No pending rewards");
        IERC20(HAPPY_COIN).transfer(msg.sender, pendingRewards);
        emit AllRewardsClaimed(pendingRewards);
    }

    function getRewardsRatesPerRarity(uint256 tokenId) public view returns (uint256) {
        if(tokenId < 5001) return rewardsRatesPerSecond[0];
        else if(tokenId < 8001) return rewardsRatesPerSecond[1];
        else if(tokenId < 9301) return rewardsRatesPerSecond[2];
        else if(tokenId < 9981) return rewardsRatesPerSecond[3];
        else return rewardsRatesPerSecond[4];
    }

    function getRewardsRateIndex(uint256 tokenId) public pure returns (uint256){
        if(tokenId < 5001) return 0;
        else if(tokenId < 8001) return 1;
        else if(tokenId < 9301) return 2;
        else if(tokenId < 9981) return 3;
        else return 4;
    }

    function getPendingRewardsById(uint256 tokenId) public view returns (uint256){
        uint256 stakeTimestamp = stakeInfo[tokenId].stakeTimestamp;
        if(stakeTimestamp == 0) return 0;
        uint256 current_time = block.timestamp;
        uint256 current_rewardsRate = getRewardsRatesPerRarity(tokenId);
        uint256 rewards;

        if(currentCycle == 0) {
            rewards = current_rewardsRate * (current_time - stakeTimestamp) - stakeInfo[tokenId].rewardsClaimed;
            return rewards * multiplierPerLevel[IHappyMonkey(HAPPY_MONKEY).getNftLevel(tokenId)] / 100;
        }

        uint256 rewardsRateIndex = getRewardsRateIndex(tokenId);
        uint256 firstCycle = stakeInfo[tokenId].cycle;

        if(currentCycle > firstCycle){
            //calculate rewards for the previous cycles
            uint256 prevRewards = cycleInfo[currentCycle - 1].rewards[rewardsRateIndex] - cycleInfo[firstCycle].rewards[rewardsRateIndex];

            uint256 firstCycleTotDuration = cycleInfo[firstCycle].endTimestamp - (firstCycle > 0 ? cycleInfo[firstCycle - 1].endTimestamp : startTimestamp);

            // endTimestamp - stakeTimestamp = firstCycle stake duration
            // firstCycleRewards = totRewards in that cycle * firstCycle stake duration / firstCycle total duration
            uint256 firstCycleRewards = cycleInfo[firstCycle].rewards[rewardsRateIndex] * (cycleInfo[firstCycle].endTimestamp - stakeTimestamp) / firstCycleTotDuration;
            rewards += prevRewards + firstCycleRewards;
        }
        // calculate rewards for the current cycle
        rewards += current_rewardsRate * (current_time - cycleInfo[currentCycle - 1].endTimestamp);
        rewards = rewards * multiplierPerLevel[IHappyMonkey(HAPPY_MONKEY).getNftLevel(tokenId)] / 100;
        return rewards - stakeInfo[tokenId].rewardsClaimed;
    }

    function setRewardsRates(uint256[5] memory _rewardsRatesPerSecond) external onlyOwner{
        uint256 timeElapsed = block.timestamp - lastRatesUpdateTime;
        uint256[5] memory tempRewards;
        uint256[5] memory lastCycleRewards = currentCycle > 0 ? cycleInfo[currentCycle - 1].rewards : cycleInfo[0].rewards; // we don't like underflow
        for(uint256 i; i < 5; i++){
            tempRewards[i] = (rewardsRatesPerSecond[i] * timeElapsed) + lastCycleRewards[i];
        }
        rewardsRatesPerSecond = _rewardsRatesPerSecond;
        lastRatesUpdateTime = block.timestamp;
        cycleInfo[currentCycle].rewards = tempRewards;
        cycleInfo[currentCycle].endTimestamp = block.timestamp;

        currentCycle++;
        emit RewardsRatesUpdated(rewardsRatesPerSecond, lastRatesUpdateTime);
    }

    function setDailyRewardsRates(uint256[5] memory _dailyRewardsRates) external onlyOwner{
        uint256 timeElapsed = block.timestamp - lastRatesUpdateTime;
        uint256[5] memory tempRewards;
        uint256[5] memory lastCycleRewards = currentCycle > 0 ? cycleInfo[currentCycle - 1].rewards : cycleInfo[0].rewards; // we don't like underflow
        for(uint256 i; i < 5; i++){
            tempRewards[i] = (rewardsRatesPerSecond[i] * timeElapsed) + lastCycleRewards[i];
        }
        for(uint256 i; i < 5; i++){
            rewardsRatesPerSecond[i] = _dailyRewardsRates[i] / 1 days;
        }
        lastRatesUpdateTime = block.timestamp;
        cycleInfo[currentCycle].rewards = tempRewards;
        cycleInfo[currentCycle].endTimestamp = block.timestamp;
        currentCycle++;
        emit RewardsRatesUpdated(rewardsRatesPerSecond, lastRatesUpdateTime);
    }


    function setStakingEnabled(bool _enabled) external onlyOwner {
        stakingEnabled = _enabled;
        if(startTimestamp == 0) startTimestamp = block.timestamp;
        if(lastRatesUpdateTime == 0) lastRatesUpdateTime = block.timestamp;
        emit StakingEnabled(_enabled);
    }

    function setMultiplierPerLevel(uint256 _level, uint256 _multiplierPerLevel) external onlyOwner {
        multiplierPerLevel[_level] = _multiplierPerLevel;
        emit MultiplierPerLevelUpdated(_level, _multiplierPerLevel);
    }

    function setHappyCoinAddress(address _HAPPY_COIN) external onlyOwner{
        HAPPY_COIN = _HAPPY_COIN;
        emit HappyCoinAddressUpdated(_HAPPY_COIN);
    }

    function setHappyMonkeyAddress(address _HAPPY_MONKEY) external onlyOwner{
        HAPPY_MONKEY = _HAPPY_MONKEY;
        emit HappyMonkeyAddressUpdated(_HAPPY_MONKEY);
    }

    function setMinHappyBalance(uint256 _MIN_HAPPY_BALANCE) external onlyOwner{
        MIN_HAPPY_BALANCE = _MIN_HAPPY_BALANCE;
        emit MinHappyBalanceUpdated(_MIN_HAPPY_BALANCE);
    }

    function emergencyWithClaim(uint256 tokenId) external onlyOwner{
        require(!stakingEnabled, "Staking must be disabled");
        address staker = stakeInfo[tokenId].staker;
        uint256 pendingRewards = getPendingRewardsById(tokenId);
        IERC721(HAPPY_MONKEY).transferFrom(address(this), staker, tokenId);
        if(pendingRewards > 0)IERC20(HAPPY_COIN).transfer(staker, pendingRewards);
    }

    function emergencyWithClaimInBulk(uint256[] memory tokenIds) external onlyOwner{
        require(!stakingEnabled, "Staking must be disabled");
        uint256 size = tokenIds.length;
        uint256 i;
        address staker;
        uint256 pendingRewards;
        for(i; i < size;){
            staker = stakeInfo[tokenIds[i]].staker;
            pendingRewards = getPendingRewardsById(tokenIds[i]);
            IERC721(HAPPY_MONKEY).transferFrom(address(this), staker, tokenIds[i]);
            if(pendingRewards > 0) IERC20(HAPPY_COIN).transfer(staker, pendingRewards);
            unchecked {++i;}
        }
    }

    function emergencyNoClaim(uint256 tokenId) external onlyOwner{
        require(!stakingEnabled, "Staking must be disabled");
        address staker = stakeInfo[tokenId].staker;
        IERC721(HAPPY_MONKEY).transferFrom(address(this), staker, tokenId);
    }

    function emergencyNoClaimInBulk(uint256[] memory tokenIds) external onlyOwner{
        require(!stakingEnabled, "Staking must be disabled");
        uint256 size = tokenIds.length;
        uint256 i;
        address staker;
        for(i; i < size;){
            staker = stakeInfo[tokenIds[i]].staker;
            IERC721(HAPPY_MONKEY).transferFrom(address(this), staker, tokenIds[i]);
            unchecked {++i;}
        }
    }

    function rescueBEP20(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function getUserStakes(address user) external view returns(uint256[] memory){
        return userStakes[user].idStaked;
    }

    function getUserStakeAtIndex(address user, uint256 index) external view returns(uint256){
        require(userStakes[user].numberOfStakes > index, "Index out of bounds");
        return userStakes[user].idStaked[index];
    }

    function getCycleInfo(uint256 cycleId) external view returns(CycleInfo memory){
        return cycleInfo[cycleId];
    }

    function getStakeInfo(uint256 tokenId) external view returns(StakeInfo memory){
        return stakeInfo[tokenId];
    }

    function getDailyRewardsRates() external view returns(uint256 common, uint256 uncommon, uint256 rare, uint256 epic, uint256 legendary){
        uint256 commonRate = rewardsRatesPerSecond[0] * 1 days;
        uint256 uncommonRate = rewardsRatesPerSecond[1] * 1 days;
        uint256 rareRate = rewardsRatesPerSecond[2] * 1 days;
        uint256 epicRate = rewardsRatesPerSecond[3] * 1 days;
        uint256 legendaryRate = rewardsRatesPerSecond[4] * 1 days;
        return (commonRate, uncommonRate, rareRate, epicRate, legendaryRate);
    }

    function getMultipliersPerLevel(uint256 _level) external view returns(uint256){
        return multiplierPerLevel[_level];
    }

    function getPendingRewardsByUser(address user) external view returns(uint256){
        require(userStakes[user].numberOfStakes > 0, "No pending rewards");
        uint256 i;
        uint256 size = userStakes[user].numberOfStakes;
        uint256[] memory stakedIds = userStakes[user].idStaked;
        uint256 pendingRewards;
        for(i; i < size; ){
            pendingRewards += getPendingRewardsById(stakedIds[i]);
            unchecked {++i;}
        }
        return pendingRewards;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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