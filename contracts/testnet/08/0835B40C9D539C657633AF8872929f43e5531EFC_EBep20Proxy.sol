// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ETokenInterfaces.sol";
import "./ErrorReporter.sol";
import "./Proxiable.sol";

contract EBep20Proxy is Proxiable, TokenErrorReporter, ETokenAdminStorage {
    
    constructor(address _implementation) public {
        // Set admin to caller
        admin = payable(msg.sender);
        _setImplementation(_implementation);
    }

    function _setImplementation(address newImplementation) public returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_IMPLEMENTATION_OWNER_CHECK);
        }
        _updateImplementAddress(newImplementation);
        return uint(Error.NO_ERROR);
    }
}

pragma solidity ^0.8.13;

import "./ComptrollerInterface.sol";
import "./InterestRateModel.sol";

contract ETokenAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;
}

contract ETokenStorage is ETokenAdminStorage{
    /**
     * @dev Guard variable for re-entrancy checks
     */
    bool internal _notEntered;

    /**
     * @notice EIP-20 token name for this token
     */
    string public name;

    /**
     * @notice EIP-20 token symbol for this token
     */
    string public symbol;

    /**
     * @notice EIP-20 token decimals for this token
     */
    uint8 public decimals;

    /**
     * @notice Maximum borrow rate that can ever be applied (.0005% / block)
     */

    uint internal constant borrowRateMaxMantissa = 0.0005e16;

    /**
     * @notice Maximum fraction of interest that can be set aside for reserves
     */
    uint internal constant reserveFactorMaxMantissa = 1e18;

    // /**
    //  * @notice Administrator for this contract
    //  */
    // address payable public admin;

    /**
     * @notice Pending administrator for this contract
     */
    address payable public pendingAdmin;

    /**
     * @notice Contract which oversees inter-eToken operations
     */
    ComptrollerInterface public comptroller;

    /**
     * @notice Model which tells what the current interest rate should be
     */
    InterestRateModel public interestRateModel;

    /**
     * @notice Initial exchange rate used when minting the first ETokens (used when totalSupply = 0)
     */
    uint internal initialExchangeRateMantissa;

    /**
     * @notice Fraction of interest currently set aside for reserves
     */
    uint public reserveFactorMantissa;

    /**
     * @notice Block number that interest was last accrued at
     */
    uint public accrualBlockNumber;

    /**
     * @notice Accumulator of the total earned interest rate since the opening of the market
     */
    uint public borrowIndex;

    /**
     * @notice Total amount of outstanding borrows of the underlying in this market
     */
    uint public totalBorrows;

    /**
     * @notice Total amount of reserves of the underlying held in this market
     */
    uint public totalReserves;

    /**
     * @notice Total number of tokens in circulation
     */
    uint public totalSupply;

    /**
     * @notice Official record of token balances for each account
     */
    mapping (address => uint) internal accountTokens;

    /**
     * @notice Approved token transfer amounts on behalf of others
     */
    mapping (address => mapping (address => uint)) internal transferAllowances;

    /**
     * @notice Container for borrow balance information
     * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
     * @member interestIndex Global borrowIndex as of the most recent balance-changing action
     */
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    /**
     * @notice Mapping of account addresses to outstanding borrow balances
     */
    mapping(address => BorrowSnapshot) internal accountBorrows;

    /**
     * @notice allow token to deposit
     */
    bool public depositAllowed;

    /**
     * @notice allow token to borrow
     */
    bool public borrowAllowed;

    /**
     * @notice allow token to deposit with specific address
     */
    bool public onlyWhiteListAllowToDeposit;

    /**
     * @notice set whitelist of deposit account
     */
    mapping(address => bool) public depositWhiteListAccounts;
}

abstract contract ETokenInterface is ETokenStorage {
    /**
     * @notice Indicator that this is a EToken contract (for inspection)
     */
    bool public constant isEToken = true;


    /*** Market Events ***/

    // /**
    //  * @notice Event emitted when interest is accrued
    //  */
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    // /**
    //  * @notice Event emitted when tokens are minted
    //  */
    event Mint(address minter, uint mintAmount, uint mintTokens);

    // /**
    //  * @notice Event emitted when tokens are minted behalf by payer to receiver
    //  */
    // event MintBehalf(address payer, address receiver, uint mintAmount, uint mintTokens);

    // /**
    //  * @notice Event emitted when tokens are redeemed
    //  */
    // event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    // /**
    //  * @notice Event emitted when tokens are redeemed and fee are transferred
    //  */
    // event RedeemFee(address redeemer, uint feeAmount, uint redeemTokens);

    // /**
    //  * @notice Event emitted when underlying is borrowed
    //  */
    // event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    // /**
    //  * @notice Event emitted when a borrow is repaid
    //  */
    // event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);

    // /**
    //  * @notice Event emitted when a borrow is liquidated
    //  */
    // event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address eTokenCollateral, uint seizeTokens);


    // /*** Admin Events ***/

    // /**
    //  * @notice Event emitted when pendingAdmin is changed
    //  */
    // event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    // /**
    //  * @notice Event emitted when pendingAdmin is accepted, which means admin is updated
    //  */
    // event NewAdmin(address oldAdmin, address newAdmin);

    // /**
    //  * @notice Event emitted when comptroller is changed
    //  */
    event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);

    // /**
    //  * @notice Event emitted when interestRateModel is changed
    //  */
    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

    // /**
    //  * @notice Event emitted when the reserve factor is changed
    //  */
    // event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    // /**
    //  * @notice Event emitted when the reserves are added
    //  */
    // event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

    // /**
    //  * @notice Event emitted when the reserves are reduced
    //  */
    // event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);

    // /**
    //  * @notice EIP20 Transfer event
    //  */
    event Transfer(address indexed from, address indexed to, uint amount);

    // /**
    //  * @notice EIP20 Approval event
    //  */
    // event Approval(address indexed owner, address indexed spender, uint amount);

    // /**
    //  * @notice Failure event
    //  */
    // event Failure(uint error, uint info, uint detail);

    // /**
    //  * @notice Emitted when _depositAllowed is changed
    //  */
    // event AllowTokenToDeposit(bool allow);

    // /**
    //  * @notice Emitted when _borrowAllowed is changed
    //  */
    // event AllowTokenToBorrow(bool allow);

    // /**
    //  * @notice Emitted when _onlyWhiteListAllowToDeposit is changed
    //  */
    // event AllowOnlyWhiteListToDeposit(bool allow);

    // /**
    //  * @notice Emitted when depositWhiteListAccounts is changed
    //  */
    // event DepositWhiteListAccountsSet(address whitelist, bool state);


    // /*** User Interface ***/

    // function transfer(address dst, uint amount) external virtual returns (bool);
    // function transferFrom(address src, address dst, uint amount) external virtual returns (bool);
    // function approve(address spender, uint amount) external virtual returns (bool);
    // function allowance(address owner, address spender) external view virtual returns (uint);
    function balanceOf(address owner) external view  virtual returns (uint);
    // function balanceOfUnderlying(address owner) external virtual returns (uint);
    function getAccountSnapshot(address account) external view virtual returns (uint, uint, uint, uint);
    // function borrowRatePerBlock() external view virtual returns (uint);
    // function supplyRatePerBlock() external view virtual returns (uint);
    // function totalBorrowsCurrent() external virtual returns (uint);
    // function borrowBalanceCurrent(address account) external virtual returns (uint);
    function borrowBalanceStored(address account) public view virtual returns (uint);
    // function exchangeRateCurrent() public virtual returns (uint);
    function exchangeRateStored() public view virtual returns (uint);
    // function getCash() external view virtual returns (uint);
    function accrueInterest() public virtual returns (uint);
    // function seize(address liquidator, address borrower, uint seizeTokens) external virtual returns (uint);


    // /*** Admin Functions ***/

    // function _setPendingAdmin(address payable newPendingAdmin) external virtual returns (uint);
    // function _acceptAdmin() external virtual returns (uint);
    function _setComptroller(ComptrollerInterface newComptroller) public virtual returns (uint);
    // function _setReserveFactor(uint newReserveFactorMantissa) external virtual returns (uint);
    // function _reduceReserves(uint reduceAmount) external virtual returns (uint);
    // function _setInterestRateModel(InterestRateModel newInterestRateModel) public virtual returns (uint);
    // function _setDepositAllowed(bool allow) public virtual returns (uint);
    // function _setBorrowAllowed(bool allow) public virtual returns (uint);
    // function _setOnlyWhiteListAllowToDeposit(bool allow) public virtual returns (uint);
    // function _setDepositWhiteListAccounts(address _toWhitelist, bool _state) public virtual returns (uint);
}

contract EBep20Storage {
    /**
     * @notice Underlying asset for this EToken
     */
    address public underlying;
}

abstract contract EBep20Interface is EBep20Storage {

    /*** User Interface ***/

    function mint(uint mintAmount, bool activateCollateral) external virtual returns (uint);
    // function redeem(uint redeemTokens) external virtual returns (uint);
    // function redeemUnderlying(uint redeemAmount) external virtual returns (uint);
    // function borrow(uint borrowAmount) external virtual returns (uint);
    // function repayBorrow(uint repayAmount) external virtual returns (uint);
    // function repayBorrowBehalf(address borrower, uint repayAmount) external virtual returns (uint);
    // function liquidateBorrow(address borrower, uint repayAmount, ETokenInterface eTokenCollateral) external virtual returns (uint);


    // /*** Admin Functions ***/

    // function _addReserves(uint addAmount) external virtual returns (uint);
}

contract EProxyStorage {
    bool public isEProxyStrorage;
}

pragma solidity ^0.8.13;

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
        TOO_MUCH_REPAY
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        ADD_TO_MARKET_REJECTION,
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
        SET_TREASURY_OWNER_CHECK
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event ErrorReporterFailure(uint error, uint info, uint detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit ErrorReporterFailure(uint(err), uint(info), 0);

        return uint(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit ErrorReporterFailure(uint(err), uint(info), opaqueError);

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

    /*
     * Note: FailureInfo (but not Error) is kept in alphabetical order
     *       This is because FailureInfo grows significantly faster, and
     *       the order of Error has some meaning, while the order of FailureInfo
     *       is entirely arbitrary.
     */
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
        BORROW_IS_NOT_ALLOWED,
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
        MINT_IS_NOT_ALLOWED,
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
        SET_BORROW_ALLOWED_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COMPTROLLER_OWNER_CHECK,
        SET_DEPOSIT_ALLOWED_OWNER_CHECK,
        SET_DEPOSIT_WHITELIST_ACCOUNTS_OWNER_CHECK,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ONLY_WHITELIST_ALLOW_TO_DEPOSIT_OWNER_CHECK,
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
        SFT_MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_FEE_CALCULATION_FAILED
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event ErrorReporterFailure(uint error, uint info, uint detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit ErrorReporterFailure(uint(err), uint(info), 0);

        return uint(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit ErrorReporterFailure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Proxiable {
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address public implementation;

    event NewImplementation(address oldImplementation, address newImplementation);

    function _updateImplementAddress( address newImplementation) internal {

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }

        // Save current values for inclusion in log
        address oldImplementation = implementation;
        implementation = newImplementation;

        emit NewImplementation(oldImplementation, implementation);
    }

    function _implementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }

    function _delegate(address implementation) internal {
        // solhint-disable-next-line no-inline-assembly
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

    fallback() external payable {
        _delegate(_implementation());
    }
}

pragma solidity ^0.8.13;

abstract contract ComptrollerInterfaceG1 {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata eTokens) external virtual returns (uint[] memory);
    function addToMarketByEToken(address eToken, address user) external virtual returns (uint);
    function exitMarket(address eToken) external virtual returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address eToken, address minter, uint mintAmount) external virtual returns (uint);
    function mintVerify(address eToken, address minter, uint mintAmount, uint mintTokens) external virtual;

    function redeemAllowed(address eToken, address redeemer, uint redeemTokens) external virtual returns (uint);
    function redeemVerify(address eToken, address redeemer, uint redeemAmount, uint redeemTokens) external virtual;

    function borrowAllowed(address eToken, address borrower, uint borrowAmount) external virtual returns (uint);
    function borrowVerify(address eToken, address borrower, uint borrowAmount) external virtual;

    function repayBorrowAllowed(
        address eToken,
        address payer,
        address borrower,
        uint repayAmount) external virtual returns (uint);
    function repayBorrowVerify(
        address eToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external virtual ;

    function liquidateBorrowAllowed(
        address eTokenBorrowed,
        address eTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external virtual returns (uint);
    function liquidateBorrowVerify(
        address eTokenBorrowed,
        address eTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external virtual;

    function seizeAllowed(
        address eTokenCollateral,
        address eTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external virtual returns (uint);
    function seizeVerify(
        address eTokenCollateral,
        address eTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external virtual;

    function transferAllowed(address eToken, address src, address dst, uint transferTokens) external virtual returns (uint);
    function transferVerify(address eToken, address src, address dst, uint transferTokens) external virtual;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address eTokenBorrowed,
        address eTokenCollateral,
        uint repayAmount) external view virtual returns (uint, uint);
}

abstract contract ComptrollerInterfaceG2 is ComptrollerInterfaceG1 {
}

abstract contract ComptrollerInterface is ComptrollerInterfaceG2 {
}

interface IComptroller {
    function liquidationIncentiveMantissa() external view returns (uint);
    /*** Treasury Data ***/
    function treasuryAddress() external view returns (address);
    function treasuryPercent() external view returns (uint);
}

pragma solidity ^0.8.13;

/**
  * @title Evry.Finance's InterestRateModel Interface
  * @author Evry.Finance
  */
abstract contract InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    bool public constant isInterestRateModel = true;

    /**
      * @notice Calculates the current borrow interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @return The borrow rate per block (as a percentage, and scaled by 1e18)
      */
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view virtual returns (uint);

    /**
      * @notice Calculates the current supply interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @param reserveFactorMantissa The current reserve factor the market has
      * @return The supply rate per block (as a percentage, and scaled by 1e18)
      */
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view virtual returns (uint);

}