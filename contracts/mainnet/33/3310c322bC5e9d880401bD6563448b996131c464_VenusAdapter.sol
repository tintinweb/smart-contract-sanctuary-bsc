// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../../libs/venus/VenusComptroller.sol";  
import "../../../libs/atlantis/ExponentialNoError.sol"; 
 
import "../../interfaces/ILendingAdapter.sol";
import "../../../common/Errors.sol";

contract VenusAdapter is ILendingAdapter, ExponentialNoError {

    VenusComptroller public immutable comptroller;
    address public immutable rewardToken;

    address constant NATIVE_TOKEN_ADDRESS = address(0x1E1e1E1E1e1e1e1e1e1E1E1E1E1e1e1E1e1e1E1E);
    bytes32 constant NATIVE_VTOKEN_NAME = keccak256("vBNB");

    constructor(VenusComptroller account, address _rewardToken) {
        comptroller = account;
        rewardToken = _rewardToken;
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
            VToken vToken = tokens[i];
            markets[i].platformToken = address(vToken);
            markets[i].asset = _underlying(vToken);
            markets[i].collateralFactor = collateralFactor(address(vToken));
        }
    }

    function rewardTokens() external view override returns(address[] memory result) {
        result = new address[](1);
        result[0] = rewardToken;
    }

    function underlying(address platformToken) public view override returns(address asset) {
        VToken vToken = VToken(platformToken);
        return _underlying(vToken);
    }

    function _underlying(VToken vToken) internal view returns(address asset) {
        if (compareStrings(vToken.symbol(), "vBNB"))  
            return NATIVE_TOKEN_ADDRESS;
        return vToken.underlying();
    }

    function amountUnderlying(address platformToken, uint amount) public view override returns(uint) {
        VToken vToken = VToken(platformToken);
        Exp memory exchangeRate = Exp({mantissa: vToken.exchangeRateStored()});
        return mul_ScalarTruncate(exchangeRate, amount);
    }

    function priceUnderlying(address platformToken) public view override returns(uint) {
        return comptroller.oracle().getUnderlyingPrice(VToken(platformToken));
    }

    function isCollateral(address account, address platformToken) external view override returns(bool) {
        return comptroller.checkMembership(account, platformToken); 
    }

    function collateralFactor(address platformToken) public view override returns(uint factor) {
        bool listed;
        (listed, factor, ) = comptroller.markets(platformToken);
        if (!listed)
            factor = 0;
    }

    function enableCollateral(address platformToken) external override {
        address[] memory tokens = new address[](1);
        tokens[0] = platformToken;
        comptroller.enterMarkets(tokens);
    }

    function accountInfo(address account) external view override
        returns(uint totalDeposit,
                uint totalCollateral,
                uint totalBorrow, 
                uint healthFactor) {
        (totalDeposit, totalCollateral, totalBorrow, healthFactor) = 
            _accountInfoInternal(account);
    }

    function accountInfo(address account, address platformToken) external view override 
        returns(uint depositToken, uint borrowToken) 
    {
        VToken vToken = VToken(platformToken);
        uint oErr;
        (oErr, depositToken, borrowToken, ) = vToken.getAccountSnapshot(account);
        if (oErr != 0) {
            depositToken = 0;
            borrowToken = 0;
        }
    }

    function rewardAccrued(address account) external view override returns(uint) {
        return comptroller.venusAccrued(account);
    }

    function deposit(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        IERC20 asset = IERC20(_underlying(token));
        if (address(asset) == NATIVE_TOKEN_ADDRESS) {
            // TODO handle native asset
        } else {
            if (asset.allowance(address(this), address(token)) < amount)
                asset.approve(address(token), type(uint).max);
            token.mint(amount);
        }
    }

    function withdraw(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        token.redeemUnderlying(amount);
    }

    function borrow(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        IERC20 asset = IERC20(underlying(platformToken));
        if (address(asset) != NATIVE_TOKEN_ADDRESS &&
            asset.allowance(address(this), platformToken) < amount) {
            asset.approve(platformToken, type(uint256).max);
        }
        token.borrow(amount);
    }

    function repay(address platformToken, uint amount) external override {
        VToken token = VToken(platformToken);
        token.repayBorrow(amount);
    }

    function harvestReward(address account) external override {  
        comptroller.claimVenus(account);
    }

    function getBorrowableToken(address account, address platformToken, uint expectedHealthFactor) 
        external view override returns(uint)  
    {
        require(expectedHealthFactor >= 1 ether, Errors.ILA_INVALID_EXPECTED_HEALTH_FACTOR);

        (,uint totalCollateral, uint totalBorrow, uint healthFactor) = _accountInfoInternal(account);

        if (expectedHealthFactor >= healthFactor && healthFactor > 0)
            return 0;

        VToken aToken = VToken(platformToken);

        uint extraBorrowAmount = totalCollateral * 1 ether / expectedHealthFactor - totalBorrow;
        
        uint oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(aToken);        
        Exp memory oraclePrice = Exp({mantissa: oraclePriceMantissa});

        uint borrowToken = div_(extraBorrowAmount, oraclePrice);
        return borrowToken;
    }

    function getWithdrawableToken(address account, address platformToken, uint expectedHealthFactor) 
        external view override returns(uint) 
    {
        require(expectedHealthFactor >= 1 ether, Errors.ILA_INVALID_EXPECTED_HEALTH_FACTOR);

        (,uint totalCollateral, uint totalBorrow, uint healthFactor) = _accountInfoInternal(account);

        if (expectedHealthFactor >= healthFactor && healthFactor > 0)
            return 0;

        VToken vToken = VToken(platformToken);
        uint withdrawableAmount = totalCollateral - totalBorrow * expectedHealthFactor / 1 ether;

        uint maxWithdrawAmount = amountUnderlying(platformToken, vToken.balanceOf(account));

        uint oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(vToken);        
        Exp memory oraclePrice = Exp({mantissa: oraclePriceMantissa});

        uint withdrawToken = div_(withdrawableAmount, oraclePrice);

        return withdrawToken > maxWithdrawAmount ? maxWithdrawAmount : withdrawToken;
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
        VToken[] memory vTokens = comptroller.getAssetsIn(account);
        for (uint i = 0; i < vTokens.length; i++) {
            VToken vToken = vTokens[i];

            (bool isListed, uint collateralFactorMantissa, ) = comptroller.markets(address(vToken));
            if (!isListed)
                continue;

            (oErr, vars.aTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) =
                vToken.getAccountSnapshot(account);
            require(oErr == 0, "VenusAdapter: error querying account snapshot");

            vars.collateralFactor = Exp({mantissa: collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});

            // Get the normalized price of the vToken
            vars.oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(vToken);
            if (vars.oraclePriceMantissa == 0) {
                continue;
            }
            vars.oraclePrice = mul_(Exp({mantissa: vars.oraclePriceMantissa}), vars.exchangeRate);

            // Pre-compute a conversion factor from tokens -> ether (normalized price value)
            vars.tokensToDenom = mul_(vars.collateralFactor, vars.oraclePrice);

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
                vars.sumBorrow == 0 ? 0 :  vars.sumCollateral * 1 ether / vars.sumBorrow );
    }

    function accountDetailInfo(address account) external view override returns(AccountDetailInfo[] memory result) {
        uint oErr;
        uint collateralFactorMantissa;
        AccountLiquidityLocalVars memory vars;
        VToken[] memory vTokens = comptroller.getAssetsIn(account);
        result = new AccountDetailInfo[](vTokens.length);

        for(uint i = 0; i < vTokens.length; i++) {
            VToken vToken = vTokens[i];

            result[i].platformToken = address(vToken);
            result[i].asset = _underlying(vToken);

            (oErr, result[i].deposit, result[i].borrow, vars.exchangeRateMantissa) =
                vToken.getAccountSnapshot(account);
            
            (result[i].listed, collateralFactorMantissa,) = comptroller.markets(address(vToken));

            if (!result[i].listed)
                continue;

            vars.collateralFactor = Exp({mantissa: collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});

            // Get the normalized price of the vToken
            vars.oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(vToken);
            
            result[i].deposit = mul_ScalarTruncate(vars.exchangeRate, result[i].deposit);
            result[i].borrow = mul_ScalarTruncate(vars.exchangeRate, result[i].borrow);
            result[i].exchangeRateMantissa = vars.exchangeRateMantissa; 
            result[i].oraclePriceMantissa = vars.oraclePriceMantissa;


            if (vars.oraclePriceMantissa == 0) {
                continue;
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});

            // Pre-compute a conversion factor from tokens -> ether (normalized price value)
            vars.tokensToDenom = mul_(vars.collateralFactor, vars.oraclePrice);

            // sumDeposit += oraclePrice * aTokenBalance
            result[i].depositValue = mul_ScalarTruncate(vars.oraclePrice, result[i].deposit);

            // sumCollateral += tokensToDenom * aTokenBalance
            result[i].collateral = mul_ScalarTruncate(vars.tokensToDenom, result[i].deposit);

            // sumBorrowPlusEffects += oraclePrice * borrowBalance
            result[i].borrowValue = mul_ScalarTruncate(vars.oraclePrice, result[i].borrow);
        }
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
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

pragma solidity ^0.8.0;

interface VenusComptroller {
    /// @notice Indicator that this is a Comptroller contract (for inspection)

    function oracle() external view returns(VenusPriceOracle);

    function getAllMarkets() external view returns (VToken[] memory);
    function markets(address vToken) external view returns(bool isListed, uint collateralFactorMantissa, bool isVenus);

    function getAssetsIn(address account) external view returns (VToken[] memory);
    function checkMembership(address account, address aToken) external view returns (bool);

    function venusAccrued(address) external view returns (uint);
    function claimVenus(address holder) external;

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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IDefiAdapter.sol";

struct MarketInfo {
    address platformToken;
    address asset;
    uint collateralFactor;
}

struct AccountDetailInfo {
    address platformToken;
    address asset;
    uint deposit;
    uint collateral;
    uint borrow;
    uint depositValue;
    uint borrowValue;
    bool listed;
    uint oraclePriceMantissa;
    uint exchangeRateMantissa;
}

interface ILendingAdapter is IDefiAdapter {
    function getMarket(address asset) external view returns(address platformToken);
    function getMarkets() external view returns(MarketInfo[] memory markets);
    function isCollateral(address account, address platformToken) external view returns(bool);
    function enableCollateral(address platformToken) external;
    function rewardTokens() external view returns(address[] memory);

    function collateralFactor(address platformToken) external view returns(uint);

    function priceUnderlying(address platformToken) external view returns(uint);
    /**
    @notice healthFactor is stored scale 1e18, and should be greater than 1.0
            otherwise, the account will be liquidated.
     */
    function accountInfo(address account) external view 
        returns(uint totalDeposit,
                uint totalCollateral, 
                uint totalBorrow, 
                uint healthFactor);
    function accountInfo(address account, address platformToken) external view 
        returns(uint depositToken, uint borrowToken);

    function rewardAccrued(address account) external view returns(uint);
    function accountDetailInfo(address account) external view returns(AccountDetailInfo[] memory) ;

    function deposit(address platformToken, uint amount) external;
    function withdraw(address platformToken, uint amount) external;
    function borrow(address platformToken, uint amount) external;
    function repay(address platformToken, uint amount) external;
    function harvestReward(address account) external;

    function getBorrowableToken(address account, address platformToken, uint expectedHealthFactor) external view returns(uint);
    function getWithdrawableToken(address account, address platformToken, uint expectedHealthFactor) external view returns(uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Errors {
    /// Common error
    string constant CM_CONTRACT_HAS_BEEN_INITIALIZED = "CM-01"; 
    string constant CM_FACTORY_ADDRESS_IS_NOT_CONFIGURED = "CM-02";
    string constant CM_VICS_ADDRESS_IS_NOT_CONFIGURED = "CM-03";
    string constant CM_VICS_EXCHANGE_IS_NOT_CONFIGURED = "CM-04";
    string constant CM_CEX_FUND_MANAGER_IS_NOT_CONFIGURED = "CM-05";
    string constant CM_TREASURY_MANAGER_IS_NOT_CONFIGURED = "CM-06";
    string constant CM_CEX_DEFAULT_MASTER_ACCOUNT_IS_NOT_CONFIGURED = "CM-07";
    string constant CM_ADDRESS_IS_NOT_ICEXDABOTCERTTOKEN = "CM-08";
    string constant CM_INDEX_OUT_OF_RANGE = "CM-09";
    string constant CM_UNAUTHORIZED_CALLER = "CM-10";
    string constant CM_PROXY_ADMIN_IS_NOT_CONFIGURED = "CM-11";
    

    /// IBCertToken error  (Bot Certificate Token)
    string constant BCT_CALLER_IS_NOT_OWNER = "BCT-01"; 
    string constant BCT_REQUIRE_ALL_TOKENS_BURNT = "BCT-02";
    string constant BCT_UNLOCK_AMOUNT_EXCEEDS_TOTAL_LOCKED = "BCT-03";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_UNLOCKING = "BCT-04a";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_LOCKING = "BCT-04b";
    string constant BCT_AMOUNT_EXCEEDS_TOTAL_STAKE = "BCT-05";
    string constant BCT_CANNOT_MINT_TO_ZERO_ADDRESS = "BCT-06";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_BURN = "BCT-07";
    string constant BCT_INSUFFICIENT_ACCOUNT_FUND = "BCT-08";
    string constant BCT_CALLER_IS_NEITHER_BOT_NOR_CERTLOCKER = "BCT-09";
    string constant BCT_VALUE_MISMATCH_ASSET_AMOUNT = "BCT-10";

    /// IBCEXCertToken error (Cex Bot Certificate Token)
    string constant CBCT_CALLER_IS_NOT_FUND_MANAGER = "CBCT-01";

    /// GovernToken error (Bot Governance Token)
    string constant BGT_CALLER_IS_NOT_OWNED_BOT = "BGT-01";
    string constant BGT_CANNOT_MINT_TO_ZERO_ADDRESS = "BGT-02";
    string constant BGT_CALLER_IS_NOT_GOVERNANCE = "BGT-03";

    // VaultBase error (VB)
    string constant VB_CALLER_IS_NOT_DABOT = "VB-01a";
    string constant VB_CALLER_IS_NOT_OWNER_BOT = "VB-01b";
    string constant VB_INVALID_VAULT_ID = "VB-02";
    string constant VB_INVALID_VAULT_TYPE = "VB-03";
    string constant VB_INVALID_SNAPSHOT_ID = "VB-04";

    // RegularVault Error (RV)
    string constant RV_VAULT_IS_RESTRICTED = "RV-01";
    string constant RV_DEPOSIT_LOCKED = "RV-02";
    string constant RV_WITHDRAWL_AMOUNT_EXCEED_DEPOSIT = "RV-03";

    // BotVaultManager (VM)
    string constant VM_VAULT_EXISTS = "VM-01";

    // BotManager (BM)
    string constant BM_DOES_NOT_SUPPORT_IDABOT = "BM-01";
    string constant BM_DUPLICATED_BOT_QUALIFIED_NAME = "BM-02";
    string constant BM_TEMPLATE_IS_NOT_REGISTERED = "BM-03";
    string constant BM_GOVERNANCE_TOKEN_IS_NOT_DEPLOYED = "BM-04";
    string constant BM_BOT_IS_NOT_REGISTERED = "BM-05";

    // DABotModule (BMOD)
    string constant BMOD_CALLER_IS_NOT_OWNER = "BMOD-01";
    string constant BMOD_CALLER_IS_NOT_BOT_MANAGER = "BMOD-02";
    string constant BMOD_BOT_IS_ABANDONED = "BMOD-03";

    // DABotControllerLib (BCL)
    string constant BCL_DUPLICATED_MODULE = "BCL-01";
    string constant BCL_CERT_TOKEN_IS_NOT_CONFIGURED = "BCL-02";
    string constant BCL_GOVERN_TOKEN_IS_NOT_CONFIGURED = "BCL-03";
    string constant BCL_GOVERN_TOKEN_IS_NOT_DEPLOYED = "BCL-04";
    string constant BCL_WARMUP_LOCKER_IS_NOT_CONFIGURED = "BCL-05";
    string constant BCL_COOLDOWN_LOCKER_IS_NOT_CONFIGURED = "BCL-06";
    string constant BCL_UKNOWN_MODULE_ID = "BCL-07";
    string constant BCL_BOT_MANAGER_IS_NOT_CONFIGURED = "BCL-08";

    // DABotController (BCMOD)
    string constant BCMOD_CANNOT_CALL_TEMPLATE_METHOD_ON_BOT_INSTANCE = "BCMOD-01";
    string constant BCMOD_CALLER_IS_NOT_OWNER = "BCMOD-02";
    string constant BCMOD_MODULE_HANDLER_NOT_FOUND_FOR_METHOD_SIG = "BCMOD-03";
    string constant BCMOD_NEW_OWNER_IS_ZERO = "BCMOD-04";

    // CEXFundManagerModule (CFMOD)
    string constant CFMOD_DUPLICATED_BENEFITCIARY = "CFMOD-01";
    string constant CFMOD_INVALID_CERTIFICATE_OF_ASSET = "CFMOD-02";
    string constant CFMOD_CALLER_IS_NOT_FUND_MANAGER = "CFMOD-03";

    // DABotSettingLib (BSL)
    string constant BSL_CALLER_IS_NOT_OWNER = "BSL-01";
    string constant BSL_CALLER_IS_NOT_GOVERNANCE_EXECUTOR = "BSL-02";
    string constant BSL_IBO_ENDTIME_IS_SOONER_THAN_IBO_STARTTIME = "BSL-03";
    string constant BSL_BOT_IS_ABANDONED = "BSL-04";

    // DABotSettingModule (BSMOD)
    string constant BSMOD_IBO_ENDTIME_IS_SOONER_THAN_IBO_STARTTIME =  "BSMOD-01";
    string constant BSMOD_INIT_DEPOSIT_IS_LESS_THAN_CONFIGURED_THRESHOLD = "BSMOD-02";
    string constant BSMOD_FOUNDER_SHARE_IS_ZERO = "BSMOD-03";
    string constant BSMOD_INSUFFICIENT_MAX_SHARE = "BSMOD-04";
    string constant BSMOD_FOUNDER_SHARE_IS_GREATER_THAN_IBO_SHARE = "BSMOD-05";

    // DABotCertLocker (LOCKER)
    string constant LOCKER_CALLER_IS_NOT_OWNER_BOT = "LOCKER-01";

    // DABotStakingModule (BSTMOD)
    string constant BSTMOD_PRE_IBO_REQUIRED = "BSTMOD-01";
    string constant BSTMOD_AFTER_IBO_REQUIRED = "BSTMOD-02";
    string constant BSTMOD_INVALID_PORTFOLIO_ASSET = "BSTMOD-03";
    string constant BSTMOD_PORTFOLIO_FULL = "BSTMOD-04";
    string constant BSTMOD_INVALID_CERTIFICATE_ASSET = "BSTMOD-05";
    string constant BSTMOD_PORTFOLIO_ASSET_NOT_FOUND = "BSTMOD-06";
    string constant BSTMOD_ASSET_IS_ZERO = "BSTMOD-07";
    string constant BSTMOD_INVALID_STAKING_CAP = "BSTMOD-08";
    string constant BSTMOD_INSUFFICIENT_FUND = "BSTMOD-09";
    string constant BSTMOD_CAP_IS_ZERO = "BSTMOD-10";
    string constant BSTMOD_CAP_IS_LESS_THAN_STAKED_AND_IBO_CAP = "BSTMOD-11";
    string constant BSTMOD_WERIGHT_IS_ZERO = "BSTMOD-12";

    // CEX FundManager (CFM)
    string constant CFM_REQ_TYPE_IS_MISMATCHED = "CFM-01";
    string constant CFM_INVALID_REQUEST_ID = "CFM-02";
    string constant CFM_CALLER_IS_NOT_BOT_TOKEN = "CFM-03";
    string constant CFM_CLOSE_TYPE_VALUE_IS_NOT_SUPPORTED = "CFM-04";
    string constant CFM_UNKNOWN_REQUEST_TYPE = "CFM-05";
    string constant CFM_CALLER_IS_NOT_REQUESTER = "CFM-06";
    string constant CFM_CALLER_IS_NOT_APPROVER = "CFM-07";
    string constant CFM_CEX_CERTIFICATE_IS_REQUIRED = "CFM-08";
    string constant CFM_TREASURY_ASSET_CERTIFICATE_IS_REQUIRED = "CFM-09";
    string constant CFM_FAIL_TO_TRANSFER_VALUE = "CFM-10";
    string constant CFM_AWARDED_ASSET_IS_NOT_TREASURY = "CFM-11";
    string constant CFM_INSUFFIENT_ASSET_TO_MINT_STOKEN = "CFM-12";

    // FarmBot Module (FBM)  string constant FBM_ = "FBM-";
    string constant FBM_CANNOT_REMOVE_WORKER = "FBM-01";
    string constant FBM_NULL_OPERATOR_ACCOUNT = "FBM-02";

    // TreasuryAsset (TA)
    string constant TA_MINT_ZERO_AMOUNT = "TA-01";
    string constant TA_LOCK_AMOUNT_EXCEED_BALANCE = "TA-02";
    string constant TA_UNLOCK_AMOUNT_AND_PASSED_VALUE_IS_MISMATCHED = "TA-03";
    string constant TA_AMOUNT_EXCEED_AVAILABLE_BALANCE = "TA-04";
    string constant TA_AMOUNT_EXCEED_VALUE_BALANCE = "TA-05";
    string constant TA_FUND_MANAGER_IS_NOT_SET = "TA-06";
    string constant TA_FAIL_TO_TRANSFER_VALUE = "TA-07";

    // Governance (GOV)
    string constant GOV_DEFAULT_STRATEGY_IS_NOT_SET = "GOV-01";
    string constant GOV_INSUFFICIENT_POWER_TO_CREATE_PROPOSAL = "GOV-02";
    string constant GOV_INSUFFICIENT_VICS_TO_CREATE_PROPOSAL = "GOV-03";
    string constant GOV_INVALID_PROPOSAL_ID = "GOV-04";
    string constant GOV_REQUIRED_PROPOSER_OR_GUARDIAN = "GOV-05";
    string constant GOV_TARGET_SHOULD_BE_ZERO_OR_REGISTERED_BOT = "GOV-06";
    string constant GOV_INSUFFICIENT_POWER_TO_VOTE = "GOV-07";
    string constant GOV_INVALID_NEW_STATE = "GOV-08";
    string constant GOV_CANNOT_CHANGE_STATE_OF_CLOSED_PROPOSAL = "GOV-08";
    string constant GOV_INVALID_CREATION_DATA = "GOV-09";
    string constant GOV_CANNOT_CHANGE_STATE_OF_ON_CHAIN_PROPOSAL = "GOV-10";
    string constant GOV_PROPOSAL_DONT_ACCEPT_VOTE = "GOV-11";
    string constant GOV_DUPLICATED_VOTE = "GOV-12";
    string constant GOV_CAN_ONLY_QUEUE_PASSED_PROPOSAL = "GOV-13";
    string constant GOV_DUPLICATED_ACTION = "GOV-14";
    string constant GOV_INVALID_VICS_ADDRESS = "GOV-15";

    // Timelock Executor (TLE)
    string constant TLE_DELAY_SHORTER_THAN_MINIMUM = "TLE-01";
    string constant TLE_DELAY_LONGER_THAN_MAXIMUM = "TLE-02";
    string constant TLE_ONLY_BY_ADMIN = "TLE-03";
    string constant TLE_ONLY_BY_PENDING_ADMIN = "TLE-04";
    string constant TLE_ONLY_BY_THIS_TIMELOCK = "TLE-05";
    string constant TLE_EXECUTION_TIME_UNDERESTIMATED = "TLE-06";
    string constant TLE_ACTION_NOT_QUEUED = "TLE-07";
    string constant TLE_TIMELOCK_NOT_FINISHED = "TLE-08";
    string constant TLE_GRACE_PERIOD_FINISHED = "TLE-09";
    string constant TLE_NOT_ENOUGH_MSG_VALUE = "TLE-10";

    // DABotVoteStrategy (BVS) string constant BVS_ = "BVS-";
    string constant BVS_NOT_A_REGISTERED_DABOT = "BVS-01";

    // DABotWhiteList (BWL) string constant BWL_ = "BWL-";
    string constant BWL_ACCOUNT_IS_ZERO = "BWL-01";
    string constant BWL_ACCOUNT_IS_NOT_WHITELISTED = "BWL-02";

    // Marginal Lending Worker string constant MLF_ = "MLF-";
    string constant MLF_ZERO_DEPOSIT = "MLF-01";
    string constant MLF_UNKNOWN_CONFIG_TOPIC = "MLF-02";
    string constant MLF_REGISTERED_COLLATERAL_ID_EXPECTED = "MLF-03";
    string constant MLF_CONFIG_TOPICS_AND_VALUES_MISMATCHED = "MLF-04";
    string constant MLF_ADAPTER_IS_NOT_CONFIGURED = "MLF-05";
    string constant MLF_CANNOT_REMOVE_IN_USED_COLLATERAL = "MLF-06";
    string constant MLF_CANNOT_CHANGE_LENDING_ADAPTER = "MLF-07";
    string constant MLF_INVALID_PLATFORM_TOKEN = "MLF-08";
    string constant MLF_CANNOT_CHANGE_IN_USED_LEVERAGE_ASSET = "MLF-09";
    string constant MLF_INVALID_EXPECTED_HEALTH_FACTOR = "MLF-10";
    string constant MLF_LEVERAGE_ASSET_IS_NOT_SET = "MLF-11";
    string constant MLF_INVALID_PRECISION = "MLF-12";
    string constant MLF_INTERNAL_ERROR = "MLF-13";

    // FarmCertTokenModule (FTM) string constant FTM_ = "FTM-";
    string constant FTM_INSUFFICICIENT_AMOUNT_TO_DEPOSIT = "FTM-01";

    // ILendingAdapter (ILA) string constant ILA_ = "ILA-";
    string constant ILA_INVALID_EXPECTED_HEALTH_FACTOR = "ILA-01";
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDefiAdapter {
    function underlying(address platformToken) external view returns(address);
    function amountUnderlying(address platformToken, uint amount) external view returns(uint);
}