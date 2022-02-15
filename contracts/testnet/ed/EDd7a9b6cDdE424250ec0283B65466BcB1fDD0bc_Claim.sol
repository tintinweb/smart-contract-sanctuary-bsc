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
pragma solidity ^0.8.0;

/**
 * @title Claim
 * @author gotbit
 */

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Claim is Ownable {
    struct Round {
        uint256 cliff;
        uint256 constReward;
        uint256 linearPeriod;
    }

    struct Allocation {
        uint256 seed;
        uint256 strategic;
        uint256 private_;
    }

    struct User {
        uint256 claimed;
        Allocation allocation;
        uint256 claimTimestamp;
    }

    uint256 public constant MONTH = 30 days;
    uint256 public constant MINUTE = 1 minutes;
    uint256 public constant CONST_PERIOD = 2 * 24 hours;
    uint256 public constant CONST_RELAX = MONTH;

    IERC20 public token;

    bool public isStarted;
    uint256 public startTimestamp;

    mapping(string => Round) rounds;
    mapping(address => User) public users;

    event Started(uint256 timestamp, address who);
    event Claimed(address indexed to, uint256 value);
    event SettedAllocation(
        address indexed to,
        uint256 seed,
        uint256 strategic,
        uint256 private_
    );

    constructor(address owner_, address token_) {
        transferOwnership(owner_);
        token = IERC20(token_);

        rounds['seed'] = Round(1, 10, 13);
        rounds['strategic'] = Round(0, 15, 9);
        rounds['private'] = Round(0, 20, 7);
    }

    function getDate()
        public
        view
        returns (
            uint256 d,
            uint256 m,
            uint256 y
        )
    {
        uint256 s = block.timestamp;
        uint256 z = s / 86400 + 719468;
        uint256 era = (z >= 0 ? z : z - 146096) / 146097;

        uint256 doe = uint256((z - era * 146097));
        uint256 yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
        y = uint256(yoe) + era * 400;
        uint256 doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        uint256 mp = (5 * doy + 2) / 153;
        d = doy - (153 * mp + 2) / 5 + 1;

        if (mp < 10) {
            m = mp + 3;
        } else {
            m = mp - 9;
        }

        if (m <= 2) {
            y += 1;
        }
    }

    function start() external onlyOwner returns (bool status) {
        require(!isStarted, 'The claim has already begun');

        isStarted = true;
        startTimestamp = block.timestamp;

        emit Started(startTimestamp, msg.sender);

        return true;
    }

    function claim() external returns (bool status) {
        require(isStarted, 'The claim has not started yet');

        uint256 value_ = calculateUnclaimed(msg.sender);

        require(value_ > 0, 'You dont have DES to harvest');
        require(
            token.balanceOf(address(this)) >= value_,
            'Not enough tokens on contract'
        );

        users[msg.sender].claimed += value_;
        users[msg.sender].claimTimestamp = block.timestamp;

        require(token.transfer(msg.sender, value_), 'Transfer issues');

        emit Claimed(msg.sender, value_);
        return true;
    }

    function getAllocation(address user_) external view returns (uint256 sum) {
        return
            (users[user_].allocation.seed +
                users[user_].allocation.strategic +
                users[user_].allocation.private_) / 2;
    }

    function calculateUnclaimed(address user_) public view returns (uint256 unclaimed) {
        require(isStarted, 'The claim has not started yet');

        uint256 resultSeed_ = calculateRound('seed', users[user_].allocation.seed);
        uint256 resultStrategic_ = calculateRound(
            'strategic',
            users[user_].allocation.strategic
        );
        uint256 resultPrivate_ = calculateRound(
            'private',
            users[user_].allocation.private_
        );

        return
            (resultSeed_ + resultStrategic_ + resultPrivate_) / 2 - users[user_].claimed;
    }

    function calculateRound(string memory roundName_, uint256 allocation_)
        internal
        view
        returns (uint256 unclaimedFromRound)
    {
        require(isStarted, 'The claim has not started yet');

        Round memory round_ = rounds[roundName_];

        uint256 timePassed_ = block.timestamp - startTimestamp;
        uint256 bank_ = allocation_;

        if (timePassed_ < (round_.cliff * MONTH)) return 0;

        timePassed_ -= (round_.cliff * MONTH);
        uint256 constReward_ = (bank_ * round_.constReward) / 100;
        if (round_.cliff == 0) {
            if (timePassed_ < CONST_PERIOD / 2) return constReward_ / 2;
        }

        if (timePassed_ < CONST_RELAX) return constReward_;
        timePassed_ -= CONST_RELAX;

        uint256 minutesPassed_ = timePassed_ / MINUTE;
        uint256 leftInBank_ = bank_ - constReward_;
        return
            (leftInBank_ * MINUTE * minutesPassed_) /
            (MONTH * round_.linearPeriod) +
            constReward_;
    }

    function setAllocations(
        address[] memory whos_,
        uint256[] memory seeds_,
        uint256[] memory strategics_,
        uint256[] memory privates_
    ) public onlyOwner {
        uint256 len = whos_.length;
        require(seeds_.length == len, 'Different length');
        require(strategics_.length == len, 'Different length');
        require(privates_.length == len, 'Different length');

        for (uint256 i = 0; i < len; i++) {
            address who_ = whos_[i];

            if (users[who_].claimed == 0) {
                uint256 seed_ = seeds_[i];
                uint256 strategic_ = strategics_[i];
                uint256 private_ = privates_[i];

                users[who_] = User({
                    claimed: users[who_].claimed,
                    allocation: Allocation(seed_, strategic_, private_),
                    claimTimestamp: users[who_].claimTimestamp
                });
                emit SettedAllocation(who_, seed_, strategic_, private_);
            }
        }
    }
}