// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "@redstone-finance/evm-connector/contracts/data-services/MainDemoConsumerBase.sol";

import "@interest-protocol/library/RebaseLib.sol";
import "@interest-protocol/dex/interfaces/IPair.sol";
import "@interest-protocol/earn/interfaces/ICasaDePapel.sol";

import "./interfaces/IERC20Fees.sol";
import "./interfaces/IERC20Market.sol";
import "./interfaces/ILPFreeMarket.sol";
import "./interfaces/INativeTokenMarket.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/ISyntheticMarket.sol";

import "./synthetics/PriceAware.sol";

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

contract InterestViewDinero is PriceAware, MainDemoConsumerBase {
    using RebaseLib for Rebase;

    IPriceOracle private immutable ORACLE;
    ICasaDePapel private immutable CASA_DE_PAPEL;
    IERC20 private immutable DNR;
    InterestViewBalancesInterface private immutable INTEREST_VIEW_BALANCES;
    IPair private immutable WBNB_IPX_LP;
    IERC20 private immutable IPX;
    IERC20 private immutable BUSD;

    enum DineroMarketType {
        Native,
        ERC20,
        LpFreeMarket
    }

    enum SyntheticMarketType {
        Chainlink,
        RedstoneConsumer,
        RedstonePriceAware
    }

    struct DineroMarketSummary {
        uint256 totalCollateral;
        uint256 LTV;
        uint256 interestRate;
        uint256 liquidationFee;
        uint256 collateralUSDPrice;
        uint256 userElasticLoan;
    }

    struct SyntheticMarketSummary {
        uint256 TVL;
        uint256 LTV;
        uint256 fee;
        uint256 syntheticUSDPrice;
        uint256 userSyntMinted;
    }

    struct SyntheticMarketData {
        uint256 userSyntMinted;
        uint256 transferFee;
        uint256 syntheticUSDPrice;
        uint256 liquidationFee;
        uint256 TVL;
        uint256 LTV;
        uint256 userCollateral;
        uint256 collateralAllowance;
        uint256 collateralBalance;
        uint256 syntBalance;
        uint256 pendingRewards;
    }

    struct DineroMarketData {
        uint256 loanBase;
        uint256 loanElastic;
        uint256 interestRate;
        uint256 lastAccrued;
        uint256 collateralUSDPrice;
        uint256 liquidationFee;
        uint256 LTV;
        uint256 userCollateral;
        uint256 userPrincipal;
        uint256 collateralAllowance;
        uint256 collateralBalance;
        uint256 dnrBalance;
        uint256 rewardsBalance;
        uint256 pendingRewards;
        uint256 maxBorrowAmount;
    }

    struct PoolData {
        address stakingToken;
        bool stable;
        uint256 reserve0;
        uint256 reserve1;
        uint256 allocationPoints;
        uint256 totalStakingAmount;
        uint256 totalSupply;
    }

    struct MintData {
        uint256 totalAllocationPoints;
        uint256 interestPerBlock;
    }

    constructor(
        ICasaDePapel casaDePapel,
        IPriceOracle oracle,
        IERC20 dnr,
        InterestViewBalancesInterface interestViewBalances,
        IPair wbnbIPXLP,
        IERC20 ipx,
        IERC20 busd
    ) {
        CASA_DE_PAPEL = casaDePapel;
        ORACLE = oracle;
        DNR = dnr;
        INTEREST_VIEW_BALANCES = interestViewBalances;
        WBNB_IPX_LP = wbnbIPXLP;
        IPX = ipx;
        BUSD = busd;
    }

    function getDineroMarketsSummary(
        address user,
        INativeTokenMarket _nativeMarket,
        IERC20Market[] calldata _erc20Markets,
        ILPFreeMarket[] calldata _lpMarkets
    )
        external
        view
        returns (
            DineroMarketSummary memory nativeMarket,
            DineroMarketSummary[] memory erc20Markets,
            DineroMarketSummary[] memory lpMarkets
        )
    {
        nativeMarket = _getNativeMarketSummary(user, _nativeMarket);

        erc20Markets = new DineroMarketSummary[](_erc20Markets.length);

        for (uint256 i; i < _erc20Markets.length; i++) {
            erc20Markets[i] = _getERC20MarketSummary(user, _erc20Markets[i]);
        }

        lpMarkets = new DineroMarketSummary[](_lpMarkets.length);

        for (uint256 i; i < _lpMarkets.length; i++) {
            lpMarkets[i] = _getLPMarketSummary(user, _lpMarkets[i]);
        }
    }

    function getDineroMarketData(
        address user,
        address market,
        address baseToken,
        DineroMarketType kind
    )
        external
        view
        returns (
            DineroMarketData memory marketData,
            PoolData memory ipxPoolData,
            PoolData memory collateralPoolData,
            MintData memory mintData,
            uint256 nativeUSDPrice,
            uint256 baseTokenUSDPrice
        )
    {
        if (kind == DineroMarketType.ERC20)
            marketData = _getERC20MarketData(user, IERC20Market(market));

        if (kind == DineroMarketType.Native)
            marketData = _getNativeMarketData(user, INativeTokenMarket(market));

        if (kind == DineroMarketType.LpFreeMarket) {
            marketData = _getLPFreeMarketData(user, ILPFreeMarket(market));
            IPair pair = IPair(ILPFreeMarket(market).COLLATERAL());
            ipxPoolData = _getPoolData(WBNB_IPX_LP);
            collateralPoolData = _getPoolData(pair);
            mintData.totalAllocationPoints = CASA_DE_PAPEL
                .totalAllocationPoints();
            mintData.interestPerBlock = CASA_DE_PAPEL.interestTokenPerBlock();
            baseTokenUSDPrice = ORACLE.getTokenUSDPrice(baseToken, 1 ether);
            nativeUSDPrice = ORACLE.getNativeTokenUSDPrice(1 ether);
        }
    }

    function getSyntheticMarketsSummary(
        address user,
        address[] calldata markets,
        SyntheticMarketType[] calldata syntheticMarketTypes,
        bytes32[] calldata redstoneSymbols
    )
        external
        view
        returns (
            SyntheticMarketSummary[] memory data,
            uint256[] memory redStonePrices
        )
    {
        data = new SyntheticMarketSummary[](markets.length);

        for (uint256 i; i < markets.length; i++) {
            SyntheticMarketSummary memory summary;
            ISyntheticMarket market = ISyntheticMarket(markets[i]);
            SyntheticMarketType syntheticType = syntheticMarketTypes[i];

            IERC20Fees synt = IERC20Fees(market.SYNT());

            summary.LTV = market.maxLTVRatio();
            summary.TVL = BUSD.balanceOf(address(market));

            if (syntheticType == SyntheticMarketType.Chainlink)
                summary.syntheticUSDPrice = ORACLE.getTokenUSDPrice(
                    address(synt),
                    1 ether
                );
            summary.fee = synt.transferFee();
            (, summary.userSyntMinted, ) = market.accountOf(user);

            data[i] = summary;
        }

        redStonePrices = getOracleNumericValuesFromTxMsg(redstoneSymbols);
    }

    function getSyntheticUserMarketData(
        address user,
        ISyntheticMarket market,
        address collateral,
        SyntheticMarketType oracleType,
        bytes32 dataFeedId
    ) external view returns (SyntheticMarketData memory data) {
        IERC20Fees synt = IERC20Fees(market.SYNT());

        {
            address[] memory tokens = new address[](2);

            tokens[0] = collateral;
            tokens[1] = address(synt);

            (
                uint256[] memory allowances,
                uint256[] memory balances
            ) = INTEREST_VIEW_BALANCES.getUserBalancesAndAllowances(
                    user,
                    address(market),
                    tokens
                );

            data.collateralAllowance = allowances[0];
            data.collateralBalance = balances[0];
            data.syntBalance = balances[1];
        }

        {
            data.LTV = market.maxLTVRatio();
            data.TVL = market.totalSynt();

            if (oracleType == SyntheticMarketType.Chainlink)
                data.syntheticUSDPrice = ORACLE.getTokenUSDPrice(
                    address(synt),
                    1 ether
                );

            if (oracleType == SyntheticMarketType.RedstoneConsumer)
                data.syntheticUSDPrice = getOracleNumericValueFromTxMsg(
                    dataFeedId
                );

            data.transferFee = synt.transferFee();
            (data.userCollateral, data.userSyntMinted, ) = market.accountOf(
                user
            );
            data.liquidationFee = market.liquidationFee();
            data.pendingRewards = market.getPendingRewards(user);
        }
    }

    function _getPoolData(IPair pair)
        private
        view
        returns (PoolData memory poolData)
    {
        uint256 poolId = CASA_DE_PAPEL.getPoolId(address(pair));
        {
            (, , bool st, , uint256 r0, uint256 r1, , ) = pair.metadata();

            poolData.stable = st;
            poolData.reserve0 = r0;
            poolData.reserve1 = r1;
        }

        {
            (
                ,
                uint256 allocationPoints,
                ,
                ,
                uint256 totalSupply
            ) = CASA_DE_PAPEL.pools(poolId);

            poolData.stakingToken = address(pair);
            poolData.allocationPoints = allocationPoints;
            poolData.totalStakingAmount = totalSupply;
            poolData.totalSupply = IERC20(pair).totalSupply();
        }
    }

    function _getERC20MarketData(address user, IERC20Market market)
        private
        view
        returns (DineroMarketData memory marketData)
    {
        address[] memory tokens = new address[](2);

        address collateral = market.COLLATERAL();

        tokens[0] = address(DNR);
        tokens[1] = collateral;

        {
            (
                uint256[] memory allowances,
                uint256[] memory balances
            ) = INTEREST_VIEW_BALANCES.getUserBalancesAndAllowances(
                    user,
                    address(market),
                    tokens
                );

            marketData.collateralAllowance = allowances[1];
            marketData.collateralBalance = balances[1];
            marketData.dnrBalance = balances[0];
        }

        {
            (uint128 elastic, uint128 base) = market.loan();

            marketData.loanBase = base;
            marketData.loanElastic = elastic;
        }

        {
            (uint128 lastAccrued, uint128 interestRate, , ) = market
                .loanTerms();

            marketData.interestRate = interestRate;
            marketData.lastAccrued = lastAccrued;

            marketData.collateralUSDPrice = ORACLE.getTokenUSDPrice(
                collateral,
                1 ether
            );
        }

        {
            marketData.LTV = market.maxLTVRatio();
            marketData.liquidationFee = market.liquidationFee();
        }

        {
            (uint128 _collateral, uint128 principal) = market.accountOf(user);

            marketData.userCollateral = _collateral;
            marketData.userPrincipal = principal;
            marketData.maxBorrowAmount = market.maxBorrowAmount();
        }
    }

    function _getNativeMarketData(address user, INativeTokenMarket market)
        private
        view
        returns (DineroMarketData memory marketData)
    {
        address[] memory tokens = new address[](1);

        tokens[0] = address(DNR);

        {
            (
                uint256 nativeBalance,
                uint256[] memory balances
            ) = INTEREST_VIEW_BALANCES.getUserBalances(user, tokens);

            marketData.collateralAllowance = type(uint256).max;
            marketData.collateralBalance = nativeBalance;
            marketData.dnrBalance = balances[0];
        }

        {
            (uint128 elastic, uint128 base) = market.loan();

            marketData.loanBase = base;
            marketData.loanElastic = elastic;
        }

        {
            (uint128 lastAccrued, uint128 interestRate, , ) = market
                .loanTerms();

            marketData.interestRate = interestRate;
            marketData.lastAccrued = lastAccrued;

            marketData.collateralUSDPrice = ORACLE.getNativeTokenUSDPrice(
                1 ether
            );
        }

        {
            marketData.LTV = market.maxLTVRatio();
            marketData.liquidationFee = market.liquidationFee();
        }

        {
            (uint128 collateral, uint128 principal) = market.accountOf(user);

            marketData.userCollateral = collateral;
            marketData.userPrincipal = principal;
            marketData.maxBorrowAmount = market.maxBorrowAmount();
        }
    }

    function _getLPFreeMarketData(address user, ILPFreeMarket market)
        private
        view
        returns (DineroMarketData memory marketData)
    {
        address[] memory tokens = new address[](2);
        address collateral = market.COLLATERAL();

        tokens[0] = address(DNR);
        tokens[1] = collateral;

        {
            (
                uint256[] memory allowances,
                uint256[] memory balances
            ) = INTEREST_VIEW_BALANCES.getUserBalancesAndAllowances(
                    user,
                    address(market),
                    tokens
                );

            marketData.collateralAllowance = allowances[1];
            marketData.collateralBalance = balances[1];
            marketData.dnrBalance = balances[0];
        }

        {
            uint256 totalPrincipal = market.totalPrincipal();

            marketData.loanBase = totalPrincipal;
            marketData.loanElastic = totalPrincipal;

            marketData.collateralUSDPrice = ORACLE.getIPXLPTokenUSDPrice(
                collateral,
                1 ether
            );
        }

        {
            marketData.LTV = market.maxLTVRatio();
            marketData.liquidationFee = market.liquidationFee();
        }

        {
            (uint128 _collateral, , , uint256 principal) = market.accountOf(
                user
            );

            marketData.userCollateral = _collateral;
            marketData.userPrincipal = principal;
            marketData.pendingRewards = market.getPendingRewards(user);
            marketData.maxBorrowAmount = market.maxBorrowAmount();
            marketData.rewardsBalance = IPX.balanceOf(user);
        }
    }

    function _getNativeMarketSummary(address user, INativeTokenMarket market)
        private
        view
        returns (DineroMarketSummary memory)
    {
        (, uint128 interestRate, , ) = market.loanTerms();

        (uint128 elastic, uint128 base) = market.loan();

        Rebase memory loan = Rebase(elastic, base);

        (, uint128 principal) = market.accountOf(user);

        return
            DineroMarketSummary(
                address(market).balance,
                market.maxLTVRatio(),
                interestRate,
                market.liquidationFee(),
                ORACLE.getNativeTokenUSDPrice(1 ether),
                loan.toElastic(principal, false)
            );
    }

    function _getERC20MarketSummary(address user, IERC20Market market)
        private
        view
        returns (DineroMarketSummary memory)
    {
        (, uint128 interestRate, , ) = market.loanTerms();

        address token = market.COLLATERAL();

        (uint128 elastic, uint128 base) = market.loan();

        Rebase memory loan = Rebase(elastic, base);

        (, uint128 principal) = market.accountOf(user);

        return
            DineroMarketSummary(
                IERC20(token).balanceOf(address(market)),
                market.maxLTVRatio(),
                interestRate,
                market.liquidationFee(),
                ORACLE.getTokenUSDPrice(token, 1 ether),
                loan.toElastic(principal, false)
            );
    }

    function _getLPMarketSummary(address user, ILPFreeMarket market)
        private
        view
        returns (DineroMarketSummary memory)
    {
        (, , , uint256 principal) = market.accountOf(user);

        return
            DineroMarketSummary(
                market.totalCollateral(),
                market.maxLTVRatio(),
                0,
                market.liquidationFee(),
                ORACLE.getIPXLPTokenUSDPrice(market.COLLATERAL(), 1 ether),
                principal
            );
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       Oracle Logic                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function isSignerAuthorized(address _receviedSigner)
        public
        view
        virtual
        override
        returns (bool)
    {
        // Signers for redstone-custom-urls-demo data feed (it has 2 authorised signers)
        return
            _receviedSigner == 0x11fFFc9970c41B9bFB9Aa35Be838d39bce918CfF ||
            _receviedSigner == 0xdBcC2C6c892C8d3e3Fe4D325fEc810B7376A5Ed6;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "../core/RedstoneConsumerNumericBase.sol";

contract MainDemoConsumerBase is RedstoneConsumerNumericBase {
  function getUniqueSignersThreshold() public view virtual override returns (uint8) {
    return 1;
  }

  function getAuthorisedSignerIndex(address signerAddress)
    public
    view
    virtual
    override
    returns (uint8)
  {
    if (signerAddress == 0x0C39486f770B26F5527BBBf942726537986Cd7eb) {
      return 0;
    } else {
      revert SignerNotAuthorised(signerAddress);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeCastLib.sol";
import "./MathLib.sol";

/// @dev The elastic represents an arbitrary amount, while the base is the shares of said amount. We save the base and elastic as uint128 instead of uint256 to optimize gas consumption by storing them in one storage slot. A maximum number of 2**128-1 should be enough to cover most of the use cases.
struct Rebase {
    uint128 elastic;
    uint128 base;
}

/**
 * @title A set of functions to manage the change in numbers of tokens and to properly represent them in shares.
 * @dev This library provides a collection of functions to manipulate the base and elastic values saved in a Rebase struct. In a pool context, the percentage of tokens a user owns. The elastic value represents the current number of pool tokens after incurring losses or profits. The functions in this library will revert if the base or elastic goes over 2**1281. Therefore, it is crucial to keep in mind the upper bound limit number this library supports.
 */
library RebaseLib {
    using SafeCastLib for uint256;
    using MathLib for uint256;

    /**
     * @dev Calculates a base value from an elastic value using the ratio of a {Rebase} struct.
     * @param total A {Rebase} struct, which represents a base/elastic pair.
     * @param elastic The new base is calculated from this elastic.
     * @param roundUp Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return base The base value calculated from the elastic and total arguments.
     */
    function toBase(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (uint256 base) {
        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = elastic.mulDiv(total.base, total.elastic);
            if (roundUp && base.mulDiv(total.elastic, total.base) < elastic) {
                base += 1;
            }
        }
    }

    /**
     * @dev Calculates the elastic value from a base value using the ratio of a {Rebase} struct.
     * @param total A {Rebase} struct, which represents a base/elastic pair.
     * @param base The returned elastic is calculated from this base.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return elastic The elastic value calculated from the base and total arguments.
     *
     */
    function toElastic(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = base.mulDiv(total.elastic, total.base);
            if (roundUp && elastic.mulDiv(total.base, total.elastic) < base) {
                elastic += 1;
            }
        }
    }

    /**
     * @dev Calculates new elastic and base values to a {Rebase} pair by increasing the elastic value. This function maintains the ratio of the current {Rebase} pair.
     * @param total The {Rebase} struct that we will be adding the additional elastic value.
     * @param elastic The additional elastic value to add to a {Rebase} struct.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return total The new {Rebase} struct.
     * @return base The additional base value that was added to the new {Rebase} struct.
     */
    function add(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 base) {
        base = toBase(total, elastic, roundUp);
        total.elastic += elastic.toUint128();
        total.base += base.toUint128();
        return (total, base);
    }

    /**
     * @dev Calculates new elastic and base values to a {Rebase} pair by decreasing the base value. This function maintains the ratio of the current {Rebase} pair.
     * @param total The {Rebase} struct that we will be adding the additional elastic value.
     * @param base The amount of base to subtract from the {Rebase} struct.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return total The new {Rebase} struct.
     * @return elastic The amount of elastic that was removed from the {Rebase} struct.
     */
    function sub(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 elastic) {
        elastic = toElastic(total, base, roundUp);
        total.elastic -= elastic.toUint128();
        total.base -= base.toUint128();
        return (total, elastic);
    }

    /**
     * @dev Adds a base and elastic value to a {Rebase} struct.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param base The value to be added to the `total.base`.
     * @param elastic The value to be added to the `total.elastic`.
     * @return total The new {Rebase} struct is calculated by adding the `base` and `elastic` values.
     */
    function add(
        Rebase memory total,
        uint256 base,
        uint256 elastic
    ) internal pure returns (Rebase memory) {
        total.base += base.toUint128();
        total.elastic += elastic.toUint128();
        return total;
    }

    /**
     * @dev Substracts a base and elastic value to a {Rebase} struct.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param base The `total.base` will be decreased by this value.
     * @param elastic The `total.elastic` will be decreased by this value.
     * @return total The new {Rebase} struct is calculated by decreasing the `base` and `elastic` values.
     */
    function sub(
        Rebase memory total,
        uint256 base,
        uint256 elastic
    ) internal pure returns (Rebase memory) {
        total.base -= base.toUint128();
        total.elastic -= elastic.toUint128();
        return total;
    }

    /**
     * @dev This function increases the elastic value of a {Rebase} pair. The `total` parameter is saved in storage. This function will update the global state of the caller contract.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param elastic The value to be added to the `total.elastic`.
     * @return newElastic The new elastic value after reducing `elastic` from `total.elastic`.
     */
    function addElastic(Rebase storage total, uint256 elastic)
        internal
        returns (uint256 newElastic)
    {
        newElastic = total.elastic += elastic.toUint128();
    }

    /**
     * @dev This function decreases the elastic value of a {Rebase} pair. The `total` parameter is saved in storage. This function will update the global state of the caller contract.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param elastic The value to be removed to the `total.elastic`.
     * @return newElastic The new elastic value after reducing `elastic` from `total.elastic`.
     */
    function subElastic(Rebase storage total, uint256 elastic)
        internal
        returns (uint256 newElastic)
    {
        newElastic = total.elastic -= elastic.toUint128();
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IERC20Fees {
    function decimals() external pure returns (uint8);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function transferFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IERC20Market {
    function treasury() external view returns (address);

    function COLLATERAL() external view returns (address);

    function liquidationFee() external view returns (uint96);

    function maxBorrowAmount() external view returns (uint128);

    function maxLTVRatio() external view returns (uint128);

    function loan() external view returns (uint128 elastic, uint128 base);

    function loanTerms()
        external
        view
        returns (
            uint128 lastAccrued,
            uint128 interestRate,
            uint128 dnrEarned,
            uint128 collateralEarned
        );

    function accountOf(address account)
        external
        view
        returns (uint128 collateral, uint128 principal);

    function getDineroEarnings() external;

    function getCollateralEarnings() external;

    function accrue() external;

    function deposit(address to, uint256 amount) external;

    function withdraw(address to, uint256 amount) external;

    function borrow(address to, uint256 amount) external;

    function repay(address account, uint256 amount) external;

    function request(uint256[] calldata requests, bytes[] calldata requestArgs)
        external;

    function liquidate(
        address[] calldata accounts,
        uint256[] calldata principals,
        address recipient,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ILPFreeMarket {
    function COLLATERAL() external view returns (address);

    function liquidationFee() external view returns (uint96);

    function POOL_ID() external view returns (uint96);

    function maxLTVRatio() external view returns (uint128);

    function totalCollateral() external view returns (uint128);

    function totalPrincipal() external view returns (uint128);

    function maxBorrowAmount() external view returns (uint128);

    function totalRewardsPerToken() external view returns (uint256);

    function accountOf(address account)
        external
        view
        returns (
            uint128 collateral,
            uint128 rewards,
            uint256 rewardDebt,
            uint256 principal
        );

    function collateralEarnings() external view returns (uint256);

    function treasury() external view returns (address);

    function getPendingRewards(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface INativeTokenMarket {
    function treasury() external view returns (address);

    function liquidationFee() external view returns (uint96);

    function maxBorrowAmount() external view returns (uint128);

    function maxLTVRatio() external view returns (uint128);

    function loan() external view returns (uint128 elastic, uint128 base);

    function loanTerms()
        external
        view
        returns (
            uint128 lastAccrued,
            uint128 interestRate,
            uint128 dnrEarned,
            uint128 collateralEarned
        );

    function accountOf(address account)
        external
        view
        returns (uint128 collateral, uint128 principal);

    function getDineroEarnings() external;

    function getCollateralEarnings() external;

    function accrue() external;

    function deposit(address to) external payable;

    function withdraw(address to, uint256 amount) external;

    function borrow(address to, uint256 amount) external;

    function repay(address account, uint256 amount) external;

    function request(uint256[] calldata requests, bytes[] calldata requestArgs)
        external
        payable;

    function liquidate(
        address[] calldata accounts,
        uint256[] calldata principals,
        address recipient,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IPriceOracle {
    function getTokenUSDPrice(address token, uint256 amount)
        external
        view
        returns (uint256 price);

    function getIPXLPTokenUSDPrice(address pair, uint256 amount)
        external
        view
        returns (uint256 price);

    function getNativeTokenUSDPrice(uint256 amount)
        external
        view
        returns (uint256 price);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ISyntheticMarket {
    function SYNT() external view returns (address);

    function accountOf(address account)
        external
        view
        returns (
            uint128 collateral,
            uint128 synt,
            uint256 rewardDebt
        );

    function getPendingRewards(address account) external view returns (uint256);

    function liquidationFee() external view returns (uint256);

    function maxLTVRatio() external view returns (uint256);

    function owner() external view returns (address);

    function totalRewardsPerToken() external view returns (uint256);

    function totalSynt() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract PriceAware {
    using ECDSA for bytes32;

    uint256 constant _MAX_DATA_TIMESTAMP_DELAY = 5 * 60; // 5 minutes
    uint256 constant _MAX_BLOCK_TIMESTAMP_DELAY = 60; // 1 min

    /* ========== VIRTUAL FUNCTIONS (MAY BE OVERRIDEN IN CHILD CONTRACTS) ========== */

    function getMaxDataTimestampDelay() public view virtual returns (uint256) {
        return _MAX_DATA_TIMESTAMP_DELAY;
    }

    function getMaxBlockTimestampDelay() public view virtual returns (uint256) {
        return _MAX_BLOCK_TIMESTAMP_DELAY;
    }

    function isSignerAuthorized(address _receviedSigner)
        public
        view
        virtual
        returns (bool);

    function isTimestampValid(uint256 _receivedTimestamp)
        public
        view
        virtual
        returns (bool)
    {
        // Getting data timestamp from future seems quite unlikely
        // But we've already spent too much time with different cases
        // Where block.timestamp was less than dataPackage.timestamp.
        // Some blockchains may case this problem as well.
        // That's why we add MAX_BLOCK_TIMESTAMP_DELAY
        // and allow data "from future" but with a small delay
        require(
            (block.timestamp + getMaxBlockTimestampDelay()) >
                _receivedTimestamp,
            "Data with future timestamps is not allowed"
        );

        return
            block.timestamp < _receivedTimestamp ||
            block.timestamp - _receivedTimestamp < getMaxDataTimestampDelay();
    }

    /* ========== FUNCTIONS WITH IMPLEMENTATION (CAN NOT BE OVERRIDEN) ========== */

    function getPriceFromMsg(bytes32 symbol) internal view returns (uint256) {
        bytes32[] memory symbols = new bytes32[](1);
        symbols[0] = symbol;
        return getPricesFromMsg(symbols)[0];
    }

    function getPricesFromMsg(bytes32[] memory symbols)
        internal
        view
        returns (uint256[] memory)
    {
        // The structure of calldata witn n - data items:
        // The data that is signed (symbols, values, timestamp) are inside the {} brackets
        // [origina_call_data| ?]{[[symbol | 32][value | 32] | n times][timestamp | 32]}[size | 1][signature | 65]

        // 1. First we extract dataSize - the number of data items (symbol,value pairs) in the message
        uint8 dataSize; //Number of data entries
        assembly {
            // Calldataload loads slots of 32 bytes
            // The last 65 bytes are for signature
            // We load the previous 32 bytes and automatically take the 2 least significant ones (casting to uint16)
            dataSize := calldataload(sub(calldatasize(), 97))
        }

        // 2. We calculate the size of signable message expressed in bytes
        // ((symbolLen(32) + valueLen(32)) * dataSize + timeStamp length
        uint16 messageLength = uint16(dataSize) * 64 + 32; //Length of data message in bytes

        // 3. We extract the signableMessage

        // (That's the high level equivalent 2k gas more expensive)
        // bytes memory rawData = msg.data.slice(msg.data.length - messageLength - 65, messageLength);

        bytes memory signableMessage;
        assembly {
            signableMessage := mload(0x40)
            mstore(signableMessage, messageLength)
            // The starting point is callDataSize minus length of data(messageLength), signature(65) and size(1) = 66
            calldatacopy(
                add(signableMessage, 0x20),
                sub(calldatasize(), add(messageLength, 66)),
                messageLength
            )
            mstore(0x40, add(signableMessage, 0x20))
        }

        // 4. We first hash the raw message and then hash it again with the prefix
        // Following the https://github.com/ethereum/eips/issues/191 standard
        bytes32 hash = keccak256(signableMessage);
        bytes32 hashWithPrefix = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );

        // 5. We extract the off-chain signature from calldata

        // (That's the high level equivalent 2k gas more expensive)
        // bytes memory signature = msg.data.slice(msg.data.length - 65, 65);
        bytes memory signature;
        assembly {
            signature := mload(0x40)
            mstore(signature, 65)
            calldatacopy(add(signature, 0x20), sub(calldatasize(), 65), 65)
            mstore(0x40, add(signature, 0x20))
        }

        // 6. We verify the off-chain signature against on-chain hashed data

        address signer = hashWithPrefix.recover(signature);
        require(isSignerAuthorized(signer), "Signer not authorized");

        // 7. We extract timestamp from callData

        uint256 dataTimestamp;
        assembly {
            // Calldataload loads slots of 32 bytes
            // The last 65 bytes are for signature + 1 for data size
            // We load the previous 32 bytes
            dataTimestamp := calldataload(sub(calldatasize(), 98))
        }

        // 8. We validate timestamp
        require(isTimestampValid(dataTimestamp), "Data timestamp is invalid");

        return _readFromCallData(symbols, uint256(dataSize), messageLength);
    }

    function _readFromCallData(
        bytes32[] memory symbols,
        uint256 dataSize,
        uint16 messageLength
    ) private pure returns (uint256[] memory) {
        uint256[] memory values;
        uint256 i;
        uint256 j;
        uint256 readyAssets;
        bytes32 currentSymbol;

        // We iterate directly through call data to extract the values for symbols
        assembly {
            let start := sub(calldatasize(), add(messageLength, 66))

            values := mload(0x40)
            mstore(values, mload(symbols))
            mstore(0x40, add(add(values, 0x20), mul(mload(symbols), 0x20)))

            for {
                i := 0
            } lt(i, mload(symbols)) {
                i := add(i, 1)
            } {
                currentSymbol := mload(add(add(symbols, 32), mul(i, 32)))
                for {
                    j := 0
                } lt(j, dataSize) {
                    j := add(j, 1)
                } {
                    if eq(calldataload(add(start, mul(j, 64))), currentSymbol) {
                        mstore(
                            add(add(values, 32), mul(i, 32)),
                            calldataload(add(add(start, mul(j, 64)), 32))
                        )
                        readyAssets := add(readyAssets, 1)
                    }

                    if eq(readyAssets, mload(symbols)) {
                        i := dataSize
                    }
                }
            }
        }

        return (values);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "./RedstoneConsumerBase.sol";

/**
 * @title The base contract for Redstone consumers' contracts that allows to
 * securely calculate numeric redstone oracle values
 * @author The Redstone Oracles team
 * @dev This contract can extend other contracts to allow them
 * securely fetch Redstone oracle data from transactions calldata
 */
abstract contract RedstoneConsumerNumericBase is RedstoneConsumerBase {
  /**
   * @dev This function can be used in a consumer contract to securely extract an
   * oracle value for a given data feed id. Security is achieved by
   * signatures verification, timestamp validation, and aggregating values
   * from different authorised signers into a single numeric value. If any of the
   * required conditions do not match, the function will revert.
   * Note! This function expects that tx calldata contains redstone payload in the end
   * Learn more about redstone payload here: https://github.com/redstone-finance/redstone-oracles-monorepo/tree/main/packages/evm-connector#readme
   * @param dataFeedId bytes32 value that uniquely identifies the data feed
   * @return Extracted and verified numeric oracle value for the given data feed id
   */
  function getOracleNumericValueFromTxMsg(bytes32 dataFeedId)
    internal
    view
    virtual
    returns (uint256)
  {
    bytes32[] memory dataFeedIds = new bytes32[](1);
    dataFeedIds[0] = dataFeedId;
    return getOracleNumericValuesFromTxMsg(dataFeedIds)[0];
  }

  /**
   * @dev This function can be used in a consumer contract to securely extract several
   * numeric oracle values for a given array of data feed ids. Security is achieved by
   * signatures verification, timestamp validation, and aggregating values
   * from different authorised signers into a single numeric value. If any of the
   * required conditions do not match, the function will revert.
   * Note! This function expects that tx calldata contains redstone payload in the end
   * Learn more about redstone payload here: https://github.com/redstone-finance/redstone-oracles-monorepo/tree/main/packages/evm-connector#readme
   * @param dataFeedIds An array of unique data feed identifiers
   * @return An array of the extracted and verified oracle values in the same order
   * as they are requested in the dataFeedIds array
   */
  function getOracleNumericValuesFromTxMsg(bytes32[] memory dataFeedIds)
    internal
    view
    virtual
    returns (uint256[] memory)
  {
    return _securelyExtractOracleValuesFromTxMsg(dataFeedIds);
  }

  /**
   * @dev This function works similarly to the `getOracleNumericValuesFromTxMsg` with the
   * only difference that it allows to request oracle data for an array of data feeds
   * that may contain duplicates
   * 
   * @param dataFeedIdsWithDuplicates An array of data feed identifiers (duplicates are allowed)
   * @return An array of the extracted and verified oracle values in the same order
   * as they are requested in the dataFeedIdsWithDuplicates array
   */
  function getOracleNumericValuesWithDuplicatesFromTxMsg(bytes32[] memory dataFeedIdsWithDuplicates) internal view returns (uint256[] memory) {
    // Building an array without duplicates
    bytes32[] memory dataFeedIdsWithoutDuplicates = new bytes32[](dataFeedIdsWithDuplicates.length);
    bool alreadyIncluded;
    uint256 uniqueDataFeedIdsCount = 0;

    for (uint256 indexWithDup = 0; indexWithDup < dataFeedIdsWithDuplicates.length; indexWithDup++) {
      // Checking if current element is already included in `dataFeedIdsWithoutDuplicates`
      alreadyIncluded = false;
      for (uint256 indexWithoutDup = 0; indexWithoutDup < uniqueDataFeedIdsCount; indexWithoutDup++) {
        if (dataFeedIdsWithoutDuplicates[indexWithoutDup] == dataFeedIdsWithDuplicates[indexWithDup]) {
          alreadyIncluded = true;
          break;
        }
      }

      // Adding if not included
      if (!alreadyIncluded) {
        dataFeedIdsWithoutDuplicates[uniqueDataFeedIdsCount] = dataFeedIdsWithDuplicates[indexWithDup];
        uniqueDataFeedIdsCount++;
      }
    }

    // Overriding dataFeedIdsWithoutDuplicates.length
    // Equivalent to: dataFeedIdsWithoutDuplicates.length = uniqueDataFeedIdsCount;
    assembly {
      mstore(dataFeedIdsWithoutDuplicates, uniqueDataFeedIdsCount)
    }

    // Requesting oracle values (without duplicates)
    uint256[] memory valuesWithoutDuplicates = getOracleNumericValuesFromTxMsg(dataFeedIdsWithoutDuplicates);

    // Preparing result values array
    uint256[] memory valuesWithDuplicates = new uint256[](dataFeedIdsWithDuplicates.length);
    for (uint256 indexWithDup = 0; indexWithDup < dataFeedIdsWithDuplicates.length; indexWithDup++) {
      for (uint256 indexWithoutDup = 0; indexWithoutDup < dataFeedIdsWithoutDuplicates.length; indexWithoutDup++) {
        if (dataFeedIdsWithDuplicates[indexWithDup] == dataFeedIdsWithoutDuplicates[indexWithoutDup]) {
          valuesWithDuplicates[indexWithDup] = valuesWithoutDuplicates[indexWithoutDup];
          break;
        }
      }
    }

    return valuesWithDuplicates;
  }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./RedstoneConstants.sol";
import "./RedstoneDefaultsLib.sol";
import "./CalldataExtractor.sol";
import "../libs/BitmapLib.sol";
import "../libs/SignatureLib.sol";

/**
 * @title The base contract with the main Redstone logic
 * @author The Redstone Oracles team
 * @dev Do not use this contract directly in consumer contracts, take a
 * look at `RedstoneConsumerNumericBase` and `RedstoneConsumerBytesBase` instead
 */
abstract contract RedstoneConsumerBase is CalldataExtractor {
  using SafeMath for uint256;

  /* ========== VIRTUAL FUNCTIONS (MAY BE OVERRIDEN IN CHILD CONTRACTS) ========== */

  /**
   * @dev This function must be implemented by the child consumer contract.
   * It should return a unique index for a given signer address if the signer
   * is authorised, otherwise it should revert
   * @param receviedSigner The address of a signer, recovered from ECDSA signature
   * @return Unique index for a signer in the range [0..255]
   */
  function getAuthorisedSignerIndex(address receviedSigner) public view virtual returns (uint8);

  /**
   * @dev This function may be overriden by the child consumer contract.
   * It should validate the timestamp against the current time (block.timestamp)
   * It should revert with a helpful message if the timestamp is not valid
   * @param receivedTimestampMilliseconds Timestamp extracted from calldata
   */
  function validateTimestamp(uint256 receivedTimestampMilliseconds) public view virtual {
    RedstoneDefaultsLib.validateTimestamp(receivedTimestampMilliseconds);
  }

  /**
   * @dev This function should be overriden by the child consumer contract.
   * @return The minimum required value of unique authorised signers
   */
  function getUniqueSignersThreshold() public view virtual returns (uint8) {
    return 1;
  }

  /**
   * @dev This function may be overriden by the child consumer contract.
   * It should aggregate values from different signers to a single uint value.
   * By default, it calculates the median value
   * @param values An array of uint256 values from different signers
   * @return Result of the aggregation in the form of a single number
   */
  function aggregateValues(uint256[] memory values) public view virtual returns (uint256) {
    return RedstoneDefaultsLib.aggregateValues(values);
  }

  /* ========== FUNCTIONS WITH IMPLEMENTATION (CAN NOT BE OVERRIDEN) ========== */

  /**
   * @dev This is an internal helpful function for secure extraction oracle values
   * from the tx calldata. Security is achieved by signatures verification, timestamp
   * validation, and aggregating values from different authorised signers into a
   * single numeric value. If any of the required conditions (e.g. too old timestamp or
   * insufficient number of autorised signers) do not match, the function will revert.
   *
   * Note! You should not call this function in a consumer contract. You can use
   * `getOracleNumericValuesFromTxMsg` or `getOracleNumericValueFromTxMsg` instead.
   *
   * @param dataFeedIds An array of unique data feed identifiers
   * @return An array of the extracted and verified oracle values in the same order
   * as they are requested in dataFeedIds array
   */
  function _securelyExtractOracleValuesFromTxMsg(bytes32[] memory dataFeedIds)
    internal
    view
    returns (uint256[] memory)
  {
    // Initializing helpful variables and allocating memory
    uint256[] memory uniqueSignerCountForDataFeedIds = new uint256[](dataFeedIds.length);
    uint256[] memory signersBitmapForDataFeedIds = new uint256[](dataFeedIds.length);
    uint256[][] memory valuesForDataFeeds = new uint256[][](dataFeedIds.length);
    for (uint256 i = 0; i < dataFeedIds.length; i++) {
      // The line below is commented because newly allocated arrays are filled with zeros
      // But we left it for better readability
      // signersBitmapForDataFeedIds[i] = 0; // <- setting to an empty bitmap
      valuesForDataFeeds[i] = new uint256[](getUniqueSignersThreshold());
    }

    // Extracting the number of data packages from calldata
    uint256 calldataNegativeOffset = _extractByteSizeOfUnsignedMetadata();
    uint256 dataPackagesCount = _extractDataPackagesCountFromCalldata(calldataNegativeOffset);
    calldataNegativeOffset += DATA_PACKAGES_COUNT_BS;

    // Saving current free memory pointer
    uint256 freeMemPtr;
    assembly {
      freeMemPtr := mload(FREE_MEMORY_PTR)
    }

    // Data packages extraction in a loop
    for (uint256 dataPackageIndex = 0; dataPackageIndex < dataPackagesCount; dataPackageIndex++) {
      // Extract data package details and update calldata offset
      uint256 dataPackageByteSize = _extractDataPackage(
        dataFeedIds,
        uniqueSignerCountForDataFeedIds,
        signersBitmapForDataFeedIds,
        valuesForDataFeeds,
        calldataNegativeOffset
      );
      calldataNegativeOffset += dataPackageByteSize;

      // Shifting memory pointer back to the "safe" value
      assembly {
        mstore(FREE_MEMORY_PTR, freeMemPtr)
      }
    }

    // Validating numbers of unique signers and calculating aggregated values for each dataFeedId
    return _getAggregatedValues(valuesForDataFeeds, uniqueSignerCountForDataFeedIds);
  }

  /**
   * @dev This is a private helpful function, which extracts data for a data package based
   * on the given negative calldata offset, verifies them, and in the case of successful
   * verification updates the corresponding data package values in memory
   *
   * @param dataFeedIds an array of unique data feed identifiers
   * @param uniqueSignerCountForDataFeedIds an array with the numbers of unique signers
   * for each data feed
   * @param signersBitmapForDataFeedIds an array of sginers bitmaps for data feeds
   * @param valuesForDataFeeds 2-dimensional array, valuesForDataFeeds[i][j] contains
   * j-th value for the i-th data feed
   * @param calldataNegativeOffset negative calldata offset for the given data package
   *
   * @return An array of the aggregated values
   */
  function _extractDataPackage(
    bytes32[] memory dataFeedIds,
    uint256[] memory uniqueSignerCountForDataFeedIds,
    uint256[] memory signersBitmapForDataFeedIds,
    uint256[][] memory valuesForDataFeeds,
    uint256 calldataNegativeOffset
  ) private view returns (uint256) {
    uint256 signerIndex;

    (
      uint256 dataPointsCount,
      uint256 eachDataPointValueByteSize
    ) = _extractDataPointsDetailsForDataPackage(calldataNegativeOffset);

    // We use scopes to resolve problem with too deep stack
    {
      uint48 extractedTimestamp;
      address signerAddress;
      bytes32 signedHash;
      bytes memory signedMessage;
      uint256 signedMessageBytesCount;

      signedMessageBytesCount = dataPointsCount.mul(eachDataPointValueByteSize + DATA_POINT_SYMBOL_BS)
        + DATA_PACKAGE_WITHOUT_DATA_POINTS_AND_SIG_BS;

      uint256 timestampCalldataOffset = msg.data.length.sub(
        calldataNegativeOffset + TIMESTAMP_NEGATIVE_OFFSET_IN_DATA_PACKAGE_WITH_STANDARD_SLOT_BS);

      uint256 signedMessageCalldataOffset = msg.data.length.sub(
        calldataNegativeOffset + SIG_BS + signedMessageBytesCount);

      assembly {
        // Extracting the signed message
        signedMessage := extractBytesFromCalldata(
          signedMessageCalldataOffset,
          signedMessageBytesCount
        )

        // Hashing the signed message
        signedHash := keccak256(add(signedMessage, BYTES_ARR_LEN_VAR_BS), signedMessageBytesCount)

        // Extracting timestamp
        extractedTimestamp := calldataload(timestampCalldataOffset)

        function initByteArray(bytesCount) -> ptr {
          ptr := mload(FREE_MEMORY_PTR)
          mstore(ptr, bytesCount)
          ptr := add(ptr, BYTES_ARR_LEN_VAR_BS)
          mstore(FREE_MEMORY_PTR, add(ptr, bytesCount))
        }

        function extractBytesFromCalldata(offset, bytesCount) -> extractedBytes {
          let extractedBytesStartPtr := initByteArray(bytesCount)
          calldatacopy(
            extractedBytesStartPtr,
            offset,
            bytesCount
          )
          extractedBytes := sub(extractedBytesStartPtr, BYTES_ARR_LEN_VAR_BS)
        }
      }

      // Validating timestamp
      validateTimestamp(extractedTimestamp);

      // Verifying the off-chain signature against on-chain hashed data
      signerAddress = SignatureLib.recoverSignerAddress(
        signedHash,
        calldataNegativeOffset + SIG_BS
      );
      signerIndex = getAuthorisedSignerIndex(signerAddress);
    }

    // Updating helpful arrays
    {
      bytes32 dataPointDataFeedId;
      uint256 dataPointValue;
      for (uint256 dataPointIndex = 0; dataPointIndex < dataPointsCount; dataPointIndex++) {
        // Extracting data feed id and value for the current data point
        (dataPointDataFeedId, dataPointValue) = _extractDataPointValueAndDataFeedId(
          calldataNegativeOffset,
          eachDataPointValueByteSize,
          dataPointIndex
        );

        for (
          uint256 dataFeedIdIndex = 0;
          dataFeedIdIndex < dataFeedIds.length;
          dataFeedIdIndex++
        ) {
          if (dataPointDataFeedId == dataFeedIds[dataFeedIdIndex]) {
            uint256 bitmapSignersForDataFeedId = signersBitmapForDataFeedIds[dataFeedIdIndex];

            if (
              !BitmapLib.getBitFromBitmap(bitmapSignersForDataFeedId, signerIndex) && /* current signer was not counted for current dataFeedId */
              uniqueSignerCountForDataFeedIds[dataFeedIdIndex] < getUniqueSignersThreshold()
            ) {
              // Increase unique signer counter
              uniqueSignerCountForDataFeedIds[dataFeedIdIndex]++;

              // Add new value
              valuesForDataFeeds[dataFeedIdIndex][
                uniqueSignerCountForDataFeedIds[dataFeedIdIndex] - 1
              ] = dataPointValue;

              // Update signers bitmap
              signersBitmapForDataFeedIds[dataFeedIdIndex] = BitmapLib.setBitInBitmap(
                bitmapSignersForDataFeedId,
                signerIndex
              );
            }

            // Breaking, as there couldn't be several indexes for the same feed ID
            break;
          }
        }
      }
    }

    // Return total data package byte size
    return
      DATA_PACKAGE_WITHOUT_DATA_POINTS_BS +
      (eachDataPointValueByteSize + DATA_POINT_SYMBOL_BS) *
      dataPointsCount;
  }

  /**
   * @dev This is a private helpful function, which aggregates values from different
   * authorised signers for the given arrays of values for each data feed
   *
   * @param valuesForDataFeeds 2-dimensional array, valuesForDataFeeds[i][j] contains
   * j-th value for the i-th data feed
   * @param uniqueSignerCountForDataFeedIds an array with the numbers of unique signers
   * for each data feed
   *
   * @return An array of the aggregated values
   */
  function _getAggregatedValues(
    uint256[][] memory valuesForDataFeeds,
    uint256[] memory uniqueSignerCountForDataFeedIds
  ) private view returns (uint256[] memory) {
    uint256[] memory aggregatedValues = new uint256[](valuesForDataFeeds.length);
    uint256 uniqueSignersThreshold = getUniqueSignersThreshold();

    for (uint256 dataFeedIndex = 0; dataFeedIndex < valuesForDataFeeds.length; dataFeedIndex++) {
      if (uniqueSignerCountForDataFeedIds[dataFeedIndex] < uniqueSignersThreshold) {
        revert InsufficientNumberOfUniqueSigners(
          uniqueSignerCountForDataFeedIds[dataFeedIndex],
          uniqueSignersThreshold);
      }
      uint256 aggregatedValueForDataFeedId = aggregateValues(valuesForDataFeeds[dataFeedIndex]);
      aggregatedValues[dataFeedIndex] = aggregatedValueForDataFeedId;
    }

    return aggregatedValues;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

/**
 * @title The base contract with helpful constants
 * @author The Redstone Oracles team
 * @dev It mainly contains redstone-related values, which improve readability
 * of other contracts (e.g. CalldataExtractor and RedstoneConsumerBase)
 */
contract RedstoneConstants {
  // === Abbreviations ===
  // BS - Bytes size
  // PTR - Pointer (memory location)
  // SIG - Signature

  // Solidity and YUL constants
  uint256 internal constant STANDARD_SLOT_BS = 32;
  uint256 internal constant FREE_MEMORY_PTR = 0x40;
  uint256 internal constant BYTES_ARR_LEN_VAR_BS = 32;
  uint256 internal constant FUNCTION_SIGNATURE_BS = 4;
  uint256 internal constant REVERT_MSG_OFFSET = 68; // Revert message structure described here: https://ethereum.stackexchange.com/a/66173/106364
  uint256 internal constant STRING_ERR_MESSAGE_MASK = 0x08c379a000000000000000000000000000000000000000000000000000000000;

  // RedStone protocol consts
  uint256 internal constant SIG_BS = 65;
  uint256 internal constant TIMESTAMP_BS = 6;
  uint256 internal constant DATA_PACKAGES_COUNT_BS = 2;
  uint256 internal constant DATA_POINTS_COUNT_BS = 3;
  uint256 internal constant DATA_POINT_VALUE_BYTE_SIZE_BS = 4;
  uint256 internal constant DATA_POINT_SYMBOL_BS = 32;
  uint256 internal constant DEFAULT_DATA_POINT_VALUE_BS = 32;
  uint256 internal constant UNSGINED_METADATA_BYTE_SIZE_BS = 3;
  uint256 internal constant REDSTONE_MARKER_BS = 9; // byte size of 0x000002ed57011e0000
  uint256 internal constant REDSTONE_MARKER_MASK = 0x0000000000000000000000000000000000000000000000000002ed57011e0000;

  // Derived values (based on consts)
  uint256 internal constant TIMESTAMP_NEGATIVE_OFFSET_IN_DATA_PACKAGE_WITH_STANDARD_SLOT_BS = 104; // SIG_BS + DATA_POINTS_COUNT_BS + DATA_POINT_VALUE_BYTE_SIZE_BS + STANDARD_SLOT_BS
  uint256 internal constant DATA_PACKAGE_WITHOUT_DATA_POINTS_BS = 78; // DATA_POINT_VALUE_BYTE_SIZE_BS + TIMESTAMP_BS + DATA_POINTS_COUNT_BS + SIG_BS
  uint256 internal constant DATA_PACKAGE_WITHOUT_DATA_POINTS_AND_SIG_BS = 13; // DATA_POINT_VALUE_BYTE_SIZE_BS + TIMESTAMP_BS + DATA_POINTS_COUNT_BS
  uint256 internal constant REDSTONE_MARKER_BS_PLUS_STANDARD_SLOT_BS = 41; // REDSTONE_MARKER_BS + STANDARD_SLOT_BS

  // Error messages
  error CalldataOverOrUnderFlow();
  error IncorrectUnsignedMetadataSize();
  error InsufficientNumberOfUniqueSigners(uint256 receviedSignersCount, uint256 requiredSignersCount);
  error EachSignerMustProvideTheSameValue();
  error EmptyCalldataPointersArr();
  error InvalidCalldataPointer();
  error CalldataMustHaveValidPayload();
  error SignerNotAuthorised(address receivedSigner);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "../libs/NumericArrayLib.sol";

/**
 * @title Default implementations of virtual redstone consumer base functions
 * @author The Redstone Oracles team
 */
library RedstoneDefaultsLib {
  uint256 constant DEFAULT_MAX_DATA_TIMESTAMP_DELAY_SECONDS = 3 minutes;
  uint256 constant DEFAULT_MAX_DATA_TIMESTAMP_AHEAD_SECONDS = 1 minutes;

  error TimestampFromTooLongFuture(uint256 receivedTimestampSeconds, uint256 blockTimestamp);
  error TimestampIsTooOld(uint256 receivedTimestampSeconds, uint256 blockTimestamp);

  function validateTimestamp(uint256 receivedTimestampMilliseconds) internal view {
    // Getting data timestamp from future seems quite unlikely
    // But we've already spent too much time with different cases
    // Where block.timestamp was less than dataPackage.timestamp.
    // Some blockchains may case this problem as well.
    // That's why we add MAX_BLOCK_TIMESTAMP_DELAY
    // and allow data "from future" but with a small delay
    uint256 receivedTimestampSeconds = receivedTimestampMilliseconds / 1000;

    if (block.timestamp < receivedTimestampSeconds) {
      if ((receivedTimestampSeconds - block.timestamp) > DEFAULT_MAX_DATA_TIMESTAMP_AHEAD_SECONDS) {
        revert TimestampFromTooLongFuture(receivedTimestampSeconds, block.timestamp);
      }
    } else if ((block.timestamp - receivedTimestampSeconds) > DEFAULT_MAX_DATA_TIMESTAMP_DELAY_SECONDS) {
      revert TimestampIsTooOld(receivedTimestampSeconds, block.timestamp);
    }
  }

  function aggregateValues(uint256[] memory values) internal pure returns (uint256) {
    return NumericArrayLib.pickMedian(values);
  }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./RedstoneConstants.sol";

/**
 * @title The base contract with the main logic of data extraction from calldata
 * @author The Redstone Oracles team
 * @dev This contract was created to reuse the same logic in the RedstoneConsumerBase
 * and the ProxyConnector contracts
 */
contract CalldataExtractor is RedstoneConstants {
  using SafeMath for uint256;

  function _extractByteSizeOfUnsignedMetadata() internal pure returns (uint256) {
    // Checking if the calldata ends with the RedStone marker
    bool hasValidRedstoneMarker;
    assembly {
      let calldataLast32Bytes := calldataload(sub(calldatasize(), STANDARD_SLOT_BS))
      hasValidRedstoneMarker := eq(
        REDSTONE_MARKER_MASK,
        and(calldataLast32Bytes, REDSTONE_MARKER_MASK)
      )
    }
    if (!hasValidRedstoneMarker) {
      revert CalldataMustHaveValidPayload();
    }

    // Using uint24, because unsigned metadata byte size number has 3 bytes
    uint24 unsignedMetadataByteSize;
    if (REDSTONE_MARKER_BS_PLUS_STANDARD_SLOT_BS > msg.data.length) {
      revert CalldataOverOrUnderFlow();
    }
    assembly {
      unsignedMetadataByteSize := calldataload(
        sub(calldatasize(), REDSTONE_MARKER_BS_PLUS_STANDARD_SLOT_BS)
      )
    }
    uint256 calldataNegativeOffset = unsignedMetadataByteSize
      + UNSGINED_METADATA_BYTE_SIZE_BS
      + REDSTONE_MARKER_BS;
    if (calldataNegativeOffset + DATA_PACKAGES_COUNT_BS > msg.data.length) {
      revert IncorrectUnsignedMetadataSize();
    }
    return calldataNegativeOffset;
  }

  // We return uint16, because unsigned metadata byte size number has 2 bytes
  function _extractDataPackagesCountFromCalldata(uint256 calldataNegativeOffset)
    internal
    pure
    returns (uint16 dataPackagesCount)
  {
    uint256 calldataNegativeOffsetWithStandardSlot = calldataNegativeOffset + STANDARD_SLOT_BS;
    if (calldataNegativeOffsetWithStandardSlot > msg.data.length) {
      revert CalldataOverOrUnderFlow();
    }
    assembly {
      dataPackagesCount := calldataload(
        sub(calldatasize(), calldataNegativeOffsetWithStandardSlot)
      )
    }
    return dataPackagesCount;
  }

  function _extractDataPointValueAndDataFeedId(
    uint256 calldataNegativeOffsetForDataPackage,
    uint256 defaultDataPointValueByteSize,
    uint256 dataPointIndex
  ) internal pure virtual returns (bytes32 dataPointDataFeedId, uint256 dataPointValue) {
    uint256 negativeOffsetToDataPoints = calldataNegativeOffsetForDataPackage + DATA_PACKAGE_WITHOUT_DATA_POINTS_BS;
    uint256 dataPointNegativeOffset = negativeOffsetToDataPoints.add(
      (1 + dataPointIndex).mul((defaultDataPointValueByteSize + DATA_POINT_SYMBOL_BS))
    );
    uint256 dataPointCalldataOffset = msg.data.length.sub(dataPointNegativeOffset);
    assembly {
      dataPointDataFeedId := calldataload(dataPointCalldataOffset)
      dataPointValue := calldataload(add(dataPointCalldataOffset, DATA_POINT_SYMBOL_BS))
    }
  }

  function _extractDataPointsDetailsForDataPackage(uint256 calldataNegativeOffsetForDataPackage)
    internal
    pure
    returns (uint256 dataPointsCount, uint256 eachDataPointValueByteSize)
  {
    // Using uint24, because data points count byte size number has 3 bytes
    uint24 dataPointsCount_;

    // Using uint32, because data point value byte size has 4 bytes
    uint32 eachDataPointValueByteSize_;

    // Extract data points count
    uint256 negativeCalldataOffset = calldataNegativeOffsetForDataPackage + SIG_BS;
    uint256 calldataOffset = msg.data.length.sub(negativeCalldataOffset + STANDARD_SLOT_BS);
    assembly {
      dataPointsCount_ := calldataload(calldataOffset)
    }

    // Extract each data point value size
    calldataOffset = calldataOffset.sub(DATA_POINTS_COUNT_BS);
    assembly {
      eachDataPointValueByteSize_ := calldataload(calldataOffset)
    }

    // Prepare returned values
    dataPointsCount = dataPointsCount_;
    eachDataPointValueByteSize = eachDataPointValueByteSize_;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library BitmapLib {
  function setBitInBitmap(uint256 bitmap, uint256 bitIndex) internal pure returns (uint256) {
    return bitmap | (1 << bitIndex);
  }

  function getBitFromBitmap(uint256 bitmap, uint256 bitIndex) internal pure returns (bool) {
    uint256 bitAtIndex = bitmap & (1 << bitIndex);
    return bitAtIndex > 0;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library SignatureLib {
  uint256 constant ECDSA_SIG_R_BS = 32;
  uint256 constant ECDSA_SIG_S_BS = 32;

  function recoverSignerAddress(bytes32 signedHash, uint256 signatureCalldataNegativeOffset)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      let signatureCalldataStartPos := sub(calldatasize(), signatureCalldataNegativeOffset)
      r := calldataload(signatureCalldataStartPos)
      signatureCalldataStartPos := add(signatureCalldataStartPos, ECDSA_SIG_R_BS)
      s := calldataload(signatureCalldataStartPos)
      signatureCalldataStartPos := add(signatureCalldataStartPos, ECDSA_SIG_S_BS)
      v := byte(0, calldataload(signatureCalldataStartPos)) // last byte of the signature memory array
    }
    return ecrecover(signedHash, v, r, s);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library NumericArrayLib {
  // This function sort array in memory using bubble sort algorithm,
  // which performs even better than quick sort for small arrays

  uint256 constant BYTES_ARR_LEN_VAR_BS = 32;
  uint256 constant UINT256_VALUE_BS = 32;

  error CanNotPickMedianOfEmptyArray();

  // This function modifies the array
  function pickMedian(uint256[] memory arr) internal pure returns (uint256) {
    if (arr.length == 0) {
      revert CanNotPickMedianOfEmptyArray();
    }
    sort(arr);
    uint256 middleIndex = arr.length / 2;
    if (arr.length % 2 == 0) {
      uint256 sum = SafeMath.add(arr[middleIndex - 1], arr[middleIndex]);
      return sum / 2;
    } else {
      return arr[middleIndex];
    }
  }

  function sort(uint256[] memory arr) internal pure {
    assembly {
      let arrLength := mload(arr)
      let valuesPtr := add(arr, BYTES_ARR_LEN_VAR_BS)
      let endPtr := add(valuesPtr, mul(arrLength, UINT256_VALUE_BS))
      for {
        let arrIPtr := valuesPtr
      } lt(arrIPtr, endPtr) {
        arrIPtr := add(arrIPtr, UINT256_VALUE_BS) // arrIPtr += 32
      } {
        for {
          let arrJPtr := valuesPtr
        } lt(arrJPtr, arrIPtr) {
          arrJPtr := add(arrJPtr, UINT256_VALUE_BS) // arrJPtr += 32
        } {
          let arrI := mload(arrIPtr)
          let arrJ := mload(arrJPtr)
          if lt(arrI, arrJ) {
            mstore(arrIPtr, arrJ)
            mstore(arrJPtr, arrI)
          }
        }
      }
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of functions to safely cast uint256 numbers to smaller uint bit numbers.
 * @dev We use solidity to optimize the gas consumption, and the functions will revert without any reason.
 */
library SafeCastLib {
    /**
     * @notice Casts a uint256 to uint128 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint128
     * @return y The uint128 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**128 - 1
     */
    function toUint128(uint256 x) internal pure returns (uint128 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(128, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint112 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint112
     * @return y The uint112 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**112 - 1
     */
    function toUint112(uint256 x) internal pure returns (uint112 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(112, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint96 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint96
     * @return y The uint96 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**96 - 1
     */
    function toUint96(uint256 x) internal pure returns (uint96 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(96, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint64 for memory optimization
     *
     * @param x The uint256 that will be casted to uint64
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**64 - 1
     */
    function toUint64(uint256 x) internal pure returns (uint64 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(64, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint32 for memory optimization
     *
     * @param x The uint256 that will be casted to uint32
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**32 - 1
     */
    function toUint32(uint256 x) internal pure returns (uint32 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(32, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of utility functions to perform mathematical operations.
 */
library MathLib {
    /// @notice The decimal houses of most ERC20 tokens and native tokens.
    uint256 private constant SCALAR = 1e18;

    /**
     * @notice It multiplies two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if iszero(or(iszero(x), eq(div(mul(x, y), x), y))) {
                revert(0, 0)
            }

            z := div(mul(x, y), SCALAR)
        }
    }

    /**
     * @notice It divides two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. It does not guard against underflows because the EVM div opcode cannot underflow. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if or(
                iszero(y),
                iszero(or(iszero(x), eq(div(mul(x, SCALAR), x), SCALAR)))
            ) {
                revert(0, 0)
            }
            z := div(mul(x, SCALAR), y)
        }
    }

    /**
     * @notice It returns a version of the first argument with 18 decimals.
     * @dev This function protects against shadow integer overflow.
     * @param x Number that will be manipulated to have 18 decimals.
     * @param decimals The current decimal houses of the first argument
     * @return z A version of the first argument with 18 decimals.
     */
    function adjust(uint256 x, uint8 decimals) internal pure returns (uint256) {
        /// If the number has 18 decimals, we do not need to do anything.
        /// Since {mulDiv} protects against shadow overflow, we can first add 18 decimal houses and then remove the current decimal houses.
        return decimals == 18 ? x : mulDiv(x, SCALAR, 10**decimals);
    }

    /**
     * @notice It adds two numbers.
     * @dev This function has no protection against integer overflow to optimize gas consumption. It must only be used when we are 100% certain it will not overflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(x, y)
        }
    }

    /**
     * @notice It subtracts two numbers.
     * @dev This function has no protection against integer underflow to optimize gas consumption. It must only be used when we are 100% certain it will not underflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := sub(x, y)
        }
    }

    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // Handle division by zero
        require(denominator > 0);

        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remiander Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Short circuit 256 by 256 division
        // This saves gas when a * b is small, at the cost of making the
        // large case a bit more expensive. Depending on your use case you
        // may want to remove this short circuit and always go through the
        // 512 bit path.
        if (prod1 == 0) {
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Handle overflow, the result must be < 2**256
        require(prod1 < denominator);

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        // Note mulmod(_, _, 0) == 0
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1 unless denominator is zero, then twos is zero.
        uint256 twos = denominator & (~denominator + 1);
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        // If denominator is zero the inverse starts with 2
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson itteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256
        // If denominator is zero, inv is now 128

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /**
     * @notice This function finds the square root of a number.
     * @dev It was taken from https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol.
     * @param x This function will find the square root of this number.
     * @return The square root of x.
     */
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }

    /**
     * @notice It returns the smaller number between the two arguments.
     * @param x Any uint256 number.
     * @param y Any uint256 number.
     * @return It returns whichever is smaller between x and y.
     */
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}