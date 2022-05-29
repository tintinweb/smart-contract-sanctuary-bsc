// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";


interface IAdminableForCaptain {
    function admin() external view returns (address);
    function pendingAdmin() external view returns (address);
    function _acceptAdmin() external returns (uint);
    function _setPendingAdmin(address newPendingAdmin) external returns (uint);
}


interface IComptrollerForCaptain  is IAdminableForCaptain { 
    
    function bouncer() external view returns(address);
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

interface ICTokenForCaptain is IAdminableForCaptain {
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
    function _setInterestRateModel(address newInterestRateModel) external returns (uint);
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
/// @title Captain Ola
/// @author Ola
/// @notice Interact with lending network


contract NewCaptainOla is Ownable {

    IComptrollerForCaptain public managedUnitroller;


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

 
    function _active() private view {
        require(address(managedUnitroller) != address(0), "Not controlling any network");
    }
    function _activeWithBouncer() private view {
        require(address(managedUnitroller) != address(0), "Not controlling any network");
        require(managedUnitroller.bouncer() != address(0), "LN has no bouncer");
    }
    function _activeWithRainmaker() private view {
        require(address(managedUnitroller) != address(0), "Not controlling any network");
        require(managedUnitroller.rainMaker() != address(0), "LN has no rain maker");
    }

    /**
      * @notice Calls `_acceptAdmin` of unitroller to finalize the transfer to self.
      * @dev Must call _setPendingAdmin of self before calling this function
      * @param _unitroller Lending network unitroller address.
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _acceptAdmin(
        address _unitroller
    ) external onlyOwner returns (uint) {
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
    function _setPendingAdmin(
        address newPendingAdmin
    ) external onlyOwner returns (uint)  {
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
    function removeManagedUnitroller() external onlyOwner returns(uint) {
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
    }

    function _setCollateralFactor(address cToken, uint newCollateralFactorMantissa) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setCollateralFactor(cToken, newCollateralFactorMantissa);
    }
    function _zeroCollateralFactor(address[] calldata cTokens) external onlyOwner returns (uint) {
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

    function _setLiquidationFactor(address cToken, uint newLiquidationFactorMantissa)  external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setLiquidationFactor(cToken, newLiquidationFactorMantissa);
    }
    function _setLiquidationIncentive(address cToken, uint newLiquidationIncentiveMantissa) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setLiquidationIncentive(cToken, newLiquidationIncentiveMantissa);
    }
    function _setReserveFactor(address cToken, uint newReserveFactorMantissa) external onlyOwner returns (uint) {
        _active();
        return ICTokenForCaptain(cToken)._setReserveFactor(newReserveFactorMantissa);
    }

    function _setInterestRateModel(address cToken, address newInterestRateModel) external onlyOwner returns (uint) {
        _active();
        return ICTokenForCaptain(cToken)._setInterestRateModel(newInterestRateModel);
    }

    function _setRainMaker(bytes32 contractNameHash, bytes calldata deployParams, bytes calldata retireParams, bytes calldata connectParams, address incentiveTokenAddress) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setRainMaker(contractNameHash, deployParams, retireParams, connectParams);
        if (contractNameHash != bytes32(0)) {
            IRainMakerForCaptain(managedUnitroller.rainMaker())._setLnIncentiveToken(incentiveTokenAddress);
        }
    }
    function _setBouncer(bytes32 contractNameHash, bytes calldata deployParams, bytes calldata retireParams, bytes calldata connectParams) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setBouncer(contractNameHash, deployParams, retireParams, connectParams);
    }
    function _setLimitMinting(bool flagValue) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setLimitMinting(flagValue);
    }
    function _setMinBorrowAmountUsd(uint minBorrowAmountUsd_) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setMinBorrowAmountUsd(minBorrowAmountUsd_);
    }
    function _setPauseGuardian(address newPauseGuardian) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setPauseGuardian(newPauseGuardian);
    }
    function _setLimitBorrowing(bool flagValue) external onlyOwner returns (uint) {
        _active();
        return managedUnitroller._setLimitBorrowing(flagValue);
    }
    function _setBorrowCapGuardian(address newBorrowCapGuardian) external onlyOwner {
        _active();
        return managedUnitroller._setBorrowCapGuardian(newBorrowCapGuardian);
    }
    function _setAdminBankAddress(address payable newAdminBankAddress) external onlyOwner {
        _active();
        managedUnitroller._setAdminBankAddress(newAdminBankAddress);
    }
    function _setMarketBorrowCaps(address[] calldata cTokens, uint[] calldata newBorrowCaps) external onlyOwner {
        _active();
        managedUnitroller._setMarketBorrowCaps(cTokens, newBorrowCaps);
    }

    function _pauseAllMinting() external onlyOwner returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
         for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setMintPaused(markets[i], true) == true);
        }
        return true;
    }
    function _resumeAllMinting() external onlyOwner returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
         for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setMintPaused(markets[i], false) == false);
        }
        return false;
    }
    function _pauseMint(address cToken) external onlyOwner returns (bool) {
        _active();
        return managedUnitroller._setMintPaused(cToken, true);
    }
    function _resumeMint(address cToken) external onlyOwner returns (bool) {
        _active();
        return managedUnitroller._setMintPaused(cToken, false);
    }

    function _pauseAllBorrow() external onlyOwner returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
         for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setBorrowPaused(markets[i], true) == true);
        }
        return true;
    }
    function _resumeAllBorrow() external onlyOwner returns (bool) {
        _active();
        address[] memory markets = managedUnitroller.getAllMarkets();
         for (uint i = 0; i < markets.length; i++) {
            require(managedUnitroller._setBorrowPaused(markets[i], false) == false);
        }
        return false;
    }
    function _pauseBorrow(address cToken) external onlyOwner returns (bool) {
        _active();
        return managedUnitroller._setBorrowPaused(cToken, true);
    }
    function _resumeBorrow(address cToken) external onlyOwner returns (bool) {
        _active();
        return managedUnitroller._setBorrowPaused(cToken, false);
    }
    function _pauseTransfer() external onlyOwner returns (bool) {
        _active();
        return managedUnitroller._setTransferPaused(true);
    }
    function _resumeTransfer() external onlyOwner returns (bool) {
        _active();
        return managedUnitroller._setTransferPaused(false);
    }

    /**
      * @notice Add market to network with params
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _supportMarket(
        address _comptroller,
        address underlying,
        bytes32 contractNameHash,
        bytes calldata params,
        address interestRateModel,
        uint reserveFactorMantissa,
        uint collateralFactorMantissa,
        uint liquidationFactorMantissa,
        uint liquidationIncentiveMantissa
    ) external onlyOwner returns (uint) {
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

    /**
      * @notice Set active collateral caps to markets in the network
      * @dev In order of markets addition to the network
      */
    function _setActiveCollateralCaps(
        address[] calldata cTokens,
        uint[] calldata activeCollateralCaps
    ) external onlyOwner {

        _active();
        managedUnitroller._setActiveCollateralCaps(
            cTokens,
            activeCollateralCaps
        );
    }


    // // rain maker functions

    function _emergencyZeroSpeeds(address[] calldata _cTokens) external onlyOwner {
        _activeWithRainmaker();
        IRainMakerForCaptain(managedUnitroller.rainMaker())._emergencyZeroSpeeds(_cTokens);
    }
    function _setDynamicCompSpeeds(address[] calldata _cTokens, uint[] calldata _compSupplySpeeds, uint[] calldata _compBorrowSpeeds) onlyOwner external {
        _activeWithRainmaker();
        IRainMakerForCaptain(managedUnitroller.rainMaker())._setDynamicCompSpeeds(_cTokens, _compSupplySpeeds, _compBorrowSpeeds);
    }
    function _setDynamicCompSpeed(address cToken, uint compSupplySpeed, uint compBorrowSpeed) onlyOwner external {
        _activeWithRainmaker();
        IRainMakerForCaptain(managedUnitroller.rainMaker())._setDynamicCompSpeed(cToken, compSupplySpeed, compBorrowSpeed);
    }
    
    function _setLnIncentiveToken(address incentiveTokenAddress) onlyOwner external {
        _activeWithRainmaker();
        IRainMakerForCaptain(managedUnitroller.rainMaker())._setLnIncentiveToken(incentiveTokenAddress);
    }

    function approveAccount(address account) external onlyOwner {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).approveAccount(account);
    }
    function approveAccounts(address[] calldata accounts) external onlyOwner {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).approveAccounts(accounts);
    }
    function denyAccount(address account) external onlyOwner {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).denyAccount(account);
    }
    function denyAccounts(address[] calldata accounts) external onlyOwner {
        _activeWithBouncer();
        IBouncerForCaptain(managedUnitroller.bouncer()).denyAccounts(accounts);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}