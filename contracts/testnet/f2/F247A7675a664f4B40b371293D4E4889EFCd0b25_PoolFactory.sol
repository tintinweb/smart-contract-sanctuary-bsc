// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/factory/IPoolFactory.sol";
import "../interfaces/trader/ITraderPool.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "@dlsl/dev-modules/pool-contracts-registry/pool-factory/AbstractPoolFactory.sol";

import "../gov/GovPool.sol";
import "../gov/GovUserKeeper.sol";
import "../gov/settings/GovSettings.sol";
import "../gov/validators/GovValidators.sol";
import "../gov/GovPoolRegistry.sol";

import "../trader/BasicTraderPool.sol";
import "../trader/InvestTraderPool.sol";
import "../trader/TraderPoolRiskyProposal.sol";
import "../trader/TraderPoolInvestProposal.sol";
import "../trader/TraderPoolRegistry.sol";

import "../core/CoreProperties.sol";

import "../core/Globals.sol";

contract PoolFactory is IPoolFactory, AbstractPoolFactory {
    TraderPoolRegistry internal _traderPoolRegistry;
    GovPoolRegistry internal _govPoolRegistry;

    CoreProperties internal _coreProperties;

    event TraderPoolDeployed(
        string poolType,
        string symbol,
        string name,
        address at,
        address proposalContract,
        address trader,
        address basicToken,
        uint256 commission,
        string descriptionURL
    );

    function setDependencies(address contractsRegistry) public override {
        super.setDependencies(contractsRegistry);

        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        _traderPoolRegistry = TraderPoolRegistry(registry.getTraderPoolRegistryContract());
        _govPoolRegistry = GovPoolRegistry(registry.getGovPoolRegistryContract());
        _coreProperties = CoreProperties(registry.getCorePropertiesContract());
    }

    function deployGovPool(bool withValidators, GovPoolDeployParams calldata parameters)
        external
        override
    {
        string memory poolType = _govPoolRegistry.GOV_POOL_NAME();

        address settingsProxy = _deploy(
            address(_govPoolRegistry),
            _govPoolRegistry.SETTINGS_NAME()
        );
        address validatorsProxy;

        if (withValidators) {
            validatorsProxy = _deploy(
                address(_govPoolRegistry),
                _govPoolRegistry.VALIDATORS_NAME()
            );
        }

        address userKeeperProxy = _deploy(
            address(_govPoolRegistry),
            _govPoolRegistry.USER_KEEPER_NAME()
        );
        address poolProxy = _deploy(address(_govPoolRegistry), poolType);

        GovSettings(settingsProxy).__GovSettings_init(
            parameters.seetingsParams.internalProposalSetting,
            parameters.seetingsParams.defaultProposalSetting
        );
        GovUserKeeper(userKeeperProxy).__GovUserKeeper_init(
            parameters.userKeeperParams.tokenAddress,
            parameters.userKeeperParams.nftAddress,
            parameters.userKeeperParams.totalPowerInTokens,
            parameters.userKeeperParams.nftsTotalSupply
        );

        if (withValidators) {
            GovValidators(validatorsProxy).__GovValidators_init(
                parameters.validatorsParams.name,
                parameters.validatorsParams.symbol,
                parameters.validatorsParams.duration,
                parameters.validatorsParams.quorum,
                parameters.validatorsParams.validators,
                parameters.validatorsParams.balances
            );
        }

        GovPool(payable(poolProxy)).__GovPool_init(
            settingsProxy,
            userKeeperProxy,
            validatorsProxy,
            parameters.votesLimit,
            parameters.feePercentage,
            parameters.descriptionURL
        );

        GovSettings(settingsProxy).transferOwnership(poolProxy);
        GovUserKeeper(userKeeperProxy).transferOwnership(poolProxy);

        if (withValidators) {
            GovValidators(validatorsProxy).transferOwnership(poolProxy);
        }

        GovPool(payable(poolProxy)).transferOwnership(parameters.owner);

        _register(address(_govPoolRegistry), poolType, poolProxy);

        _govPoolRegistry.associateUserWithPool(parameters.owner, poolType, poolProxy);
    }

    function deployBasicPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external override {
        string memory poolType = _traderPoolRegistry.BASIC_POOL_NAME();
        ITraderPool.PoolParameters
            memory poolParameters = _validateAndConstructTraderPoolParameters(parameters);

        address proposalProxy = _deploy(
            address(_traderPoolRegistry),
            _traderPoolRegistry.RISKY_PROPOSAL_NAME()
        );
        address poolProxy = _deploy(address(_traderPoolRegistry), poolType);

        BasicTraderPool(poolProxy).__BasicTraderPool_init(
            name,
            symbol,
            poolParameters,
            proposalProxy
        );
        TraderPoolRiskyProposal(proposalProxy).__TraderPoolRiskyProposal_init(
            ITraderPoolProposal.ParentTraderPoolInfo(
                poolProxy,
                poolParameters.trader,
                poolParameters.baseToken,
                poolParameters.baseTokenDecimals
            )
        );

        _register(address(_traderPoolRegistry), poolType, poolProxy);
        _injectDependencies(address(_traderPoolRegistry), poolProxy);

        _traderPoolRegistry.associateUserWithPool(poolParameters.trader, poolType, poolProxy);

        emit TraderPoolDeployed(
            poolType,
            symbol,
            name,
            poolProxy,
            proposalProxy,
            poolParameters.trader,
            poolParameters.baseToken,
            poolParameters.commissionPercentage,
            poolParameters.descriptionURL
        );
    }

    function deployInvestPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external override {
        string memory poolType = _traderPoolRegistry.INVEST_POOL_NAME();
        ITraderPool.PoolParameters
            memory poolParameters = _validateAndConstructTraderPoolParameters(parameters);

        address proposalProxy = _deploy(
            address(_traderPoolRegistry),
            _traderPoolRegistry.INVEST_PROPOSAL_NAME()
        );
        address poolProxy = _deploy(address(_traderPoolRegistry), poolType);

        InvestTraderPool(poolProxy).__InvestTraderPool_init(
            name,
            symbol,
            poolParameters,
            proposalProxy
        );
        TraderPoolInvestProposal(proposalProxy).__TraderPoolInvestProposal_init(
            ITraderPoolProposal.ParentTraderPoolInfo(
                poolProxy,
                poolParameters.trader,
                poolParameters.baseToken,
                poolParameters.baseTokenDecimals
            )
        );

        _register(address(_traderPoolRegistry), poolType, poolProxy);
        _injectDependencies(address(_traderPoolRegistry), poolProxy);

        _traderPoolRegistry.associateUserWithPool(poolParameters.trader, poolType, poolProxy);

        emit TraderPoolDeployed(
            poolType,
            symbol,
            name,
            poolProxy,
            proposalProxy,
            poolParameters.trader,
            poolParameters.baseToken,
            poolParameters.commissionPercentage,
            poolParameters.descriptionURL
        );
    }

    function _validateAndConstructTraderPoolParameters(
        TraderPoolDeployParameters calldata parameters
    ) internal view returns (ITraderPool.PoolParameters memory poolParameters) {
        (uint256 general, uint256[] memory byPeriod) = _coreProperties.getTraderCommissions();

        require(parameters.trader != address(0), "PoolFactory: invalid trader address");
        require(
            !_coreProperties.isBlacklistedToken(parameters.baseToken),
            "PoolFactory: token is blacklisted"
        );
        require(
            parameters.commissionPercentage >= general &&
                parameters.commissionPercentage <= byPeriod[uint256(parameters.commissionPeriod)],
            "PoolFactory: Incorrect percentage"
        );

        poolParameters = ITraderPool.PoolParameters(
            parameters.descriptionURL,
            parameters.trader,
            parameters.privatePool,
            parameters.totalLPEmission,
            parameters.baseToken,
            ERC20(parameters.baseToken).decimals(),
            parameters.minimalInvestment,
            parameters.commissionPeriod,
            parameters.commissionPercentage
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../gov/settings/IGovSettings.sol";
import "../core/ICoreProperties.sol";

/**
 * This is the Factory contract for the trader and gov pools. Anyone can create a pool for themselves to become a trader
 * or a governance owner. There are 3 pools available: BasicTraderPool, InvestTraderPool and GovPool
 */
interface IPoolFactory {
    struct SettingsDeployParams {
        IGovSettings.ProposalSettings internalProposalSetting;
        IGovSettings.ProposalSettings defaultProposalSetting;
    }

    struct ValidatorsDeployParams {
        string name;
        string symbol;
        uint64 duration;
        uint128 quorum;
        address[] validators;
        uint256[] balances;
    }

    struct UserKeeperDeployParams {
        address tokenAddress;
        address nftAddress;
        uint256 totalPowerInTokens;
        uint256 nftsTotalSupply;
    }

    struct GovPoolDeployParams {
        SettingsDeployParams seetingsParams;
        ValidatorsDeployParams validatorsParams;
        UserKeeperDeployParams userKeeperParams;
        address owner;
        uint256 votesLimit;
        uint256 feePercentage;
        string descriptionURL;
    }

    /// @notice The parameters one can specify on the trader pool's creation
    /// @param descriptionURL the IPFS URL of the pool description
    /// @param trader the trader of the pool
    /// @param privatePool the publicity of the pool
    /// @param totalLPEmission maximal* emission of LP tokens that can be invested
    /// @param baseToken the address of the base token of the pool
    /// @param minimalInvestment the minimal allowed investment into the pool
    /// @param commissionPeriod the duration of the commission period
    /// @param commissionPercentage trader's commission percentage (including DEXE commission)
    struct TraderPoolDeployParameters {
        string descriptionURL;
        address trader;
        bool privatePool;
        uint256 totalLPEmission; // zero means unlimited
        address baseToken;
        uint256 minimalInvestment; // zero means any value
        ICoreProperties.CommissionPeriod commissionPeriod;
        uint256 commissionPercentage;
    }

    /// @notice The function to deploy gov pools
    /// @param withValidators if true deploys gov pool with validators
    /// @param parameters the pool deploy parameters
    function deployGovPool(bool withValidators, GovPoolDeployParams calldata parameters) external;

    /// @notice The function to deploy basic pools
    /// @param name the ERC20 name of the pool
    /// @param symbol the ERC20 symbol of the pool
    /// @param parameters the pool deploy parameters
    function deployBasicPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external;

    /// @notice The function to deploy invest pools
    /// @param name the ERC20 name of the pool
    /// @param symbol the ERC20 symbol of the pool
    /// @param parameters the pool deploy parameters
    function deployInvestPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../core/IPriceFeed.sol";
import "../core/ICoreProperties.sol";

/**
 * The TraderPool contract is a central business logic contract the DEXE platform is built around. The TraderPool represents
 * a collective pool where investors share its funds and the ownership. The share is represented with the LP tokens and the
 * income is made through the trader's activity. The pool itself is tidily integrated with the UniswapV2 protocol and the trader
 * is allowed to trade with the tokens in this pool. Several safety mechanisms are implemented here: Active Portfolio, Trader Leverage,
 * Proposals, Commissions horizon and simplified onchain PathFinder that protect the user funds
 */
interface ITraderPool {
    /// @notice The enum of exchange types
    /// @param FROM_EXACT the type corresponding to the exchangeFromExact function
    /// @param TO_EXACT the type corresponding to the exchangeToExact function
    enum ExchangeType {
        FROM_EXACT,
        TO_EXACT
    }

    /// @notice The struct that holds the parameters of this pool
    /// @param descriptionURL the IPFS URL of the description
    /// @param trader the address of trader of this pool
    /// @param privatePool the publicity of the pool. Of the pool is private, only private investors are allowed to invest into it
    /// @param totalLPEmission the total* number of pool's LP tokens. The investors are disallowed to invest more that this number
    /// @param baseToken the address of pool's base token
    /// @param baseTokenDecimals are the decimals of base token (just the gas savings)
    /// @param minimalInvestment is the minimal number of base tokens the investor is allowed to invest (in 18 decimals)
    /// @param commissionPeriod represents the duration of the commission period
    /// @param commissionPercentage trader's commission percentage (DEXE takes commission from this commission)
    struct PoolParameters {
        string descriptionURL;
        address trader;
        bool privatePool;
        uint256 totalLPEmission; // zero means unlimited
        address baseToken;
        uint256 baseTokenDecimals;
        uint256 minimalInvestment; // zero means any value
        ICoreProperties.CommissionPeriod commissionPeriod;
        uint256 commissionPercentage;
    }

    /// @notice The struct that stores basic investor's info
    /// @param investedBase the amount of base tokens the investor invested into the pool (normalized)
    /// @param commissionUnlockEpoch the commission epoch number the trader will be able to take commission from this investor
    struct InvestorInfo {
        uint256 investedBase;
        uint256 commissionUnlockEpoch;
    }

    /// @notice The struct that is returned from the TraderPoolView contract to see the taken commissions
    /// @param traderBaseCommission the total trader's commission in base tokens (normalized)
    /// @param traderLPCommission the equivalent trader's commission in LP tokens
    /// @param traderUSDCommission the equivalent trader's commission in USD (normalized)
    /// @param dexeBaseCommission the total platform's commission in base tokens (normalized)
    /// @param dexeLPCommission the equivalent platform's commission in LP tokens
    /// @param dexeUSDCommission the equivalent platform's commission in USD (normalized)
    /// @param dexeDexeCommission the equivalent platform's commission in DEXE tokens (normalized)
    struct Commissions {
        uint256 traderBaseCommission;
        uint256 traderLPCommission;
        uint256 traderUSDCommission;
        uint256 dexeBaseCommission;
        uint256 dexeLPCommission;
        uint256 dexeUSDCommission;
        uint256 dexeDexeCommission;
    }

    /// @notice The struct that is returned from the TraderPoolView contract to see the received amounts
    /// @param baseAmount total received base amount
    /// @param lpAmount total received LP amount (zero in getDivestAmountsAndCommissions())
    /// @param positions the addresses of positions tokens from which the "receivedAmounts" are calculated
    /// @param givenAmounts the amounts (either in base tokens or in position tokens) given
    /// @param receivedAmounts the amounts (either in base tokens or in position tokens) received
    struct Receptions {
        uint256 baseAmount;
        uint256 lpAmount;
        address[] positions;
        uint256[] givenAmounts;
        uint256[] receivedAmounts; // should be used as minAmountOut
    }

    /// @notice The struct that is returned from the TraderPoolView contract and stores information about the trader leverage
    /// @param totalPoolUSDWithProposals the total USD value of the pool + proposal pools
    /// @param traderLeverageUSDTokens the maximal amount of USD that the trader is allowed to own
    /// @param freeLeverageUSD the amount of USD that could be invested into the pool
    /// @param freeLeverageBase the amount of base tokens that could be invested into the pool (basically converted freeLeverageUSD)
    struct LeverageInfo {
        uint256 totalPoolUSDWithProposals;
        uint256 traderLeverageUSDTokens;
        uint256 freeLeverageUSD;
        uint256 freeLeverageBase;
    }

    /// @notice The struct that is returned from the TraderPoolView contract and stores information about the investor
    /// @param commissionUnlockTimestamp the timestamp after which the trader will be allowed to take the commission from this user
    /// @param poolLPBalance the LP token balance of this used excluding proposals balance. The same as calling .balanceOf() function
    /// @param investedBase the amount of base tokens invested into the pool (after commission calculation this might increase)
    /// @param poolUSDShare the equivalent amount of USD that represent the user's pool share
    /// @param poolUSDShare the equivalent amount of base tokens that represent the user's pool share
    /// @param owedBaseCommission the base commission the user will pay if the trader desides to claim commission now
    /// @param owedLPCommission the equivalent LP commission the user will pay if the trader desides to claim commission now
    struct UserInfo {
        uint256 commissionUnlockTimestamp;
        uint256 poolLPBalance;
        uint256 investedBase;
        uint256 poolUSDShare;
        uint256 poolBaseShare;
        uint256 owedBaseCommission;
        uint256 owedLPCommission;
    }

    /// @notice The structure that is returned from the TraderPoolView contract and stores static information about the pool
    /// @param ticker the ERC20 symbol of this pool
    /// @param name the ERC20 name of this pool
    /// @param parameters the active pool parameters (that are set in the constructor)
    /// @param openPositions the array of open positions addresses
    /// @param baseAndPositionBalances the array of balances. [0] is the balance of base tokens (array is normalized)
    /// @param totalBlacklistedPositions is the number of blacklisted positions this pool has
    /// @param totalInvestors is the number of investors this pools has (excluding trader)
    /// @param totalPoolUSD is the current USD TVL in this pool
    /// @param totalPoolBase is the current base token TVL in this pool
    /// @param lpSupply is the current number of LP tokens (without proposals)
    /// @param lpLockedInProposals is the current number of LP tokens that are locked in proposals
    /// @param traderUSD is the equivalent amount of USD that represent the trader's pool share
    /// @param traderBase is the equivalent amount of base tokens that represent the trader's pool share
    /// @param traderLPBalance is the amount of LP tokens the trader has in the pool (excluding proposals)
    struct PoolInfo {
        string ticker;
        string name;
        PoolParameters parameters;
        address[] openPositions;
        uint256[] baseAndPositionBalances;
        uint256 totalBlacklistedPositions;
        uint256 totalInvestors;
        uint256 totalPoolUSD;
        uint256 totalPoolBase;
        uint256 lpSupply;
        uint256 lpLockedInProposals;
        uint256 traderUSD;
        uint256 traderBase;
        uint256 traderLPBalance;
    }

    /// @notice The function that returns a PriceFeed contract
    /// @return the price feed used
    function priceFeed() external view returns (IPriceFeed);

    /// @notice The function that returns a CoreProperties contract
    /// @return the core properties contract
    function coreProperties() external view returns (ICoreProperties);

    /// @notice The function that checks whether the specified address is a private investor
    /// @param who the address to check
    /// @return true if the pool is private and who is a private investor, false otherwise
    function isPrivateInvestor(address who) external view returns (bool);

    /// @notice The function that checks whether the specified address is a trader admin
    /// @param who the address to check
    /// @return true if who is an admin, false otherwise
    function isTraderAdmin(address who) external view returns (bool);

    /// @notice The function that checks whether the specified address is a trader
    /// @param who the address to check
    /// @return true if who is a trader, false otherwise
    function isTrader(address who) external view returns (bool);

    /// @notice The function to modify trader admins. Trader admins are eligible for executing swaps
    /// @param admins the array of addresses to grant or revoke an admin rights
    /// @param add if true the admins will be added, if false the admins will be removed
    function modifyAdmins(address[] calldata admins, bool add) external;

    /// @notice The function to modify private investors
    /// @param privateInvestors the address to be added/removed from private investors list
    /// @param add if true the investors will be added, if false the investors will be removed
    function modifyPrivateInvestors(address[] calldata privateInvestors, bool add) external;

    /// @notice The function that check if the private investor can be removed
    /// @param investor private investor
    /// @return true if can be removed, false otherwise
    function canRemovePrivateInvestor(address investor) external view returns (bool);

    /// @notice The function to change certain parameters of the pool
    /// @param descriptionURL the IPFS URL to new description
    /// @param privatePool the new access for this pool
    /// @param totalLPEmission the new LP emission for this pool
    /// @param minimalInvestment the new minimal investment bound
    function changePoolParameters(
        string calldata descriptionURL,
        bool privatePool,
        uint256 totalLPEmission,
        uint256 minimalInvestment
    ) external;

    /// @notice The function to get the total number of investors
    /// @return the total number of investors
    function totalInvestors() external view returns (uint256);

    /// @notice The function to get an address of a proposal pool used by this contract
    /// @return the address of the proposal pool
    function proposalPoolAddress() external view returns (address);

    /// @notice The function that returns the actual LP emmission (the totalSupply() might be less)
    /// @return the actual LP tokens emission
    function totalEmission() external view returns (uint256);

    /// @notice The function that returns the filtered open positions list (filtered against the blacklist)
    /// @return the array of open positions
    function openPositions() external view returns (address[] memory);

    /// @notice The function that returns the information about the investors
    /// @param offset the starting index of the investors array
    /// @param limit the length of the observed array
    /// @return usersInfo the information about the investors
    function getUsersInfo(uint256 offset, uint256 limit)
        external
        view
        returns (UserInfo[] memory usersInfo);

    /// @notice The function to get the static pool information
    /// @return poolInfo the static info of the pool
    function getPoolInfo() external view returns (PoolInfo memory poolInfo);

    /// @notice The function to get the trader leverage information
    /// @return leverageInfo the trader leverage information
    function getLeverageInfo() external view returns (LeverageInfo memory leverageInfo);

    /// @notice The function to get the amounts of positions tokens that will be given to the investor on the investment
    /// @param amountInBaseToInvest normalized amount of base tokens to be invested
    /// @return receptions the information about the tokens received
    function getInvestTokens(uint256 amountInBaseToInvest)
        external
        view
        returns (Receptions memory receptions);

    /// @notice The function to invest into the pool. The "getInvestTokens" function has to be called to receive minPositionsOut amounts
    /// @param amountInBaseToInvest the amount of base tokens to be invested (normalized)
    /// @param minPositionsOut the minimal amounts of position tokens to be received
    function invest(uint256 amountInBaseToInvest, uint256[] calldata minPositionsOut) external;

    /// @notice The function to get the received commissions from the users when the "reinvestCommission" function is called.
    /// This function also "projects" commissions to the current positions if they were to be closed
    /// @param offsetLimits the starting indexes and the lengths of the investors array
    /// Starting indexes are under even positions, lengths are under odd
    /// @return commissions the received commissions info
    function getReinvestCommissions(uint256[] calldata offsetLimits)
        external
        view
        returns (Commissions memory commissions);

    /// @notice The function that takes the commission from the users' income. This function should be called once per the
    /// commission period. Use "getReinvestCommissions()" function to get minDexeCommissionOut parameter
    /// @param offsetLimits the array of starting indexes and the lengths of the investors array.
    /// Starting indexes are under even positions, lengths are under odd
    /// @param minDexeCommissionOut the minimal amount of DEXE tokens the platform will receive
    function reinvestCommission(uint256[] calldata offsetLimits, uint256 minDexeCommissionOut)
        external;

    /// @notice The function to get the commissions and received tokens when the "divest" function is called
    /// @param user the address of the user who is going to divest
    /// @param amountLP the amount of LP tokens the users is going to divest
    /// @return receptions the tokens that the user will receive
    /// @return commissions the commissions the user will have to pay
    function getDivestAmountsAndCommissions(address user, uint256 amountLP)
        external
        view
        returns (Receptions memory receptions, Commissions memory commissions);

    /// @notice The function to divest from the pool. The "getDivestAmountsAndCommissions()" function should be called
    /// to receive minPositionsOut and minDexeCommissionOut parameters
    /// @param amountLP the amount of LP tokens to divest
    /// @param minPositionsOut the amount of positions tokens to be converted into the base tokens and given to the user
    /// @param minDexeCommissionOut the DEXE commission in DEXE tokens
    function divest(
        uint256 amountLP,
        uint256[] calldata minPositionsOut,
        uint256 minDexeCommissionOut
    ) external;

    /// @notice The function to exchange tokens for tokens
    /// @param from the tokens to exchange from
    /// @param to the token to exchange to
    /// @param amount the amount of tokens to be exchanged (normalized). If fromExact, this should equal amountIn, else amountOut
    /// @param amountBound this should be minAmountOut if fromExact, else maxAmountIn
    /// @param optionalPath the optional path between from and to tokens used by the pathfinder
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external;

    /// @notice The function to get token prices required for the slippage
    /// @param from the token to exchange from
    /// @param to the token to exchange to
    /// @param amount the amount of tokens to be exchanged. If fromExact, this should be amountIn, else amountOut
    /// @param optionalPath optional path between from and to tokens used by the pathfinder
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    /// @return amount the minAmountOut if fromExact, else maxAmountIn
    /// @return path the tokens path that will be used during the swap
    function getExchangeAmount(
        address from,
        address to,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view returns (uint256, address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the registry contract of DEXE platform that stores information about
 * the other contracts used by the protocol. Its purpose is to keep track of the propotol's
 * contracts, provide upgradeability mechanism and dependency injection mechanism.
 */
interface IContractsRegistry {
    /// @notice Used in dependency injection mechanism
    /// @return UserRegistry contract address
    function getUserRegistryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return PoolFactory contract address
    function getPoolFactoryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return TraderPoolRegistry contract address
    function getTraderPoolRegistryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return GovPoolRegistry contract address
    function getGovPoolRegistryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return DEXE token contract address
    function getDEXEContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Platform's native USD token contract address. This may be USDT/BUSD/USDC/DAI/FEI
    function getUSDContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return PriceFeed contract address
    function getPriceFeedContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return UniswapV2Router contract address. This can be any forked contract as well
    function getUniswapV2RouterContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return UniswapV2Factory contract address. This can be any forked contract as well
    function getUniswapV2FactoryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Insurance contract address
    function getInsuranceContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Treasury contract/wallet address
    function getTreasuryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Dividends contract/wallet address
    function getDividendsContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return CoreProperties contract address
    function getCorePropertiesContract() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../contracts-registry/AbstractDependant.sol";
import "../AbstractPoolContractsRegistry.sol";

import "./PublicBeaconProxy.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  This is an abstract factory contract that is used in pair with the PoolContractsRegistry contract to
 *  deploy, register and inject pools.
 *
 *  The actual `deploy()` function has to be implemented in the descendants of this contract. The deployment
 *  is made via the BeaconProxy pattern.
 */
abstract contract AbstractPoolFactory is AbstractDependant {
    address internal _contractsRegistry;

    /**
     *  @notice The function that accepts dependencies from the ContractsRegistry, can be overriden
     *  @param contractsRegistry the dependency registry
     */
    function setDependencies(address contractsRegistry) public virtual override dependant {
        _contractsRegistry = contractsRegistry;
    }

    /**
     *  @notice The internal deploy function that deploys BeaconProxy pointing to the
     *  pool implementation taken from the PoolContractRegistry
     */
    function _deploy(address poolRegistry, string memory poolType) internal returns (address) {
        return
            address(
                new PublicBeaconProxy(
                    AbstractPoolContractsRegistry(poolRegistry).getProxyBeacon(poolType),
                    ""
                )
            );
    }

    /**
     *  @notice The internal function that registers newly deployed pool in the provided PoolContractRegistry
     */
    function _register(
        address poolRegistry,
        string memory poolType,
        address poolProxy
    ) internal {
        AbstractPoolContractsRegistry(poolRegistry).addPool(poolType, poolProxy);
    }

    /**
     *  @notice The function that injects dependencies to the newly deployed pool and sets
     *  provided PoolContractsRegistry as an injector
     */
    function _injectDependencies(address poolRegistry, address proxy) internal {
        AbstractDependant(proxy).setDependencies(_contractsRegistry);
        AbstractDependant(proxy).setInjector(poolRegistry);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import "../interfaces/gov/IGovPool.sol";

import "./GovFee.sol";

contract GovPool is IGovPool, GovFee, ERC721HolderUpgradeable, ERC1155HolderUpgradeable {
    string public descriptionURL;

    event ProposalExecuted(uint256 proposalId);

    function __GovPool_init(
        address govSettingAddress,
        address govUserKeeperAddress,
        address validatorsAddress,
        uint256 _votesLimit,
        uint256 _feePercentage,
        string calldata _descriptionURL
    ) external initializer {
        __GovFee_init(
            govSettingAddress,
            govUserKeeperAddress,
            validatorsAddress,
            _votesLimit,
            _feePercentage
        );
        __ERC721Holder_init();
        __ERC1155Holder_init();

        descriptionURL = _descriptionURL;
    }

    function execute(uint256 proposalId) external override {
        Proposal storage proposal = proposals[proposalId];

        require(
            _getProposalState(proposal.core) == ProposalState.Succeeded,
            "Gov: invalid proposal status"
        );

        proposal.core.executed = true;

        address[] memory executors = proposal.executors;
        uint256[] memory values = proposal.values;
        bytes[] memory data = proposal.data;

        for (uint256 i; i < data.length; i++) {
            (bool status, bytes memory returnedData) = executors[i].call{value: values[i]}(
                data[i]
            );

            if (!status) {
                revert(_getRevertMsg(returnedData));
            }
        }

        emit ProposalExecuted(proposalId);
    }

    receive() external payable {}

    function _getRevertMsg(bytes memory data) internal pure returns (string memory) {
        if (data.length < 68) {
            return "Transaction reverted silently";
        }

        assembly {
            data := add(data, 0x04)
        }

        return abi.decode(data, (string));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "../interfaces/gov/IGovUserKeeper.sol";

import "../libs/MathHelper.sol";
import "../libs/ShrinkableArray.sol";

import "./ERC721/ERC721Power.sol";

contract GovUserKeeper is IGovUserKeeper, OwnableUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using MathHelper for uint256;
    using ShrinkableArray for ShrinkableArray.UintArray;
    using EnumerableSet for EnumerableSet.UintSet;
    using Paginator for EnumerableSet.UintSet;
    using DecimalsConverter for uint256;

    address public tokenAddress;
    address public nftAddress;

    NFTInfo private _nftInfo;

    mapping(address => uint256) public override tokenBalance; // user => token balance
    mapping(address => EnumerableSet.UintSet) private _nftBalance; // user => nft balance

    mapping(address => uint256) private _maxTokensLocked; // user => maximum locked amount
    mapping(address => mapping(uint256 => uint256)) private _lockedInProposals; // user => proposal id => locked amount
    mapping(address => EnumerableSet.UintSet) private _lockedProposals; // user => array of proposal ids

    mapping(address => EnumerableSet.UintSet) private _nftLocked; // user => locked nfts
    mapping(uint256 => uint256) private _nftLockedNums; // tokenId => locked num

    mapping(address => mapping(address => uint256)) public override delegatedTokens; // holder => spender => amount
    mapping(address => mapping(address => EnumerableSet.UintSet)) private _delegatedNfts; // holder => spender => tokenIds

    uint256 private _latestPowerSnapshotId;

    mapping(uint256 => NFTSnapshot) public nftSnapshot; // snapshot id => snapshot info

    event TokensAdded(address account, uint256 amount);
    event TokensDelegated(address holder, address spender, uint256 amount);
    event TokensWithdrawn(address account, uint256 amount);
    event TokensLocked(address account, uint256 amount);

    event NftsAdded(address account, uint256[] ids);
    event NftsDelegated(address holder, address spender, uint256[] ids, bool[] status);
    event NftsWithdrawn(address account);
    event NftsLocked(address account, uint256[] ids, uint256 length);

    modifier withSupportedToken() {
        require(tokenAddress != address(0), "GovUK: token is not supported");
        _;
    }

    modifier withSupportedNft() {
        require(nftAddress != address(0), "GovUK: nft is not supported");
        _;
    }

    function __GovUserKeeper_init(
        address _tokenAddress,
        address _nftAddress,
        uint256 totalPowerInTokens,
        uint256 nftsTotalSupply
    ) external initializer {
        __Ownable_init();
        __ERC721Holder_init();

        require(_tokenAddress != address(0) || _nftAddress != address(0), "GovUK: zero addresses");

        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;

        if (_nftAddress != address(0)) {
            require(totalPowerInTokens > 0, "GovUK: the equivalent is zero");

            _nftInfo.totalPowerInTokens = totalPowerInTokens;

            if (IERC165(_nftAddress).supportsInterface(type(IERC721Power).interfaceId)) {
                _nftInfo.isSupportPower = true;
                _nftInfo.isSupportTotalSupply = true;
            } else if (
                IERC165(_nftAddress).supportsInterface(type(IERC721Enumerable).interfaceId)
            ) {
                _nftInfo.isSupportTotalSupply = true;
            } else {
                require(nftsTotalSupply > 0, "GovUK: total supply is zero");

                _nftInfo.totalSupply = nftsTotalSupply;
            }
        }
    }

    function depositTokens(address holder, uint256 amount) external override withSupportedToken {
        address token = tokenAddress;

        IERC20(token).safeTransferFrom(
            msg.sender,
            address(this),
            amount.from18(ERC20(token).decimals())
        );

        tokenBalance[holder] += amount;

        emit TokensAdded(holder, amount);
    }

    function delegateTokens(address spender, uint256 amount) external override withSupportedToken {
        delegatedTokens[msg.sender][spender] = amount;

        emit TokensDelegated(msg.sender, spender, amount);
    }

    function withdrawTokens(uint256 amount) external override withSupportedToken {
        address token = tokenAddress;
        uint256 balance = tokenBalance[msg.sender];
        uint256 newLockedAmount = _getNewTokenLockedAmount(msg.sender);

        _maxTokensLocked[msg.sender] = newLockedAmount;
        amount = amount.min(balance - newLockedAmount);

        require(amount > 0, "GovUK: nothing to withdraw");

        tokenBalance[msg.sender] = balance - amount;

        IERC20(token).safeTransfer(msg.sender, amount.from18(ERC20(token).decimals()));

        emit TokensWithdrawn(msg.sender, amount);
    }

    function depositNfts(address holder, uint256[] calldata nftIds)
        external
        override
        withSupportedNft
    {
        IERC721 nft = IERC721(nftAddress);

        for (uint256 i; i < nftIds.length; i++) {
            nft.safeTransferFrom(msg.sender, address(this), nftIds[i]);

            _nftBalance[holder].add(nftIds[i]);
        }

        emit NftsAdded(holder, nftIds);
    }

    function delegateNfts(
        address spender,
        uint256[] calldata nftIds,
        bool[] calldata delegationStatus
    ) external override withSupportedNft {
        for (uint256 i; i < nftIds.length; i++) {
            if (delegationStatus[i]) {
                _delegatedNfts[msg.sender][spender].add(nftIds[i]);
            } else {
                _delegatedNfts[msg.sender][spender].remove(nftIds[i]);
            }
        }

        emit NftsDelegated(msg.sender, spender, nftIds, delegationStatus);
    }

    function withdrawNfts(uint256[] calldata nftIds) external override withSupportedNft {
        IERC721 nft = IERC721(nftAddress);

        for (uint256 i; i < nftIds.length; i++) {
            if (
                !_nftBalance[msg.sender].contains(nftIds[i]) ||
                _nftLocked[msg.sender].contains(nftIds[i])
            ) {
                continue;
            }

            _nftBalance[msg.sender].remove(nftIds[i]);

            nft.safeTransferFrom(address(this), msg.sender, nftIds[i]);
        }

        emit NftsWithdrawn(msg.sender);
    }

    function getNftContractInfo()
        external
        view
        override
        returns (
            bool supportPower,
            bool supportTotalSupply,
            uint256 totalPowerInTokens,
            uint256 totalSupply
        )
    {
        return (
            _nftInfo.isSupportPower,
            _nftInfo.isSupportTotalSupply,
            _nftInfo.totalPowerInTokens,
            _nftInfo.totalSupply
        );
    }

    function tokenBalanceOf(address user) external view override returns (uint256, uint256) {
        return (tokenBalance[user], _getNewTokenLockedAmount(user));
    }

    function nftBalanceCountOf(address user) external view override returns (uint256, uint256) {
        return (_nftBalance[user].length(), _nftLocked[user].length());
    }

    function delegatedNftsCountOf(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _delegatedNfts[holder][spender].length();
    }

    function nftBalanceOf(
        address user,
        uint256 offset,
        uint256 limit
    ) external view override returns (uint256[] memory nftIds) {
        return _nftBalance[user].part(offset, limit);
    }

    function nftLockedBalanceOf(
        address user,
        uint256 offset,
        uint256 limit
    ) external view override returns (uint256[] memory nftIds, uint256[] memory lockedAmounts) {
        nftIds = _nftLocked[user].part(offset, limit);

        lockedAmounts = new uint256[](nftIds.length);

        for (uint256 i = 0; i < nftIds.length; i++) {
            lockedAmounts[i] = _nftLockedNums[nftIds[i]];
        }
    }

    function getDelegatedNfts(
        address holder,
        address spender,
        uint256 offset,
        uint256 limit
    ) external view override returns (uint256[] memory nftIds) {
        return _delegatedNfts[holder][spender].part(offset, limit);
    }

    function getTotalVoteWeight() external view override returns (uint256) {
        address token = tokenAddress;

        return
            (token != address(0) ? IERC20(token).totalSupply().to18(ERC20(token).decimals()) : 0) +
            _nftInfo.totalPowerInTokens;
    }

    function getNftsPowerInTokens(ShrinkableArray.UintArray calldata nftIds, uint256 snapshotId)
        external
        view
        override
        returns (uint256)
    {
        address _nftAddress = nftAddress;

        if (_nftAddress == address(0)) {
            return 0;
        }

        if (!_nftInfo.isSupportPower) {
            uint256 totalSupply;

            if (_nftInfo.isSupportTotalSupply) {
                totalSupply = nftSnapshot[snapshotId].totalSupply;
            } else {
                totalSupply = _nftInfo.totalSupply;
            }

            return
                totalSupply == 0
                    ? 0
                    : nftIds.length.ratio(_nftInfo.totalPowerInTokens, totalSupply);
        }

        uint256 nftsPower;

        for (uint256 i; i < nftIds.length; i++) {
            (, , uint256 collateralAmount, , ) = ERC721Power(_nftAddress).nftInfos(
                nftIds.values[i]
            );

            nftsPower += collateralAmount;
        }

        uint256 totalNftsPower = nftSnapshot[snapshotId].totalNftsPower;

        if (totalNftsPower != 0) {
            uint256 totalPowerInTokens = _nftInfo.totalPowerInTokens;

            for (uint256 i; i < nftIds.length; i++) {
                nftsPower += totalPowerInTokens.ratio(
                    nftSnapshot[snapshotId].nftPower[nftIds.values[i]],
                    totalNftsPower
                );
            }
        }

        return nftsPower;
    }

    function filterNftsAvailableForDelegator(
        address delegate,
        address holder,
        ShrinkableArray.UintArray calldata nftIds
    ) external view override returns (ShrinkableArray.UintArray memory) {
        ShrinkableArray.UintArray memory validNfts = ShrinkableArray.create(nftIds.length);
        uint256 length;

        for (uint256 i; i < nftIds.length; i++) {
            if (!_delegatedNfts[holder][delegate].contains(nftIds.values[i])) {
                continue;
            }

            validNfts.values[length++] = nftIds.values[i];
        }

        return validNfts.crop(length);
    }

    function createNftPowerSnapshot() external override onlyOwner returns (uint256) {
        bool isSupportPower = _nftInfo.isSupportPower;
        bool isSupportTotalSupply = _nftInfo.isSupportTotalSupply;

        if (!isSupportTotalSupply) {
            return 0;
        }

        IERC721Power nftContract = IERC721Power(nftAddress);
        uint256 supply = nftContract.totalSupply();

        uint256 currentPowerSnapshotId = ++_latestPowerSnapshotId;

        if (!isSupportPower) {
            nftSnapshot[currentPowerSnapshotId].totalSupply = supply;

            return currentPowerSnapshotId;
        }

        uint256 totalNftsPower;

        for (uint256 i; i < supply; i++) {
            uint256 index = nftContract.tokenByIndex(i);
            uint256 power = nftContract.recalculateNftPower(index);

            nftSnapshot[currentPowerSnapshotId].nftPower[index] = power;
            totalNftsPower += power;
        }

        nftSnapshot[currentPowerSnapshotId].totalNftsPower = totalNftsPower;

        return currentPowerSnapshotId;
    }

    function lockTokens(
        address voter,
        uint256 amount,
        uint256 proposalId
    ) external onlyOwner {
        uint256 newLockedAmount = _lockedInProposals[voter][proposalId] + amount;

        _lockedInProposals[voter][proposalId] = newLockedAmount;
        _lockedProposals[voter].add(proposalId);

        if (newLockedAmount > _maxTokensLocked[voter]) {
            _maxTokensLocked[voter] = newLockedAmount;

            emit TokensLocked(voter, newLockedAmount);
        }
    }

    function unlockTokens(address voter, uint256 proposalId) external override onlyOwner {
        if (_maxTokensLocked[voter] == 0) {
            return;
        }

        delete _lockedInProposals[voter][proposalId];
        _lockedProposals[voter].remove(proposalId);
    }

    function lockNfts(address voter, ShrinkableArray.UintArray calldata nftIds)
        external
        override
        onlyOwner
        returns (ShrinkableArray.UintArray memory)
    {
        ShrinkableArray.UintArray memory locked = ShrinkableArray.create(nftIds.length);
        uint256 length;

        for (uint256 i; i < nftIds.length; i++) {
            if (!_nftBalance[voter].contains(nftIds.values[i])) {
                continue;
            }

            _nftLocked[voter].add(nftIds.values[i]);
            _nftLockedNums[nftIds.values[i]]++;

            locked.values[length++] = nftIds.values[i];
        }

        locked = locked.crop(length);

        emit NftsLocked(voter, locked.values, locked.length);

        return locked;
    }

    function unlockNfts(address voter, uint256[] calldata nftIds) external override onlyOwner {
        for (uint256 i; i < nftIds.length; i++) {
            if (!_nftLocked[voter].contains(nftIds[i])) {
                continue;
            }

            uint256 nftLockedNum = _nftLockedNums[nftIds[i]];

            if (nftLockedNum == 1) {
                _nftLocked[voter].remove(nftIds[i]);
            } else {
                _nftLockedNums[nftIds[i]] = nftLockedNum - 1;
            }
        }
    }

    function canUserParticipate(
        address user,
        uint256 requiredTokens,
        uint256 requiredNfts
    ) external view override returns (bool) {
        return (tokenBalance[user] >= requiredTokens ||
            _nftBalance[user].length() >= requiredNfts);
    }

    function _getNewTokenLockedAmount(address voter) private view returns (uint256) {
        EnumerableSet.UintSet storage lockedProposals = _lockedProposals[voter];

        uint256 lockedAmount = _maxTokensLocked[voter];
        uint256 length = lockedProposals.length();

        if (lockedAmount == 0) {
            return 0;
        }

        uint256 newLockedAmount;

        for (uint256 i = length; i > 0; i--) {
            newLockedAmount = newLockedAmount.max(
                _lockedInProposals[voter][lockedProposals.at(i - 1)]
            );

            if (newLockedAmount == lockedAmount) {
                break;
            }
        }

        return newLockedAmount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../../interfaces/gov/settings/IGovSettings.sol";

import "../../core/Globals.sol";

contract GovSettings is IGovSettings, OwnableUpgradeable {
    uint256 private constant _INTERNAL_SETTINGS_ID = 1;
    uint256 private constant _DEFAULT_SETTINGS_ID = 2;

    uint256 private _latestSettingsId;

    mapping(uint256 => ProposalSettings) public settings; // settingsId => info
    mapping(address => uint256) public executorToSettings; // executor => seetingsId

    function __GovSettings_init(
        ProposalSettings calldata internalProposalSetting,
        ProposalSettings calldata defaultProposalSetting
    ) external initializer {
        __Ownable_init();

        _validateProposalSettings(internalProposalSetting);
        _validateProposalSettings(defaultProposalSetting);

        settings[_INTERNAL_SETTINGS_ID] = internalProposalSetting;
        settings[_DEFAULT_SETTINGS_ID] = defaultProposalSetting;

        executorToSettings[address(this)] = _INTERNAL_SETTINGS_ID;

        _latestSettingsId += 2;
    }

    function addSettings(ProposalSettings[] calldata _settings) external override onlyOwner {
        uint256 settingsId = _latestSettingsId;

        for (uint256 i; i < _settings.length; i++) {
            _validateProposalSettings(_settings[i]);

            settings[++settingsId] = _settings[i];
        }

        _latestSettingsId = settingsId;
    }

    function editSettings(uint256[] calldata settingsIds, ProposalSettings[] calldata _settings)
        external
        override
        onlyOwner
    {
        for (uint256 i; i < _settings.length; i++) {
            if (!_settingsExist(settingsIds[i])) {
                continue;
            }

            _validateProposalSettings(_settings[i]);

            settings[settingsIds[i]] = _settings[i];
        }
    }

    function changeExecutors(address[] calldata executors, uint256[] calldata settingsIds)
        external
        override
        onlyOwner
    {
        for (uint256 i; i < executors.length; i++) {
            if (settingsIds[i] == _INTERNAL_SETTINGS_ID || executors[i] == address(this)) {
                continue;
            }

            executorToSettings[executors[i]] = settingsIds[i];
        }
    }

    function _validateProposalSettings(ProposalSettings calldata _settings) private pure {
        require(_settings.duration > 0, "GovSettings: invalid vote duration value");
        require(_settings.quorum <= PERCENTAGE_100, "GovSettings: invalid quorum value");
        require(
            _settings.durationValidators > 0,
            "GovSettings: invalid validator vote duration value"
        );
        require(
            _settings.quorumValidators <= PERCENTAGE_100,
            "GovSettings: invalid validator quorum value"
        );
    }

    function _settingsExist(uint256 settingsId) private view returns (bool) {
        return settings[settingsId].duration > 0;
    }

    function executorInfo(address executor)
        public
        view
        returns (
            uint256,
            bool,
            bool
        )
    {
        uint256 settingsId = executorToSettings[executor];

        return
            settingsId == 0
                ? (0, false, false)
                : (settingsId, settingsId == _INTERNAL_SETTINGS_ID, _settingsExist(settingsId));
    }

    function getDefaultSettings() external view override returns (ProposalSettings memory) {
        return settings[_DEFAULT_SETTINGS_ID];
    }

    function getSettings(address executor)
        external
        view
        override
        returns (ProposalSettings memory)
    {
        (uint256 settingsId, bool isInternal, bool isSettingsSet) = executorInfo(executor);

        if (isInternal) {
            return settings[_INTERNAL_SETTINGS_ID];
        }

        if (isSettingsSet) {
            return settings[settingsId];
        }

        return settings[_DEFAULT_SETTINGS_ID];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/gov/validators/IGovValidators.sol";

import "./GovValidatorsToken.sol";

import "../../libs/MathHelper.sol";
import "../../core/Globals.sol";

contract GovValidators is IGovValidators, OwnableUpgradeable {
    using Math for uint256;
    using MathHelper for uint256;

    GovValidatorsToken public govValidatorsToken;

    /// @dev Base internal proposal settings
    InternalProposalSettings public internalProposalSettings;

    uint256 private _latestInternalProposalId;

    mapping(uint256 => InternalProposal) public internalProposals; // proposalId => info
    mapping(uint256 => ExternalProposal) public externalProposals; // proposalId => info

    mapping(uint256 => mapping(address => uint256)) public addressVotedInternal; // proposalId => user => voted amount
    mapping(uint256 => mapping(address => uint256)) public addressVotedExternal; // proposalId => user => voted amount

    /// @dev Access only for addresses that have validator tokens
    modifier onlyValidatorHolder() {
        require(
            govValidatorsToken.balanceOf(msg.sender) > 0,
            "Validators: caller is not the validator"
        );
        _;
    }

    function __GovValidators_init(
        string calldata name,
        string calldata symbol,
        uint64 duration,
        uint128 quorum,
        address[] calldata validators,
        uint256[] calldata balances
    ) external initializer {
        __Ownable_init();

        require(validators.length == balances.length, "Validators: invalid array length");
        require(validators.length > 0, "Validators: length is zero");
        require(duration > 0, "Validators: duration is zero");
        require(quorum <= PERCENTAGE_100, "Validators: invalid quorum value");

        GovValidatorsToken _validatorsTokenContract = new GovValidatorsToken(name, symbol);

        govValidatorsToken = _validatorsTokenContract;
        internalProposalSettings.duration = duration;
        internalProposalSettings.quorum = quorum;

        for (uint256 i; i < validators.length; i++) {
            _validatorsTokenContract.mint(validators[i], balances[i]);
        }
    }

    function createInternalProposal(
        ProposalType proposalType,
        uint256[] calldata newValues,
        address[] calldata users
    ) external override onlyValidatorHolder {
        if (proposalType == ProposalType.ChangeInternalDuration) {
            require(newValues[0] > 0, "Validators: invalid duration value");
        } else if (proposalType == ProposalType.ChangeInternalQuorum) {
            require(newValues[0] <= PERCENTAGE_100, "Validators: invalid quorum value");
        } else if (proposalType == ProposalType.ChangeInternalDurationAndQuorum) {
            require(
                newValues[0] > 0 && newValues[1] <= PERCENTAGE_100,
                "Validators: invalid duration or quorum values"
            );
        } else {
            require(newValues.length == users.length, "Validators: invalid length");

            for (uint256 i = 0; i < users.length; i++) {
                require(users[i] != address(0), "Validators: invalid address");
            }
        }

        internalProposals[++_latestInternalProposalId] = InternalProposal({
            proposalType: proposalType,
            core: ProposalCore({
                voteEnd: uint64(block.timestamp + internalProposalSettings.duration),
                executed: false,
                quorum: internalProposalSettings.quorum,
                votesFor: 0,
                snapshotId: govValidatorsToken.snapshot()
            }),
            newValues: newValues,
            userAddresses: users
        });
    }

    function createExternalProposal(
        uint256 proposalId,
        uint64 duration,
        uint128 quorum
    ) external override onlyOwner {
        require(!_proposalExists(proposalId, false), "Validators: proposal already exist");

        externalProposals[proposalId] = ExternalProposal({
            core: ProposalCore({
                voteEnd: uint64(block.timestamp + duration),
                executed: false,
                quorum: quorum,
                votesFor: 0,
                snapshotId: govValidatorsToken.snapshot()
            })
        });
    }

    function vote(
        uint256 proposalId,
        uint256 amount,
        bool isInternal
    ) external override {
        require(_proposalExists(proposalId, isInternal), "Validators: proposal does not exist");

        ProposalCore storage core = isInternal
            ? internalProposals[proposalId].core
            : externalProposals[proposalId].core;

        require(
            _getProposalState(core) == ProposalState.Voting,
            "Validators: only by `Voting` state"
        );

        uint256 balanceAt = govValidatorsToken.balanceOfAt(msg.sender, core.snapshotId);
        uint256 voted = isInternal
            ? addressVotedInternal[proposalId][msg.sender]
            : addressVotedExternal[proposalId][msg.sender];
        uint256 voteAmount = amount.min(balanceAt - voted);

        require(voteAmount > 0, "Validators: vote amount can't be a zero");

        if (isInternal) {
            addressVotedInternal[proposalId][msg.sender] = voted + voteAmount;
        } else {
            addressVotedExternal[proposalId][msg.sender] = voted + voteAmount;
        }

        core.votesFor += voteAmount;
    }

    function execute(uint256 proposalId) external override {
        require(_proposalExists(proposalId, true), "Validators: proposal does not exist");

        InternalProposal storage proposal = internalProposals[proposalId];

        require(
            _getProposalState(proposal.core) == ProposalState.Succeeded,
            "Validators: only by `Succeeded` state"
        );

        proposal.core.executed = true;

        ProposalType proposalType = proposal.proposalType;

        if (proposalType == ProposalType.ChangeInternalDuration) {
            internalProposalSettings.duration = uint64(proposal.newValues[0]);
        } else if (proposalType == ProposalType.ChangeInternalQuorum) {
            internalProposalSettings.quorum = uint128(proposal.newValues[0]);
        } else if (proposalType == ProposalType.ChangeInternalDurationAndQuorum) {
            internalProposalSettings.duration = uint64(proposal.newValues[0]);
            internalProposalSettings.quorum = uint128(proposal.newValues[1]);
        } else if (proposalType == ProposalType.ChangeBalances) {
            GovValidatorsToken validatorsToken = govValidatorsToken;
            uint256 length = proposal.newValues.length;

            for (uint256 i = 0; i < length; i++) {
                address user = proposal.userAddresses[i];
                uint256 newBalance = proposal.newValues[i];
                uint256 balance = validatorsToken.balanceOf(user);

                if (balance < newBalance) {
                    validatorsToken.mint(user, newBalance - balance);
                } else {
                    validatorsToken.burn(user, balance - newBalance);
                }
            }
        }
    }

    function getProposalState(uint256 proposalId, bool isInternal)
        external
        view
        override
        returns (ProposalState)
    {
        if (!_proposalExists(proposalId, isInternal)) {
            return ProposalState.Undefined;
        }

        return
            isInternal
                ? _getProposalState(internalProposals[proposalId].core)
                : _getProposalState(externalProposals[proposalId].core);
    }

    function _getProposalState(ProposalCore storage core) private view returns (ProposalState) {
        if (core.executed) {
            return ProposalState.Executed;
        }

        if (_isQuorumReached(core)) {
            return ProposalState.Succeeded;
        }

        if (core.voteEnd < block.timestamp) {
            return ProposalState.Defeated;
        }

        return ProposalState.Voting;
    }

    function isQuorumReached(uint256 proposalId, bool isInternal)
        external
        view
        override
        returns (bool)
    {
        if (!_proposalExists(proposalId, isInternal)) {
            return false;
        }

        return
            isInternal
                ? _isQuorumReached(internalProposals[proposalId].core)
                : _isQuorumReached(externalProposals[proposalId].core);
    }

    function _isQuorumReached(ProposalCore storage core) private view returns (bool) {
        uint256 totalSupply = govValidatorsToken.totalSupplyAt(core.snapshotId);
        uint256 currentQuorum = PERCENTAGE_100.ratio(core.votesFor, totalSupply);

        return currentQuorum >= core.quorum;
    }

    function _proposalExists(uint256 proposalId, bool isInternal) private view returns (bool) {
        return
            isInternal
                ? internalProposals[proposalId].core.voteEnd != 0
                : externalProposals[proposalId].core.voteEnd != 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/pool-contracts-registry/AbstractPoolContractsRegistry.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "../interfaces/gov/IGovPoolRegistry.sol";
import "../interfaces/core/IContractsRegistry.sol";

contract GovPoolRegistry is IGovPoolRegistry, AbstractPoolContractsRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Paginator for EnumerableSet.AddressSet;
    using Math for uint256;

    string public constant GOV_POOL_NAME = "GOV_POOL";
    string public constant SETTINGS_NAME = "SETTINGS";
    string public constant VALIDATORS_NAME = "VALIDATORS";
    string public constant USER_KEEPER_NAME = "USER_KEEPER";

    address internal _poolFactory;

    mapping(address => mapping(string => EnumerableSet.AddressSet)) internal _ownerPools; // pool owner => name => pool

    function _onlyPoolFactory() internal view override {
        require(_poolFactory == _msgSender(), "GovPoolRegistry: Caller is not a factory");
    }

    function setDependencies(address contractsRegistry) public override {
        super.setDependencies(contractsRegistry);

        _poolFactory = IContractsRegistry(contractsRegistry).getPoolFactoryContract();
    }

    function associateUserWithPool(
        address user,
        string calldata name,
        address poolAddress
    ) external override onlyPoolFactory {
        _ownerPools[user][name].add(poolAddress);
    }

    function countOwnerPools(address user, string calldata name)
        external
        view
        override
        returns (uint256)
    {
        return _ownerPools[user][name].length();
    }

    function listOwnerPools(
        address user,
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory pools) {
        return _ownerPools[user][name].part(offset, limit);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/trader/IBasicTraderPool.sol";
import "../interfaces/trader/ITraderPoolRiskyProposal.sol";

import "./TraderPool.sol";

contract BasicTraderPool is IBasicTraderPool, TraderPool {
    using MathHelper for uint256;
    using SafeERC20 for IERC20;

    ITraderPoolRiskyProposal internal _traderPoolProposal;

    event ProposalDivested(
        uint256 proposalId,
        address user,
        uint256 divestedLP2,
        uint256 receivedLP,
        uint256 receivedBase
    );

    modifier onlyProposalPool() {
        _onlyProposalPool();
        _;
    }

    function _onlyProposalPool() internal view {
        require(msg.sender == address(_traderPoolProposal), "BTP: not a proposal");
    }

    function _canTrade(address token) internal view {
        require(
            token == _poolParameters.baseToken || coreProperties.isWhitelistedToken(token),
            "BTP: invalid exchange"
        );
    }

    function __BasicTraderPool_init(
        string calldata name,
        string calldata symbol,
        ITraderPool.PoolParameters calldata _poolParameters,
        address traderPoolProposal
    ) public initializer {
        __TraderPool_init(name, symbol, _poolParameters);

        _traderPoolProposal = ITraderPoolRiskyProposal(traderPoolProposal);

        IERC20(_poolParameters.baseToken).safeApprove(traderPoolProposal, MAX_UINT);
    }

    function setDependencies(address contractsRegistry) public override dependant {
        super.setDependencies(contractsRegistry);

        AbstractDependant(address(_traderPoolProposal)).setDependencies(contractsRegistry);
    }

    function canRemovePrivateInvestor(address investor) public view override returns (bool) {
        return
            balanceOf(investor) == 0 &&
            _traderPoolProposal.getTotalActiveInvestments(investor) == 0;
    }

    function proposalPoolAddress() external view override returns (address) {
        return address(_traderPoolProposal);
    }

    function totalEmission() public view override returns (uint256) {
        return totalSupply() + _traderPoolProposal.totalLockedLP();
    }

    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) public override {
        _canTrade(to);

        super.exchange(from, to, amount, amountBound, optionalPath, exType);
    }

    function createProposal(
        address token,
        uint256 lpAmount,
        ITraderPoolRiskyProposal.ProposalLimits calldata proposalLimits,
        uint256 instantTradePercentage,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut,
        address[] calldata optionalPath
    ) external override onlyTrader {
        uint256 baseAmount = _divestPositions(lpAmount, minDivestOut);

        _traderPoolProposal.create(
            token,
            proposalLimits,
            lpAmount,
            baseAmount,
            instantTradePercentage,
            minProposalOut,
            optionalPath
        );

        _burn(msg.sender, lpAmount);
    }

    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut
    ) external override {
        uint256 baseAmount = _divestPositions(lpAmount, minDivestOut);

        _traderPoolProposal.invest(proposalId, msg.sender, lpAmount, baseAmount, minProposalOut);

        _updateFromData(msg.sender, lpAmount);
        _burn(msg.sender, lpAmount);
    }

    function reinvestProposal(
        uint256 proposalId,
        uint256 lp2Amount,
        uint256[] calldata minPositionsOut,
        uint256 minProposalOut
    ) external override {
        uint256 receivedBase = _traderPoolProposal.divest(
            proposalId,
            msg.sender,
            lp2Amount,
            minProposalOut
        );

        uint256 lpMinted = _investPositions(
            address(_traderPoolProposal),
            receivedBase,
            minPositionsOut
        );
        _updateToData(msg.sender, receivedBase);

        emit ProposalDivested(proposalId, msg.sender, lp2Amount, lpMinted, receivedBase);
    }

    function checkRemoveInvestor(address user) external override onlyProposalPool {
        _checkRemoveInvestor(user, 0);
    }

    function checkNewInvestor(address user) external override onlyProposalPool {
        _checkNewInvestor(user);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/trader/IInvestTraderPool.sol";
import "../interfaces/trader/ITraderPoolInvestProposal.sol";

import "./TraderPool.sol";

contract InvestTraderPool is IInvestTraderPool, TraderPool {
    using SafeERC20 for IERC20;
    using MathHelper for uint256;
    using DecimalsConverter for uint256;

    ITraderPoolInvestProposal internal _traderPoolProposal;

    uint256 internal _firstExchange;

    event ProposalDivested(
        uint256 proposalId,
        address user,
        uint256 divestedLP2,
        uint256 receivedLP,
        uint256 receivedBase
    );

    modifier onlyProposalPool() {
        _onlyProposalPool();
        _;
    }

    function _onlyProposalPool() internal view {
        require(msg.sender == address(_traderPoolProposal), "ITP: not a proposal");
    }

    function __InvestTraderPool_init(
        string calldata name,
        string calldata symbol,
        ITraderPool.PoolParameters calldata _poolParameters,
        address traderPoolProposal
    ) public initializer {
        __TraderPool_init(name, symbol, _poolParameters);

        _traderPoolProposal = ITraderPoolInvestProposal(traderPoolProposal);

        IERC20(_poolParameters.baseToken).safeApprove(traderPoolProposal, MAX_UINT);
    }

    function setDependencies(address contractsRegistry) public override dependant {
        super.setDependencies(contractsRegistry);

        AbstractDependant(address(_traderPoolProposal)).setDependencies(contractsRegistry);
    }

    function canRemovePrivateInvestor(address investor) public view override returns (bool) {
        return
            balanceOf(investor) == 0 &&
            _traderPoolProposal.getTotalActiveInvestments(investor) == 0;
    }

    function proposalPoolAddress() external view override returns (address) {
        return address(_traderPoolProposal);
    }

    function totalEmission() public view override returns (uint256) {
        return totalSupply() + _traderPoolProposal.totalLockedLP();
    }

    function getInvestDelayEnd() public view override returns (uint256) {
        uint256 delay = coreProperties.getDelayForRiskyPool();

        return delay != 0 ? (_firstExchange != 0 ? _firstExchange + delay : MAX_UINT) : 0;
    }

    function invest(uint256 amountInBaseToInvest, uint256[] calldata minPositionsOut)
        public
        override
    {
        require(
            isTraderAdmin(msg.sender) || getInvestDelayEnd() <= block.timestamp,
            "ITP: investment delay"
        );

        super.invest(amountInBaseToInvest, minPositionsOut);
    }

    function _setFirstExchangeTime() internal {
        if (_firstExchange == 0) {
            _firstExchange = block.timestamp;
        }
    }

    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) public override {
        _setFirstExchangeTime();

        super.exchange(from, to, amount, amountBound, optionalPath, exType);
    }

    function createProposal(
        string calldata descriptionURL,
        uint256 lpAmount,
        ITraderPoolInvestProposal.ProposalLimits calldata proposalLimits,
        uint256[] calldata minPositionsOut
    ) external override onlyTrader {
        uint256 baseAmount = _divestPositions(lpAmount, minPositionsOut);

        _traderPoolProposal.create(descriptionURL, proposalLimits, lpAmount, baseAmount);

        _burn(msg.sender, lpAmount);
    }

    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minPositionsOut
    ) external override {
        require(
            isTraderAdmin(msg.sender) || getInvestDelayEnd() <= block.timestamp,
            "ITP: investment delay"
        );

        uint256 baseAmount = _divestPositions(lpAmount, minPositionsOut);

        _traderPoolProposal.invest(proposalId, msg.sender, lpAmount, baseAmount);

        _updateFromData(msg.sender, lpAmount);
        _burn(msg.sender, lpAmount);
    }

    function reinvestProposal(uint256 proposalId, uint256[] calldata minPositionsOut)
        external
        override
    {
        uint256 receivedBase = _traderPoolProposal.divest(proposalId, msg.sender);

        if (receivedBase == 0) {
            return;
        }

        uint256 lpMinted = _investPositions(
            address(_traderPoolProposal),
            receivedBase,
            minPositionsOut
        );
        _updateToData(msg.sender, receivedBase);

        emit ProposalDivested(proposalId, msg.sender, 0, lpMinted, receivedBase);
    }

    function checkRemoveInvestor(address user) external override onlyProposalPool {
        _checkRemoveInvestor(user, 0);
    }

    function checkNewInvestor(address user) external override onlyProposalPool {
        _checkNewInvestor(user);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../interfaces/trader/ITraderPoolRiskyProposal.sol";
import "../interfaces/trader/IBasicTraderPool.sol";

import "../libs/PriceFeed/PriceFeedLocal.sol";
import "../libs/TraderPoolProposal/TraderPoolRiskyProposalView.sol";

import "../core/Globals.sol";
import "./TraderPoolProposal.sol";

contract TraderPoolRiskyProposal is ITraderPoolRiskyProposal, TraderPoolProposal {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;
    using DecimalsConverter for uint256;
    using MathHelper for uint256;
    using Math for uint256;
    using Address for address;
    using TraderPoolRiskyProposalView for ParentTraderPoolInfo;
    using PriceFeedLocal for IPriceFeed;

    mapping(uint256 => ProposalInfo) internal _proposalInfos; // proposal id => info

    event ProposalCreated(
        uint256 proposalId,
        address token,
        ITraderPoolRiskyProposal.ProposalLimits proposalLimits
    );
    event ProposalExchanged(
        uint256 proposalId,
        address sender,
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event ProposalActivePortfolioExchanged(
        uint256 proposalId,
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event ProposalPositionClosed(uint256 proposalId, address positionToken);

    function __TraderPoolRiskyProposal_init(ParentTraderPoolInfo calldata parentTraderPoolInfo)
        public
        initializer
    {
        __TraderPoolProposal_init(parentTraderPoolInfo);
    }

    function changeProposalRestrictions(uint256 proposalId, ProposalLimits calldata proposalLimits)
        external
        override
        onlyTraderAdmin
    {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");

        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalRestrictionsChanged(proposalId, msg.sender);
    }

    function getProposalInfos(uint256 offset, uint256 limit)
        external
        view
        override
        returns (ProposalInfoExtended[] memory proposals)
    {
        return
            TraderPoolRiskyProposalView.getProposalInfos(
                _proposalInfos,
                _investors,
                offset,
                limit
            );
    }

    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view override returns (ActiveInvestmentInfo[] memory investments) {
        return
            TraderPoolRiskyProposalView.getActiveInvestmentsInfo(
                _activeInvestments[user],
                _baseBalances,
                _lpBalances,
                _proposalInfos,
                user,
                offset,
                limit
            );
    }

    function getUserInvestmentsLimits(address user, uint256[] calldata proposalIds)
        external
        view
        override
        returns (uint256[] memory lps)
    {
        return _parentTraderPoolInfo.getUserInvestmentsLimits(_lpBalances, user, proposalIds);
    }

    function getCreationTokens(
        address token,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        address[] calldata optionalPath
    )
        external
        view
        override
        returns (
            uint256 positionTokens,
            uint256 positionTokenPrice,
            address[] memory path
        )
    {
        return
            _parentTraderPoolInfo.getCreationTokens(
                token,
                baseInvestment.percentage(instantTradePercentage),
                optionalPath
            );
    }

    function create(
        address token,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        uint256 minPositionOut,
        address[] calldata optionalPath
    ) external override onlyParentTraderPool returns (uint256 proposalId) {
        require(token.isContract(), "BTP: not a contract");
        require(token != _parentTraderPoolInfo.baseToken, "BTP: wrong proposal token");
        require(
            proposalLimits.timestampLimit == 0 || proposalLimits.timestampLimit >= block.timestamp,
            "TPRP: wrong timestamp"
        );
        require(
            proposalLimits.investLPLimit == 0 || proposalLimits.investLPLimit >= lpInvestment,
            "TPRP: wrong investment limit"
        );
        require(lpInvestment > 0 && baseInvestment > 0, "TPRP: zero investment");
        require(instantTradePercentage <= PERCENTAGE_100, "TPRP: percantage is bigger than 100");

        proposalId = ++proposalsTotalNum;

        address baseToken = _parentTraderPoolInfo.baseToken;
        address trader = _parentTraderPoolInfo.trader;

        priceFeed.checkAllowance(baseToken);
        priceFeed.checkAllowance(token);

        _proposalInfos[proposalId].token = token;
        _proposalInfos[proposalId].tokenDecimals = ERC20(token).decimals();
        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalCreated(proposalId, token, proposalLimits);

        _transferAndMintLP(proposalId, trader, lpInvestment, baseInvestment);
        _investActivePortfolio(
            proposalId,
            baseInvestment,
            baseInvestment.percentage(instantTradePercentage),
            lpInvestment,
            optionalPath,
            minPositionOut
        );
    }

    function _investActivePortfolio(
        uint256 proposalId,
        uint256 baseInvestment,
        uint256 baseToExchange,
        uint256 lpInvestment,
        address[] memory optionalPath,
        uint256 minPositionOut
    ) internal {
        ProposalInfo storage info = _proposalInfos[proposalId];

        info.lpLocked += lpInvestment;
        info.balanceBase += baseInvestment - baseToExchange;

        if (baseToExchange > 0) {
            uint256 amountGot = priceFeed.normExchangeFromExact(
                _parentTraderPoolInfo.baseToken,
                info.token,
                baseToExchange,
                optionalPath,
                minPositionOut
            );

            info.balancePosition += amountGot;

            emit ProposalActivePortfolioExchanged(
                proposalId,
                _parentTraderPoolInfo.baseToken,
                info.token,
                baseToExchange,
                amountGot
            );
        }
    }

    function getInvestTokens(uint256 proposalId, uint256 baseInvestment)
        external
        view
        override
        returns (
            uint256 baseAmount,
            uint256 positionAmount,
            uint256 lp2Amount
        )
    {
        return
            _parentTraderPoolInfo.getInvestTokens(
                _proposalInfos[proposalId],
                proposalId,
                baseInvestment
            );
    }

    function getInvestmentPercentage(
        uint256 proposalId,
        address user,
        uint256 toBeInvested
    ) public view override returns (uint256) {
        uint256 lpBalance = totalLPBalances[user] +
            IERC20(_parentTraderPoolInfo.parentPoolAddress).balanceOf(user);

        return (_lpBalances[user][proposalId] + toBeInvested).ratio(PERCENTAGE_100, lpBalance);
    }

    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 minPositionOut
    ) external override onlyParentTraderPool {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");

        ProposalInfo storage info = _proposalInfos[proposalId];

        require(
            info.proposalLimits.timestampLimit == 0 ||
                block.timestamp <= info.proposalLimits.timestampLimit,
            "TPRP: proposal is closed"
        );
        require(
            info.proposalLimits.investLPLimit == 0 ||
                info.lpLocked + lpInvestment <= info.proposalLimits.investLPLimit,
            "TPRP: proposal is overinvested"
        );
        require(
            info.proposalLimits.maxTokenPriceLimit == 0 ||
                priceFeed.getNormPriceIn(_parentTraderPoolInfo.baseToken, info.token, DECIMALS) <=
                info.proposalLimits.maxTokenPriceLimit,
            "TPRP: token price too high"
        );

        address trader = _parentTraderPoolInfo.trader;

        if (user != trader) {
            uint256 traderPercentage = getInvestmentPercentage(proposalId, trader, 0);
            uint256 userPercentage = getInvestmentPercentage(proposalId, user, lpInvestment);

            require(userPercentage <= traderPercentage, "TPRP: investing more than trader");
        }

        _transferAndMintLP(proposalId, user, lpInvestment, baseInvestment);

        if (info.balancePosition + info.balanceBase > 0) {
            uint256 positionTokens = priceFeed.getNormPriceOut(
                info.token,
                _parentTraderPoolInfo.baseToken,
                info.balancePosition
            );
            uint256 baseToExchange = baseInvestment.ratio(
                positionTokens,
                positionTokens + info.balanceBase
            );

            _investActivePortfolio(
                proposalId,
                baseInvestment,
                baseToExchange,
                lpInvestment,
                new address[](0),
                minPositionOut
            );
        }
    }

    function _divestActivePortfolio(
        uint256 proposalId,
        uint256 lp2,
        uint256 minPositionOut
    ) internal returns (uint256 receivedBase) {
        ProposalInfo storage info = _proposalInfos[proposalId];
        uint256 supply = totalSupply(proposalId);

        uint256 baseShare = receivedBase = info.balanceBase.ratio(lp2, supply);
        uint256 positionShare = info.balancePosition.ratio(lp2, supply);

        if (positionShare > 0) {
            uint256 amountGot = priceFeed.normExchangeFromExact(
                info.token,
                _parentTraderPoolInfo.baseToken,
                positionShare,
                new address[](0),
                minPositionOut
            );

            info.balancePosition -= positionShare;
            receivedBase += amountGot;

            emit ProposalActivePortfolioExchanged(
                proposalId,
                info.token,
                _parentTraderPoolInfo.baseToken,
                positionShare,
                amountGot
            );
        }

        info.balanceBase -= baseShare;
    }

    function _divestProposalTrader(uint256 proposalId, uint256 lp2) internal returns (uint256) {
        require(
            _proposalInfos[proposalId].balancePosition == 0,
            "TPRP: divesting with open position"
        );

        return _divestActivePortfolio(proposalId, lp2, 0);
    }

    function getDivestAmounts(uint256[] calldata proposalIds, uint256[] calldata lp2s)
        external
        view
        override
        returns (Receptions memory receptions)
    {
        return _parentTraderPoolInfo.getDivestAmounts(_proposalInfos, proposalIds, lp2s);
    }

    function divest(
        uint256 proposalId,
        address user,
        uint256 lp2,
        uint256 minPositionOut
    ) public override onlyParentTraderPool returns (uint256 receivedBase) {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");
        require(balanceOf(user, proposalId) >= lp2, "TPRP: divesting more than balance");

        if (user == _parentTraderPoolInfo.trader) {
            receivedBase = _divestProposalTrader(proposalId, lp2);
        } else {
            receivedBase = _divestActivePortfolio(proposalId, lp2, minPositionOut);
        }

        (uint256 lpToBurn, uint256 baseToBurn) = _updateFrom(user, proposalId, lp2, false);
        _burn(user, proposalId, lp2);

        _proposalInfos[proposalId].lpLocked -= lpToBurn;

        totalLockedLP -= lpToBurn;
        investedBase -= baseToBurn;
    }

    function exchange(
        uint256 proposalId,
        address from,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");

        ProposalInfo storage info = _proposalInfos[proposalId];

        address baseToken = _parentTraderPoolInfo.baseToken;
        address positionToken = info.token;
        address to;

        require(from == baseToken || from == positionToken, "TPRP: invalid from token");

        if (from == baseToken) {
            to = positionToken;
        } else {
            to = baseToken;
        }

        uint256 amountGot;

        if (exType == ITraderPoolRiskyProposal.ExchangeType.FROM_EXACT) {
            if (from == baseToken) {
                require(amount <= info.balanceBase, "TPRP: wrong base amount");
            } else {
                require(amount <= info.balancePosition, "TPRP: wrong position amount");
            }

            amountGot = priceFeed.normExchangeFromExact(
                from,
                to,
                amount,
                optionalPath,
                amountBound
            );
        } else {
            if (from == baseToken) {
                require(amountBound <= info.balanceBase, "TPRP: wrong base amount");
            } else {
                require(amountBound <= info.balancePosition, "TPRP: wrong position amount");
            }

            amountGot = priceFeed.normExchangeToExact(from, to, amount, optionalPath, amountBound);

            (amount, amountGot) = (amountGot, amount);
        }

        emit ProposalExchanged(proposalId, msg.sender, from, to, amount, amountGot);

        if (from == baseToken) {
            info.balanceBase -= amount;
            info.balancePosition += amountGot;
        } else {
            info.balanceBase += amountGot;
            info.balancePosition -= amount;

            if (info.balancePosition == 0) {
                emit ProposalPositionClosed(proposalId, from);
            }
        }
    }

    function getExchangeAmount(
        uint256 proposalId,
        address from,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view override returns (uint256, address[] memory) {
        return
            _parentTraderPoolInfo.getExchangeAmount(
                _proposalInfos[proposalId].token,
                proposalId,
                from,
                amount,
                optionalPath,
                exType
            );
    }

    function _baseInProposal(uint256 proposalId) internal view override returns (uint256) {
        return
            _proposalInfos[proposalId].balanceBase +
            priceFeed.getNormPriceOut(
                _proposalInfos[proposalId].token,
                _parentTraderPoolInfo.baseToken,
                _proposalInfos[proposalId].balancePosition
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../interfaces/trader/ITraderPoolInvestProposal.sol";
import "../interfaces/trader/IInvestTraderPool.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";
import "@dlsl/dev-modules/libs/arrays/ArrayHelper.sol";

import "../libs/TraderPoolProposal/TraderPoolInvestProposalView.sol";

import "../core/Globals.sol";
import "./TraderPoolProposal.sol";

contract TraderPoolInvestProposal is ITraderPoolInvestProposal, TraderPoolProposal {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using DecimalsConverter for uint256;
    using ArrayHelper for uint256;
    using ArrayHelper for address;
    using MathHelper for uint256;
    using Math for uint256;
    using TraderPoolInvestProposalView for ParentTraderPoolInfo;

    mapping(uint256 => ProposalInfo) internal _proposalInfos; // proposal id => info
    mapping(uint256 => RewardInfo) internal _rewardInfos; // proposal id => reward info

    mapping(address => mapping(uint256 => UserRewardInfo)) internal _userRewardInfos; // user => proposal id => user reward info

    event ProposalCreated(
        uint256 proposalId,
        ITraderPoolInvestProposal.ProposalLimits proposalLimits
    );
    event ProposalWithdrawn(uint256 proposalId, address sender, uint256 amount);
    event ProposalSupplied(
        uint256 proposalId,
        address sender,
        uint256[] amounts,
        address[] tokens
    );
    event ProposalClaimed(uint256 proposalId, address user, uint256[] amounts, address[] tokens);

    function __TraderPoolInvestProposal_init(ParentTraderPoolInfo calldata parentTraderPoolInfo)
        public
        initializer
    {
        __TraderPoolProposal_init(parentTraderPoolInfo);
    }

    function changeProposalRestrictions(uint256 proposalId, ProposalLimits calldata proposalLimits)
        external
        override
        onlyTraderAdmin
    {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalRestrictionsChanged(proposalId, msg.sender);
    }

    function getProposalInfos(uint256 offset, uint256 limit)
        external
        view
        override
        returns (ProposalInfoExtended[] memory proposals)
    {
        return
            TraderPoolInvestProposalView.getProposalInfos(
                _proposalInfos,
                _investors,
                offset,
                limit
            );
    }

    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view override returns (ActiveInvestmentInfo[] memory investments) {
        return
            TraderPoolInvestProposalView.getActiveInvestmentsInfo(
                _activeInvestments[user],
                _baseBalances,
                _lpBalances,
                user,
                offset,
                limit
            );
    }

    function _baseInProposal(uint256 proposalId) internal view override returns (uint256) {
        return _proposalInfos[proposalId].investedBase;
    }

    function create(
        string calldata descriptionURL,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external override onlyParentTraderPool returns (uint256 proposalId) {
        require(
            proposalLimits.timestampLimit == 0 || proposalLimits.timestampLimit >= block.timestamp,
            "TPIP: wrong timestamp"
        );
        require(
            proposalLimits.investLPLimit == 0 || proposalLimits.investLPLimit >= lpInvestment,
            "TPIP: wrong investment limit"
        );
        require(lpInvestment > 0 && baseInvestment > 0, "TPIP: zero investment");

        proposalId = ++proposalsTotalNum;

        address trader = _parentTraderPoolInfo.trader;

        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalCreated(proposalId, proposalLimits);

        _transferAndMintLP(proposalId, trader, lpInvestment, baseInvestment);

        _proposalInfos[proposalId].descriptionURL = descriptionURL;
        _proposalInfos[proposalId].lpLocked = lpInvestment;
        _proposalInfos[proposalId].investedBase = baseInvestment;
        _proposalInfos[proposalId].newInvestedBase = baseInvestment;
    }

    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external override onlyParentTraderPool {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        ProposalInfo storage info = _proposalInfos[proposalId];

        require(
            info.proposalLimits.timestampLimit == 0 ||
                block.timestamp <= info.proposalLimits.timestampLimit,
            "TPIP: proposal is closed"
        );
        require(
            info.proposalLimits.investLPLimit == 0 ||
                info.lpLocked + lpInvestment <= info.proposalLimits.investLPLimit,
            "TPIP: proposal is overinvested"
        );

        _updateRewards(proposalId, user);
        _transferAndMintLP(proposalId, user, lpInvestment, baseInvestment);

        info.lpLocked += lpInvestment;
        info.investedBase += baseInvestment;
        info.newInvestedBase += baseInvestment;
    }

    function getRewards(uint256[] calldata proposalIds, address user)
        external
        view
        override
        returns (Receptions memory receptions)
    {
        return
            TraderPoolInvestProposalView.getRewards(
                _rewardInfos,
                _userRewardInfos,
                proposalIds,
                user
            );
    }

    function _payout(
        address user,
        uint256[] memory claimed,
        address[] memory addresses
    ) internal {
        for (uint256 i = 0; i < addresses.length; i++) {
            address token = addresses[i];

            if (token == address(0)) {
                continue;
            }

            IERC20(token).safeTransfer(user, claimed[i].from18(ERC20(token).decimals()));
        }
    }

    function _updateCumulativeSum(
        uint256 proposalId,
        uint256 amount,
        address token
    ) internal {
        RewardInfo storage rewardInfo = _rewardInfos[proposalId];

        rewardInfo.rewardTokens.add(token);
        rewardInfo.cumulativeSums[token] += PRECISION.ratio(amount, totalSupply(proposalId));
    }

    function _updateRewards(uint256 proposalId, address user) internal {
        UserRewardInfo storage userRewardInfo = _userRewardInfos[user][proposalId];
        RewardInfo storage rewardInfo = _rewardInfos[proposalId];

        uint256 length = rewardInfo.rewardTokens.length();

        for (uint256 i = 0; i < length; i++) {
            address token = rewardInfo.rewardTokens.at(i);
            uint256 cumulativeSum = rewardInfo.cumulativeSums[token];

            userRewardInfo.rewardsStored[token] +=
                ((cumulativeSum - userRewardInfo.cumulativeSumsStored[token]) *
                    balanceOf(user, proposalId)) /
                PRECISION;
            userRewardInfo.cumulativeSumsStored[token] = cumulativeSum;
        }
    }

    function _calculateRewards(uint256 proposalId, address user)
        internal
        returns (
            uint256 totalClaimed,
            uint256[] memory claimed,
            address[] memory addresses
        )
    {
        _updateRewards(proposalId, user);

        RewardInfo storage rewardInfo = _rewardInfos[proposalId];
        uint256 length = rewardInfo.rewardTokens.length();

        claimed = new uint256[](length);
        addresses = new address[](length);

        address baseToken = _parentTraderPoolInfo.baseToken;
        uint256 baseIndex;

        for (uint256 i = 0; i < length; i++) {
            address token = rewardInfo.rewardTokens.at(i);

            claimed[i] = _userRewardInfos[user][proposalId].rewardsStored[token];
            addresses[i] = token;
            totalClaimed += claimed[i];

            delete _userRewardInfos[user][proposalId].rewardsStored[token];

            if (token == baseToken) {
                baseIndex = i;
            }
        }

        if (length > 0) {
            /// @dev make the base token first (if not found, do nothing)
            (claimed[0], claimed[baseIndex]) = (claimed[baseIndex], claimed[0]);
            (addresses[0], addresses[baseIndex]) = (addresses[baseIndex], addresses[0]);
        }
    }

    function divest(uint256 proposalId, address user)
        external
        override
        onlyParentTraderPool
        returns (uint256 claimedBase)
    {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        (
            uint256 totalClaimed,
            uint256[] memory claimed,
            address[] memory addresses
        ) = _calculateRewards(proposalId, user);

        require(totalClaimed > 0, "TPIP: nothing to divest");

        emit ProposalClaimed(proposalId, user, claimed, addresses);

        if (addresses[0] == _parentTraderPoolInfo.baseToken) {
            claimedBase = claimed[0];
            addresses[0] = address(0);

            _proposalInfos[proposalId].lpLocked -= claimed[0].min(
                _proposalInfos[proposalId].lpLocked
            );

            _updateFromData(user, proposalId, claimed[0]);
            investedBase -= claimed[0].min(investedBase);
            totalLockedLP -= claimed[0].min(totalLockedLP); // intentional base from LP subtraction
        }

        _payout(user, claimed, addresses);
    }

    function withdraw(uint256 proposalId, uint256 amount) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");
        require(
            amount <= _proposalInfos[proposalId].newInvestedBase,
            "TPIP: withdrawing more than balance"
        );

        _proposalInfos[proposalId].newInvestedBase -= amount;

        IERC20(_parentTraderPoolInfo.baseToken).safeTransfer(
            _parentTraderPoolInfo.trader,
            amount.from18(_parentTraderPoolInfo.baseTokenDecimals)
        );

        emit ProposalWithdrawn(proposalId, msg.sender, amount);
    }

    function supply(
        uint256 proposalId,
        uint256[] calldata amounts,
        address[] calldata addresses
    ) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");
        require(addresses.length == amounts.length, "TPIP: length mismatch");

        for (uint256 i = 0; i < addresses.length; i++) {
            address token = addresses[i];
            uint256 actualAmount = amounts[i].from18(ERC20(token).decimals());

            require(actualAmount > 0, "TPIP: amount is 0");

            IERC20(token).safeTransferFrom(msg.sender, address(this), actualAmount);

            _updateCumulativeSum(proposalId, amounts[i], token);
        }

        emit ProposalSupplied(proposalId, msg.sender, amounts, addresses);
    }

    function convertInvestedBaseToDividends(uint256 proposalId) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        uint256 newInvestedBase = _proposalInfos[proposalId].newInvestedBase;
        address baseToken = _parentTraderPoolInfo.baseToken;

        _updateCumulativeSum(proposalId, newInvestedBase, baseToken);

        emit ProposalWithdrawn(proposalId, msg.sender, newInvestedBase);
        emit ProposalSupplied(
            proposalId,
            msg.sender,
            newInvestedBase.asArray(),
            baseToken.asArray()
        );

        delete _proposalInfos[proposalId].newInvestedBase;
    }

    function _updateFrom(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        bool isTransfer
    ) internal override returns (uint256 lpTransfer, uint256 baseTransfer) {
        _updateRewards(proposalId, user);

        return super._updateFrom(user, proposalId, lp2Amount, isTransfer);
    }

    function _updateTo(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal override {
        _updateRewards(proposalId, user);

        super._updateTo(user, proposalId, lp2Amount, lpAmount, baseAmount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/pool-contracts-registry/AbstractPoolContractsRegistry.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "../interfaces/trader/ITraderPoolRegistry.sol";
import "../interfaces/core/IContractsRegistry.sol";

contract TraderPoolRegistry is ITraderPoolRegistry, AbstractPoolContractsRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Paginator for EnumerableSet.AddressSet;
    using Math for uint256;

    string public constant BASIC_POOL_NAME = "BASIC_POOL";
    string public constant INVEST_POOL_NAME = "INVEST_POOL";
    string public constant RISKY_PROPOSAL_NAME = "RISKY_POOL_PROPOSAL";
    string public constant INVEST_PROPOSAL_NAME = "INVEST_POOL_PROPOSAL";

    address internal _poolFactory;

    mapping(address => mapping(string => EnumerableSet.AddressSet)) internal _traderPools; // trader => name => pool

    function _onlyPoolFactory() internal view override {
        require(_poolFactory == _msgSender(), "TraderPoolRegistry: Caller is not a factory");
    }

    function setDependencies(address contractsRegistry) public override {
        super.setDependencies(contractsRegistry);

        _poolFactory = IContractsRegistry(contractsRegistry).getPoolFactoryContract();
    }

    function associateUserWithPool(
        address user,
        string calldata name,
        address poolAddress
    ) external onlyPoolFactory {
        _traderPools[user][name].add(poolAddress);
    }

    function countTraderPools(address user, string calldata name)
        external
        view
        override
        returns (uint256)
    {
        return _traderPools[user][name].length();
    }

    function listTraderPools(
        address user,
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory pools) {
        return _traderPools[user][name].part(offset, limit);
    }

    function listPoolsWithInfo(
        string calldata name,
        uint256 offset,
        uint256 limit
    )
        external
        view
        override
        returns (
            address[] memory pools,
            ITraderPool.PoolInfo[] memory poolInfos,
            ITraderPool.LeverageInfo[] memory leverageInfos
        )
    {
        pools = _pools[name].part(offset, limit);

        poolInfos = new ITraderPool.PoolInfo[](pools.length);
        leverageInfos = new ITraderPool.LeverageInfo[](pools.length);

        for (uint256 i = 0; i < pools.length; i++) {
            poolInfos[i] = ITraderPool(pools[i]).getPoolInfo();
            leverageInfos[i] = ITraderPool(pools[i]).getLeverageInfo();
        }
    }

    function isBasicPool(address potentialPool) public view override returns (bool) {
        return _pools[BASIC_POOL_NAME].contains(potentialPool);
    }

    function isInvestPool(address potentialPool) public view override returns (bool) {
        return _pools[INVEST_POOL_NAME].contains(potentialPool);
    }

    function isPool(address potentialPool) external view override returns (bool) {
        return isBasicPool(potentialPool) || isInvestPool(potentialPool);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "../interfaces/core/ICoreProperties.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/AddressSetHelper.sol";

import "./Globals.sol";

contract CoreProperties is ICoreProperties, OwnableUpgradeable, AbstractDependant {
    using EnumerableSet for EnumerableSet.AddressSet;
    using AddressSetHelper for EnumerableSet.AddressSet;
    using Paginator for EnumerableSet.AddressSet;
    using Math for uint256;

    CoreParameters public coreParameters;

    address internal _insuranceAddress;
    address internal _treasuryAddress;
    address internal _dividendsAddress;

    EnumerableSet.AddressSet internal _whitelistTokens;
    EnumerableSet.AddressSet internal _blacklistTokens;

    function __CoreProperties_init(CoreParameters calldata _coreParameters) external initializer {
        __Ownable_init();

        coreParameters = _coreParameters;
    }

    function setDependencies(address contractsRegistry) public virtual override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        _insuranceAddress = registry.getInsuranceContract();
        _treasuryAddress = registry.getTreasuryContract();
        _dividendsAddress = registry.getDividendsContract();
    }

    function setCoreParameters(CoreParameters calldata _coreParameters)
        external
        override
        onlyOwner
    {
        coreParameters = _coreParameters;
    }

    function addWhitelistTokens(address[] calldata tokens) external override onlyOwner {
        _whitelistTokens.add(tokens);
    }

    function removeWhitelistTokens(address[] calldata tokens) external override onlyOwner {
        _whitelistTokens.remove(tokens);
    }

    function addBlacklistTokens(address[] calldata tokens) external override onlyOwner {
        _blacklistTokens.add(tokens);
    }

    function removeBlacklistTokens(address[] calldata tokens) external override onlyOwner {
        _blacklistTokens.remove(tokens);
    }

    function setMaximumPoolInvestors(uint256 count) external override onlyOwner {
        coreParameters.maxPoolInvestors = count;
    }

    function setMaximumOpenPositions(uint256 count) external override onlyOwner {
        coreParameters.maxOpenPositions = count;
    }

    function setTraderLeverageParams(uint256 threshold, uint256 slope)
        external
        override
        onlyOwner
    {
        coreParameters.leverageThreshold = threshold;
        coreParameters.leverageSlope = slope;
    }

    function setCommissionInitTimestamp(uint256 timestamp) external override onlyOwner {
        coreParameters.commissionInitTimestamp = timestamp;
    }

    function setCommissionDurations(uint256[] calldata durations) external override onlyOwner {
        coreParameters.commissionDurations = durations;
    }

    function setDEXECommissionPercentages(
        uint256 dexeCommission,
        uint256[] calldata distributionPercentages
    ) external override onlyOwner {
        coreParameters.dexeCommissionPercentage = dexeCommission;
        coreParameters.dexeCommissionDistributionPercentages = distributionPercentages;
    }

    function setTraderCommissionPercentages(
        uint256 minTraderCommission,
        uint256[] calldata maxTraderCommissions
    ) external override onlyOwner {
        coreParameters.minTraderCommission = minTraderCommission;
        coreParameters.maxTraderCommissions = maxTraderCommissions;
    }

    function setDelayForRiskyPool(uint256 delayForRiskyPool) external override onlyOwner {
        coreParameters.delayForRiskyPool = delayForRiskyPool;
    }

    function setInsuranceParameters(
        uint256 insuranceFactor,
        uint256 maxInsurancePoolShare,
        uint256 minInsuranceDeposit,
        uint256 minInsuranceProposalAmount,
        uint256 insuranceWithdrawalLock
    ) external override onlyOwner {
        coreParameters.insuranceFactor = insuranceFactor;
        coreParameters.maxInsurancePoolShare = maxInsurancePoolShare;
        coreParameters.minInsuranceDeposit = minInsuranceDeposit;
        coreParameters.minInsuranceProposalAmount = minInsuranceProposalAmount;
        coreParameters.insuranceWithdrawalLock = insuranceWithdrawalLock;
    }

    function totalWhitelistTokens() external view override returns (uint256) {
        return _whitelistTokens.length();
    }

    function totalBlacklistTokens() external view override returns (uint256) {
        return _blacklistTokens.length();
    }

    function getWhitelistTokens(uint256 offset, uint256 limit)
        external
        view
        override
        returns (address[] memory tokens)
    {
        return _whitelistTokens.part(offset, limit);
    }

    function getBlacklistTokens(uint256 offset, uint256 limit)
        external
        view
        override
        returns (address[] memory tokens)
    {
        return _blacklistTokens.part(offset, limit);
    }

    function isWhitelistedToken(address token) external view override returns (bool) {
        return _whitelistTokens.contains(token);
    }

    function isBlacklistedToken(address token) external view override returns (bool) {
        return _blacklistTokens.contains(token);
    }

    function getFilteredPositions(address[] memory positions)
        external
        view
        override
        returns (address[] memory filteredPositions)
    {
        uint256 newLength = positions.length;

        for (uint256 i = positions.length; i > 0; i--) {
            if (_blacklistTokens.contains(positions[i - 1])) {
                if (i == newLength) {
                    --newLength;
                } else {
                    positions[i - 1] = positions[--newLength];
                }
            }
        }

        filteredPositions = new address[](newLength);

        for (uint256 i = 0; i < newLength; i++) {
            filteredPositions[i] = positions[i];
        }
    }

    function getMaximumPoolInvestors() external view override returns (uint256) {
        return coreParameters.maxPoolInvestors;
    }

    function getMaximumOpenPositions() external view override returns (uint256) {
        return coreParameters.maxOpenPositions;
    }

    function getTraderLeverageParams() external view override returns (uint256, uint256) {
        return (coreParameters.leverageThreshold, coreParameters.leverageSlope);
    }

    function getCommissionInitTimestamp() public view override returns (uint256) {
        return coreParameters.commissionInitTimestamp;
    }

    function getCommissionDuration(CommissionPeriod period)
        public
        view
        override
        returns (uint256)
    {
        return coreParameters.commissionDurations[uint256(period)];
    }

    function getDEXECommissionPercentages()
        external
        view
        override
        returns (
            uint256,
            uint256[] memory,
            address[3] memory
        )
    {
        return (
            coreParameters.dexeCommissionPercentage,
            coreParameters.dexeCommissionDistributionPercentages,
            [_insuranceAddress, _treasuryAddress, _dividendsAddress]
        );
    }

    function getTraderCommissions() external view override returns (uint256, uint256[] memory) {
        return (coreParameters.minTraderCommission, coreParameters.maxTraderCommissions);
    }

    function getDelayForRiskyPool() external view override returns (uint256) {
        return coreParameters.delayForRiskyPool;
    }

    function getInsuranceFactor() external view override returns (uint256) {
        return coreParameters.insuranceFactor;
    }

    function getMaxInsurancePoolShare() external view override returns (uint256) {
        return coreParameters.maxInsurancePoolShare;
    }

    function getMinInsuranceDeposit() external view override returns (uint256) {
        return coreParameters.minInsuranceDeposit;
    }

    function getMinInsuranceProposalAmount() external view override returns (uint256) {
        return coreParameters.minInsuranceProposalAmount;
    }

    function getInsuranceWithdrawalLock() external view override returns (uint256) {
        return coreParameters.insuranceWithdrawalLock;
    }

    function getCommissionEpochByTimestamp(uint256 timestamp, CommissionPeriod commissionPeriod)
        external
        view
        override
        returns (uint256)
    {
        return
            (timestamp - getCommissionInitTimestamp()) /
            getCommissionDuration(commissionPeriod) +
            1;
    }

    function getCommissionTimestampByEpoch(uint256 epoch, CommissionPeriod commissionPeriod)
        external
        view
        override
        returns (uint256)
    {
        return getCommissionInitTimestamp() + epoch * getCommissionDuration(commissionPeriod);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

uint256 constant PERCENTAGE_100 = 10**27;
uint256 constant PRECISION = 10**25;
uint256 constant DECIMALS = 10**18;

uint256 constant MAX_UINT = type(uint256).max;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the contract that stores proposal settings that will be used by the governance pool
 */
interface IGovSettings {
    struct ProposalSettings {
        bool earlyCompletion;
        uint64 duration;
        uint64 durationValidators;
        uint128 quorum;
        uint128 quorumValidators;
        uint256 minTokenBalance;
        uint256 minNftBalance;
    }

    /// @notice Add new types to contract
    /// @param _settings New settings
    function addSettings(ProposalSettings[] calldata _settings) external;

    /// @notice Edit existed type
    /// @param settingsIds Existed settings IDs
    /// @param _settings New settings
    function editSettings(uint256[] calldata settingsIds, ProposalSettings[] calldata _settings)
        external;

    /// @notice Change executors association
    /// @param executors Addresses
    /// @param settingsIds New types
    function changeExecutors(address[] calldata executors, uint256[] calldata settingsIds)
        external;

    /// @notice The function the get executor's info
    /// @param executor Executor address
    /// @return settings ID for `executor`
    /// @return `true` if `executor` is current address
    /// @return `true` if `executor` has valid `ProposalSettings`
    function executorInfo(address executor)
        external
        view
        returns (
            uint256,
            bool,
            bool
        );

    /// @notice The function to get default settings
    /// @return default setting
    function getDefaultSettings() external view returns (ProposalSettings memory);

    /// @notice The function the get the settings of the executor
    /// @param executor Executor address
    /// @return `ProposalSettings` by `executor` address
    function getSettings(address executor) external view returns (ProposalSettings memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the central contract of the protocol which stores the parameters that may be modified by the DAO.
 * These are commissions percentages, trader leverage formula parameters, insurance parameters and pools parameters
 */
interface ICoreProperties {
    /// @notice 3 types of commission periods
    enum CommissionPeriod {
        PERIOD_1,
        PERIOD_2,
        PERIOD_3
    }

    /// @notice 3 commission receivers
    enum CommissionTypes {
        INSURANCE,
        TREASURY,
        DIVIDENDS
    }

    /// @notice The struct that stores vital platform's parameters that may be modified by the OWNER
    /// @param maxPoolInvestors the maximum number of investors in the TraderPool
    /// @param maxOpenPositions the maximum number of concurrently opened positions by a trader
    /// @param leverageThreshold the first parameter in the trader's formula
    /// @param leverageSlope the second parameters in the trader's formula
    /// @param commissionInitTimestamp the initial timestamp of the commission rounds
    /// @param commissionDurations the durations of the commission periods in seconds - see enum CommissionPeriod
    /// @param dexeCommissionPercentage the protocol's commission percentage, multiplied by 10**25
    /// @param dexeCommissionDistributionPercentages the individual percentages of the commission contracts (should sum up to 10**27 = 100%)
    /// @param minTraderCommission the minimal trader's commission the trader can specify
    /// @param maxTraderCommissions the maximal trader's commission the trader can specify based on the chosen commission period
    /// @param delayForRiskyPool the investment delay after the first exchange in the risky pool in seconds
    /// @param insuranceFactor the deposit insurance multiplier. Means how many insurance tokens is received per deposited token
    /// @param maxInsurancePoolShare the maximal share of the pool which can be used to pay out the insurance. 3 = 1/3 of the pool
    /// @param minInsuranceDeposit the minimal required deposit in DEXE tokens to receive an insurance
    /// @param minInsuranceProposalAmount the minimal amount of DEXE to be on insurance deposit to propose claims
    /// @param insuranceWithdrawalLock the time needed to wait to withdraw tokens from the insurance after the deposit
    struct CoreParameters {
        uint256 maxPoolInvestors;
        uint256 maxOpenPositions;
        uint256 leverageThreshold;
        uint256 leverageSlope;
        uint256 commissionInitTimestamp;
        uint256[] commissionDurations;
        uint256 dexeCommissionPercentage;
        uint256[] dexeCommissionDistributionPercentages;
        uint256 minTraderCommission;
        uint256[] maxTraderCommissions;
        uint256 delayForRiskyPool;
        uint256 insuranceFactor;
        uint256 maxInsurancePoolShare;
        uint256 minInsuranceDeposit;
        uint256 minInsuranceProposalAmount;
        uint256 insuranceWithdrawalLock;
    }

    /// @notice The function to set CoreParameters
    /// @param _coreParameters the parameters
    function setCoreParameters(CoreParameters calldata _coreParameters) external;

    /// @notice This function adds new tokens that will be made available for the BaseTraderPool trading
    /// @param tokens the array of tokens to be whitelisted
    function addWhitelistTokens(address[] calldata tokens) external;

    /// @notice This function removes tokens from the whitelist, disabling BasicTraderPool trading of these tokens
    /// @param tokens basetokens to be removed
    function removeWhitelistTokens(address[] calldata tokens) external;

    /// @notice This function adds tokens to the blacklist, automatically updating pools positions and disabling
    /// all of the pools of trading these tokens. DAO might permanently ban malicious tokens this way
    /// @param tokens the tokens to be added to the blacklist
    function addBlacklistTokens(address[] calldata tokens) external;

    /// @notice The function that removes tokens from the blacklist, automatically updating pools positions
    /// and enabling trading of these tokens
    /// @param tokens the tokens to be removed from the blacklist
    function removeBlacklistTokens(address[] calldata tokens) external;

    /// @notice The function to set the maximum pool investors
    /// @param count new maximum pool investors
    function setMaximumPoolInvestors(uint256 count) external;

    /// @notice The function to set the maximum concurrent pool positions
    /// @param count new maximum pool positions
    function setMaximumOpenPositions(uint256 count) external;

    /// @notice The function the adjust trader leverage formula
    /// @param threshold new first parameter of the leverage function
    /// @param slope new second parameter of the leverage formula
    function setTraderLeverageParams(uint256 threshold, uint256 slope) external;

    /// @notice The function to set new initial timestamp of the commission rounds
    /// @param timestamp new timestamp (in seconds)
    function setCommissionInitTimestamp(uint256 timestamp) external;

    /// @notice The function to change the commission durations for the commission periods
    /// @param durations the array of new durations (in seconds)
    function setCommissionDurations(uint256[] calldata durations) external;

    /// @notice The function to modify the platform's commission percentages
    /// @param dexeCommission DEXE percentage commission. Should be multiplied by 10**25
    /// @param distributionPercentages the percentages of the individual contracts (has to add up to 10**27)
    function setDEXECommissionPercentages(
        uint256 dexeCommission,
        uint256[] calldata distributionPercentages
    ) external;

    /// @notice The function to set new bounds for the trader commission
    /// @param minTraderCommission the lower bound of the trade's commission
    /// @param maxTraderCommissions the array of upper bound commissions per period
    function setTraderCommissionPercentages(
        uint256 minTraderCommission,
        uint256[] calldata maxTraderCommissions
    ) external;

    /// @notice The function to set new investment delay for the risky pool
    /// @param delayForRiskyPool new investment delay after the first exchange
    function setDelayForRiskyPool(uint256 delayForRiskyPool) external;

    /// @notice The function to set new insurance parameters
    /// @param insuranceFactor the deposit tokens multiplier
    /// @param maxInsurancePoolShare the maximum share of the insurance pool to be paid in a single payout
    /// @param minInsuranceDeposit the minimum allowed deposit in DEXE tokens to receive an insurance
    /// @param minInsuranceProposalAmount the minimal amount of DEXE to be on insurance deposit to propose claims
    /// @param insuranceWithdrawalLock the time needed to wait to withdraw tokens from the insurance after the deposit
    function setInsuranceParameters(
        uint256 insuranceFactor,
        uint256 maxInsurancePoolShare,
        uint256 minInsuranceDeposit,
        uint256 minInsuranceProposalAmount,
        uint256 insuranceWithdrawalLock
    ) external;

    /// @notice The function that returns the total number of whitelisted tokens
    /// @return the number of whitelisted tokens
    function totalWhitelistTokens() external view returns (uint256);

    /// @notice The function that returns the total number of blacklisted tokens
    /// @return the number of blacklisted tokens
    function totalBlacklistTokens() external view returns (uint256);

    /// @notice The paginated function to get addresses of whitelisted tokens
    /// @param offset the starting index of the tokens array
    /// @param limit the length of the array to observe
    /// @return tokens requested whitelist array
    function getWhitelistTokens(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory tokens);

    /// @notice The paginated function to get addresses of blacklisted tokens
    /// @param offset the starting index of the tokens array
    /// @param limit the length of the array to observe
    /// @return tokens requested blacklist array
    function getBlacklistTokens(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory tokens);

    /// @notice This function checks if the provided token can be opened in the BasicTraderPool
    /// @param token the token to be checked
    /// @return true if the token can be traded as the position, false otherwise
    function isWhitelistedToken(address token) external view returns (bool);

    /// @notice This function checks if the provided token is blacklisted
    /// @param token the token to be checked
    /// @return true if the token is blacklisted, false otherwise
    function isBlacklistedToken(address token) external view returns (bool);

    /// @notice The helper function that filters the provided positions tokens according to the blacklist
    /// @param positions the addresses of tokens
    /// @return filteredPositions the array of tokens without the ones in the blacklist
    function getFilteredPositions(address[] memory positions)
        external
        view
        returns (address[] memory filteredPositions);

    /// @notice The function to fetch the maximum pool investors
    /// @return maximum pool investors
    function getMaximumPoolInvestors() external view returns (uint256);

    /// @notice The function to fetch the maximum concurrently opened positions
    /// @return the maximum concurrently opened positions
    function getMaximumOpenPositions() external view returns (uint256);

    /// @notice The function to get trader's leverage function parameters
    /// @return threshold the first function parameter
    /// @return slope the second function parameter
    function getTraderLeverageParams() external view returns (uint256 threshold, uint256 slope);

    /// @notice The function to get the initial commission timestamp
    /// @return the initial timestamp
    function getCommissionInitTimestamp() external view returns (uint256);

    /// @notice The function the get the commission duration for the specified period
    /// @param period the commission period
    function getCommissionDuration(CommissionPeriod period) external view returns (uint256);

    /// @notice The function to get DEXE commission percentages and receivers
    /// @return totalPercentage the overall DEXE commission percentage
    /// @return individualPercentages the array of individual receiver's percentages
    /// individualPercentages[INSURANCE] - insurance commission
    /// individualPercentages[TREASURY] - treasury commission
    /// individualPercentages[DIVIDENDS] - dividends commission
    /// @return commissionReceivers the commission receivers
    function getDEXECommissionPercentages()
        external
        view
        returns (
            uint256 totalPercentage,
            uint256[] memory individualPercentages,
            address[3] memory commissionReceivers
        );

    /// @notice The function to get trader's commission info
    /// @return minTraderCommission minimal available trader commission
    /// @return maxTraderCommissions maximal available trader commission per period
    function getTraderCommissions()
        external
        view
        returns (uint256 minTraderCommission, uint256[] memory maxTraderCommissions);

    /// @notice The function to get the investment delay of the risky pool
    /// @return the investment delay in seconds
    function getDelayForRiskyPool() external view returns (uint256);

    /// @notice The function to get the insurance deposit multiplier
    /// @return the multiplier
    function getInsuranceFactor() external view returns (uint256);

    /// @notice The function to get the max payout share of the insurance pool
    /// @return the max pool share to be paid in a single request
    function getMaxInsurancePoolShare() external view returns (uint256);

    /// @notice The function to get the min allowed insurance deposit
    /// @return the min allowed insurance deposit in DEXE tokens
    function getMinInsuranceDeposit() external view returns (uint256);

    /// @notice The function to get the min amount of tokens required to be able to propose claims
    /// @return the min amount of tokens required to propose claims
    function getMinInsuranceProposalAmount() external view returns (uint256);

    /// @notice The function to get insurance withdrawal lock duration
    /// @return the duration of insurance lock
    function getInsuranceWithdrawalLock() external view returns (uint256);

    /// @notice The function to get current commission epoch based on the timestamp and period
    /// @param timestamp the timestamp (should not be less than the initial timestamp)
    /// @param commissionPeriod the enum of commission durations
    /// @return the number of the epoch
    function getCommissionEpochByTimestamp(uint256 timestamp, CommissionPeriod commissionPeriod)
        external
        view
        returns (uint256);

    /// @notice The funcition to get the end timestamp of the provided commission epoch
    /// @param epoch the commission epoch to get the end timestamp for
    /// @param commissionPeriod the enum of commission durations
    /// @return the end timestamp of the provided commission epoch
    function getCommissionTimestampByEpoch(uint256 epoch, CommissionPeriod commissionPeriod)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function allowance(address owner, address spender) external view returns (uint256);

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
pragma solidity ^0.8.4;

/**
 * This is the price feed contract which is used to fetch the spot prices from the UniswapV2 protocol + execute swaps
 * on its pairs. The protocol does not require price oracles to be secure and reliable. There also is a pathfinder
 * built into the contract to find the optimal* path between the pairs
 */
interface IPriceFeed {
    /// @notice A struct this is returned from the UniswapV2PathFinder library when an optimal* path is found
    /// @param path the optimal* path itself
    /// @param amounts either the "amounts out" or "amounts in" required
    /// @param withProvidedPath a bool flag saying if the path is found via the specified path
    struct FoundPath {
        address[] path;
        uint256[] amounts;
        bool withProvidedPath;
    }

    /// @notice This function sets path tokens that will be used in the pathfinder
    /// @param pathTokens the array of tokens to be added into the path finder
    function addPathTokens(address[] calldata pathTokens) external;

    /// @notice This function removes path tokens from the pathfinder
    /// @param pathTokens the array of tokens to be removed from the pathfinder
    function removePathTokens(address[] calldata pathTokens) external;

    /// @notice This function tries to find the optimal exchange rate (the price) between "inToken" and "outToken" using
    /// custom pathfinder, saved paths and optional specified path. The optimality is reached when the amount of
    /// outTokens is maximal
    /// @param inToken the token to exchange from
    /// @param outToken the received token
    /// @param amountIn the amount of inToken to be exchanged (in inToken decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountOut amount of outToken after the swap (in outToken decimals)
    /// @return path the tokens path that will be used during the swap
    function getExtendedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice This function tries to find the optimal exchange rate (the price) between "inToken" and "outToken" using
    /// custom pathfinder, saved paths and optional specified path. The optimality is reached when the amount of
    /// inTokens is minimal
    /// @param inToken the token to exchange from
    /// @param outToken the received token
    /// @param amountOut the amount of outToken to be received (in inToken decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountIn amount of inToken to execute a swap (in outToken decimals)
    /// @return path the tokens path that will be used during the swap
    function getExtendedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceOut" function with automatic usage of saved paths.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountIn the amount of inToken to be exchanged (with 18 decimals)
    /// @return amountOut the received amount of outToken after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceIn" function with automatic usage of saved paths.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountOut the amount of outToken to be received (with 18 decimals)
    /// @return amountIn required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceOut" function.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountIn the amount of inToken to be exchanged (with 18 decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountOut the received amount of outToken after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedExtendedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceIn" function.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountOut the amount of outToken to be received (with 18 decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountIn the required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedExtendedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice The same as "getPriceOut" with "outToken" being native USD token
    /// @param inToken the token to be exchanged from
    /// @param amountIn the amount of inToken to exchange (with 18 decimals)
    /// @return amountOut the received amount of native USD tokens after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceOutUSD(address inToken, uint256 amountIn)
        external
        view
        returns (uint256 amountOut, address[] memory path);

    /// @notice The same as "getPriceIn" with "outToken" being USD token
    /// @param inToken the token to get the price of
    /// @param amountOut the amount of USD to be received (with 18 decimals)
    /// @return amountIn the required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceInUSD(address inToken, uint256 amountOut)
        external
        view
        returns (uint256 amountIn, address[] memory path);

    /// @notice The same as "getPriceOut" with "outToken" being DEXE token
    /// @param inToken the token to be exchanged from
    /// @param amountIn the amount of inToken to exchange (with 18 decimals)
    /// @return amountOut the received amount of DEXE tokens after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceOutDEXE(address inToken, uint256 amountIn)
        external
        view
        returns (uint256 amountOut, address[] memory path);

    /// @notice The same as "getPriceIn" with "outToken" being DEXE token
    /// @param inToken the token to get the price of
    /// @param amountOut the amount of DEXE to be received (with 18 decimals)
    /// @return amountIn the required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceInDEXE(address inToken, uint256 amountOut)
        external
        view
        returns (uint256 amountIn, address[] memory path);

    /// @notice The function that performs an actual Uniswap swap (swapExactTokensForTokens),
    /// taking the amountIn inToken tokens from the msg.sender and sending not less than minAmountOut outTokens back.
    /// The approval of amountIn tokens has to be made to this address beforehand
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountIn the amount of inToken tokens to be exchanged
    /// @param optionalPath the optional path that will be considered by the pathfinder to find the best route
    /// @param minAmountOut the minimal amount of outToken tokens that have to be received after the swap.
    /// basically this is a sandwich attack protection mechanism
    /// @return the amount of outToken tokens sent to the msg.sender after the swap
    function exchangeFromExact(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] calldata optionalPath,
        uint256 minAmountOut
    ) external returns (uint256);

    /// @notice The function that performs an actual Uniswap swap (swapTokensForExactTokens),
    /// taking not more than maxAmountIn inToken tokens from the msg.sender and sending amountOut outTokens back.
    /// The approval of maxAmountIn tokens has to be made to this address beforehand
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountOut the amount of outToken tokens to be received
    /// @param optionalPath the optional path that will be considered by the pathfinder to find the best route
    /// @param maxAmountIn the maximal amount of inTokens that have to be taken to execute the swap.
    /// basically this is a sandwich attack protection mechanism
    /// @return the amount of inTokens taken from the msg.sender
    function exchangeToExact(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] calldata optionalPath,
        uint256 maxAmountIn
    ) external returns (uint256);

    /// @notice The same as "exchangeFromExact" except that the amount of inTokens and received amount of outTokens is normalized
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountIn the amount of inTokens to be exchanged (in 18 decimals)
    /// @param optionalPath the optional path that will be considered by the pathfinder
    /// @param minAmountOut the minimal amount of outTokens to be received (also normalized)
    /// @return normalized amount of outTokens sent to the msg.sender after the swap
    function normalizedExchangeFromExact(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] calldata optionalPath,
        uint256 minAmountOut
    ) external returns (uint256);

    /// @notice The same as "exchangeToExact" except that the amount of inTokens and received amount of outTokens is normalized
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountOut the amount of outTokens to be received (in 18 decimals)
    /// @param optionalPath the optional path that will be considered by the pathfinder
    /// @param maxAmountIn the maximal amount of inTokens to be taken (also normalized)
    /// @return normalized amount of inTokens taken from the msg.sender to execute the swap
    function normalizedExchangeToExact(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] calldata optionalPath,
        uint256 maxAmountIn
    ) external returns (uint256);

    /// @notice The function that returns the total number of path tokens (tokens used in the pathfinder)
    /// @return the number of path tokens
    function totalPathTokens() external view returns (uint256);

    /// @notice The function to get the list of path tokens
    /// @return the list of path tokens
    function getPathTokens() external view returns (address[] memory);

    /// @notice The function to get the list of saved tokens of the pool
    /// @param pool the address the path is saved for
    /// @param from the from token (path beginning)
    /// @param to the to token (path ending)
    /// @return the array of addresses representing the inclusive path between tokens
    function getSavedPaths(
        address pool,
        address from,
        address to
    ) external view returns (address[] memory);

    /// @notice This function checks if the provided token is used by the pathfinder
    /// @param token the token to be checked
    /// @return true if the token is used by the pathfinder, false otherwise
    function isSupportedPathToken(address token) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 *  @notice The ContractsRegistry module
 *
 *  This is a contract that must be used as dependencies accepter in the dependency injection mechanism.
 *  Upon the injection, the Injector (ContractsRegistry most of the time) will call the `setDependencies()` function.
 *  The dependant contract will have to pull the required addresses from the supplied ContractsRegistry as a parameter.
 *
 *  The AbstractDependant is fully compatible with proxies courtesy of custom storage slot.
 */
abstract contract AbstractDependant {
    /**
     *  @notice The slot where the dependency injector is located.
     *  @dev keccak256(AbstractDependant.setInjector(address)) - 1
     *
     *  Only the injector is allowed to inject dependencies.
     *  The first to call the setDependencies() (with the modifier applied) function becomes an injector
     */
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier dependant() {
        _checkInjector();
        _;
        _setInjector(msg.sender);
    }

    /**
     *  @notice The function that will be called from the ContractsRegistry (or factory) to inject dependencies.
     *  @param contractsRegistry the registry to pull dependencies from
     *
     *  The Dependant must apply dependant() modifier to this function
     */
    function setDependencies(address contractsRegistry) external virtual;

    /**
     *  @notice The function is made external to allow for the factories to set the injector to the ContractsRegistry
     *  @param _injector the new injector
     */
    function setInjector(address _injector) external {
        _checkInjector();
        _setInjector(_injector);
    }

    /**
     *  @notice The function to get the current injector
     *  @return _injector the current injector
     */
    function getInjector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }

    /**
     *  @notice Internal function that checks the injector credentials
     */
    function _checkInjector() internal view {
        address _injector = getInjector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
    }

    /**
     *  @notice Internal function that sets the injector
     */
    function _setInjector(address _injector) internal {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../libs/arrays/Paginator.sol";

import "../contracts-registry/AbstractDependant.sol";

import "./ProxyBeacon.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  This contract can be used as a pool registry that keeps track of deployed pools by the system.
 *  One can integrate factories to deploy and register pools or add them manually
 *
 *  The registry uses BeaconProxy pattern to provide upgradeability and Dependant pattern to provide dependency
 *  injection mechanism into the pools. This module should be used together with the ContractsRegistry module.
 *
 *  The users of this module have to override `_onlyPoolFactory()` method and revert in case a wrong msg.sender is
 *  trying to add pools into the registry.
 *
 *  The contract is ment to be used behind a proxy itself.
 */
abstract contract AbstractPoolContractsRegistry is OwnableUpgradeable, AbstractDependant {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Paginator for EnumerableSet.AddressSet;
    using Math for uint256;

    address internal _contractsRegistry;

    mapping(string => ProxyBeacon) private _beacons;
    mapping(string => EnumerableSet.AddressSet) internal _pools; // name => pool

    modifier onlyPoolFactory() {
        _onlyPoolFactory();
        _;
    }

    /**
     *  @notice The function that acts as an access limiter, has to be overriden
     */
    function _onlyPoolFactory() internal view virtual;

    /**
     *  @notice The proxy initializer function
     */
    function __PoolContractsRegistry_init() external initializer {
        __Ownable_init();
    }

    /**
     *  @notice The function that accepts dependencies from the ContractsRegistry, can be overriden
     *  @param contractsRegistry the dependency registry
     */
    function setDependencies(address contractsRegistry) public virtual override dependant {
        _contractsRegistry = contractsRegistry;
    }

    /**
     *  @notice The function that sets pools' implementations. Deploys ProxyBeacons on the first set.
     *  This function is also used to upgrade pools
     *  @param names the names that are associated with the pools implementations
     *  @param newImplementations the new implementations of the pools (ProxyBeacons will point to these)
     */
    function setNewImplementations(string[] calldata names, address[] calldata newImplementations)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < names.length; i++) {
            if (address(_beacons[names[i]]) == address(0)) {
                _beacons[names[i]] = new ProxyBeacon();
            }

            if (_beacons[names[i]].implementation() != newImplementations[i]) {
                _beacons[names[i]].upgrade(newImplementations[i]);
            }
        }
    }

    /**
     *  @notice The paginated function that injects new dependencies to the pools. Can be used when the dependant contract
     *  gets fully replaced to update the pools' dependencies
     *  @param name the pools name that will be injected
     *  @param offset the starting index in the pools array
     *  @param limit the number of pools
     */
    function injectDependenciesToExistingPools(
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external onlyOwner {
        EnumerableSet.AddressSet storage pools = _pools[name];

        uint256 to = (offset + limit).min(pools.length()).max(offset);

        require(to != offset, "PoolContractsRegistry: No pools to inject");

        address contractsRegistry = _contractsRegistry;

        for (uint256 i = offset; i < to; i++) {
            AbstractDependant(pools.at(i)).setDependencies(contractsRegistry);
        }
    }

    /**
     *  @notice The function to get implementation of the specific pools
     *  @param name the name of the pools
     *  @return address the implementation these pools point to
     */
    function getImplementation(string calldata name) external view returns (address) {
        require(
            address(_beacons[name]) != address(0),
            "PoolContractsRegistry: This mapping doesn't exist"
        );

        return _beacons[name].implementation();
    }

    /**
     *  @notice The function to get the BeaconProxy of the specific pools (mostly needed in the factories)
     *  @param name the name of the pools
     *  @return address the BeaconProxy address
     */
    function getProxyBeacon(string calldata name) external view returns (address) {
        require(address(_beacons[name]) != address(0), "PoolContractsRegistry: Bad ProxyBeacon");

        return address(_beacons[name]);
    }

    /**
     *  @notice The function to add new pools into the registry
     *  @param name the pool's associated name
     *  @param poolAddress the proxy address of the pool
     */
    function addPool(string calldata name, address poolAddress) external onlyPoolFactory {
        _pools[name].add(poolAddress);
    }

    /**
     *  @notice The function to count pools by specified name
     *  @param name the associated pools name
     *  @return the number of pools with this name
     */
    function countPools(string calldata name) external view returns (uint256) {
        return _pools[name].length();
    }

    /**
     *  @notice The paginated function to list pools by their name (call `countPools()` to account for pagination)
     *  @param name the associated pools name
     *  @param offset the starting index in the pools array
     *  @param limit the number of pools
     *  @return pools the array of pools proxies
     */
    function listPools(
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory pools) {
        return _pools[name].part(offset, limit);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  The helper BeaconProxy that get deployed by the PoolFactory. Note that the external
 *  `implementation()` function is added to the contract to provide compatability with the
 *  Etherscan. This means that the implementation must not have such a function declared.
 */
contract PublicBeaconProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) payable BeaconProxy(beacon, data) {}

    /**
     *  @notice The function that returns implementation contract this proxy points to
     *  @return address the implementation address
     */
    function implementation() external view virtual returns (address) {
        return _implementation();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 *  @notice Library for pagination.
 *
 *  Supports the following data types `uin256[]`, `address[]`, `bytes32[]`, `UintSet`,
 * `AddressSet`, `BytesSet`.
 *
 */
library Paginator {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /**
     * @notice Returns part of an array.
     * @dev All functions below have the same description.
     *
     * Examples:
     * - part([4, 5, 6, 7], 0, 4) will return [4, 5, 6, 7]
     * - part([4, 5, 6, 7], 2, 4) will return [6, 7]
     * - part([4, 5, 6, 7], 2, 1) will return [6]
     *
     * @param arr Storage array.
     * @param offset Offset, index in an array.
     * @param limit Number of elements after the `offset`.
     */
    function part(
        uint256[] storage arr,
        uint256 offset,
        uint256 limit
    ) internal view returns (uint256[] memory list) {
        uint256 to = _handleIncomingParametersForPart(arr.length, offset, limit);

        list = new uint256[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = arr[i];
        }
    }

    function part(
        address[] storage arr,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory list) {
        uint256 to = _handleIncomingParametersForPart(arr.length, offset, limit);

        list = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = arr[i];
        }
    }

    function part(
        bytes32[] storage arr,
        uint256 offset,
        uint256 limit
    ) internal view returns (bytes32[] memory list) {
        uint256 to = _handleIncomingParametersForPart(arr.length, offset, limit);

        list = new bytes32[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = arr[i];
        }
    }

    function part(
        EnumerableSet.UintSet storage set,
        uint256 offset,
        uint256 limit
    ) internal view returns (uint256[] memory list) {
        uint256 to = _handleIncomingParametersForPart(set.length(), offset, limit);

        list = new uint256[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = set.at(i);
        }
    }

    function part(
        EnumerableSet.AddressSet storage set,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory list) {
        uint256 to = _handleIncomingParametersForPart(set.length(), offset, limit);

        list = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = set.at(i);
        }
    }

    function part(
        EnumerableSet.Bytes32Set storage set,
        uint256 offset,
        uint256 limit
    ) internal view returns (bytes32[] memory list) {
        uint256 to = _handleIncomingParametersForPart(set.length(), offset, limit);

        list = new bytes32[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = set.at(i);
        }
    }

    function _handleIncomingParametersForPart(
        uint256 length,
        uint256 offset,
        uint256 limit
    ) private pure returns (uint256 to) {
        to = offset + limit;

        if (to > length) to = length;
        if (offset > to) to = offset;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  This is a utility lightweighted ProxyBeacon contract this is used as a beacon that BeaconProxies point to.
 */
contract ProxyBeacon is IBeacon {
    using Address for address;

    address private immutable _owner;
    address private _implementation;

    event Upgraded(address indexed implementation);

    modifier onlyOwner() {
        require(_owner == msg.sender, "ProxyBeacon: Not an owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function implementation() external view override returns (address) {
        return _implementation;
    }

    function upgrade(address newImplementation) external onlyOwner {
        require(newImplementation.isContract(), "ProxyBeacon: Not a contract");

        _implementation = newImplementation;

        emit Upgraded(newImplementation);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the Governance pool contract. This contract is the third contract the user can deploy through
 * the factory. The users can participate in proposal's creation, voting and execution processes
 */
interface IGovPool {
    /// @notice Execute proposal
    /// @param proposalId Proposal ID
    function execute(uint256 proposalId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/gov/IGovFee.sol";

import "./GovVote.sol";

abstract contract GovFee is IGovFee, OwnableUpgradeable, GovVote {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using Math for uint64;
    using MathHelper for uint256;

    uint64 private _deployedAt;

    uint256 public feePercentage;

    /// @dev zero address - native token
    mapping(address => uint64) public lastUpdate; // token address => last update

    event FeeWithdrawn(address token, uint256 amount, uint256 fee);

    function __GovFee_init(
        address govSettingAddress,
        address govUserKeeperAddress,
        address validatorsAddress,
        uint256 _votesLimit,
        uint256 _feePercentage
    ) internal {
        __GovVote_init(govSettingAddress, govUserKeeperAddress, validatorsAddress, _votesLimit);
        __Ownable_init();

        require(
            _feePercentage <= PERCENTAGE_100,
            "GovFee: `_feePercentage` can't be more than 100%"
        );

        _deployedAt = uint64(block.timestamp);
        feePercentage = _feePercentage;
    }

    function withdrawFee(address tokenAddress, address recipient) external override onlyOwner {
        uint64 _lastUpdate = uint64(lastUpdate[tokenAddress].max(_deployedAt));

        lastUpdate[tokenAddress] = uint64(block.timestamp);

        uint256 balance;
        uint256 toWithdraw;

        if (tokenAddress != address(0)) {
            balance = IERC20(tokenAddress).balanceOf(address(this));
        } else {
            balance = address(this).balance;
        }

        uint256 fee = feePercentage.ratio(block.timestamp - _lastUpdate, 1 days * 365);
        toWithdraw = balance.min(balance.percentage(fee));

        require(toWithdraw > 0, "GFee: nothing to withdraw");

        if (tokenAddress != address(0)) {
            IERC20(tokenAddress).safeTransfer(recipient, toWithdraw);
        } else {
            payable(recipient).transfer(toWithdraw);
        }

        emit FeeWithdrawn(tokenAddress, toWithdraw, fee);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This contract is responsible for the owner's fee collection (part of the pool)
 */
interface IGovFee {
    /// @notice Withdraw fee
    /// @param tokenAddress ERC20 token address or zero address for native withdraw
    /// @param recipient Tokens recipient
    function withdrawFee(address tokenAddress, address recipient) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/gov/validators/IGovValidators.sol";
import "../interfaces/gov/IGovVote.sol";

import "../libs/MathHelper.sol";
import "../libs/ShrinkableArray.sol";

import "./GovCreator.sol";

import "../core/Globals.sol";

abstract contract GovVote is IGovVote, GovCreator {
    using Math for uint256;
    using MathHelper for uint256;
    using ShrinkableArray for ShrinkableArray.UintArray;
    using ShrinkableArray for uint256[];
    using EnumerableSet for EnumerableSet.UintSet;

    /// @dev `Validators` contract address
    IGovValidators public validators;

    uint256 public votesLimit;

    mapping(uint256 => uint256) private _totalVotedInProposal; // proposalId => total voted
    mapping(uint256 => mapping(address => VoteInfo)) private _voteInfos; // proposalId => voter => info

    mapping(address => EnumerableSet.UintSet) private _votedInProposals; // voter => active proposal ids

    function __GovVote_init(
        address govSettingAddress,
        address govUserKeeperAddress,
        address validatorsAddress,
        uint256 _votesLimit
    ) internal {
        __GovCreator_init(govSettingAddress, govUserKeeperAddress);

        require(_votesLimit > 0);

        validators = IGovValidators(validatorsAddress);
        votesLimit = _votesLimit;
    }

    function voteTokens(uint256 proposalId, uint256 amount) external override {
        _voteTokens(proposalId, amount, msg.sender);
    }

    function voteDelegatedTokens(
        uint256 proposalId,
        uint256 amount,
        address holder
    ) external override {
        _voteTokens(
            proposalId,
            amount.min(govUserKeeper.delegatedTokens(holder, msg.sender)),
            holder
        );
    }

    function voteNfts(uint256 proposalId, uint256[] calldata nftIds) external override {
        _voteNfts(proposalId, nftIds.transform(), msg.sender);
    }

    function voteDelegatedNfts(
        uint256 proposalId,
        uint256[] calldata nftIds,
        address holder
    ) external override {
        ShrinkableArray.UintArray memory nftIdsFiltered = govUserKeeper
            .filterNftsAvailableForDelegator(msg.sender, holder, nftIds.transform());

        require(nftIdsFiltered.length > 0, "GovV: nfts is not found");

        _voteNfts(proposalId, nftIdsFiltered, holder);
    }

    function unlock(address user) external override {
        unlockInProposals(_votedInProposals[user].values(), user);
    }

    function unlockInProposals(uint256[] memory proposalIds, address user) public override {
        IGovUserKeeper userKeeper = govUserKeeper;

        for (uint256 i; i < proposalIds.length; i++) {
            _beforeUnlock(proposalIds[i]);

            userKeeper.unlockTokens(user, proposalIds[i]);
            userKeeper.unlockNfts(user, _voteInfos[proposalIds[i]][user].nftsVoted.values());

            _votedInProposals[user].remove(proposalIds[i]);
        }
    }

    function unlockNfts(
        uint256 proposalId,
        address user,
        uint256[] calldata nftIds
    ) external override {
        _beforeUnlock(proposalId);

        for (uint256 i; i < nftIds.length; i++) {
            require(
                _voteInfos[proposalId][user].nftsVoted.contains(nftIds[i]),
                "GovV: NFT is not voting"
            );
        }

        govUserKeeper.unlockNfts(user, nftIds);
    }

    function moveProposalToValidators(uint256 proposalId) external override {
        ProposalCore storage core = proposals[proposalId].core;
        ProposalState state = _getProposalState(core);

        require(state == ProposalState.WaitingForVotingTransfer, "GovV: can't be moved");

        validators.createExternalProposal(
            proposalId,
            core.settings.durationValidators,
            core.settings.quorumValidators
        );
    }

    function getTotalVotes(uint256 proposalId, address voter)
        external
        view
        override
        returns (uint256, uint256)
    {
        return (_totalVotedInProposal[proposalId], _voteInfos[proposalId][voter].totalVoted);
    }

    function getVoteInfo(uint256 proposalId, address voter)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256[] memory
        )
    {
        return (
            _totalVotedInProposal[proposalId],
            _voteInfos[proposalId][voter].totalVoted,
            _voteInfos[proposalId][voter].tokensVoted,
            _voteInfos[proposalId][voter].nftsVoted.values()
        );
    }

    function getProposalState(uint256 proposalId) external view override returns (ProposalState) {
        return _getProposalState(proposals[proposalId].core);
    }

    function _getProposalState(ProposalCore storage core) internal view returns (ProposalState) {
        uint64 voteEnd = core.voteEnd;

        if (voteEnd == 0) {
            return ProposalState.Undefined;
        }

        if (core.executed) {
            return ProposalState.Executed;
        }

        if (core.settings.earlyCompletion || voteEnd < block.timestamp) {
            if (_quorumReached(core)) {
                if (address(validators) != address(0)) {
                    IGovValidators.ProposalState status = validators.getProposalState(
                        core.proposalId,
                        false
                    );

                    if (status == IGovValidators.ProposalState.Undefined) {
                        return ProposalState.WaitingForVotingTransfer;
                    }

                    if (status == IGovValidators.ProposalState.Voting) {
                        return ProposalState.ValidatorVoting;
                    }

                    if (status == IGovValidators.ProposalState.Succeeded) {
                        return ProposalState.Succeeded;
                    }

                    if (status == IGovValidators.ProposalState.Defeated) {
                        return ProposalState.Defeated;
                    }
                } else {
                    return ProposalState.Succeeded;
                }
            }

            if (voteEnd < block.timestamp) {
                return ProposalState.Defeated;
            }
        }

        return ProposalState.Voting;
    }

    function _quorumReached(ProposalCore storage core) private view returns (bool) {
        uint256 totalVoteWeight = govUserKeeper.getTotalVoteWeight();

        return
            totalVoteWeight == 0
                ? false
                : PERCENTAGE_100.ratio(core.votesFor, totalVoteWeight) >= core.settings.quorum;
    }

    function _voteTokens(
        uint256 proposalId,
        uint256 amount,
        address voter
    ) private {
        ProposalCore storage core = _beforeVote(proposalId, voter);
        IGovUserKeeper userKeeper = govUserKeeper;

        uint256 tokenBalance = userKeeper.tokenBalance(voter);

        uint256 voted = _voteInfos[proposalId][voter].tokensVoted;
        uint256 voteAmount = amount.min(tokenBalance - voted);

        require(voteAmount > 0, "GovV: vote amount is zero");

        userKeeper.lockTokens(voter, voteAmount, proposalId);

        _totalVotedInProposal[proposalId] += voteAmount;
        _voteInfos[proposalId][voter].totalVoted += voteAmount;
        _voteInfos[proposalId][voter].tokensVoted = voted + voteAmount;

        core.votesFor += voteAmount;
    }

    function _voteNfts(
        uint256 proposalId,
        ShrinkableArray.UintArray memory nftIds,
        address voter
    ) private {
        ProposalCore storage core = _beforeVote(proposalId, voter);

        ShrinkableArray.UintArray memory _nftsToVote = ShrinkableArray.create(nftIds.length);
        uint256 length;

        for (uint256 i; i < nftIds.length; i++) {
            if (_voteInfos[proposalId][voter].nftsVoted.contains(nftIds.values[i])) {
                continue;
            }

            require(i == 0 || nftIds.values[i] > nftIds.values[i - 1], "GovV: wrong NFT order");

            _nftsToVote.values[length++] = nftIds.values[i];
        }

        IGovUserKeeper userKeeper = govUserKeeper;

        _nftsToVote = userKeeper.lockNfts(voter, _nftsToVote.crop(length));
        uint256 voteAmount = userKeeper.getNftsPowerInTokens(_nftsToVote, core.nftPowerSnapshotId);

        require(voteAmount > 0, "GovV: vote amount is zero");

        for (uint256 i; i < _nftsToVote.length; i++) {
            _voteInfos[proposalId][voter].nftsVoted.add(_nftsToVote.values[i]);
        }

        _totalVotedInProposal[proposalId] += voteAmount;
        _voteInfos[proposalId][voter].totalVoted += voteAmount;

        core.votesFor += voteAmount;
    }

    function _beforeVote(uint256 proposalId, address voter)
        private
        returns (ProposalCore storage)
    {
        _votedInProposals[voter].add(proposalId);
        ProposalCore storage core = proposals[proposalId].core;

        require(_votedInProposals[voter].length() <= votesLimit, "GovV: vote limit reached");
        require(_getProposalState(core) == ProposalState.Voting, "GovV: vote unavailable");
        require(
            govUserKeeper.canUserParticipate(
                voter,
                core.settings.minTokenBalance,
                core.settings.minNftBalance
            ),
            "GovV: low balance"
        );

        return core;
    }

    function _beforeUnlock(uint256 proposalId) private view {
        ProposalState state = _getProposalState(proposals[proposalId].core);

        require(
            state == ProposalState.Succeeded || state == ProposalState.Defeated,
            "GovV: invalid proposal status"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the voting contract that is queried on the proposal's second voting stage
 */
interface IGovValidators {
    enum ProposalState {
        Voting,
        Defeated,
        Succeeded,
        Executed,
        Undefined
    }

    enum ProposalType {
        ChangeInternalDuration,
        ChangeInternalQuorum,
        ChangeInternalDurationAndQuorum,
        ChangeBalances
    }

    struct InternalProposalSettings {
        uint64 duration;
        uint128 quorum;
    }

    struct ProposalCore {
        bool executed;
        uint64 voteEnd;
        uint128 quorum;
        uint256 votesFor;
        uint256 snapshotId;
    }

    struct InternalProposal {
        ProposalType proposalType;
        ProposalCore core;
        uint256[] newValues;
        address[] userAddresses;
    }

    struct ExternalProposal {
        ProposalCore core;
    }

    /// @notice Create internal proposal for changing validators balances, base quorum, base duration
    /// @param proposalType `ProposalType`
    /// 0 - `ChangeInternalDuration`, change base duration
    /// 1 - `ChangeInternalQuorum`, change base quorum
    /// 2 - `ChangeInternalDurationAndQuorum`, change base duration and quorum
    /// 3 - `ChangeBalances`, change address balance
    /// @param newValues New values (tokens amounts array, quorum or duration or both)
    /// @param userAddresses Validators addresses, set it if `proposalType` == `ChangeBalances`
    function createInternalProposal(
        ProposalType proposalType,
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external;

    /// @notice Create external proposal. This function can call only `Gov` contract
    /// @param proposalId Proposal ID from `Gov` contract
    /// @param duration Duration from `Gov` contract
    /// @param quorum Quorum from `Gov` contract
    function createExternalProposal(
        uint256 proposalId,
        uint64 duration,
        uint128 quorum
    ) external;

    /// @notice Vote in proposal
    /// @param proposalId Proposal ID, internal or external
    /// @param amount Amount of tokens to vote
    /// @param isInternal If `true`, you will vote in internal proposal
    function vote(
        uint256 proposalId,
        uint256 amount,
        bool isInternal
    ) external;

    /// @notice Only for internal proposals. External proposals should be executed from governance.
    /// @param proposalId Internal proposal ID
    function execute(uint256 proposalId) external;

    /// @notice Return proposal state
    /// @dev Options:
    /// `Voting` - proposal where addresses can vote.
    /// `Defeated` - proposal where voting time is over and proposal defeated.
    /// `Succeeded` - proposal with the required number of votes.
    /// `Executed` - executed proposal (only for internal proposal).
    /// `Undefined` - nonexistent proposal.
    function getProposalState(uint256 proposalId, bool isInternal)
        external
        view
        returns (ProposalState);

    /// @param proposalId Proposal ID
    /// @param isInternal If `true`, check internal proposal
    /// @return `true` if quorum reached. Return `false` if not or proposal isn't exist.
    function isQuorumReached(uint256 proposalId, bool isInternal) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * This is the contract that is responsible for the first stage governance voting process (part of the pool)
 */
interface IGovVote {
    enum ProposalState {
        Voting,
        WaitingForVotingTransfer,
        ValidatorVoting,
        Defeated,
        Succeeded,
        Executed,
        Undefined
    }

    struct VoteInfo {
        uint256 totalVoted;
        uint256 tokensVoted;
        EnumerableSet.UintSet nftsVoted;
    }

    /// @notice Token voting
    /// @param proposalId Proposal ID
    /// @param amount Token amount. Wei
    function voteTokens(uint256 proposalId, uint256 amount) external;

    /// @notice Delegate token voting
    /// @param proposalId Proposal ID
    /// @param amount Token amount. Wei
    /// @param holder Token holder
    function voteDelegatedTokens(
        uint256 proposalId,
        uint256 amount,
        address holder
    ) external;

    /// @notice NFTs voting
    /// @param proposalId Proposal ID
    /// @param nftIds NFTs that the user votes with
    function voteNfts(uint256 proposalId, uint256[] calldata nftIds) external;

    /// @notice NFTs voting
    /// @param proposalId Proposal ID
    /// @param nftIds NFTs that the user votes with
    /// @param holder NFTs holder
    function voteDelegatedNfts(
        uint256 proposalId,
        uint256[] calldata nftIds,
        address holder
    ) external;

    /// @notice Unlock tokens and NFTs in all ended proposals.
    /// @param user Voter address
    function unlock(address user) external;

    /// @notice Unlock tokens and NFTs in selected ended proposals.
    /// @param proposalIds Proposal IDs
    /// @param user Voter address
    function unlockInProposals(uint256[] memory proposalIds, address user) external;

    /// @notice Unlock NFTs in ended proposals
    /// @param proposalId Proposal ID
    /// @param user Voter address
    /// @param nftIds NFTs to unlock
    function unlockNfts(
        uint256 proposalId,
        address user,
        uint256[] calldata nftIds
    ) external;

    /// @notice Move proposal from internal voting to `Validators` contract
    /// @param proposalId Proposal ID
    function moveProposalToValidators(uint256 proposalId) external;

    /// @notice The function to get voter's general vote info
    /// @param proposalId Proposal ID
    /// @param voter Voter address
    /// @return Total voted amount in proposal, total voted amount by the voter
    function getTotalVotes(uint256 proposalId, address voter)
        external
        view
        returns (uint256, uint256);

    /// @notice The function to get voter's vote info with tokens and NFT information
    /// @param proposalId Proposal ID
    /// @param voter Voter address
    /// @return Total voted amount in proposal, total voted amount by address, voted tokens amount, voted NFTs
    function getVoteInfo(uint256 proposalId, address voter)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256[] memory
        );

    /// @param proposalId Proposal ID
    /// @return `ProposalState`:
    /// 0 -`Voting`, proposal where addresses can vote
    /// 1 -`WaitingForVotingTransfer`, approved proposal that waiting `moveProposalToValidators()` call
    /// 2 -`ValidatorVoting`, validators voting
    /// 3 -`Defeated`, proposal where voting time is over and proposal defeated on first or second step
    /// 4 -`Succeeded`, proposal with the required number of votes on each step
    /// 5 -`Executed`, executed proposal
    /// 6 -`Undefined`, nonexistent proposal
    function getProposalState(uint256 proposalId) external view returns (ProposalState);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../core/Globals.sol";

library MathHelper {
    /// @notice percent has to be multiplied by PRECISION
    function percentage(uint256 num, uint256 percent) internal pure returns (uint256) {
        return (num * percent) / PERCENTAGE_100;
    }

    function ratio(
        uint256 base,
        uint256 num,
        uint256 denom
    ) internal pure returns (uint256) {
        return (base * num) / denom;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library ShrinkableArray {
    struct UintArray {
        uint256[] values;
        uint256 length;
    }

    /**
     * @dev Create `ShrinkableArray` from `uint256[]`, save original array and length
     */
    function transform(uint256[] memory arr) internal pure returns (UintArray memory) {
        return UintArray(arr, arr.length);
    }

    /**
     * @dev Create blank `ShrinkableArray` - empty array with original length
     */
    function create(uint256 length) internal pure returns (UintArray memory) {
        return UintArray(new uint256[](length), length);
    }

    /**
     * @dev Change array length
     */
    function crop(UintArray memory arr, uint256 newLength)
        internal
        pure
        returns (UintArray memory)
    {
        arr.length = newLength;

        return arr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../interfaces/gov/settings/IGovSettings.sol";
import "../interfaces/gov/IGovUserKeeper.sol";
import "../interfaces/gov/IGovCreator.sol";

abstract contract GovCreator is IGovCreator {
    IGovSettings public govSetting;
    IGovUserKeeper public govUserKeeper;

    uint256 private _latestProposalId;

    mapping(uint256 => Proposal) public proposals; // proposalId => info

    event ProposalCreated(uint256 id);

    function __GovCreator_init(address govSettingAddress, address govUserKeeperAddress) internal {
        require(govSettingAddress != address(0), "GovC: address is zero (1)");
        require(govUserKeeperAddress != address(0), "GovC: address is zero (2)");

        govSetting = IGovSettings(govSettingAddress);
        govUserKeeper = IGovUserKeeper(govUserKeeperAddress);
    }

    function createProposal(
        string calldata descriptionURL,
        address[] memory executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) external override {
        require(
            executors.length > 0 &&
                executors.length == values.length &&
                executors.length == data.length,
            "GovC: invalid array length"
        );
        require(govUserKeeper.canUserParticipate(msg.sender, 1, 1), "GovC: low balance");

        uint256 proposalId = ++_latestProposalId;

        address mainExecutor = executors[executors.length - 1];
        (, bool isInternal, bool trustedExecutor) = govSetting.executorInfo(mainExecutor);

        bool forceDefaultSettings;
        IGovSettings.ProposalSettings memory settings;

        if (isInternal) {
            executors = _handleExecutorsAndDataForInternalProposal(executors, values, data);
        } else if (trustedExecutor) {
            forceDefaultSettings = _handleDataForExistingSettingsProposal(values, data);
        }

        if (forceDefaultSettings) {
            settings = govSetting.getDefaultSettings();
        } else {
            settings = govSetting.getSettings(mainExecutor);
        }

        proposals[proposalId] = Proposal({
            core: ProposalCore({
                settings: settings,
                executed: false,
                voteEnd: uint64(block.timestamp + settings.duration),
                votesFor: 0,
                nftPowerSnapshotId: govUserKeeper.createNftPowerSnapshot(),
                proposalId: proposalId
            }),
            descriptionURL: descriptionURL,
            executors: executors,
            values: values,
            data: data
        });

        emit ProposalCreated(proposalId);
    }

    function getProposalInfo(uint256 proposalId)
        external
        view
        override
        returns (address[] memory, bytes[] memory)
    {
        return (proposals[proposalId].executors, proposals[proposalId].data);
    }

    function _handleExecutorsAndDataForInternalProposal(
        address[] memory executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) private pure returns (address[] memory) {
        address mainExecutor = executors[executors.length - 1];

        for (uint256 i; i < data.length; i++) {
            bytes4 selector = _getSelector(data[i]);
            require(
                values[i] == 0 &&
                    (selector == IGovSettings.addSettings.selector ||
                        selector == IGovSettings.editSettings.selector ||
                        selector == IGovSettings.changeExecutors.selector),
                "GovC: invalid internal data"
            );

            executors[i] = mainExecutor;
        }

        return executors;
    }

    function _handleDataForExistingSettingsProposal(
        uint256[] calldata values,
        bytes[] calldata data
    ) private pure returns (bool) {
        for (uint256 i; i < data.length - 1; i++) {
            bytes4 selector = _getSelector(data[i]);

            if (
                values[i] != 0 ||
                (selector != IERC20.approve.selector &&
                    selector != IERC721.approve.selector &&
                    selector != IERC721.setApprovalForAll.selector &&
                    selector != IERC1155.setApprovalForAll.selector)
            ) {
                return true; // should use default settings
            }
        }

        return false;
    }

    function _getSelector(bytes calldata data) private pure returns (bytes4 selector) {
        assembly {
            selector := calldataload(data.offset)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../libs/ShrinkableArray.sol";

/**
 * This contract is responsible for securely storing user's funds that are used during the voting. This are either
 * ERC20 tokens or NFTs
 */
interface IGovUserKeeper {
    struct NFTInfo {
        bool isSupportPower;
        bool isSupportTotalSupply;
        uint256 totalPowerInTokens;
        uint256 totalSupply;
    }

    struct NFTSnapshot {
        uint256 totalSupply;
        uint256 totalNftsPower;
        mapping(uint256 => uint256) nftPower;
    }

    /// @notice The function to get the token balance of the user
    /// @param user the user to get the balance of
    /// @return the balance
    function tokenBalance(address user) external view returns (uint256);

    /// @notice The function to get the delegated amounts
    /// @param holder the delegator
    /// @param spender the delegatee
    /// @return the delegated amount
    function delegatedTokens(address holder, address spender) external view returns (uint256);

    /// @notice Add tokens to the `holder` balance
    /// @param holder Holder
    /// @param amount Token amount. Wei
    function depositTokens(address holder, uint256 amount) external;

    /// @notice Delegate (approve) tokens from `msg.sender` to `spender`
    /// @param spender Spender
    /// @param amount Token amount. Wei
    function delegateTokens(address spender, uint256 amount) external;

    /// @notice Withdraw tokens from balance
    /// @param amount Token amount. Wei
    function withdrawTokens(uint256 amount) external;

    /// @notice Add NFTs to the `holder` balance
    /// @param holder Holder
    /// @param nftIds NFTs. Array [1, 34, ...]
    function depositNfts(address holder, uint256[] calldata nftIds) external;

    /// @notice Delegate (approve) NFTs from `msg.sender` to `spender`
    /// @param spender Spender
    /// @param nftIds NFTs. Array [1, 34, ...]
    /// @param delegationStatus. Array [true, false, ...]. If `true`, delegate nft to `spender`
    function delegateNfts(
        address spender,
        uint256[] calldata nftIds,
        bool[] calldata delegationStatus
    ) external;

    /// @notice Withdraw NFTs from balance
    /// @param nftIds NFT Ids
    function withdrawNfts(uint256[] calldata nftIds) external;

    /// @return bool `true` if NFT contract support `Power` interface
    /// @return bool `true` if NFT contract support `Enumerable` interface
    /// @return uint256 Total power of all NFTs in tokens
    /// @return uint256 Total supply if NFT contract isn't support `Power` and `Enumerable` interface
    function getNftContractInfo()
        external
        view
        returns (
            bool,
            bool,
            uint256,
            uint256
        );

    /// @param user Holder address
    /// @return uint256 Actual token balance. Wei
    /// @return uint256 Actual locked amount. Wei
    function tokenBalanceOf(address user) external view returns (uint256, uint256);

    /// @param user Holder address
    /// @return uint256 Actual NFTs count on balance
    /// @return uint256 Actual locked NFTs count on balance
    function nftBalanceCountOf(address user) external view returns (uint256, uint256);

    function delegatedNftsCountOf(address holder, address spender) external view returns (uint256);

    /// @param user Holder address
    /// @param offset Index in array
    /// @param limit NFTs limit
    /// @return uint256[] NFTs on balance
    function nftBalanceOf(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory);

    /// @param user Holder address
    /// @param offset Index in array
    /// @param limit NFTs limit
    /// @return uint256[] Locked NFTs
    /// @return uint256[] Locked num for each locked NFT
    function nftLockedBalanceOf(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, uint256[] memory);

    /// @param holder Main token holder address
    /// @param spender Spender address
    /// @param offset Index in array
    /// @param limit NFTs limit
    /// @return Delegated NFTs. Array
    function getDelegatedNfts(
        address holder,
        address spender,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory);

    /// @return uint256 Total vote amount for each proposal
    /// @dev Participates in the quorum calculation
    function getTotalVoteWeight() external view returns (uint256);

    /// @notice Calculate certain NFTs power by `snapshotId`
    /// @param nftIds NFT IDs
    /// @param snapshotId Snapshot ID
    /// @return uint256 Nft power in tokens
    function getNftsPowerInTokens(ShrinkableArray.UintArray calldata nftIds, uint256 snapshotId)
        external
        view
        returns (uint256);

    /// @param delegate Spender address
    /// @param holder Main token holder address
    /// @param nftIds Array of NFTs that should be filtered
    /// @return Return filtered input array, where only delegated NFTs
    function filterNftsAvailableForDelegator(
        address delegate,
        address holder,
        ShrinkableArray.UintArray calldata nftIds
    ) external view returns (ShrinkableArray.UintArray memory);

    /// @notice Create NFTs power snapshot
    /// @return Return NFTs power snapshot ID
    function createNftPowerSnapshot() external returns (uint256);

    /// @notice Lock tokens. Locked tokens unavailable to transfer from contract
    /// @param voter Voter address
    /// @param amount Token amount. Wei
    function lockTokens(
        address voter,
        uint256 amount,
        uint256 proposalId
    ) external;

    /// @notice Unlock tokens
    /// @param voter Holder address
    /// @param proposalId Proposal ID
    function unlockTokens(address voter, uint256 proposalId) external;

    /// @notice Filters incoming NFTs (`nftIds`) by existing on balance and locks them
    /// @param voter NFT owner address. If NFT is not on contract or owner is other address, skip it
    /// @param nftIds List of NFT ids to lock.
    /// @return uint256[] Array with locked nftIds
    function lockNfts(address voter, ShrinkableArray.UintArray calldata nftIds)
        external
        returns (ShrinkableArray.UintArray memory);

    /// @notice Unlock incoming `nftIds`
    /// @param voter Holder address
    /// @param nftIds List of NFT ids to unlock
    function unlockNfts(address voter, uint256[] calldata nftIds) external;

    /// @notice Checks the user's balance
    /// @param user Holder address
    /// @param requiredTokens Minimal require tokens amount
    /// @param requiredNfts Minimal require nfts amount
    function canUserParticipate(
        address user,
        uint256 requiredTokens,
        uint256 requiredNfts
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./settings/IGovSettings.sol";

/**
 * This contract is responsible for the creation of new proposals (part of the pool)
 */
interface IGovCreator {
    struct ProposalCore {
        IGovSettings.ProposalSettings settings;
        bool executed;
        uint64 voteEnd;
        uint256 votesFor;
        uint256 nftPowerSnapshotId;
        uint256 proposalId;
    }

    struct Proposal {
        ProposalCore core;
        string descriptionURL;
        address[] executors;
        uint256[] values;
        bytes[] data;
    }

    /// @notice Create proposal
    /// @notice For internal proposal, last executor should be `GovSetting` contract
    /// @notice For typed proposal, last executor should be typed contract
    /// @notice For external proposal, any configuration of addresses and bytes
    /// @param descriptionURL IPFS url to the proposal's description
    /// @param executors Executors addresses
    /// @param values the ether values
    /// @param data data Bytes
    function createProposal(
        string calldata descriptionURL,
        address[] memory executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) external;

    /// @param proposalId Proposal ID
    /// @return Executor addresses
    /// @return Data for each address
    function getProposalInfo(uint256 proposalId)
        external
        view
        returns (address[] memory, bytes[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 *  @notice This library is used to convert numbers that use token's N decimals to M decimals.
 *  Comes extremely handy with standardizing the business logic that is intended to work with many different ERC20 tokens
 *  that have different precision (decimals). One can perform calculations with 18 decimals only and resort to convertion
 *  only when the payouts (or interactions) with the actual tokes have to be made.
 *
 *  The best usage scenario involves accepting and calculating values with 18 decimals throughout the project, despite the tokens decimals.
 *
 *  Also it is recommended to call `round18()` function on the first execution line in order to get rid of the
 *  trailing numbers if the destination decimals are less than 18
 *
 *  Example:
 *
 *  contract Taker {
 *      ERC20 public USDC;
 *      uint256 public paid;
 *
 *      . . .
 *
 *      function pay(uint256 amount) external {
 *          uint256 decimals = USDC.decimals();
 *          amount = amount.round18(decimals);
 *
 *          paid += amount;
 *          USDC.transferFrom(msg.sender, address(this), amount.from18(decimals));
 *      }
 *  }
 */
library DecimalsConverter {
    function convert(
        uint256 amount,
        uint256 baseDecimals,
        uint256 destDecimals
    ) internal pure returns (uint256) {
        if (baseDecimals > destDecimals) {
            amount = amount / 10**(baseDecimals - destDecimals);
        } else if (baseDecimals < destDecimals) {
            amount = amount * 10**(destDecimals - baseDecimals);
        }

        return amount;
    }

    function to18(uint256 amount, uint256 baseDecimals) internal pure returns (uint256) {
        return convert(amount, baseDecimals, 18);
    }

    function from18(uint256 amount, uint256 destDecimals) internal pure returns (uint256) {
        return convert(amount, 18, destDecimals);
    }

    function round18(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        return to18(from18(amount, decimals), decimals);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../interfaces/gov/ERC721/IERC721Power.sol";

import "../../libs/MathHelper.sol";

import "../../core/Globals.sol";

contract ERC721Power is IERC721Power, ERC721Enumerable, Ownable {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using MathHelper for uint256;
    using DecimalsConverter for uint256;

    uint64 public powerCalcStartTimestamp;
    string public baseURI;

    /// @notice Contain detail nft information
    mapping(uint256 => NftInfo) public nftInfos; // tokenId => info

    uint256 public reductionPercent;

    address public collateralToken;
    uint256 public totalCollateral;

    uint256 public maxPower;
    uint256 public requiredCollateral;

    modifier onlyBeforePowerCalc() {
        require(
            block.timestamp < powerCalcStartTimestamp,
            "NftToken: power calculation already begun"
        );
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint64 startTimestamp
    ) ERC721(name, symbol) {
        powerCalcStartTimestamp = startTimestamp;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Power).interfaceId || super.supportsInterface(interfaceId);
    }

    function setReductionPercent(uint256 _reductionPercent)
        external
        override
        onlyOwner
        onlyBeforePowerCalc
    {
        require(_reductionPercent > 0, "NftToken: reduction percent can't be a zero");
        require(_reductionPercent < PERCENTAGE_100, "NftToken: reduction percent can't be a 100%");

        reductionPercent = _reductionPercent;
    }

    function setMaxPower(uint256 _maxPower) external override onlyOwner onlyBeforePowerCalc {
        require(_maxPower > 0, "NftToken: max power can't be zero (1)");

        maxPower = _maxPower;
    }

    function setNftMaxPower(uint256 _maxPower, uint256 tokenId)
        external
        override
        onlyOwner
        onlyBeforePowerCalc
    {
        require(_maxPower > 0, "NftToken: max power can't be zero (2)");

        nftInfos[tokenId].maxPower = _maxPower;
    }

    function setCollateralToken(address _collateralToken)
        external
        override
        onlyOwner
        onlyBeforePowerCalc
    {
        require(_collateralToken != address(0), "NftToken: zero address");

        collateralToken = _collateralToken;
    }

    function setRequiredCollateral(uint256 amount)
        external
        override
        onlyOwner
        onlyBeforePowerCalc
    {
        require(amount > 0, "NftToken: required collateral amount can't be zero (1)");

        requiredCollateral = amount;
    }

    function setNftRequiredCollateral(uint256 amount, uint256 tokenId)
        external
        override
        onlyOwner
        onlyBeforePowerCalc
    {
        require(amount > 0, "NftToken: required collateral amount can't be zero (2)");

        nftInfos[tokenId].requiredCollateral = amount;
    }

    function safeMint(address to, uint256 tokenId)
        external
        override
        onlyOwner
        onlyBeforePowerCalc
    {
        require(getMaxPowerForNft(tokenId) > 0, "NftToken: max power for nft isn't set");
        require(
            getRequiredCollateralForNft(tokenId) > 0,
            "NftToken: required collateral amount for nft isn't set"
        );

        _safeMint(to, tokenId, "");
    }

    function addCollateral(uint256 amount, uint256 tokenId) external override {
        require(ownerOf(tokenId) == msg.sender, "NftToken: sender isn't an nft owner (1)");

        IERC20(collateralToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount.from18(ERC20(collateralToken).decimals())
        );

        uint256 currentCollateralAmount = nftInfos[tokenId].currentCollateral;
        _recalculateNftPower(tokenId, currentCollateralAmount);

        nftInfos[tokenId].currentCollateral = currentCollateralAmount + amount;
        totalCollateral += amount;
    }

    function removeCollateral(uint256 amount, uint256 tokenId) external override {
        require(ownerOf(tokenId) == msg.sender, "NftToken: sender isn't an nft owner (2)");

        uint256 currentCollateralAmount = nftInfos[tokenId].currentCollateral;
        amount = amount.min(currentCollateralAmount);

        require(amount > 0, "NftToken: nothing to remove");

        _recalculateNftPower(tokenId, currentCollateralAmount);

        nftInfos[tokenId].currentCollateral = currentCollateralAmount - amount;
        totalCollateral -= amount;

        IERC20(collateralToken).safeTransfer(
            msg.sender,
            amount.from18(ERC20(collateralToken).decimals())
        );
    }

    function recalculateNftPower(uint256 tokenId) external override returns (uint256) {
        return _recalculateNftPower(tokenId, nftInfos[tokenId].currentCollateral);
    }

    function getMaxPowerForNft(uint256 tokenId) public view override returns (uint256) {
        uint256 maxPowerForNft = nftInfos[tokenId].maxPower;

        return maxPowerForNft == 0 ? maxPower : maxPowerForNft;
    }

    function getRequiredCollateralForNft(uint256 tokenId) public view override returns (uint256) {
        uint256 requiredCollateralForNft = nftInfos[tokenId].requiredCollateral;

        return requiredCollateralForNft == 0 ? requiredCollateral : requiredCollateralForNft;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _recalculateNftPower(uint256 tokenId, uint256 currentCollateral)
        private
        returns (uint256)
    {
        if (block.timestamp <= powerCalcStartTimestamp) {
            return 0;
        }

        // Calculate the minimum possible power based on the collateral of the nft
        uint256 maxNftPower = getMaxPowerForNft(tokenId);
        uint256 minNftPower = maxNftPower.ratio(
            currentCollateral,
            getRequiredCollateralForNft(tokenId)
        );
        minNftPower = maxNftPower.min(minNftPower);

        // Get last update and current power. Or set them to default if it is first iteration
        uint64 lastUpdate = nftInfos[tokenId].lastUpdate;
        uint256 currentPower = nftInfos[tokenId].currentPower;

        if (lastUpdate == 0) {
            lastUpdate = powerCalcStartTimestamp;
            currentPower = maxNftPower;
        }

        nftInfos[tokenId].lastUpdate = uint64(block.timestamp);

        // Calculate reduction amount
        uint256 powerReductionPercent = reductionPercent * (block.timestamp - lastUpdate);
        uint256 powerReduction = currentPower.min(maxNftPower.percentage(powerReductionPercent));
        uint256 newPotentialPower = currentPower - powerReduction;

        if (minNftPower <= newPotentialPower) {
            nftInfos[tokenId].currentPower = newPotentialPower;

            return newPotentialPower;
        }

        if (minNftPower <= currentPower) {
            nftInfos[tokenId].currentPower = minNftPower;

            return minNftPower;
        }

        return currentPower;
    }

    function setBaseUri(string calldata uri) external onlyOwner {
        baseURI = uri;
    }

    function withdrawStuckERC20(address token, address to) external onlyOwner {
        uint256 toWithdraw = IERC20(token).balanceOf(address(this));

        if (token == collateralToken) {
            toWithdraw -= totalCollateral;
        }

        require(toWithdraw > 0, "NftToken: nothing to withdraw");

        IERC20(token).safeTransfer(to, toWithdraw);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * This is the custom NFT contract with voting power
 */
interface IERC721Power is IERC721Enumerable {
    struct NftInfo {
        uint64 lastUpdate;
        uint256 currentPower;
        uint256 currentCollateral;
        uint256 maxPower;
        uint256 requiredCollateral;
    }

    /// @notice Set reduction percent. 100% = 10^27
    /// @param _reductionPercent Decimals
    function setReductionPercent(uint256 _reductionPercent) external;

    /// @notice Set max possible power (coefficient) for all nfts
    /// @param _maxPower Decimals
    function setMaxPower(uint256 _maxPower) external;

    /// @notice Set max possible power (coefficient) for certain nft
    /// @param _maxPower Decimals
    /// @param tokenId Nft number
    function setNftMaxPower(uint256 _maxPower, uint256 tokenId) external;

    /// @notice Set collateral token address
    /// @param _collateralToken Address
    function setCollateralToken(address _collateralToken) external;

    /// @notice Set required collateral amount for all nfts
    /// @param amount Wei
    function setRequiredCollateral(uint256 amount) external;

    /// @notice Set required collateral amount for certain nft
    /// @param amount Wei
    /// @param tokenId Nft number
    function setNftRequiredCollateral(uint256 amount, uint256 tokenId) external;

    /// @notice Mint new nft
    /// @param to Address
    /// @param tokenId Nft number
    function safeMint(address to, uint256 tokenId) external;

    /// @notice Add collateral amount to certain nft
    /// @param amount Wei
    /// @param tokenId Nft number
    function addCollateral(uint256 amount, uint256 tokenId) external;

    /// @notice Remove collateral amount from certain nft
    /// @param amount Wei
    /// @param tokenId Nft number
    function removeCollateral(uint256 amount, uint256 tokenId) external;

    /// @notice Recalculate nft power (coefficient)
    /// @param tokenId Nft number
    function recalculateNftPower(uint256 tokenId) external returns (uint256);

    /// @notice Return max possible power (coefficient) for nft
    /// @param tokenId Nft number
    function getMaxPowerForNft(uint256 tokenId) external view returns (uint256);

    /// @notice Return required collateral amount for nft
    /// @param tokenId Nft number
    function getRequiredCollateralForNft(uint256 tokenId) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

import "../../interfaces/gov/validators/IGovValidatorsToken.sol";

contract GovValidatorsToken is IGovValidatorsToken, ERC20Snapshot {
    address public immutable validator;

    modifier onlyValidator() {
        require(validator == msg.sender, "ValidatorsToken: caller is not the validator");
        _;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        validator = msg.sender;
    }

    function mint(address account, uint256 amount) external override onlyValidator {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external override onlyValidator {
        _burn(account, amount);
    }

    function snapshot() external override onlyValidator returns (uint256) {
        return _snapshot();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override onlyValidator {
        super._beforeTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Snapshot.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Arrays.sol";
import "../../../utils/Counters.sol";

/**
 * @dev This contract extends an ERC20 token with a snapshot mechanism. When a snapshot is created, the balances and
 * total supply at the time are recorded for later access.
 *
 * This can be used to safely create mechanisms based on token balances such as trustless dividends or weighted voting.
 * In naive implementations it's possible to perform a "double spend" attack by reusing the same balance from different
 * accounts. By using snapshots to calculate dividends or voting power, those attacks no longer apply. It can also be
 * used to create an efficient ERC20 forking mechanism.
 *
 * Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
 * snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
 * id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
 * and the account address.
 *
 * NOTE: Snapshot policy can be customized by overriding the {_getCurrentSnapshotId} method. For example, having it
 * return `block.number` will trigger the creation of snapshot at the begining of each new block. When overridding this
 * function, be careful about the monotonicity of its result. Non-monotonic snapshot ids will break the contract.
 *
 * Implementing snapshots for every block using this method will incur significant gas costs. For a gas-efficient
 * alternative consider {ERC20Votes}.
 *
 * ==== Gas Costs
 *
 * Snapshots are efficient. Snapshot creation is _O(1)_. Retrieval of balances or total supply from a snapshot is _O(log
 * n)_ in the number of snapshots that have been created, although _n_ for a specific account will generally be much
 * smaller since identical balances in subsequent snapshots are stored as a single entry.
 *
 * There is a constant overhead for normal ERC20 transfers due to the additional snapshot bookkeeping. This overhead is
 * only significant for the first transfer that immediately follows a snapshot for a particular account. Subsequent
 * transfers will have normal cost until the next snapshot, and so on.
 */

abstract contract ERC20Snapshot is ERC20 {
    // Inspired by Jordi Baylina's MiniMeToken to record historical balances:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Get the current snapshotId
     */
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // mint
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            // burn
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            // transfer
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * This is the contract that determines the validators
 */
interface IGovValidatorsToken is IERC20 {
    /// @notice Mint new tokens, available only from `Validators` contract
    /// @param account Address
    /// @param amount Token amount to mint. Wei
    function mint(address account, uint256 amount) external;

    /// @notice Burn tokens, available only from `Validators` contract
    /// @param account Address
    /// @param amount Token amount to burn. Wei
    function burn(address account, uint256 amount) external;

    /// @notice Create tokens snapshot
    /// @return Snapshot ID
    function snapshot() external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Arrays.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is governance pools registry contract. The registry stores information about the deployed governance pools
 * and their owners. The owner of this contract is able to upgrade all the governance pools and the associated pools
 * with it via the BeaconProxy pattern
 */
interface IGovPoolRegistry {
    /// @notice The function to associate an owner with the pool (called by the PoolFactory)
    /// @param user the owner of the pool
    /// @param name the type of the pool
    /// @param poolAddress the address of the new pool
    function associateUserWithPool(
        address user,
        string calldata name,
        address poolAddress
    ) external;

    /// @notice The function that counts owner's pools by their type
    /// @param user the owner of the pool
    /// @param name the type of the pool
    /// @return the total number of pools with the specified type
    function countOwnerPools(address user, string calldata name) external view returns (uint256);

    /// @notice The function that lists gov pools by the provided type and user
    /// @param user the owner
    /// @param name the type of the pool
    /// @param offset the starting index of the pools array
    /// @param limit the length of the observed pools array
    /// @return pools the addresses of the pools
    function listOwnerPools(
        address user,
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory pools);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolInvestorsHook.sol";
import "./ITraderPoolRiskyProposal.sol";
import "./ITraderPool.sol";

/**
 * This is the first type of pool that can de deployed by the trader in the DEXE platform.
 * BasicTraderPool inherits TraderPool functionality and adds the ability to invest into the risky proposals.
 * RiskyProposals are basically subpools where the trader is only allowed to open positions to the prespecified token.
 * Investors can enter subpools by allocating parts of their funds to the proposals. The allocation as done
 * through internal withdrawal and deposit process
 */
interface IBasicTraderPool is ITraderPoolInvestorsHook {
    /// @notice This function is used to create risky proposals (basically subpools) and allow investors to invest into it.
    /// The proposals follow pretty much the same rules as the main pool except that the trade can happen with a specified token only.
    /// Investors can't fund the proposal more than the trader percentage wise
    /// @param token the token the proposal will be opened to
    /// @param lpAmount the amount of LP tokens the trader would like to invest into the proposal at its creation
    /// @param proposalLimits the certain limits this proposal will have
    /// @param instantTradePercentage the percentage of LP tokens (base tokens under them) that will be traded to the proposal token
    /// @param minDivestOut is an array of minimal received amounts of positions on proposal creation (call getDivestAmountsAndCommissions()) to fetch this values
    /// @param minProposalOut is a minimal received amount of proposal position on proposal creation (call getCreationTokens()) to fetch this value
    /// @param optionalPath is an optional path between the base token and proposal token that will be used by the pathfinder
    function createProposal(
        address token,
        uint256 lpAmount,
        ITraderPoolRiskyProposal.ProposalLimits calldata proposalLimits,
        uint256 instantTradePercentage,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut,
        address[] calldata optionalPath
    ) external;

    /// @notice This function invests into the created proposals. The function takes user's part of the pool, converts it to
    /// the base token and puts the funds into the proposal
    /// @param proposalId the id of the proposal a user would like to invest to
    /// @param lpAmount the amount of LP tokens to invest into the proposal
    /// @param minDivestOut the minimal received pool positions amounts
    /// @param minProposalOut the minimal amount of proposal tokens to receive
    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut
    ) external;

    /// @notice This function divests from the proposal and puts the funds back to the main pool
    /// @param proposalId the id of the proposal to divest from
    /// @param lp2Amount the amount of proposal LP tokens to be divested
    /// @param minInvestsOut the minimal amounts of main pool positions tokens to be received
    /// @param minProposalOut the minimal amount of base tokens received on a proposal divest
    function reinvestProposal(
        uint256 proposalId,
        uint256 lp2Amount,
        uint256[] calldata minInvestsOut,
        uint256 minProposalOut
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolProposal.sol";

/**
 * This is the proposal the trader is able to create for the BasicTraderPool. This proposal is basically a simplified
 * version of a BasicTraderPool where a trader is only able to trade to a predefined token. The proposal itself encapsulates
 * investors and shares the profit only with the ones who invested into it
 */
interface ITraderPoolRiskyProposal is ITraderPoolProposal {
    /// @notice The enum of exchange types
    /// @param FROM_EXACT the type corresponding to the exchangeFromExact function
    /// @param TO_EXACT the type corresponding to the exchangeToExact function
    enum ExchangeType {
        FROM_EXACT,
        TO_EXACT
    }

    /// @notice The struct that stores certain proposal limits
    /// @param timestampLimit the timestamp after which the investment into this proposal closes
    /// @param investLPLimit the maximal number of invested LP tokens after which the investment into the proposal closes
    /// @param maxTokenPriceLimit the maximal price of the proposal token to the base token after which the investment into the proposal closes
    /// basically, if priceIn(base, token, 1) > maxTokenPriceLimit, the proposal closes for the investment
    struct ProposalLimits {
        uint256 timestampLimit;
        uint256 investLPLimit;
        uint256 maxTokenPriceLimit;
    }

    /// @notice The struct that holds the information of this proposal
    /// @param token the address of the proposal token
    /// @param tokenDecimals the decimals of the proposal token
    /// @param proposalLimits the investment limits of this proposal
    /// @param lpLocked the amount of LP tokens that are locked in this proposal
    /// @param balanceBase the base token balance of this proposal (normalized)
    /// @param balancePosition the position token balance of this proposal (normalized)
    struct ProposalInfo {
        address token;
        uint256 tokenDecimals;
        ProposalLimits proposalLimits;
        uint256 lpLocked;
        uint256 balanceBase;
        uint256 balancePosition;
    }

    /// @notice The struct that holds extra information about this proposal
    /// @param proposalInfo the information about this proposal
    /// @param totalProposalUSD the equivalent USD TVL in this proposal
    /// @param totalProposalBase the equivalent base TVL in this proposal
    /// @param totalInvestors the number of investors currently in this proposal
    /// @param positionTokenPrice the exact price on 1 position token in base tokens
    struct ProposalInfoExtended {
        ProposalInfo proposalInfo;
        uint256 totalProposalUSD;
        uint256 totalProposalBase;
        uint256 lp2Supply;
        uint256 totalInvestors;
        uint256 positionTokenPrice;
    }

    /// @notice The struct that is used in the "TraderPoolRiskyProposalView" contract and stores information about the investor's
    /// active investments
    /// @param proposalId the id of the proposal
    /// @param lp2Balance the investor's balance of proposal's LP tokens
    /// @param baseInvested the amount of invested base tokens by investor
    /// @param lpInvested the amount of invested LP tokens by investor
    /// @param baseShare the amount of investor's base token in this proposal
    /// @param positionShare the amount of investor's position token in this proposal
    struct ActiveInvestmentInfo {
        uint256 proposalId;
        uint256 lp2Balance;
        uint256 baseInvested;
        uint256 lpInvested;
        uint256 baseShare;
        uint256 positionShare;
    }

    /// @notice The struct that is used in the "TraderPoolRiskyProposalView" contract and stores information about the funds
    /// received on the divest action
    /// @param baseAmount the total amount of base tokens received
    /// @param positions the divested positions addresses
    /// @param givenAmounts the given amounts of tokens (in position tokens)
    /// @param receivedAmounts the received amounts of tokens (in base tokens)
    struct Receptions {
        uint256 baseAmount;
        address[] positions;
        uint256[] givenAmounts;
        uint256[] receivedAmounts; // should be used as minAmountOut
    }

    /// @notice The function to change the proposal investment restrictions
    /// @param proposalId the id of the proposal to change the restriction for
    /// @param proposalLimits the new limits for the proposal
    function changeProposalRestrictions(uint256 proposalId, ProposalLimits calldata proposalLimits)
        external;

    /// @notice The function to get the information about the proposals
    /// @param offset the starting index of the proposals array
    /// @param limit the number of proposals to observe
    /// @return proposals the information about the proposals
    function getProposalInfos(uint256 offset, uint256 limit)
        external
        view
        returns (ProposalInfoExtended[] memory proposals);

    /// @notice The function to get the information about the active proposals of this user
    /// @param user the user to observe
    /// @param offset the starting index of the users array
    /// @param limit the number of users to observe
    /// @return investments the information about the currently active investments
    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ActiveInvestmentInfo[] memory investments);

    /// @notice The function that returns the maximum allowed LP investment for the user
    /// @param user the user to get the investment limit for
    /// @param proposalIds the ids of the proposals to investigate the limits for
    /// @return lps the array of numbers representing the maximum allowed investment in LP tokens
    function getUserInvestmentsLimits(address user, uint256[] calldata proposalIds)
        external
        view
        returns (uint256[] memory lps);

    /// @notice The function that returns the percentage of invested LPs agains the user's LP balance
    /// @param proposalId the proposal the user invested in
    /// @param user the proposal's investor to calculate percentage for
    /// @param toBeInvested LP amount the user is willing to invest
    /// @return the percentage of invested LPs + toBeInvested against the user's balance
    function getInvestmentPercentage(
        uint256 proposalId,
        address user,
        uint256 toBeInvested
    ) external view returns (uint256);

    /// @notice The function to get the amount of position token on proposal creation
    /// @param token the proposal token
    /// @param baseInvestment the amount of base tokens invested rightaway
    /// @param instantTradePercentage the percentage of tokens that will be traded instantly to a "token"
    /// @param optionalPath the optional path between base token and position token that will be used by the pathfinder
    /// @return positionTokens the amount of position tokens received upon creation
    /// @return positionTokenPrice the price of 1 proposal token to the base token
    /// @return path the tokens path that will be used during the swap
    function getCreationTokens(
        address token,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        address[] calldata optionalPath
    )
        external
        view
        returns (
            uint256 positionTokens,
            uint256 positionTokenPrice,
            address[] memory path
        );

    /// @notice The function to create a proposal
    /// @param token the proposal token (the one that the trades are only allowed to)
    /// @param proposalLimits the investment limits for this proposal
    /// @param lpInvestment the amount of LP tokens invested rightaway
    /// @param baseInvestment the equivalent amount of baseToken invested rightaway
    /// @param instantTradePercentage the percentage of tokens that will be traded instantly to a "token"
    /// @param minPositionOut the minimal amount of position tokens received (call getCreationTokens())
    /// @param optionalPath the optional path between base token and position token that will be used by the pathfinder
    /// @return proposalId the id of the created proposal
    function create(
        address token,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        uint256 minPositionOut,
        address[] calldata optionalPath
    ) external returns (uint256 proposalId);

    /// @notice The function to get the amount of base tokens and position tokens received on this proposal investment
    /// @param proposalId the id of the proposal to invest in
    /// @param baseInvestment the amount of base tokens to be invested (normalized)
    /// @return baseAmount the received amount of base tokens (normalized)
    /// @return positionAmount the received amount of position tokens (normalized)
    /// @return lp2Amount the amount of LP2 tokens received
    function getInvestTokens(uint256 proposalId, uint256 baseInvestment)
        external
        view
        returns (
            uint256 baseAmount,
            uint256 positionAmount,
            uint256 lp2Amount
        );

    /// @notice The function to invest into the proposal
    /// @param proposalId the id of the proposal to invest in
    /// @param user the investor
    /// @param lpInvestment the amount of LP tokens invested into the proposal
    /// @param baseInvestment the equivalent amount of baseToken invested into the proposal
    /// @param minPositionOut the minimal amount of position tokens received on proposal investment (call getInvestTokens())
    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 minPositionOut
    ) external;

    /// @notice The function to get the received tokens on divest
    /// @param proposalIds the ids of the proposals to divest from
    /// @param lp2s the amounts of proposals LPs to be divested
    /// @return receptions the information about the received tokens
    function getDivestAmounts(uint256[] calldata proposalIds, uint256[] calldata lp2s)
        external
        view
        returns (Receptions memory receptions);

    /// @notice The function to divest (reinvest) from a proposal
    /// @param proposalId the id of the proposal to divest from
    /// @param user the investor (or trader) who is divesting
    /// @param lp2 the amount of proposal LPs to divest
    /// @param minPositionOut the minimal amount of base tokens received from the position (call getDivestAmounts())
    /// @return received amount of base tokens
    function divest(
        uint256 proposalId,
        address user,
        uint256 lp2,
        uint256 minPositionOut
    ) external returns (uint256);

    /// @notice The function to exchange tokens for tokens in the specified proposal
    /// @param proposalId the proposal to exchange tokens in
    /// @param from the tokens to exchange from
    /// @param amount the amount of tokens to be exchanged (normalized). If fromExact, this should equal amountIn, else amountOut
    /// @param amountBound this should be minAmountOut if fromExact, else maxAmountIn
    /// @param optionalPath the optional path between from and to tokens used by the pathfinder
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    function exchange(
        uint256 proposalId,
        address from,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external;

    /// @notice The function to get token prices required for the slippage in the specified proposal
    /// @param proposalId the id of the proposal to get the prices in
    /// @param from the token to exchange from
    /// @param amount the amount of tokens to be exchanged. If fromExact, this should be amountIn, else amountOut
    /// @param optionalPath optional path between from and to tokens used by the pathfinder
    /// @return amount the minAmountOut if fromExact, else maxAmountIn
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    function getExchangeAmount(
        uint256 proposalId,
        address from,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view returns (uint256, address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../interfaces/trader/ITraderPool.sol";
import "../interfaces/core/IPriceFeed.sol";
import "../interfaces/insurance/IInsurance.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/PriceFeed/PriceFeedLocal.sol";
import "../libs/TraderPool/TraderPoolPrice.sol";
import "../libs/TraderPool/TraderPoolLeverage.sol";
import "../libs/TraderPool/TraderPoolCommission.sol";
import "../libs/TraderPool/TraderPoolExchange.sol";
import "../libs/TraderPool/TraderPoolView.sol";
import "../libs/TokenBalance.sol";
import "../libs/MathHelper.sol";

import "../core/Globals.sol";

abstract contract TraderPool is ITraderPool, ERC20Upgradeable, AbstractDependant {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using Math for uint256;
    using DecimalsConverter for uint256;
    using TraderPoolPrice for PoolParameters;
    using TraderPoolPrice for address;
    using TraderPoolLeverage for PoolParameters;
    using TraderPoolCommission for PoolParameters;
    using TraderPoolExchange for PoolParameters;
    using TraderPoolView for PoolParameters;
    using MathHelper for uint256;
    using PriceFeedLocal for IPriceFeed;
    using TokenBalance for address;

    IERC20 internal _dexeToken;
    IPriceFeed public override priceFeed;
    ICoreProperties public override coreProperties;

    EnumerableSet.AddressSet internal _traderAdmins;

    PoolParameters internal _poolParameters;

    EnumerableSet.AddressSet internal _privateInvestors;
    EnumerableSet.AddressSet internal _investors;
    EnumerableSet.AddressSet internal _positions;

    mapping(address => mapping(uint256 => uint256)) internal _investsInBlocks; // user => block => LP amount

    mapping(address => InvestorInfo) public investorsInfo;

    event InvestorAdded(address investor);
    event InvestorRemoved(address investor);
    event Invested(address user, uint256 investedBase, uint256 receivedLP);
    event Divested(address user, uint256 divestedLP, uint256 receivedBase);
    event ActivePortfolioExchanged(
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event CommissionClaimed(address sender, uint256 traderLpClaimed, uint256 traderBaseClaimed);
    event DescriptionURLChanged(address sender, string descriptionURL);
    event ModifiedAdmins(address sender, address[] admins, bool add);
    event ModifiedPrivateInvestors(address sender, address[] privateInvestors, bool add);

    modifier onlyTraderAdmin() {
        _onlyTraderAdmin();
        _;
    }

    function _onlyTraderAdmin() internal view {
        require(isTraderAdmin(msg.sender), "TP: not an admin");
    }

    modifier onlyTrader() {
        _onlyTrader();
        _;
    }

    function _onlyTrader() internal view {
        require(isTrader(msg.sender), "TP: not a trader");
    }

    function _checkUserBalance(uint256 amountLP) internal view {
        require(
            amountLP <= balanceOf(msg.sender) - _investsInBlocks[msg.sender][block.number],
            "TP: wrong amount"
        );
    }

    function isPrivateInvestor(address who) public view override returns (bool) {
        return _privateInvestors.contains(who);
    }

    function isTraderAdmin(address who) public view override returns (bool) {
        return _traderAdmins.contains(who);
    }

    function isTrader(address who) public view override returns (bool) {
        return _poolParameters.trader == who;
    }

    function __TraderPool_init(
        string calldata name,
        string calldata symbol,
        PoolParameters calldata poolParameters
    ) public onlyInitializing {
        __ERC20_init(name, symbol);

        _poolParameters = poolParameters;
        _traderAdmins.add(poolParameters.trader);
    }

    function setDependencies(address contractsRegistry) public virtual override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        _dexeToken = IERC20(registry.getDEXEContract());
        priceFeed = IPriceFeed(registry.getPriceFeedContract());
        coreProperties = ICoreProperties(registry.getCorePropertiesContract());
    }

    function modifyAdmins(address[] calldata admins, bool add) external override onlyTraderAdmin {
        for (uint256 i = 0; i < admins.length; i++) {
            if (add) {
                _traderAdmins.add(admins[i]);
            } else {
                _traderAdmins.remove(admins[i]);
            }
        }

        _traderAdmins.add(_poolParameters.trader);

        emit ModifiedAdmins(msg.sender, admins, add);
    }

    function modifyPrivateInvestors(address[] calldata privateInvestors, bool add)
        external
        override
        onlyTraderAdmin
    {
        for (uint256 i = 0; i < privateInvestors.length; i++) {
            if (add) {
                _privateInvestors.add(privateInvestors[i]);
            } else if (canRemovePrivateInvestor(privateInvestors[i])) {
                _privateInvestors.remove(privateInvestors[i]);
            }
        }

        emit ModifiedPrivateInvestors(msg.sender, privateInvestors, add);
    }

    function canRemovePrivateInvestor(address investor)
        public
        view
        virtual
        override
        returns (bool);

    function changePoolParameters(
        string calldata descriptionURL,
        bool privatePool,
        uint256 totalLPEmission,
        uint256 minimalInvestment
    ) external override onlyTraderAdmin {
        require(
            totalLPEmission == 0 || totalEmission() <= totalLPEmission,
            "TP: wrong emission supply"
        );
        require(
            !privatePool || (privatePool && _investors.length() == 0),
            "TP: pool is not empty"
        );

        _poolParameters.descriptionURL = descriptionURL;
        _poolParameters.privatePool = privatePool;
        _poolParameters.totalLPEmission = totalLPEmission;
        _poolParameters.minimalInvestment = minimalInvestment;

        emit DescriptionURLChanged(msg.sender, descriptionURL);
    }

    function totalInvestors() external view override returns (uint256) {
        return _investors.length();
    }

    function proposalPoolAddress() external view virtual override returns (address);

    function totalEmission() public view virtual override returns (uint256);

    function openPositions() public view returns (address[] memory) {
        return coreProperties.getFilteredPositions(_positions.values());
    }

    function getUsersInfo(uint256 offset, uint256 limit)
        external
        view
        override
        returns (UserInfo[] memory usersInfo)
    {
        return _poolParameters.getUsersInfo(_investors, offset, limit);
    }

    function getPoolInfo() external view override returns (PoolInfo memory poolInfo) {
        return _poolParameters.getPoolInfo(_positions);
    }

    function _transferBaseAndMintLP(
        address baseHolder,
        uint256 totalBaseInPool,
        uint256 amountInBaseToInvest
    ) internal returns (uint256) {
        IERC20(_poolParameters.baseToken).safeTransferFrom(
            baseHolder,
            address(this),
            amountInBaseToInvest.from18(_poolParameters.baseTokenDecimals)
        );

        uint256 toMintLP = amountInBaseToInvest;

        if (totalBaseInPool > 0) {
            toMintLP = toMintLP.ratio(totalSupply(), totalBaseInPool);
        }

        require(
            _poolParameters.totalLPEmission == 0 ||
                totalEmission() + toMintLP <= _poolParameters.totalLPEmission,
            "TP: minting > emission"
        );

        _investsInBlocks[msg.sender][block.number] += toMintLP;
        _mint(msg.sender, toMintLP);

        return toMintLP;
    }

    function getLeverageInfo() external view override returns (LeverageInfo memory leverageInfo) {
        return _poolParameters.getLeverageInfo();
    }

    function getInvestTokens(uint256 amountInBaseToInvest)
        external
        view
        override
        returns (Receptions memory receptions)
    {
        return _poolParameters.getInvestTokens(amountInBaseToInvest);
    }

    function _investPositions(
        address baseHolder,
        uint256 amountInBaseToInvest,
        uint256[] calldata minPositionsOut
    ) internal returns (uint256 lpMinted) {
        address baseToken = _poolParameters.baseToken;
        (
            uint256 totalBase,
            ,
            address[] memory positionTokens,
            uint256[] memory positionPricesInBase
        ) = _poolParameters.getNormalizedPoolPriceAndPositions();

        lpMinted = _transferBaseAndMintLP(baseHolder, totalBase, amountInBaseToInvest);

        for (uint256 i = 0; i < positionTokens.length; i++) {
            uint256 amount = positionPricesInBase[i].ratio(amountInBaseToInvest, totalBase);
            uint256 amountGot = priceFeed.normExchangeFromExact(
                baseToken,
                positionTokens[i],
                amount,
                new address[](0),
                minPositionsOut[i]
            );

            emit ActivePortfolioExchanged(baseToken, positionTokens[i], amount, amountGot);
        }
    }

    function invest(uint256 amountInBaseToInvest, uint256[] calldata minPositionsOut)
        public
        virtual
        override
    {
        require(amountInBaseToInvest > 0, "TP: zero investment");
        require(amountInBaseToInvest >= _poolParameters.minimalInvestment, "TP: underinvestment");

        _poolParameters.checkLeverage(amountInBaseToInvest);

        uint256 lpMinted = _investPositions(msg.sender, amountInBaseToInvest, minPositionsOut);
        _updateTo(msg.sender, lpMinted, amountInBaseToInvest);
    }

    function _distributeCommission(
        uint256 baseToDistribute,
        uint256 lpToDistribute,
        uint256 minDexeCommissionOut
    ) internal {
        require(baseToDistribute > 0, "TP: no commission available");

        (
            uint256 dexePercentage,
            uint256[] memory poolPercentages,
            address[3] memory commissionReceivers
        ) = coreProperties.getDEXECommissionPercentages();

        (uint256 dexeLPCommission, uint256 dexeBaseCommission) = TraderPoolCommission
            .calculateDexeCommission(baseToDistribute, lpToDistribute, dexePercentage);
        uint256 dexeCommission = priceFeed.normExchangeFromExact(
            _poolParameters.baseToken,
            address(_dexeToken),
            dexeBaseCommission,
            new address[](0),
            minDexeCommissionOut
        );

        _mint(_poolParameters.trader, lpToDistribute - dexeLPCommission);
        TraderPoolCommission.sendDexeCommission(
            _dexeToken,
            dexeCommission,
            poolPercentages,
            commissionReceivers
        );

        emit CommissionClaimed(
            msg.sender,
            lpToDistribute - dexeLPCommission,
            baseToDistribute - dexeBaseCommission
        );
    }

    function getReinvestCommissions(uint256[] calldata offsetLimits)
        external
        view
        override
        returns (Commissions memory commissions)
    {
        return _poolParameters.getReinvestCommissions(_investors, offsetLimits);
    }

    function getNextCommissionEpoch() public view returns (uint256) {
        return _poolParameters.nextCommissionEpoch();
    }

    function reinvestCommission(uint256[] calldata offsetLimits, uint256 minDexeCommissionOut)
        external
        virtual
        override
        onlyTraderAdmin
    {
        require(openPositions().length == 0, "TP: positions are open");

        uint256 investorsLength = _investors.length();
        uint256 totalSupply = totalSupply();
        uint256 nextCommissionEpoch = getNextCommissionEpoch();
        uint256 allBaseCommission;
        uint256 allLPCommission;

        for (uint256 i = 0; i < offsetLimits.length; i += 2) {
            uint256 to = (offsetLimits[i] + offsetLimits[i + 1]).min(investorsLength).max(
                offsetLimits[i]
            );

            for (uint256 j = offsetLimits[i]; j < to; j++) {
                address investor = _investors.at(j);
                InvestorInfo storage info = investorsInfo[investor];

                if (nextCommissionEpoch > info.commissionUnlockEpoch) {
                    (
                        uint256 investorBaseAmount,
                        uint256 baseCommission,
                        uint256 lpCommission
                    ) = _poolParameters.calculateCommissionOnReinvest(investor, totalSupply);

                    info.commissionUnlockEpoch = nextCommissionEpoch;

                    if (lpCommission > 0) {
                        info.investedBase = investorBaseAmount - baseCommission;

                        _burn(investor, lpCommission);

                        allBaseCommission += baseCommission;
                        allLPCommission += lpCommission;
                    }
                }
            }
        }

        _distributeCommission(allBaseCommission, allLPCommission, minDexeCommissionOut);
    }

    function _divestPositions(uint256 amountLP, uint256[] calldata minPositionsOut)
        internal
        returns (uint256 investorBaseAmount)
    {
        _checkUserBalance(amountLP);

        address[] memory _openPositions = openPositions();
        address baseToken = _poolParameters.baseToken;
        uint256 totalSupply = totalSupply();

        investorBaseAmount = baseToken.normThisBalance().ratio(amountLP, totalSupply);

        for (uint256 i = 0; i < _openPositions.length; i++) {
            uint256 amount = _openPositions[i].normThisBalance().ratio(amountLP, totalSupply);
            uint256 amountGot = priceFeed.normExchangeFromExact(
                _openPositions[i],
                baseToken,
                amount,
                new address[](0),
                minPositionsOut[i]
            );

            investorBaseAmount += amountGot;

            emit ActivePortfolioExchanged(_openPositions[i], baseToken, amount, amountGot);
        }
    }

    function _divestInvestor(
        uint256 amountLP,
        uint256[] calldata minPositionsOut,
        uint256 minDexeCommissionOut
    ) internal {
        uint256 investorBaseAmount = _divestPositions(amountLP, minPositionsOut);
        (uint256 baseCommission, uint256 lpCommission) = _poolParameters
            .calculateCommissionOnDivest(msg.sender, investorBaseAmount, amountLP);
        uint256 receivedBase = investorBaseAmount - baseCommission;

        _updateFrom(msg.sender, amountLP, receivedBase);
        _burn(msg.sender, amountLP);

        IERC20(_poolParameters.baseToken).safeTransfer(
            msg.sender,
            receivedBase.from18(_poolParameters.baseTokenDecimals)
        );

        if (baseCommission > 0) {
            _distributeCommission(baseCommission, lpCommission, minDexeCommissionOut);
        }
    }

    function _divestTrader(uint256 amountLP) internal {
        _checkUserBalance(amountLP);

        IERC20 baseToken = IERC20(_poolParameters.baseToken);
        uint256 receivedBase = address(baseToken).thisBalance().ratio(amountLP, totalSupply());

        _updateFrom(msg.sender, amountLP, receivedBase);
        _burn(msg.sender, amountLP);

        baseToken.safeTransfer(msg.sender, receivedBase);
    }

    function getDivestAmountsAndCommissions(address user, uint256 amountLP)
        external
        view
        override
        returns (Receptions memory receptions, Commissions memory commissions)
    {
        return _poolParameters.getDivestAmountsAndCommissions(user, amountLP);
    }

    function divest(
        uint256 amountLP,
        uint256[] calldata minPositionsOut,
        uint256 minDexeCommissionOut
    ) public virtual override {
        bool senderTrader = isTrader(msg.sender);
        require(!senderTrader || openPositions().length == 0, "TP: can't divest");

        if (senderTrader) {
            _divestTrader(amountLP);
        } else {
            _divestInvestor(amountLP, minPositionsOut, minDexeCommissionOut);
        }
    }

    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) public virtual override onlyTraderAdmin {
        _poolParameters.exchange(_positions, from, to, amount, amountBound, optionalPath, exType);
    }

    function getExchangeAmount(
        address from,
        address to,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view override returns (uint256, address[] memory) {
        return
            _poolParameters.getExchangeAmount(_positions, from, to, amount, optionalPath, exType);
    }

    function _updateFromData(address user, uint256 lpAmount)
        internal
        returns (uint256 baseTransfer)
    {
        if (!isTrader(user)) {
            InvestorInfo storage info = investorsInfo[user];

            baseTransfer = info.investedBase.ratio(lpAmount, balanceOf(user));
            info.investedBase -= baseTransfer;
        }
    }

    function _updateToData(address user, uint256 baseAmount) internal {
        if (!isTrader(user)) {
            investorsInfo[user].investedBase += baseAmount;
        }
    }

    function _checkRemoveInvestor(address user, uint256 lpAmount) internal {
        if (!isTrader(user) && lpAmount == balanceOf(user)) {
            _investors.remove(user);
            investorsInfo[user].commissionUnlockEpoch = 0;

            emit InvestorRemoved(user);
        }
    }

    function _checkNewInvestor(address user) internal {
        require(
            !_poolParameters.privatePool || isTraderAdmin(user) || isPrivateInvestor(user),
            "TP: private pool"
        );

        if (!isTrader(user) && !_investors.contains(user)) {
            _investors.add(user);
            investorsInfo[user].commissionUnlockEpoch = getNextCommissionEpoch();

            require(
                _investors.length() <= coreProperties.getMaximumPoolInvestors(),
                "TP: max investors"
            );

            emit InvestorAdded(user);
        }
    }

    function _updateFrom(
        address user,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal returns (uint256 baseTransfer) {
        baseTransfer = _updateFromData(user, lpAmount);

        emit Divested(user, lpAmount, baseAmount == 0 ? baseTransfer : baseAmount);

        _checkRemoveInvestor(user, lpAmount);
    }

    function _updateTo(
        address user,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal {
        _checkNewInvestor(user);
        _updateToData(user, baseAmount);

        emit Invested(user, baseAmount, lpAmount);
    }

    /// @notice if trader transfers tokens to an investor, we will count them as "earned" and add to the commission calculation
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(amount > 0, "TP: 0 transfer");

        if (from != address(0) && to != address(0) && from != to) {
            uint256 baseTransfer = _updateFrom(from, amount, 0); // baseTransfer is intended to be zero if sender is a trader
            _updateTo(to, amount, baseTransfer);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is an interface that is used in the proposals to add new investors upon token transfers
 */
interface ITraderPoolInvestorsHook {
    /// @notice The callback function that is called from _beforeTokenTransfer hook in the proposal contract.
    /// Needed to maintain the total investors amount
    /// @param user the transferrer of the funds
    function checkRemoveInvestor(address user) external;

    /// @notice The callback function that is called from _beforeTokenTransfer hook in the proposal contract.
    /// Needed to maintain the total investors amount
    /// @param user the receiver of the funds
    function checkNewInvestor(address user) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../core/IPriceFeed.sol";

/**
 * This this the abstract TraderPoolProposal contract. This contract has 2 implementations:
 * TraderPoolRiskyProposal and TraderPoolInvestProposal. Each of these contracts goes as a supplementary contract
 * for TraderPool contracts. Traders are able to create special proposals that act as subpools where investors can invest to.
 * Each subpool has its own LP token that represents the pool's share
 */
interface ITraderPoolProposal {
    /// @notice The struct that stores information about the parent trader pool
    /// @param parentPoolAddress the address of the parent trader pool
    /// @param trader the address of the trader
    /// @param baseToken the address of the base tokens the parent trader pool has
    /// @param baseTokenDecimals the baseToken decimals
    struct ParentTraderPoolInfo {
        address parentPoolAddress;
        address trader;
        address baseToken;
        uint256 baseTokenDecimals;
    }

    /// @notice The function that returns the PriceFeed this proposal uses
    /// @return the price feed address
    function priceFeed() external view returns (IPriceFeed);

    /// @notice The function that returns the amount of currently locked LP tokens in all proposals
    /// @return the amount of locked LP tokens in all proposals
    function totalLockedLP() external view returns (uint256);

    /// @notice The function that returns the amount of currently invested base tokens into all proposals
    /// @return the amount of invested base tokens
    function investedBase() external view returns (uint256);

    /// @notice The function that returns base token address of the parent pool
    /// @return base token address
    function getBaseToken() external view returns (address);

    /// @notice The function that returns the amount of currently invested base tokens into all proposals in USD
    /// @return the amount of invested base tokens in USD equivalent
    function getInvestedBaseInUSD() external view returns (uint256);

    /// @notice The function that returns total locked LP tokens amount of a specific user
    /// @param user the user to observe
    /// @return the total locked LP amount
    function totalLPBalances(address user) external view returns (uint256);

    /// @notice The function to get the total amount of currently active investments of a specific user
    /// @param user the user to observe
    /// @return the amount of currently active investments of the user
    function getTotalActiveInvestments(address user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the native DEXE insurance contract. Users can come and insure their invested funds by putting
 * DEXE tokens here. If the accident happens, the claim proposal has to be made for further investigation by the
 * DAO. The insurance is paid in DEXE tokens to all the provided addresses and backed by the commissions the protocol receives
 */
interface IInsurance {
    /// @notice Possible statuses of the proposed claim
    /// @param NULL the claim is either not created or pending
    /// @param ACCEPTED the claim is accepted and paid
    /// @param REJECTED the claim is rejected
    enum ClaimStatus {
        NULL,
        ACCEPTED,
        REJECTED
    }

    /// @notice The struct that holds finished claims info
    /// @param claimers the addresses that received the payout
    /// @param amounts the amounts in DEXE tokens paid to the claimers
    /// @param status the final status of the claim
    struct FinishedClaims {
        address[] claimers;
        uint256[] amounts;
        ClaimStatus status;
    }

    /// @notice The struct that holds information about the user
    /// @param stake the amount of tokens the user staked (bought the insurance for)
    /// @param lastDepositTimestamp the timestamp of user's last deposit
    /// @param lastProposalTimestamp the timestamp of user's last proposal creation
    struct UserInfo {
        uint256 stake;
        uint256 lastDepositTimestamp;
        uint256 lastProposalTimestamp;
    }

    /// @notice The "callback" function that is called from the TraderPools when the commission is sent to the insurance
    /// @param amount the received amount of DEXE tokens
    function receiveDexeFromPools(uint256 amount) external;

    /// @notice The function to buy an insurance for the deposited DEXE tokens. Minimal insurance is specified by the DAO
    /// @param deposit the amount of DEXE tokens to be deposited
    function buyInsurance(uint256 deposit) external;

    /// @notice The function that calculates received insurance from the deposited tokens
    /// @param deposit the amount of tokens to be deposited
    /// @return the received insurance tokens
    function getReceivedInsurance(uint256 deposit) external view returns (uint256);

    /// @notice The function to withdraw deposited DEXE tokens back (the insurance will cover less tokens as well)
    /// @param amountToWithdraw the amount of DEXE tokens to withdraw
    function withdraw(uint256 amountToWithdraw) external;

    /// @notice The function to propose the claim for the DAO review. Only the insurance holder can do that
    /// @param url the IPFS url to the claim evidence. Used as a claim key
    function proposeClaim(string calldata url) external;

    /// @notice The function to get the total count of ongoing claims
    /// @return the number of currently ongoing claims
    function ongoingClaimsCount() external view returns (uint256);

    /// @notice The paginated function to fetch currently going claims
    /// @param offset the starting index of the array
    /// @param limit the length of the observed window
    /// @return urls the IPFS URLs of the claims' evidence
    function listOngoingClaims(uint256 offset, uint256 limit)
        external
        view
        returns (string[] memory urls);

    /// @notice The function to get the total number of finished claims
    /// @return the number of finished claims
    function finishedClaimsCount() external view returns (uint256);

    /// @notice The paginated function to list finished claims
    /// @param offset the starting index of the array
    /// @param limit the length of the observed window
    /// @return urls the IPFS URLs of the claims' evidence
    /// @return info the extended info of the claims
    function listFinishedClaims(uint256 offset, uint256 limit)
        external
        view
        returns (string[] memory urls, FinishedClaims[] memory info);

    /// @notice The function called by the DAO to accept the claim
    /// @param url the IPFS URL of the claim to accept
    /// @param users the receivers of the claim
    /// @param amounts the amounts in DEXE tokens to be paid to the receivers (the contract will validate the payout amounts)
    function acceptClaim(
        string calldata url,
        address[] calldata users,
        uint256[] memory amounts
    ) external;

    /// @notice The function to reject the provided claim
    /// @param url the IPFS URL of the claim to be rejected
    function rejectClaim(string calldata url) external;

    /// @notice The function to get user's insurance info
    /// @param user the user to get info about
    /// @return deposit the total DEXE deposit of the provided user
    /// @return insurance the total insurance of the provided user
    function getInsurance(address user) external view returns (uint256 deposit, uint256 insurance);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../interfaces/core/IPriceFeed.sol";

import "../../core/Globals.sol";

library PriceFeedLocal {
    using SafeERC20 for IERC20;

    function checkAllowance(IPriceFeed priceFeed, address token) internal {
        if (IERC20(token).allowance(address(this), address(priceFeed)) == 0) {
            IERC20(token).safeApprove(address(priceFeed), MAX_UINT);
        }
    }

    function getNormPriceOut(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountIn
    ) internal view returns (uint256 amountOut) {
        (amountOut, ) = priceFeed.getNormalizedPriceOut(inToken, outToken, amountIn);
    }

    function getNormPriceIn(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountOut
    ) internal view returns (uint256 amountIn) {
        (amountIn, ) = priceFeed.getNormalizedPriceIn(inToken, outToken, amountOut);
    }

    function normExchangeFromExact(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath,
        uint256 minAmountOut
    ) internal returns (uint256) {
        return
            priceFeed.normalizedExchangeFromExact(
                inToken,
                outToken,
                amountIn,
                optionalPath,
                minAmountOut
            );
    }

    function normExchangeToExact(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath,
        uint256 maxAmountIn
    ) internal returns (uint256) {
        return
            priceFeed.normalizedExchangeToExact(
                inToken,
                outToken,
                amountOut,
                optionalPath,
                maxAmountIn
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../../libs/TokenBalance.sol";

library TraderPoolPrice {
    using EnumerableSet for EnumerableSet.AddressSet;
    using TokenBalance for address;

    function getNormalizedPoolPriceAndPositions(ITraderPool.PoolParameters storage poolParameters)
        public
        view
        returns (
            uint256 totalPriceInBase,
            uint256 currentBaseAmount,
            address[] memory positionTokens,
            uint256[] memory positionPricesInBase
        )
    {
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        address[] memory openPositions = ITraderPool(address(this)).openPositions();
        totalPriceInBase = currentBaseAmount = poolParameters.baseToken.normThisBalance();

        positionTokens = new address[](openPositions.length);
        positionPricesInBase = new uint256[](openPositions.length);

        for (uint256 i = 0; i < openPositions.length; i++) {
            positionTokens[i] = openPositions[i];

            (positionPricesInBase[i], ) = priceFeed.getNormalizedPriceOut(
                positionTokens[i],
                poolParameters.baseToken,
                positionTokens[i].normThisBalance()
            );

            totalPriceInBase += positionPricesInBase[i];
        }
    }

    function getNormalizedPoolPriceAndUSD(ITraderPool.PoolParameters storage poolParameters)
        external
        view
        returns (uint256 totalBase, uint256 totalUSD)
    {
        (totalBase, , , ) = getNormalizedPoolPriceAndPositions(poolParameters);

        (totalUSD, ) = ITraderPool(address(this)).priceFeed().getNormalizedPriceOutUSD(
            poolParameters.baseToken,
            totalBase
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/trader/ITraderPoolProposal.sol";
import "../../interfaces/core/IPriceFeed.sol";
import "../../interfaces/core/ICoreProperties.sol";

import "./TraderPoolPrice.sol";
import "../../libs/MathHelper.sol";

library TraderPoolLeverage {
    using MathHelper for uint256;
    using TraderPoolPrice for ITraderPool.PoolParameters;

    function _getNormalizedLeveragePoolPriceInUSD(
        ITraderPool.PoolParameters storage poolParameters
    ) internal view returns (uint256 totalInUSD, uint256 traderInUSD) {
        address trader = poolParameters.trader;
        address proposalPool = ITraderPool(address(this)).proposalPoolAddress();
        uint256 totalEmission = ITraderPool(address(this)).totalEmission();
        uint256 traderBalance = IERC20(address(this)).balanceOf(trader);

        (, totalInUSD) = poolParameters.getNormalizedPoolPriceAndUSD();

        if (proposalPool != address(0)) {
            totalInUSD += ITraderPoolProposal(proposalPool).getInvestedBaseInUSD();
            traderBalance += ITraderPoolProposal(proposalPool).totalLPBalances(trader);
        }

        if (totalEmission > 0) {
            traderInUSD = totalInUSD.ratio(traderBalance, totalEmission);
        }
    }

    function getMaxTraderLeverage(ITraderPool.PoolParameters storage poolParameters)
        public
        view
        returns (uint256 totalTokensUSD, uint256 maxTraderLeverageUSDTokens)
    {
        uint256 traderUSDTokens;

        (totalTokensUSD, traderUSDTokens) = _getNormalizedLeveragePoolPriceInUSD(poolParameters);
        (uint256 threshold, uint256 slope) = ITraderPool(address(this))
            .coreProperties()
            .getTraderLeverageParams();

        int256 traderUSD = int256(traderUSDTokens / DECIMALS);
        int256 multiplier = traderUSD / int256(threshold);

        int256 numerator = int256(threshold) +
            ((multiplier + 1) * (2 * traderUSD - int256(threshold))) -
            (multiplier * multiplier * int256(threshold));

        int256 boost = traderUSD * 2;

        maxTraderLeverageUSDTokens = uint256((numerator / int256(slope) + boost)) * DECIMALS;
    }

    function checkLeverage(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 amountInBaseToInvest
    ) external view {
        if (msg.sender == poolParameters.trader) {
            return;
        }

        (uint256 totalPriceInUSD, uint256 maxTraderVolumeInUSD) = getMaxTraderLeverage(
            poolParameters
        );
        (uint256 addInUSD, ) = ITraderPool(address(this)).priceFeed().getNormalizedPriceOutUSD(
            poolParameters.baseToken,
            amountInBaseToInvest
        );

        require(
            addInUSD + totalPriceInUSD <= maxTraderVolumeInUSD,
            "TP: exchange exceeds leverage"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../interfaces/insurance/IInsurance.sol";
import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/ICoreProperties.sol";

import "../../trader/TraderPool.sol";

import "../../libs/MathHelper.sol";
import "../../libs/TokenBalance.sol";

library TraderPoolCommission {
    using DecimalsConverter for uint256;
    using MathHelper for uint256;
    using SafeERC20 for IERC20;
    using TokenBalance for address;

    function _calculateInvestorCommission(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 investorBaseAmount,
        uint256 investorLPAmount,
        uint256 investedBaseAmount
    ) internal view returns (uint256 baseCommission, uint256 lpCommission) {
        if (investorBaseAmount > investedBaseAmount) {
            baseCommission = (investorBaseAmount - investedBaseAmount).percentage(
                poolParameters.commissionPercentage
            );
            lpCommission = investorLPAmount.ratio(baseCommission, investorBaseAmount);
        }
    }

    function nextCommissionEpoch(ITraderPool.PoolParameters storage poolParameters)
        public
        view
        returns (uint256)
    {
        return
            ITraderPool(address(this)).coreProperties().getCommissionEpochByTimestamp(
                block.timestamp,
                poolParameters.commissionPeriod
            );
    }

    function calculateCommissionOnReinvest(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 oldTotalSupply
    )
        external
        view
        returns (
            uint256 investorBaseAmount,
            uint256 baseCommission,
            uint256 lpCommission
        )
    {
        if (oldTotalSupply > 0) {
            uint256 investorBalance = IERC20(address(this)).balanceOf(investor);
            uint256 baseTokenBalance = poolParameters.baseToken.normThisBalance();

            investorBaseAmount = baseTokenBalance.ratio(investorBalance, oldTotalSupply);

            (baseCommission, lpCommission) = calculateCommissionOnDivest(
                poolParameters,
                investor,
                investorBaseAmount,
                investorBalance
            );
        }
    }

    function calculateCommissionOnDivest(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 investorBaseAmount,
        uint256 amountLP
    ) public view returns (uint256 baseCommission, uint256 lpCommission) {
        uint256 balance = IERC20(address(this)).balanceOf(investor);

        if (balance > 0) {
            (uint256 investedBase, ) = TraderPool(address(this)).investorsInfo(investor);
            investedBase = investedBase.ratio(amountLP, balance);

            (baseCommission, lpCommission) = _calculateInvestorCommission(
                poolParameters,
                investorBaseAmount,
                amountLP,
                investedBase
            );
        }
    }

    function calculateDexeCommission(
        uint256 baseToDistribute,
        uint256 lpToDistribute,
        uint256 dexePercentage
    ) external pure returns (uint256 lpCommission, uint256 baseCommission) {
        lpCommission = lpToDistribute.percentage(dexePercentage);
        baseCommission = baseToDistribute.percentage(dexePercentage);
    }

    function sendDexeCommission(
        IERC20 dexeToken,
        uint256 dexeCommission,
        uint256[] calldata poolPercentages,
        address[3] calldata commissionReceivers
    ) external {
        uint256[] memory receivedCommissions = new uint256[](3);
        uint256 dexeDecimals = ERC20(address(dexeToken)).decimals();

        for (uint256 i = 0; i < commissionReceivers.length; i++) {
            receivedCommissions[i] = dexeCommission.percentage(poolPercentages[i]);
            dexeToken.safeTransfer(
                commissionReceivers[i],
                receivedCommissions[i].from18(dexeDecimals)
            );
        }

        uint256 insurance = uint256(ICoreProperties.CommissionTypes.INSURANCE);

        IInsurance(commissionReceivers[insurance]).receiveDexeFromPools(
            receivedCommissions[insurance]
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/IPriceFeed.sol";
import "../../interfaces/core/ICoreProperties.sol";

import "../PriceFeed/PriceFeedLocal.sol";
import "../TokenBalance.sol";

library TraderPoolExchange {
    using EnumerableSet for EnumerableSet.AddressSet;
    using PriceFeedLocal for IPriceFeed;
    using TokenBalance for address;

    event Exchanged(
        address sender,
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event PositionClosed(address position);

    function _checkThisBalance(uint256 amount, address token) internal view {
        require(amount <= token.normThisBalance(), "TP: invalid exchange amount");
    }

    function exchange(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage positions,
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ITraderPool.ExchangeType exType
    ) external {
        ICoreProperties coreProperties = ITraderPool(address(this)).coreProperties();
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();

        require(from != to, "TP: ambiguous exchange");
        require(
            !coreProperties.isBlacklistedToken(from) && !coreProperties.isBlacklistedToken(to),
            "TP: blacklisted token"
        );
        require(
            from == poolParameters.baseToken || positions.contains(from),
            "TP: invalid exchange address"
        );

        priceFeed.checkAllowance(from);
        priceFeed.checkAllowance(to);

        if (to != poolParameters.baseToken) {
            positions.add(to);
        }

        uint256 amountGot;

        if (exType == ITraderPool.ExchangeType.FROM_EXACT) {
            _checkThisBalance(amount, from);
            amountGot = priceFeed.normExchangeFromExact(
                from,
                to,
                amount,
                optionalPath,
                amountBound
            );
        } else {
            _checkThisBalance(amountBound, from);
            amountGot = priceFeed.normExchangeToExact(from, to, amount, optionalPath, amountBound);

            (amount, amountGot) = (amountGot, amount);
        }

        emit Exchanged(msg.sender, from, to, amount, amountGot);

        if (from != poolParameters.baseToken && from.thisBalance() == 0) {
            positions.remove(from);

            emit PositionClosed(from);
        }

        require(
            positions.length() <= coreProperties.getMaximumOpenPositions(),
            "TP: max positions"
        );
    }

    function getExchangeAmount(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage positions,
        address from,
        address to,
        uint256 amount,
        address[] calldata optionalPath,
        ITraderPool.ExchangeType exType
    ) external view returns (uint256, address[] memory) {
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        ICoreProperties coreProperties = ITraderPool(address(this)).coreProperties();

        if (coreProperties.isBlacklistedToken(from) || coreProperties.isBlacklistedToken(to)) {
            return (0, new address[](0));
        }

        if (from == to || (from != poolParameters.baseToken && !positions.contains(from))) {
            return (0, new address[](0));
        }

        return
            exType == ITraderPool.ExchangeType.FROM_EXACT
                ? priceFeed.getNormalizedExtendedPriceOut(from, to, amount, optionalPath)
                : priceFeed.getNormalizedExtendedPriceIn(from, to, amount, optionalPath);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../../trader/TraderPool.sol";

import "./TraderPoolPrice.sol";
import "./TraderPoolCommission.sol";
import "./TraderPoolLeverage.sol";
import "../MathHelper.sol";
import "../TokenBalance.sol";
import "../PriceFeed/PriceFeedLocal.sol";

library TraderPoolView {
    using EnumerableSet for EnumerableSet.AddressSet;
    using TraderPoolPrice for ITraderPool.PoolParameters;
    using TraderPoolPrice for address;
    using TraderPoolCommission for ITraderPool.PoolParameters;
    using TraderPoolLeverage for ITraderPool.PoolParameters;
    using DecimalsConverter for uint256;
    using MathHelper for uint256;
    using Math for uint256;
    using TokenBalance for address;
    using PriceFeedLocal for IPriceFeed;

    function _getTraderAndPlatformCommissions(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 baseCommission,
        uint256 lpCommission
    ) internal view returns (ITraderPool.Commissions memory commissions) {
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        (uint256 dexePercentage, , ) = ITraderPool(address(this))
            .coreProperties()
            .getDEXECommissionPercentages();

        (uint256 usdCommission, ) = priceFeed.getNormalizedPriceOutUSD(
            poolParameters.baseToken,
            baseCommission
        );

        commissions.dexeBaseCommission = baseCommission.percentage(dexePercentage);
        commissions.dexeLPCommission = lpCommission.percentage(dexePercentage);
        commissions.dexeUSDCommission = usdCommission.percentage(dexePercentage);

        commissions.traderBaseCommission = baseCommission - commissions.dexeBaseCommission;
        commissions.traderLPCommission = lpCommission - commissions.dexeLPCommission;
        commissions.traderUSDCommission = usdCommission - commissions.dexeUSDCommission;

        (commissions.dexeDexeCommission, ) = priceFeed.getNormalizedPriceOutDEXE(
            poolParameters.baseToken,
            commissions.dexeBaseCommission
        );
    }

    function getInvestTokens(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 amountInBaseToInvest
    ) external view returns (ITraderPool.Receptions memory receptions) {
        (
            uint256 totalBase,
            uint256 currentBaseAmount,
            address[] memory positionTokens,
            uint256[] memory positionPricesInBase
        ) = poolParameters.getNormalizedPoolPriceAndPositions();

        receptions.lpAmount = amountInBaseToInvest;
        receptions.positions = positionTokens;
        receptions.givenAmounts = new uint256[](positionTokens.length);
        receptions.receivedAmounts = new uint256[](positionTokens.length);

        if (totalBase > 0) {
            receptions.baseAmount = currentBaseAmount.ratio(amountInBaseToInvest, totalBase);
            receptions.lpAmount = receptions.lpAmount.ratio(
                IERC20(address(this)).totalSupply(),
                totalBase
            );
        }

        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();

        for (uint256 i = 0; i < positionTokens.length; i++) {
            receptions.givenAmounts[i] = positionPricesInBase[i].ratio(
                amountInBaseToInvest,
                totalBase
            );
            receptions.receivedAmounts[i] = priceFeed.getNormPriceOut(
                poolParameters.baseToken,
                positionTokens[i],
                receptions.givenAmounts[i]
            );
        }
    }

    function _getReinvestCommission(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 totalPoolBase,
        uint256 totalSupply
    ) internal view returns (uint256 baseCommission, uint256 lpCommission) {
        (, uint256 commissionUnlockEpoch) = TraderPool(address(this)).investorsInfo(investor);

        if (poolParameters.nextCommissionEpoch() > commissionUnlockEpoch) {
            uint256 lpBalance = IERC20(address(this)).balanceOf(investor);
            uint256 baseShare = totalPoolBase.ratio(lpBalance, totalSupply);

            (baseCommission, lpCommission) = poolParameters.calculateCommissionOnDivest(
                investor,
                baseShare,
                lpBalance
            );
        }
    }

    function getReinvestCommissions(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage investors,
        uint256[] calldata offsetLimits
    ) external view returns (ITraderPool.Commissions memory commissions) {
        (uint256 totalPoolBase, ) = poolParameters.getNormalizedPoolPriceAndUSD();
        uint256 totalSupply = IERC20(address(this)).totalSupply();

        uint256 allBaseCommission;
        uint256 allLPCommission;

        for (uint256 i = 0; i < offsetLimits.length; i += 2) {
            uint256 to = (offsetLimits[i] + offsetLimits[i + 1]).min(investors.length()).max(
                offsetLimits[i]
            );

            for (uint256 j = offsetLimits[i]; j < to; j++) {
                address investor = investors.at(j);

                (uint256 baseCommission, uint256 lpCommission) = _getReinvestCommission(
                    poolParameters,
                    investor,
                    totalPoolBase,
                    totalSupply
                );

                allBaseCommission += baseCommission;
                allLPCommission += lpCommission;
            }
        }

        return
            _getTraderAndPlatformCommissions(poolParameters, allBaseCommission, allLPCommission);
    }

    function getDivestAmountsAndCommissions(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 amountLP
    )
        external
        view
        returns (
            ITraderPool.Receptions memory receptions,
            ITraderPool.Commissions memory commissions
        )
    {
        ERC20 baseToken = ERC20(poolParameters.baseToken);
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        address[] memory openPositions = ITraderPool(address(this)).openPositions();

        uint256 totalSupply = IERC20(address(this)).totalSupply();

        receptions.positions = new address[](openPositions.length);
        receptions.givenAmounts = new uint256[](openPositions.length);
        receptions.receivedAmounts = new uint256[](openPositions.length);

        if (totalSupply > 0) {
            receptions.baseAmount = baseToken
                .balanceOf(address(this))
                .ratio(amountLP, totalSupply)
                .to18(baseToken.decimals());

            for (uint256 i = 0; i < openPositions.length; i++) {
                receptions.positions[i] = openPositions[i];
                receptions.givenAmounts[i] = ERC20(receptions.positions[i])
                    .balanceOf(address(this))
                    .ratio(amountLP, totalSupply)
                    .to18(ERC20(receptions.positions[i]).decimals());

                receptions.receivedAmounts[i] = priceFeed.getNormPriceOut(
                    receptions.positions[i],
                    address(baseToken),
                    receptions.givenAmounts[i]
                );
                receptions.baseAmount += receptions.receivedAmounts[i];
            }

            if (investor != poolParameters.trader) {
                (uint256 baseCommission, uint256 lpCommission) = poolParameters
                    .calculateCommissionOnDivest(investor, receptions.baseAmount, amountLP);

                commissions = _getTraderAndPlatformCommissions(
                    poolParameters,
                    baseCommission,
                    lpCommission
                );
            }
        }
    }

    function getLeverageInfo(ITraderPool.PoolParameters storage poolParameters)
        public
        view
        returns (ITraderPool.LeverageInfo memory leverageInfo)
    {
        (
            leverageInfo.totalPoolUSDWithProposals,
            leverageInfo.traderLeverageUSDTokens
        ) = poolParameters.getMaxTraderLeverage();

        if (leverageInfo.traderLeverageUSDTokens > leverageInfo.totalPoolUSDWithProposals) {
            leverageInfo.freeLeverageUSD =
                leverageInfo.traderLeverageUSDTokens -
                leverageInfo.totalPoolUSDWithProposals;
            (leverageInfo.freeLeverageBase, ) = ITraderPool(address(this))
                .priceFeed()
                .getNormalizedPriceInUSD(poolParameters.baseToken, leverageInfo.freeLeverageUSD);
        }
    }

    function _getUserInfo(
        ITraderPool.PoolParameters storage poolParameters,
        address user,
        uint256 totalPoolBase,
        uint256 totalPoolUSD,
        uint256 totalSupply,
        ICoreProperties.CommissionPeriod commissionPeriod
    ) internal view returns (ITraderPool.UserInfo memory userInfo) {
        ICoreProperties coreProperties = ITraderPool(address(this)).coreProperties();

        userInfo.poolLPBalance = IERC20(address(this)).balanceOf(user);
        (userInfo.investedBase, userInfo.commissionUnlockTimestamp) = TraderPool(address(this))
            .investorsInfo(user);

        if (totalSupply > 0) {
            userInfo.poolUSDShare = totalPoolUSD.ratio(userInfo.poolLPBalance, totalSupply);
            userInfo.poolBaseShare = totalPoolBase.ratio(userInfo.poolLPBalance, totalSupply);

            if (userInfo.commissionUnlockTimestamp > 0) {
                (userInfo.owedBaseCommission, userInfo.owedLPCommission) = poolParameters
                    .calculateCommissionOnDivest(
                        user,
                        userInfo.poolBaseShare,
                        userInfo.poolLPBalance
                    );
            }
        }

        userInfo.commissionUnlockTimestamp = userInfo.commissionUnlockTimestamp == 0
            ? coreProperties.getCommissionEpochByTimestamp(block.timestamp, commissionPeriod)
            : userInfo.commissionUnlockTimestamp;

        userInfo.commissionUnlockTimestamp = coreProperties.getCommissionTimestampByEpoch(
            userInfo.commissionUnlockTimestamp,
            commissionPeriod
        );
    }

    function getUsersInfo(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage investors,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPool.UserInfo[] memory usersInfo) {
        uint256 to = (offset + limit).min(investors.length()).max(offset);
        (uint256 totalPoolBase, uint256 totalPoolUSD) = poolParameters
            .getNormalizedPoolPriceAndUSD();
        uint256 totalSupply = IERC20(address(this)).totalSupply();

        usersInfo = new ITraderPool.UserInfo[](to - offset + 1);

        usersInfo[0] = _getUserInfo(
            poolParameters,
            poolParameters.trader,
            totalPoolBase,
            totalPoolUSD,
            totalSupply,
            poolParameters.commissionPeriod
        );

        for (uint256 i = offset; i < to; i++) {
            usersInfo[i - offset + 1] = _getUserInfo(
                poolParameters,
                investors.at(i),
                totalPoolBase,
                totalPoolUSD,
                totalSupply,
                poolParameters.commissionPeriod
            );
        }
    }

    function getPoolInfo(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage positions
    ) external view returns (ITraderPool.PoolInfo memory poolInfo) {
        poolInfo.ticker = ERC20(address(this)).symbol();
        poolInfo.name = ERC20(address(this)).name();

        poolInfo.parameters = poolParameters;
        poolInfo.openPositions = ITraderPool(address(this)).openPositions();

        poolInfo.baseAndPositionBalances = new uint256[](poolInfo.openPositions.length + 1);
        poolInfo.baseAndPositionBalances[0] = poolInfo.parameters.baseToken.normThisBalance();

        for (uint256 i = 0; i < poolInfo.openPositions.length; i++) {
            poolInfo.baseAndPositionBalances[i + 1] = poolInfo.openPositions[i].normThisBalance();
        }

        poolInfo.totalBlacklistedPositions = positions.length() - poolInfo.openPositions.length;
        poolInfo.totalInvestors = ITraderPool(address(this)).totalInvestors();

        (poolInfo.totalPoolBase, poolInfo.totalPoolUSD) = poolParameters
            .getNormalizedPoolPriceAndUSD();

        poolInfo.lpSupply = IERC20(address(this)).totalSupply();
        poolInfo.lpLockedInProposals =
            ITraderPool(address(this)).totalEmission() -
            poolInfo.lpSupply;

        if (poolInfo.lpSupply > 0) {
            poolInfo.traderLPBalance = IERC20(address(this)).balanceOf(poolParameters.trader);
            poolInfo.traderUSD = poolInfo.totalPoolUSD.ratio(
                poolInfo.traderLPBalance,
                poolInfo.lpSupply
            );
            poolInfo.traderBase = poolInfo.totalPoolBase.ratio(
                poolInfo.traderLPBalance,
                poolInfo.lpSupply
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

library TokenBalance {
    using DecimalsConverter for uint256;

    function normThisBalance(address token) internal view returns (uint256) {
        return IERC20(token).balanceOf(address(this)).to18(ERC20(token).decimals());
    }

    function thisBalance(address token) internal view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function allowance(address owner, address spender) external view returns (uint256);

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolInvestorsHook.sol";
import "./ITraderPoolInvestProposal.sol";
import "./ITraderPool.sol";

/**
 * This is the second type of the pool the trader is able to create in the DEXE platform. Similar to the BasicTraderPool,
 * it inherits the functionality of the TraderPool yet differs in the proposals implementation. Investors can fund the
 * investment proposals and the trader will be able to do whetever he wants to do with the received funds
 */
interface IInvestTraderPool is ITraderPoolInvestorsHook {
    /// @notice This function returns a timestamp after which investors can start investing into the pool.
    /// The delay starts after opening the first position. Needed to minimize scam
    /// @return the timestamp after which the investment is allowed
    function getInvestDelayEnd() external view returns (uint256);

    /// @notice This function creates an investment proposal that users will be able to invest in
    /// @param descriptionURL the IPFS URL of the description document
    /// @param lpAmount the amount of LP tokens the trader will invest rightaway
    /// @param proposalLimits the certain limits this proposal will have
    /// @param minPositionsOut the amounts of base tokens received from positions to be invested into the proposal
    function createProposal(
        string calldata descriptionURL,
        uint256 lpAmount,
        ITraderPoolInvestProposal.ProposalLimits calldata proposalLimits,
        uint256[] calldata minPositionsOut
    ) external;

    /// @notice The function to invest into the proposal. Contrary to the RiskyProposal there is no percentage wise investment limit
    /// @param proposalId the id of the proposal to invest in
    /// @param lpAmount to amount of lpTokens to be invested into the proposal
    /// @param minPositionsOut the amounts of base tokens received from positions to be invested into the proposal
    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minPositionsOut
    ) external;

    /// @notice This function invests all the profit from the proposal into this pool
    /// @param proposalId the id of the proposal to take the profit from
    /// @param minPositionsOut the amounts of position tokens received on investment
    function reinvestProposal(uint256 proposalId, uint256[] calldata minPositionsOut) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolProposal.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * This is the proposal the trader is able to create for the TraderInvestPool. The proposal itself is a subpool where investors
 * can send funds to. These funds become fully controlled by the trader himself and might be withdrawn for any purposes.
 * Anyone can supply funds to this kind of proposal and the funds will be distributed proportionally between all the proposal
 * investors
 */
interface ITraderPoolInvestProposal is ITraderPoolProposal {
    /// @notice The limits of this proposal
    /// @param timestampLimit the timestamp after which the proposal will close for the investments
    /// @param investLPLimit the maximal invested amount of LP tokens after which the proposal will close
    struct ProposalLimits {
        uint256 timestampLimit;
        uint256 investLPLimit;
    }

    /// @notice The struct that stores information about the proposal
    /// @param descriptionURL the IPFS URL of the proposal's description
    /// @param proposalLimits the limits of this proposal
    /// @param lpLocked the amount of LP tokens that are locked in this proposal
    /// @param investedBase the total amount of currently invested base tokens (this should never decrease because we don't burn LP)
    /// @param newInvestedBase the total amount of newly invested base tokens that the trader can withdraw
    struct ProposalInfo {
        string descriptionURL;
        ProposalLimits proposalLimits;
        uint256 lpLocked;
        uint256 investedBase;
        uint256 newInvestedBase;
    }

    /// @notice The struct that holds extra information about this proposal
    /// @param proposalInfo the information about this proposal
    /// @param totalInvestors the number of investors currently in this proposal
    struct ProposalInfoExtended {
        ProposalInfo proposalInfo;
        uint256 totalInvestors;
    }

    /// @param cumulativeSums the helper values per rewarded token needed to calculate the investors' rewards
    /// @param rewardToken the set of rewarded token addresses
    struct RewardInfo {
        mapping(address => uint256) cumulativeSums; // with PRECISION
        EnumerableSet.AddressSet rewardTokens;
    }

    /// @notice The struct that stores the reward info about a single investor
    /// @param rewardsStored the amount of tokens the investor earned per rewarded token
    /// @param cumulativeSumsStored the helper variable needed to calculate investor's rewards per rewarded tokens
    struct UserRewardInfo {
        mapping(address => uint256) rewardsStored;
        mapping(address => uint256) cumulativeSumsStored; // with PRECISION
    }

    /// @notice The struct that is used by the TraderPoolInvestProposalView contract. It stores the information about
    /// currently active investor's proposals
    /// @param proposalId the id of the proposal
    /// @param lp2Balance investor's balance of proposal's LP tokens
    /// @param baseInvested the amount of invested base tokens by investor
    /// @param lpInvested the amount of invested LP tokens by investor
    struct ActiveInvestmentInfo {
        uint256 proposalId;
        uint256 lp2Balance;
        uint256 baseInvested;
        uint256 lpInvested;
    }

    /// @notice The struct that stores information about values of corresponding token addresses, used in the
    /// TraderPoolInvestProposalView contract
    /// @param amounts the amounts of underlying tokens
    /// @param tokens the correspoding token addresses
    struct Reception {
        uint256[] amounts;
        address[] tokens;
    }

    /// @notice The struct that is used by the TraderPoolInvestProposalView contract. It stores the information
    /// about the rewards
    /// @param totalBaseAmount is the overall value of reward tokens in usd (might not be correct due to limitations of pathfinder)
    /// @param totalBaseAmount is the overall value of reward tokens in base token (might not be correct due to limitations of pathfinder)
    /// @param baseAmountFromRewards the amount of base tokens that can be reinvested into the parent pool
    /// @param rewards the array of amounts and addresses of rewarded tokens (containts base tokens)
    struct Receptions {
        uint256 totalUsdAmount;
        uint256 totalBaseAmount;
        uint256 baseAmountFromRewards;
        Reception[] rewards;
    }

    /// @notice The function to change the proposal limits
    /// @param proposalId the id of the proposal to change
    /// @param proposalLimits the new limits for this proposal
    function changeProposalRestrictions(uint256 proposalId, ProposalLimits calldata proposalLimits)
        external;

    /// @notice The function to get the information about the proposals
    /// @param offset the starting index of the proposals array
    /// @param limit the number of proposals to observe
    /// @return proposals the information about the proposals
    function getProposalInfos(uint256 offset, uint256 limit)
        external
        view
        returns (ProposalInfoExtended[] memory proposals);

    /// @notice The function to get the information about the active proposals of this user
    /// @param user the user to observe
    /// @param offset the starting index of the users array
    /// @param limit the number of users to observe
    /// @return investments the information about the currently active investments
    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ActiveInvestmentInfo[] memory investments);

    /// @notice The function that creates proposals
    /// @param descriptionURL the IPFS URL of new description
    /// @param proposalLimits the certain limits of this proposal
    /// @param lpInvestment the amount of LP tokens invested on proposal's creation
    /// @param baseInvestment the equivalent amount of base tokens invested on proposal's creation
    /// @return proposalId the id of the created proposal
    function create(
        string calldata descriptionURL,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external returns (uint256 proposalId);

    /// @notice The function that is used to get user's rewards from the proposals
    /// @param proposalIds the array of proposals ids
    /// @param user the user to get rewards of
    /// @return receptions the information about the received rewards
    function getRewards(uint256[] calldata proposalIds, address user)
        external
        view
        returns (Receptions memory receptions);

    /// @notice The function that is used to invest into the proposal
    /// @param proposalId the id of the proposal
    /// @param user the user that invests
    /// @param lpInvestment the amount of LP tokens the user invests
    /// @param baseInvestment the equivalent amount of base tokens the user invests
    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external;

    /// @notice The function that is used to divest profit into the main pool from the specified proposal
    /// @param proposalId the id of the proposal to divest from
    /// @param user the user who divests
    /// @return the received amount of base tokens
    function divest(uint256 proposalId, address user) external returns (uint256);

    /// @notice The trader function to withdraw the invested funds to his wallet
    /// @param proposalId The id of the proposal to withdraw the funds from
    /// @param amount the amount of base tokens to withdraw (normalized)
    function withdraw(uint256 proposalId, uint256 amount) external;

    /// @notice The function to convert newly invested funds to the rewards
    /// @param proposalId the id of the proposal
    function convertInvestedBaseToDividends(uint256 proposalId) external;

    /// @notice The function to supply reward to the investors
    /// @param proposalId the id of the proposal to supply the funds to
    /// @param amounts the amounts of tokens to be supplied (normalized)
    /// @param addresses the addresses of tokens to be supplied
    function supply(
        uint256 proposalId,
        uint256[] calldata amounts,
        address[] calldata addresses
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/trader/ITraderPoolRiskyProposal.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../MathHelper.sol";
import "../PriceFeed/PriceFeedLocal.sol";

import "../../trader/TraderPoolRiskyProposal.sol";

library TraderPoolRiskyProposalView {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using MathHelper for uint256;
    using Math for uint256;
    using Address for address;
    using PriceFeedLocal for IPriceFeed;

    function getProposalInfos(
        mapping(uint256 => ITraderPoolRiskyProposal.ProposalInfo) storage proposalInfos,
        mapping(uint256 => EnumerableSet.AddressSet) storage investors,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolRiskyProposal.ProposalInfoExtended[] memory proposals) {
        uint256 to = (offset + limit)
            .min(TraderPoolRiskyProposal(address(this)).proposalsTotalNum())
            .max(offset);

        proposals = new ITraderPoolRiskyProposal.ProposalInfoExtended[](to - offset);

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();
        address baseToken = ITraderPoolRiskyProposal(address(this)).getBaseToken();

        for (uint256 i = offset; i < to; i++) {
            proposals[i - offset].proposalInfo = proposalInfos[i + 1];

            proposals[i - offset].totalProposalBase =
                proposals[i - offset].proposalInfo.balanceBase +
                priceFeed.getNormPriceOut(
                    proposals[i - offset].proposalInfo.token,
                    baseToken,
                    proposals[i - offset].proposalInfo.balancePosition
                );
            (proposals[i - offset].totalProposalUSD, ) = priceFeed.getNormalizedPriceOutUSD(
                baseToken,
                proposals[i - offset].totalProposalBase
            );
            proposals[i - offset].lp2Supply = TraderPoolRiskyProposal(address(this)).totalSupply(
                i + 1
            );
            proposals[i - offset].totalInvestors = investors[i + 1].length();
            proposals[i - offset].positionTokenPrice = priceFeed.getNormPriceIn(
                baseToken,
                proposals[i - offset].proposalInfo.token,
                DECIMALS
            );
        }
    }

    function getActiveInvestmentsInfo(
        EnumerableSet.UintSet storage activeInvestments,
        mapping(address => mapping(uint256 => uint256)) storage baseBalances,
        mapping(address => mapping(uint256 => uint256)) storage lpBalances,
        mapping(uint256 => ITraderPoolRiskyProposal.ProposalInfo) storage proposalInfos,
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolRiskyProposal.ActiveInvestmentInfo[] memory investments) {
        uint256 to = (offset + limit).min(activeInvestments.length()).max(offset);

        investments = new ITraderPoolRiskyProposal.ActiveInvestmentInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 proposalId = activeInvestments.at(i);
            uint256 balance = TraderPoolRiskyProposal(address(this)).balanceOf(user, proposalId);
            uint256 supply = TraderPoolRiskyProposal(address(this)).totalSupply(proposalId);

            investments[i - offset] = ITraderPoolRiskyProposal.ActiveInvestmentInfo(
                proposalId,
                balance,
                baseBalances[user][proposalId],
                lpBalances[user][proposalId],
                proposalInfos[proposalId].balanceBase.ratio(balance, supply),
                proposalInfos[proposalId].balancePosition.ratio(balance, supply)
            );
        }
    }

    function getUserInvestmentsLimits(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        mapping(address => mapping(uint256 => uint256)) storage lpBalances,
        address user,
        uint256[] calldata proposalIds
    ) external view returns (uint256[] memory lps) {
        lps = new uint256[](proposalIds.length);

        ITraderPoolRiskyProposal proposal = ITraderPoolRiskyProposal(address(this));
        address trader = parentTraderPoolInfo.trader;

        uint256 lpBalance = proposal.totalLPBalances(user) +
            IERC20(parentTraderPoolInfo.parentPoolAddress).balanceOf(user);

        for (uint256 i = 0; i < proposalIds.length; i++) {
            if (user != trader) {
                uint256 proposalId = proposalIds[i];

                uint256 maxPercentage = proposal.getInvestmentPercentage(proposalId, trader, 0);
                uint256 maxInvestment = lpBalance.percentage(maxPercentage);

                lps[i] = maxInvestment > lpBalances[user][proposalId]
                    ? maxInvestment - lpBalances[user][proposalId]
                    : 0;
            } else {
                lps[i] = MAX_UINT;
            }
        }
    }

    function getCreationTokens(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        address token,
        uint256 baseToExchange,
        address[] calldata optionalPath
    )
        external
        view
        returns (
            uint256 positionTokens,
            uint256 positionTokenPrice,
            address[] memory path
        )
    {
        address baseToken = parentTraderPoolInfo.baseToken;

        if (!token.isContract() || token == baseToken) {
            return (0, 0, new address[](0));
        }

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();

        (positionTokens, path) = priceFeed.getNormalizedExtendedPriceOut(
            baseToken,
            token,
            baseToExchange,
            optionalPath
        );
        (positionTokenPrice, ) = priceFeed.getNormalizedExtendedPriceIn(
            baseToken,
            token,
            DECIMALS,
            optionalPath
        );
    }

    function getInvestTokens(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        ITraderPoolRiskyProposal.ProposalInfo storage info,
        uint256 proposalId,
        uint256 baseInvestment
    )
        external
        view
        returns (
            uint256 baseAmount,
            uint256 positionAmount,
            uint256 lp2Amount
        )
    {
        if (proposalId > TraderPoolRiskyProposal(address(this)).proposalsTotalNum()) {
            return (0, 0, 0);
        }

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();
        uint256 tokensPrice = priceFeed.getNormPriceOut(
            info.token,
            parentTraderPoolInfo.baseToken,
            info.balancePosition
        );
        uint256 totalBase = tokensPrice + info.balanceBase;

        lp2Amount = baseInvestment;
        baseAmount = baseInvestment;

        if (totalBase > 0) {
            uint256 baseToExchange = baseInvestment.ratio(tokensPrice, totalBase);

            baseAmount = baseInvestment - baseToExchange;
            positionAmount = priceFeed.getNormPriceOut(
                parentTraderPoolInfo.baseToken,
                info.token,
                baseToExchange
            );
            lp2Amount = lp2Amount.ratio(
                TraderPoolRiskyProposal(address(this)).totalSupply(proposalId),
                totalBase
            );
        }
    }

    function getDivestAmounts(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        mapping(uint256 => ITraderPoolRiskyProposal.ProposalInfo) storage proposalInfos,
        uint256[] calldata proposalIds,
        uint256[] calldata lp2s
    ) external view returns (ITraderPoolRiskyProposal.Receptions memory receptions) {
        receptions.positions = new address[](proposalIds.length);
        receptions.givenAmounts = new uint256[](proposalIds.length);
        receptions.receivedAmounts = new uint256[](proposalIds.length);

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();
        uint256 proposalsTotalNum = TraderPoolRiskyProposal(address(this)).proposalsTotalNum();

        for (uint256 i = 0; i < proposalIds.length; i++) {
            uint256 proposalId = proposalIds[i];

            if (proposalId > proposalsTotalNum) {
                continue;
            }

            uint256 propSupply = TraderPoolRiskyProposal(address(this)).totalSupply(proposalId);

            if (propSupply > 0) {
                receptions.positions[i] = proposalInfos[proposalId].token;
                receptions.givenAmounts[i] = proposalInfos[proposalId].balancePosition.ratio(
                    lp2s[i],
                    propSupply
                );
                receptions.receivedAmounts[i] = priceFeed.getNormPriceOut(
                    proposalInfos[proposalId].token,
                    parentTraderPoolInfo.baseToken,
                    receptions.givenAmounts[i]
                );

                receptions.baseAmount +=
                    proposalInfos[proposalId].balanceBase.ratio(lp2s[i], propSupply) +
                    receptions.receivedAmounts[i];
            }
        }
    }

    function getExchangeAmount(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        address positionToken,
        uint256 proposalId,
        address from,
        uint256 amount,
        address[] calldata optionalPath,
        ITraderPoolRiskyProposal.ExchangeType exType
    ) external view returns (uint256, address[] memory) {
        if (proposalId > TraderPoolRiskyProposal(address(this)).proposalsTotalNum()) {
            return (0, new address[](0));
        }

        address baseToken = parentTraderPoolInfo.baseToken;
        address to;

        if (from != baseToken && from != positionToken) {
            return (0, new address[](0));
        }

        if (from == baseToken) {
            to = positionToken;
        } else {
            to = baseToken;
        }

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();

        return
            exType == ITraderPoolRiskyProposal.ExchangeType.FROM_EXACT
                ? priceFeed.getNormalizedExtendedPriceOut(from, to, amount, optionalPath)
                : priceFeed.getNormalizedExtendedPriceIn(from, to, amount, optionalPath);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../interfaces/core/IPriceFeed.sol";
import "../interfaces/trader/ITraderPoolProposal.sol";
import "../interfaces/trader/ITraderPoolInvestorsHook.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/MathHelper.sol";

import "./TraderPool.sol";

abstract contract TraderPoolProposal is
    ITraderPoolProposal,
    ERC1155SupplyUpgradeable,
    AbstractDependant
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using MathHelper for uint256;
    using DecimalsConverter for uint256;
    using Math for uint256;

    ParentTraderPoolInfo internal _parentTraderPoolInfo;

    IPriceFeed public override priceFeed;

    uint256 public proposalsTotalNum;

    uint256 public override totalLockedLP;
    uint256 public override investedBase;

    mapping(uint256 => EnumerableSet.AddressSet) internal _investors; // proposal id => investors

    mapping(address => EnumerableSet.UintSet) internal _activeInvestments; // user => proposals
    mapping(address => mapping(uint256 => uint256)) internal _baseBalances; // user => proposal id => base invested
    mapping(address => mapping(uint256 => uint256)) internal _lpBalances; // user => proposal id => LP invested
    mapping(address => uint256) public override totalLPBalances; // user => LP invested

    event ProposalRestrictionsChanged(uint256 proposalId, address sender);
    event ProposalInvestorAdded(uint256 proposalId, address investor);
    event ProposalInvestorRemoved(uint256 proposalId, address investor);
    event ProposalInvested(
        uint256 proposalId,
        address user,
        uint256 investedLP,
        uint256 investedBase,
        uint256 receivedLP2
    );
    event ProposalDivested(
        uint256 proposalId,
        address user,
        uint256 divestedLP2,
        uint256 receivedLP,
        uint256 receivedBase
    );

    modifier onlyParentTraderPool() {
        _onlyParentTraderPool();
        _;
    }

    function _onlyParentTraderPool() internal view {
        require(_msgSender() == _parentTraderPoolInfo.parentPoolAddress, "TPP: not a ParentPool");
    }

    modifier onlyTraderAdmin() {
        _onlyTraderAdmin();
        _;
    }

    function _onlyTraderAdmin() internal view {
        require(
            TraderPool(_parentTraderPoolInfo.parentPoolAddress).isTraderAdmin(_msgSender()),
            "TPP: not a trader admin"
        );
    }

    function __TraderPoolProposal_init(ParentTraderPoolInfo calldata parentTraderPoolInfo)
        public
        onlyInitializing
    {
        __ERC1155Supply_init();

        _parentTraderPoolInfo = parentTraderPoolInfo;

        IERC20(parentTraderPoolInfo.baseToken).safeApprove(
            parentTraderPoolInfo.parentPoolAddress,
            MAX_UINT
        );
    }

    function setDependencies(address contractsRegistry) external override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        priceFeed = IPriceFeed(registry.getPriceFeedContract());
    }

    function getBaseToken() external view override returns (address) {
        return _parentTraderPoolInfo.baseToken;
    }

    function getInvestedBaseInUSD() external view override returns (uint256 investedBaseUSD) {
        (investedBaseUSD, ) = priceFeed.getNormalizedPriceOutUSD(
            _parentTraderPoolInfo.baseToken,
            investedBase
        );
    }

    function getTotalActiveInvestments(address user) external view override returns (uint256) {
        return _activeInvestments[user].length();
    }

    function _baseInProposal(uint256 proposalId) internal view virtual returns (uint256);

    function _transferAndMintLP(
        uint256 proposalId,
        address to,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) internal {
        IERC20(_parentTraderPoolInfo.baseToken).safeTransferFrom(
            _parentTraderPoolInfo.parentPoolAddress,
            address(this),
            baseInvestment.from18(_parentTraderPoolInfo.baseTokenDecimals)
        );

        uint256 baseInProposal = _baseInProposal(proposalId);
        uint256 toMint = baseInvestment;

        if (baseInProposal > 0) {
            toMint = toMint.ratio(totalSupply(proposalId), baseInProposal);
        }

        totalLockedLP += lpInvestment;
        investedBase += baseInvestment;

        _mint(to, proposalId, toMint, "");
        _updateTo(to, proposalId, toMint, lpInvestment, baseInvestment);
    }

    function _updateFromData(
        address user,
        uint256 proposalId,
        uint256 lp2Amount
    ) internal returns (uint256 lpTransfer, uint256 baseTransfer) {
        uint256 baseBalance = _baseBalances[user][proposalId];
        uint256 lpBalance = _lpBalances[user][proposalId];

        baseTransfer = baseBalance.ratio(lp2Amount, balanceOf(user, proposalId)).min(baseBalance);
        lpTransfer = lpBalance.ratio(lp2Amount, balanceOf(user, proposalId)).min(lpBalance);

        _baseBalances[user][proposalId] -= baseTransfer;
        _lpBalances[user][proposalId] -= lpTransfer;
        totalLPBalances[user] -= lpTransfer;
    }

    function _updateToData(
        address user,
        uint256 proposalId,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal {
        _activeInvestments[user].add(proposalId);

        _baseBalances[user][proposalId] += baseAmount;
        _lpBalances[user][proposalId] += lpAmount;
        totalLPBalances[user] += lpAmount;
    }

    function _checkRemoveInvestor(
        address user,
        uint256 proposalId,
        uint256 lp2Amount
    ) internal {
        if (balanceOf(user, proposalId) == lp2Amount) {
            _activeInvestments[user].remove(proposalId);

            if (user != _parentTraderPoolInfo.trader) {
                _investors[proposalId].remove(user);

                if (_activeInvestments[user].length() == 0) {
                    ITraderPoolInvestorsHook(_parentTraderPoolInfo.parentPoolAddress)
                        .checkRemoveInvestor(user);
                }

                emit ProposalInvestorRemoved(proposalId, user);
            }
        }
    }

    function _checkNewInvestor(address user, uint256 proposalId) internal {
        if (user != _parentTraderPoolInfo.trader && !_investors[proposalId].contains(user)) {
            _investors[proposalId].add(user);
            ITraderPoolInvestorsHook(_parentTraderPoolInfo.parentPoolAddress).checkNewInvestor(
                user
            );

            emit ProposalInvestorAdded(proposalId, user);
        }
    }

    function _updateFrom(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        bool isTransfer
    ) internal virtual returns (uint256 lpTransfer, uint256 baseTransfer) {
        (lpTransfer, baseTransfer) = _updateFromData(user, proposalId, lp2Amount);

        if (isTransfer) {
            emit ProposalDivested(proposalId, user, lp2Amount, lpTransfer, baseTransfer);
        }

        _checkRemoveInvestor(user, proposalId, lp2Amount);
    }

    function _updateTo(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal virtual {
        _checkNewInvestor(user, proposalId);
        _updateToData(user, proposalId, lpAmount, baseAmount);

        emit ProposalInvested(proposalId, user, lpAmount, baseAmount, lp2Amount);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "TPP: 0 transfer");

            if (from != address(0) && to != address(0) && to != from) {
                (uint256 lpTransfer, uint256 baseTransfer) = _updateFrom(
                    from,
                    ids[i],
                    amounts[i],
                    true
                );
                _updateTo(to, ids[i], amounts[i], lpTransfer, baseTransfer);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155SupplyUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Supply_init() internal onlyInitializing {
    }

    function __ERC1155Supply_init_unchained() internal onlyInitializing {
    }
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155SupplyUpgradeable.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155Upgradeable.sol";
import "./IERC1155ReceiverUpgradeable.sol";
import "./extensions/IERC1155MetadataURIUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 *  @notice A simple library to reverse common arrays
 */
library ArrayHelper {
    function reverse(uint256[] memory arr) internal pure returns (uint256[] memory reversed) {
        reversed = new uint256[](arr.length);
        uint256 i = arr.length;

        while (i > 0) {
            i--;
            reversed[arr.length - 1 - i] = arr[i];
        }
    }

    function reverse(address[] memory arr) internal pure returns (address[] memory reversed) {
        reversed = new address[](arr.length);
        uint256 i = arr.length;

        while (i > 0) {
            i--;
            reversed[arr.length - 1 - i] = arr[i];
        }
    }

    function asArray(address elem) internal pure returns (address[] memory array) {
        array = new address[](1);
        array[0] = elem;
    }

    function asArray(uint256 elem) internal pure returns (uint256[] memory array) {
        array = new uint256[](1);
        array[0] = elem;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/trader/ITraderPoolInvestProposal.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../PriceFeed/PriceFeedLocal.sol";
import "../../libs/MathHelper.sol";

import "../../trader/TraderPoolInvestProposal.sol";

library TraderPoolInvestProposalView {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using MathHelper for uint256;
    using Math for uint256;
    using PriceFeedLocal for IPriceFeed;

    function getProposalInfos(
        mapping(uint256 => ITraderPoolInvestProposal.ProposalInfo) storage proposalInfos,
        mapping(uint256 => EnumerableSet.AddressSet) storage investors,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolInvestProposal.ProposalInfoExtended[] memory proposals) {
        uint256 to = (offset + limit)
            .min(TraderPoolInvestProposal(address(this)).proposalsTotalNum())
            .max(offset);

        proposals = new ITraderPoolInvestProposal.ProposalInfoExtended[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            proposals[i - offset].proposalInfo = proposalInfos[i + 1];
            proposals[i - offset].totalInvestors = investors[i + 1].length();
        }
    }

    function getActiveInvestmentsInfo(
        EnumerableSet.UintSet storage activeInvestments,
        mapping(address => mapping(uint256 => uint256)) storage baseBalances,
        mapping(address => mapping(uint256 => uint256)) storage lpBalances,
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolInvestProposal.ActiveInvestmentInfo[] memory investments) {
        uint256 to = (offset + limit).min(activeInvestments.length()).max(offset);
        investments = new ITraderPoolInvestProposal.ActiveInvestmentInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 proposalId = activeInvestments.at(i);

            investments[i - offset] = ITraderPoolInvestProposal.ActiveInvestmentInfo(
                proposalId,
                TraderPoolInvestProposal(address(this)).balanceOf(user, proposalId),
                baseBalances[user][proposalId],
                lpBalances[user][proposalId]
            );
        }
    }

    function getRewards(
        mapping(uint256 => ITraderPoolInvestProposal.RewardInfo) storage rewardInfos,
        mapping(address => mapping(uint256 => ITraderPoolInvestProposal.UserRewardInfo))
            storage userRewardInfos,
        uint256[] calldata proposalIds,
        address user
    ) external view returns (ITraderPoolInvestProposal.Receptions memory receptions) {
        receptions.rewards = new ITraderPoolInvestProposal.Reception[](proposalIds.length);

        IPriceFeed priceFeed = ITraderPoolInvestProposal(address(this)).priceFeed();
        uint256 proposalsTotalNum = TraderPoolInvestProposal(address(this)).proposalsTotalNum();
        address baseToken = ITraderPoolInvestProposal(address(this)).getBaseToken();

        for (uint256 i = 0; i < proposalIds.length; i++) {
            uint256 proposalId = proposalIds[i];

            if (proposalId > proposalsTotalNum) {
                continue;
            }

            ITraderPoolInvestProposal.UserRewardInfo storage userRewardInfo = userRewardInfos[
                user
            ][proposalId];
            ITraderPoolInvestProposal.RewardInfo storage rewardInfo = rewardInfos[proposalId];

            uint256 balance = TraderPoolInvestProposal(address(this)).balanceOf(user, proposalId);

            receptions.rewards[i].tokens = rewardInfo.rewardTokens.values();
            receptions.rewards[i].amounts = new uint256[](receptions.rewards[i].tokens.length);

            for (uint256 j = 0; j < receptions.rewards[i].tokens.length; j++) {
                address token = receptions.rewards[i].tokens[j];

                receptions.rewards[i].amounts[j] =
                    userRewardInfo.rewardsStored[token] +
                    (rewardInfo.cumulativeSums[token] - userRewardInfo.cumulativeSumsStored[token])
                        .ratio(balance, PRECISION);

                if (token == baseToken) {
                    receptions.totalBaseAmount += receptions.rewards[i].amounts[j];
                    receptions.baseAmountFromRewards += receptions.rewards[i].amounts[j];
                } else {
                    receptions.totalBaseAmount += priceFeed.getNormPriceOut(
                        token,
                        baseToken,
                        receptions.rewards[i].amounts[j]
                    );
                }
            }

            (receptions.totalUsdAmount, ) = priceFeed.getNormalizedPriceOutUSD(
                baseToken,
                receptions.totalBaseAmount
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPool.sol";

/**
 * This is the TraderPoolRegistry contract, a tuned ContractsRegistry contract. Its purpose is the management of
 * TraderPools + proposal pools. The owner of this contract is capable of upgrading TraderPools'
 * implementation via the ProxyBeacon pattern
 */
interface ITraderPoolRegistry {
    /// @notice The function to associate an owner with the pool (called by the PoolFactory)
    /// @param user the trader of the pool
    /// @param name the type of the pool
    /// @param poolAddress the address of the new pool
    function associateUserWithPool(
        address user,
        string calldata name,
        address poolAddress
    ) external;

    /// @notice The function that counts trader's pools by their type
    /// @param user the owner of the pool
    /// @param name the type of the pool
    /// @return the total number of pools with the specified type
    function countTraderPools(address user, string calldata name) external view returns (uint256);

    /// @notice The function that lists trader pools by the provided type and user
    /// @param user the trader
    /// @param name the type of the pool
    /// @param offset the starting index of the pools array
    /// @param limit the length of the observed pools array
    /// @return pools the addresses of the pools
    function listTraderPools(
        address user,
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory pools);

    /// @notice The function that lists the pools with their static info
    /// @param name the type of the pool
    /// @param offset the the starting index of the pools array
    /// @param limit the length of the observed pools array
    /// @return pools the addresses of the pools
    /// @return poolInfos the array of static information per pool
    /// @return leverageInfos the array of trader leverage information per pool
    function listPoolsWithInfo(
        string calldata name,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            address[] memory pools,
            ITraderPool.PoolInfo[] memory poolInfos,
            ITraderPool.LeverageInfo[] memory leverageInfos
        );

    /// @notice The function to check if the given address is a valid BasicTraderPool
    /// @param potentialPool the address to inspect
    /// @return true if the address is a BasicTraderPool, false otherwise
    function isBasicPool(address potentialPool) external view returns (bool);

    /// @notice The function to check if the given address is a valid InvestTraderPool
    /// @param potentialPool the address to inspect
    /// @return true if the address is an InvestTraderPool, false otherwise
    function isInvestPool(address potentialPool) external view returns (bool);

    /// @notice The function to check if the given address is a valid TraderPool
    /// @param potentialPool the address to inspect
    /// @return true if the address is a TraderPool, false otherwise
    function isPool(address potentialPool) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library AddressSetHelper {
    using EnumerableSet for EnumerableSet.AddressSet;

    function add(EnumerableSet.AddressSet storage addressSet, address[] calldata array) internal {
        for (uint256 i = 0; i < array.length; i++) {
            addressSet.add(array[i]);
        }
    }

    function remove(EnumerableSet.AddressSet storage addressSet, address[] calldata array)
        internal
    {
        for (uint256 i = 0; i < array.length; i++) {
            addressSet.remove(array[i]);
        }
    }
}