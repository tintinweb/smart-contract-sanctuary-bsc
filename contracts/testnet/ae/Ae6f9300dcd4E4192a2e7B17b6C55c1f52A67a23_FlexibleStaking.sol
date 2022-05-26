// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token/BEP20/IBEP20.sol";
import "./ILockedFlexibleStakingFactory.sol";
import "./utils/ReentrancyGuardForFlexibleStaking.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FlexibleStaking is ReentrancyGuardForFlexibleStaking {
    // State Variables
    IBEP20 s_rewardToken;
    IBEP20 s_stakingToken;
    address s_creator;
    ILockedFlexibleStakingFactory s_factory;
    uint256 s_duration; // in seconds
    uint256 s_rewardPercentage;
    address s_nftAddress;
    uint256 s_minimumStaking;
    uint256 s_maximumStaking;
    bool s_isSoldOut;
    uint256 s_totalSupply;
    uint256 s_totalRewards;
    uint256 s_participants;
    uint256 s_allocatedRewards;
    uint256 s_sold;
    uint256 s_creatorClaimedRewards;
    uint256 s_endPoolDate;

    mapping(address => uint256) private s_balances;

    enum Status {
        LOCKED,
        REDEEMABLE,
        REDEEMED
    }

    struct Stake {
        uint256 amount;
        uint256 dateStaked;
        uint256 dateRedeemed;
        Status status;
    }

    struct Total {
        uint256 allocatedRewards;
        uint256 totalRewards;
        uint256 solds;
        uint256 creatorClaimedRewards;
    }

    Stake[] s_stakes;
    mapping(address => bool) public s_hasStake;
    mapping(uint256 => address) s_stakeToOwner;
    mapping(address => uint256) private s_ownerStakeCount;

    function init(
        address _creator,
        ILockedFlexibleStakingFactory _factory,
        IBEP20 _rewardToken,
        IBEP20 _stakingToken,
        uint256 _duration,
        uint256 _rewardPercentage,
        address _nftAddress,
        uint256 _minimumStaking,
        uint256 _maximumStaking,
        uint256 _totalSupply,
        uint256 _totalRewards
    ) external {
        // require(_duration >= 8 days, 'Duration must be greater than or equal to 8 days');
        require(
            _duration <= 365 days,
            "Duration must be less than or equal to 365 days"
        );
        s_creator = _creator;
        s_factory = _factory;
        s_rewardToken = _rewardToken;
        s_stakingToken = _stakingToken;
        s_duration = _duration;
        s_rewardPercentage = _rewardPercentage;
        s_nftAddress = _nftAddress;
        s_minimumStaking = _minimumStaking;
        s_maximumStaking = _maximumStaking;
        s_isSoldOut = false;
        s_totalSupply = _totalSupply;
        s_totalRewards = _totalRewards;
    }

    // Views
    function balanceOf(address account) external view returns (uint256) {
        return s_balances[account];
    }

    function getStakingInfo()
        external
        view
        returns (
            address creator,
            IBEP20 rewardToken,
            IBEP20 stakingToken,
            uint256 duration,
            uint256 rewardPercentage,
            uint256 minimumStaking,
            uint256 maximumStaking,
            bool isSoldOut,
            uint256 totalSupply,
            uint256 participants,
            Total memory total // Remove
        )
    {

        Total memory s_total;
        s_total.allocatedRewards = s_allocatedRewards;
        s_total.totalRewards = s_totalRewards;
        s_total.solds = s_sold;
        s_total.creatorClaimedRewards = s_creatorClaimedRewards;

        return (
            s_creator,
            s_rewardToken,
            s_stakingToken,
            s_duration,
            s_rewardPercentage,
            s_minimumStaking,
            s_maximumStaking,
            s_isSoldOut,
            s_totalSupply,
            s_participants,
            s_total
        );
    }

    function stakeByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](s_ownerStakeCount[_owner]);
        uint256 counter = 0;
        for (uint256 i = 0; i < s_stakes.length; i++) {
            if (s_stakeToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function stakeByIndex(uint256 _index)
        public
        view
        returns (
            uint256 amount,
            uint256 dateStaked,
            uint256 dateRedeemed,
            uint256 rewards,
            uint256 rewardsByFinalDuration,
            Status status
        )
    {
        Stake storage stake = s_stakes[_index];

        if (s_endPoolDate == 0) {
            if (stake.dateRedeemed > 0) {
                status = Status.REDEEMED;
                rewards = _calculateAccruedReward(stake.amount, stake.dateStaked, stake.dateRedeemed);
            } else if (stake.dateStaked + s_duration > block.timestamp) {
                status = Status.LOCKED;
                rewards = _calculateAccruedReward(stake.amount, stake.dateStaked, block.timestamp);
            } else if (stake.dateRedeemed == 0) {
                rewards = _calculateAccruedReward(stake.amount, stake.dateStaked, block.timestamp);
                status = Status.REDEEMABLE;
            }
        } else {
            if (stake.dateRedeemed > 0) {
                status = Status.REDEEMED;
                rewards = _calculateAccruedReward(stake.amount, stake.dateStaked, s_endPoolDate);
            } else if (stake.dateStaked + s_duration > block.timestamp) {
                status = Status.LOCKED;
                rewards = _calculateAccruedReward(stake.amount, stake.dateStaked, s_endPoolDate);
            } else if (stake.dateRedeemed == 0) {
                rewards = _calculateAccruedReward(stake.amount, stake.dateStaked, s_endPoolDate);
                status = Status.REDEEMABLE;
            }
        }

        rewardsByFinalDuration = _calculateReward(stake.amount);

        return (
            stake.amount,
            stake.dateStaked,
            stake.dateRedeemed,
            rewards,
            rewardsByFinalDuration,
            status
        );
    }

    function createStake(uint256 _amount) public {
        require(s_hasStake[msg.sender] == false, "Caller has stake already");
        require(
            _amount + s_balances[msg.sender] <= s_maximumStaking,
            "Exceeds maximum staking per address"
        );
        require(
            _amount >= s_minimumStaking,
            "Amount must be greater than or equal to minimum staking"
        );
        require(
            _amount <= s_maximumStaking,
            "Amount must be less than or equal to maximum staking"
        );
        require(
            s_maximumStaking > s_minimumStaking,
            "Maximum Staking must be grater than minimum staking"
        );
        require(s_sold < s_totalSupply, "Staking is sold out");
        require(_amount + s_sold <= s_totalSupply, "Insufficient supply");

        if (s_sold + _amount == s_totalSupply) {
         s_isSoldOut = true;   
        }

        s_sold += _amount;
        s_balances[msg.sender] += _amount;

        Stake memory newStake;
        newStake.amount = _amount;

        //Reason for testing this usign this specicifc days is because of Accrued functionality,
        //when the current date of block is morethan the expected duration, it will cause error on computation

        //less 3 days for testing
        //newStake.dateStaked = block.timestamp - 259200;
        //less 5 days for testing
        //newStake.dateStaked = block.timestamp - 432000;

        //less 7 days for testing
        //newStake.dateStaked = block.timestamp - 604800;

        //equal 8 days for testing
        //newStake.dateStaked = block.timestamp - 691200;

        //morethan 8 days for testing
        //9 days
        //newStake.dateStaked = block.timestamp - 777600;

        newStake.dateStaked = block.timestamp;
        newStake.status = Status.LOCKED;
        s_stakes.push(newStake);
        uint256 stakeIndex = s_stakes.length - 1;

        //s_allocatedRewards += _calculateReward(_amount);
        s_hasStake[msg.sender] = true;
        s_stakeToOwner[stakeIndex] = msg.sender;
        s_ownerStakeCount[msg.sender]++;
        s_participants++;
        s_factory.setHasStake(msg.sender);
        s_stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _calculateReward(uint256 _amountStaked)
        internal
        view
        returns (uint256 reward)
    {
        uint256 dailyYield = (s_rewardPercentage / 100) * _amountStaked / 365;
        // reward = (dailyYield * (s_duration / 1 minutes)) / 1e18;
        reward = (dailyYield * (s_duration / 1 minutes)) / 1e18; // for testin only
    }

    function quickRedeem(uint256 _stakeIndex) public nonReentrant {
        require(s_stakeToOwner[_stakeIndex] == msg.sender);
        Stake storage stake = s_stakes[_stakeIndex];
        uint256 amount = stake.amount;

        require(_calculateAccruedReward(amount, stake.dateStaked, block.timestamp) > 0, 'Staker have zero reward');

        uint claimable = _calculateReward(amount) - _calculateAccruedReward(amount, stake.dateStaked, block.timestamp);

        if (claimable > 0) {
            s_isSoldOut = false;   
        }

        s_allocatedRewards += _calculateAccruedReward(amount, stake.dateStaked, block.timestamp);
        s_balances[msg.sender] -= amount;
        s_hasStake[msg.sender] = false;
        s_stakingToken.transfer(msg.sender, amount);
        s_rewardToken.transfer(msg.sender, _calculateAccruedReward(amount, stake.dateStaked, block.timestamp));
        stake.dateRedeemed = block.timestamp;
    }

    function _calculateAccruedReward(uint256 _amountStaked, uint256 _dateStaked, uint256 _dateRedeemed) internal view returns (uint256 reward) {
        uint256 dailyYield = (s_rewardPercentage / 100) * _amountStaked / 365;

        uint256 duration = 0;

        if (_dateRedeemed >= _dateStaked + s_duration) {
            reward = (dailyYield * (s_duration / 1 minutes)) / 1e18; // for testin only
        } else {
            duration = _dateRedeemed - _dateStaked;

            if (duration > s_duration)
                reward = (dailyYield * (s_duration / 1 minutes)) / 1e18; // for testin only
            else
                reward = (dailyYield * (duration / 1 minutes)) / 1e18; // for testin only  
        }
    }

    //for testing only. for getting durationg between dates by days or minutes
    function _checkAccruedDurations(uint256 _amountStaked, uint256 _dateStaked, uint256 _dateRedeemed) internal view returns (uint256) {
        uint256 dailyYield = (s_rewardPercentage / 100) * _amountStaked / 365;

        uint256 duration = 0;

        if (_dateRedeemed >= _dateStaked + s_duration) {
            duration = s_duration;
            //reward = (dailyYield * (s_duration / 1 minutes)) / 1e18; // for testin only
        } else {
            

            if (duration > s_duration)
            duration = s_duration;
                //reward = (dailyYield * (s_duration / 1 minutes)) / 1e18; // for testin only
            else {
                duration = _dateRedeemed - _dateStaked;
                //reward = (dailyYield * (duration / 1 minutes)) / 1e18; // for testin only  
            }
        }

        return duration;
    }

    function getStakes() external view returns (Stake[] memory)
    {
        return s_stakes;
    }

    function endStake() external nonReentrant {
        require(s_isSoldOut == false, "Pool has ended already");
        require(msg.sender == s_creator, "Caller is not a creator");
        uint256 unAllocatedRewards = (s_totalRewards - s_allocatedRewards) - getUnallocatedAcrruedRewards();

        s_rewardToken.transfer(s_creator, unAllocatedRewards);
        s_isSoldOut = true;
        s_endPoolDate = block.timestamp;
        s_creatorClaimedRewards = unAllocatedRewards;
        s_allocatedRewards += unAllocatedRewards;
    }

    function getUnallocatedAcrruedRewards() internal view returns (uint256 unallocatedAcrruedRewards) {
        for (uint256 i = 0; i < s_stakes.length; i++) {
            if (s_stakes[i].dateRedeemed == 0) {
                (,,,uint256 rewards,uint256 rewardsByFinalDuration,) = stakeByIndex(i);
                unallocatedAcrruedRewards += rewardsByFinalDuration - rewards;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockedFlexibleStakingFactory {
    function setHasStake(address _staker) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuardForFlexibleStaking {
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
     * by making the `nonReentrant` function external, and make it call a
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}