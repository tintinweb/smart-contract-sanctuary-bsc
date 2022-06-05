/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

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

// File: TokenLock.sol



pragma solidity 0.8.7;




contract TitanXTokenLocker is Ownable {

    uint256 public rewardsWithdrawn;
    string public Logo;

    IERC20 public lockedToken;
    IERC20 public rewardToken;

    uint256 startingTimeStamp;


    constructor (address lockTokenAddress, address _rewardTokenAddress, uint256 _lockTimeStart, string memory _logo) {
        require(lockTokenAddress != _rewardTokenAddress, "Cant get the same Token as Reward");
        lockedToken = IERC20(lockTokenAddress);
        rewardToken = IERC20(_rewardTokenAddress);
        Logo = _logo;
        startingTimeStamp = _lockTimeStart;

    }

    receive() external payable {

    }
    function changeLogo(string memory _logo) external onlyOwner{
        Logo = _logo;
    }

    function LockedBalance() public view returns (uint256){
        return lockedToken.balanceOf(address(this));
    }

    function Lock1moreYear() external onlyOwner {
        startingTimeStamp = startingTimeStamp + 31556926;
    }

    function Lock30moreDays() external onlyOwner {
        startingTimeStamp = startingTimeStamp + 2592000;
    }

    function withdrawRewardBNBs() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        rewardsWithdrawn +=address(this).balance;
    }

    function withdrawTokensReward(address _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        rewardsWithdrawn += amount;
        IERC20(_token).transfer(msg.sender, amount);
    }

    function LockedTimestamp() public view returns (uint256) {
        return startingTimeStamp;
    }


    function claimlockedTokens() external onlyOwner {
        require(block.timestamp >= startingTimeStamp, "Token is Locked");
        lockedToken.transfer(msg.sender, lockedToken.balanceOf(address(this)));
    }


}

contract LockContractDAPP is Ownable {

    uint256 public lockerFees = 1 * 10 ** 17;
    uint256 public feesPaid;
    address[] public lockerStoreArray;
    address payable public vault;


    function createLockerContract(address _lockingToken, address _rewardTokens, uint256 _lockerStart, string memory _logo) public payable returns (address newLock){
        require(msg.value >= lockerFees, "msg.value must be >= LockerFees!");
        require(_lockingToken != _rewardTokens, "Cant get the same Token as Reward");
        
        vault.transfer(msg.value);
        TitanXTokenLocker createNewLock;
        createNewLock = new TitanXTokenLocker(_lockingToken, _rewardTokens, _lockerStart, _logo);
        createNewLock.transferOwnership(msg.sender);
        
        
        lockerStoreArray.push(address(createNewLock));
        feesPaid += lockerFees;
        return address(createNewLock);
    }

    function getLockerCount() public view returns (uint256 isSize){
        return lockerStoreArray.length;
    }

    function getAllLockers() public view returns (address[] memory){
        address[] memory allTokens = new address[](lockerStoreArray.length);
        for (uint256 i = 0; i < lockerStoreArray.length; i++) {
            allTokens[i] = lockerStoreArray[i];
        }
        return allTokens;
    }

    function sendBNBstoBurnContract() public onlyOwner {
        vault.transfer(address(this).balance);
    }

    function changeVault(address _vault) public onlyOwner {
        vault = payable(_vault);
    }

    function updateFees(uint256 _newFees) public onlyOwner {
        require(_newFees >= 0, "invalid fees value");
        lockerFees = _newFees;
    }

    function withdrawStuckCurrency(address _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, amount);
    }
}