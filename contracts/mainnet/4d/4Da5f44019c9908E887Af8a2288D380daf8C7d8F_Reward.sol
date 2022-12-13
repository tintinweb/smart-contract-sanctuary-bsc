/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.10;

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
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.10;

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.10;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: contracts/Reward.sol


pragma solidity ^0.8.10;



contract Reward is ReentrancyGuard{
    struct Pool{
        uint256 poolId;
        address owner;
        IERC20Metadata  depositToken;
        IERC20Metadata  rewardToken;
        uint8   depositTokenDecimal;
        uint256 supply;
        uint256 depositAmount;
        uint256 startBlock;
        uint256 endBlock;
        uint256 rewardShare;
        uint256 rewardPerBlock;
        uint256 lastUpdateBlock;
    }
    
    struct User{
        address user;
        IERC20Metadata  token;
        uint256 amount;
        uint256 depositBlock;
    }

    uint256 public poolId;
    uint256 public fee = 3;
    address public feeAddress;
    mapping(uint256 => Pool) public pools;
    mapping(address => mapping(uint256 =>User)) public  users;

    constructor(uint256 feePercent,address feeDest){
        fee = feePercent;
        feeAddress =  feeDest;
    }

    function createPool(IERC20Metadata depositToken,IERC20Metadata rewardToken,uint256 supply,uint256 endBlock) external nonReentrant {
        require(endBlock > block.number,"end block must bigger than start block");
        poolId ++;

        uint256 balanceBefore = rewardToken.balanceOf(address(this));
        rewardToken.transferFrom(msg.sender,address(this), supply);
        uint256 balanceAfter = rewardToken.balanceOf(address(this));
        if(balanceAfter-balanceBefore < supply){
            supply = balanceAfter - balanceBefore;
        }

        pools[poolId].poolId = poolId;
        pools[poolId].owner = msg.sender;
        pools[poolId].depositToken = depositToken;
        pools[poolId].rewardToken = rewardToken;
        pools[poolId].depositTokenDecimal = depositToken.decimals();
        pools[poolId].supply = supply;
        pools[poolId].startBlock = block.number;
        pools[poolId].lastUpdateBlock = block.number;
        pools[poolId].endBlock = endBlock;
        pools[poolId].rewardPerBlock = supply/(endBlock-block.number);

    }

    function deposit(uint256 depositPoolId,IERC20Metadata token, uint256 amount) external nonReentrant {
        Pool memory pool =  pools[depositPoolId];
        require(pool.endBlock >= block.number  && pool.startBlock <= block.number,"pool not exist or already end");
        require(address(pool.depositToken) == address(token),"not support token");
        
        uint256 balanceBefore = token.balanceOf(address(this));
        token.transferFrom(msg.sender,address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));

        if(balanceAfter-balanceBefore < amount){
            amount = balanceAfter - balanceBefore;
        }

        pools[depositPoolId].depositAmount += amount;

        claimRewards(depositPoolId);

        User memory user = users[msg.sender][depositPoolId];
        user.token = token;
        user.amount += amount;
        user.user = msg.sender;
        user.depositBlock = block.number;
        users[msg.sender][depositPoolId]  = user;
    }

    function claimRewards(uint256 claimPoolId) public{
        updateReward(claimPoolId);
        uint256 reward = rewards(claimPoolId,msg.sender);
        if (reward == 0){
            return;
        }

        uint256 endBlock = block.number;
        Pool memory pool = pools[claimPoolId];
        if (endBlock > pool.endBlock){
            endBlock = pool.endBlock;
        }
        users[msg.sender][claimPoolId].depositBlock = endBlock;

        IERC20Metadata token = pool.rewardToken;
        
        uint256 userReward = reward*(100-fee)/100;
        uint256 rewardFee = reward - userReward;
        if (userReward > 0 ){
            token.transfer(msg.sender, userReward);
        }
        if (rewardFee > 0){
            token.transfer(feeAddress, rewardFee);
        }
    }

    function withdraw(uint256 withdrawPoolId,bool isEmergecy) internal{
        claimRewards(withdrawPoolId);
        Pool memory pool = pools[withdrawPoolId];
        IERC20Metadata token = pool.depositToken;
        uint256 balance = users[msg.sender][withdrawPoolId].amount;
        if (balance == 0 || pool.depositAmount < balance){
            return;
        }

        pools[withdrawPoolId].depositAmount -= balance;
        
        if (!isEmergecy){
            users[msg.sender][withdrawPoolId].amount = 0;
            token.transfer(msg.sender,balance);
            return;
        }

        uint256 userBalance = (100-fee)*balance/100;
        uint256 feeBalance = balance - userBalance;
        users[msg.sender][withdrawPoolId].amount = 0;
        if (userBalance > 0 ){
            token.transfer(msg.sender,userBalance);
        }
        if (feeBalance > 0){
            token.transfer(feeAddress,feeBalance);
        } 
    }

    function rewards(uint256 pid,address sender) public view returns (uint256 userReward){
        Pool memory pool = pools[pid];

        if (pool.endBlock == 0 || pool.depositAmount == 0){
            return 0;
        }

        uint256 endBlock = block.number;
        if (endBlock > pool.endBlock){
            endBlock = pool.endBlock;
        }

        uint256 blockDelta  = endBlock - pool.lastUpdateBlock;
        uint256 rewardShare = pool.rewardShare + blockDelta*pool.rewardPerBlock*(10**pool.depositTokenDecimal)/pool.depositAmount;
        
        User memory user = users[sender][pid];
        userReward = user.amount*(endBlock-user.depositBlock)*rewardShare /(endBlock - pool.startBlock)/(10**pool.depositTokenDecimal);
    }

    function updateReward(uint256 pid) internal{
        Pool memory pool = pools[pid];

        if (block.number <= pool.lastUpdateBlock || pool.lastUpdateBlock == 0 || pool.depositAmount == 0){
            return;
        }

        uint256 endBlock = block.number;
        if (endBlock > pool.endBlock){
            endBlock = pool.endBlock;
        }

        uint256 blockDelta  = endBlock - pool.lastUpdateBlock;
        pool.rewardShare += blockDelta*pool.rewardPerBlock*(10**pool.depositTokenDecimal)/pool.depositAmount;
        pool.lastUpdateBlock = endBlock;

        pools[pid] = pool;
    }

    function  withdrawAll(uint256 withdrawPoolId) external nonReentrant {
        Pool memory pool = pools[withdrawPoolId];
        require(block.number > pool.endBlock && pool.endBlock > 0,"pool not end yet");
        withdraw(withdrawPoolId,false);
    }

    function emergencyWithdrawAll(uint256 withdrawPoolId) external nonReentrant {
        Pool memory pool = pools[withdrawPoolId];
        require(block.number > pool.startBlock && pool.startBlock > 0,"pool not start yet");
        withdraw(withdrawPoolId,true);
    }

}