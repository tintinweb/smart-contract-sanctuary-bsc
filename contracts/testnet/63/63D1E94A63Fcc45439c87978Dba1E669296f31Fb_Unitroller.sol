/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

// Sources flattened with hardhat v2.8.4 https://hardhat.org

// File contracts/ComptrollerInterface.sol

pragma solidity ^0.5.16;

contract ComptrollerInterfaceG1 {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;
    function enterMarkets(address[] calldata aTokens) external returns (uint[] memory);
    function exitMarket(address aToken) external returns (uint);
    function mintAllowed(address aToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address aToken, address minter, uint mintAmount, uint mintTokens) external;
    function redeemAllowed(address aToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address aToken, address redeemer, uint redeemAmount, uint redeemTokens) external;
    function borrowAllowed(address aToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address aToken, address borrower, uint borrowAmount) external;
    function repayBorrowAllowed(
        address aToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address aToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;
    function liquidateBorrowAllowed(
        address aTokenBorrowed,
        address aTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address aTokenBorrowed,
        address aTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;
    function seizeAllowed(
        address aTokenCollateral,
        address aTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address aTokenCollateral,
        address aTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address aToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address aToken, address src, address dst, uint transferTokens) external;
    function liquidateCalculateSeizeTokens(
        address aTokenBorrowed,
        address aTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
    function setMintedXAIOf(address owner, uint amount) external returns (uint);
}
contract ComptrollerInterfaceG2 is ComptrollerInterfaceG1 {
    function liquidateXAICalculateSeizeTokens(
        address aTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}
contract ComptrollerInterface is ComptrollerInterfaceG2 {
}
interface IXAIVault {
    function updatePendingRewards() external;
}
interface IComptroller {
    /*** Treasury Data ***/
    function treasuryAddress() external view returns (address);
    function treasuryPercent() external view returns (uint);
}
pragma solidity ^0.5.16;
contract InterestRateModel {
    bool public constant isInterestRateModel = true;
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);
}
pragma solidity ^0.5.16;
contract ATokenStorage {
    bool internal _notEntered;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint internal constant borrowRateMaxMantissa = 0.0005e16;
    uint internal constant reserveFactorMaxMantissa = 1e18;
    address payable public admin;
    address payable public pendingAdmin;
    ComptrollerInterface public comptroller;
    InterestRateModel public interestRateModel;
    uint internal initialExchangeRateMantissa;
    uint public reserveFactorMantissa;
    uint public accrualBlockNumber;
    uint public borrowIndex;
    uint public totalBorrows;
    uint public totalReserves;
    uint public totalSupply;
    mapping (address => uint) internal accountTokens;
    mapping (address => mapping (address => uint)) internal transferAllowances;
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }
    mapping(address => BorrowSnapshot) internal accountBorrows;
    uint public constant protocolSeizeShareMantissa = 5e16; //5%
}

contract ATokenInterface is ATokenStorage {
    bool public constant isAToken = true;
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);
    event Mint(address minter, uint mintAmount, uint mintTokens);
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);
    event RedeemFee(address redeemer, uint feeAmount, uint redeemTokens);
    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);
    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);
    event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address aTokenCollateral, uint seizeTokens);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);
    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);
    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);
    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event Failure(uint error, uint info, uint detail);
    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) public view returns (uint);
    function exchangeRateCurrent() public returns (uint);
    function exchangeRateStored() public view returns (uint);
    function getCash() external view returns (uint);
    function accrueInterest() public returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);
    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint);
    function _acceptAdmin() external returns (uint);
    function _setComptroller(ComptrollerInterface newComptroller) public returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
    function _reduceReserves(uint reduceAmount) external returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint);
}

contract ABep20Storage {
    address public underlying;
}

contract ABep20Interface is ABep20Storage {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, ATokenInterface aTokenCollateral) external returns (uint);
    function _addReserves(uint addAmount) external returns (uint);
}

contract ADelegationStorage {
    address public implementation;
}

contract ADelegatorInterface is ADelegationStorage {
    event NewImplementation(address oldImplementation, address newImplementation);
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public;
}

contract ADelegateInterface is ADelegationStorage {
    function _becomeImplementation(bytes memory data) public;
    function _resignImplementation() public;
}
pragma solidity ^0.5.16;
contract ComptrollerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        COMPTROLLER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED, // no longer possible
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY,
        INSUFFICIENT_BALANCE_FOR_XAI
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        SET_PAUSE_GUARDIAN_OWNER_CHECK,
        SET_XAI_MINT_RATE_CHECK,
        SET_XAICONTROLLER_OWNER_CHECK,
        SET_MINTED_XAI_REJECTION,
        SET_TREASURY_OWNER_CHECK
    }
    event Failure(uint error, uint info, uint detail);
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);

        return uint(err);
    }
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}

contract TokenErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        COMPTROLLER_REJECTION,
        COMPTROLLER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED,
        TOKEN_PRICE_ERROR
    }
    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_MARKET_NOT_LISTED,
        BORROW_COMPTROLLER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_COMPTROLLER_REJECTION,
        LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_COMPTROLLER_REJECTION,
        MINT_EXCHANGE_CALCULATION_FAILED,
        MINT_EXCHANGE_RATE_READ_FAILED,
        MINT_FRESHNESS_CHECK,
        MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
        REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
        REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        REDEEM_EXCHANGE_RATE_READ_FAILED,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_VALIDATION,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COMPTROLLER_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ORACLE_MARKET_NOT_LISTED,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_RESERVE_FACTOR_FRESH_CHECK,
        SET_RESERVE_FACTOR_BOUNDS_CHECK,
        TRANSFER_COMPTROLLER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH,
        ADD_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_RESERVES_FRESH_CHECK,
        ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE,
        TOKEN_GET_UNDERLYING_PRICE_ERROR,
        REPAY_XAI_COMPTROLLER_REJECTION,
        REPAY_XAI_FRESHNESS_CHECK,
        XAI_MINT_EXCHANGE_CALCULATION_FAILED,
        SFT_MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_FEE_CALCULATION_FAILED
    }
    event Failure(uint error, uint info, uint detail);
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);

        return uint(err);
    }
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);
        return uint(err);
    }
}

contract XAIControllerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        REJECTION,
        SNAPSHOT_ERROR,
        PRICE_ERROR,
        MATH_ERROR,
        INSUFFICIENT_BALANCE_FOR_XAI
    }

    enum FailureInfo {
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_COMPTROLLER_OWNER_CHECK,
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        XAI_MINT_REJECTION,
        XAI_BURN_REJECTION,
        XAI_LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        XAI_LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        XAI_LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        XAI_LIQUIDATE_COMPTROLLER_REJECTION,
        XAI_LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        XAI_LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        XAI_LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        XAI_LIQUIDATE_FRESHNESS_CHECK,
        XAI_LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        XAI_LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        XAI_LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        XAI_LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        XAI_LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        XAI_LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        XAI_LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_FEE_CALCULATION_FAILED,
        SET_TREASURY_OWNER_CHECK
    }
    event Failure(uint error, uint info, uint detail);
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);
        return uint(err);
    }
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);
        return uint(err);
    }
}
pragma solidity ^0.5.16;
contract CarefulMath {
    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }
    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }
        uint c = a * b;
        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }
    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }
        return (MathError.NO_ERROR, a / b);
    }
    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }
    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {
        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }
    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {
        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}

pragma solidity ^0.5.16;
contract ExponentialNoError {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }
    function truncate(Exp memory exp) internal pure returns (uint) {
        return exp.mantissa / expScale;
    }
    function mul_ScalarTruncate(Exp memory a, uint scalar) internal pure returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) internal pure returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }
    function lessThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
        return left.mantissa < right.mantissa;
    }
    function lessThanOrEqualExp(Exp memory left, Exp memory right) internal pure returns (bool) {
        return left.mantissa <= right.mantissa;
    }
    function greaterThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
        return left.mantissa > right.mantissa;
    }
    function isZeroExp(Exp memory value) internal pure returns (bool) {
        return value.mantissa == 0;
    }
    function safe224(uint n, string memory errorMessage) internal pure returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) internal pure returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) internal pure returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) internal pure returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) internal pure returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) internal pure returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) internal pure returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) internal pure returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) internal pure returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) internal pure returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) internal pure returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) internal pure returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) internal pure returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) internal pure returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}


// File contracts/Exponential.sol

pragma solidity ^0.5.16;

contract Exponential is CarefulMath, ExponentialNoError {
  
    function getExp(uint num, uint denom) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function addExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }
    function subExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }
    function mulScalar(Exp memory a, uint scalar) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }
    function mulScalarTruncate(Exp memory a, uint scalar) internal pure returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }
    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) internal pure returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }
        return addUInt(truncate(product), addend);
    }
    function divScalar(Exp memory a, uint scalar) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }
    function divScalarByExp(uint scalar, Exp memory divisor) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }
    function divScalarByExpTruncate(uint scalar, Exp memory divisor) internal pure returns (MathError, uint) {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }
    function mulExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {

        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }
    function mulExp(uint a, uint b) internal pure returns (MathError, Exp memory) {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }
    function mulExp3(Exp memory a, Exp memory b, Exp memory c) internal pure returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }
    function divExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }
}
// File contracts/EIP20Interface.sol
pragma solidity ^0.5.16;
interface EIP20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address dst, uint256 amount) external returns (bool success);
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);
    function approve(address spender, uint256 amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
// File contracts/EIP20NonStandardInterface.sol
pragma solidity ^0.5.16;

interface EIP20NonStandardInterface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address dst, uint256 amount) external;
    function transferFrom(address src, address dst, uint256 amount) external;
    function approve(address spender, uint256 amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
pragma solidity ^0.5.16;
contract AToken is ATokenInterface, Exponential, TokenErrorReporter {
    function initialize(ComptrollerInterface comptroller_,
                        InterestRateModel interestRateModel_,
                        uint initialExchangeRateMantissa_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_) public {
        require(msg.sender == admin, "only admin may initialize the market");
        require(accrualBlockNumber == 0 && borrowIndex == 0, "market may only be initialized once");
        // Set initial exchange rate
        initialExchangeRateMantissa = initialExchangeRateMantissa_;
        require(initialExchangeRateMantissa > 0, "initial exchange rate must be greater than zero.");
        // Set the comptroller
        uint err = _setComptroller(comptroller_);
        require(err == uint(Error.NO_ERROR), "setting comptroller failed");
        // Initialize block number and borrow index (block number mocks depend on comptroller being set)
        accrualBlockNumber = getBlockNumber();
        borrowIndex = mantissaOne;
        // Set the interest rate model (depends on block number / borrow index)
        err = _setInterestRateModelFresh(interestRateModel_);
        require(err == uint(Error.NO_ERROR), "setting interest rate model failed");
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        // The counter starts true to prevent changing it from zero to non-zero (i.e. smaller cost/refund)
        _notEntered = true;
    }
    function transferTokens(address spender, address src, address dst, uint tokens) internal returns (uint) {
        uint allowed = comptroller.transferAllowed(address(this), src, dst, tokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
        }
        if (src == dst) {
            return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
        }
        uint startingAllowance = 0;
        if (spender == src) {
            startingAllowance = uint(-1);
        } else {
            startingAllowance = transferAllowances[src][spender];
        }
        MathError mathErr;
        uint allowanceNew;
        uint sraTokensNew;
        uint dstTokensNew;
        (mathErr, allowanceNew) = subUInt(startingAllowance, tokens);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        (mathErr, sraTokensNew) = subUInt(accountTokens[src], tokens);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ENOUGH);
        }

        (mathErr, dstTokensNew) = addUInt(accountTokens[dst], tokens);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_TOO_MUCH);
        }
        accountTokens[src] = sraTokensNew;
        accountTokens[dst] = dstTokensNew;
        if (startingAllowance != uint(-1)) {
            transferAllowances[src][spender] = allowanceNew;
        }
        emit Transfer(src, dst, tokens);
        comptroller.transferVerify(address(this), src, dst, tokens);
        return uint(Error.NO_ERROR);
    }
    function transfer(address dst, uint256 amount) external nonReentrant returns (bool) {
        return transferTokens(msg.sender, msg.sender, dst, amount) == uint(Error.NO_ERROR);
    }
    function transferFrom(address src, address dst, uint256 amount) external nonReentrant returns (bool) {
        return transferTokens(msg.sender, src, dst, amount) == uint(Error.NO_ERROR);
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }
    function allowance(address owner, address spender) external view returns (uint256) {
        return transferAllowances[owner][spender];
    }
    function balanceOf(address owner) external view returns (uint256) {
        return accountTokens[owner];
    }
    function balanceOfUnderlying(address owner) external returns (uint) {
        Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
        (MathError mErr, uint balance) = mulScalarTruncate(exchangeRate, accountTokens[owner]);
        require(mErr == MathError.NO_ERROR, "balance could not be calculated");
        return balance;
    }

    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint) {
        uint aTokenBalance = accountTokens[account];
        uint borrowBalance;
        uint exchangeRateMantissa;

        MathError mErr;

        (mErr, borrowBalance) = borrowBalanceStoredInternal(account);
        if (mErr != MathError.NO_ERROR) {
            return (uint(Error.MATH_ERROR), 0, 0, 0);
        }

        (mErr, exchangeRateMantissa) = exchangeRateStoredInternal();
        if (mErr != MathError.NO_ERROR) {
            return (uint(Error.MATH_ERROR), 0, 0, 0);
        }

        return (uint(Error.NO_ERROR), aTokenBalance, borrowBalance, exchangeRateMantissa);
    }
    function getBlockNumber() internal view returns (uint) {
        return block.number;
    }
    function borrowRatePerBlock() external view returns (uint) {
        return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalReserves);
    }

    function supplyRatePerBlock() external view returns (uint) {
        return interestRateModel.getSupplyRate(getCashPrior(), totalBorrows, totalReserves, reserveFactorMantissa);
    }
    function totalBorrowsCurrent() external nonReentrant returns (uint) {
        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return totalBorrows;
    }

    function borrowBalanceCurrent(address account) external nonReentrant returns (uint) {
        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return borrowBalanceStored(account);
    }
    function borrowBalanceStored(address account) public view returns (uint) {
        (MathError err, uint result) = borrowBalanceStoredInternal(account);
        require(err == MathError.NO_ERROR, "borrowBalanceStored: borrowBalanceStoredInternal failed");
        return result;
    }

    function borrowBalanceStoredInternal(address account) internal view returns (MathError, uint) {
        MathError mathErr;
        uint principalTimesIndex;
        uint result;
        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];
        if (borrowSnapshot.principal == 0) {
            return (MathError.NO_ERROR, 0);
        }
        (mathErr, principalTimesIndex) = mulUInt(borrowSnapshot.principal, borrowIndex);
        if (mathErr != MathError.NO_ERROR) {
            return (mathErr, 0);
        }
        (mathErr, result) = divUInt(principalTimesIndex, borrowSnapshot.interestIndex);
        if (mathErr != MathError.NO_ERROR) {
            return (mathErr, 0);
        }
        return (MathError.NO_ERROR, result);
    }
    function exchangeRateCurrent() public nonReentrant returns (uint) {
        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return exchangeRateStored();
    }
    function exchangeRateStored() public view returns (uint) {
        (MathError err, uint result) = exchangeRateStoredInternal();
        require(err == MathError.NO_ERROR, "exchangeRateStored: exchangeRateStoredInternal failed");
        return result;
    }
    function exchangeRateStoredInternal() internal view returns (MathError, uint) {
        uint _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return (MathError.NO_ERROR, initialExchangeRateMantissa);
        } else {
            uint totalCash = getCashPrior();
            uint cashPlusBorrowsMinusReserves;
            Exp memory exchangeRate;
            MathError mathErr;

            (mathErr, cashPlusBorrowsMinusReserves) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }
            (mathErr, exchangeRate) = getExp(cashPlusBorrowsMinusReserves, _totalSupply);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            return (MathError.NO_ERROR, exchangeRate.mantissa);
        }
    }
    function getCash() external view returns (uint) {
        return getCashPrior();
    }
    function accrueInterest() public returns (uint) {
        uint currentBlockNumber = getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;
        if (accrualBlockNumberPrior == currentBlockNumber) {
            return uint(Error.NO_ERROR);
        }
        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint reservesPrior = totalReserves;
        uint borrowIndexPrior = borrowIndex;
        uint borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "borrow rate is absurdly high");
        (MathError mathErr, uint blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);
        require(mathErr == MathError.NO_ERROR, "could not calculate block delta");
        Exp memory simpleInterestFactor;
        uint interestAccumulated;
        uint totalBorrowsNew;
        uint totalReservesNew;
        uint borrowIndexNew;
        (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa: borrowRateMantissa}), blockDelta);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED, uint(mathErr));
        }
        (mathErr, interestAccumulated) = mulScalarTruncate(simpleInterestFactor, borrowsPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED, uint(mathErr));
        }
        (mathErr, totalBorrowsNew) = addUInt(interestAccumulated, borrowsPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED, uint(mathErr));
        }
        (mathErr, totalReservesNew) = mulScalarTruncateAddUInt(Exp({mantissa: reserveFactorMantissa}), interestAccumulated, reservesPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED, uint(mathErr));
        }
        (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED, uint(mathErr));
        }
        accrualBlockNumber = currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;
        emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);
        return uint(Error.NO_ERROR);
    }

    function mintInternal(uint mintAmount) internal nonReentrant returns (uint, uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.MINT_ACCRUE_INTEREST_FAILED), 0);
        }
        return mintFresh(msg.sender, mintAmount);
    }
    struct MintLocalVars {
        Error err;
        MathError mathErr;
        uint exchangeRateMantissa;
        uint mintTokens;
        uint totalSupplyNew;
        uint accountTokensNew;
        uint actualMintAmount;
    }
    function mintFresh(address minter, uint mintAmount) internal returns (uint, uint) {
        uint allowed = comptroller.mintAllowed(address(this), minter, mintAmount);
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.MINT_COMPTROLLER_REJECTION, allowed), 0);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.MINT_FRESHNESS_CHECK), 0);
        }
        MintLocalVars memory vars;
        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        if (vars.mathErr != MathError.NO_ERROR) {
            return (failOpaque(Error.MATH_ERROR, FailureInfo.MINT_EXCHANGE_RATE_READ_FAILED, uint(vars.mathErr)), 0);
        }
        vars.actualMintAmount = doTransferIn(minter, mintAmount);
        (vars.mathErr, vars.mintTokens) = divScalarByExpTruncate(vars.actualMintAmount, Exp({mantissa: vars.exchangeRateMantissa}));
        require(vars.mathErr == MathError.NO_ERROR, "MINT_EXCHANGE_CALCULATION_FAILED");
        (vars.mathErr, vars.totalSupplyNew) = addUInt(totalSupply, vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED");
        (vars.mathErr, vars.accountTokensNew) = addUInt(accountTokens[minter], vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED");
        totalSupply = vars.totalSupplyNew;
        accountTokens[minter] = vars.accountTokensNew;
        emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), minter, vars.mintTokens);
        comptroller.mintVerify(address(this), minter, vars.actualMintAmount, vars.mintTokens);

        return (uint(Error.NO_ERROR), vars.actualMintAmount);
    }
    function redeemInternal(uint redeemTokens) internal nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(msg.sender, redeemTokens, 0);
    }
    function redeemUnderlyingInternal(uint redeemAmount) internal nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(msg.sender, 0, redeemAmount);
    }
    struct RedeemLocalVars {
        Error err;
        MathError mathErr;
        uint exchangeRateMantissa;
        uint redeemTokens;
        uint redeemAmount;
        uint totalSupplyNew;
        uint accountTokensNew;
    }
    function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn) internal returns (uint) {
        require(redeemTokensIn == 0 || redeemAmountIn == 0, "one of redeemTokensIn or redeemAmountIn must be zero");
        RedeemLocalVars memory vars;
        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_RATE_READ_FAILED, uint(vars.mathErr));
        }
        if (redeemTokensIn > 0) {
            vars.redeemTokens = redeemTokensIn;
            (vars.mathErr, vars.redeemAmount) = mulScalarTruncate(Exp({mantissa: vars.exchangeRateMantissa}), redeemTokensIn);
            if (vars.mathErr != MathError.NO_ERROR) {
                return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED, uint(vars.mathErr));
            }
        } else {
            (vars.mathErr, vars.redeemTokens) = divScalarByExpTruncate(redeemAmountIn, Exp({mantissa: vars.exchangeRateMantissa}));
            if (vars.mathErr != MathError.NO_ERROR) {
                return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED, uint(vars.mathErr));
            }
            vars.redeemAmount = redeemAmountIn;
        }
        uint allowed = comptroller.redeemAllowed(address(this), redeemer, vars.redeemTokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REDEEM_COMPTROLLER_REJECTION, allowed);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDEEM_FRESHNESS_CHECK);
        }
        (vars.mathErr, vars.totalSupplyNew) = subUInt(totalSupply, vars.redeemTokens);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED, uint(vars.mathErr));
        }

        (vars.mathErr, vars.accountTokensNew) = subUInt(accountTokens[redeemer], vars.redeemTokens);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }
        if (getCashPrior() < vars.redeemAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDEEM_TRANSFER_OUT_NOT_POSSIBLE);
        }
        uint feeAmount;
        uint remainedAmount;
        if (IComptroller(address(comptroller)).treasuryPercent() != 0) {
            (vars.mathErr, feeAmount) = mulUInt(vars.redeemAmount, IComptroller(address(comptroller)).treasuryPercent());
            if (vars.mathErr != MathError.NO_ERROR) {
                return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_FEE_CALCULATION_FAILED, uint(vars.mathErr));
            }
            (vars.mathErr, feeAmount) = divUInt(feeAmount, 1e18);
            if (vars.mathErr != MathError.NO_ERROR) {
                return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_FEE_CALCULATION_FAILED, uint(vars.mathErr));
            }
            (vars.mathErr, remainedAmount) = subUInt(vars.redeemAmount, feeAmount);
            if (vars.mathErr != MathError.NO_ERROR) {
                return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_FEE_CALCULATION_FAILED, uint(vars.mathErr));
            }
            doTransferOut(address(uint160(IComptroller(address(comptroller)).treasuryAddress())), feeAmount);
            emit RedeemFee(redeemer, feeAmount, vars.redeemTokens);
        } else {
            remainedAmount = vars.redeemAmount;
        }
        doTransferOut(redeemer, remainedAmount);
        totalSupply = vars.totalSupplyNew;
        accountTokens[redeemer] = vars.accountTokensNew;
        emit Transfer(redeemer, address(this), vars.redeemTokens);
        emit Redeem(redeemer, remainedAmount, vars.redeemTokens);
        comptroller.redeemVerify(address(this), redeemer, vars.redeemAmount, vars.redeemTokens);
        return uint(Error.NO_ERROR);
    }
    function borrowInternal(uint borrowAmount) internal nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
        }
        return borrowFresh(msg.sender, borrowAmount);
    }
    struct BorrowLocalVars {
        MathError mathErr;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
    }
    function borrowFresh(address payable borrower, uint borrowAmount) internal returns (uint) {
        uint allowed = comptroller.borrowAllowed(address(this), borrower, borrowAmount);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.BORROW_COMPTROLLER_REJECTION, allowed);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.BORROW_FRESHNESS_CHECK);
        }
        if (getCashPrior() < borrowAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.BORROW_CASH_NOT_AVAILABLE);
        }
        BorrowLocalVars memory vars;
        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }
        (vars.mathErr, vars.accountBorrowsNew) = addUInt(vars.accountBorrows, borrowAmount);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }
        (vars.mathErr, vars.totalBorrowsNew) = addUInt(totalBorrows, borrowAmount);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }
        doTransferOut(borrower, borrowAmount);
        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;
        emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);
        comptroller.borrowVerify(address(this), borrower, borrowAmount);
        return uint(Error.NO_ERROR);
    }
    function repayBorrowInternal(uint repayAmount) internal nonReentrant returns (uint, uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.REPAY_BORROW_ACCRUE_INTEREST_FAILED), 0);
        }
        return repayBorrowFresh(msg.sender, msg.sender, repayAmount);
    }

    function repayBorrowBehalfInternal(address borrower, uint repayAmount) internal nonReentrant returns (uint, uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.REPAY_BEHALF_ACCRUE_INTEREST_FAILED), 0);
        }
        return repayBorrowFresh(msg.sender, borrower, repayAmount);
    }

    struct RepayBorrowLocalVars {
        Error err;
        MathError mathErr;
        uint repayAmount;
        uint borrowerIndex;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
        uint actualRepayAmount;
    }
    function repayBorrowFresh(address payer, address borrower, uint repayAmount) internal returns (uint, uint) {
        uint allowed = comptroller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REPAY_BORROW_COMPTROLLER_REJECTION, allowed), 0);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.REPAY_BORROW_FRESHNESS_CHECK), 0);
        }
        RepayBorrowLocalVars memory vars;
        vars.borrowerIndex = accountBorrows[borrower].interestIndex;
        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
        if (vars.mathErr != MathError.NO_ERROR) {
            return (failOpaque(Error.MATH_ERROR, FailureInfo.REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, uint(vars.mathErr)), 0);
        }
        if (repayAmount == uint(-1)) {
            vars.repayAmount = vars.accountBorrows;
        } else {
            vars.repayAmount = repayAmount;
        }
        vars.actualRepayAmount = doTransferIn(payer, vars.repayAmount);
        (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, vars.actualRepayAmount);
        require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED");
        (vars.mathErr, vars.totalBorrowsNew) = subUInt(totalBorrows, vars.actualRepayAmount);
        require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED");
        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;
        emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);
        comptroller.repayBorrowVerify(address(this), payer, borrower, vars.actualRepayAmount, vars.borrowerIndex);
        return (uint(Error.NO_ERROR), vars.actualRepayAmount);
    }
    function liquidateBorrowInternal(address borrower, uint repayAmount, ATokenInterface aTokenCollateral) internal nonReentrant returns (uint, uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED), 0);
        }
        error = aTokenCollateral.accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED), 0);
        }
        return liquidateBorrowFresh(msg.sender, borrower, repayAmount, aTokenCollateral);
    }
    function liquidateBorrowFresh(address liquidator, address borrower, uint repayAmount, ATokenInterface aTokenCollateral) internal returns (uint, uint) {
        uint allowed = comptroller.liquidateBorrowAllowed(address(this), address(aTokenCollateral), liquidator, borrower, repayAmount);
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_COMPTROLLER_REJECTION, allowed), 0);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_FRESHNESS_CHECK), 0);
        }
        if (aTokenCollateral.accrualBlockNumber() != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_COLLATERAL_FRESHNESS_CHECK), 0);
        }
        if (borrower == liquidator) {
            return (fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_LIQUIDATOR_IS_BORROWER), 0);
        }
        if (repayAmount == 0) {
            return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_ZERO), 0);
        }
        if (repayAmount == uint(-1)) {
            return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX), 0);
        }
        (uint repayBorrowError, uint actualRepayAmount) = repayBorrowFresh(liquidator, borrower, repayAmount);
        if (repayBorrowError != uint(Error.NO_ERROR)) {
            return (fail(Error(repayBorrowError), FailureInfo.LIQUIDATE_REPAY_BORROW_FRESH_FAILED), 0);
        }
        (uint amountSeizeError, uint seizeTokens) = comptroller.liquidateCalculateSeizeTokens(address(this), address(aTokenCollateral), actualRepayAmount);
        require(amountSeizeError == uint(Error.NO_ERROR), "LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED");
        require(aTokenCollateral.balanceOf(borrower) >= seizeTokens, "LIQUIDATE_SEIZE_TOO_MUCH");
        uint seizeError;
        if (address(aTokenCollateral) == address(this)) {
            seizeError = seizeInternal(address(this), liquidator, borrower, seizeTokens);
        } else {
            seizeError = aTokenCollateral.seize(liquidator, borrower, seizeTokens);
        }
        require(seizeError == uint(Error.NO_ERROR), "token seizure failed");
        emit LiquidateBorrow(liquidator, borrower, actualRepayAmount, address(aTokenCollateral), seizeTokens);
        comptroller.liquidateBorrowVerify(address(this), address(aTokenCollateral), liquidator, borrower, actualRepayAmount, seizeTokens);
        return (uint(Error.NO_ERROR), actualRepayAmount);
    }
    function seize(address liquidator, address borrower, uint seizeTokens) external nonReentrant returns (uint) {
        return seizeInternal(msg.sender, liquidator, borrower, seizeTokens);
    }
   struct SeizeInternalLocalVars {
        MathError mathErr;
        uint borrowerTokensNew;
        uint liquidatorTokensNew;
        uint liquidatorSeizeTokens;
        uint protocolSeizeTokens;
        uint protocolSeizeAmount;
        uint exchangeRateMantissa;
        uint totalReservesNew;
        uint totalSupplyNew;
    }
    function seizeInternal(address seizerToken, address liquidator, address borrower, uint seizeTokens) internal returns (uint) {
        uint allowed = comptroller.seizeAllowed(address(this), seizerToken, liquidator, borrower, seizeTokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, allowed);
        }
        if (borrower == liquidator) {
            return fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER);
        }
        SeizeInternalLocalVars memory vars;
        (vars.mathErr, vars.borrowerTokensNew) = subUInt(accountTokens[borrower], seizeTokens);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED, uint(vars.mathErr));
        }
        // 15 token in 100.
        // uint liquidatorSeize = mul_(seizeTokens, Exp({mantissa: protocolLiquidatorSeizeShareMantissa}));
        // 5 token in 15.
        vars.protocolSeizeTokens = mul_(seizeTokens, Exp({mantissa: protocolSeizeShareMantissa}));
        vars.liquidatorSeizeTokens = sub_(seizeTokens, vars.protocolSeizeTokens);
        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        require(vars.mathErr == MathError.NO_ERROR, "exchange rate math error");
        vars.protocolSeizeAmount = mul_ScalarTruncate(Exp({mantissa: vars.exchangeRateMantissa}), vars.protocolSeizeTokens);
        vars.totalReservesNew = add_(totalReserves, vars.protocolSeizeAmount);
        vars.totalSupplyNew = sub_(totalSupply, vars.protocolSeizeTokens);
        (vars.mathErr, vars.liquidatorTokensNew) = addUInt(accountTokens[liquidator], vars.liquidatorSeizeTokens);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED, uint(vars.mathErr));
        }
        totalReserves = vars.totalReservesNew;
        totalSupply = vars.totalSupplyNew;
        accountTokens[borrower] = vars.borrowerTokensNew;
        accountTokens[liquidator] = vars.liquidatorTokensNew;
        emit Transfer(borrower, liquidator, vars.liquidatorSeizeTokens);
        emit Transfer(borrower, address(this), vars.protocolSeizeTokens);
        emit ReservesAdded(address(this), vars.protocolSeizeAmount, vars.totalReservesNew);
        return uint(Error.NO_ERROR);
    }
    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
        return uint(Error.NO_ERROR);
    }
    function _acceptAdmin() external returns (uint) {
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
        }
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
        return uint(Error.NO_ERROR);
    }
    function _setComptroller(ComptrollerInterface newComptroller) public returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_COMPTROLLER_OWNER_CHECK);
        }
        ComptrollerInterface oldComptroller = comptroller;
        require(newComptroller.isComptroller(), "marker method returned false");
        comptroller = newComptroller;
        emit NewComptroller(oldComptroller, newComptroller);
        return uint(Error.NO_ERROR);
    }
    function _setReserveFactor(uint newReserveFactorMantissa) external nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED);
        }
        return _setReserveFactorFresh(newReserveFactorMantissa);
    }
    function _setReserveFactorFresh(uint newReserveFactorMantissa) internal returns (uint) {
        // Check caller is admin
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_RESERVE_FACTOR_ADMIN_CHECK);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_RESERVE_FACTOR_FRESH_CHECK);
        }
        if (newReserveFactorMantissa > reserveFactorMaxMantissa) {
            return fail(Error.BAD_INPUT, FailureInfo.SET_RESERVE_FACTOR_BOUNDS_CHECK);
        }
        uint oldReserveFactorMantissa = reserveFactorMantissa;
        reserveFactorMantissa = newReserveFactorMantissa;
        emit NewReserveFactor(oldReserveFactorMantissa, newReserveFactorMantissa);
        return uint(Error.NO_ERROR);
    }
    function _addReservesInternal(uint addAmount) internal nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.ADD_RESERVES_ACCRUE_INTEREST_FAILED);
        }
        (error, ) = _addReservesFresh(addAmount);
        return error;
    }

    function _addReservesFresh(uint addAmount) internal returns (uint, uint) {
        uint totalReservesNew;
        uint actualAddAmount;
        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.ADD_RESERVES_FRESH_CHECK), actualAddAmount);
        }
        actualAddAmount = doTransferIn(msg.sender, addAmount);
        totalReservesNew = totalReserves + actualAddAmount;
        require(totalReservesNew >= totalReserves, "add reserves unexpected overflow");
        totalReserves = totalReservesNew;
        emit ReservesAdded(msg.sender, actualAddAmount, totalReservesNew);
        return (uint(Error.NO_ERROR), actualAddAmount);
    }

    function _reduceReserves(uint reduceAmount) external nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDUCE_RESERVES_ACCRUE_INTEREST_FAILED);
        }
        return _reduceReservesFresh(reduceAmount);
    }

    function _reduceReservesFresh(uint reduceAmount) internal returns (uint) {
        uint totalReservesNew;
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.REDUCE_RESERVES_ADMIN_CHECK);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDUCE_RESERVES_FRESH_CHECK);
        }
        if (getCashPrior() < reduceAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDUCE_RESERVES_CASH_NOT_AVAILABLE);
        }
        if (reduceAmount > totalReserves) {
            return fail(Error.BAD_INPUT, FailureInfo.REDUCE_RESERVES_VALIDATION);
        }
        totalReservesNew = totalReserves - reduceAmount;
        require(totalReservesNew <= totalReserves, "reduce reserves unexpected underflow");
        totalReserves = totalReservesNew;
        doTransferOut(admin, reduceAmount);
        emit ReservesReduced(admin, reduceAmount, totalReservesNew);
        return uint(Error.NO_ERROR);
    }
    function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED);
        }
        return _setInterestRateModelFresh(newInterestRateModel);
    }

    function _setInterestRateModelFresh(InterestRateModel newInterestRateModel) internal returns (uint) {
        InterestRateModel oldInterestRateModel;
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_INTEREST_RATE_MODEL_OWNER_CHECK);
        }
        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_INTEREST_RATE_MODEL_FRESH_CHECK);
        }
        oldInterestRateModel = interestRateModel;
        require(newInterestRateModel.isInterestRateModel(), "marker method returned false");
        interestRateModel = newInterestRateModel;
        emit NewMarketInterestRateModel(oldInterestRateModel, newInterestRateModel);

        return uint(Error.NO_ERROR);
    }
    function getCashPrior() internal view returns (uint);
    function doTransferIn(address from, uint amount) internal returns (uint);
    function doTransferOut(address payable to, uint amount) internal;
    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }
}

pragma solidity ^0.5.16;

contract PriceOracle {
    bool public constant isPriceOracle = true;
    function getUnderlyingPrice(AToken aToken) external view returns (uint);
}
// File contracts/XAIControllerInterface.sol
pragma solidity ^0.5.16;

contract XAIControllerInterface {
    function getXAIAddress() public view returns (address);
    function getMintableXAI(address minter) public view returns (uint, uint);
    function mintXAI(address minter, uint mintXAIAmount) external returns (uint);
    function repayXAI(address repayer, uint repayXAIAmount) external returns (uint);

    function _initializeAnnexXAIState(uint blockNumber) external returns (uint);
    function updateAnnexXAIMintIndex() external returns (uint);
    function calcDistributeXAIMinterAnnex(address xaiMinter) external returns(uint, uint, uint, uint);
}

pragma solidity ^0.5.16;

contract UnitrollerAdminStorage {
 
    address public admin;
    address public pendingAdmin;
    address public comptrollerImplementation;
    address public pendingComptrollerImplementation;
}

contract ComptrollerV1Storage is UnitrollerAdminStorage {
    PriceOracle public oracle;
    uint public closeFactorMantissa;
    uint public liquidationIncentiveMantissa;
    uint public maxAssets;
    mapping(address => AToken[]) public accountAssets;
    struct Market {
        bool isListed;
        uint collateralFactorMantissa;
        mapping(address => bool) accountMembership;
        bool isAnnex;
    }
    mapping(address => Market) public markets;
    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;
    struct AnnexMarketState {
        uint224 index;
        uint32 block;
    }
    AToken[] public allMarkets;
    uint public annexRate;
    mapping(address => uint) public annexSpeeds;
    mapping(address => AnnexMarketState) public annexSupplyState;
    mapping(address => AnnexMarketState) public annexBorrowState;
    mapping(address => mapping(address => uint)) public annexSupplierIndex;
    mapping(address => mapping(address => uint)) public annexBorrowerIndex;
    mapping(address => uint) public annexAccrued;
    XAIControllerInterface public xaiController;
    mapping(address => uint) public mintedXAIs;
    uint public xaiMintRate;
    bool public mintXAIGuardianPaused;
    bool public repayXAIGuardianPaused;
    bool public protocolPaused;
    uint public annexXAIRate;
}
contract ComptrollerV2Storage is ComptrollerV1Storage {
    uint public annexXAIVaultRate;
    address public xaiVaultAddress;
    uint256 public releaseStartBlock;
    uint256 public minReleaseAmount;
}
contract ComptrollerV3Storage is ComptrollerV2Storage {
    address public borrowCapGuardian;
    mapping(address => uint) public borrowCaps;
}
contract ComptrollerV4Storage is ComptrollerV3Storage {
    address public treasuryGuardian;
    address public treasuryAddress;
    uint256 public treasuryPercent;
}
contract ComptrollerV5Storage is ComptrollerV4Storage {
    mapping(address => uint) public annexBorrowSpeeds;
    mapping(address => uint) public annexSupplySpeeds;
}

pragma solidity ^0.5.16;
contract Unitroller is UnitrollerAdminStorage, ComptrollerErrorReporter {
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);
    event NewImplementation(address oldImplementation, address newImplementation);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    constructor() public {
        // Set admin to caller
        admin = msg.sender;
    }
    function _setPendingImplementation(address newPendingImplementation) public returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_OWNER_CHECK);
        }
        address oldPendingImplementation = pendingComptrollerImplementation;
        pendingComptrollerImplementation = newPendingImplementation;
        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);
        return uint(Error.NO_ERROR);
    }
    function _acceptImplementation() public returns (uint) {
        if (msg.sender != pendingComptrollerImplementation || pendingComptrollerImplementation == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK);
        }
        address oldImplementation = comptrollerImplementation;
        address oldPendingImplementation = pendingComptrollerImplementation;
        comptrollerImplementation = pendingComptrollerImplementation;
        pendingComptrollerImplementation = address(0);
        emit NewImplementation(oldImplementation, comptrollerImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);
        return uint(Error.NO_ERROR);
    }
    function _setPendingAdmin(address newPendingAdmin) public returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
        return uint(Error.NO_ERROR);
    }
    function _acceptAdmin() public returns (uint) {
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
        }
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
        return uint(Error.NO_ERROR);
    }
    function () external payable {
        (bool success, ) = comptrollerImplementation.delegatecall(msg.data);
        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize)

              switch success
              case 0 { revert(free_mem_ptr, returndatasize) }
              default { return(free_mem_ptr, returndatasize) }
        }
    }
}
// File contracts/Governance/ANN.sol
pragma solidity ^0.5.16;

contract Context {
  constructor () internal { }
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

contract Ownable is Context {
    address private _owner;
    address private _authorizedNewOwner;
    event OwnershipTransferAuthorization(address indexed authorizedAddress);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function authorizedNewOwner() public view returns (address) {
        return _authorizedNewOwner;
    }
    function authorizeOwnershipTransfer(address authorizedAddress) external onlyOwner {
        _authorizedNewOwner = authorizedAddress;
        emit OwnershipTransferAuthorization(_authorizedNewOwner);
    }
    function assumeOwnership() external {
        require(_msgSender() == _authorizedNewOwner, "Ownable: only the authorized new owner can accept ownership");
        emit OwnershipTransferred(_owner, _authorizedNewOwner);
        _owner = _authorizedNewOwner;
        _authorizedNewOwner = address(0);
    }
    function renounceOwnership(address confirmAddress) public onlyOwner {
        require(confirmAddress == _owner, "Ownable: confirm address is wrong");
        emit OwnershipTransferred(_owner, address(0));
        _authorizedNewOwner = address(0);
        _owner = address(0);
    }
}
contract ANN is Ownable {
    string public constant name = "Annex";
    string public constant symbol = "ANN";
    uint8 public constant decimals = 18;
    uint public constant totalSupply = 1000000000e18; // 1 billion ANN
    uint32 public constant eligibleEpochs = 30; // 30 epochs
    mapping (address => mapping (address => uint96)) internal allowances;
    mapping (address => uint96) internal balances;
    mapping (address => address) public delegates;
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }
    struct TransferPoint {
        uint32 epoch;
        uint96 balance;
    }
    struct EpochConfig {
        uint32 epoch;
        uint32 blocks;
        uint32 roi;
    }
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
    mapping (address => mapping (uint32 => TransferPoint)) public transferPoints;
    mapping (address => uint32) public numCheckpoints;
    mapping (address => uint32) public numTransferPoints;
    mapping (address => uint96) public claimedAmounts;
    EpochConfig[] public epochConfigs;
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    mapping (address => uint) public nonces;
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    event EpochConfigChanged(uint32 indexed previousEpoch, uint32 previousBlocks, uint32 previousROI, uint32 indexed newEpoch, uint32 newBlocks, uint32 newROI);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    constructor(address account) public {
        EpochConfig memory newEpochConfig = EpochConfig(
            0,
            24 * 60 * 60 / 3, // 1 day blocks in BSC
            20 // 0.2% ROI increase per epoch
        );
        epochConfigs.push(newEpochConfig);
        emit EpochConfigChanged(0, 0, 0, newEpochConfig.epoch, newEpochConfig.blocks, newEpochConfig.roi);
        balances[account] = uint96(totalSupply);
        _writeTransferPoint(address(0), account, 0, 0, uint96(totalSupply));
        emit Transfer(address(0), account, totalSupply);
    }
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }
    function approve(address spender, uint rawAmount) external returns (bool) {
        uint96 amount;
        if (rawAmount == uint(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(rawAmount, "ANN::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }
    function transfer(address dst, uint rawAmount) external  returns (bool) {
        uint96 amount = safe96(rawAmount, "ANN::transfer: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }
    function transferFrom(address src, address dst, uint rawAmount) external  returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "ANN::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != uint96(-1)) {
            uint96 newAllowance = sub96(spenderAllowance, amount, "ANN::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }
    function delegate(address delegatee) public  {
        return _delegate(msg.sender, delegatee);
    }
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public  {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "ANN::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "ANN::delegateBySig: invalid nonce");
        require(now <= expiry, "ANN::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }
    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }
    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "ANN::getPriorVotes: not yet determined");
        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }
        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }
    function setEpochConfig(uint32 blocks, uint32 roi) public onlyOwner {
        require(blocks > 0, "ANN::setEpochConfig: zero blocks");
        require(roi < 10000, "ANN::setEpochConfig: roi exceeds max fraction");
        EpochConfig memory prevEC = epochConfigs[epochConfigs.length - 1];
        EpochConfig memory newEC = EpochConfig(getEpochs(block.number), blocks, roi);
        require(prevEC.blocks != newEC.blocks || prevEC.roi != newEC.roi, "ANN::setEpochConfig: blocks and roi same as before");
        if (prevEC.epoch == newEC.epoch) {
            epochConfigs[epochConfigs.length - 1] = newEC;
        } else {
            epochConfigs.push(newEC);
        }
        emit EpochConfigChanged(prevEC.epoch, prevEC.blocks, prevEC.roi, newEC.epoch, newEC.blocks, newEC.roi);
    }
    function getCurrentEpochBlocks() public view returns (uint32 blocks) {
        blocks = epochConfigs[epochConfigs.length - 1].blocks;
    }
    function getCurrentEpochROI() public view returns (uint32 roi) {
        roi = epochConfigs[epochConfigs.length - 1].roi;
    }
    function getCurrentEpochConfig() public view returns (uint32 epoch, uint32 blocks, uint32 roi) {
        EpochConfig memory ec = epochConfigs[epochConfigs.length - 1];
        epoch = ec.epoch;
        blocks = ec.blocks;
        roi = ec.roi;
    }
    function getEpochConfig(uint32 forEpoch) public view returns (uint32 index, uint32 epoch, uint32 blocks, uint32 roi) {
        index = uint32(epochConfigs.length - 1);
        for (; index > 0; index--) {
            if (forEpoch >= epochConfigs[index].epoch) {
                break;
            }
        }
        EpochConfig memory ec = epochConfigs[index];
        epoch = ec.epoch;
        blocks = ec.blocks;
        roi = ec.roi;
    }
    function getEpochs(uint blockNumber) public view returns (uint32) {
        uint96 blocks = 0;
        uint96 epoch = 0;
        uint blockNum = blockNumber;
        for (uint32 i = 0; i < epochConfigs.length; i++) {
            uint96 deltaBlocks = (uint96(epochConfigs[i].epoch) - epoch) * blocks;
            if (blockNum < deltaBlocks) {
                break;
            }
            blockNum = blockNum - deltaBlocks;
            epoch = epochConfigs[i].epoch;
            blocks = epochConfigs[i].blocks;
        }

        if (blocks == 0) {
            blocks = getCurrentEpochBlocks();
        }
        epoch = epoch + uint96(blockNum / blocks);
        if (epoch >= 2**32) {
            epoch = 2**32 - 1;
        }
        return uint32(epoch);
    }
    function getHoldingReward(address account) public view returns (uint96) {
        uint32 nTransferPoint = numTransferPoints[account];
        if (nTransferPoint == 0) {
            return 0;
        }
        uint32 lastEpoch = getEpochs(block.number);
        if (lastEpoch == 0) {
            return 0;
        }
        lastEpoch = lastEpoch - 1;
        if (lastEpoch < eligibleEpochs) {
            return 0;
        } else {
            uint32 lastEligibleEpoch = lastEpoch - eligibleEpochs;
            if (transferPoints[account][0].epoch > lastEligibleEpoch) {
                return 0;
            }
            if (transferPoints[account][nTransferPoint - 1].epoch <= lastEligibleEpoch) {
                nTransferPoint = nTransferPoint - 1;
            } else {
                uint32 upper = nTransferPoint - 1;
                nTransferPoint = 0;
                while (upper > nTransferPoint) {
                    uint32 center = upper - (upper - nTransferPoint) / 2; // ceil, avoiding overflow
                    TransferPoint memory tp = transferPoints[account][center];
                    if (tp.epoch == lastEligibleEpoch) {
                        nTransferPoint = center;
                        break;
                    } if (tp.epoch < lastEligibleEpoch) {
                        nTransferPoint = center;
                    } else {
                        upper = center - 1;
                    }
                }
            }
        }
        uint256 reward = 0;
        for (uint32 iTP = 0; iTP <= nTransferPoint; iTP++) {
            TransferPoint memory tp = transferPoints[account][iTP];
            (uint32 iEC,,,uint32 roi) = getEpochConfig(tp.epoch);
            uint32 startEpoch = tp.epoch;
            for (; iEC < epochConfigs.length; iEC++) {
                uint32 epoch = lastEpoch;
                bool tookNextTP = false;
                if (iEC < (epochConfigs.length - 1) && epoch > epochConfigs[iEC + 1].epoch) {
                    epoch = epochConfigs[iEC + 1].epoch;
                }
                if (iTP < nTransferPoint && epoch > transferPoints[account][iTP + 1].epoch) {
                    epoch = transferPoints[account][iTP + 1].epoch;
                    tookNextTP = true;
                }
                reward = reward + (uint256(tp.balance) * roi * sub32(epoch, startEpoch, "ANN::getHoldingReward: invalid epochs"));
                if (tookNextTP) {
                    break;
                }
                startEpoch = epoch;
                if (iEC < (epochConfigs.length - 1)) {
                    roi = epochConfigs[iEC + 1].roi;
                }
            }
        }
        uint96 amount = safe96(reward / 10000, "ANN::getHoldingReward: reward exceeds 96 bits");
        if (claimedAmounts[account] > 0) {
            amount = sub96(amount, claimedAmounts[account], "ANN::getHoldingReward: invalid claimed amount");
        }

        return amount;
    }
    function claimReward() public  {
        uint96 holdingReward = getHoldingReward(msg.sender);
        if (balances[address(this)] < holdingReward) {
            holdingReward = balances[address(this)];
        }
        claimedAmounts[msg.sender] = add96(claimedAmounts[msg.sender], holdingReward, "ANN::claimReward: invalid claimed amount");
        _transferTokens(address(this), msg.sender, holdingReward);
    }
    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;
        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }
    function _transferTokens(address src, address dst, uint96 amount) internal {
        require(src != address(0), "ANN::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "ANN::_transferTokens: cannot transfer to the zero address");
        balances[src] = sub96(balances[src], amount, "ANN::_transferTokens: transfer amount exceeds balance");
        balances[dst] = add96(balances[dst], amount, "ANN::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);
        _moveDelegates(delegates[src], delegates[dst], amount);
        if (amount > 0) {
            _writeTransferPoint(src, dst, numTransferPoints[dst], balances[src], balances[dst]);
        }
    }
    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "ANN::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }
            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "ANN::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }
    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {
      uint32 blockNumber = safe32(block.number, "ANN::_writeCheckpoint: block number exceeds 32 bits");
      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }
      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
    function _writeTransferPoint(address src, address dst, uint32 nDstPoint, uint96 srcBalance, uint96 dstBalance) internal {
        uint32 epoch = getEpochs(block.number);
        if (src != address(this)) {
            for (uint32 i = 0; i < numTransferPoints[src]; i++) {
                delete transferPoints[src][i];
            }
            claimedAmounts[src] = 0;
            if (srcBalance > 0) {
                transferPoints[src][0] = TransferPoint(epoch, srcBalance);
                numTransferPoints[src] = 1;
            } else {
                numTransferPoints[src] = 0;
            }
        }
        if (dst != address(this)) {
            if (nDstPoint > 0 && transferPoints[dst][nDstPoint - 1].epoch >= epoch) {
                transferPoints[dst][nDstPoint - 1].balance = dstBalance;
            } else {
                transferPoints[dst][nDstPoint] = TransferPoint(epoch, dstBalance);
                numTransferPoints[dst] = nDstPoint + 1;
            }
        }
    }
    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }
    function add32(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }
    function sub32(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }
    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }
    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

pragma solidity >=0.5.16;

contract LibNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  usr,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {
        _;
        assembly {
            let mark := msize()                       // end of memory ensures zero
            mstore(0x40, add(mark, 288))              // update free memory pointer
            mstore(mark, 0x20)                        // bytes type data offset
            mstore(add(mark, 0x20), 224)              // bytes size (padded)
            calldatacopy(add(mark, 0x40), 0, 224)     // bytes payload
            log4(mark, 288,                           // calldata
                 shl(224, shr(224, calldataload(0))), // msg.sig
                 caller(),                            // msg.sender
                 calldataload(4),                     // arg1
                 calldataload(36)                     // arg2
                )
        }
    }
}
pragma solidity >=0.5.16;

contract XAI is LibNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) external note auth { wards[guy] = 1; }
    function deny(address guy) external note auth { wards[guy] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "XAI/not-authorized");
        _;
    }

    // --- BEP20 Data ---
    string  public constant name     = "XAI Stablecoin";
    string  public constant symbol   = "XAI";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;
    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint)                      public nonces;
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    // --- Math ---
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "XAI math error");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "XAI math error");
    }
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;
    constructor(uint256 chainId_) public {
        wards[msg.sender] = 1;
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId_,
            address(this)
        ));
    }
    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        public returns (bool)
    {
        require(balanceOf[src] >= wad, "XAI/insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "XAI/insufficient-allowance");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }
    function mint(address usr, uint wad) external auth {
        balanceOf[usr] = add(balanceOf[usr], wad);
        totalSupply = add(totalSupply, wad);
        emit Transfer(address(0), usr, wad);
    }
    function burn(address usr, uint wad) external {
        require(balanceOf[usr] >= wad, "XAI/insufficient-balance");
        if (usr != msg.sender && allowance[usr][msg.sender] != uint(-1)) {
            require(allowance[usr][msg.sender] >= wad, "XAI/insufficient-allowance");
            allowance[usr][msg.sender] = sub(allowance[usr][msg.sender], wad);
        }
        balanceOf[usr] = sub(balanceOf[usr], wad);
        totalSupply = sub(totalSupply, wad);
        emit Transfer(usr, address(0), wad);
    }
    function approve(address usr, uint wad) external returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }
    function push(address usr, uint wad) external {
        transferFrom(msg.sender, usr, wad);
    }
    function pull(address usr, uint wad) external {
        transferFrom(usr, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) external {
        transferFrom(src, dst, wad);
    }
    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external
    {
        bytes32 digest = keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH,
                                     holder,
                                     spender,
                                     nonce,
                                     expiry,
                                     allowed))
        ));

        require(holder != address(0), "XAI/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "XAI/invalid-permit");
        require(expiry == 0 || now <= expiry, "XAI/permit-expired");
        require(nonce == nonces[holder]++, "XAI/invalid-nonce");
        uint wad = allowed ? uint(-1) : 0;
        allowance[holder][spender] = wad;
        emit Approval(holder, spender, wad);
    }
}
pragma solidity ^0.5.16;
contract Comptroller is ComptrollerV5Storage, ComptrollerInterfaceG2, ComptrollerErrorReporter, ExponentialNoError {
    event MarketListed(AToken aToken);
    event MarketEntered(AToken aToken, address account);
    event MarketExited(AToken aToken, address account);
    event NewCloseFactor(uint oldCloseFactorMantissa, uint newCloseFactorMantissa);
    event NewCollateralFactor(AToken aToken, uint oldCollateralFactorMantissa, uint newCollateralFactorMantissa);
    event NewLiquidationIncentive(uint oldLiquidationIncentiveMantissa, uint newLiquidationIncentiveMantissa);
    event NewPriceOracle(PriceOracle oldPriceOracle, PriceOracle newPriceOracle);
    event NewXAIVaultInfo(address vault_, uint releaseStartBlock_, uint releaseInterval_);
    event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);
    event ActionPaused(string action, bool pauseState);
    event ActionPaused(AToken aToken, string action, bool pauseState);
    event NewAnnexXAIRate(uint oldAnnexXAIRate, uint newAnnexXAIRate);
    event NewAnnexXAIVaultRate(uint oldAnnexXAIVaultRate, uint newAnnexXAIVaultRate);
    event AnnexBorrowSpeedUpdated(AToken indexed aToken, uint oldSpeed, uint newSpeed);
    event AnnexSupplySpeedUpdated(AToken indexed aToken, uint oldSpeed, uint newSpeed);
    event DistributedSupplierAnnex(AToken indexed aToken, address indexed supplier, uint annexDelta, uint annexSupplyIndex);
    event DistributedBorrowerAnnex(AToken indexed aToken, address indexed borrower, uint annexDelta, uint annexBorrowIndex);
    event DistributedXAIMinterAnnex(address indexed xaiMinter, uint annexDelta, uint annexXAIMintIndex);
    event DistributedXAIVaultAnnex(uint amount);
    event NewXAIController(XAIControllerInterface oldXAIController, XAIControllerInterface newXAIController);
    event NewXAIMintRate(uint oldXAIMintRate, uint newXAIMintRate);
    event ActionProtocolPaused(bool state);
    event NewBorrowCap(AToken indexed aToken, uint newBorrowCap);
    event NewBorrowCapGuardian(address oldBorrowCapGuardian, address newBorrowCapGuardian);
    event NewTreasuryGuardian(address oldTreasuryGuardian, address newTreasuryGuardian);
    event NewTreasuryAddress(address oldTreasuryAddress, address newTreasuryAddress);
    event NewTreasuryPercent(uint oldTreasuryPercent, uint newTreasuryPercent);
    uint public constant annexClaimThreshold = 0.001e18;
    event AnnexGranted(address recipient, uint amount);
    uint224 public constant annexInitialIndex = 1e36;
    uint internal constant closeFactorMinMantissa = 0.05e18; // 0.05
    uint internal constant closeFactorMaxMantissa = 0.9e18; // 0.9
    uint internal constant collateralFactorMaxMantissa = 0.9e18; // 0.9
    constructor() public {
        admin = msg.sender;
    }
    modifier onlyProtocolAllowed {
        require(!protocolPaused, "protocol is paused");
        _;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can");
        _;
    }
    modifier onlyListedMarket(AToken aToken) {
        require(markets[address(aToken)].isListed, "annex market is not listed");
        _;
    }
    modifier validPauseState(bool state) {
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can");
        require(msg.sender == admin || state, "only admin can unpause");
        _;
    }
    function getAssetsIn(address account) external view returns (AToken[] memory) {
        return accountAssets[account];
    }
    function checkMembership(address account, AToken aToken) external view returns (bool) {
        return markets[address(aToken)].accountMembership[account];
    }
    function enterMarkets(address[] calldata aTokens) external returns (uint[] memory) {
        uint len = aTokens.length;
        uint[] memory results = new uint[](len);
        for (uint i = 0; i < len; i++) {
            results[i] = uint(addToMarketInternal(AToken(aTokens[i]), msg.sender));
        }
        return results;
    }
    function addToMarketInternal(AToken aToken, address borrower) internal returns (Error) {
        Market storage marketToJoin = markets[address(aToken)];
        if (!marketToJoin.isListed) {
            return Error.MARKET_NOT_LISTED;
        }
        if (marketToJoin.accountMembership[borrower]) {
            // already joined
            return Error.NO_ERROR;
        }
        marketToJoin.accountMembership[borrower] = true;
        accountAssets[borrower].push(aToken);
        emit MarketEntered(aToken, borrower);
        return Error.NO_ERROR;
    }
    function exitMarket(address aTokenAddress) external returns (uint) {
        AToken aToken = AToken(aTokenAddress);
        (uint oErr, uint tokensHeld, uint amountOwed, ) = aToken.getAccountSnapshot(msg.sender);
        require(oErr == 0, "getAccountSnapshot failed"); // semi-opaque error code
        if (amountOwed != 0) {
            return fail(Error.NONZERO_BORROW_BALANCE, FailureInfo.EXIT_MARKET_BALANCE_OWED);
        }
        uint allowed = redeemAllowedInternal(aTokenAddress, msg.sender, tokensHeld);
        if (allowed != 0) {
            return failOpaque(Error.REJECTION, FailureInfo.EXIT_MARKET_REJECTION, allowed);
        }
        Market storage marketToExit = markets[address(aToken)];
        if (!marketToExit.accountMembership[msg.sender]) {
            return uint(Error.NO_ERROR);
        }
        delete marketToExit.accountMembership[msg.sender];
        AToken[] storage userAssetList = accountAssets[msg.sender];
        uint len = userAssetList.length;
        uint i;
        for (; i < len; i++) {
            if (userAssetList[i] == aToken) {
                userAssetList[i] = userAssetList[len - 1];
                userAssetList.length--;
                break;
            }
        }
        assert(i < len);
        emit MarketExited(aToken, msg.sender);
        return uint(Error.NO_ERROR);
    }
    function mintAllowed(address aToken, address minter, uint mintAmount) external onlyProtocolAllowed returns (uint) {
        require(!mintGuardianPaused[aToken], "mint is paused");
        mintAmount;
        if (!markets[aToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }
        updateAnnexSupplyIndex(aToken);
        distributeSupplierAnnex(aToken, minter,false);
        return uint(Error.NO_ERROR);
    }
    function mintVerify(address aToken, address minter, uint actualMintAmount, uint mintTokens) external {
        // Shh - currently unused
        aToken;
        minter;
        actualMintAmount;
        mintTokens;
    }
    function redeemAllowed(address aToken, address redeemer, uint redeemTokens) external onlyProtocolAllowed returns (uint) {
        uint allowed = redeemAllowedInternal(aToken, redeemer, redeemTokens);
        if (allowed != uint(Error.NO_ERROR)) {
            return allowed;
        }
        updateAnnexSupplyIndex(aToken);
        distributeSupplierAnnex(aToken, redeemer,false);
        return uint(Error.NO_ERROR);
    }
    function redeemAllowedInternal(address aToken, address redeemer, uint redeemTokens) internal view returns (uint) {
        if (!markets[aToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }
        if (!markets[aToken].accountMembership[redeemer]) {
            return uint(Error.NO_ERROR);
        }
        (Error err, , uint shortfall) = getHypotheticalAccountLiquidityInternal(redeemer, AToken(aToken), redeemTokens, 0);
        if (err != Error.NO_ERROR) {
            return uint(err);
        }
        if (shortfall != 0) {
            return uint(Error.INSUFFICIENT_LIQUIDITY);
        }
        return uint(Error.NO_ERROR);
    }
    function redeemVerify(address aToken, address redeemer, uint redeemAmount, uint redeemTokens) external {
        // Shh - currently unused
        aToken;
        redeemer;
        require(redeemTokens != 0 || redeemAmount == 0, "redeemTokens zero");
    }
    function borrowAllowed(address aToken, address borrower, uint borrowAmount) external onlyProtocolAllowed returns (uint) {
        require(!borrowGuardianPaused[aToken], "borrow is paused");
        if (!markets[aToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }
        if (!markets[aToken].accountMembership[borrower]) {
            require(msg.sender == aToken, "sender must be aToken");
            Error err = addToMarketInternal(AToken(aToken), borrower);
            if (err != Error.NO_ERROR) {
                return uint(err);
            }
        }
        if (oracle.getUnderlyingPrice(AToken(aToken)) == 0) {
            return uint(Error.PRICE_ERROR);
        }
        uint borrowCap = borrowCaps[aToken];
        if (borrowCap != 0) {
            uint totalBorrows = AToken(aToken).totalBorrows();
            uint nextTotalBorrows = add_(totalBorrows, borrowAmount);
            require(nextTotalBorrows < borrowCap, "market borrow cap reached");
        }
        (Error err, , uint shortfall) = getHypotheticalAccountLiquidityInternal(borrower, AToken(aToken), 0, borrowAmount);
        if (err != Error.NO_ERROR) {
            return uint(err);
        }
        if (shortfall != 0) {
            return uint(Error.INSUFFICIENT_LIQUIDITY);
        }
        Exp memory borrowIndex = Exp({mantissa: AToken(aToken).borrowIndex()});
        updateAnnexBorrowIndex(aToken, borrowIndex);
        distributeBorrowerAnnex(aToken, borrower, borrowIndex,false);
        return uint(Error.NO_ERROR);
    }
    function borrowVerify(address aToken, address borrower, uint borrowAmount) external {
        // Shh - currently unused
        aToken;
        borrower;
        borrowAmount;
        if (false) {
            maxAssets = maxAssets;
        }
    }
    function repayBorrowAllowed(
        address aToken,
        address payer,
        address borrower,
        uint repayAmount) external onlyProtocolAllowed returns (uint) {
        payer;
        borrower;
        repayAmount;
        if (!markets[aToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }
        Exp memory borrowIndex = Exp({mantissa: AToken(aToken).borrowIndex()});
        updateAnnexBorrowIndex(aToken, borrowIndex);
        distributeBorrowerAnnex(aToken, borrower, borrowIndex,false);
        return uint(Error.NO_ERROR);
    }
    function repayBorrowVerify(
        address aToken,
        address payer,
        address borrower,
        uint actualRepayAmount,
        uint borrowerIndex) external {
        aToken;
        payer;
        borrower;
        actualRepayAmount;
        borrowerIndex;
        if (false) {
            maxAssets = maxAssets;
        }
    }
    function liquidateBorrowAllowed(
        address aTokenBorrowed,
        address aTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external onlyProtocolAllowed returns (uint) {
        liquidator;
        if (!(markets[aTokenBorrowed].isListed || address(aTokenBorrowed) == address(xaiController)) || !markets[aTokenCollateral].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }
        (Error err, , uint shortfall) = getHypotheticalAccountLiquidityInternal(borrower, AToken(0), 0, 0);
        if (err != Error.NO_ERROR) {
            return uint(err);
        }
        if (shortfall == 0) {
            return uint(Error.INSUFFICIENT_SHORTFALL);
        }
        uint borrowBalance;
        if (address(aTokenBorrowed) != address(xaiController)) {
            borrowBalance = AToken(aTokenBorrowed).borrowBalanceStored(borrower);
        } else {
            borrowBalance = mintedXAIs[borrower];
        }
        uint maxClose = mul_ScalarTruncate(Exp({mantissa: closeFactorMantissa}), borrowBalance);
        if (repayAmount > maxClose) {
            return uint(Error.TOO_MUCH_REPAY);
        }
        return uint(Error.NO_ERROR);
    }
    function liquidateBorrowVerify(
        address aTokenBorrowed,
        address aTokenCollateral,
        address liquidator,
        address borrower,
        uint actualRepayAmount,
        uint seizeTokens) external {
        aTokenBorrowed;
        aTokenCollateral;
        liquidator;
        borrower;
        actualRepayAmount;
        seizeTokens;
        if (false) {
            maxAssets = maxAssets;
        }
    }
    function seizeAllowed(
        address aTokenCollateral,
        address aTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external onlyProtocolAllowed returns (uint) {
        require(!seizeGuardianPaused, "seize is paused");
        seizeTokens;
        if (!markets[aTokenCollateral].isListed || !(markets[aTokenBorrowed].isListed || address(aTokenBorrowed) == address(xaiController))) {
            return uint(Error.MARKET_NOT_LISTED);
        }
        if (AToken(aTokenCollateral).comptroller() != AToken(aTokenBorrowed).comptroller()) {
            return uint(Error.COMPTROLLER_MISMATCH);
        }
        updateAnnexSupplyIndex(aTokenCollateral);
        distributeSupplierAnnex(aTokenCollateral, borrower,false);
        distributeSupplierAnnex(aTokenCollateral, liquidator,false);
        return uint(Error.NO_ERROR);
    }
    function seizeVerify(
        address aTokenCollateral,
        address aTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external {
        aTokenCollateral;
        aTokenBorrowed;
        liquidator;
        borrower;
        seizeTokens;
        if (false) {
            maxAssets = maxAssets;
        }
    }
    function transferAllowed(address aToken, address src, address dst, uint transferTokens) external onlyProtocolAllowed returns (uint) {
        require(!transferGuardianPaused, "transfer is paused");
        uint allowed = redeemAllowedInternal(aToken, src, transferTokens);
        if (allowed != uint(Error.NO_ERROR)) {
            return allowed;
        }
        updateAnnexSupplyIndex(aToken);
        distributeSupplierAnnex(aToken, src,false);
        distributeSupplierAnnex(aToken, dst,false);
        return uint(Error.NO_ERROR);
    }
    function transferVerify(address aToken, address src, address dst, uint transferTokens) external {
        aToken;
        src;
        dst;
        transferTokens;
        if (false) {
            maxAssets = maxAssets;
        }
    }
    struct AccountLiquidityLocalVars {
        uint sumCollateral;
        uint sumBorrowPlusEffects;
        uint aTokenBalance;
        uint borrowBalance;
        uint exchangeRateMantissa;
        uint oraclePriceMantissa;
        Exp collateralFactor;
        Exp exchangeRate;
        Exp oraclePrice;
        Exp tokensToDenom;
    }
    function getAccountLiquidity(address account) public view returns (uint, uint, uint) {
        (Error err, uint liquidity, uint shortfall) = getHypotheticalAccountLiquidityInternal(account, AToken(0), 0, 0);
        return (uint(err), liquidity, shortfall);
    }
    function getHypotheticalAccountLiquidity(
        address account,
        address aTokenModify,
        uint redeemTokens,
        uint borrowAmount) public view returns (uint, uint, uint) {
        (Error err, uint liquidity, uint shortfall) = getHypotheticalAccountLiquidityInternal(account, AToken(aTokenModify), redeemTokens, borrowAmount);
        return (uint(err), liquidity, shortfall);
    }
    function getHypotheticalAccountLiquidityInternal(
        address account,
        AToken aTokenModify,
        uint redeemTokens,
        uint borrowAmount) internal view returns (Error, uint, uint) {
        AccountLiquidityLocalVars memory vars; // Holds all our calculation results
        uint oErr;
        AToken[] memory assets = accountAssets[account];
        for (uint i = 0; i < assets.length; i++) {
            AToken asset = assets[i];
            (oErr, vars.aTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) = asset.getAccountSnapshot(account);
            if (oErr != 0) { // semi-opaque error code, we assume NO_ERROR == 0 is invariant between upgrades
                return (Error.SNAPSHOT_ERROR, 0, 0);
            }
            vars.collateralFactor = Exp({mantissa: markets[address(asset)].collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});
            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
            if (vars.oraclePriceMantissa == 0) {
                return (Error.PRICE_ERROR, 0, 0);
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});
            vars.tokensToDenom = mul_(mul_(vars.collateralFactor, vars.exchangeRate), vars.oraclePrice);
            vars.sumCollateral = mul_ScalarTruncateAddUInt(vars.tokensToDenom, vars.aTokenBalance, vars.sumCollateral);
            vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, vars.sumBorrowPlusEffects);
            if (asset == aTokenModify) {
                vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.tokensToDenom, redeemTokens, vars.sumBorrowPlusEffects);
                vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, borrowAmount, vars.sumBorrowPlusEffects);
            }
        }
        vars.sumBorrowPlusEffects = add_(vars.sumBorrowPlusEffects, mintedXAIs[account]);
        if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
            return (Error.NO_ERROR, vars.sumCollateral - vars.sumBorrowPlusEffects, 0);
        } else {
            return (Error.NO_ERROR, 0, vars.sumBorrowPlusEffects - vars.sumCollateral);
        }
    }
    function liquidateCalculateSeizeTokens(address aTokenBorrowed, address aTokenCollateral, uint actualRepayAmount) external view returns (uint, uint) {
        uint priceBorrowedMantissa = oracle.getUnderlyingPrice(AToken(aTokenBorrowed));
        uint priceCollateralMantissa = oracle.getUnderlyingPrice(AToken(aTokenCollateral));
        if (priceBorrowedMantissa == 0 || priceCollateralMantissa == 0) {
            return (uint(Error.PRICE_ERROR), 0);
        }
        uint exchangeRateMantissa = AToken(aTokenCollateral).exchangeRateStored(); // Note: reverts on error
        uint seizeTokens;
        Exp memory numerator;
        Exp memory denominator;
        Exp memory ratio;
        numerator = mul_(Exp({mantissa: liquidationIncentiveMantissa}), Exp({mantissa: priceBorrowedMantissa}));
        denominator = mul_(Exp({mantissa: priceCollateralMantissa}), Exp({mantissa: exchangeRateMantissa}));
        ratio = div_(numerator, denominator);
        seizeTokens = mul_ScalarTruncate(ratio, actualRepayAmount);
        return (uint(Error.NO_ERROR), seizeTokens);
    }
    function liquidateXAICalculateSeizeTokens(address aTokenCollateral, uint actualRepayAmount) external view returns (uint, uint) {
        uint priceBorrowedMantissa = 1e18;  // Note: this is XAI
        uint priceCollateralMantissa = oracle.getUnderlyingPrice(AToken(aTokenCollateral));
        if (priceCollateralMantissa == 0) {
            return (uint(Error.PRICE_ERROR), 0);
        }
        uint exchangeRateMantissa = AToken(aTokenCollateral).exchangeRateStored(); // Note: reverts on error
        uint seizeTokens;
        Exp memory numerator;
        Exp memory denominator;
        Exp memory ratio;
        numerator = mul_(Exp({mantissa: liquidationIncentiveMantissa}), Exp({mantissa: priceBorrowedMantissa}));
        denominator = mul_(Exp({mantissa: priceCollateralMantissa}), Exp({mantissa: exchangeRateMantissa}));
        ratio = div_(numerator, denominator);
        seizeTokens = mul_ScalarTruncate(ratio, actualRepayAmount);
        return (uint(Error.NO_ERROR), seizeTokens);
    }
    function _setPriceOracle(PriceOracle newOracle) public returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PRICE_ORACLE_OWNER_CHECK);
        }
        PriceOracle oldOracle = oracle;
        oracle = newOracle;
        emit NewPriceOracle(oldOracle, newOracle);
        return uint(Error.NO_ERROR);
    }
    function _setCloseFactor(uint newCloseFactorMantissa) external returns (uint) {
    	require(msg.sender == admin, "only admin can set close factor");
        uint oldCloseFactorMantissa = closeFactorMantissa;
        closeFactorMantissa = newCloseFactorMantissa;
        emit NewCloseFactor(oldCloseFactorMantissa, newCloseFactorMantissa);
        return uint(Error.NO_ERROR);
    }
    function _setCollateralFactor(AToken aToken, uint newCollateralFactorMantissa) external returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_COLLATERAL_FACTOR_OWNER_CHECK);
        }
        Market storage market = markets[address(aToken)];
        if (!market.isListed) {
            return fail(Error.MARKET_NOT_LISTED, FailureInfo.SET_COLLATERAL_FACTOR_NO_EXISTS);
        }
        Exp memory newCollateralFactorExp = Exp({mantissa: newCollateralFactorMantissa});
        Exp memory highLimit = Exp({mantissa: collateralFactorMaxMantissa});
        if (lessThanExp(highLimit, newCollateralFactorExp)) {
            return fail(Error.INVALID_COLLATERAL_FACTOR, FailureInfo.SET_COLLATERAL_FACTOR_VALIDATION);
        }
        if (newCollateralFactorMantissa != 0 && oracle.getUnderlyingPrice(aToken) == 0) {
            return fail(Error.PRICE_ERROR, FailureInfo.SET_COLLATERAL_FACTOR_WITHOUT_PRICE);
        }
        uint oldCollateralFactorMantissa = market.collateralFactorMantissa;
        market.collateralFactorMantissa = newCollateralFactorMantissa;
        emit NewCollateralFactor(aToken, oldCollateralFactorMantissa, newCollateralFactorMantissa);

        return uint(Error.NO_ERROR);
    }
    function _setLiquidationIncentive(uint newLiquidationIncentiveMantissa) external returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_LIQUIDATION_INCENTIVE_OWNER_CHECK);
        }
        uint oldLiquidationIncentiveMantissa = liquidationIncentiveMantissa;
        liquidationIncentiveMantissa = newLiquidationIncentiveMantissa;
        emit NewLiquidationIncentive(oldLiquidationIncentiveMantissa, newLiquidationIncentiveMantissa);
        return uint(Error.NO_ERROR);
    }
    function _supportMarket(AToken aToken) external returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SUPPORT_MARKET_OWNER_CHECK);
        }
        if (markets[address(aToken)].isListed) {
            return fail(Error.MARKET_ALREADY_LISTED, FailureInfo.SUPPORT_MARKET_EXISTS);
        }
        aToken.isAToken(); // Sanity check to make sure its really a AToken
        require(aToken.isAToken(),"invalid aToken address");
        markets[address(aToken)] = Market({isListed: true, isAnnex: false, collateralFactorMantissa: 0});
        _addMarketInternal(aToken);
        _initializeMarket(aToken);
        emit MarketListed(aToken);
        return uint(Error.NO_ERROR);
    }
    function _initializeMarket(AToken aToken) internal {
        uint32 blockNumber = safe32(getBlockNumber(), "block number exceeds 32 bits");
        AnnexMarketState storage supplyState = annexSupplyState[address(aToken)];
        AnnexMarketState storage borrowState = annexBorrowState[address(aToken)];
        if (supplyState.index == 0) {
            supplyState.index = annexInitialIndex;
            supplyState.block = blockNumber;
        }
        if (borrowState.index == 0) {
            borrowState.index = annexInitialIndex;
            borrowState.block = blockNumber;
        }
        supplyState.block = borrowState.block = blockNumber;
    }
    function _addMarketInternal(AToken aToken) internal {
        for (uint i = 0; i < allMarkets.length; i ++) {
            require(allMarkets[i] != aToken, "market already added");
        }
        allMarkets.push(aToken);
    }
    function _setPauseGuardian(address newPauseGuardian) public returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PAUSE_GUARDIAN_OWNER_CHECK);
        }
        address oldPauseGuardian = pauseGuardian;
        pauseGuardian = newPauseGuardian;
        emit NewPauseGuardian(oldPauseGuardian, newPauseGuardian);
        return uint(Error.NO_ERROR);
    }
    function _setMarketBorrowCaps(AToken[] calldata aTokens, uint[] calldata newBorrowCaps) external {
        require(msg.sender == admin || msg.sender == borrowCapGuardian, "only admin or borrow cap guardian can set borrow caps");
        uint numMarkets = aTokens.length;
        uint numBorrowCaps = newBorrowCaps.length;
        require(numMarkets != 0 && numMarkets == numBorrowCaps, "invalid input");
        for(uint i = 0; i < numMarkets; i++) {
            borrowCaps[address(aTokens[i])] = newBorrowCaps[i];
            emit NewBorrowCap(aTokens[i], newBorrowCaps[i]);
        }
    }
    function _setBorrowCapGuardian(address newBorrowCapGuardian) external onlyAdmin {
        address oldBorrowCapGuardian = borrowCapGuardian;
        borrowCapGuardian = newBorrowCapGuardian;
        emit NewBorrowCapGuardian(oldBorrowCapGuardian, newBorrowCapGuardian);
    }
    function _setProtocolPaused(bool state) public validPauseState(state) returns(bool) {
        protocolPaused = state;
        emit ActionProtocolPaused(state);
        return state;
    }
    function _setXAIController(XAIControllerInterface xaiController_) external returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_XAICONTROLLER_OWNER_CHECK);
        }
        XAIControllerInterface oldRate = xaiController;
        xaiController = xaiController_;
        emit NewXAIController(oldRate, xaiController_);
    }
    function _setXAIMintRate(uint newXAIMintRate) external returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_XAI_MINT_RATE_CHECK);
        }
        uint oldXAIMintRate = xaiMintRate;
        xaiMintRate = newXAIMintRate;
        emit NewXAIMintRate(oldXAIMintRate, newXAIMintRate);
        return uint(Error.NO_ERROR);
    }
    function _setTreasuryData(address newTreasuryGuardian, address newTreasuryAddress, uint newTreasuryPercent) external returns (uint) {
        if (!(msg.sender == admin || msg.sender == treasuryGuardian)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_TREASURY_OWNER_CHECK);
        }
        require(newTreasuryPercent < 1e18, "treasury percent cap overflow");
        address oldTreasuryGuardian = treasuryGuardian;
        address oldTreasuryAddress = treasuryAddress;
        uint oldTreasuryPercent = treasuryPercent;
        treasuryGuardian = newTreasuryGuardian;
        treasuryAddress = newTreasuryAddress;
        treasuryPercent = newTreasuryPercent;
        emit NewTreasuryGuardian(oldTreasuryGuardian, newTreasuryGuardian);
        emit NewTreasuryAddress(oldTreasuryAddress, newTreasuryAddress);
        emit NewTreasuryPercent(oldTreasuryPercent, newTreasuryPercent);
        return uint(Error.NO_ERROR);
    }
    function _become(Unitroller unitroller) public {
        require(msg.sender == unitroller.admin(), "only unitroller admin can");
        require(unitroller._acceptImplementation() == 0, "not authorized");
        Comptroller(address(unitroller))._upgradeSplitANNRewards();
    }
    function _upgradeSplitANNRewards() public {
        require(msg.sender == comptrollerImplementation, "only brains can become itself");
        for (uint i = 0; i < allMarkets.length; i ++) {
            address market = address(allMarkets[i]);
            annexBorrowSpeeds[market] = annexSupplySpeeds[market] = annexSpeeds[market];
            delete annexSpeeds[market];
        }
    }
    function adminOrInitializing() internal view returns (bool) {
        return msg.sender == admin || msg.sender == comptrollerImplementation;
    }
    function setAnnexSpeedInternal(AToken aToken, uint newSupplySpeed, uint newBorrowSpeed) internal {
        Market storage market = markets[address(aToken)];
        require(market.isListed, "annex market is not listed");
        uint currentSupplySpeed = annexSupplySpeeds[address(aToken)];
        if (currentSupplySpeed != newSupplySpeed) {
            updateAnnexSupplyIndex(address(aToken));
            annexSupplySpeeds[address(aToken)] = newSupplySpeed;
            emit AnnexSupplySpeedUpdated(aToken, currentSupplySpeed, newSupplySpeed);
        }
        uint currentBorrowSpeed = annexBorrowSpeeds[address(aToken)];
        if (currentBorrowSpeed != newBorrowSpeed) {
            Exp memory borrowIndex = Exp({mantissa: aToken.borrowIndex()});
            updateAnnexBorrowIndex(address(aToken), borrowIndex);
            annexBorrowSpeeds[address(aToken)] = newBorrowSpeed;
            emit AnnexBorrowSpeedUpdated(aToken, currentBorrowSpeed, newBorrowSpeed);
        
    }

    }
    function updateAnnexSupplyIndex(address aToken) internal {
        AnnexMarketState storage supplyState = annexSupplyState[aToken];
        uint supplySpeed = annexSupplySpeeds[aToken];
        uint blockNumber = getBlockNumber();
        uint deltaBlocks = sub_(blockNumber, uint(supplyState.block));
        if (deltaBlocks > 0 && supplySpeed > 0) {
            uint supplyTokens = AToken(aToken).totalSupply();
            uint annexAccrued = mul_(deltaBlocks, supplySpeed);
            Double memory ratio = supplyTokens > 0 ? fraction(annexAccrued, supplyTokens) : Double({mantissa: 0});
            Double memory index = add_(Double({mantissa: supplyState.index}), ratio);
            annexSupplyState[aToken] = AnnexMarketState({
                index: safe224(index.mantissa, "new index overflows"),
                block: safe32(blockNumber, "block number overflows")
            });
        } else if (deltaBlocks > 0) {
            supplyState.block = safe32(blockNumber, "block number overflows");
        }
    }
    function updateAnnexBorrowIndex(address aToken, Exp memory marketBorrowIndex) internal {
        AnnexMarketState storage borrowState = annexBorrowState[aToken];
        uint borrowSpeed = annexBorrowSpeeds[aToken];
        uint blockNumber = getBlockNumber();
        uint deltaBlocks = sub_(blockNumber, uint(borrowState.block));
        if (deltaBlocks > 0 && borrowSpeed > 0) {
            uint borrowAmount = div_(AToken(aToken).totalBorrows(), marketBorrowIndex);
            uint annexAccrued = mul_(deltaBlocks, borrowSpeed);
            Double memory ratio = borrowAmount > 0 ? fraction(annexAccrued, borrowAmount) : Double({mantissa: 0});
            Double memory index = add_(Double({mantissa: borrowState.index}), ratio);
            annexBorrowState[aToken] = AnnexMarketState({
                index: safe224(index.mantissa, "new index overflows"),
                block: safe32(blockNumber, "block number overflows")
            });
        } else if (deltaBlocks > 0) {
            borrowState.block = safe32(blockNumber, "block number overflows");
        }
    }
    function distributeSupplierAnnex(address aToken, address supplier, bool distributeAll) internal {
        if (address(xaiVaultAddress) != address(0)) {
            releaseToVault();
        }
        AnnexMarketState storage supplyState = annexSupplyState[aToken];
        Double memory supplyIndex = Double({mantissa: supplyState.index});
        Double memory supplierIndex = Double({mantissa: annexSupplierIndex[aToken][supplier]});
        annexSupplierIndex[aToken][supplier] = supplyIndex.mantissa;
        if (supplierIndex.mantissa == 0 && supplyIndex.mantissa > 0) {
            supplierIndex.mantissa = annexInitialIndex;
        }
        Double memory deltaIndex = sub_(supplyIndex, supplierIndex);
        uint supplierTokens = AToken(aToken).balanceOf(supplier);
        uint supplierDelta = mul_(supplierTokens, deltaIndex);
        uint supplierAccrued = add_(annexAccrued[supplier], supplierDelta);
        annexAccrued[supplier] = transferAnnex(supplier, supplierAccrued, distributeAll ? 0 : annexClaimThreshold);
        emit DistributedSupplierAnnex(AToken(aToken), supplier, supplierDelta, supplyIndex.mantissa);
    }
    function distributeBorrowerAnnex(address aToken, address borrower, Exp memory marketBorrowIndex, bool distributeAll) internal {
        if (address(xaiVaultAddress) != address(0)) {
            releaseToVault();
        }
        AnnexMarketState storage borrowState = annexBorrowState[aToken];
        Double memory borrowIndex = Double({mantissa: borrowState.index});
        Double memory borrowerIndex = Double({mantissa: annexBorrowerIndex[aToken][borrower]});
        annexBorrowerIndex[aToken][borrower] = borrowIndex.mantissa;
        if (borrowerIndex.mantissa > 0) {
            Double memory deltaIndex = sub_(borrowIndex, borrowerIndex);
            uint borrowerAmount = div_(AToken(aToken).borrowBalanceStored(borrower), marketBorrowIndex);
            uint borrowerDelta = mul_(borrowerAmount, deltaIndex);
            uint borrowerAccrued = add_(annexAccrued[borrower], borrowerDelta);
            annexAccrued[borrower] = transferAnnex(borrower, borrowerAccrued, distributeAll ? 0 : annexClaimThreshold);
            emit DistributedBorrowerAnnex(AToken(aToken), borrower, borrowerDelta, borrowIndex.mantissa);
        }
    }
     function transferAnnex(address user, uint userAccrued, uint threshold) internal returns (uint) {
        if (userAccrued >= threshold && userAccrued > 0) {
            ANN ann = ANN(getANNAddress());
            uint annexRemaining = ann.balanceOf(address(this));
            if (userAccrued <= annexRemaining) {
                ann.transfer(user, userAccrued);
                return 0;
            }
        }
        return userAccrued;
    }
    function distributeXAIMinterAnnex(address xaiMinter) public {
        if (address(xaiVaultAddress) != address(0)) {
            releaseToVault();
        }
        if (address(xaiController) != address(0)) {
            uint xaiMinterAccrued;
            uint xaiMinterDelta;
            uint xaiMintIndexMantissa;
            uint err;
            (err, xaiMinterAccrued, xaiMinterDelta, xaiMintIndexMantissa) = xaiController.calcDistributeXAIMinterAnnex(xaiMinter);
            if (err == uint(Error.NO_ERROR)) {
                annexAccrued[xaiMinter] = xaiMinterAccrued;
                emit DistributedXAIMinterAnnex(xaiMinter, xaiMinterDelta, xaiMintIndexMantissa);
            }
        }
    }
    function claimAnnex(address holder) public {
        return claimAnnex(holder, allMarkets);
    }
    function claimAnnex(address holder, AToken[] memory aTokens) public {
        address[] memory holders = new address[](1);
        holders[0] = holder;
        claimAnnex(holders, aTokens, true, true);
    }
    function claimAnnex(address[] memory  holders, AToken[] memory aTokens, bool borrowers, bool suppliers) public {
        uint j;
        if(address(xaiController) != address(0)) {
            xaiController.updateAnnexXAIMintIndex();
        }
        for (j = 0; j < holders.length; j++) {
            distributeXAIMinterAnnex(holders[j]);
            annexAccrued[holders[j]] = grantANNInternal(holders[j], annexAccrued[holders[j]]);
        }
        for (uint i = 0; i < aTokens.length; i++) {
            AToken aToken = aTokens[i];
            require(markets[address(aToken)].isListed, "not listed market");
            if (borrowers) {
                Exp memory borrowIndex = Exp({mantissa: aToken.borrowIndex()});
                updateAnnexBorrowIndex(address(aToken), borrowIndex);
                for (j = 0; j < holders.length; j++) {
                    distributeBorrowerAnnex(address(aToken), holders[j], borrowIndex,true);
                    annexAccrued[holders[j]] = grantANNInternal(holders[j], annexAccrued[holders[j]]);
                }
            }
            if (suppliers) {
                updateAnnexSupplyIndex(address(aToken));
                for (j = 0; j < holders.length; j++) {
                    distributeSupplierAnnex(address(aToken), holders[j],true);
                    annexAccrued[holders[j]] = grantANNInternal(holders[j], annexAccrued[holders[j]]);
                }
            }
        }
    }
    function grantANNInternal(address user, uint amount) internal returns (uint) {
        ANN ann = ANN(getANNAddress());
        uint annexRemaining = ann.balanceOf(address(this));
        if (amount > 0 && amount <= annexRemaining) {
            ann.transfer(user, amount);
            return 0;
        }
        return amount;
    }
    function _grantANN(address recipient, uint amount) public {
        require(adminOrInitializing(), "only admin can grant ann");
        uint amountLeft = grantANNInternal(recipient, amount);
        require(amountLeft == 0, "insufficient ann for grant");
        emit AnnexGranted(recipient, amount);
    }
    function _setAnnexXAIRate(uint annexXAIRate_) public onlyAdmin {
        uint oldXAIRate = annexXAIRate;
        annexXAIRate = annexXAIRate_;
        emit NewAnnexXAIRate(oldXAIRate, annexXAIRate_);
    }
    function _setAnnexXAIVaultRate(uint annexXAIVaultRate_) public onlyAdmin {
        uint oldAnnexXAIVaultRate = annexXAIVaultRate;
        annexXAIVaultRate = annexXAIVaultRate_;
        emit NewAnnexXAIVaultRate(oldAnnexXAIVaultRate, annexXAIVaultRate_);
    }
    function _setXAIVaultInfo(address vault_, uint256 releaseStartBlock_, uint256 minReleaseAmount_) public onlyAdmin {
        xaiVaultAddress = vault_;
        releaseStartBlock = releaseStartBlock_;
        minReleaseAmount = minReleaseAmount_;
        emit NewXAIVaultInfo(vault_, releaseStartBlock_, minReleaseAmount_);
    }
    function _setAnnexSpeed(AToken aToken, uint newSupplySpeed, uint newBorrowSpeed) public {
        require(adminOrInitializing(), "only admin can set annex speed");
        setAnnexSpeedInternal(aToken, newSupplySpeed, newBorrowSpeed);
    }
    function getAllMarkets() public view returns (AToken[] memory) {
        return allMarkets;
    }
    function getBlockNumber() public view returns (uint) {
        return block.number;
    }
    function getANNAddress() public view returns (address) {
        return 0xb75f3F9D35d256a94BBd7A3fC2E16c768E17930E;
    }
    function setMintedXAIOf(address owner, uint amount) external onlyProtocolAllowed returns (uint) {
        require(!mintXAIGuardianPaused && !repayXAIGuardianPaused, "XAI is paused");
        if (msg.sender != address(xaiController)) {
            return fail(Error.REJECTION, FailureInfo.SET_MINTED_XAI_REJECTION);
        }
        mintedXAIs[owner] = amount;
        return uint(Error.NO_ERROR);
    }
    function releaseToVault() public {
        if(releaseStartBlock == 0 || getBlockNumber() < releaseStartBlock) {
            return;
        }
        ANN ann = ANN(getANNAddress());
        uint256 annBalance = ann.balanceOf(address(this));
        if(annBalance == 0) {
            return;
        }
        uint256 actualAmount;
        uint256 deltaBlocks = sub_(getBlockNumber(), releaseStartBlock);
        uint256 _releaseAmount = mul_(annexXAIVaultRate, deltaBlocks);
        if (_releaseAmount < minReleaseAmount) {
            return;
        }
        if (annBalance >= _releaseAmount) {
            actualAmount = _releaseAmount;
        } else {
            actualAmount = annBalance;
        }
        releaseStartBlock = getBlockNumber();
        ann.transfer(xaiVaultAddress, actualAmount);
        emit DistributedXAIVaultAnnex(actualAmount);
        IXAIVault(xaiVaultAddress).updatePendingRewards();
    }
}