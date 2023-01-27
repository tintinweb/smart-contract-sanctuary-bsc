/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-10
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

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

/**
 * @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
 */
contract StakingDBT is Ownable {
    IBEP20 private IBEP20Interface;
    AggregatorV3Interface internal priceFeed;
    address pairAddress;
    int tierLevel1;
    int tierLevel2;
    int tierLevel3;

    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */
    constructor(address _tokenAddress) {
        // This push is needed so we avoid index 0 causing bug of index-1
        IBEP20Interface = IBEP20(_tokenAddress);

        /**
         * Network: BSC
         * Aggregator: BNB/USD
         * Address (MainNet): 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
         * Address (TestNet): 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
         */
        priceFeed = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
        stakeholders.push();
        tierLevel1 = 150 * (10**9);
        tierLevel2 = 300 * (10**9);
        tierLevel3 = 700 * (10**9);
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        uint256 amount;
        uint256 token_tier_level;
        uint256 nft_level;
        uint256 tier_level;
        uint256 cooldown_time;
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        uint256 tier_level;
    }

    struct TotalSummary {
        uint256 locked_amount;
        uint256 total_staker;
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

    event Staked(address indexed user, uint256 amount, uint256 timestamp);

    event Withdrawed(address indexed user, uint256 amount, uint256 timestamp);

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
     * @notice _getTokenTierLevel calc token price and tier level
     */
    function _getTokenTierLevel(uint256 totalAmount)
        internal
        view
        returns (uint256)
    {
        uint256 tierLevel;
        int256 totalPrice = getPrice(totalAmount);

        if (totalPrice > (tierLevel1 * (10**9))) {
            tierLevel = 3;
        } else if (totalPrice > (tierLevel2 * (10**9))) {
            tierLevel = 2;
        } else if (totalPrice > (tierLevel3 * (10**9))) {
            tierLevel = 1;
        } else {
            tierLevel = 0;
        }
        return tierLevel;
    }

    /**
     * @notice _getTierLevel calc tier system level
     */
    function _getTierLevel(uint256 token_tier_level, uint256 nft_level)
        internal
        pure
        returns (uint256)
    {
        uint256 tierLevel;

        if (
            nft_level == 2 ||
            token_tier_level > 2 ||
            (token_tier_level > 0 && nft_level == 2)
        ) {
            tierLevel = 3;
        } else if (
            token_tier_level > 1 || (token_tier_level > 0 && nft_level == 1)
        ) {
            tierLevel = 2;
        } else if (token_tier_level > 0) {
            tierLevel = 1;
        } else {
            tierLevel = 0;
        }
        return tierLevel;
    }

    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    function setTierLevel1(uint _tierLevel1) public onlyOwner {
        tierLevel1 = int(_tierLevel1);
    }

    function setTierLevel2(uint _tierLevel2) public onlyOwner {
        tierLevel2 = int(_tierLevel2);
    }

    function setTierLevel3(uint _tierLevel3) public onlyOwner {
        tierLevel3 = int(_tierLevel3);
    }

    function getTierLevelValues() public view returns (int256[3] memory) {
        int256[3] memory arr = [tierLevel1, tierLevel2, tierLevel3];
        return arr;
    }

    function getPrice(uint256 amount) public view returns (int256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint256 Res0, uint256 Res1, ) = pair.getReserves();
        uint256 bnbAmount = (amount * Res0) / Res1;
        int256 price = _getBNBPrice(bnbAmount);
        return price;
    }

    function _getBNBPrice(uint256 amount) public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (price / (10**8)) * int256(amount);
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function stake(uint256 amount) public {
        // Simple check so that user does not stake 0
        require(amount > 0, "Cannot stake nothing");

        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;

        if (index == 0) {
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].amount = stakeholders[index].amount + amount;

        stakeholders[index].token_tier_level = _getTokenTierLevel(
            stakeholders[index].amount
        );

        uint256 tier_level = _getTierLevel(
            stakeholders[index].token_tier_level,
            stakeholders[index].nft_level
        );

        stakeholders[index].tier_level = tier_level;

        // Emit an event that the stake has occured
        if (IBEP20Interface.transferFrom(msg.sender, address(this), amount)) {
            emit Staked(msg.sender, amount, timestamp);
        } else {
            revert("Unable to transfer funds");
        }
    }

    function updateNFTLevel(address staker, uint256 _NFTLevel)
        public
        onlyOwner
    {
        uint256 index = stakes[staker];

        if (index == 0) {
            index = _addStakeholder(staker);
        }

        stakeholders[index].nft_level = _NFTLevel;

        uint256 tier_level = _getTierLevel(
            stakeholders[index].token_tier_level,
            stakeholders[index].nft_level
        );

        stakeholders[index].tier_level = tier_level;
    }

    function withdraw(uint256 amount) public {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;

        require(
            stakeholders[index].amount >= amount,
            "Staking: Cannot withdraw more than you have staked"
        );

        stakeholders[index].amount = stakeholders[index].amount - amount;

        stakeholders[index].token_tier_level = _getTokenTierLevel(
            stakeholders[index].amount
        );

        uint256 tier_level = _getTierLevel(
            stakeholders[index].token_tier_level,
            stakeholders[index].nft_level
        );

        stakeholders[index].tier_level = tier_level;

        if (IBEP20Interface.transfer(msg.sender, amount)) {
            emit Withdrawed(msg.sender, amount, timestamp);
        } else {
            revert("Unable to transfer funds");
        }
    }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        uint256 index = stakes[_staker];
        StakingSummary memory summary = StakingSummary(0, 0);
        if (index > 0) {
            summary = StakingSummary(
                stakeholders[index].amount,
                stakeholders[index].tier_level);
        }
        return summary;
    }

    function totalSummary() public view returns (TotalSummary memory) {
        uint256 totalStakeAmount;

        TotalSummary memory summary = TotalSummary(0, stakeholders.length);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            totalStakeAmount = totalStakeAmount + stakeholders[s].amount;
        }
        // Assign calculate amount to summary
        summary.locked_amount = totalStakeAmount;
        return summary;
    }

}