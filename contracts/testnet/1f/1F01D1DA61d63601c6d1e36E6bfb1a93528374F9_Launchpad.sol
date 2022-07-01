// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IIGOStakingPool {
    function userInfo(address) external view returns(uint256,uint256,uint);
    function invest(address, uint256) external;
}


contract Launchpad is Ownable {
    //count of pool added to Launchpad
    uint256 private _poolCount = 0;

    IERC20 GovernanceToken;

    struct Pool {
        uint id;
        address owner;
        string poolInfoUrl;
        string logoUrl;

        ////////////// Pool information

        // uint64 bidStartTime;
        uint64 bidEndTime;
        
        bool accessType;

        //token
        address tokenAddress;
        uint tokenPrice;
        uint tokenPriceDecimals;
        uint tokenTotalSupply;
        uint totalRaised;
        uint claimed;
        bool issued;
        bool allowed;
        bool removed;

        //tier system
        uint[8] priceRangeEveryTier;
        uint[9] targetAmountEveryTier;
        uint[9] investedAmountEveryTier;
    }
    
    uint public fee = 1; // 1:1000000
    uint public constant stakingPoolCount = 5;
    address[stakingPoolCount] stakingPools;
    
    mapping(uint => Pool) _poolList;
    mapping(uint => mapping(address => uint)) _whiteList;
    mapping(uint => mapping(address => uint)) _claimedList;

    event Bid(uint poolId,uint amount, uint tierLevel);

    event Add(uint poolId, string poolInfoUrl, string logoUrl);

    event Modify(uint poolId, address tokenAddress, uint tokenPrice, uint tokenDecimals, uint256 tokenTotalSupply, /*uint64 bidStartTime, */uint64 bidEndTime, uint[8] tier);

    event IssueToken(uint poolId);

    event RemovePool(uint poolId);

    event Claim(uint poolId);

    event ClaimTickets(uint poolId);

    event AllowPool(uint poolId);

    constructor(address igotoken, address pool1, address pool2, address pool3, address pool4, address pool5) {

        GovernanceToken = IERC20(igotoken);
        stakingPools[0] = pool1;
        stakingPools[1] = pool2;
        stakingPools[2] = pool3;
        stakingPools[3] = pool4;
        stakingPools[4] = pool5;
    }

    /**
        modifiers
     */
    modifier onlyPoolOwner(uint poolId){
        require(msg.sender == _poolList[poolId].owner, "Only pool owner can modify pool information.");
        _;
    }

    modifier validPoolId(uint poolId) {
        require(poolId >= 0, "Invalid Pool Id");
        require(poolId < _poolCount, "Invalid Pool Id");
        _;
    }

    /**
    add new pool
     */
    function addPool(string memory poolInfoUrl, string memory logoUrl) external {
        Pool memory newPool;
        newPool.id = _poolCount;
        newPool.owner = msg.sender;
        newPool.poolInfoUrl = poolInfoUrl;
        newPool.logoUrl = logoUrl;
        newPool.removed = false;

        _poolList[_poolCount ++] = newPool;

        emit Add(_poolCount - 1, poolInfoUrl, logoUrl);
    }

    function issueToken(uint poolId) public onlyPoolOwner(poolId) validPoolId(poolId) {

        require(_poolList[poolId].allowed, "Pool is not allowed.");
        
        address tokenAddress = _poolList[poolId].tokenAddress;
        uint256 tokenTotalSupply = _poolList[poolId].tokenTotalSupply;
        
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= tokenTotalSupply, "Not enough tokens");
        
        IERC20(tokenAddress).transferFrom(address(msg.sender), address(this), tokenTotalSupply);
        
        _poolList[poolId].issued = true;

        emit IssueToken(poolId);
    }

    /**
        Modify pool
     */

    function  modifyPoolInfo(uint poolId, address tokenAddress, uint tokenPrice, uint tokenDecimals, uint256 tokenTotalSupply, /*uint64 bidStartTime, */uint64 bidEndTime, uint[8] memory tier) public onlyPoolOwner(poolId) validPoolId(poolId){

        require(!_poolList[poolId].issued, "Pool is already Started.");

        setTokenAddress(poolId, tokenAddress);
        setTokenPrice(poolId, tokenPrice, tokenDecimals);
        setTierSystem(poolId, tier);
        setTokenTotalSupply(poolId, tokenTotalSupply);
        setBidTime(poolId, /*bidStartTime,*/ bidEndTime);

        _poolList[poolId].issued = false;

        emit Modify(poolId, tokenAddress, tokenPrice, tokenDecimals, tokenTotalSupply, /*bidStartTime,*/ bidEndTime, tier);
    }

    function allowPool(uint poolId) public onlyOwner {
        _poolList[poolId].allowed = true;

        emit AllowPool(poolId);
    }

    function removePool(uint poolId) public onlyOwner {
        _poolList[poolId].removed = true;

        emit RemovePool(poolId);
    }
    
    function setTokenAddress(uint256 poolId, address tokenAddress) private onlyPoolOwner(poolId) validPoolId(poolId){

        _poolList[poolId].tokenAddress = tokenAddress;
    }
    function setTokenPrice(uint poolId, uint tokenPrice, uint tokenPriceDecimals) private onlyPoolOwner(poolId) validPoolId(poolId){
        _poolList[poolId].tokenPrice = tokenPrice;
        _poolList[poolId].tokenPriceDecimals = tokenPriceDecimals;
    }
    function setTokenTotalSupply(uint256 poolId, uint256 tokenTotalSupply) private onlyPoolOwner(poolId) validPoolId(poolId){
        _poolList[poolId].tokenTotalSupply = tokenTotalSupply;

        _poolList[poolId].targetAmountEveryTier[0] = tokenTotalSupply * 11 / 100;
        for (uint i = 1; i <= 8; i++) {
            _poolList[poolId].targetAmountEveryTier[i] = tokenTotalSupply * 10 / 100;
        }  
    }

    function setBidTime(uint256 poolId, /*uint64 bidStartTime,*/ uint64 bidEndTime) private onlyPoolOwner(poolId) validPoolId(poolId){
        require(bidEndTime > block.timestamp * 1000, "End time needs to be above current time");
        // _poolList[poolId].bidStartTime = bidStartTime;
        _poolList[poolId].bidEndTime = bidEndTime;
    }
    function setTierSystem(uint256 poolId, uint[8] memory tier) private onlyPoolOwner(poolId) validPoolId(poolId) {

        for (uint i = 0; i < 8; i++) {
            _poolList[poolId].priceRangeEveryTier[i] = tier[i];
        }        
    }
    
    function bid(uint poolId, uint amount) external validPoolId(poolId) {
        // require(_poolList[poolId].bidStartTime != 0, "Bid start time is not set.");
        require(_poolList[poolId].bidEndTime != 0, "Bid end time is not set.");
        // require(block.timestamp * 1000 >= _poolList[poolId].bidStartTime, "Bid is not started yet.");
        require(block.timestamp * 1000 <= _poolList[poolId].bidEndTime, "Bid is already closed");

        uint tierLevel = getTierLevel(poolId, msg.sender);
        
        uint256 newInvestAmount = amount * _poolList[poolId].tokenPrice;
        // check overflow amount in tier system
        require(_poolList[poolId].targetAmountEveryTier[tierLevel] >= (_poolList[poolId].investedAmountEveryTier[tierLevel] + newInvestAmount), "Invest amounts are full in this tier system");

        uint bidAmount = amount;

        // transfer staked IGO tokens to launchpad for bid
        uint8 i;
        for (i = 0; i < stakingPoolCount; i++) {
            (uint256 remainAmount, ,) = IIGOStakingPool(stakingPools[i]).userInfo(msg.sender);
            if (bidAmount > remainAmount) {
                IIGOStakingPool(stakingPools[i]).invest(msg.sender, remainAmount);
                bidAmount -= remainAmount;
            } else {
                IIGOStakingPool(stakingPools[i]).invest(msg.sender, bidAmount);
                break;
            }
        }
        
        _poolList[poolId].totalRaised += newInvestAmount;
        _whiteList[poolId][msg.sender] += amount;
        _poolList[poolId].investedAmountEveryTier[tierLevel] += newInvestAmount;
        
        emit Bid(poolId, amount, tierLevel);
    }

    /**
        Load pools
     */
    function loadPools() external view returns(Pool[] memory) {
        Pool[] memory pools = new Pool[](_poolCount);
        uint i;
        for(i = 0 ; i < _poolCount ; i ++) {
            pools[i] = _poolList[i];
        }
        return pools;
    }

    function loadPool(uint poolID) external view validPoolId(poolID) returns(Pool memory) {
        return _poolList[poolID];
    }

    /**
        Claim
     */

    function claim(uint poolId) public validPoolId(poolId) onlyPoolOwner(poolId) {

        require(msg.sender == _poolList[poolId].owner, "Only can be called by owner");

        uint remain = _poolList[poolId].totalRaised / _poolList[poolId].tokenPrice - _poolList[poolId].claimed;

        require(remain > 0, "Nothing to claim");

        require(GovernanceToken.balanceOf(address(this)) >= remain, "Not Enough IGO tokens in LaunchPad");

        uint claimAmount = remain - remain * fee / 10**6;
        GovernanceToken.transfer(owner(), remain * fee / 10**6);
        GovernanceToken.transfer(address(msg.sender), claimAmount);

        _poolList[poolId].claimed += remain;

        emit Claim(poolId);
    }

    function unclaimedTickets(address investor, uint poolId) external view validPoolId(poolId) returns(uint) {
        return (_whiteList[poolId][investor] - _claimedList[poolId][investor]) * _poolList[poolId].tokenPrice;
    }

    function claimTickets(uint poolId) public validPoolId(poolId) {
        require(_whiteList[poolId][msg.sender] > 0, "Not invester");

        uint remain = _whiteList[poolId][msg.sender] - _claimedList[poolId][msg.sender];

        require(remain > 0, "Nothing to claim");

        require(_poolList[poolId].issued == true, "Ticket Token is not issued");

        uint ticketBalance = IERC20(_poolList[poolId].tokenAddress).balanceOf(address(this));
        uint ticketRemain = remain * _poolList[poolId].tokenPrice;
        
        require(ticketRemain <= ticketBalance, "Not Enough Ticket Token");

        IERC20(_poolList[poolId].tokenAddress).transfer(address(msg.sender), ticketRemain);

        _claimedList[poolId][msg.sender] += remain;

        emit ClaimTickets(poolId);
    }

    function getStakingBalnce(address staker) public view returns(uint256){
        uint256 totalStakingBalance = 0;

        for (uint i = 0; i < stakingPoolCount; i++) {
            (uint256 amount,,) = IIGOStakingPool(stakingPools[i]).userInfo(staker);
            totalStakingBalance += amount;
        }

        return totalStakingBalance;
    }

    function getTierLevel(uint256 poolId, address user) public view returns(uint) {
        
        uint256 totalStakingBalance = getStakingBalnce(user);

        uint i = 0;

        for (i = 0; i < 2; i++) { // Tier system
            if (_poolList[poolId].priceRangeEveryTier[i] > totalStakingBalance) {
                break;
            }
        }

        return i+1;
    }

    function setPools(address pool1, address pool2, address pool3, address pool4, address pool5) public onlyOwner {
        stakingPools[0] = pool1;
        stakingPools[1] = pool2;
        stakingPools[2] = pool3;
        stakingPools[3] = pool4;
        stakingPools[4] = pool5;
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