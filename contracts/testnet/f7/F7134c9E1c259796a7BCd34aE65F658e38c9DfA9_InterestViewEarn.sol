// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@interest-protocol/dex/interfaces/IPair.sol";
import "@interest-protocol/dex/interfaces/IERC20.sol";

import "./interfaces/ICasaDePapel.sol";
import "./interfaces/IDineroVault.sol";

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

    struct DineroVaultSummary {
        uint256 tvl;
        uint256 depositAmount;
    }

    struct UserDineroVaultData {
        uint256 maxDineroAmount;
        uint256 mintedDineroAmount;
        uint256 depositAmount;
        uint256 underlyingBalance;
        uint256 underlyingAllowance;
        uint256 dineroBalance;
    }

    IOracle private constant ORACLE =
        IOracle(0x601543e1C59FE2485e8dbA4298Dd97423AA92f0B);

    ICasaDePapel private constant CASA_DE_PAPEL =
        ICasaDePapel(0xc5004e33c339351dbc44C16e18860a23467E651e);

    InterestViewBalancesInterface private constant INTEREST_VIEW_BALANCES =
        InterestViewBalancesInterface(
            0xaB852f3c3c926bd2430E7d6358441ee1ddbc2cF1
        );

    IERC20 private constant DINERO =
        IERC20(0x57486681D2E0Bc9B0494446b8c5df35cd20D4E92);

    address private constant WBNB_IPX_PAIR =
        0xD4a22921a4A642AA653595f5530abd358F7f0842;

    function getVaultsSummary(
        address user,
        IDineroVault[] calldata _dineroVaults
    ) external view returns (DineroVaultSummary[] memory dineroVaults) {
        dineroVaults = new DineroVaultSummary[](_dineroVaults.length);

        for (uint256 i; i < _dineroVaults.length; i++) {
            dineroVaults[i] = _getDineroVaultSummary(user, _dineroVaults[i]);
        }
    }

    function getUserDineroVault(
        IDineroVault vault,
        IERC20 underlying,
        address user
    ) external view returns (UserDineroVaultData memory data) {
        data.mintedDineroAmount = vault.mintedDineroAmount();
        data.maxDineroAmount = vault.maxDineroAmount();
        data.depositAmount = vault.balanceOf(user);

        (
            data.underlyingAllowance,
            data.underlyingBalance
        ) = INTEREST_VIEW_BALANCES.getUserBalanceAndAllowance(
            user,
            address(vault),
            address(underlying)
        );

        data.dineroBalance = DINERO.balanceOf(user);
    }

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

        for (uint256 i; i < pairs.length; i++) {
            pools[i] = _getPoolData(pairs[i], poolIds[i], user);
        }

        prices = _getPrices(tokens);

        mintData = _getMintData();
    }

    function getUserFarmData(
        IERC20 token,
        address user,
        uint256 poolId,
        address[] calldata tokens
    )
        external
        view
        returns (
            PoolData memory ipxPoolData,
            PoolData memory poolData,
            MintData memory mintData,
            UserFarmData memory farmData,
            uint256[] memory prices
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

        // Pool ID 1 must be Int/NATIVE WRAPPED TOKEN
        ipxPoolData = _getPoolData(WBNB_IPX_PAIR, 1, user);

        poolData = _getPoolData(address(token), poolId, user);
        prices = _getPrices(tokens);
    }

    function _getPrices(address[] calldata tokens)
        private
        view
        returns (uint256[] memory prices)
    {
        prices = new uint256[](tokens.length);

        for (uint256 i; i < tokens.length; i++) {
            prices[i] = ORACLE.getTokenUSDPrice(tokens[i], 1 ether);
        }
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

    function _getDineroVaultSummary(address user, IDineroVault vault)
        private
        view
        returns (DineroVaultSummary memory data)
    {
        data.tvl = vault.mintedDineroAmount();
        data.depositAmount = vault.balanceOf(user);
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IDineroVault {
    function balanceOf(address user) external view returns (uint256);

    function maxDineroAmount() external view returns (uint128);

    function mintedDineroAmount() external view returns (uint128);

    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;
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