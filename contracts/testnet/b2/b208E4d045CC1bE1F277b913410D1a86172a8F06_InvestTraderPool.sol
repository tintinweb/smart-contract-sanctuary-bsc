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

uint256 constant PERCENTAGE_100 = 10**27;
uint256 constant PRECISION = 10**25;
uint256 constant DECIMALS = 10**18;

uint256 constant MAX_UINT = type(uint256).max;

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