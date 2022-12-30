/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


/*SPDX-License-Identifier: GPL-3.0*/
pragma solidity ^0.8.15;


contract USDCGame is Ownable, ReentrancyGuard{
    /*State*/
    uint256 public totalDeposits;
    uint256 public totalDepositors;

    uint256 specifiedAmountForWithdraw;
    uint256 public minimumDepositAmount;

    uint256 public adminFee = 450;  /* 4.5% */
    uint256 public charityFee = 550;    /* 5.5% */
    uint256 PERCENT_DIVIDER = 10000;

    address public admin;
    address public charity;

    IERC20 USDC;
    address public tokenAddress;
    bool public randomizerEnabled;  /*Randomizer enabled status*/

    uint256 lastSpecialAddressCount;
    mapping (uint256 => address) lastSpecialAddresses; /*Special adresses stored here*/
    
    mapping (address => uint256) public UserToId; 
    mapping (uint256 => address) public IdToUser;  
    mapping (uint256 => uint256) public UserDeposits;
    mapping (uint256 => uint256) public UserWithdraws;
    mapping (uint256 => bool) public ExcludeFromWithdraw;
    mapping (uint256 => bool) public WithdrawEnabled; 

    address public randomizerCaller;

    modifier onlyCaller{
        require(_msgSender() == randomizerCaller, "Error: only called by the caller");
        _;
    }

    /* Some useful events*/
    event Deposit(address indexed depositor, uint256 indexed depositedAmount);
    event TaxDeduction(uint256 indexed toAdmin, uint256 indexed toCharity);
    event Withdraw(address indexed depositer, uint256 indexed withdrawAmount);
    
    constructor(address _usdc, address _admin, address _charity, address _randomizerCaller){
        USDC = IERC20(_usdc);
        tokenAddress = _usdc;
        admin = _admin;
        charity = _charity;
        minimumDepositAmount = 20 * (10**USDC.decimals());  /* Minimum deposit amount is 20 USDC*/
        randomizerCaller = _randomizerCaller;
    }

    /*Logic*/

    /*
    * Make Deposit */
    function deposit(uint256 _depositAmount) nonReentrant external returns(bool){
        address _owner = msg.sender;
        require(_depositAmount >= minimumDepositAmount, "Deposit Error: minimum deposit");
        require(USDC.balanceOf(_owner) >= _depositAmount, "Deposit Error: Insufficient USDC Balance");

        /* Approval is required from the depositor for transfer. Manage the same from fontend*/
        uint256 afterTax = _deductTax(_depositAmount, _owner);
        /* Transfer to contract*/
        USDC.transferFrom(_owner, address(this), afterTax);

        /* after deposit*/
        _afterDeposit(_owner, _depositAmount);

        emit Deposit(_owner, _depositAmount);
        return true;
    }

    /*
    * Calculate and transfer tax */
    function _deductTax(uint256 _beforeTax, address _owner) private returns(uint256 _afterTax){
        uint256 toAdmin;
        uint256 toCharity;
        toAdmin = (_beforeTax*adminFee)/PERCENT_DIVIDER;
        toCharity = (_beforeTax*charityFee)/PERCENT_DIVIDER;
        /* Do transfer */
        USDC.transferFrom(_owner, admin, toAdmin);
        USDC.transferFrom(_owner, charity, toCharity);

        _afterTax = _beforeTax - (toAdmin + toCharity);
        emit TaxDeduction(toAdmin, toCharity);
    } 

    /*
    * Hook: afterDeposit */
    function _afterDeposit(address _owner, uint256 _depositAmount) private{
        /* Update State */
        totalDeposits = totalDeposits + _depositAmount;
        createUserIdList(_owner);
        uint256 userId = UserToId[_owner];
        UserDeposits[userId] += _depositAmount;
        coolRandomizer();
    }

    /*
    * Create user id list*/
    function createUserIdList(address userAddress) internal{
        uint256 userId = UserToId[userAddress];
        uint256 incr = totalDepositors + 1;
        if(userId == 0){
            UserToId[userAddress] = incr;
            IdToUser[incr] = userAddress;
            totalDepositors++;
        }
    }

    /*
    * Exclude from withdraw*/
    function setExcludeFromWithdraw(address userAddress) internal{
        uint256 id = UserToId[userAddress];
        ExcludeFromWithdraw[id] = true;
    }
    /*
    * Include in Withdraw*/
    function setIncludeInWithdraw(address userAddress) external onlyOwner{
        uint256 id = UserToId[userAddress];
        ExcludeFromWithdraw[id] = false;
    }

    /*
    * Withdraw function*/
    function withdraw() nonReentrant external{
        address _owner = msg.sender;
        uint256 userId = UserToId[_owner];
        uint256 cap = specifiedAmountForWithdraw;
        /* Some Checks*/
        require(ExcludeFromWithdraw[userId] != true, "Withdraw Error: can't withdraw twice");
        require(WithdrawEnabled[userId] == true, "Withdraw Error: not randomly picked");
        
        UserWithdraws[userId] += cap;
        /* transfer now*/
        USDC.transfer(_owner, cap);
        /*after withdraw made*/
        ExcludeFromWithdraw[userId] = true;
        WithdrawEnabled[userId] = false;
        emit Withdraw(_owner, cap);
    }

    /*
    * Create randomly picked ids*/
    function coolRandomizer() private{
        if(randomizerEnabled){
            /* calculate certain percentage of user from totalDepositors*/
            uint256 certainPercentage = randomNumberGenerator(100);
            uint256 percentToUsers = (certainPercentage*totalDepositors)/100;
            lastSpecialAddressCount = percentToUsers;

            /* now as we have got total number of users to distribute to
            *  we can randomly select that many users and make them withdrawable*/

            for(uint8 index=0;index<percentToUsers;index++){
                uint256 randomId = randomNumberGenerator(percentToUsers);
                if(ExcludeFromWithdraw[randomId]){
                    randomId = randomNumberGenerator(percentToUsers);
                    if(index>0){
                        index--;
                    }else{
                        index=0;
                    }
                    continue;
                }
                lastSpecialAddresses[index] = IdToUser[randomId]; /*Spitting out addresss*/
                WithdrawEnabled[randomId] = true;
            }
        }    
    }
    /*Get special addresses*/
    function getSpecialAddresses() external onlyCaller returns(address[] memory){
        coolRandomizer();
        address[] memory ret = new address[](lastSpecialAddressCount);
        for(uint32 i=0;i<lastSpecialAddressCount;i++){
            ret[i] = lastSpecialAddresses[i];
        }
        return ret;
    }
    /*
    * A cool random number generator*/
    function randomNumberGenerator(uint256 _upto) private view returns(uint256){
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        uint256 randomNumber = seed - ((seed / _upto) * _upto);
        if(randomNumber == 0){
            randomNumber++;
        }
        return randomNumber;
    }

    /*
    * Set randomizerCaller*/
    function setRandomizerCaller(address _address) onlyOwner external returns(bool){
        randomizerCaller = _address;
        return true;
    }
    /*
    * Toggle randomizer enabled status*/
    function toggleRandomizer() onlyOwner external returns(bool){
        randomizerEnabled = !randomizerEnabled;
        return true;
    }

    /*
    * Change admin address*/
    function setAdmin(address _newAdmin) onlyOwner external returns(bool){
        admin = _newAdmin;
        return true;
    }

    /*
    * Change charity address*/
    function setCharity(address _charity) onlyOwner external returns(bool){
        charity = _charity;
        return true;
    }

    /*
    * Get contract ether balance*/
    function contractBalance() external view returns(uint256 etherBalance){
        return address(this).balance;
    }

    /*
    * Get contract token balance*/
    function contractTokenBalance(address whichToken) external view returns(uint256 tokenBalance){
        return(IERC20(whichToken).balanceOf(address(this)));
    }

    /* Set Specified amount to withdraw
    * only owner function
    * set specified amount for randomly picked users to withdraw*/
    function setSpecifiedAmount(uint256 _amount) onlyOwner external returns(uint256){
        specifiedAmountForWithdraw = _amount;
        return specifiedAmountForWithdraw;
    }

    /* Set minimum deposit amount, onlyowner*/
    function setMinimumDepositAmount(uint256 _amount) onlyOwner external returns(uint256){
        minimumDepositAmount = _amount;
        return minimumDepositAmount;
    }

    /* Cool Janitor*/
    /* Transfer any token available in this contract's balance*/
    function sweep(address token) onlyOwner external returns(uint256 _swept){
        uint256 thisBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner(), thisBalance);
        _swept = thisBalance;
    }

}