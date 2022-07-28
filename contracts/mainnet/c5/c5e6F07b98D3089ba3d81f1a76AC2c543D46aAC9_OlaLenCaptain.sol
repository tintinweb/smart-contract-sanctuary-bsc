// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./CaptainStorage.sol";

interface IAdminableForCaptain {
    function admin() external view returns (address);
    function pendingAdmin() external view returns (address);
    function _acceptAdmin() external returns (uint);
    function _setPendingAdmin(address newPendingAdmin) external returns (uint);
}

interface RegistryForCaptain {
    function getImplementationForLn(address lnUnitroller, bytes32 contractNameHash) external returns (address);
    function getLnVersion(address lnUnitroller) external returns (uint256);
    function updateLnVersion(uint256 newVersion) external returns (bool);
}

interface IComptrollerForCaptain  is IAdminableForCaptain { 
    
    function bouncer() external view returns(address);
    function registry() external view returns(address);
    function rainMaker() external view returns(address);
    function getAllMarkets() external returns (address[] memory);

    function hasBouncer() view external returns (bool);
    function _supportNewMarket(address underlying,
        bytes32 contractNameHash,
        bytes calldata params,
        address interestRateModel,
        bytes calldata becomeImplementationData) external returns (uint);

    function _setCollateralFactor(
        address cToken,
        uint newCollateralFactorMantissa
    ) external returns (uint);

    function _setLiquidationFactor(
        address cToken,
        uint newLiquidationFactorMantissa
    ) external returns (uint);

    function _setLiquidationIncentive(
        address cToken,
        uint newLiquidationIncentiveMantissa
    ) external returns (uint);

    function existingMarketTypes(
        address underlying, 
        bytes32 contractNameHash
    ) external returns (address);

    function _setRainMaker(bytes32 contractNameHash, bytes calldata deployParams, bytes calldata retireParams, bytes calldata connectParams) external returns (uint);
    function _setBouncer(bytes32 contractNameHash, bytes calldata deployParams, bytes calldata retireParams, bytes calldata connectParams) external returns (uint);
    function _setLimitMinting(bool flagValue) external returns (uint);
    function _setMinBorrowAmountUsd(uint minBorrowAmountUsd_) external returns (uint);
    function _setPauseGuardian(address newPauseGuardian) external returns (uint);
    function _setLimitBorrowing(bool flagValue) external returns (uint);
    function _setBorrowCapGuardian(address newBorrowCapGuardian) external;
    function _setAdminBankAddress(address payable newAdminBankAddress) external;
    function _setMarketBorrowCaps(address[] calldata cTokens, uint[] calldata newBorrowCaps) external;
    function _setMintPaused(address cToken, bool state) external returns (bool);
    function _setBorrowPaused(address cToken, bool state) external returns (bool);
    function _setTransferPaused(bool state) external returns (bool);

    function _setActiveCollateralCaps(
        address[] calldata cTokens,
        uint[] calldata newActiveCollateralCaps
    ) external;

}

interface IUnitrollerForCaptain {
    function _upgradeLnSystemVersion(uint256 newSystemVersion, bytes calldata becomeImplementationData) external returns (uint);
}

interface ICTokenForCaptain is IAdminableForCaptain {
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
    function _setInterestRateModel(address newInterestRateModel) external returns (uint);
}

interface IStakeableOTokenForCaptain {
    function _migrateStakingTarget(address newStakingTarget, bytes calldata params) external returns (uint);
}

interface IRainMakerForCaptain {
    function _emergencyZeroSpeeds(address[] calldata _cTokens) external;
    function _setDynamicCompSpeeds(address[] calldata _cTokens, uint[] calldata _compSupplySpeeds, uint[] calldata _compBorrowSpeeds) external;
    function _setDynamicCompSpeed(address cToken, uint compSupplySpeed, uint compBorrowSpeed) external;
    function _setLnIncentiveToken(address incentiveTokenAddress) external;
}

interface IBouncerForCaptain {
    function approveAccount(address account) external;
    function approveAccounts(address[] calldata accounts) external;
    function denyAccount(address account) external;
    function denyAccounts(address[] calldata accounts) external;
}

/**
 * @title Ola LeN Captain
 * @author Ola FinanceS
*/
contract OlaLenCaptain is CaptainAdminStorage {

    enum LenCaptainRoles {
        PAUSER,
        RESUMER,
        MAINTAINER
    }

    IComptrollerForCaptain public managedUnitroller;
    address public securityManager;

    mapping(address => bool) public hasPauserRole;
    mapping(address => bool) public hasResumerRole;
    mapping(address => bool) public hasMaintainerRole;

    // Note : These lists are used for tracking, they do not take part in the actual restriction logic
    address[] public pausersList;
    address[] public resumersList;
    address[] public maintainersList;

    struct RainMakerDynamicSpeeds {
         address[] cTokens;
         uint[] compSupplySpeeds;
         uint[] compBorrowSpeeds;
    }

    enum Error {
        NO_ERROR,
        UNAUTHORIZED
    }

    /**
      * @notice Emitted when pendingAdmin is changed
      */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
      * @notice Emitted when pendingAdmin is accepted, which means admin is updated
      */
    event NewAdmin(address oldAdmin, address newAdmin);

    /**
     * @notice Emitted when the 'security manager' is set
     */
    event NewSecurityManager(address oldSecurityManager, address newSecurityManager);

    /**
     * @notice Emitted when a 'pauser' is whitelisted
     */
    event PauserAdded(address pauser);
    /**
     * @notice Emitted when a 'pauser' is removed from whitelist
     */
    event PauserRemoved(address pauser);

    /**
     * @notice Emitted when a 'resumer' is whitelisted
     */
    event ResumerAdded(address pauser);
    /**
     * @notice Emitted when a 'resumer' is removed from whitelist
     */
    event ResumerRemoved(address pauser);

    /**
     * @notice Emitted when a 'maintainer' is whitelisted
     */
    event MaintainerAdded(address pauser);
    /**
         * @notice Emitted when a 'maintainer' is removed from whitelist
     */
    event MaintainerRemoved(address pauser);

    constructor() {
        admin = msg.sender;
    }

    // ************
    //  Captain ownership
    // ************

    /**
     * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @param newPendingAdmin New pending admin.
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _setPendingAdmin(address newPendingAdmin) public returns (uint) {
        // Check caller = admin
        require(msg.sender == admin, "Not Admin");

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return 0;
    }

    /**
     * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
     * @dev Admin function for pending admin to accept role and update admin
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _acceptAdmin() public returns (uint) {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        require(msg.sender == pendingAdmin && msg.sender != address(0), "Not the EXISTING pending admin");

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return 0;
    }

    // ************
    //  Modifiers
    // ************

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(admin == msg.sender, "not the admin");
        _;
    }

    /**
     * @dev Throws if called by any account other than the admin or security manager.
     */
    modifier onlyAdminOrSecurity() {
        require(admin == msg.sender || msg.sender == securityManager, "not the admin or security manager");
        _;
    }

    /**
     * @dev Throws if called by any account other than the admin OR security manager OR whitelisted pauser.
     */
    modifier onlyWithPausePrivilege() {
        require(admin == msg.sender || msg.sender == securityManager || hasPauserRole[msg.sender], "not valid pauser");
        _;
    }

    /**
     * @dev Throws if called by any account other than the admin OR security manager OR whitelisted pauser.
     */
    modifier onlyWithResumePrivilege() {
        require(admin == msg.sender || msg.sender == securityManager || hasResumerRole[msg.sender], "not valid resumer");
        _;
    }

    /**
     * @dev Throws if called by any account other than the admin OR security manager OR whitelisted maintainer.
     */
    modifier onlyWithMaintainPrivilege() {
        require(admin == msg.sender || msg.sender == securityManager || hasMaintainerRole[msg.sender], "not valid maintainer");
        _;
    }

    // ************
    //  In-Function "Modifiers"
    // ************

    function _active() public view {
        require(address(managedUnitroller) != address(0), "Not controlling any network");
    }

    function _activeWithBouncer() public view {
        require(address(managedUnitroller) != address(0), "Not controlling any network");
        require(managedUnitroller.bouncer() != address(0), "LN has no bouncer");
    }

    function _activeWithRainmaker() public view {
        require(address(managedUnitroller) != address(0), "Not controlling any network");
        require(managedUnitroller.rainMaker() != address(0), "LN has no rain maker");
    }

    // ************
    //  View
    // ************

    /**
     * @notice View function to get the complete pausers list.
     */
    function getAllPausers() external view returns (address[] memory) {
        return pausersList;
    }

    /**
     * @notice View function to get the complete resumers list.
     */
    function getAllResumers() external view returns (address[] memory) {
        return resumersList;
    }

    /**
     * @notice View function to get the complete maintainers list.
     */
    function getAllMaintainers() external view returns (address[] memory) {
        return maintainersList;
    }

    // ************
    //  Lending Network ownership
    // ************

    /**
      * @notice Calls `_acceptAdmin` of unitroller to finalize the transfer to self.
      * @dev Must call _setPendingAdmin of self before calling this function
      * @param _unitroller Lending network unitroller address.
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _acceptAdminOfLeN(
        address _unitroller
    ) external onlyAdmin returns (uint) {
        require (address(managedUnitroller) == address(0), "Captain exists");
        IComptrollerForCaptain unitrollerContract = IComptrollerForCaptain(_unitroller);
        require (unitrollerContract.pendingAdmin() == address(this), "Not the pending admin");
        address oldAdmin = unitrollerContract.admin();
        address[] memory markets = unitrollerContract.getAllMarkets();
        for (uint i = 0; i < markets.length; i++) {
            require(ICTokenForCaptain(markets[i]).pendingAdmin() == address(this), "Not market pending admin");
            require(IAdminableForCaptain(markets[i])._acceptAdmin() == 0, "Unable to accept admin for market");

        }
        address bouncer = unitrollerContract.bouncer();
        if (bouncer != address(0)) {
            require(IAdminableForCaptain(bouncer).pendingAdmin() == address(this), "Not bouncer pending admin");
            require(IAdminableForCaptain(bouncer)._acceptAdmin() == 0, "Unable to accept admin for bouncer");

        }
        address rainMaker = unitrollerContract.rainMaker();
        if (rainMaker != address(0)) {
            require(IAdminableForCaptain(rainMaker).pendingAdmin() == address(this), "Not rainmaker pending admin");
            require(IAdminableForCaptain(rainMaker)._acceptAdmin() == 0, "Unable to accept admin for rain maker");
        }
        require(unitrollerContract._acceptAdmin() == 0, "Unable to accept admin for bouncer");
        managedUnitroller = IComptrollerForCaptain(_unitroller);
        emit NewAdmin(oldAdmin, address(this));
        return uint(Error.NO_ERROR);
        
    }

    /**
      * @notice Calls the `_setPendingAdmin` function of the unitroller to begin change of admin on lending network
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin of lending network.
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _setPendingAdminOfLeN(
        address newPendingAdmin
    ) external onlyAdmin returns (uint)  {
        _active();
        require (managedUnitroller.admin() == address(this), "Not the current owner");
        address oldPendingAdmin = managedUnitroller.pendingAdmin();
        address[] memory markets = managedUnitroller.getAllMarkets();
        for (uint i = 0; i < markets.length; i++) {
            require(ICTokenForCaptain(markets[i]).admin() == address(this), "Not admin of the market");
        }
        address bouncer = managedUnitroller.bouncer();
        if (bouncer != address(0)) {
            require(IAdminableForCaptain(bouncer).admin() == address(this), "Not bouncer admin");
            require(IAdminableForCaptain(bouncer)._setPendingAdmin(newPendingAdmin) == 0, "Unable to set admin for rainmaker");
        }
        address rainMaker = managedUnitroller.rainMaker();
        if (rainMaker != address(0)) {
            require(IAdminableForCaptain(rainMaker).admin() == address(this), "Not rainmaker admin");
            require(IAdminableForCaptain(rainMaker)._setPendingAdmin(newPendingAdmin) == 0, "Unable to set admin for rainmaker");
        }
        for (uint i = 0; i < markets.length; i++) {
            require(IAdminableForCaptain(markets[i])._setPendingAdmin(newPendingAdmin) == 0, "Unable to set admin for market");
        }

        require(managedUnitroller._setPendingAdmin(newPendingAdmin) == 0, "Unable to set admin for unitroller");
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
        return uint(Error.NO_ERROR);
    }

    function removeManagedUnitroller() external onlyAdmin returns(uint) {
        _active();
        require (managedUnitroller.admin() != address(this), "Still the owner");
        address[] memory markets = managedUnitroller.getAllMarkets();
        for (uint i = 0; i < markets.length; i++) {
            require(IAdminableForCaptain(markets[i]).admin() != address(this), "Still the market owner");
        }
        address bouncer = managedUnitroller.bouncer();
        if (bouncer != address(0)) {
            require(IAdminableForCaptain(bouncer).admin() != address(this), "Still bouncer admin");
            
        }
        address rainMaker = managedUnitroller.rainMaker();
        if (rainMaker != address(0)) {
            require(IAdminableForCaptain(rainMaker).admin() == address(this), "Still rainmaker admin");
        }
        managedUnitroller = IComptrollerForCaptain(address(0));

        return 0;
    }

    // ************
    //  Captain Roles
    // ************

    function setSecurityManager(address _securityManager) external onlyAdminOrSecurity {
        address oldSecurityManager = securityManager;
        securityManager = _securityManager;
        emit NewSecurityManager(oldSecurityManager, securityManager);
    }

    function addPauser(address _pauser) external onlyAdminOrSecurity {
        if (!hasPauserRole[_pauser]) {
            hasPauserRole[_pauser] = true;
            addToRolesListInternal(_pauser, LenCaptainRoles.PAUSER);
            emit PauserAdded(_pauser);
        }
    }
    function removePauser(address _pauser) external onlyAdminOrSecurity {
        if (hasPauserRole[_pauser]) {
            hasPauserRole[_pauser] = false;
            removeFromRolesListInternal(_pauser, LenCaptainRoles.PAUSER);
            emit PauserRemoved(_pauser);
        }
    }

    function addResumer(address _resumer) external onlyAdminOrSecurity {
        if (!hasResumerRole[_resumer]) {
            hasResumerRole[_resumer] = true;
            addToRolesListInternal(_resumer, LenCaptainRoles.RESUMER);
            emit ResumerAdded(_resumer);
        }
    }
    function removeResumer(address _resumer) external onlyAdminOrSecurity {
        if (hasResumerRole[_resumer]) {
            hasResumerRole[_resumer] = false;
            removeFromRolesListInternal(_resumer, LenCaptainRoles.RESUMER);
            emit ResumerRemoved(_resumer);
        }
    }

    function addMaintainer(address _maintainer) external onlyAdminOrSecurity {
        if (!hasMaintainerRole[_maintainer]) {
            hasMaintainerRole[_maintainer] = true;
            addToRolesListInternal(_maintainer, LenCaptainRoles.MAINTAINER);
            emit MaintainerAdded(_maintainer);
        }
    }
    function removeMaintainer(address _maintainer) external onlyAdminOrSecurity {
        if (hasMaintainerRole[_maintainer]) {
            hasMaintainerRole[_maintainer] = false;
            removeFromRolesListInternal(_maintainer, LenCaptainRoles.MAINTAINER);
            emit MaintainerRemoved(_maintainer);
        }
    }

    // ************
    //  "Adapter" functions
    // ************

    function _setCollateralFactor(address cToken, uint newCollateralFactorMantissa) external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setCollateralFactor(cToken, newCollateralFactorMantissa);
    }
    function _setLiquidationFactor(address cToken, uint newLiquidationFactorMantissa)  external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setLiquidationFactor(cToken, newLiquidationFactorMantissa);
    }
    function _setLiquidationIncentive(address cToken, uint newLiquidationIncentiveMantissa) external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setLiquidationIncentive(cToken, newLiquidationIncentiveMantissa);
    }
    function _setReserveFactor(address cToken, uint newReserveFactorMantissa) external onlyAdmin returns (uint) {
        _active();
        return ICTokenForCaptain(cToken)._setReserveFactor(newReserveFactorMantissa);
    }

    function _setInterestRateModel(address cToken, address newInterestRateModel) external onlyAdmin returns (uint) {
        _active();
        return ICTokenForCaptain(cToken)._setInterestRateModel(newInterestRateModel);
    }

    function _setLimitMinting(bool flagValue) external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setLimitMinting(flagValue);
    }
    function _setLimitBorrowing(bool flagValue) external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setLimitBorrowing(flagValue);
    }

    function _setMinBorrowAmountUsd(uint minBorrowAmountUsd_) external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setMinBorrowAmountUsd(minBorrowAmountUsd_);
    }

    function _setPauseGuardian(address newPauseGuardian) external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setPauseGuardian(newPauseGuardian);
    }
    function _setBorrowCapGuardian(address newBorrowCapGuardian) external onlyAdmin {
        _active();
        return managedUnitroller._setBorrowCapGuardian(newBorrowCapGuardian);
    }

    function _setAdminBankAddress(address payable newAdminBankAddress) external onlyAdmin {
        _active();
        managedUnitroller._setAdminBankAddress(newAdminBankAddress);
    }

    // ************
    //  Complex functions
    // ************

    function _setRainMaker(bytes32 contractNameHash, bytes calldata deployParams, bytes calldata retireParams, bytes calldata connectParams, address incentiveTokenAddress, RainMakerDynamicSpeeds calldata rainMakerDynamicSpeeds) external onlyAdmin returns (uint) {
        _active();
        uint result =  managedUnitroller._setRainMaker(contractNameHash, deployParams, retireParams, connectParams);
        if (contractNameHash != bytes32(0)) {
            IRainMakerForCaptain(managedUnitroller.rainMaker())._setLnIncentiveToken(incentiveTokenAddress);
            if (rainMakerDynamicSpeeds.cTokens.length > 0) {
                IRainMakerForCaptain(managedUnitroller.rainMaker())._setDynamicCompSpeeds(rainMakerDynamicSpeeds.cTokens, rainMakerDynamicSpeeds.compSupplySpeeds, rainMakerDynamicSpeeds.compBorrowSpeeds);
            }
        }
        return result;
    }
    function _setBouncer(bytes32 contractNameHash, bytes calldata deployParams, bytes calldata retireParams, bytes calldata connectParams) external onlyAdmin returns (uint) {
        _active();
        return managedUnitroller._setBouncer(contractNameHash, deployParams, retireParams, connectParams);
    }

    /**
     * @notice Support a new market and configure with given params in one tx.
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _migrateStakingTarget(address stakeableMarket, address newStakingTarget, bytes calldata params) external onlyAdmin returns (uint) {
        _active();

        // Migrate staking target
        uint result =  IStakeableOTokenForCaptain(stakeableMarket)._migrateStakingTarget(newStakingTarget, params);

        require(result == 0);

        return uint(Error.NO_ERROR);
    }

    /**
     * @notice Support a new market and configure with given params in one tx.
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _supportMarket(
        address underlying,
        bytes32 contractNameHash,
        bytes calldata params,
        address interestRateModel,
        uint reserveFactorMantissa,
        uint collateralFactorMantissa,
        uint liquidationFactorMantissa,
        uint liquidationIncentiveMantissa
    ) external onlyAdmin returns (uint) {
        _active();

        // Add new market
        uint result =  managedUnitroller._supportNewMarket(
            underlying,
            contractNameHash,
            params,
            interestRateModel,
            "");

        require(result == 0);

        // Get market address
        address cTokenAddress = managedUnitroller.existingMarketTypes(underlying, contractNameHash);
        ICTokenForCaptain cToken = ICTokenForCaptain(cTokenAddress);

        // Set market params
        require(cToken._setReserveFactor(reserveFactorMantissa) == 0);
        require(managedUnitroller._setLiquidationFactor(cTokenAddress, liquidationFactorMantissa) == 0);
        require(managedUnitroller._setCollateralFactor(cTokenAddress, collateralFactorMantissa) == 0);
        require(managedUnitroller._setLiquidationIncentive(cTokenAddress, liquidationIncentiveMantissa) == 0);

        return result;
    }

    // ************
    //  Lending Network Version
    // ************

    function updateLnVersion(uint256 newSystemVersion, bytes calldata becomeImplementationData) external onlyAdmin returns (uint) {
        _active();
        return IUnitrollerForCaptain(address(managedUnitroller))._upgradeLnSystemVersion(newSystemVersion, becomeImplementationData);
    }

    // ************
    //  RainMaker interaction
    // ************

    function _setDynamicCompSpeeds(address[] calldata _cTokens, uint[] calldata _compSupplySpeeds, uint[] calldata _compBorrowSpeeds) onlyAdmin external {
        _activeWithRainmaker();
        IRainMakerForCaptain(managedUnitroller.rainMaker())._setDynamicCompSpeeds(_cTokens, _compSupplySpeeds, _compBorrowSpeeds);
    }
    function _setDynamicCompSpeed(address cToken, uint compSupplySpeed, uint compBorrowSpeed) onlyAdmin external {
        _activeWithRainmaker();
        IRainMakerForCaptain(managedUnitroller.rainMaker())._setDynamicCompSpeed(cToken, compSupplySpeed, compBorrowSpeed);
    }

    // ************
    //  Bouncer interaction
    // ************

    function approveAccount(address account) external onlyAdmin {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).approveAccount(account);
    }
    function approveAccounts(address[] calldata accounts) external onlyAdmin {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).approveAccounts(accounts);
    }
    function denyAccount(address account) external onlyAdmin {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).denyAccount(account);
    }
    function denyAccounts(address[] calldata accounts) external onlyAdmin {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).denyAccounts(accounts);
    }

    // ************
    //  Maintainer functions
    // ************

    function _setMarketBorrowCaps(address[] calldata cTokens, uint[] calldata newBorrowCaps) external onlyWithMaintainPrivilege {
        _active();
        managedUnitroller._setMarketBorrowCaps(cTokens, newBorrowCaps);
    }

    function _setActiveCollateralCaps(
        address[] calldata cTokens,
        uint[] calldata activeCollateralCaps
    ) external onlyWithMaintainPrivilege {
        _active();
        managedUnitroller._setActiveCollateralCaps(
            cTokens,
            activeCollateralCaps
        );
    }

    // ************
    //  Emergency Pausing functions
    // ************

    /**
     * @notice Zeros the collateral factor of all given markets.
     * @param cTokens The markets to pause, empty array means "all markets"
     */
    function _zeroCollateralFactor(address[] calldata cTokens) external onlyWithPausePrivilege returns (uint) {
        _active();
        address[] memory marketsToUse;
        if (cTokens.length == 0) {
            marketsToUse = managedUnitroller.getAllMarkets();
        } else {
            marketsToUse = cTokens;
        }

        for (uint i = 0; i < marketsToUse.length; i++) {
            require(managedUnitroller._setCollateralFactor(marketsToUse[i], 0) == uint(Error.NO_ERROR), "set collateral factor error");
        }
        return uint(Error.NO_ERROR);
    }

    function _pauseMint(address cToken) external onlyWithPausePrivilege returns (bool) {
        _active();
        return managedUnitroller._setMintPaused(cToken, true);
    }
    function _pauseAllMinting() external onlyWithPausePrivilege returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
        for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setMintPaused(markets[i], true) == true);
        }
        return true;
    }

    function _pauseBorrow(address cToken) external onlyWithPausePrivilege returns (bool) {
        _active();
        return managedUnitroller._setBorrowPaused(cToken, true);
    }
    function _pauseAllBorrow() external onlyWithPausePrivilege returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
        for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setBorrowPaused(markets[i], true) == true);
        }
        return true;
    }

    function _pauseTransfer() external onlyWithPausePrivilege returns (bool) {
        _active();
        return managedUnitroller._setTransferPaused(true);
    }

    /**
     * Sets all RainMaker speeds to 0.
     */
    function _emergencyZeroSpeeds(address[] calldata _cTokens) external onlyWithPausePrivilege {
        _activeWithRainmaker();
        //  IRainMakerForCaptain(managedUnitroller.rainMaker())._emergencyZeroSpeeds(_cTokens);
        for (uint i = 0; i < _cTokens.length; i++) {
            IRainMakerForCaptain(managedUnitroller.rainMaker())._setDynamicCompSpeed(_cTokens[i], 0, 0);
        }
    }

    // ************
    //  Emergency Resuming functions
    // ************

    function _resumeMint(address cToken) external onlyWithResumePrivilege returns (bool) {
        _active();
        return managedUnitroller._setMintPaused(cToken, false);
    }
    function _resumeAllMinting() external onlyWithResumePrivilege returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
         for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setMintPaused(markets[i], false) == false);
        }
        return false;
    }

    function _resumeBorrow(address cToken) external onlyWithResumePrivilege returns (bool) {
        _active();
        return managedUnitroller._setBorrowPaused(cToken, false);
    }
    function _resumeAllBorrow() external onlyWithResumePrivilege returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
         for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setBorrowPaused(markets[i], false) == false);
        }
        return false;
    }

    function _resumeTransfer() external onlyWithResumePrivilege returns (bool) {
        _active();
        return managedUnitroller._setTransferPaused(false);
    }

    // ************
    //  Array utils
    // ************

    function addToRolesListInternal(address _account, LenCaptainRoles roleId) internal {
        address[] storage list;

        if (roleId == LenCaptainRoles.PAUSER) {
            list = pausersList;
        } else if (roleId == LenCaptainRoles.RESUMER) {
            list = resumersList;
        } else if (roleId == LenCaptainRoles.MAINTAINER) {
            list = maintainersList;
        } else {
            revert("!Role");
        }

        // Sanity, this should never fail.
        int8 index = findAddressIndexInArray(list, _account);
        require(index < 0, "already in list");
        list.push(_account);
    }

    function removeFromRolesListInternal(address _account, LenCaptainRoles roleId) internal {
        address[] storage list;

        if (roleId == LenCaptainRoles.PAUSER) {
            list = pausersList;
        } else if (roleId == LenCaptainRoles.RESUMER) {
            list = resumersList;
        } else if (roleId == LenCaptainRoles.MAINTAINER) {
            list = maintainersList;
        } else {
            revert("!Role");
        }

        // Sanity, this should never fail.
        int8 index = findAddressIndexInArray(pausersList, _account);
        require(index >= 0, "not in list");

        list[uint(index)] = list[pausersList.length - 1];
        list.pop();
    }

    /**
     * @notice Utility function for array manipulation.
     */
    function findAddressIndexInArray(address[] memory addresses, address item) internal returns (int8) {
        int8 itemIndex = -1;

        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == item) {
                itemIndex = int8(i);
                break;
            }
        }

        return itemIndex;
    }
}

pragma solidity ^0.7.6;

contract CaptainAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;
}