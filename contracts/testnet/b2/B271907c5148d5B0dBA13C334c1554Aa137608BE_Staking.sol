// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

import "@openzeppelin/contracts/utils/Counters.sol";

contract Staking {
    using Counters for Counters.Counter;

    IBEP20 private stakingToken;

    constructor(address _stakingToken) {
        stakingToken = IBEP20(_stakingToken);
    }

    uint256 private _totalSupply;
    uint256 private lastUpdatedTime;

    enum TariffPlane {
        Days90,
        Days180,
        Days360
    }
    enum AmountPlane {
        Small,
        Medium,
        Large
    }

    struct Rate {
        address owner;
        uint256 amount;
        uint256 rate;
        uint256 expiredTime;
        bool isClaimed;
        TariffPlane daysPlane;
        AmountPlane amountPlane;
    }

    mapping(address => mapping(uint256 => Rate)) private _rates;
    mapping(address => Counters.Counter) private _ratesId;

    event Staked(
        address indexed owner,
        uint256 amount,
        uint256 rate,
        uint256 expiredTime
    );
    event Claimed(address indexed receiver, uint256 amount, uint256 id);

    mapping(address => uint256) private _balances;

    modifier amountNotA0(uint256 _amount) {
        require(_amount > 0, "The amount must be greater then 0");
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
            day == 90 || day == 180 || day == 360,
            "Choose correct plane: 90/180/360 days"
        );
        _;
    }

    function earned(uint256 id) public view returns (uint256) {
        return
            (_rates[msg.sender][id].amount / 100) * _rates[msg.sender][id].rate;
    }

    function stake(uint256 _amount, uint256 day)
        external
        amountNotA0(_amount)
        dayIsCorrect(day)
    {
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        AmountPlane sortedAmount = sortAmount(_amount);
        uint256 id = _ratesId[msg.sender].current();
        uint256 expiredTime = calculateTime(day);
        uint256 rate = checkPlane(sortedAmount, day);

        _rates[msg.sender][id] = Rate(
            msg.sender,
            _amount,
            rate,
            expiredTime,
            false,
            getDaysPlane(day),
            sortedAmount
        );

        _totalSupply += _amount;
        _balances[msg.sender] += _amount;

        _ratesId[msg.sender].increment();
        emit Staked(msg.sender, _amount, rate, expiredTime);
    }

    function claim(uint256 id) external checkTime(id) {
        require(!_rates[msg.sender][id].isClaimed, "Reward already claimed!");

        _rates[msg.sender][id].isClaimed = true;

        uint256 reward = earned(id);
        stakingToken.transfer(msg.sender, reward);
        emit Claimed(msg.sender, reward, id);
    }
    function sortAmount(uint256 _amount) internal pure returns (AmountPlane) {
        if (_amount < 100_000) {
            return AmountPlane.Small;
        } else if (_amount < 1_000_000) {
            return AmountPlane.Medium;
        }
        return AmountPlane.Large;
    }

    function checkSmallRate(AmountPlane plane) internal pure returns (uint256) {
        if (plane == AmountPlane.Small) {
            return 8;
        } else if (plane == AmountPlane.Medium) {
            return 9;
        }
        return 10;
    }

    function checkMediumRate(AmountPlane plane)
        internal
        pure
        returns (uint256)
    {
        if (plane == AmountPlane.Small) {
            return 9;
        } else if (plane == AmountPlane.Medium) {
            return 10;
        }
        return 11;
    }

    function checkLargeRate(AmountPlane plane) internal pure returns (uint256) {
        if (plane == AmountPlane.Small) {
            return 10;
        } else if (plane == AmountPlane.Medium) {
            return 11;
        }
        return 12;
    }

    function checkPlane(AmountPlane plane, uint256 day)
        internal
        pure
        returns (uint256)
    {
        if (day == 90) {
            return checkSmallRate(plane);
        } else if (day == 180) {
            return checkMediumRate(plane);
        }
        return checkLargeRate(plane);
    }

    function getDaysPlane(uint256 day) internal pure returns (TariffPlane) {
        if (day == 90) {
            return TariffPlane.Days90;
        } else if (day == 180) {
            return TariffPlane.Days180;
        }
        return TariffPlane.Days360;
    }

    function calculateTime(uint256 day) internal view returns (uint256) {
        return (block.timestamp + day * 1 * 1);
    }

    function getStakingToken() external view returns (IBEP20) {
        return stakingToken;
    }

    function getTotalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function allPositionsBalanceOf(address _account)
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

    function timeUpdate() public {
        lastUpdatedTime = block.timestamp;
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