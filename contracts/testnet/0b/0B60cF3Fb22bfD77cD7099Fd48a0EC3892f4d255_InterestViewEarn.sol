// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@interest-protocol/dex/interfaces/IPair.sol";

import "./interfaces/ICasaDePapel.sol";

interface InterestViewBalancesInterface {
    function getUserBalances(address account, address[] calldata tokens)
        external
        view
        returns (uint256 nativeBalance, uint256[] memory balances);

    function getUserBalanceAndAllowance(
        address user,
        address spender,
        address token
    ) external view returns (uint256 allowance, uint256 balance);

    function getUserBalancesAndAllowances(
        address user,
        address spender,
        address[] calldata tokens
    )
        external
        view
        returns (uint256[] memory allowances, uint256[] memory balances);
}

interface IOracle {
    function getTokenUSDPrice(address, uint256) external view returns (uint256);
}

contract InterestViewEarn {
    struct PoolData {
        address stakingToken;
        bool stable;
        uint256 reserve0;
        uint256 reserve1;
        uint256 allocationPoints;
        uint256 totalStakingAmount;
        uint256 totalSupply;
        uint256 stakingAmount;
    }

    struct MintData {
        uint256 totalAllocationPoints;
        uint256 interestPerBlock;
    }

    struct UserFarmData {
        uint256 allowance;
        uint256 balance;
        uint256 pendingRewards;
    }

    IOracle private constant ORACLE =
        IOracle(0x601543e1C59FE2485e8dbA4298Dd97423AA92f0B);

    ICasaDePapel private constant CASA_DE_PAPEL =
        ICasaDePapel(0x8386ECf50C2a4749DF15b6BC7b4A85Ad5A93f4E3);

    InterestViewBalancesInterface private constant INTEREST_VIEW_BALANCES =
        InterestViewBalancesInterface(
            0xaB852f3c3c926bd2430E7d6358441ee1ddbc2cF1
        );

    address private constant IPX = 0x0D7747F1686d67824dc5a299AAc09F438dD6aef2;

    function getFarmsSummary(
        address user,
        address[] calldata pairs,
        uint256[] calldata poolIds,
        address[] calldata tokens
    )
        external
        view
        returns (
            PoolData[] memory pools,
            MintData memory mintData,
            uint256[] memory prices
        )
    {
        pools = new PoolData[](pairs.length);
        prices = new uint256[](tokens.length);

        for (uint256 i; i < pairs.length; i++) {
            pools[i] = _getPoolData(pairs[i], poolIds[i], user);
        }

        for (uint256 i; i < tokens.length; i++) {
            prices[i] = ORACLE.getTokenUSDPrice(tokens[i], 1 ether);
        }

        mintData = _getMintData();
    }

    function getUserFarmData(
        IERC20 token,
        address user,
        uint256 poolId,
        address baseToken
    )
        external
        view
        returns (
            PoolData memory ipxPoolData,
            PoolData memory poolData,
            MintData memory mintData,
            UserFarmData memory farmData,
            uint256 baseTokenPrice
        )
    {
        (farmData.allowance, farmData.balance) = INTEREST_VIEW_BALANCES
            .getUserBalanceAndAllowance(
                user,
                address(CASA_DE_PAPEL),
                address(token)
            );

        farmData.pendingRewards = CASA_DE_PAPEL.getUserPendingRewards(
            poolId,
            user
        );

        mintData = _getMintData();

        ipxPoolData = _getPoolData(IPX, 0, user);

        poolData = _getPoolData(address(token), poolId, user);

        baseTokenPrice = ORACLE.getTokenUSDPrice(baseToken, 1 ether);
    }

    function _getMintData() private view returns (MintData memory) {
        return
            MintData(
                CASA_DE_PAPEL.totalAllocationPoints(),
                CASA_DE_PAPEL.interestTokenPerBlock()
            );
    }

    function _getPoolData(
        address pair,
        uint256 id,
        address user
    ) private view returns (PoolData memory poolData) {
        {
            (
                address stakingToken,
                uint256 allocationPoints,
                ,
                ,
                uint256 totalStakingAmount
            ) = CASA_DE_PAPEL.pools(id);

            poolData.stakingToken = stakingToken;
            poolData.allocationPoints = allocationPoints;
            poolData.totalStakingAmount = totalStakingAmount;
            poolData.totalSupply = IERC20(pair).totalSupply();

            (poolData.stakingAmount, ) = CASA_DE_PAPEL.userInfo(id, user);
        }

        if (id != 0) {
            (, , bool stable, , uint256 r0, uint256 r1, , ) = IPair(pair)
                .metadata();

            poolData.reserve0 = r0;
            poolData.reserve1 = r1;
            poolData.stable = stable;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import {Observation} from "../DataTypes.sol";

import "./IERC20.sol";

interface IPair is IERC20 {
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

    event Sync(uint256 reserve0, uint256 reserve1);

    function stable() external view returns (bool);

    function nonces(address) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function observations(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function reserve0() external view returns (uint256);

    function reserve1() external view returns (uint256);

    function blockTimestampLast() external view returns (uint256);

    function reserve0CumulativeLast() external view returns (uint256);

    function reserve1CumulativeLast() external view returns (uint256);

    function observationLength() external view returns (uint256);

    function getFirstObservationInWindow()
        external
        view
        returns (Observation memory);

    function observationIndexOf(uint256 timestamp)
        external
        pure
        returns (uint256 index);

    function metadata()
        external
        view
        returns (
            address t0,
            address t1,
            bool st,
            uint256 fee,
            uint256 r0,
            uint256 r1,
            uint256 dec0,
            uint256 dec1
        );

    function tokens() external view returns (address, address);

    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getTokenPrice(address tokenIn, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function currentCumulativeReserves()
        external
        view
        returns (
            uint256 reserve0Cumulative,
            uint256 reserve1Cumulative,
            uint256 blockTimestamp
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function getAmountOut(address, uint256) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ICasaDePapel {
    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Stake(address indexed user, uint256 indexed poolId, uint256 amount);

    event Unstake(address indexed user, uint256 indexed poolId, uint256 amount);

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    );

    event Liquidate(
        address indexed liquidator,
        address indexed debtor,
        uint256 amount
    );

    event UpdatePool(
        uint256 indexed poolId,
        uint256 blockNumber,
        uint256 accruedIntPerShare
    );

    event UpdatePoolAllocationPoint(
        uint256 indexed poolId,
        uint256 allocationPoints
    );

    event AddPool(
        address indexed token,
        uint256 indexed poolId,
        uint256 allocationPoints
    );

    event NewInterestTokenRatePerBlock(uint256 rate);

    event NewTreasury(address indexed treasury);

    function START_BLOCK() external view returns (uint256);

    function interestTokenPerBlock() external view returns (uint256);

    function treasury() external view returns (address);

    function treasuryBalance() external view returns (uint256);

    function pools(uint256 index)
        external
        view
        returns (
            address stakingToken,
            uint256 allocationPoints,
            uint256 lastRewardBlock,
            uint256 accruedIntPerShare,
            uint256 totalSupply
        );

    function userInfo(uint256 poolId, address account)
        external
        view
        returns (uint256 amount, uint256 rewardsPaid);

    function hasPool(address token) external view returns (bool);

    function getPoolId(address token) external view returns (uint256);

    function totalAllocationPoints() external view returns (uint256);

    function getPoolsLength() external view returns (uint256);

    function getUserPendingRewards(uint256 poolId, address _user)
        external
        view
        returns (uint256);

    function mintTreasuryRewards() external;

    function updatePool(uint256 poolId) external;

    function updateAllPools() external;

    function stake(uint256 poolId, uint256 amount) external;

    function unstake(uint256 poolId, uint256 amount) external;

    function emergencyWithdraw(uint256 poolId) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

struct Observation {
    uint256 timestamp;
    uint256 reserve0Cumulative;
    uint256 reserve1Cumulative;
}

struct Route {
    address from;
    address to;
}

struct Amount {
    uint256 amount;
    bool stable;
}

struct InitData {
    address token0;
    address token1;
    bool stable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}