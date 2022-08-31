/**
 *Submitted for verification at BscScan.com on 2022-08-31
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

// File: forwarding.sol


pragma solidity 0.8.3;



interface IClaimToken is IERC20 {
    function mint(address _account, uint256 amount) external;
    function burn(address _account, uint256 amount) external;
}

/// @title A contract for staking tokens
/// @dev Conventially, this should be renamed to include the name of the token it receives
contract StakingForwarder is Ownable {

    // Tokens managed by the contract
    IERC20 internal stakeToken;
    IClaimToken internal returnToken;

    // For timelock
    struct LockedItem {
        uint256 expires;
        uint256 amount;
    }
    mapping(address => LockedItem[]) public timelocks;
    // store the amount deposited for each account every day    
    mapping (uint256 => mapping(address => uint256)) public dailyDeposit;
    mapping (address => uint256) public firstDepost;
    mapping (address => uint256) public lastWithdraw;

    event Deposit(address account, uint256 amount);
    event Withdraw(address account, uint256 amount);
    event Withdraw30Day(address account, uint256 amount);

    address public stakingAddress;

    uint256 public lockInterval = 7776000 * 1 seconds; // 90 days
    uint256 public month = 2592000 * 1 seconds; // 30 days
    uint256 public rewardPercent = 100; // 1%
    uint256 public amount = 25 * (10**18); // 25 BUSD
    uint256 public maxDailyDeposit = 500 * (10**18); // 500 BUSD

    /// @param _stakeTokenAddress The address of the token to be staked, that the contract accepts
    /// @param _returnTokenAddress The address of the token that's given in return
    constructor(address _stakeTokenAddress, address _returnTokenAddress) {
        stakeToken = IERC20(_stakeTokenAddress);
        returnToken = IClaimToken(_returnTokenAddress);
        stakingAddress = msg.sender;
    }

    /// @notice Accepts tokens, locks them and gives different tokens in return
    /// @dev The depositor should approve the contract to manage stakingTokens
    /// @dev For minting returnTokens, this contract should be the owner of them
    function deposit() external {
        require(timelocks[msg.sender].length < 600, "Too many consecutive deposits");
        require(dailyDeposit[getDay()][msg.sender] + amount <= maxDailyDeposit, "Daily deposit too high");

        stakeToken.transferFrom(msg.sender, stakingAddress, amount);
        returnToken.mint(msg.sender, amount);
        LockedItem memory timelockData;
        timelockData.expires = block.timestamp + lockInterval;
        timelockData.amount = amount;
        timelocks[msg.sender].push(timelockData);
        if (firstDepost[msg.sender] == 0) {
            firstDepost[msg.sender] = block.timestamp;
        }
        emit Deposit(msg.sender, amount);
    }

    /// @notice If the timelock is expired, gives back the staked tokens in return for the tokens obtained while depositing
    /// @dev This contract should have sufficient allowance to be able to burn returnTokens from the user
    /// @dev For burning returnTokens, this contract should be the owner of them
    function withdraw() external {
        require(returnToken.allowance(msg.sender, address(this)) >= amount, "Token allowance not sufficient");
        require(returnToken.balanceOf(msg.sender) - getLockedAmount(msg.sender) >= amount, "Not enough unlocked tokens");

        returnToken.burn(msg.sender, amount);
        stakeToken.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    /// @notice Withdraw 1% every 30 days
    function withdraw30Day() external {
        require(firstDepost[msg.sender] + month < block.timestamp, "To soon to claim first reward");
        uint256 amountOut = getLockedAmount(msg.sender) / rewardPercent; 
        require(amountOut > 0, "Non-positive withdraw amount");
        require(lastWithdraw[msg.sender] + month < block.timestamp, "Can only withdraw every 30 days");

        lastWithdraw[msg.sender] = block.timestamp;
        stakeToken.transfer(msg.sender, amountOut);
        emit Withdraw30Day(msg.sender, amountOut);
    }

    /// @notice Sets the timelock interval for new deposits
    /// @param _seconds The desired interval in minutes
    function setLockInterval(uint256 _seconds) external onlyOwner {
        lockInterval = _seconds * 1 seconds;
    }

    /// @notice Sets the timelock interval for new deposits
    /// @param _percent The desired reward in percent
    function setRewardPercent(uint256 _percent) external onlyOwner {
        rewardPercent = _percent;
    }

    function setDepositAmount(uint256 _amount) external onlyOwner {
        amount = _amount;
    }

    function setStakingAddress(address _address) external onlyOwner {
        stakingAddress = _address;
    }

    /// @notice Withdraws non-stake tokens that are stuck
    function withdrawForeignToken(address token) public onlyOwner {
        require(address(stakeToken) != address(token), "Cannot withdraw stake token");
        IERC20(address(token)).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }

    /// @notice Checks the amount of locked tokens for an account and deletes any expired lock data
    /// @param _investor The address whose tokens should be checked
    /// @return The amount of locked tokens
    function getLockedAmount(address _investor) public returns (uint256) {
        uint256 lockedAmount = 0;
        LockedItem[] storage usersLocked = timelocks[_investor];
        int256 usersLockedLength = int256(usersLocked.length);
        uint256 blockTimestamp = block.timestamp;
        for(int256 i = 0; i < usersLockedLength; i++) {
            if (usersLocked[uint256(i)].expires <= blockTimestamp) {
                // Expired locks, remove them
                usersLocked[uint256(i)] = usersLocked[uint256(usersLockedLength) - 1];
                usersLocked.pop();
                usersLockedLength--;
                i--;
            } else {
                // Still not expired, count it in
                lockedAmount += usersLocked[uint256(i)].amount;
            }
        }
        return lockedAmount;
    }

    function getDay() internal view returns(uint256){
        return block.timestamp / 1 days;
    }

}