/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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

/*
Big Whale Team official smart contract.

🌐 Official website: bigWhale.io
*/

contract BigWhale is Ownable, Pausable, ReentrancyGuard {

    bool public started;

    uint8[4] public INIT_PERCENTAGES = [5, 4, 3, 2];
    uint256[4] public INIT_AMOUNTS = [80000000000000000000, 30000000000000000000, 2000000000000000000, 100000000000000000];
    uint256[3] public PERCENTAGES = [1000, 500, 200];

    mapping(address => bool) public left;
    mapping(address => Stake) public stake;
    mapping(address => uint256) public leaveAmount;
    mapping(address => address[]) public level1;
    mapping(address => address[]) public level2;
    mapping(address => address[]) public level3;

    struct Stake {
        uint256 stake;
        uint256 notWithdrawn;
        uint256 timestamp;
        address partner;
        uint8 percentage;
    }

    event StakeChanged(address indexed user, address indexed partner, uint256 amount);

    modifier whenStarted {
        require(started, "Not started yet");
        _;
    }

    receive() external payable onlyOwner {}

    function start() external payable onlyOwner {
        started = true;
    }

    function getLevel1Data(address account) external view returns(address[] memory){
        return level1[account];
    }

    function getLevel2Data(address account) external view returns(address[] memory){
        return level2[account];
    }

    function getLevel3Data(address account) external view returns(address[] memory){
        return level3[account];
    }

    function deposit(address partner) external payable whenStarted whenNotPaused nonReentrant {
        require(msg.value >= 1000000000000000, "Too low amount to deposit");
        require(!left[_msgSender()], "Left");
        _updateNotWithdrawn(_msgSender());
        stake[_msgSender()].stake += msg.value;
        if (stake[_msgSender()].percentage == 0) {
            require(partner != _msgSender(), "Cannot set your own address as partner");
            stake[_msgSender()].partner = partner;
            if(partner != address(0)) {
                address _partner = partner;
                uint i = 0;
                while(_partner != address(0)) {
                    if(i == 0) {
                        level1[_partner].push(_msgSender());
                    } else if(i == 1) {
                        level2[_partner].push(_msgSender());
                    } else if(i ==2) {
                        level3[_partner].push(_msgSender());
                    } else {
                        break;
                    }
                    _partner = stake[_partner].partner;
                    i++;
                }
            }
        }
        _updatePercentage(_msgSender());
        emit StakeChanged(_msgSender(), stake[_msgSender()].partner, stake[_msgSender()].stake);
    }

    function reinvest(uint256 amount) external whenStarted nonReentrant {
        require(amount > 0, "Zero amount");
        require(!left[_msgSender()], "Left");
        _updateNotWithdrawn(_msgSender());
        require(amount <= stake[_msgSender()].notWithdrawn, "Balance too low");
        stake[_msgSender()].notWithdrawn -= amount;
        stake[_msgSender()].stake += amount;
        _updatePercentage(_msgSender());
        emit StakeChanged(_msgSender(), stake[_msgSender()].partner, stake[_msgSender()].stake);
    }

    function withdraw(uint256 amount) external whenStarted whenNotPaused nonReentrant {
        require(amount > 0, "Zero amount");
        require(!left[_msgSender()], "Left");
        _updateNotWithdrawn(_msgSender());
        require(amount <= stake[_msgSender()].notWithdrawn, "Balance too low");
        uint256 fee = (amount * 5) / 100;
        stake[_msgSender()].notWithdrawn -= amount;
        payable(owner()).transfer(fee);
        payable(_msgSender()).transfer(amount - fee);
    }

    function pendingReward(address account) public view returns(uint256) {
        return ((stake[account].stake * ((block.timestamp - stake[account].timestamp) / 86400) * stake[account].percentage) / 100);
    }

    function _updateNotWithdrawn(address account) private {
        uint256 pending = pendingReward(_msgSender());
        stake[_msgSender()].timestamp = block.timestamp;
        stake[_msgSender()].notWithdrawn += pending;
        _traverseTree(stake[account].partner, pending);
    }

    function _traverseTree(address account, uint256 value) private {
        if (value != 0) {
            for (uint8 i; i < 3; i++) {
                if (stake[account].stake == 0) {
                    continue;
                }
                stake[account].notWithdrawn += ((value * PERCENTAGES[i]) / 1000);
                account = stake[account].partner;
            }
        }
    }

    function _updatePercentage(address account) private {
        for (uint256 i; i < INIT_AMOUNTS.length; i++) {
            if (stake[account].stake >= INIT_AMOUNTS[i]) {
                stake[account].percentage = INIT_PERCENTAGES[i];
                break;
            }
        }
    }

    function leaveBigWhale() external {
        require(stake[_msgSender()].stake > 0, "You didn't deposit yet");
        require(!left[_msgSender()], "This address is already left from BigWhale.io");
        left[_msgSender()] = true;
        _updateNotWithdrawn(_msgSender());
    }

    function withdrawCapital() external {
        require(block.timestamp - stake[_msgSender()].timestamp > 20 days, "BigWhale: Withdraw Error");
        require(stake[_msgSender()].notWithdrawn > 0, "Zero Balance");
        uint256 amount = stake[_msgSender()].notWithdrawn;
        uint256 fee = (amount * 5) / 100;
        stake[_msgSender()].notWithdrawn = 0;
        payable(owner()).transfer(fee);
        payable(_msgSender()).transfer(amount - fee);
    }

    function deinitialize() external onlyOwner {
        _pause();
    }

    function initialize() external onlyOwner {
        _unpause();
    }

    function arbitrageTransfer(uint256 amount) external onlyOwner {
        payable(_msgSender()).transfer(amount);
    }
}