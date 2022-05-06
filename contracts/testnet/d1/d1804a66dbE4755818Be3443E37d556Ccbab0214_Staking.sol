// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StakingReserve.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Staking is Ownable {
    using Counters for Counters.Counter;
    StakingReserve public immutable reserve;
    IERC20 public immutable gold;
    event StakeUpdate(
        address account,
        uint256 packageId,
        uint256 amount,
        uint256 totalProfit
    );
    event StakeReleased(
        address account,
        uint256 packageId,
        uint256 amount,
        uint256 totalProfit
    );
    struct StakePackage {
        uint256 rate;
        uint256 decimal;
        uint256 minStaking;
        uint256 lockTime;
        bool isOffline;
    }
    struct StakingInfo {
        uint256 startTime;
        uint256 timePoint;
        uint256 amount;
        uint256 totalProfit;
    }
    Counters.Counter private _stakePackageCount;
    mapping(uint256 => StakePackage) public stakePackages;
    mapping(address => mapping(uint256 => StakingInfo)) public stakes;

    /**
     * @dev Initialize
     * @notice This is the initialize function, run on deploy event
     * @param tokenAddr_ address of main token
     * @param reserveAddress_ address of reserve contract
     */
    constructor(address tokenAddr_, address reserveAddress_) {
        gold = IERC20(tokenAddr_);
        reserve = StakingReserve(reserveAddress_);
    }

    /**
     * @dev Add new staking package
     * @notice New package will be added with an id
     */
    function addStakePackage(
        uint256 rate_,
        uint256 decimal_,
        uint256 minStaking_,
        uint256 lockTime_
    ) external onlyOwner {
        require(rate_ >= 0, "Staking: rate_ invalid");
        require(decimal_ >= 0, "Staking: decimal_ invalid");
        require(minStaking_ > 0, "Staking: minStaking_ invalid");
        require(lockTime_ >= 0, "Staking: lockTime_ invalid");

        _stakePackageCount.increment();
        uint256 _stakePackageId = _stakePackageCount.current();
        stakePackages[_stakePackageId] = StakePackage({
                rate: rate_,
                decimal: decimal_,
                minStaking: minStaking_,
                lockTime: lockTime_,
                isOffline: false
            });
    }

    /**
     * @dev Remove an stake package
     * @notice A stake package with packageId will be set to offline
     * so none of new staker can stake to an offine stake package
     */
    function removeStakePackage(uint256 packageId_) external onlyOwner {
        require(stakePackages[packageId_].minStaking > 0, "Staking: package is not exists");
        require(stakePackages[packageId_].isOffline == false, "Staking: package is offline already");
        stakePackages[packageId_].isOffline = true;
    }

    /**
     * @dev User stake amount of gold to stakes[address][packageId]
     * @notice if is there any amount of gold change in the stake package,
     * calculate the profit and add it to total Profit,
     * otherwise just add completely new stake. 
     */
    function stake(uint256 amount_, uint256 packageId_) external {
        require(amount_ > 0, "Staking: Amount must be greater than 0");
        require(stakePackages[packageId_].minStaking > 0, "Staking: package not exists");
        require(stakePackages[packageId_].minStaking <= amount_, "Staking: amount invalid");
        require(stakePackages[packageId_].isOffline == false, "Staking: package is offline");
        uint256 allowance = gold.allowance(msg.sender, address(this));
        require(allowance >= amount_, "Staking: allowance invalid");
        gold.transferFrom(
            address(msg.sender),
            address(reserve),
            amount_
        );

        StakingInfo storage stake = stakes[msg.sender][packageId_];
        if (stake.amount > 0) {
            stake.totalProfit = calculateProfit(packageId_);
        } else {
            stake.startTime = block.timestamp;
        }
        stake.timePoint = block.timestamp;
        stake.amount = stake.amount + amount_;

        emit StakeUpdate(msg.sender, packageId_, amount_, stake.totalProfit);
    }
    /**
     * @dev Take out all the stake amount and profit of account's stake from reserve contract
     */
    function unStake(uint256 packageId_) external {
        require(stakePackages[packageId_].minStaking > 0, "Staking: package not exists");
        require(stakePackages[packageId_].lockTime < block.timestamp, "Staking: package is still locked");
        StakingInfo memory stake = stakes[msg.sender][packageId_];
        require(stake.amount > 0, "Staking: user amount must be greater than zero");
        uint256 totalProfit = calculateProfit(packageId_);
        uint256 amount = stake.amount;
        uint256 total = totalProfit + stake.amount;
        uint256 reserveBalance = reserve.getBalanceOfReserve();
        require(reserveBalance >= total, "Staking: reserveBalance invalid");
        delete stakes[msg.sender][packageId_];
        reserve.distributeGold(
            address(msg.sender),
            total
        );

        emit StakeReleased(msg.sender, packageId_, amount, totalProfit);
    }
    /**
     * @dev calculate current profit of an package of user known packageId
     */

    function calculateProfit(uint256 packageId_)
        public
        view
        returns (uint256)
    {
        require(stakePackages[packageId_].minStaking > 0, "Staking: package not exists");
        StakingInfo memory stake = stakes[msg.sender][packageId_];
        if (stake.amount == 0) {
            return 0;
        }
        uint256 aprOfPackage = getAprOfPackage(packageId_);
        uint256 numberOfDays = (block.timestamp - stake.timePoint) / (60 * 60 * 24);
        return (stake.amount * (aprOfPackage / 365) * numberOfDays) / 1e18 + stake.totalProfit;
    }

    function getAprOfPackage(uint256 packageId_)
        public
        view
        returns (uint256)
    {
        StakePackage memory stakePackage = stakePackages[packageId_];
        uint256 rate = (stakePackage.rate * 1e18) / 10 ** (stakePackage.decimal + 2);
        return rate;
    }

    function getStakePackage(uint256 packageId_)
        public
        view
        returns (StakePackage memory)
    {
        return stakePackages[packageId_];
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
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Staking reserve is a contract that holds tokens from staking actions and allows
//  the staking contract to take the amount to interest their profit

contract StakingReserve is Ownable {
    IERC20 public mainToken;
    address public stakeAddress;

    constructor(address _mainToken) {
        mainToken = IERC20(_mainToken);
    }

    function getBalanceOfReserve() public view returns (uint256) {
        return mainToken.balanceOf(address(this));
    }

    function setStakeAdress(address _stakeAddress) external onlyOwner {
        require(_stakeAddress != address(0), "StakingReserve: _stakeAddress is zero address");
        stakeAddress = _stakeAddress;
    }
    function distributeGold(address _recipient, uint256 _amount) external {
        require(msg.sender == stakeAddress, "StakingReserve: stakeAddress invalid");
        mainToken.transfer(_recipient, _amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

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