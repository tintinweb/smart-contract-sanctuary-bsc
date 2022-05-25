pragma solidity ^0.8.0;

// SPDX-License-Identifier: BUSL-1.1

import "Interfaces.sol";

contract TwapPriceProvider {
    address public token0;
    address public token1;
    ISlidingWindowOracleV1 public twap;
    AggregatorV3Interface public priceProvider;

    constructor(
        address _token0,
        address _token1,
        ISlidingWindowOracleV1 _twap,
        AggregatorV3Interface pp
    ) {
        token0 = _token0;
        token1 = _token1;
        priceProvider = pp;
        twap = _twap;
    }

    // Should return USD price
    function getUsdPrice() external view returns (uint256 _price) {
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 bnb_price = uint256(latestPrice);
        uint256 token_price = twap.consult(token0, 1e8, token1);
        _price = (token_price * bnb_price) / 1e8;
    }
}

pragma solidity ^0.8.0;

interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface ILiquidityPool {
    struct LockedLiquidity {
        uint256 amount;
        uint256 premium;
        bool locked;
    }

    event Profit(uint256 indexed id, uint256 amount);
    event Loss(uint256 indexed id, uint256 amount);
    event Provide(address indexed account, uint256 amount, uint256 writeAmount);
    event Withdraw(
        address indexed account,
        uint256 amount,
        uint256 writeAmount
    );

    function unlock(uint256 id) external;

    // function unlockPremium(uint256 amount) external;
    event UpdateRevertTransfersInLockUpPeriod(
        address indexed account,
        bool value
    );
    event InitiateWithdraw(uint256 tokenXAmount, address account);
    event ProcessWithdrawRequest(uint256 tokenXAmount, address account);
    event UpdatePoolState(bool hasPoolEnded);
    event PoolRollOver(uint256 round);
    event UpdateMaxLiquidity(uint256 indexed maxLiquidity);
    event UpdateExpiry(uint256 expiry);
    event UpdateProjectOwner(address account);
    event Initialize(uint256 _initialExpiry);

    function totalTokenXBalance() external view returns (uint256 amount);

    function unlockWithoutProfit(uint256 id) external;

    function send(
        uint256 id,
        address account,
        uint256 amount
    ) external;

    function lock(
        uint256 id,
        uint256 tokenXAmount,
        uint256 premium
    ) external;

    function changeLock(
        uint256 id,
        uint256 tokenXAmount,
        uint256 premium
    ) external;
}

interface IBufferOptions {
    event Create(
        uint256 indexed id,
        address indexed account,
        uint256 settlementFee,
        uint256 totalFee,
        string metadata
    );

    event Exercise(uint256 indexed id, uint256 profit);
    event Expire(uint256 indexed id, uint256 premium);
    event PayReferralFee(address indexed referrer, uint256 amount);
    event PayAdminFee(address indexed owner, uint256 amount);
    event AutoExerciseStatusChange(address indexed account, bool status);

    enum State {
        Inactive,
        Active,
        Exercised,
        Expired
    }
    enum OptionType {
        Invalid,
        Put,
        Call
    }
    enum PaymentMethod {
        Usdc,
        TokenX
    }

    event UpdateOptionCreationWindow(
        uint256 startHour,
        uint256 startMinute,
        uint256 endHour,
        uint256 endMinute
    );
    event TransferUnits(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        uint256 targetTokenId,
        uint256 transferUnits
    );

    event Split(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 newTokenId,
        uint256 splitUnits
    );

    event Merge(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 indexed targetTokenId,
        uint256 mergeUnits
    );

    event ApprovalUnits(
        address indexed approval,
        uint256 indexed tokenId,
        uint256 allowance
    );
    struct OptionDetails {
        uint256 period;
        uint256 amount;
        uint256 strike;
        bool isYes;
        bool isAbove;
    }

    struct Option {
        State state;
        uint256 strike;
        uint256 amount;
        uint256 lockedAmount;
        uint256 premium;
        uint256 expiration;
        OptionType optionType;
    }

    struct BinaryOptionType {
        bool isYes;
        bool isAbove;
    }

    struct SlotDetail {
        uint256 strike;
        uint256 expiration;
        OptionType optionType;
        bool isValid;
    }

    struct ApproveUnits {
        address[] approvals;
        mapping(address => uint256) allowances;
    }
}

interface INFTReceiver {
    function onNFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        uint256 units,
        bytes calldata data
    ) external returns (bytes4);
}

interface IOptionsConfig {
    enum PermittedTradingType {
        All,
        OnlyPut,
        OnlyCall,
        None
    }
    event UpdateImpliedVolatility(uint256 value);
    event UpdateSettlementFeePercentage(uint256 value);
    event UpdateSettlementFeeRecipient(address account);
    event UpdateStakingFeePercentage(uint256 value);
    event UpdateReferralRewardPercentage(uint256 value);
    event UpdateOptionCollaterizationRatio(uint256 value);
    event UpdateNFTSaleRoyaltyPercentage(uint256 value);
    event UpdateTradingPermission(PermittedTradingType permissionType);
    event UpdateStrike(uint256 value);
    event UpdateUnits(uint256 value);
    event Initialize(uint256 initialStrike, uint256 iv);
}

interface IOptionWindowCreator {
    struct OptionCreationWindow {
        uint256 startHour;
        uint256 startMinute;
        uint256 endHour;
        uint256 endMinute;
    }
    event UpdateOptionCreationWindow(
        uint256 startHour,
        uint256 startMinute,
        uint256 endHour,
        uint256 endMinute
    );
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
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

    function getTimestamp(uint256 _roundId)
        external
        view
        returns (uint256 timestamp);

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

interface IPriceProvider {
    function getUsdPrice() external view returns (uint256 _price);

    function getRoundData(uint256 _roundId)
        external
        view
        returns (
            uint80 roundId,
            uint256 price,
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

    function decimals() external view returns (uint8);
}

interface INFTCore {
    function burnOption(uint256 optionId_) external;

    function unitsInToken(uint256 optionId_) external view returns (uint256);

    function slotOf(uint256 optionId_) external view returns (uint256);

    function transferUnitsFrom(
        address from_,
        address to_,
        uint256 optionId_,
        uint256 targetOptionId_,
        uint256 transferUnits_,
        address sender
    ) external;

    function checkOnNFTReceived(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 units_,
        bytes memory _data,
        address sender
    ) external returns (bool);

    function isApprovedOrOwner(address account, uint256 optionId_)
        external
        returns (bool);
}

interface ISlidingWindowOracleV1 {
    function consult(
        address tokenIn,
        uint256 amountIn,
        address tokenOut
    ) external view returns (uint256 amountOut);

    function observationIndexOf(uint256 timestamp)
        external
        view
        returns (uint256 index);
}

interface ISlidingWindowOracle {
    function consult(address tvlOracle)
        external
        view
        returns (uint256 amountOut);

    function getTimeWeightedAverageTVL(address tvlOracle, uint256 roundId)
        external
        view
        returns (uint256 roundTimestamp, uint256 KPI);
}