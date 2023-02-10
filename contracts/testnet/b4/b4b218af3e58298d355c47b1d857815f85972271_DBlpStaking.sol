/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-10
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external view returns (uint256);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

/**
 * @notice Contract is a inheritable smart contract that will add a
 * New modifier called onlyOwner available in the smart contract inherting it
 *
 * onlyOwner makes a function only callable from the Token owner
 *
 */
contract Ownable {
    // _owner is the owner of the Token
    address private _owner;

    /**
     * Event OwnershipTransferred is used to log that a ownership change of the token has occured
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * Modifier
     * We create our own function modifier called onlyOwner, it will Require the current owner to be
     * the same as msg.sender
     */
    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Ownable: only owner can call this function"
        );
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @notice owner() returns the currently assigned owner of the Token
     *
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @notice renounceOwnership will set the owner to zero address
     * This will make the contract owner less, It will make ALL functions with
     * onlyOwner no longer callable.
     * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @notice transferOwnership will assign the {newOwner} as owner
     *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @notice _transferOwnership will assign the {newOwner} as owner
     *
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DBlpStaking is Ownable {
    IBEP20 private DBToken;
    IUniswapV2Pair private LPToken;
    uint256 currentRewardPool;

    struct StakeLevel {
        uint256 duration;
        uint256 rewardAPY;
    }

    StakeLevel[] stakelevels;
    /**
     * @notice
     * A stake struct is used to represent the way we store stakes,
     * A Stake will contain the users address, the amount staked and a timestamp,
     * Since which is when the stake was made
     */
    struct Stake {
        uint256 lpamount;
        uint256 dbamount;
        uint256 since;
        uint256 update;
        uint256 level;
        uint256 claimable;
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
     * @notice
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;
    /**
     * @notice
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;
    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );

    event Unstaked(address indexed user, uint256 amount, uint256 timestamp);
    event WithdrawReward(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    /**
     * @notice
      rewardPerHour is 1000 because it is used to represent 0.001, since we only use integer numbers
      This will give users 0.1% reward for each staked token / H
     */
    uint256 internal rewardPerHour = 1000;

    constructor(address _dbtokenAddress, address _lptokenAddress) {
        DBToken = IBEP20(_dbtokenAddress);
        LPToken = IUniswapV2Pair(_lptokenAddress);
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
        stakelevels.push(StakeLevel(30, 50));
        stakelevels.push(StakeLevel(90, 100));
        stakelevels.push(StakeLevel(180, 150));
    }

    function _setStakeLevelDays(uint256 level, uint256 _days)
        external
        onlyOwner
    {
        stakelevels[level].duration += _days;
    }

    function _setStakeLevelAPY(uint256 level, uint256 _apy) external onlyOwner {
        stakelevels[level].rewardAPY += _apy;
    }

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function stake(uint256 _amount, uint256 _level) public {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");

        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        // See if the staker already has a staked index or if its the first time
        if (index == 0) {
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
        }
        uint256 _dbAmount = calculateDBFromLP(_amount);

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(
            Stake(_amount, _dbAmount, _level, timestamp, timestamp, 0)
        );
        // Emit an event that the stake has occured
        if (LPToken.transferFrom(msg.sender, address(this), _amount)) {
            emit Staked(msg.sender, _amount, index, timestamp);
        } else {
            revert("Unable to transfer funds");
        }
    }

    function calculateDBFromLP(uint256 _amount) public view returns (uint256) {
        uint256 totalLP = LPToken.totalSupply();
        (uint256 Res0, , ) = LPToken.getReserves();
        uint256 dbAmount = (Res0 * _amount) / totalLP;
        return dbAmount;
    }

    function calculateDBReward(Stake memory _stake)
        internal
        view
        returns (uint256)
    {
        if (
            block.timestamp - _stake.since >=
            stakelevels[_stake.level].duration * 24 * 60 * 60
        ) {
            uint256 duration = (block.timestamp - _stake.update) / 1 days;
            uint256 amount = _stake.dbamount + _stake.claimable;
            for (uint256 i = 0; i < duration; i++) {
                amount =
                    amount +
                    (amount * stakelevels[_stake.level].rewardAPY / 365 / 1000);
            }
            uint256 reward = amount - _stake.dbamount;
            return reward;
        }
        return 0;
    }

    function unstake(uint256 amount, uint256 index) public {
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];

        require(
            current_stake.lpamount >= amount,
            "UnStaking: Cannot withdraw more than you have staked"
        );

        require(
            (block.timestamp - current_stake.since) >=
                (stakelevels[current_stake.level].duration * 24 * 60 * 60),
            "UnStaking: Cannot withdraw in cooldown time"
        );

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateDBReward(current_stake);
        uint256 rewardPool = DBToken.balanceOf(address(this));

        require(rewardPool > reward, "UnStaking: Reward pool is not enough.");

        uint256 timestamp = block.timestamp;

        // Remove by subtracting the money unstaked
        current_stake.lpamount = current_stake.lpamount - amount;
        // If stake is empty, 0, then remove it from the array of stakes
        if (current_stake.lpamount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            // If not empty then replace the value of it
            stakeholders[user_index]
                .address_stakes[index]
                .lpamount = current_stake.lpamount;
            uint256 dbAmount = calculateDBFromLP(current_stake.lpamount);
            stakeholders[user_index].address_stakes[index].dbamount = dbAmount;
            stakeholders[user_index].address_stakes[index].claimable = 0;
            stakeholders[user_index].address_stakes[index].update = timestamp;
        }
        if (LPToken.transfer(msg.sender, amount)) {
            DBToken.transfer(msg.sender, reward);
            emit Unstaked(msg.sender, amount, timestamp);
        } else {
            revert("Unable to transfer funds");
        }
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function withdrawReward(uint256 amount, uint256 index) public {
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];

        uint256 timestamp = block.timestamp;
        require(
            (timestamp - current_stake.since) >=
                (stakelevels[current_stake.level].duration * 24 * 60 * 60),
            "Withdraw: Cannot withdraw in cooldown time"
        );

        // Calculate available Reward first before we start modifying data
        uint256 claimable = calculateDBReward(current_stake);
        uint256 rewardPool = DBToken.balanceOf(address(this));

        require(
            claimable > amount,
            "Withdraw: Cannot withdraw more than claimable amount."
        );

        require(rewardPool > amount, "Withdraw: Reward pool is not enough.");

        stakeholders[user_index].address_stakes[index].claimable =
            claimable -
            amount;
        stakeholders[user_index].address_stakes[index].update = timestamp;

        if (DBToken.transfer(msg.sender, amount)) {
            emit WithdrawReward(msg.sender, amount, timestamp);
        } else {
            revert("Unable to transfer funds");
        }
    }

    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateDBReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].lpamount;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    function getStakeLevels() public view returns (StakeLevel[] memory) {

        return stakelevels;
    }
}