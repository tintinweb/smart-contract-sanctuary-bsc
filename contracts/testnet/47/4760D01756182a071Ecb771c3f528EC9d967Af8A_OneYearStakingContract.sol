/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)




// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)



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


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)



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


contract OneYearStakingContract is Ownable, ReentrancyGuard {

    struct Struct {
        uint timestamp;
        uint rewardPerBlock;
    }

    Struct[] public rewardPerBlockHistory;

    mapping(address => uint[]) private ownerStakeIds;

    mapping(uint => address) public stakingUser;
    mapping(uint => uint) public stakingAmount;
    mapping(uint => uint) public stakingEndDate;
    mapping(uint => uint) public stakingLastClaim;

    uint public stakesCount;
    uint public totalSupply;
    uint public totalStaked;
    bool public stakingAllowed;
    uint public lastUpdatePoolSizePercent;
    uint public maxApr;
    uint public percentAutoUpdatePool;

    uint public constant MAX_SUPPLY = 80 * 1e6 * 1e18;
    uint public constant MINIMUM_AMOUNT = 1 * 1e18;
    uint public constant REWARD_PER_BLOCK = 0.000008 * 1e18;
    uint public constant SECONDS_IN_YEAR = 31536000;
    uint public constant MIN_APR = 25;


    mapping(address => bool) private stakerAddressList;


    // address public constant STAKING_TOKEN_ADDRESS = 0x1d0Ac23F03870f768ca005c84cBb6FB82aa884fD; // galeon address
    address public constant STAKING_TOKEN_ADDRESS = 0xDecB06cCa15031927Adb8B2e8773145646CFB564; // galeon address

    IERC20 private constant STAKING_TOKEN = IERC20(STAKING_TOKEN_ADDRESS);

    constructor() {
        totalSupply = 0;
        lastUpdatePoolSizePercent = 0;
        stakingAllowed = true;
        maxApr = 500; // 500%
        stakesCount = 0;
        percentAutoUpdatePool = 5;
    }

    event Stacked(uint _amount,uint _totalSupply);
    event Unstaked(uint _amount);
    event Claimed(uint _claimed);
    event StakingAllowed(bool _allow);
    event RewardPerBlockUpdatedTimestamp(uint _lastupdate);
    event AdjustMaxApr(uint _maxApr);
    event AdjustpercentAutoUpdatePool(uint _percentAutoUpdatePool);
    event UpdatedStaker(address _staker, bool _allowed);

    function addStakerAddress(address _addr) public onlyOwner {
        stakerAddressList[_addr] = true;
        emit UpdatedStaker(_addr, true);
    }

    function delStakerAddress(address _addr) public onlyOwner {
        stakerAddressList[_addr] = false;
        emit UpdatedStaker(_addr, false);
    }
    
    function isStakerAddress(address check) public view returns(bool isIndeed) {
        return stakerAddressList[check];
    }

    function adjustMaxApr(uint _maxApr) external onlyOwner {
        maxApr = _maxApr;
        emit AdjustMaxApr(maxApr);
    }

    function adjustpercentAutoUpdatePool(uint _percentAutoUpdatePool) external onlyOwner {
        percentAutoUpdatePool = _percentAutoUpdatePool;
        emit AdjustMaxApr(percentAutoUpdatePool);
    }

    function updateRewardPerBlock() external onlyOwner {
        _updateRewardPerBlock();
        lastUpdatePoolSizePercent = totalSupply * 100 / MAX_SUPPLY;
    }

    function allowStaking(bool _allow) external onlyOwner {
        stakingAllowed = _allow;
        emit StakingAllowed(_allow);
    }

    function stake(uint _amount) external {
        _stake(_amount,msg.sender);
    }

    function stakForSomeoneElse(uint _amount,address _user) external {
        require(isStakerAddress(msg.sender), "stakers allowed only");
        _stake(_amount,_user);
    }
    function recompound() external nonReentrant {
        uint toClaim = claimableRewards(msg.sender);
        require(toClaim >= MINIMUM_AMOUNT,"Insuficient amount");
        _stake(toClaim,msg.sender);
        _updateLastClaim();
    }

    function claim() external nonReentrant {
        uint toClaim = claimableRewards(msg.sender);
        require(STAKING_TOKEN.balanceOf(address(this)) > toClaim + totalStaked, "Insuficient contract balance");
        require(STAKING_TOKEN.transfer(msg.sender,toClaim), "Transfer failed");
        _updateLastClaim();
        emit Claimed(toClaim);
    }

    function unstake() external nonReentrant returns(uint) {
        uint toUnstake = 0;
        uint i = 0;
        uint stakeId;
        uint toClaim = claimableRewards(msg.sender);
        while(i < ownerStakeIds[msg.sender].length) {
            stakeId = ownerStakeIds[msg.sender][i];
            if (stakingEndDate[stakeId] < block.timestamp) {
                toUnstake += stakingAmount[stakeId];
                totalStaked -= stakingAmount[stakeId];
                stakingAmount[stakeId] = 0;
                ownerStakeIds[msg.sender][i] = ownerStakeIds[msg.sender][ownerStakeIds[msg.sender].length -1];
                ownerStakeIds[msg.sender].pop();
            } else {
                i++;
            }
        }
        require(toUnstake > 0, "Nothing to unstake"); 
        require(STAKING_TOKEN.balanceOf(address(this)) > toUnstake + toClaim, "Insuficient contract balance");
        require(STAKING_TOKEN.transfer(msg.sender,toUnstake + toClaim), "Transfer failed");
        totalStaked -= toUnstake; 
        _updateLastClaim();
        emit Unstaked(toUnstake);
        emit Claimed(toClaim);
        return toUnstake + toClaim;
    }

    function getUserStakesIds(address _user) external view returns (uint[] memory) {
        return ownerStakeIds[_user];
    }

    function claimableRewards(address _user) public view returns (uint) {
        uint reward = 0;
        uint stakeId;
        for(uint i = 0; i < ownerStakeIds[_user].length; i++) {
            stakeId = ownerStakeIds[_user][i];
            uint lastClaim = stakingLastClaim[stakeId];
            uint j;
            for(j = 0; j < rewardPerBlockHistory.length; j++) {
                if (rewardPerBlockHistory[j].timestamp > lastClaim) {
                    reward += stakingAmount[stakeId] * (rewardPerBlockHistory[j].timestamp - lastClaim) * rewardPerBlockHistory[j].rewardPerBlock;
                    lastClaim = rewardPerBlockHistory[j].timestamp;
                }
            }
            reward += stakingAmount[stakeId] * (lastClaim - block.timestamp) * rewardPerBlockHistory[j].rewardPerBlock;
        }
        return (reward);
    }

    function _updateLastClaim() internal {
        for(uint i = 0; i < ownerStakeIds[msg.sender].length; i++) {
            stakingLastClaim[ownerStakeIds[msg.sender][i]] = block.timestamp;
        }
    }

    function _stake(uint _amount, address _user) internal nonReentrant {
        require(stakingAllowed, "Staking is not enabled");
        require(_amount >= MINIMUM_AMOUNT, "Insuficient amount");
        require(totalSupply + _amount <= MAX_SUPPLY, "Pool capacity exceeded");
        require(_amount <= STAKING_TOKEN.balanceOf(msg.sender), "Insuficient balance");
        require(STAKING_TOKEN.transferFrom(msg.sender, address(this), _amount), "TransferFrom failed");
        require(ownerStakeIds[_user].length < 100, "User staking limit exceeded");
        stakingUser[stakesCount] = _user;
        stakingEndDate[stakesCount] = block.timestamp + 30 minutes;
        stakingLastClaim[stakesCount] = block.timestamp;
        ownerStakeIds[_user].push(stakesCount);
        totalSupply += _amount;
        totalStaked += _amount;
        stakesCount += 1;
        uint poolSizePercent = totalSupply * 100 / MAX_SUPPLY;
        if (poolSizePercent > lastUpdatePoolSizePercent + percentAutoUpdatePool) {
            _updateRewardPerBlock();
            lastUpdatePoolSizePercent = poolSizePercent;
        }
        emit Stacked(_amount,totalSupply);
    }

    function _updateRewardPerBlock() internal {
        uint maxRewardPerBlock = totalSupply * maxApr / SECONDS_IN_YEAR / 100 * 1e18;
        uint minRewardPerBlock = totalSupply * MIN_APR / SECONDS_IN_YEAR / 100 * 1e18;
        uint rewardPerBlock;
        if (REWARD_PER_BLOCK < minRewardPerBlock) {
            rewardPerBlock = minRewardPerBlock / totalSupply;
        } else if (REWARD_PER_BLOCK > maxRewardPerBlock) {
            rewardPerBlock = maxRewardPerBlock / totalSupply;
        } else {
            rewardPerBlock = REWARD_PER_BLOCK / totalSupply;
        }
        rewardPerBlockHistory.push(Struct(block.timestamp,rewardPerBlock));
        emit RewardPerBlockUpdatedTimestamp(block.timestamp);
    }}