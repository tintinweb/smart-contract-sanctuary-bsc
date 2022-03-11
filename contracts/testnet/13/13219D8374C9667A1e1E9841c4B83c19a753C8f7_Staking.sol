// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockedStakingFactory {
    function setHasStake(address _staker) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './token/BEP20/IBEP20.sol';
import './ILockedStakingFactory.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {

    // State Variables
    IBEP20 s_rewardToken;
    IBEP20 s_stakingToken;
    address s_creator;
    ILockedStakingFactory s_factory;
    uint s_duration; // in seconds
    uint s_rewardPercentage;
    address s_nftAddress;
    uint s_minimumStaking;
    uint s_maximumStaking;
    bool s_isSoldOut;
    uint s_totalSupply;
    uint s_totalRewards;
    uint s_participants;
    uint s_allocatedRewards;
    uint s_sold;
    mapping(address => uint) private s_balances;

    enum Status {
        LOCKED,
        REDEEMABLE,
        REDEEMED
    }

    struct Stake {
        uint amount;
        uint dateStaked;
        uint dateRedeemed;
        Status status;
    }

    Stake[] s_stakes;
    mapping(address => bool) public s_hasStake;
    mapping(uint => address) s_stakeToOwner;
    mapping(address => uint) private s_ownerStakeCount;

    function init(
        address _creator,
        ILockedStakingFactory _factory,
        IBEP20 _rewardToken,
        IBEP20 _stakingToken,
        uint _duration,
        uint _rewardPercentage,
        address _nftAddress,
        uint _minimumStaking,
        uint _maximumStaking,
        uint _totalSupply,
        uint _totalRewards
    ) external {
        // require(_duration >= 8 days, 'Duration must be greater than or equal to 8 days');
        require(_duration <= 365 days, 'Duration must be less than or equal to 365 days');
        s_creator = _creator;
        s_factory = _factory;
        s_rewardToken = _rewardToken;
        s_stakingToken= _stakingToken;
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

    function getStakingInfo() external view returns (
        address creator,
        IBEP20 rewardToken,
        IBEP20 stakingToken,
        uint duration,
        uint rewardPercentage,
        uint minimumStaking,
        uint maximumStaking,
        bool isSoldOut,
        uint totalSupply,
        uint participants,
        uint allocatedRewards,
        uint totalRewards
    ) {
        if (s_isSoldOut) {
            isSoldOut = true;
        } else {
            isSoldOut = s_sold == s_totalSupply ? true : false;
        }
        return (
            s_creator,
            s_rewardToken,
            s_stakingToken,
            s_duration,
            s_rewardPercentage,
            s_minimumStaking,
            s_maximumStaking,
            isSoldOut,
            s_totalSupply,
            s_participants,
            s_allocatedRewards,
            s_totalRewards
        );
    }

    function stakeByOwner(address _owner) external view returns (uint[] memory) {
        uint[] memory result = new uint[](s_ownerStakeCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < s_stakes.length; i++) {
            if (s_stakeToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function stakeByIndex(uint _index) public view returns (
        uint amount,
        uint dateStaked,
        uint dateRedeemed,
        uint rewards,
        Status status
    ) 
    {
        Stake storage stake = s_stakes[_index];

        if (stake.dateStaked + s_duration > block.timestamp) {
            status = Status.LOCKED;
        } else {
            if (stake.dateRedeemed == 0) { status = Status.REDEEMABLE; } 
            else { status = Status.REDEEMED; }
        }

        return(
            stake.amount,
            stake.dateStaked,
            stake.dateRedeemed,
            _calculateReward(stake.amount),
            status
        );
    }

    function createStake(uint256 _amount) public {
        require(s_hasStake[msg.sender] == false, 'Caller has stake already');
        require(_amount + s_balances[msg.sender] <= s_maximumStaking, 'Exceeds maximum staking per address');
        require(_amount >= s_minimumStaking, 'Amount must be greater than or equal to minimum staking');
        require(_amount <= s_maximumStaking, 'Amount must be less than or equal to maximum staking');
        require(s_maximumStaking > s_minimumStaking, 'Maximum Staking must be grater than minimum staking');
        require(s_sold < s_totalSupply, 'Staking is sold out');
        require(_amount + s_sold <= s_totalSupply, 'Insufficient supply');

        s_sold += _amount;
        s_balances[msg.sender] += _amount;

        Stake memory newStake;
        newStake.amount = _amount;
        newStake.dateStaked = block.timestamp;
        newStake.status = Status.LOCKED;
        s_stakes.push(newStake);
        uint stakeIndex = s_stakes.length - 1;

        s_allocatedRewards += _calculateReward(_amount);
        s_hasStake[msg.sender] = true;
        s_stakeToOwner[stakeIndex] = msg.sender;
        s_ownerStakeCount[msg.sender]++;
        s_participants++;
        s_factory.setHasStake(msg.sender);
        s_stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _calculateReward(uint _amountStaked) internal view returns (uint256 reward) {
        uint dailyYield = ((s_rewardPercentage / 100) / 365) * _amountStaked;
        // reward = (dailyYield * (s_duration / 1 minutes)) / 1e18;
        reward = (dailyYield * (s_duration / 1 minutes)) / 1e18; // for testin only
    }

    function redeem(uint _stakeIndex) public nonReentrant {
        require(s_stakeToOwner[_stakeIndex] == msg.sender);
        Stake storage stake = s_stakes[_stakeIndex];
        require(block.timestamp >= stake.dateStaked + s_duration);
        uint amount = stake.amount;
        // s_totalSupply -= amount;
        s_balances[msg.sender] -= amount;
        s_hasStake[msg.sender] = false;
        s_stakingToken.transfer(msg.sender, amount);
        s_rewardToken.transfer(msg.sender, _calculateReward(amount));
        stake.dateRedeemed = block.timestamp;
    }

    function endStake() external nonReentrant {
        bool isSoldOut = s_sold == s_totalSupply ? true : false;
        require(isSoldOut == false, 'Pool has ended already');
        require(s_isSoldOut == false, 'Pool has ended already');
        require(msg.sender == s_creator, 'Caller is not a creator');
        uint unallocatedReward = s_totalRewards - s_allocatedRewards;
        s_rewardToken.transfer(s_creator, unallocatedReward);
        s_isSoldOut = true;
    }
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

    constructor () {
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