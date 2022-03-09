/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.0 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity >= 0.6.0;


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


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// File: contracts/T2K_Locked_Staking.sol



pragma solidity ^0.8.4;




contract T2K_Locked_Staking is Ownable{
    using Counters for Counters.Counter;
    Counters.Counter internal _stakeCounter;

    struct Stake {
        address user; // user address
        uint256 id; // stake id
        uint256 amount; // amount of tokens staked
        uint256 reward; // reward amount for lock
        uint256 startTime; // time stake was created
        uint256 term; // how long it is staked (secs)
        uint256 unlockTime; // timestamp of unlock
    }

    IERC20 public T2K;

    mapping(uint256 => uint256) public idToBalance;
    mapping(uint256 => uint256) public idToTerm;
    mapping(uint256 => uint256) public idToStartTime;
    mapping(uint256 => address) private _idToAddress;
    mapping(address => uint256[]) private _addressToIds;
    mapping(uint256 => uint256) public lockToInterest;
    uint256 public total_owed;
    uint256 public total_allocated;
    uint256 public early_withdraw_penalty = 500; // 5% in basis points

    constructor(uint256 _total_allocated, address _t2k){
        total_allocated = _total_allocated;
        T2K = IERC20(_t2k);

        lockToInterest[7 days] = 40; // .4% roi for that week, 20.8% APR, 23.1% APY
        lockToInterest[30 days] = 300; // 3% roi for that month, 36% APR, 42.3% APY
        lockToInterest[90 days] = 1500; //15% roi for the 3 months, 60% APR, 75% APY
        lockToInterest[180 days] = 3500; // 35% roi for 6 months, 70% APR, 82.23% APY
        lockToInterest[360 days] = 10000; // 100% APR/APY
    }

    function updateTotalAllocated(uint256 newTotal) public onlyOwner {
        require(newTotal <= total_owed, "Too much owed");
        total_allocated = newTotal;
    }

    function deposit(uint256 amount) public onlyOwner {
        require(T2K.transferFrom(msg.sender, address(this), amount), "Transfer Failed");
        total_allocated += amount;
    }

    function updateEarlyWithdrawPenalty(uint256 newPenalty) public onlyOwner {
        require(newPenalty <= 2000, "Penalty Must be less than 20%");
        early_withdraw_penalty = newPenalty;
    }

    function getAvailableSpace(uint256 term) public view returns(uint256 available) {
        uint256 left = total_allocated - total_owed;
        available = (left * 10000) / lockToInterest[term];
        return available;
    }

    function updateLockToInterest(uint256 term, uint256 newInterest) public onlyOwner {
        lockToInterest[term] = newInterest;
    }

    function ERC20Withdraw(address token, uint256 amount) public onlyOwner {
        require(IERC20(token).transfer(owner(), amount), "ERC20 Withdraw Failed");
    }

    function getStakes(address user) public view returns(uint[] memory stakeIDs) {
        return _addressToIds[user];
    }

    function getTotalStaked() public view returns(uint256 total) {
        total = T2K.balanceOf(address(this)) - total_allocated + total_owed;
        return total;
    }

    function getStake(uint256 id) public view returns(Stake memory userStake) {
        userStake.user = _idToAddress[id];
        userStake.amount = idToBalance[id];
        userStake.id = id;
        userStake.reward = getInterest(id);
        userStake.term = idToTerm[id];
        userStake.startTime = idToStartTime[id];
        userStake.unlockTime = idToStartTime[id] + idToTerm[id];
        return userStake;
    }

    function getAllUserStakes(address user) public view returns(Stake[] memory) {
        uint[] memory ids = _addressToIds[user];
        Stake memory current;
        Stake[] memory stakes = new Stake[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            current = getStake(ids[i]);
            stakes[i] = current;
        }
        return stakes;
    }

    function getInitialStake(uint256 id) external view returns(uint256) {
        return idToBalance[id];
    }

    function getInterest(uint256 id) public view returns(uint256) {
        return (idToBalance[id] * lockToInterest[idToTerm[id]]) / 10000;
    }

    function getCurrentInterest(uint256 id) external view returns(uint256) {
        uint256 total = getInterest(id);
        uint256 timeStaked = block.timestamp - idToStartTime[id];
        return (total * timeStaked) / idToTerm[id];
    }

    function getPenalty(uint256 id) public view returns(uint256) {
        return (idToBalance[id] * early_withdraw_penalty) / 10000;
    }

    function getOwed(uint256 amount, uint256 term) public view returns(uint256 owed) {
        owed = (amount * lockToInterest[term]) / 10000;
        return owed;
    }

    function stake(uint256 amount, uint256 term) external {
        require(amount > 250, "You must stake at least 250 T2K");
        // Make sure owed will not put us over total allocated
        uint256 owed = getOwed(amount, term);
        require(owed + total_owed <= total_allocated, "Not enough room for that stake");

        // When Adding to an existing locked stake
        // Should increase the lock time accordingly
        bool existing = false;
        uint256[] memory openStakes = _addressToIds[msg.sender]; // Get all user stakes
        for(uint256 i = 0; i < openStakes.length; i++) { // iterate
            if (idToTerm[openStakes[i]] == term) { // if they have a term of that length open
                existing = true;
                uint256 percent = (amount * 100000) / idToBalance[openStakes[i]];
                uint256 increase = (term * percent) / 100000;
                if (block.timestamp + term < idToStartTime[openStakes[i]] + term + increase) {
                    idToStartTime[openStakes[i]] = block.timestamp;
                }
                else {
                    idToStartTime[openStakes[i]] += increase;
                }
                idToBalance[openStakes[i]] += amount;
                break;
            }
        }

        if (!existing) {
            uint256 current = _stakeCounter.current();
            _idToAddress[current] = msg.sender;
            idToTerm[current] = term;
            idToStartTime[current] = block.timestamp;
            idToBalance[current] = amount;
            _addressToIds[msg.sender].push(current);
            _stakeCounter.increment();
        }
        total_owed += (amount * lockToInterest[term]) / 10000;
        require(T2K.transferFrom(msg.sender, address(this), amount), "Transfer Failed");
    }

    function withdraw(uint256 id) public {
        require(msg.sender == _idToAddress[id], "Not your stake");
        require(idToStartTime[id] + idToTerm[id] <= block.timestamp, "Your Stake Hasn't Vested Yet");
        uint256 owed = getInterest(id);
        uint256 stake_amount = idToBalance[id];

        delete _idToAddress[id];
        delete idToTerm[id];
        delete idToStartTime[id];
        delete idToBalance[id];

        for (uint256 i = 0; i < _addressToIds[msg.sender].length; i++) {
            if (_addressToIds[msg.sender][i] == id) {
                _addressToIds[msg.sender][i] = _addressToIds[msg.sender][_addressToIds[msg.sender].length - 1];
                _addressToIds[msg.sender].pop();
                break;
            }
        }
        require(T2K.transfer(msg.sender, owed + stake_amount), "Transfer Failed");
    }

    function emergencyWithdraw(uint256 id) external {
        require(msg.sender == _idToAddress[id], "Not your stake");
        if (idToStartTime[id] + idToTerm[id] <= block.timestamp) {
            withdraw(id);
        }
        else {
            uint256 stake_amount = idToBalance[id];
            uint256 penalty = getPenalty(id);
            uint256 owed = getInterest(id);

            delete _idToAddress[id];
            delete idToTerm[id];
            delete idToStartTime[id];
            delete idToBalance[id];

            for (uint256 i = 0; i < _addressToIds[msg.sender].length; i++) {
                if (_addressToIds[msg.sender][i] == id) {
                    _addressToIds[msg.sender][i] = _addressToIds[msg.sender][_addressToIds[msg.sender].length - 1];
                    _addressToIds[msg.sender].pop();
                    break;
                }
            }

            total_owed -= owed;
            total_allocated += penalty;

            require(T2K.transfer(msg.sender, stake_amount - penalty), "Transfer Failed");
        }
    }
}