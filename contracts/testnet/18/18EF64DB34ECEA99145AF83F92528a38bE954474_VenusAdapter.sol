// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../../libs/venus/VenusComptroller.sol";  
import "../../../libs/atlantis/ExponentialNoError.sol"; 
 
import "../../interfaces/ILendingAdapter.sol";

contract VenusAdapter is ILendingAdapter, ExponentialNoError {

    VenusComptroller public immutable comptroller;

    address constant NATIVE_TOKEN_ADDRESS = address(0x1E1e1E1E1e1e1e1e1e1E1E1E1E1e1e1E1e1e1E1E);
    bytes32 constant NATIVE_VTOKEN_NAME = keccak256("vBNB");

    constructor(VenusComptroller account) {
        comptroller = account;
    }

    function initialize() external {
        // empty by purpose
    }

    function getMarket(address asset) external view override returns(address platformToken) {
        VToken[] memory tokens = comptroller.getAllMarkets();
        for (uint i = 0; i < tokens.length; i++) {
            VToken aToken = tokens[i];
            if (_underlying(aToken) == asset)
                return address(aToken);
        }
        return address(0);
    }

    function getMarkets() external view override returns(MarketInfo[] memory markets) {
        VToken[] memory tokens = comptroller.getAllMarkets();
        markets = new MarketInfo[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            VToken aToken = tokens[i];
            markets[i].platformToken = address(aToken);
            markets[i].asset = _underlying(aToken);
        }
    }

    function rewardTokens() external view override returns(address[] memory) {
        
    }

    function underlying(address platformToken) public view override returns(address asset) {
        VToken vToken = VToken(platformToken);
        return _underlying(vToken);
    }

    function _underlying(VToken vToken) internal view returns(address asset) {
        if (compareStrings(vToken.symbol(), "vBNB"))  
            return address(0);
        return vToken.underlying();
    }

    function amountUnderlying(address platformToken, uint amount) public view override returns(uint) {
        VToken vToken = VToken(platformToken);
        Exp memory exchangeRate = Exp({mantissa: vToken.exchangeRateStored()});
        return mul_ScalarTruncate(exchangeRate, amount);
    }

    function isCollateral(address platformToken) external view override returns(bool) {
        return comptroller.checkMembership(msg.sender, platformToken); 
    }

    function enableCollateral(address platformToken) external override {
        address[] memory tokens = new address[](1);
        tokens[0] = platformToken;
        comptroller.enterMarkets(tokens);
    }

    function accountInfo() external view override
        returns(uint totalDeposit,
                uint totalCollateral,
                uint totalBorrow, 
                uint healthFactor) {
        (totalDeposit, totalCollateral, totalBorrow, healthFactor) = 
            _accountInfoInternal(msg.sender);
    }

    function deposit(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        token.mint(amount);
    }

    function withdraw(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        token.redeemUnderlying(amount);
    }

    function borrow(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        token.borrow(amount);
    }

    function repay(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        token.repayBorrow(amount);
    }

    function getBorrowableToken(address platformToken, uint expectedHealthFactor) external view override returns(uint) {
        (,uint totalCollateral, uint totalBorrow, uint healthFactor) = _accountInfoInternal(msg.sender);

        if (expectedHealthFactor >= healthFactor)
            return 0;
        VToken aToken = VToken(platformToken);
        uint extraBorrowAmount = totalCollateral / expectedHealthFactor - totalBorrow;

        uint oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(aToken);        
        Exp memory oraclePrice = Exp({mantissa: oraclePriceMantissa});

        uint borrowToken = div_(extraBorrowAmount, oraclePrice);
        return borrowToken;
    }

    function getWithdrawableToken(address platformToken, uint expectedHealthFactor) external view override returns(uint) {
        (,uint totalCollateral, uint totalBorrow, uint healthFactor) = _accountInfoInternal(msg.sender);

        if (expectedHealthFactor >= healthFactor)
            return 0;
        VToken aToken = VToken(platformToken);
        uint withdrawableAmount = totalCollateral - totalBorrow * expectedHealthFactor;

        uint oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(aToken);        
        Exp memory oraclePrice = Exp({mantissa: oraclePriceMantissa});

        uint withdrawToken = div_(withdrawableAmount, oraclePrice);
        return withdrawToken;
    }

    struct AccountLiquidityLocalVars {
        uint sumDeposit;
        uint sumCollateral;
        uint sumBorrow;
        uint aTokenBalance;
        uint borrowBalance;
        uint exchangeRateMantissa;
        uint oraclePriceMantissa;
        Exp collateralFactor;
        Exp exchangeRate;
        Exp oraclePrice;
        Exp tokensToDenom;
    }

    function _accountInfoInternal(address account) internal view 
        returns(uint totalDeposit, uint totalCollateral, uint totalBorrow, uint healthFactor) 
    {
        AccountLiquidityLocalVars memory vars;
        uint oErr;
        VToken[] memory assets = comptroller.getAssetsIn(account);
        for (uint i = 0; i < assets.length; i++) {
            VToken asset = assets[i];

            (bool isListed, uint collateralFactorMantissa) = comptroller.markets(address(asset));
            if (!isListed)
                continue;

            (oErr, vars.aTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) =
                asset.getAccountSnapshot(account);
            require(oErr == 0, "Altantis: error querying account snapshot");

            vars.collateralFactor = Exp({mantissa: collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});

            // Get the normalized price of the asset
            vars.oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(asset);
            if (vars.oraclePriceMantissa == 0) {
                continue;
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});

            // Pre-compute a conversion factor from tokens -> ether (normalized price value)
            vars.tokensToDenom = mul_(mul_(vars.collateralFactor, vars.exchangeRate), vars.oraclePrice);

            // sumDeposit += oraclePrice * aTokenBalance
            vars.sumDeposit = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.aTokenBalance, vars.sumDeposit);

            // sumCollateral += tokensToDenom * aTokenBalance
            vars.sumCollateral = mul_ScalarTruncateAddUInt(vars.tokensToDenom, vars.aTokenBalance, vars.sumCollateral);

            // sumBorrowPlusEffects += oraclePrice * borrowBalance
            vars.sumBorrow = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, vars.sumBorrow);
       }

       return (vars.sumDeposit, 
                vars.sumCollateral, 
                vars.sumBorrow, 
                vars.sumBorrow == 0 ? 0 : vars.sumCollateral * 10000 / vars.sumBorrow / 10000);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDefiAdapter {
    function underlying(address platformToken) external view returns(address);
    function amountUnderlying(address platformToken, uint amount) external view returns(uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IDefiAdapter.sol";

struct MarketInfo {
    address platformToken;
    address asset;
}

interface ILendingAdapter is IDefiAdapter {
    function getMarket(address asset) external view returns(address platformToken);
    function getMarkets() external view returns(MarketInfo[] memory markets);
    function isCollateral(address platformToken) external view returns(bool);
    function enableCollateral(address platformToken) external;
    function rewardTokens() external view returns(address[] memory);

    /**
    @notice healthFactor is stored scale 1e18, and should be greater than 1.0
            otherwise, the account will be liquidated.
     */
    function accountInfo() external view 
        returns(uint totalDeposit,
                uint totalCollateral, 
                uint totalBorrow, 
                uint healthFactor);

    function deposit(address platformToken, uint amount) external;
    function withdraw(address platformToken, uint amount) external;
    function borrow(address platformToken, uint amount) external;
    function repay(address platformToken, uint amount) external;

    function getBorrowableToken(address platformToken, uint expectedHealthFactor) external view returns(uint);
    function getWithdrawableToken(address platformToken, uint expectedHealthFactor) external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Atlantis
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
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

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) pure internal returns (uint) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface VenusComptroller {
    /// @notice Indicator that this is a Comptroller contract (for inspection)

    function oracle() external view returns(VenusPriceOracle);

    function getAllMarkets() external view returns (VToken[] memory);
    function markets(address vToken) external view returns(bool isListed, uint collateralFactorMantissa);

    function getAssetsIn(address account) external view returns (VToken[] memory);
    function checkMembership(address account, address aToken) external view returns (bool);

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata vTokens) external returns (uint[] memory);
    function exitMarket(address vToken) external returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address vToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address vToken, address minter, uint mintAmount, uint mintTokens) external;

    function redeemAllowed(address vToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address vToken, address redeemer, uint redeemAmount, uint redeemTokens) external;

    function borrowAllowed(address vToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address vToken, address borrower, uint borrowAmount) external;

    function repayBorrowAllowed(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;

    function liquidateBorrowAllowed(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;

    function seizeAllowed(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address vToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address vToken, address src, address dst, uint transferTokens) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address vTokenBorrowed,
        address vTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}

interface VToken {
    function underlying() external view returns(address);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function comptroller() external view returns(VenusComptroller);

    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function getCash() external view returns (uint);
    function accrueInterest() external returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);

    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
}

interface VenusPriceOracle {
    function getUnderlyingPrice(VToken aToken) external view returns (uint);
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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