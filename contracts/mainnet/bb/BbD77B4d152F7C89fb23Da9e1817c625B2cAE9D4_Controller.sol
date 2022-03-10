// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./ControllerStorage.sol";
import "./ControllerAbstract.sol";
import "./ErrorReporter.sol";
import "./Unitroller.sol";

/**
 * @title CreditAssentStable's Controller Contract
 * original credit to Creditum
 * forked and modified by Assent Protocol
 */
contract Controller is ControllerV1Storage, ControllerAbstract, ErrorReporter {
    uint public constant MULTIPLIER = 10**18;
    uint public constant MAXFEEREDUCTION = 0.8 ether; // 80%

    modifier onlyAdmin() {
        require(_msgSender() == owner() || _msgSender() == controllerImplementation, "Controller: !unauthorized");
        _;
    }

    /* ========== PROTOCOL FUNCTIONS ========== */

    function enterAllowed(
        address user, 
        address collateral, 
        uint depositAmount, 
        uint borrowAmount
    ) external override returns (uint) {
        // Silence warnings
        user;
        depositAmount;
        borrowAmount;

        CollateralData memory collateralDataCopy = collateralData[collateral];
        if (!collateralDataCopy.allowed) {
            return fail(Error.COLLATERAL_NOT_ALLOWED);
        }
        if (collateralDataCopy.maxDebtRatio == 0) {
            return fail(Error.INVALID_MAX_DEBT_RATIO);
        }
        if (collateralDataCopy.liquidationThreshold == 0) {
            return fail(Error.INVALID_LIQUIDATION_THRESHOLD);
        }
        if (collateralDataCopy.depreciationDuration == 0) {
            return fail(Error.INVALID_DEPRECIATION_DURATION);
        }

        // Ensure position isn't pending liquidation
        (uint triggerTimestamp, ) = core.auctionData(collateral, user);
        if (triggerTimestamp != 0) {
            return fail(Error.PENDING_LIQUIDATION);
        }

        return uint(Error.NO_ERROR);
    }

    function enterVerify(
        address user, 
        address collateral, 
        uint depositAmount, 
        uint borrowAmount
    ) external override {
        // Silence warnings
        user;
        collateral;
        depositAmount;
        borrowAmount;

        if (false) {
            paused = paused;
        }
    }

    function depositAllowed(
        address user, 
        address collateral, 
        uint depositAmount
    ) external override returns (uint) {
        // Silence warnings
        user;
        collateral;
        depositAmount;

        if (false) {
            paused = paused;
        }

        return uint(Error.NO_ERROR);
    }

    function depositVerify(
        address user, 
        address collateral, 
        uint depositAmount
    ) external override {
        // Silence warnings
        user;
        collateral;
        depositAmount;

        if (false) {
            paused = paused;
        }
    }

    function borrowAllowed(
        address user, 
        address collateral, 
        uint borrowAmount
    ) external override returns (uint) {
        uint totalDebt = getDebtValue(user, collateral);
        (, uint debt, ) = core.userData(collateral, user);
        uint totalMinted = core.totalMinted(collateral) + totalDebt - debt;

        if (totalMinted + borrowAmount > collateralData[collateral].mintLimit) {
            return fail(Error.EXCEEDS_MINT_LIMIT);
        }

        return uint(Error.NO_ERROR);
    }

    function borrowVerify(
        address user, 
        address collateral, 
        uint borrowAmount
    ) external override {
        // Silence warnings
        user;
        collateral;
        borrowAmount;

        if (false) {
            paused = paused;
        }
    }

    function exitAllowed(
        address user,
        address collateral, 
        uint withdrawAmount, 
        uint repayAmount
    ) external override returns (uint) {
        // Silence warnings
        withdrawAmount;
        repayAmount;

        // Ensure position isn't pending liquidation
        (uint triggerTimestamp, ) = core.auctionData(collateral, user);
        if (triggerTimestamp != 0) {
            return fail(Error.PENDING_LIQUIDATION);
        }

        return uint(Error.NO_ERROR);
    }

    function exitVerify(
        address user, 
        address collateral, 
        uint withdrawAmount, 
        uint repayAmount
    ) external override {
        // Silence warnings
        user;
        collateral;
        withdrawAmount;
        repayAmount;

        if (false) {
            paused = paused;
        }
    }

    function repayAllowed(
        address user, 
        address collateral, 
        uint repayAmount 
    ) external override returns (uint) {
        // Silence warnings
        user;
        collateral;
        repayAmount;

        if (false) {
            paused = paused;
        }

        return uint(Error.NO_ERROR);
    }

    function repayVerify(
        address user, 
        address collateral, 
        uint repayAmount
    ) external override {
        // Silence warnings
        user;
        collateral;
        repayAmount;

        if (false) {
            paused = paused;
        }
    }

    function withdrawAllowed(
        address user,
        address collateral, 
        uint withdrawAmount
    ) external override returns (uint) {
        // Silence warnings
        user;
        collateral;
        withdrawAmount;
        
        if (false) {
            paused = paused;
        }

        return uint(Error.NO_ERROR);
    }

    function withdrawVerify(
        address user,
        address collateral, 
        uint withdrawAmount
    ) external override {
        // Silence warnings
        user;
        collateral;
        withdrawAmount;
        
        if (false) {
            paused = paused;
        }
    }

    function triggerLiquidationAllowed(
        address caller, 
        address borrower, 
        address collateral
    ) external override returns (uint) {
        // Silence warnings
        caller;

        // Ensure position isn't already triggered for liquidation
        (uint triggerTimestamp, ) = core.auctionData(collateral, borrower);
        if (triggerTimestamp != 0) {
            return fail(Error.PENDING_LIQUIDATION);
        }

        (uint error, , , , , uint healthFactor) = getPositionData(borrower, collateral);
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error));
        }

        if (healthFactor >= MULTIPLIER) {
            return fail(Error.POSITION_NOT_LIQUIDATABLE);
        }

        return uint(Error.NO_ERROR);
    }

    function triggerLiquidationVerify(
        address caller, 
        address borrower, 
        address collateral
    ) external override {
        // Silence warnings
        caller;
        borrower;
        collateral;

        if (false) {
            paused = paused;
        }
    }

    function liquidateBorrowAllowed(
        address liquidator, 
        address borrower, 
        address collateral
    ) external override returns (uint) {
        // Ensure position has been triggered for liquidation
        (uint triggerTimestamp, ) = core.auctionData(collateral, borrower);
        if (triggerTimestamp == 0) {
            return fail(Error.LIQUIDATION_NOT_TRIGGERED);
        }

        // Borrower can not be liquidator
        if (borrower == liquidator) {
            return fail(Error.LIQUIDATOR_IS_BORROWER);
        }

        return uint(Error.NO_ERROR);
    }

    function liquidateBorrowVerify(
        address liquidator, 
        address borrower, 
        address collateral
    ) external override {
        // Silence warnings
        liquidator;
        borrower;
        collateral;

        if (false) {
            paused = paused;
        }
    }

    function stabilizerMintAllowed(
        address user, 
        address underlying, 
        uint amount
    ) external override returns (uint) {
        // Silence warnings
        user;
        amount;

        if (!stabilizerData[underlying].allowed) {
            return fail(Error.UNDERLYING_NOT_ALLOWED);
        }

        return uint(Error.NO_ERROR);
    }

    function stabilizerMintVerify(
        address user, 
        address underlying, 
        uint amount
    ) external override {
        // Silence warnings
        user;
        underlying;
        amount;

        if (false) {
            paused = paused;
        }
    }

    function stabilizerRedeemAllowed(
        address user, 
        address underlying, 
        uint amount
    ) external override returns (uint) {
        // Silence warnings
        user;
        amount;

        if (!stabilizerData[underlying].allowed) {
            return fail(Error.UNDERLYING_NOT_ALLOWED);
        }

        // Calculate redeem fee and burn amount
        uint stabilizerFee = stabilizerData[underlying].stabilizerFee;
        uint fee = amount * stabilizerFee / MULTIPLIER;
        uint burnAmount = amount - fee;

        uint redeemAmount;
        uint decimals = IERC20(underlying).decimals();
        if (decimals <= 18) {
            redeemAmount = burnAmount / 10**(18 - decimals);
        } else {
            redeemAmount = burnAmount * 10**(decimals - 18);
        }

        uint stabilizerBalance = core.stabilizerDeposits(underlying);
        if (redeemAmount > stabilizerBalance) {
            return fail(Error.INSUFFICIENT_UNDERLYING_BALANCE);
        }
        
        return uint(Error.NO_ERROR);
    }

    function stabilizerRedeemVerify(
        address user, 
        address underlying, 
        uint amount
    ) external override {
        // Silence warnings
        user;
        underlying;
        amount;

        if (false) {
            paused = paused;
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    /// @notice Calculates user's position data
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @return (error code, collateral value, debt value, liquidity, shortfall, health factor)
    function getPositionData(address user, address collateral) public view returns (uint, uint, uint, uint, uint, uint) {
        (uint error, uint collateralValue) = getCollateralValue(user, collateral);
        if (error != uint(Error.NO_ERROR)) {
            return (error, 0, 0, 0, 0, 0);
        }

        uint debtValue = getDebtValue(user, collateral);
        uint maxDebtRatio = collateralData[collateral].maxDebtRatio;
        uint liquidationThreshold = collateralData[collateral].liquidationThreshold;
        uint maxDebt = collateralValue * maxDebtRatio / MULTIPLIER;
        
        uint healthFactor;
        if (debtValue == 0) {
            healthFactor = type(uint).max;
        } else {
            healthFactor = collateralValue * liquidationThreshold / debtValue;
        }

        uint liquidity;
        uint shortfall;
        if (healthFactor >= MULTIPLIER) {
            // Use max debt-to-collateral ratio to calculate available borrow
            if (debtValue <= maxDebt) {
                liquidity = maxDebt - debtValue;
            }
        } else {
            // Use liquidation threshold to calculate shortfall
            shortfall = debtValue - collateralValue * liquidationThreshold / MULTIPLIER;
        }

        return (uint(Error.NO_ERROR), collateralValue, debtValue, liquidity, shortfall, healthFactor);
    }

    /// @notice Calculates user's deposit value for collateral
    /// @dev Collateral value (USD) is scaled by 1e18
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @return (error code, value of user's deposited collateral)
    function getCollateralValue(address user, address collateral) public view returns (uint, uint) {
        (uint deposits, , ) = core.userData(collateral, user);
        if (deposits == 0) {
            return (uint(Error.NO_ERROR), 0);
        }

        (uint error, uint collateralPrice) = getPriceUSD(collateral);
        if (error != uint(Error.NO_ERROR)) {
            return (error, 0);
        }

        // Calculate total collateral value and scale to 1e18 (using collateral's decimals)
        uint8 decimals = IERC20(collateral).decimals();
        uint collateralValue = deposits * collateralPrice / 10**decimals;
        return (uint(Error.NO_ERROR), collateralValue);
    }

    /// @notice Returns price for token
    /// @dev Price (USD) is scaled by 1e18
    /// @param token The address of the token
    /// @return (error code, price of token in USD)
    function getPriceUSD(address token) public view returns (uint, uint) {
        if (address(oracle) == address(0)) {
            return (uint(Error.INVALID_ORACLE_ADDRESS), 0);
        }

        if (token == address(0)) {
            return (uint(Error.INVALID_TOKEN_TO_GET_PRICE), 0);
        }

        try oracle.getPriceUSD(token) returns (uint price) {
            if (price == 0) {
                return (uint(Error.INVALID_ORACLE_PRICE), 0);
            }
            return (uint(Error.NO_ERROR), price);
        } catch {
            return (uint(Error.INVALID_ORACLE_CALL), 0);
        }
    }

    /// @notice Calculates user's total outstanding debt for collateral
    /// @dev Total debt includes accrued interest
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @return totalDebt The total outstanding debt for user's collateral
    function getDebtValue(address user, address collateral) public view returns (uint) {
        (, uint positionDebt, ) = core.userData(collateral, user);
        (uint triggerTimestamp, ) = core.auctionData(collateral, user);
        if (triggerTimestamp != 0) {
            // Ignore accrued interest in total debt calculation since position is pending liquidation
            return positionDebt;
        } else {
            // Calculate total debt as current debt + fees (accrued interest)
            uint fees = getFeeCalculation(user, collateral, positionDebt);
            return positionDebt + fees;
        }
    }

    /// @notice Get the stability fee for user including the user fee reduction from VIP system
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @return fee The stability fee for user including the user fee reduction
    function getUserFee(address user, address collateral) public view returns (uint) {
        uint stabilityFee = collateralData[collateral].stabilityFee;
        uint userFeeReduction = getMarketFeeReduction(user);
        require (userFeeReduction <= MAXFEEREDUCTION, "Fee reduction too high");
        uint newStabilityFee = stabilityFee*(MULTIPLIER-userFeeReduction)/MULTIPLIER;

        // Calculate accrued interest based on time elapsed and stability fee
        return newStabilityFee;
    }

    /// @notice Calculates interest accrued for `amount` of outstanding debt
    /// @dev Interest is calculated from annual stability fee and time elapsed since last update
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @param amount The amount of debt to calculate fee for
    /// @return fee The amount of interest accrued accrued since the last update
    function getFeeCalculation(address user, address collateral, uint amount) public view returns (uint) {
        uint stabilityFee = getUserFee(user,collateral);
        (, , uint lastUpdatedAt) = core.userData(collateral, user);
        uint timeElapsed = block.timestamp - lastUpdatedAt;

        // Calculate accrued interest based on time elapsed and stability fee
        return amount * stabilityFee * timeElapsed / (365 days * MULTIPLIER); 
    }

    /// @notice Calculates principal amount for `repayAmount` of debt (including interest)
    /// @dev Principal Amount = Repay Amount - Accrued Interest
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @param amountWithInterest The amount of debt, including accrued interest
    /// @return principal The principal amount of debt, not including accrued interest
    function getPrincipalAmount(address user, address collateral, uint amountWithInterest) public view returns (uint) {
        (, , uint lastUpdatedAt) = core.userData(collateral, user);
        if (lastUpdatedAt != 0) {
            uint stabilityFee = getUserFee(user,collateral);
            uint timeElapsed = block.timestamp - lastUpdatedAt;
            uint fee = stabilityFee * timeElapsed / 365 days;

            // Calculate principal amount based on time elapsed and stability fee
            return amountWithInterest * MULTIPLIER / (MULTIPLIER + fee);
        } else {
            return amountWithInterest;
        }
    }

    /// @notice Gets auction price, amount to reward liquidator, and amount to return to owner
    /// @param borrower The borrower to be liquidated
    /// @param collateral The borrower's collateral to liquidate
    /// @return (amount of collateral to reward liquidator, amount of collateral to return to owner, cost to buyout the auction)
    function getAuctionDetails(address borrower, address collateral) public view returns (uint, uint, uint, uint) {
        uint depreciationDuration = collateralData[collateral].depreciationDuration;
        (uint triggerTimestamp, uint initialPrice) = core.auctionData(collateral, borrower);
        uint timeElapsed = block.timestamp - triggerTimestamp;
        uint debt = getDebtValue(borrower, collateral);
        uint penalty = debt * collateralData[collateral].liquidationPenalty / MULTIPLIER;
        (uint totalCollateral, , ) = core.userData(collateral, borrower);
        uint liquidationfee = collateralData[collateral].liquidationFee;

        // Calculate collateral to reward liquidator, collateral to return to owner, and auction price
        return calcAuctionDetails(depreciationDuration, timeElapsed, initialPrice, debt + penalty, totalCollateral, liquidationfee);
    }

    /// @notice Calculates auction price, amount to reward liquidator, and amount to return to owner
    /// @dev Auction price decreases linearly over depreciation duration
    /// @dev If full depreciation duration has passed, auction price is 0
    /// @param timeElapsed The time elapsed from liquidation trigger to now
    /// @param initialPrice The initial auction price of the liquidatable user's collateral
    /// @param totalDebt The liquidatable user's debt
    /// @param totalCollateral The amount of collateral the liquidatable user has deposited
    /// @return (amount of collateral to reward liquidator, amount of collateral to return to owner, cost to buyout the auction)
    function calcAuctionDetails(
        uint depreciationDuration,
        uint timeElapsed, 
        uint initialPrice, 
        uint totalDebt, 
        uint totalCollateral,
        uint liquidationfee
    ) public pure returns (uint, uint, uint, uint) {
        if (depreciationDuration > timeElapsed) {
            // Since depreciation duration hasn't passed, calculate auction price based on time elapsed since liquidation trigger
            uint depreciatedCost = initialPrice * (depreciationDuration - timeElapsed) / depreciationDuration;

            if (depreciatedCost > totalDebt) {
                // Since depreciated cost is > total debt, reward collateral to liquidator and return rest to owner (partially liquidated)
                uint collateralToLiquidator = totalCollateral * totalDebt / depreciatedCost;
                uint collateralToTreasury = collateralToLiquidator * liquidationfee / MULTIPLIER;
                collateralToLiquidator -= collateralToTreasury;
                uint collateralToOwner = totalCollateral - collateralToLiquidator - collateralToTreasury;

                return (collateralToTreasury, collateralToLiquidator, collateralToOwner, totalDebt);
            } else {
                // Since depreciated cost is < total debt, reward all collateral to liquidator (fully liquidated)
                uint collateralToLiquidator = totalCollateral;
                uint collateralToTreasury = collateralToLiquidator * liquidationfee / MULTIPLIER;
                collateralToLiquidator -= collateralToTreasury;                
                return (collateralToTreasury, collateralToLiquidator, 0, depreciatedCost);
            }
        } else {
            // Since depreciation duration has passed, auction price is 0 and will reward all collateral to liquidator (fully liquidated)
            uint collateralToLiquidator = totalCollateral;
            uint collateralToTreasury = collateralToLiquidator * liquidationfee / MULTIPLIER;
            collateralToLiquidator -= collateralToTreasury;                
            return (collateralToTreasury, collateralToLiquidator, 0, 0);
        }
    }

    /// @notice Calculates user's liquidation price for collateral
    /// @dev Liquidation price is scaled by 1e18
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @return (error code, liquidation price of user's collateral)
    function getLiquidationPrice(address user, address collateral) external view returns (uint, uint) {
        uint debtValue = getDebtValue(user, collateral);
        if (debtValue == 0) {
            return (uint(Error.NO_ERROR), type(uint).max);
        }

        (uint error, uint collateralValue) = getCollateralValue(user, collateral);
        if (error != uint(Error.NO_ERROR)) {
            return (error, 0);
        }

        uint liquidationThreshold = collateralData[collateral].liquidationThreshold;
        uint liquidationPrice = debtValue * MULTIPLIER * MULTIPLIER / (collateralValue * liquidationThreshold);
        return (uint(Error.NO_ERROR), liquidationPrice);
    }

    /// @notice Calculates user's utilization ratio for collateral
    /// @dev Utilization ratio is scaled by 1e18
    /// @param user The address of the user
    /// @param collateral The collateral
    /// @return (error code, utilization ratio of user's collateral)
    function getUtilizationRatio(address user, address collateral) external view returns (uint, uint) {
        uint debtValue = getDebtValue(user, collateral);
        if (debtValue == 0) {
            return (uint(Error.NO_ERROR), 0);
        }

        (uint error, uint collateralValue) = getCollateralValue(user, collateral);
        if (error != uint(Error.NO_ERROR)) {
            return (error, 0);
        }

        uint utilizationRatio = debtValue * MULTIPLIER / collateralValue;
        return (uint(Error.NO_ERROR), utilizationRatio);
    }

    /* ========== ADMIN FUNCTIONS ========== */

    event ParameterChanged(string name, uint oldValue, uint newValue);
    event AddressChanged(string name, address oldAddress, address newAddress);

    function _setPaused(bool _paused) external onlyAdmin {
        emit ParameterChanged("paused", paused ? 1 : 0, _paused ? 1 : 0);
        paused = _paused;
    }

    function _setCore(Core newCore) external onlyAdmin {
        require(newCore.IS_CORE(), "Controller: core address is !contract");
        emit AddressChanged("core", address(core), address(newCore));
        core = newCore;
    }

    function _setOracle(IOracle newOracle) external onlyAdmin {
        require(newOracle.IS_ORACLE(), "Controller: oracle address is !contract");
        emit AddressChanged("oracle", address(oracle), address(newOracle));
        oracle = newOracle;
    }

    function _setTreasury(address newTreasury) external onlyAdmin {
        require(newTreasury != address(0), "Controller: treasury is 0");
        emit AddressChanged("treasury", treasury, newTreasury);
        treasury = newTreasury;
    }

    function _setLiquidationTreasury(address newLiquidationTreasury) external onlyAdmin {
        require(newLiquidationTreasury != address(0), "Controller: treasury is 0");
        emit AddressChanged("liquidationtreasury", liquidationtreasury, newLiquidationTreasury);
        liquidationtreasury = newLiquidationTreasury;
    }    
   
    /// @notice Set all collateral parameters at once
    /// @dev Stability fee bounds: [0, 0.25] * 1e18
    /// @dev Mint fee bounds: [0, 0.05] * 1e18
    /// @dev Max debt ratio bounds: [0.1, 0.95] * 1e18
    /// @dev Mint limit bounds: [0, ∞) * 1e18
    /// @dev Liquidation threshold bounds: [max debt ratio + 0.01, 1) * 1e18
    /// @dev Liquidation penalty bounds: [0, 0.25] * 1e18
    /// @dev Depreciation duration bounds: [10 minutes, 1 hour]
    function _setCollateralParams(
        address collateral, 
        bool allowed,
        uint stabilityFee,
        uint mintFee,
        uint maxDebtRatio, 
        uint mintLimit, 
        uint liquidationThreshold, 
        uint liquidationPenalty,
        uint liquidationFee,
        uint depreciationDuration
    ) external onlyAdmin {
        _setAllowedCollateral(collateral, allowed);
        _setStabilityFee(collateral, stabilityFee);
        _setMintFee(collateral, mintFee);
        _setMaxDebtRatio(collateral, maxDebtRatio);
        _setMintLimit(collateral, mintLimit);
        _setLiquidationThreshold(collateral, liquidationThreshold);
        _setLiquidationPenalty(collateral, liquidationPenalty);
        _setLiquidationFee(collateral, liquidationFee);
        _setDepreciationDuration(collateral, depreciationDuration);
    }

    function _setAllowedCollaterals(address[] calldata collaterals, bool[] calldata allowed) external onlyAdmin {
        require(collaterals.length == allowed.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setAllowedCollateral(collaterals[i], allowed[i]);
        }
    }

    function _setAllowedCollateral(address collateral, bool allowed) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        emit ParameterChanged("allowed", collateralData[collateral].allowed ? 1 : 0, allowed ? 1 : 0);
        collateralData[collateral].allowed = allowed;
    }

    function _setStabilityFees(address[] calldata collaterals, uint[] calldata stabilityFees) external onlyAdmin {
        require(collaterals.length == stabilityFees.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setStabilityFee(collaterals[i], stabilityFees[i]);
        }
    }

    /// @notice Stability fee bounds: [0, 0.25] * 1e18
    function _setStabilityFee(address collateral, uint stabilityFee) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        require(stabilityFee <= 0.25 ether, "Controller: stability fee outside bounds");
        emit ParameterChanged("stabilityFee", collateralData[collateral].stabilityFee, stabilityFee);
        collateralData[collateral].stabilityFee = stabilityFee;
    }

    function _setMintFees(address[] calldata collaterals, uint[] calldata mintFees) external onlyAdmin {
        require(collaterals.length == mintFees.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setMintFee(collaterals[i], mintFees[i]);
        }
    }

    /// @notice Mint fee bounds: [0, 0.05] * 1e18
    function _setMintFee(address collateral, uint mintFee) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        require(mintFee <= 0.05 ether, "Controller: mint fee outside bounds");
        emit ParameterChanged("mintFee", collateralData[collateral].mintFee, mintFee);
        collateralData[collateral].mintFee = mintFee;
    }

    function _setMaxDebtRatios(address[] calldata collaterals, uint[] calldata maxDebtRatios) external onlyAdmin {
        require(collaterals.length == maxDebtRatios.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setMaxDebtRatio(collaterals[i], maxDebtRatios[i]);
        }
    }

    /// @notice Max debt ratio bounds: [0.1, 0.95] * 1e18
    function _setMaxDebtRatio(address collateral, uint maxDebtRatio) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        require(maxDebtRatio >= 0.1 ether && maxDebtRatio <= 0.95 ether, "Controller: max debt ratio outside bounds");
        emit ParameterChanged("maxDebtRatio", collateralData[collateral].maxDebtRatio, maxDebtRatio);
        collateralData[collateral].maxDebtRatio = maxDebtRatio;
    }

    function _setMintLimits(address[] calldata collaterals, uint[] calldata mintLimits) external onlyAdmin {
        require(collaterals.length == mintLimits.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setMintLimit(collaterals[i], mintLimits[i]);
        }
    }

    /// @notice Mint limit bounds: [0, ∞) * 1e18
    function _setMintLimit(address collateral, uint mintLimit) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        emit ParameterChanged("mintLimit", collateralData[collateral].mintLimit, mintLimit);
        collateralData[collateral].mintLimit = mintLimit;
    }

    
    function _setLiquidationThresholds(address[] calldata collaterals, uint[] calldata liquidationThresholds) external onlyAdmin {
        require(collaterals.length == liquidationThresholds.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setLiquidationThreshold(collaterals[i], liquidationThresholds[i]);
        }
    }

    /// @dev Liquidation threshold bounds: [max debt ratio + 0.01, 1) * 1e18
    function _setLiquidationThreshold(address collateral, uint liquidationThreshold) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        uint maxDebtRatio = collateralData[collateral].maxDebtRatio;
        require(maxDebtRatio != 0, "Controller: cannot initialize liquidation threshold before max debt ratio");
        require(liquidationThreshold >= maxDebtRatio + 0.01 ether && liquidationThreshold < 1 ether, "Controller: liquidation threshold outside bounds");
        emit ParameterChanged("liquidationThreshold", collateralData[collateral].liquidationThreshold, liquidationThreshold);
        collateralData[collateral].liquidationThreshold = liquidationThreshold;
    }

    function _setLiquidationPenalties(address[] calldata collaterals, uint[] calldata liquidationPenalties) external onlyAdmin {
        require(collaterals.length == liquidationPenalties.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setLiquidationPenalty(collaterals[i], liquidationPenalties[i]);
        }
    }

    /// @notice Liquidation penalty bounds: [0, 0.25] * 1e18
    function _setLiquidationPenalty(address collateral, uint liquidationPenalty) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        require(liquidationPenalty <= 0.25 ether, "Controller: liquidation penalty outside bounds");
        emit ParameterChanged("liquidationPenalty", collateralData[collateral].liquidationPenalty, liquidationPenalty);
        collateralData[collateral].liquidationPenalty = liquidationPenalty;
    }

    function _setLiquidationFees(address[] calldata collaterals, uint[] calldata liquidationFees) external onlyAdmin {
        require(collaterals.length == liquidationFees.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setLiquidationFee(collaterals[i], liquidationFees[i]);
        }
    }

    /// @notice Liquidation fee bounds: [0, 0.25] * 1e18
    function _setLiquidationFee(address collateral, uint liquidationFee) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        require(liquidationFee <= 0.25 ether, "Controller: liquidation penalty outside bounds");
        emit ParameterChanged("liquidationFee", collateralData[collateral].liquidationFee, liquidationFee);
        collateralData[collateral].liquidationFee = liquidationFee;
    }    

    function _setDepreciationDurations(address[] calldata collaterals, uint[] calldata depreciationDurations) external onlyAdmin {
        require(collaterals.length == depreciationDurations.length, "Controller: lengths don't match");
        for (uint i; i < collaterals.length; i++) {
            _setDepreciationDuration(collaterals[i], depreciationDurations[i]);
        }
    }

    /// @notice Depreciation duration bounds: [10 minutes, 1 hour]
    function _setDepreciationDuration(address collateral, uint depreciationDuration) public onlyAdmin {
        require(collateral != address(0), "Controller: collateral is 0");
        require(depreciationDuration >= 10 minutes && depreciationDuration <= 1 hours, "Controller: depreciation duration outside bounds");
        emit ParameterChanged("depreciationDuration", collateralData[collateral].depreciationDuration, depreciationDuration);
        collateralData[collateral].depreciationDuration = depreciationDuration;
    }

    function _setAllowedUnderlyings(address[] calldata underlyings, bool[] calldata allowed) external onlyAdmin {
        require(underlyings.length == allowed.length, "Controller: lengths don't match");
        for (uint i; i < underlyings.length; i++) {
            _setAllowedUnderlying(underlyings[i], allowed[i]);
        }
    }

    function _setAllowedUnderlying(address underlying, bool allowed) public onlyAdmin {
        require(underlying != address(0), "Controller: underlying is 0");
        emit ParameterChanged("allowed", stabilizerData[underlying].allowed ? 1 : 0, allowed ? 1 : 0);
        stabilizerData[underlying].allowed = allowed;
    }

    function _setStabilizerFees(address[] calldata underlyings, uint[] calldata stabilizerFees) external onlyAdmin {
        require(underlyings.length == stabilizerFees.length, "Controller: lengths don't match");
        for (uint i; i < underlyings.length; i++) {
            _setStabilizerFee(underlyings[i], stabilizerFees[i]);
        }
    }

    /// @notice Swap fee bounds: [0, 0.01] * 1e18
    function _setStabilizerFee(address underlying, uint _stabilizerFee) public onlyAdmin {
        require(underlying != address(0), "Controller: underlying is 0");
        require(_stabilizerFee <= 0.03 ether, "Controller: stabilizer fee outside bounds");
        emit ParameterChanged("stabilizerFee", stabilizerData[underlying].stabilizerFee, _stabilizerFee);
        stabilizerData[underlying].stabilizerFee = _stabilizerFee;
    }

    function _become(Unitroller unitroller) external {
        require(_msgSender() == unitroller.owner(), "Controller: !unitroller admin");
        unitroller._acceptImplementation();
    }

    function setVIP(IAssentVIP _vip) public onlyAdmin {
        require (_vip.isVIP(), "Not a VIP contract");
        require (_vip.getMarketFeeReduction(address(this)) == 0, "getAssentFeeReduction wrong answer");
        vip = _vip;
    }

    function getMarketFeeReduction(address _user) view public returns(uint _marketFeeReduction) {
        if (address(vip) != address(0)) {
            return vip.getMarketFeeReduction(_user);
        }
        else {
            return 0;
        }        
    }     

}