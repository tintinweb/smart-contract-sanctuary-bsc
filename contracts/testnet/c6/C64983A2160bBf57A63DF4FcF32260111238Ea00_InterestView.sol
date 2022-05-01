//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IDineroMarket.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/ICasaDePapel.sol";

struct DineroMarketSummary {
    uint256 totalCollateral;
    uint256 exchangeRate;
    uint256 liquidationFee;
    uint256 maxLTVRatio;
    uint64 lastAccrued;
    uint64 interestRate;
    uint128 feesEarned;
}

struct DineroMarketUserData {
    uint256 exchangeRate;
    uint256 loanElastic;
    uint256 loanBase;
    uint256 liquidationFee;
    uint256 maxLTVRatio;
    uint64 lastAccrued;
    uint64 interestRate;
    uint128 feesEarned;
    uint256 userCollateral;
    uint256 userLoan;
}

struct Reserves {
    uint112 reserve0;
    uint112 reserve1;
    uint32 blockTimestampLast;
}

// stakingToken, allocationPoints, totalSupply

struct PoolData {
    address stakingToken;
    uint256 allocationPoints;
    uint256 totalStakingAmount;
}

struct MintData {
    uint256 totalAllocationPoints;
    uint256 interestPerBlock;
}

contract InterestView {
    IOracle private constant ORACLE =
        IOracle(0x601543e1C59FE2485e8dbA4298Dd97423AA92f0B);

    ICasaDePapel private constant CASA_DE_PAPEL =
        ICasaDePapel(0x601543e1C59FE2485e8dbA4298Dd97423AA92f0B);

    function getDineroMarketsSummary(address[] calldata dineroMarkets)
        external
        view
        returns (DineroMarketSummary[] memory returnData)
    {
        uint256 length = dineroMarkets.length;
        returnData = new DineroMarketSummary[](length);

        for (uint256 i; i < length; i++) {
            IDineroMarket market = IDineroMarket(dineroMarkets[i]);
            (
                uint64 lastAccrued,
                uint64 interestRate,
                uint128 feesEarned
            ) = market.loan();

            DineroMarketSummary memory summary = DineroMarketSummary(
                market.totalCollateral(),
                market.exchangeRate(),
                market.liquidationFee(),
                market.maxLTVRatio(),
                lastAccrued,
                interestRate,
                feesEarned
            );

            returnData[i] = summary;
        }
    }

    function getUserBalances(address account, address[] calldata tokens)
        public
        view
        returns (uint256 nativeBalance, uint256[] memory balances)
    {
        uint256 length = tokens.length;
        balances = new uint256[](length);

        for (uint256 i; i < length; i++) {
            IERC20 token = IERC20(tokens[i]);

            uint256 balance = token.balanceOf(account);

            balances[i] = balance;
        }

        nativeBalance = account.balance;
    }

    function getDineroMarketUserData(
        address user,
        IDineroMarket market,
        address[] calldata tokens
    )
        external
        view
        returns (
            DineroMarketUserData memory returnData,
            uint256[] memory balances,
            uint256[] memory allowances
        )
    {
        (uint256 elastic, uint256 base) = market.totalLoan();
        (uint64 lastAccrued, uint64 interestRate, uint128 feesEarned) = market
            .loan();
        returnData = DineroMarketUserData(
            market.exchangeRate(),
            elastic,
            base,
            market.liquidationFee(),
            market.maxLTVRatio(),
            lastAccrued,
            interestRate,
            feesEarned,
            market.userCollateral(user),
            market.userLoan(user)
        );

        (, balances) = getUserBalances(user, tokens);

        for (uint256 i; i < tokens.length; i++) {
            allowances[i] = IERC20(tokens[i]).allowance(address(market), user);
        }
    }

    function getUserBalanceAndAllowance(
        address user,
        address spender,
        address token
    ) public view returns (uint256 allowance, uint256 balance) {
        IERC20 _token = IERC20(token);
        allowance = _token.allowance(user, spender);
        balance = _token.balanceOf(user);
    }

    function getUserBalancesAndAllowances(
        address user,
        address spender,
        address[] calldata tokens
    )
        external
        view
        returns (uint256[] memory allowances, uint256[] memory balances)
    {
        uint256 length = tokens.length;

        for (uint256 i; i < length; i++) {
            (uint256 allowance, uint256 balance) = getUserBalanceAndAllowance(
                user,
                spender,
                tokens[i]
            );
            allowances[i] = allowance;
            balances[i] = balance;
        }
    }

    function getFarmsSummary(
        address[] calldata pairs,
        uint256[] calldata poolIds,
        address[] calldata tokens
    )
        external
        view
        returns (
            Reserves[] memory reserves,
            PoolData[] memory poolsData,
            uint256[] memory prices,
            MintData memory mintData
        )
    {
        for (uint256 i; i < pairs.length; i++) {
            reserves[i] = _getPairV2Reserves(pairs[i]);

            poolsData[i] = _getPoolData(poolIds[i]);
        }

        mintData = MintData(
            CASA_DE_PAPEL.totalAllocationPoints(),
            CASA_DE_PAPEL.interestTokenPerBlock()
        );

        for (uint256 k; k < tokens.length; k++) {
            prices[k] = ORACLE.getTokenUSDPrice(tokens[k], 1 ether);
        }
    }

    function getUserFarmData(
        IERC20 token,
        address user,
        uint256 poolId
    )
        external
        view
        returns (
            uint256 allowance,
            uint256 balance,
            uint256 totalSupply,
            uint256 stakingAmount,
            uint256 pendingRewards
        )
    {
        (allowance, balance) = getUserBalanceAndAllowance(
            user,
            address(CASA_DE_PAPEL),
            address(token)
        );

        totalSupply = token.totalSupply();
        pendingRewards = CASA_DE_PAPEL.pendingRewards(poolId, user);

        (stakingAmount, ) = CASA_DE_PAPEL.userInfo(poolId, user);
    }

    function _getPoolData(uint256 id)
        private
        view
        returns (PoolData memory result)
    {
        (
            address stakingToken,
            uint256 allocationPoints,
            ,
            ,
            uint256 totalStakingAmount
        ) = CASA_DE_PAPEL.pools(id);

        result = PoolData(stakingToken, allocationPoints, totalStakingAmount);
    }

    function _getPairV2Reserves(address pair)
        private
        view
        returns (Reserves memory result)
    {
        (uint112 reserves0, uint112 reserves1, uint32 time) = IUniswapV2Pair(
            pair
        ).getReserves();

        result = Reserves(reserves0, reserves1, time);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IDineroMarket {
    function totalCollateral() external view returns (uint256);

    function exchangeRate() external view returns (uint256);

    function loan()
        external
        view
        returns (
            uint64,
            uint64,
            uint128
        );

    function liquidationFee() external view returns (uint256);

    function maxLTVRatio() external view returns (uint256);

    function totalLoan() external view returns (uint256, uint256);

    function userCollateral(address) external view returns (uint256);

    function userLoan(address) external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC20 {
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
    function allowance(address owner, address spender)
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
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IOracle {
    function getTokenUSDPrice(address, uint256) external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ICasaDePapel {
    function totalAllocationPoints() external view returns (uint256);

    function interestTokenPerBlock() external view returns (uint256);

    function pools(uint256)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function pendingRewards(uint256, address) external view returns (uint256);

    function userInfo(uint256, address)
        external
        view
        returns (uint256, uint256);
}