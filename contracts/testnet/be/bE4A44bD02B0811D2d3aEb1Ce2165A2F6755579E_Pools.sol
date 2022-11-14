// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Pools is Ownable {
    uint public claimFee = 1000000000000;
    uint public interestDecimal = 1000_000;
    struct Pool {
        uint timeLock;
        uint minLock;
        uint maxLock;
        uint currentInterest; // daily
        uint totalLock;
        bool enable;
    }
    struct User {
        uint totalLock;
        uint startTime;
        uint totalReward;
    }
    struct Claim {
        uint date;
        uint amount;
    }
    Pool[] public pools;
    mapping(address => mapping(uint => User)) public users; // user => pId => detail
    mapping(address => mapping(uint => Claim[])) public userClaimed;
    constructor() {

    }
    function getPools(uint[] memory _pids) external view returns(Pool[] memory _pools) {
        for(uint i = 0; i < _pids.length; i++) _pools[i] = pools[_pids[i]];
    }
    function setClaimFee(uint _claimFee) external onlyOwner {
        claimFee = _claimFee;
    }
    function getDays() public view returns(uint) {
        return block.timestamp / 1 days;
    }
    function getUsersClaimedLength(uint pid, address user) external view returns(uint length) {
        return userClaimed[user][pid].length;
    }
    function getUsersClaimed(uint pid, address user, uint _limit, uint _skip) external view returns(Claim[] memory list, uint totalItem) {
        totalItem = userClaimed[user][pid].length;
        uint limit = _limit <= totalItem - _skip ? _limit + _skip : totalItem;
        uint lengthReturn = _limit <= totalItem - _skip ? _limit : totalItem - _skip;
        list = new Claim[](lengthReturn);
        for(uint i = _skip; i < limit; i++) {
            list[i-_skip] = userClaimed[user][pid][i];
        }
    }
    function currentReward(uint pid, address user) public view returns(uint) {
        User memory u = users[user][pid];
        if(u.totalLock == 0) return 0;
        Pool memory p = pools[pid];
        uint spendDays;
        if(userClaimed[user][pid].length == 0) {
            spendDays = getDays() - u.startTime / 1 days;
        } else {
            Claim memory claim = userClaimed[user][pid][userClaimed[user][pid].length-1];
            spendDays = getDays() - claim.date;
        }
        return p.currentInterest * u.totalLock * spendDays / interestDecimal;
    }
    function withdraw(uint pid) public {
        Pool storage p = pools[pid];
        User storage u = users[_msgSender()][pid];
        require(u.totalLock > 0, 'Pools::withdraw: not lock asset');
        require(block.timestamp - u.startTime > p.timeLock, 'Pools::withdraw: not meet lock time');

        claimReward(pid);
        payable(_msgSender()).transfer(u.totalLock);

        p.totalLock -= u.totalLock;
        u.totalLock = 0;
        u.startTime = 0;
    }
    function claimReward(uint pid) public {
        uint reward = currentReward(pid, _msgSender());
        if(reward > claimFee) {
            payable(_msgSender()).transfer(reward);
            userClaimed[_msgSender()][pid].push(Claim(getDays(), reward));
            users[_msgSender()][pid].totalReward += reward;
        }
    }
    function deposit(uint pid) external payable {
        Pool storage p = pools[pid];
        User storage u = users[_msgSender()][pid];
        require(msg.value >= p.minLock && msg.value <= p.maxLock, 'Pools::deposit: Invalid amount');

        claimReward(pid);
        u.totalLock += msg.value;
        u.startTime = block.timestamp;
        p.totalLock += msg.value;
    }
    function togglePool(uint pid, bool enable) external onlyOwner {
        pools[pid].enable = enable;
    }
    function updateMinMaxPool(uint pid, uint minLock, uint maxLock) external onlyOwner {
        pools[pid].minLock = minLock;
        pools[pid].maxLock = maxLock;
    }
    function updateInterestPool(uint pid, uint currentInterest) external onlyOwner {
        pools[pid].currentInterest = currentInterest;
    }
    function updatePool(uint pid, uint timeLock, uint minLock, uint maxLock, uint currentInterest, bool enable) external onlyOwner {
        pools[pid].timeLock = timeLock;
        pools[pid].minLock = minLock;
        pools[pid].maxLock = maxLock;
        pools[pid].currentInterest = currentInterest;
        pools[pid].enable = enable;
    }
    function addPool(uint timeLock, uint minLock, uint maxLock, uint currentInterest) external onlyOwner {
        pools.push(Pool(timeLock, minLock, maxLock, currentInterest, 0, true));
    }
    function inCaseTokensGetStuck(IERC20 _token) external onlyOwner {

        uint _amount = _token.balanceOf(address(this));
        _token.transfer(msg.sender, _amount);
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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