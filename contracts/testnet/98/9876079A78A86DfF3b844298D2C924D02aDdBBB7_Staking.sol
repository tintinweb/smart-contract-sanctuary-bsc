/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.8.11;

interface IERC20 {

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract Declaration {

    uint40 constant ONE_DAY = 60 * 60 * 24;
    uint40 constant ONE_YEAR = ONE_DAY * 365;

    IERC20 public immutable SSS;

    constructor(
        address _immutableSSS
    ) {
        SSS = IERC20(_immutableSSS);
    }

}

/**
 * @dev Provides the msg.sender in the current execution context.
 */
abstract contract ContextSimple {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
abstract contract OwnableSafe is ContextSimple {
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

contract Staking is OwnableSafe, Declaration {

    struct Stake {
        uint256 amount;
        uint40 startTimestamp;
        uint40 maturityTimestamp;
    }

    mapping(address => Stake[]) public allStakes;

    mapping(address => uint256) public stakeCount;

    mapping(address => uint256) public stakerID;

    address[] stakers;

    address public stakingPool;

    uint256 public cliff;

    uint256 private constant MAX = ~uint256(0);

    event StakeBegan (
        uint256 indexed stakeID,
        address indexed staker,
        uint256 amount,
        uint40 startTimestamp,
        uint40 maturityTimestamp
    );

    event StakeEnded (
        uint256 indexed stakeID,
        address indexed staker,
        uint256 rewardPaid,
        uint256 endTimestamp
    );

    constructor(
        address _immutableSSS,
        address _stakingPool
    )
        Declaration(_immutableSSS)
    {
        stakingPool = _stakingPool;
        cliff = 7 * ONE_DAY;
    }

    function setCliff(uint256 _days) external onlyOwner { 
        cliff = _days * ONE_DAY;
    }

    function stake(
        uint256 _amount,
        uint40 _lockDays
    )
        external
    {
        stakeFor(_msgSender(), _amount, _lockDays);
    }

    function stakeFor(
        address _account,
        uint256 _amount,
        uint40 _lockDays
    )
        private
    {
        require(_amount > 0, "SSS-Stake: Amount cannot be zero");
        require(_lockDays * ONE_DAY >= cliff, "SSS-Stake: Lockdays must be greater than cliff");
        
        SSS.transferFrom(
            _account,
            stakingPool,
            _amount
        );

        uint40 blockTimestamp = uint40(block.timestamp);
        uint40 maturityTimestamp = blockTimestamp + _lockDays * ONE_DAY;

        Stake memory newStake = Stake(
            _amount,
            blockTimestamp,
            maturityTimestamp
        );

        if (stakeCount[_account] == 0) {
            stakers.push(_account);
            stakerID[_account] = stakers.length - 1;
        }

        allStakes[_account].push(newStake);
        stakeCount[_account] = allStakes[_account].length;

        emit StakeBegan(
            stakeCount[_account] - 1,
            _account,
            newStake.amount,
            newStake.startTimestamp,
            newStake.maturityTimestamp
        );
    }

    function unstake(
        uint256 _stakeID,
        uint256 _amount
    )
        external
    {
        unstakeFor(_msgSender(), _stakeID, _amount);
    }

    function unstakeFor(
        address _account,
        uint256 _stakeID,
        uint256 _amount
    )
        private
    {
        require(_stakeID < allStakes[_account].length, "SSS-Stake: Index is out of range");

        Stake storage selected = allStakes[_account][_stakeID];

        require(
            block.timestamp - selected.startTimestamp >= cliff,
            "SSS-Stake: Cliff is not reached"
        );
        require(_amount <= available(_account, _stakeID), "SSS-Stake: Amount exceeds available");

        if (block.timestamp >= selected.maturityTimestamp) {
            require(
                _amount == available(_account, _stakeID),
                "SSS-Stake: Current staking is already mature"
            );
        }

        uint256 reward = _calculateReward(_account, _stakeID);
        
        SSS.transferFrom(
            stakingPool,
            _account,
            _amount + reward
        );

        selected.amount -= _amount;

        if (selected.amount == 0) {
            Stake[] memory stakes = allStakes[_account];
            allStakes[_account][_stakeID] = stakes[stakes.length - 1];
            allStakes[_account].pop();
            stakeCount[_account] -= 1;
        } else {
            _resetTimeStamp(_account, _stakeID);
        }

        if (stakeCount[_account] == 0) {
            uint256 length = stakers.length;
            uint256 index = stakerID[_account];
            address last = stakers[length - 1];
            stakers[index] = last;
            stakerID[_account] = 0;
            stakers.pop();
        }

        emit StakeEnded(
            _stakeID,
            _account,
            reward,
            block.timestamp
        );
    }

    function stakeInfo(
        address _staker,
        uint256 _stakeID
    )
        external
        view
        returns (
            uint256 amount,
            uint40 lockDays,
            uint40 startTimestamp,
            uint40 maturityTimestamp,
            bool isMature
        )
    {
        Stake memory selected = allStakes[_staker][_stakeID];

        amount = selected.amount;
        lockDays = (selected.maturityTimestamp - selected.startTimestamp) / ONE_DAY;
        startTimestamp = selected.startTimestamp;
        maturityTimestamp = selected.maturityTimestamp;
        isMature = block.timestamp >= selected.maturityTimestamp;
    }

    function available(
        address _account,
        uint256 _stakeID
    )
        public
        view
        returns (uint256)
    {
        Stake memory selected = allStakes[_account][_stakeID];
        if (block.timestamp - selected.startTimestamp < cliff) {
            return 0;
        }
        return selected.amount;
    }

    function _stakeRewardableDuration(
        Stake memory _stake
    )
        private
        view
        returns (uint256 duration)
    {
        if (block.timestamp >= _stake.maturityTimestamp) {
            duration = _stake.maturityTimestamp - _stake.startTimestamp;
        }
        else {
            duration = block.timestamp - _stake.startTimestamp;
        }
    }

    function _getValues() private view returns (uint256, uint256) {
        uint256 totalTimeStamp;
        uint256 totalBagSize;
        uint256 length = stakers.length;
        
        for (uint256 i = 0 ; i < length ; i ++) {
            address account = stakers[i];
            uint256 count = stakeCount[account];
            for (uint256 j = 0 ; j < count ; j ++) {
                Stake memory selected = allStakes[account][j];
                uint256 duration = _stakeRewardableDuration(selected);
                totalTimeStamp += duration;
                totalBagSize += selected.amount;
            }
        }

        return (totalTimeStamp, totalBagSize);
    }

    function _calculateReward(
        address _account,
        uint256 _stakeID
    )
        private
        view
        returns (uint256 reward)
    {
        (uint256 totalTimeStamp, uint256 totalBagSize) = _getValues();
        Stake memory selected = allStakes[_account][_stakeID];
        uint256 duration = _stakeRewardableDuration(selected);
        uint256 volume = SSS.balanceOf(stakingPool);
        uint256 rewardForTimeStamp = volume * duration / totalTimeStamp;
        uint256 rewardForBagSize = volume * selected.amount / totalBagSize / 2;
        reward = rewardForTimeStamp + rewardForBagSize;
    }

    function _resetTimeStamp(
        address _account,
        uint256 _stakeID
    )
        private
    {
        Stake storage selected = allStakes[_account][_stakeID];
        selected.startTimestamp = uint40(block.timestamp);
    }
}