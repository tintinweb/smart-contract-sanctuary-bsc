/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// File: BullsStaking.sol


pragma solidity 0.8.10;





contract BullsStakingPool is Ownable, Pausable {
  struct Stake {
    uint256 timeAt; //  stake made at
    uint256 lockPeriodUntil;  //  timeAt + lockPeriod. Rewars will be calculated until this time.
  }

  uint256 constant SECONDS_IN_YEAR = 31536000;

  address public bullsToken;
  uint256 public lockPeriod;

  uint256 public stakeRequired; //  stake amount required to be made
  uint256 public apy;

  mapping(address => Stake) public stakeOf;
  mapping(address => uint256) public stakeRequiredOf; //  stake made by address

  event StakeMade(address indexed _from);
  event UnstakeMade(address indexed _from);
  event RewardWithdrawn(address indexed _to, uint256 indexed _amount);


  /***
   * @dev Constructor.
   * @param _bullsToken bullsToken address.
   * @param _lockPeriod Lock period in seconds, during which stake cannt be unstaken.
   * @param _stakeRequired Stake amount to be made.
   */
  constructor(address _bullsToken, uint256 _lockPeriod, uint256 _stakeRequired) {
    bullsToken = _bullsToken;
    lockPeriod = _lockPeriod;
    stakeRequired = _stakeRequired;
    
    apy = 0xFA;  //  250
  }

  /***
   * @dev Updates APY.
   * @param _apy APY value.
   */
  function updateAPY(uint256 _apy) external onlyOwner {
    apy = _apy;
  }

  /***
   * @dev Updates APY.
   * @param _stakeRequired Stake amount to be updated to.
   */
  function updateStakeRequired(uint256 _stakeRequired) external onlyOwner {
    stakeRequired = _stakeRequired;
  }

  /***
   * @dev Updates lockPeriod in seconds.
   * @param _lockPeriod Lock period in seconds.
   */
  function updateLockPeriod(uint256 _lockPeriod) external onlyOwner {
    lockPeriod = _lockPeriod;
  }

  /***
   * @dev Gets BULLS balance for this Smart Contract.
   * @return BULLS balance.
   */
  function getBullsBalance() external view returns (uint256) {
    return IERC20(bullsToken).balanceOf(address(this));
  }

  /***
   * @dev Makes stake.
   */
  function stake() external whenNotPaused {
    require(stakeOf[msg.sender].timeAt == 0, "Stake made");
    require(IERC20(bullsToken).transferFrom(msg.sender, address(this), stakeRequired), "Transfer failed");

    stakeOf[msg.sender] = Stake(block.timestamp, block.timestamp + lockPeriod);
    stakeRequiredOf[msg.sender] = stakeRequired;

    emit StakeMade(msg.sender);
  }

  /***
   * @dev Calculates available BULLS reward since stake made to date.
   * @return Available reward.
   */
  function calculateAvailableBullsReward() public view returns (uint256) {
    if (stakeOf[msg.sender].timeAt == 0) {
      return 0;
    }

    if (stakeOf[msg.sender].timeAt >= stakeOf[msg.sender].lockPeriodUntil) {
      return 0;
    }

    uint256 rewardPeriod;
    if (block.timestamp < stakeOf[msg.sender].lockPeriodUntil) {
      rewardPeriod = block.timestamp - stakeOf[msg.sender].timeAt;
    } else {
      rewardPeriod = stakeOf[msg.sender].lockPeriodUntil - stakeOf[msg.sender].timeAt;
    }
    
    uint256 percentagePerSec = (apy * 1 ether) / SECONDS_IN_YEAR;
    uint256 amount = ((stakeRequiredOf[msg.sender] * percentagePerSec) * rewardPeriod) / 100 ether;   //  ((2*10^18 * 9512937595129) * 12345) / (100 * 10^18) = 2348744292237350 wei == 0.2348744292237350 BULLS. 100 ether = 1 ether & 100%
    return amount;
  }

  /***
   * @dev Withdraws available reward.
   */
  function withdrawAvailableReward() public whenNotPaused {
    uint256 bullsReward = calculateAvailableBullsReward();
    require(bullsReward > 0, "No reward");

    IERC20(bullsToken).transferFrom(owner(), msg.sender, bullsReward);
    
    stakeOf[msg.sender].timeAt = block.timestamp;

    emit RewardWithdrawn(msg.sender, bullsReward);
  }

  /**
   * @dev Makes unstake.
   */
  function unstake() external whenNotPaused {
    require(stakeOf[msg.sender].timeAt > 0, "no stake");
    require(stakeOf[msg.sender].lockPeriodUntil < block.timestamp, "too early");

    if (calculateAvailableBullsReward() > 0) {
      withdrawAvailableReward();
    }
    delete stakeOf[msg.sender];

    IERC20(bullsToken).transfer(msg.sender, stakeRequiredOf[msg.sender]);
    
    emit UnstakeMade(msg.sender);
  }

  /**
   * Pausable
   */

  /***
   * @dev Pauses or unpauses.
   * @param _isPause Whether should pause or unpause.
   */
  function pause(bool _isPause) external onlyOwner {
    _isPause ? _pause() : _unpause();
  }
}