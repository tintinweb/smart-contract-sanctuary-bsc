// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "../lib/LibTypes.sol";
import "../interface/IPerpetual.sol";

contract ContractReader {
    struct GovParams {
        LibTypes.PerpGovernanceConfig perpGovernanceConfig;
        LibTypes.FundingGovernanceConfig fundingModuleGovernanceConfig;
        address fundingModuleAddress; // funding module contract address
    }

    struct PerpetualStorage {
        address collateralTokenAddress;
        uint256 totalSize;
        int256 insuranceFundBalance;
        int256 longSocialLossPerContract;
        int256 shortSocialLossPerContract;
        bool isEmergency;
        bool isGlobalSettled;
        uint256 globalSettlePrice;
        bool isPaused;
        bool isWithdrawDisabled;
        LibTypes.FundingState fundingParams;
        uint256 oraclePrice;
        uint256 oracleTime;
    }

    struct TraderPosition {
        int256 marginBalance;
        uint256 markPrice;
        uint256 maintenanceMargin;
        PerpetualStorage perpetualStorage;
        LibTypes.MarginAccount marginAccount;
        int256 availableMargin;
    }

    struct LiquidateTrader {
        address trader;
        uint256 positionSize;
    }

    struct Market {
        uint256 oraclePrice;
        uint256 oracleTime;
        uint256 totalSize;
    }

    function getGovParams(address perpetualAddress) public view returns (GovParams memory params) {
        IPerpetual perpetual = IPerpetual(perpetualAddress);
        params.perpGovernanceConfig = perpetual.getGovernance();
        params.fundingModuleGovernanceConfig = perpetual.fundingModule().getGovernance();
        params.fundingModuleAddress = address(perpetual.fundingModule());
    }

    function getPerpetualStorage(address perpetualAddress) public view returns (PerpetualStorage memory params) {
        IPerpetual perpetual = IPerpetual(perpetualAddress);
        params.collateralTokenAddress = address(perpetual.collateral());

        params.totalSize = perpetual.totalSize(LibTypes.Side.LONG);
        params.insuranceFundBalance = perpetual.insuranceFundBalance();
        params.longSocialLossPerContract = perpetual.socialLossPerContract(LibTypes.Side.LONG);
        params.shortSocialLossPerContract = perpetual.socialLossPerContract(LibTypes.Side.SHORT);

        params.isEmergency = perpetual.status() == LibTypes.Status.EMERGENCY;
        params.isGlobalSettled = perpetual.status() == LibTypes.Status.SETTLED;
        params.globalSettlePrice = perpetual.settlementPrice();
        params.isPaused = perpetual.paused();
        params.isWithdrawDisabled = perpetual.withdrawDisabled();

        params.fundingParams = perpetual.fundingModule().lastFundingState();
        (params.oraclePrice, params.oracleTime) = perpetual.fundingModule().indexPrice();
    }

    function getAccountStorage(address perpetualAddress, address trader)
        public
        view
        returns (LibTypes.MarginAccount memory margin)
    {
        IPerpetual perpetual = IPerpetual(perpetualAddress);
        return perpetual.getMarginAccount(trader);
    }
    function TraderNeedLiquidate(address perpetualAddress,uint256 start,uint256 end) public returns(LiquidateTrader[100] memory params) {
        IPerpetual perpetual = IPerpetual(perpetualAddress);
        uint256 nums = 0;
        for (uint256 i = start; i < end; i++) {
            address trader = perpetual.accountList(i);
            if (perpetual.isSafe(trader)) {
                params[nums].trader = trader;
                params[nums].positionSize = perpetual.getMarginAccount(trader).size;
                nums = nums + 1;
            }
        }
    }

    function getTraderAllPosition(address[] memory perpetualAddresses, address trader) external returns(TraderPosition[50] memory params) {
        for (uint256 i = 0; i<perpetualAddresses.length; i++) {
            params[i] = getTraderPosition(perpetualAddresses[i],trader);
        }
    }

    function getAllMarket(address[] memory perpetualAddresses) external view returns(Market[100] memory params) {
        for (uint256 i = 0; i < perpetualAddresses.length; i++) {
            IPerpetual perpetual = IPerpetual(perpetualAddresses[i]);
            (params[i].oraclePrice, params[i].oracleTime) = perpetual.fundingModule().indexPrice();
            params[i].totalSize = perpetual.totalSize(LibTypes.Side.LONG);
        }
    }

    function getTraderPosition(address perpetualAddress,address trader) public returns (TraderPosition memory params) {
        IPerpetual perpetual = IPerpetual(perpetualAddress);
        params.marginBalance = perpetual.marginBalance(trader);
        params.markPrice = perpetual.markPrice();
        params.maintenanceMargin = perpetual.maintenanceMargin(trader);
        params.perpetualStorage = getPerpetualStorage(perpetualAddress);
        params.marginAccount = perpetual.getMarginAccount(trader);
        params.availableMargin = perpetual.availableMargin(trader);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;

library LibTypes {
    enum Side {FLAT, SHORT, LONG}

    enum Status {NORMAL, EMERGENCY, SETTLED}

    function counterSide(Side side) internal pure returns (Side) {
        if (side == Side.LONG) {
            return Side.SHORT;
        } else if (side == Side.SHORT) {
            return Side.LONG;
        }
        return side;
    }

    //////////////////////////////////////////////////////////////////////////
    // Perpetual
    //////////////////////////////////////////////////////////////////////////
    struct PerpGovernanceConfig {
        uint256 initialMarginRate;
        uint256 maintenanceMarginRate;
        uint256 liquidationPenaltyRate;
        uint256 penaltyFundRate;
        int256 takerDevFeeRate;
        int256 makerDevFeeRate;
        uint256 lotSize;
        uint256 tradingLotSize;
        int256 referrerBonusRate;
        int256 referreeFeeDiscount;
    }

    struct MarginAccount {
        LibTypes.Side side;
        uint256 size;
        uint256 entryValue;
        int256 entrySocialLoss;
        int256 entryFundingLoss;
        int256 cashBalance;
    }

    //////////////////////////////////////////////////////////////////////////
    // Funding module
    //////////////////////////////////////////////////////////////////////////
    struct FundingGovernanceConfig {
        int256 emaAlpha;
        uint256 updatePremiumPrize;
        int256 markPremiumLimit;
        int256 fundingDampener;
    }

    struct FundingState {
        uint256 lastFundingTime;
        int256 lastPremium;
        int256 lastEMAPremium;
        uint256 lastIndexPrice;
        int256 accumulatedFundingPerContract;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "../interface/IFunding.sol";

import "../lib/LibTypes.sol";


interface IPerpetual {
    function devAddress() external view returns (address);

    function getMarginAccount(address trader) external view returns (LibTypes.MarginAccount memory);

    function getGovernance() external view returns (LibTypes.PerpGovernanceConfig memory);

    function status() external view returns (LibTypes.Status);

    function paused() external view returns (bool);

    function withdrawDisabled() external view returns (bool);

    function settlementPrice() external view returns (uint256);

    function globalConfig() external view returns (address);

    function collateral() external view returns (address);

    function fundingModule() external view returns (IFunding);

    function totalSize(LibTypes.Side side) external view returns (uint256);

    function totalAccounts() external view returns (uint256);

    function accountList(uint256 num) external view returns (address);

    function markPrice() external returns (uint256);

    function socialLossPerContract(LibTypes.Side side) external view returns (int256);

    function availableMargin(address trader) external returns (int256);

    function positionMargin(address trader) external view returns (uint256);

    function maintenanceMargin(address trader) external view returns (uint256);

    function isSafe(address trader) external returns (bool);

    function isSafeWithPrice(address trader, uint256 currentMarkPrice) external returns (bool);

    function isIMSafe(address trader) external returns (bool);

    function isIMSafeWithPrice(address trader, uint256 currentMarkPrice) external returns (bool);

    function marginBalance(address trader) external returns (int256);

    function tradePosition(
        address taker,
        address maker,
        LibTypes.Side side,
        uint256 price,
        uint256 amount
    ) external returns (uint256, uint256);

    function transferCashBalance(
        address from,
        address to,
        uint256 amount
    ) external;

    function depositFor(address trader, uint256 amount) external payable;

    function withdrawFor(address payable trader, uint256 amount) external;

    function liquidate(address trader, uint256 amount) external returns (uint256, uint256);

    function insuranceFundBalance() external view returns (int256);

    function beginGlobalSettlement(uint256 price) external;

    function endGlobalSettlement() external;

    function isValidLotSize(uint256 amount) external view returns (bool);

    function isValidTradingLotSize(uint256 amount) external view returns (bool);

    function setFairPrice(uint256 price) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "../lib/LibTypes.sol";
import "../interface/IPerpetual.sol";


interface IFunding {
    function indexPrice() external view returns (uint256 price, uint256 timestamp);

    function lastFundingState() external view returns (LibTypes.FundingState memory);

    function currentFundingRate() external returns (int256);

    function currentFundingState() external returns (LibTypes.FundingState memory);

    function lastFundingRate() external view returns (int256);

    function getGovernance() external view returns (LibTypes.FundingGovernanceConfig memory);

    function perpetualProxy() external view returns (IPerpetual);

    function currentMarkPrice() external returns (uint256);

    function currentPremiumRate() external returns (int256);

    function currentFairPrice() external returns (uint256);

    function currentPremium() external returns (int256);

    function currentAccumulatedFundingPerContract() external returns (int256);

    function setFairPrice(uint256 price) external;
}