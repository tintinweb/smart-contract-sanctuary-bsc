// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./IBEP20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    using Counters for Counters.Counter;

    IBEP20 private stakingToken;

    constructor(address _stakingToken) {
        stakingToken = IBEP20(_stakingToken);
    }

    uint256 private _shouldPaidAmount;
    uint256 private lastUpdatedTime;

    enum TariffPlane {
        Days90,
        Days180,
        Days360,
        Days720
    }

    struct Rate {
        address owner;
        uint256 amount;
        uint256 rate;
        uint256 expiredTime;
        bool isClaimed;
        TariffPlane daysPlane;
    }

    mapping(address => mapping(uint256 => Rate)) private _rates;
    mapping(address => Counters.Counter) private _ratesId;
    mapping(address => uint256) private _balances;

    event Staked(
        uint256 id,
        address indexed owner,
        uint256 amount,
        uint256 rate,
        uint256 expiredTime
    );
    event Claimed(address indexed receiver, uint256 amount, uint256 id);
    event TokenAddressChanged(address oldAddress, address changeAddress);

    modifier amountNot0(uint256 _amount) {
        require(_amount > 0, "The amount must be greater than 0");
        _;
    }

    modifier checkTime(uint256 id) {
        timeUpdate();
        require(
            stakingEndTime(msg.sender, id) < lastUpdatedTime,
            "Token lock time has not yet expired or Id isn't correct"
        );
        _;
    }

    modifier dayIsCorrect(uint256 day) {
        require(
            day == 90 || day == 180 || day == 360 || day == 720,
            "Choose correct plane: 90/180/360/720 days"
        );
        _;
    }

    function earned(uint256 id) private view returns (uint256) {
        return
            (_rates[msg.sender][id].amount / 1000) *
            _rates[msg.sender][id].rate;
    }

    function stake(uint256 _amount, uint256 day)
        external
        amountNot0(_amount)
        dayIsCorrect(day)
    {
        uint256 id = _ratesId[msg.sender].current();
        uint256 expiredTime = calculateTime(day);
        uint256 rate = checkPlane(day);

        uint256 totalSupply = stakingToken.balanceOf(address(this));

        require(
            (_amount * rate) / 1000 <= totalSupply - _shouldPaidAmount,
            "Fund is not enough."
        );

        _rates[msg.sender][id] = Rate(
            msg.sender,
            _amount,
            rate,
            expiredTime,
            false,
            getDaysPlane(day)
        );

        uint256 reward = (1 + rate / 1000) * _amount;
        _shouldPaidAmount += reward;
        _balances[msg.sender] += reward;
        _ratesId[msg.sender].increment();

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit Staked(id, msg.sender, _amount, rate, expiredTime);
    }

    function claim(uint256 id) external checkTime(id) {
        require(!_rates[msg.sender][id].isClaimed, "Reward already claimed!");

        _rates[msg.sender][id].isClaimed = true;

        uint256 amount = _rates[msg.sender][id].amount;
        uint256 reward = earned(id) + amount;

        _shouldPaidAmount -= reward;
        _balances[msg.sender] -= reward;

        stakingToken.transfer(msg.sender, reward);
        emit Claimed(msg.sender, reward, id);
    }

    function checkPlane(uint256 day) internal pure returns (uint256) {
        if (day == 90) {
            return 25;
        } else if (day == 180) {
            return 50;
        } else if (day == 360) {
            return 150;
        }
        return 200;
    }

    function getDaysPlane(uint256 day) internal pure returns (TariffPlane) {
        if (day == 90) {
            return TariffPlane.Days90;
        } else if (day == 180) {
            return TariffPlane.Days180;
        } else if (day == 360) {
            return TariffPlane.Days360;
        }
        return TariffPlane.Days720;
    }

    function calculateTime(uint256 day) internal view returns (uint256) {
        return (block.timestamp + day * 24 * 3600);
    }

    function getStakingToken() external view returns (IBEP20) {
        return stakingToken;
    }

    function getTotalSupply() external view returns (uint256) {
        return stakingToken.balanceOf(address(this));
    }

    function allTokensBalanceOf(address _account)
        external
        view
        returns (uint256)
    {
        return _balances[_account];
    }

    function stakingEndTime(address _account, uint256 id)
        public
        view
        returns (uint256)
    {
        return _rates[_account][id].expiredTime;
    }

    function getLastUpdatedTime() external view returns (uint256) {
        return lastUpdatedTime;
    }

    function timeUpdate() internal {
        lastUpdatedTime = block.timestamp;
    }

    function setTokenAddress(address changeAddress) external onlyOwner {
        emit TokenAddressChanged(address(stakingToken), changeAddress);
        stakingToken = IBEP20(changeAddress);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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