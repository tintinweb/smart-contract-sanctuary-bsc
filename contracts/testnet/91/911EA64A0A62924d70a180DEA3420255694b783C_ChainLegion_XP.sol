/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

pragma solidity 0.8.13;


// SPDX-License-Identifier: MIT
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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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

/**
    @dev Provides a function used to increment XP points
 */
interface IExperienceTracker {

    function addExperiencePoints(uint256 amount, uint256 id) external;

}

/**
    @dev Contract responsible for storing XP and leveling progress for individual Legionnaires.
 */
contract ChainLegion_XP is IExperienceTracker, Ownable {

    mapping (uint256 => uint256) public levelXP;
    mapping (uint256 => uint256) public totalXP;
    mapping (uint256 => uint256) public levels;

    uint256 public maxLevel = 100;
    uint public initializeFee = 0.01 ether;

    event LevelUp(uint256 id, uint256 level);
    event Initialized(uint256 id);
    event ExperienceGained(uint256 id, uint256 amount);

    /** 
        @dev Increases the max level to the given number
        [Throws] If given argument <= maxLevel
     */
    function setMaxLevel(uint256 maxLevel_) external onlyOwner {
        require (maxLevel_ > maxLevel, "Cannot reduce max level");
        maxLevel = maxLevel_; 
    }

    /**
        @dev Sets the initialization fee to the given amount
     */
    function setInitializeFee(uint256 fee_) external onlyOwner {
        initializeFee = fee_;
    }

    /** 
        @dev Initializes the given token id to level 1 
        [Throws] If the given id has already been initialized
        [Throws] If the value sent is insufficient
    */
    function initialize(uint256 id_) payable external whenNotPaused {
        require (levels[id_] == 0, "Already initialized");
        require (msg.value >= initializeFee, "Insufficent value sent.");
        levels[id_] = 1;
        emit Initialized(id_);
    }

    /** 
        @dev Levels up the given token id.
        [Throws] If the token has not been initialized
        [Throws] If max level has been reached already
        [Throws] If not enough levelXP has been accumulated
    */
    function levelUp(uint256 id_) external whenNotPaused {
        uint256 currentLevel = levels[id_];
        require (currentLevel > 0, "Not initialized");
        require (currentLevel < maxLevel, "Max level reached");

        uint256 nextLevel = currentLevel + 1;
        _levelUpTo(nextLevel, id_);
        
        emit LevelUp(id_, nextLevel);
    }

    function _levelUpTo(uint256 nextLevel_, uint256 id_) private {
        uint256 xp = levelXP[id_];

        uint256 xpRequired = _calculateXpRequired(nextLevel_);
        require (xp >= xpRequired, "Not enough XP");

        unchecked {
            levels[id_] += 1;
            levelXP[id_] = xp - xpRequired;
        }
    }

    /**
        @dev Calculates the amount of XP required to level up to the given level
     */
    function _calculateXpRequired(uint256 level_) private pure returns(uint256) {
        return (10 * (level_ ** 2) + 60);
    }

    /**
        @dev Adds the given amount of XP points to the given token id
        [Throws] If the sender is not authorized
        [Throws] If the token id has not been initialized
        [Throws] If max level has been reached
     */
    function addExperiencePoints(uint256 amount_, uint256 id_) external whenNotPaused ifAuthority(msg.sender) {
        uint256 currentLevel = levels[id_];
        require (currentLevel > 0, "Not initialized");
        require (currentLevel < maxLevel, "Max level reached");

        levelXP[id_] += amount_;
        totalXP[id_] += amount_;
        
        emit ExperienceGained(id_, amount_);
    }

    // Pausing functionality
    bool public paused = false;

    modifier whenNotPaused {
        require (!paused, "Contract paused.");
        _;
    }
    
    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
    }

    // Authorization
    mapping (address => bool) _authorities;

    modifier ifAuthority(address address_) {
        require (_authorities[address_], "Not authorized");
        _;
    }

    function setAuthority(address authority_, bool state_) external onlyOwner {
        _authorities[authority_] = state_;
    }

  /** @dev Withdraw funds from the contract to the owner */
  function withdrawAll() external onlyOwner {
    uint256 balance = address(this).balance;
    (bool success, ) = payable(owner()).call{value: balance}("");
    require (success, "Failed to withdraw funds");
  }

}