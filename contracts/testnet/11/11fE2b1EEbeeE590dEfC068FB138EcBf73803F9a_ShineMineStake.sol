/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: contracts/ShineMine.sol


pragma solidity ^0.8.10;




contract ShineMineStake is Ownable, ReentrancyGuard {

    //main user data struct
    struct userStakeData {
        uint256 silverTime;
        uint256 silverAmount;
        uint256 goldTime;
        uint256 goldAmount;
        uint256 diamondTime;
        uint256 diamondAmount;
    }

    mapping(address => userStakeData) public userStake;
    mapping(address => mapping(uint256 => uint256)) public userPointsEpoch;
    mapping(address => uint256) public lastChangeTime; //this tracks the last time change for a user
    mapping(address => uint256) public epochClaimIndex; //this keeps track of the last epoch claimed by a user
    mapping(uint256 => uint256) public epochStartTime;   //this tracks the starting time of each epoch
    mapping(uint256 => uint256) public rewardsPerPointEpoch; //this keeps tally of the expected rewards per point for each epoch
    mapping(uint256 => uint256) private epochPoints; //totals the points for each epoch
    mapping(address => uint256) public totalClaimedRewardsUser; //tracks the historical claimed rewards for each user
    
    uint256 public totalSilverStaked;
    uint256 public totalGoldStaked;
    uint256 public totalDiamondStaked;

    uint256 public lastUpdateTime; //global last update for contract

    //tracking total users
    uint256 public totalSilverStakers;
    uint256 public totalGoldStakers;
    uint256 public totalDiamondStakers;

    //silver stakers access 50% of rewards pool, gold 75%, and diamond 100%
    //staked tokens are tracked in 0.001 units. Staking less that 0.001 of the token may lead to underflow. 
    uint256 public silverReward = 2;
    uint256 public goldReward = 3;
    uint256 public diamondReward = 4;
    uint256 private rewardDenominator = 10000000000000000;

    uint256 public epoch = 0;

    uint256 public silverMinTime = 14 days;
    uint256 public goldMinTime = 90 days;
    uint256 public diamondMinTime = 180 days;

    string DIAMOND = "DIAMOND";
    string GOLD = "GOLD";
    string SILVER = "SILVER";

    IERC20 public Shine; 

/* 

    ~~~~~~~ MODIFIERS ~~~~~~~

*/

   modifier canUnstake (string calldata pool) {
        if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(DIAMOND))) {
            require(userStake[msg.sender].diamondTime + diamondMinTime < block.timestamp, "Diamond Pool time requirement not met.");
            _;
        }

        if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(GOLD))) {
            require(userStake[msg.sender].goldTime + goldMinTime < block.timestamp, "Gold Pool time requirement not met.");
            _;
        }

        if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(SILVER))) {
            require(userStake[msg.sender].silverTime + silverMinTime < block.timestamp, "Silver Pool time requirement not met.");
            _;
        }
        
    }

    receive() external payable {}

/* 

    ~~~~~~~ PUBLIC WRITE FUNCTIONS ~~~~~~~

*/

    function claimRewards() public nonReentrant  {
        updatePoints(msg.sender);
        require(epochClaimIndex[msg.sender] < epoch, "You have already claimed your available rewards all past epochs.");
        uint256 claimableRewards;
        for(uint256 i = epochClaimIndex[msg.sender]; i < epoch; i++) {
            claimableRewards += (getUserPointsEpoch(msg.sender, i) * rewardsPerPointEpoch[i]);
        }
        epochClaimIndex[msg.sender] = epoch;
        totalClaimedRewardsUser[msg.sender] += claimableRewards;
        payable(msg.sender).transfer(claimableRewards);
    }

    function stake(string calldata pool, uint256 amount) public nonReentrant {
        updatePoints(msg.sender);
        Shine.transferFrom(msg.sender, address(this), amount);
        if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(SILVER))) {
            if (userStake[msg.sender].silverAmount == 0) {
                userStake[msg.sender].silverTime = block.timestamp;
            }
            userStake[msg.sender].silverAmount += amount;
            totalSilverStaked += amount;
            totalSilverStakers ++;
        }
        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(GOLD))) {
            if (userStake[msg.sender].goldAmount == 0) {
                userStake[msg.sender].goldTime = block.timestamp;
            }
            userStake[msg.sender].goldAmount += amount;
            totalGoldStaked += amount;
            totalGoldStakers ++;
        }
        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(DIAMOND))) {
            if (userStake[msg.sender].diamondAmount == 0) {
                userStake[msg.sender].diamondTime = block.timestamp;
            }
            userStake[msg.sender].diamondAmount += amount;
            totalDiamondStaked += amount;
            totalDiamondStakers ++;
        }
        else revert();
    }

    function unstake(string calldata pool, uint256 amount) public nonReentrant canUnstake(pool) { 
        updatePoints(msg.sender);
        if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(SILVER))) {
            userStake[msg.sender].silverAmount -= amount;
            totalSilverStaked -= amount;
            if (userStake[msg.sender].silverAmount == 0) {
                totalSilverStakers --;
            }
            Shine.transfer(msg.sender, amount);
        }
        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(GOLD))) {
            userStake[msg.sender].goldAmount -= amount;
            totalGoldStaked -= amount;
            if (userStake[msg.sender].goldAmount == 0) {
                totalGoldStakers --;
            }
            Shine.transfer(msg.sender, amount);
        }
        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(DIAMOND))) {
            userStake[msg.sender].diamondAmount -= amount;
            totalDiamondStaked -= amount;
            if (userStake[msg.sender].diamondAmount == 0) {
                totalDiamondStakers --;
            }
            Shine.transfer(msg.sender, amount);
        }
        else revert();
    }

/* 

    ~~~~~~~ VIEW FUNCTIONS ~~~~~~~

*/

    function getUserStakeData(address user) public view returns (userStakeData memory) { //RETURNS THE USERSTAKE STRUCTURE
        return userStake[user];
    }

    function getTotalStaked() public view returns (uint256) { //RETURNS THE TOTAL STAKED AMOUNT
        return totalDiamondStaked + totalGoldStaked + totalSilverStaked;
    }

    function getUnlockTime(address _user, string memory _pool) public view returns (uint256 ) {
        if (keccak256(abi.encodePacked(_pool)) == keccak256(abi.encodePacked(DIAMOND))) {
            return userStake[_user].diamondTime + diamondMinTime;
        }
        else if (keccak256(abi.encodePacked(_pool)) == keccak256(abi.encodePacked(GOLD))) {
            return userStake[_user].goldTime + goldMinTime;
        }
        else if (keccak256(abi.encodePacked(_pool)) == keccak256(abi.encodePacked(SILVER))) {
            return userStake[_user].silverTime + silverMinTime;
        }
        else return 0;
    }

    function getTotalRewardPointsEpoch(uint256 _epoch) public view returns (uint256) { //RETURNS THE TOTAL REWARD POINTS FOR A GIVEN EPOCH. VALUE SHOULD INCREASE UNTIL THE EPOCH ENDS.
        return epochPoints[_epoch] + getPendingRewardPointsEpoch(_epoch);
    }

    function getCurrentEpoch() public view returns (uint256) {
        return epoch;
    }

    function getUserPointsEpoch(address user, uint256 _epoch) public view returns (uint256) {
        if (epoch > _epoch) {
            if (lastChangeTime[user] > epochStartTime[_epoch+1]) return userPointsEpoch[user][_epoch]; 
            else return userPointsEpoch[user][_epoch] + getUserPendingPointsEpoch(user, _epoch);
        }
        else {
            return userPointsEpoch[user][_epoch] + getUserPendingPointsEpoch(user, _epoch);
        }
    }

    function getUserTotalRewards(address user) public view returns(uint256) {
        uint256 totalRewards = totalClaimedRewardsUser[user];
        for(uint256 i = epochClaimIndex[user]; i < epoch; i++) {
            totalRewards += (getUserPointsEpoch(user, i) * rewardsPerPointEpoch[i]);
        }
        return totalRewards;
    }

    function getPoolStakers(string calldata pool) public view returns(uint256) {
        if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(SILVER))) {
            return totalSilverStakers;
        }

        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(GOLD))) {
            return totalGoldStakers;
        }

        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(DIAMOND))) {
            return totalDiamondStakers;
        }
        
        else {
            return 0;
        }
    }

/* 

    ~~~~~~~ INTERNAL FUNCTIONS ~~~~~~~

*/

    function updateTotalRewardsPoints() internal { //THIS FUNCTION UPDATES THE TOTAL REWARD POINTS FOR THE CURRENT EPOCH. IT WILL BE CALLED DURING THE START NEW EPOCH FUNCTION
        epochPoints[epoch] += getPendingRewardPointsEpoch(epoch);
        lastUpdateTime = block.timestamp;
    }

    function updatePoints(address user) internal {
        updateTotalRewardsPoints();
        for (uint256 i = epochClaimIndex[user]; i <= epoch; i++) {
            userPointsEpoch[user][i] += getUserPendingPointsEpoch(user, i);
        }
        lastChangeTime[user] = block.timestamp;
    }
    
    function setEpochRewardPerPoint(uint256 reward) internal { 
        rewardsPerPointEpoch[epoch] = reward / epochPoints[epoch];
    }

    function getUserPendingPointsEpoch(address user, uint256 _epoch) internal view returns (uint256) {
        uint256 epochEndTime = epochStartTime[_epoch+1];
        if (lastChangeTime[user] >= epochEndTime && epochEndTime != 0) return 0; 
        else {
            uint256 start;
            uint256 end;
            if (lastChangeTime[user] > epochStartTime[_epoch]) {
                start = lastChangeTime[user];
            }
            else {
                start = epochStartTime[_epoch];                
            }
            if (block.timestamp < epochEndTime || epochEndTime == 0) {
                end = block.timestamp;
            }
            else {
                end = epochEndTime;
            }
            uint256 delta = end - start;
            return ((userStake[user].silverAmount/rewardDenominator) * delta * silverReward) + ((userStake[user].goldAmount/rewardDenominator) * delta * goldReward) + ((userStake[user].diamondAmount/rewardDenominator) * delta * diamondReward);
        }

    }

    function getPendingRewardPointsEpoch(uint256 _epoch) internal view returns (uint256) {
        if (epoch != _epoch) return 0;
        else {
            uint256 delta = block.timestamp - lastUpdateTime;
            return ((totalSilverStaked/rewardDenominator) * delta * silverReward) + ((totalGoldStaked/rewardDenominator) * delta * goldReward) + ((totalDiamondStaked/rewardDenominator) * delta * diamondReward); 
        }
    }

/* 

    ~~~~~~~ ADMIN FUNCTIONS ~~~~~~~

*/

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance);
        payable(msg.sender).transfer(amount);
    }

    function startNewEpoch(uint256 reward) public payable onlyOwner {
        require(msg.value == reward, "Must deposit the correct amount of BNB.");
        updateTotalRewardsPoints();
        setEpochRewardPerPoint(reward);
        epoch++;
        epochStartTime[epoch] = block.timestamp;
    }

    function setPoolUnlockPeriod(string calldata pool, uint256 _days) public onlyOwner {
        if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(SILVER))) {
            silverMinTime = _days * 1 days;
        }

        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(GOLD))) {
            goldMinTime = _days * 1 days;
        }

        else if (keccak256(abi.encodePacked(pool)) == keccak256(abi.encodePacked(DIAMOND))) {
            diamondMinTime = _days * 1 days;
        }

        else {
            revert();
        }
    }

    function setShine(address shine) public onlyOwner {
        Shine = IERC20(shine);
    }

}