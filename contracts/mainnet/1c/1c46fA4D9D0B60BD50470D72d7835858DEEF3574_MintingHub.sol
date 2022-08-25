// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error Hub__HubDurationNotReached();
error Hub__HubLimitExceeded();
error Hub__HubAlreadyPurchased();
error Hub__HubNotAvailable();
error Hub__MinimumHubFee();
error Hub__MaxPercentageWithdrawalReached();
error Hub__HubDurationNotReachedYearly();
error Hub__InsufficentHubBonusBalance();
error Hub__TransferFailed();
error Hub__InsufficientBalance();

contract MintingHub is ReentrancyGuard, Ownable
{
    
    
    IERC20 public s_stakingToken;
    IERC20 public s_busdToken;


    address[] private allowedTokens;
    address[] private allowedTokensHub;
    address private s_busdAddress;
    

    constructor(address stakingToken, address busd)
    {
        s_stakingToken = IERC20(stakingToken);
        s_busdToken = IERC20(busd);
        allowedTokens.push(stakingToken);
        allowedTokensHub.push(busd);
        s_busdAddress = busd;
       
    }

     struct Hub{
        uint256 totalBUSD;
        uint256 priceBUSD;
        uint256 lockedBUSD;
        uint256 lockedVase;
        uint256 lockedVaseBalance;
        uint256 percentageWid;
        uint256 status;
        string name;
    }

    Hub[] private s_allHubs;
    mapping(address=>Hub[]) private s_addressToHubs;
    

    mapping(address=>mapping(string=>Hub)) private s_addressToHub;
    mapping(address=>mapping(string=>uint256)) private s_hubDuration;
    mapping(address=>mapping(string=>uint256)) private s_hubDurationYearly;
    mapping(address=>uint256) private s_addressToLockedVASEHUB;
    mapping(address=>mapping(string=>uint256)) private s_addressToPercentWid;
    mapping(address=>string) private s_addressToHubName;
    mapping(address=>mapping(string=>uint256)) private s_addressToLockedBal;
    mapping(address=>mapping(string=>uint256)) private s_addressToWidBal;
    mapping(address=>uint256) private s_referralEarning;

    uint256 private s_hubPercentage = 20;
    uint256 private s_refBonus = 5;
    mapping(string => uint256) private s_hubCount;
    uint256 private s_totalBUSD;
    uint256 private s_totalSupply; 

    event HubBonusClaimed(address indexed user, uint256 indexed amount, uint256 indexed percentage);
    event BuyHub(address indexed user, uint256 indexed busdTotal, uint256 indexed busdPrice,
    uint256 busdLocked, uint256 lockedVase, string hubName);
    event HubLockedClaimed(address indexed user, uint256 indexed amount);
    event WithdrawOwner(uint256 indexed amount);


    enum Hubs {BRONZE, SILVER, GOLD, RUBY,DIAMOND}

    function buyHub(string memory hubName, uint256 totalVASE, address referrer) external 
    payable checkAllowedTokensHub(s_busdAddress) minimumHubFee(msg.value)
    updateWithdrawalDurationHub(hubName) updateWithdrawalDurationHubYearly(hubName)
    {

       if(s_hubCount[hubName] == 5000)
       {
         revert Hub__HubLimitExceeded();
       }
       Hub storage hub = s_addressToHub[msg.sender][hubName];
       if(hub.totalBUSD > 0)
       {
         revert Hub__HubAlreadyPurchased();
       }
       uint256 priceTempBusd = (40 * msg.value) / 100;
       uint256 lockedTempBusd = (60 * msg.value) / 100;
       uint256 lockedVASE = (60 * totalVASE * 1e18) / 100;
       


       hub.totalBUSD = msg.value;
       hub.priceBUSD = priceTempBusd;
       hub.lockedBUSD = lockedTempBusd;
       hub.lockedVase = lockedVASE;
       hub.lockedVaseBalance = lockedVASE;
       hub.status = 1;
       hub.name = hubName;

       if(referrer != address(0))
       {
          uint256 directBonus = uint256((s_refBonus * lockedVASE) /(100 * 1e18));
          s_referralEarning[referrer] += directBonus;

       }
       
       s_allHubs.push(hub);
       s_addressToHubs[msg.sender].push(hub);
       s_addressToLockedBal[msg.sender][hubName] = lockedVASE;
       s_addressToLockedVASEHUB[msg.sender] += lockedVASE;
       s_addressToHubName[msg.sender] = hubName;
       
       
       s_totalBUSD += msg.value;
       s_hubCount[hubName] += 1;

   

        emit BuyHub(msg.sender, msg.value, priceTempBusd, lockedTempBusd, lockedVASE, hub.name);
        bool success = s_busdToken.transferFrom(msg.sender, address(this), msg.value);
        if (!success)
        {
            revert Hub__TransferFailed();
        }

    }

    function getUserHubByName(string memory hubName) external view returns(uint256 totalBUSD, uint256 priceBUSD, uint256 lockedBUSD, 
    uint256 lockedVASE, uint256 lockedVASEBal, uint256 percentageWid, uint256 status, string memory name)
    {
        Hub storage hub = s_addressToHub[msg.sender][hubName];
        if(hub.totalBUSD > 0){
            return(
            hub.totalBUSD, hub.priceBUSD, hub.lockedBUSD, hub.lockedVase,
            hub.lockedVaseBalance, hub.percentageWid, hub.status, hub.name
          );
        }else{
            revert Hub__HubNotAvailable();
        }
        
    }

    function getUserHub() external view returns(Hub[] memory)
    {

        return s_addressToHubs[msg.sender];

    }

     function withdrawHubEarnings(string memory hubName) external nonReentrant
     {
        uint256 duration = s_hubDuration[msg.sender][hubName];
        uint256 ref;
        uint256 locked;
        if(block.timestamp < duration)
        {
            revert Hub__HubDurationNotReached();
        }
      
        Hub storage hub = s_addressToHub[msg.sender][hubName];

          // transfer locked vase to user at the end of 365 days
        uint256 durationYear = s_hubDurationYearly[msg.sender][hubName];
        if(block.timestamp > durationYear)
        {
           locked = withdrawLockedHub(hubName);
        }
        
        if(hub.percentageWid >= 240)
        {
            revert Hub__MaxPercentageWithdrawalReached();
        }

        if(s_referralEarning[msg.sender] > 0)
        {
           ref = (s_referralEarning[msg.sender] * 1e18);
        }
        s_referralEarning[msg.sender] = 0;
        uint256 amount = (s_hubPercentage * hub.lockedVase ) / 100;
        hub.percentageWid += 20;
        s_addressToPercentWid[msg.sender][hubName] += 20;
        
        s_hubDuration[msg.sender][hubName] = block.timestamp + 31 days;

        amount = (amount + ref + locked);
        
        emit HubBonusClaimed(msg.sender, amount, hub.percentageWid);
        bool success = s_stakingToken.transfer(msg.sender, amount);

        if (!success) {
            revert Hub__TransferFailed();
        }

        
    }


     function withdrawLockedHub(string memory hubName) internal returns(uint256)
     {
      
        Hub storage hub = s_addressToHub[msg.sender][hubName];
        uint256 amount = hub.lockedVaseBalance;
        if(amount <= 0){
            revert Hub__InsufficientBalance();
        }
        hub.lockedVaseBalance -= amount;
        hub.status = 0;
        s_addressToLockedBal[msg.sender][hubName] -= amount;
        
        s_hubDurationYearly[msg.sender][hubName] = block.timestamp + 365 days;
        
        emit HubLockedClaimed(msg.sender, amount);
        return amount;
      
    }


    modifier updateWithdrawalDurationHub(string memory hubName)
    {
        Hub storage hub = s_addressToHub[msg.sender][hubName];
        
        if(hub.percentageWid <= 240)
        {
          s_hubDuration[msg.sender][hubName] = block.timestamp + 31 days;

        }
        _;
    }
    
    modifier updateWithdrawalDurationHubYearly(string memory hubName)
    {
        Hub storage hub = s_addressToHub[msg.sender][hubName];
        
         s_hubDurationYearly[msg.sender][hubName] = block.timestamp + 365 days;
        
        _;
    }

    modifier minimumHubFee(uint256 amount)
    {
        if(amount < 1000 ether)
        {
          revert Hub__MinimumHubFee();
        }
         
        _;
    }

    modifier checkAllowedTokensHub(address token){
    address [] memory tempAllowed = allowedTokensHub;
        for(uint256 i = 0; i < tempAllowed.length; i++)
        {
            require(tempAllowed[i] == token, "Token Not Allowed");
                
        }
        
        _;
    }

    function getUserVaseLocked() external view returns(uint256)
    {
       return s_addressToLockedVASEHUB[msg.sender];
    }
    function getUserPercentageWid(string memory hubName) external view returns(uint256)
    {
       return s_addressToPercentWid[msg.sender][hubName];
    }
    function getUserHubName() external view returns(string memory){
       return s_addressToHubName[msg.sender];
    }

    function setHubPercentage(uint256 newFee) external onlyOwner
    {

       s_hubPercentage = newFee;
    
    }
    function getHubPercentage() external view onlyOwner returns(uint256)
    {

       return s_hubPercentage;
  
    }

    function setHubRefBonus(uint256 newFee) external onlyOwner
    {

       s_refBonus = newFee;
    
    }
    function getHubRefBonus() external view onlyOwner returns(uint256)
    {

       return s_refBonus;
  
    }
    
    function withdrawAdminBusd(uint256 amount) external onlyOwner nonReentrant {
        s_totalBUSD -= amount;
        emit WithdrawOwner(amount);
        bool success = s_busdToken.transfer(msg.sender, amount);
        if (!success) {
            revert Hub__TransferFailed();
        }
    }

     function withdrawAdminVASE(uint256 amount) external onlyOwner nonReentrant {
        
        emit WithdrawOwner(amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Hub__TransferFailed();
        }
    }

    function withdrawOtherCoins(uint256 amount, address coin) external onlyOwner nonReentrant {
       
        bool success = IERC20(coin).transfer(msg.sender, amount);
        if (!success) {
            revert Hub__TransferFailed();
        }
    }

    function getAllHubsAdmin() external view onlyOwner returns(Hub[] memory){
      return s_allHubs;
    }

    function getTotalSupply() external view onlyOwner returns(uint256){
        return s_totalSupply;
    }
    function getTotalBusd() external view onlyOwner returns(uint256){
        return s_totalBUSD;
    }

    fallback() external payable
    {
        s_totalBUSD += msg.value;
    }
    receive() external payable
    {
        s_totalBUSD += msg.value;
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