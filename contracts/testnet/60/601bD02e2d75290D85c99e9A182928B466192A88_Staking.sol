// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard {
    
    address immutable token;
       
    struct pool {
        uint duration;
        uint apr; //in units of 100 i.e., 1% will be 100
        uint claimable;
        uint totalStake;
        uint rewardFunds;
        bool active;
    }

    mapping (uint => pool) pools;
    uint[] poolIds;
 
    struct record {
        uint investment;
        uint apr; //in units of 100 i.e., 1% will be 100
        uint reward;
        uint time;
    }

    mapping (address => mapping (uint => mapping (uint => record))) records;
   
    mapping (address => mapping (uint => uint)) instances;

    event Stake(address to, uint poolId, uint amount, uint _time);
    event Claim(address to, uint poolId, uint instanceId, uint amount);
    
    constructor(address _token) {
        require(_token != address(0), "zero address");
        token = _token;
    }
 
    modifier validPool(uint poolId) {
        require(pools[poolId].apr > 0, "invalid pool id");
        _;
    }

    modifier activePool(uint poolId) {
        require(pools[poolId].active, "pool is inactive");
        _;
    }
 
    function addPool(uint poolId, uint duration, uint apr) external onlyOwner {
        require(pools[poolId].apr == 0, "pool already exists");
        if (poolId  == 0)
            require(duration == 0, "duration of unlock pool should be 0");
        else
        {
            require(duration != 0, "duration of locked pool should be non zero");
        }
        pools[poolId] = pool(duration, apr, 0, 0, 0, true);
        poolIds.push(poolId);
    }

    function updatePoolApr(uint poolId, uint apr) external validPool(poolId) onlyOwner { 
        require(apr > 0, "apr must be non zero");
        pools[poolId].apr = apr;
    }

    function updatePoolStatus(uint poolId, bool status) external validPool(poolId) onlyOwner {
        pools[poolId].active = status;
    }

    function fundPool(uint poolId, uint rewardFunds) external validPool(poolId) onlyOwner {
        pools[poolId].rewardFunds += rewardFunds;
        require(IERC20(token).transferFrom(msg.sender, address(this), rewardFunds), "adding funds failed");
    }
    
    function stake(address to, uint poolId, uint amount) external validPool(poolId) activePool(poolId) {
        require(msg.sender == to,"only tx sender can stake");
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "token transfer failed");
        uint instanceId = getNewInstanceId(to, poolId);
        uint reward = 0;
        if (poolId == 0)
            amount += calculateReward(to, poolId, 1);
         else {
            reward = (amount * pools[poolId].apr) / 10000;
            pools[poolId].claimable +=  reward;
        }
        pools[poolId].totalStake += amount;
        records[to][poolId][instanceId] = record(amount, pools[poolId].apr, reward, block.timestamp);
        instances[to][poolId] = instanceId;
        emit Stake(to, poolId, amount, block.timestamp);
    }
    
    function claim(address to, uint poolId, uint instanceId) external validPool(poolId) {
        require(msg.sender == to,"only tx sender can claim");
        require(records[to][poolId][instanceId].investment > 0, "no record");
        require(block.timestamp - records[to][poolId][instanceId].time > pools[poolId].duration, "time remaining");
        uint reward;
        if (poolId == 0)
            reward = calculateReward(to, poolId, instanceId);
        else {
            reward = records[to][poolId][instanceId].reward;
            pools[poolId].claimable -= reward;
        }
        assert(reward <= pools[poolId].rewardFunds);
        pools[poolId].totalStake -= records[to][poolId][instanceId].investment;
        pools[poolId].rewardFunds -= reward;
        delete records[to][poolId][instanceId];
        emit Claim(to, poolId, instanceId, reward);
        require(IERC20(token).transfer(to, reward), "token transfer failed");
    }
 
    function getPool(uint poolId) public view validPool(poolId) returns (uint, uint, uint, uint,uint) {
        return(pools[poolId].duration, pools[poolId].apr, pools[poolId].claimable, pools[poolId].totalStake, pools[poolId].rewardFunds);
    }

    function getPoolNew(uint poolId) public view validPool(poolId) returns (pool memory) {
        return pools[poolId];
    }
 
    function getPoolIds() public view returns (uint[] memory) {
        return poolIds;
    }

    function getTotalInstances(address to, uint poolId) public view returns (uint) {
        return instances[to][poolId];
    }
 
    function getUserPool(address to, uint poolId, uint instanceId) public view validPool(poolId) returns (uint, uint, uint) {
        require(records[to][poolId][instanceId].investment > 0, "zero stake");
        return(records[to][poolId][instanceId].investment, records[to][poolId][instanceId].reward, records[to][poolId][instanceId].time);
    }
 
    function totalStakeOfUser(address to, uint poolId) public view returns(uint) {
        uint _instances = getTotalInstances(to, poolId);
        uint totalStake;
        for(uint i = 1; i <= _instances; i++) {
            totalStake += records[to][poolId][i].investment;
        }
        return totalStake;
    }

    function totalRewardOfUser(address to, uint poolId) public view returns(uint) {
        uint _instances = getTotalInstances(to, poolId);
        uint totalReward;
        if (poolId == 0)
            totalReward = calculateReward(to, poolId, 1);
        else {
            for (uint i = 1; i <= _instances; i++) {
                totalReward += records[to][poolId][i].reward;
            }
        }
        return totalReward;
    }
    
    function getNewInstanceId(address to, uint poolId) internal view returns (uint) {
         if (poolId == 0)
           return 1;
        else
           return instances[to][poolId] + 1;
    }

    function calculateReward(address to, uint poolId, uint instanceId) internal view returns(uint256) {
        uint duration = block.timestamp - records[to][0][1].time;
        uint reward = (records[to][poolId][instanceId].investment * duration * records[to][poolId][instanceId].apr) / (1 days * 10000);
        return reward;
    }

    function widthdrawEth(address to) external nonReentrant onlyOwner {
        require(to != address(0), "zero address");
        (bool sent,) = to.call{value: address(this).balance}("");
        require(sent, "Failed to manage Ether");

    }

    function widthdrawTokens(address to, address tokenAddress, uint amount)external nonReentrant onlyOwner{
        require(IERC20(tokenAddress).transfer(to, amount), "token transfer failed");
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";

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
pragma solidity ^0.8.0;
interface IERC20 {
   function transferFrom(
       address from,
       address to,
       uint256 amount
   ) external returns (bool);
   function transfer(address to, uint256 amount) external returns (bool);
   function balanceOf(
       address account
   ) external returns(uint256);
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