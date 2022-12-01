// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../Interfaces/IBaseOracle.sol";
import "../Interfaces/IWhitelist.sol";
import "../Interfaces/IPriceFeed.sol";
import "../Interfaces/IPriceCurve.sol";
import "../Interfaces/IActivePool.sol";
import "../Interfaces/IDefaultPool.sol";
import "../Interfaces/IStabilityPool.sol";
import "../Interfaces/ICollSurplusPool.sol";
import "../Interfaces/IERC20.sol";
import "./LiquityMath.sol";
import "./CheckContract.sol";


/**
 * Whitelist is the contract that keeps track of all the assets that the system takes as collateral.
 * It has onlyOwner functions to add or deprecate collaterals from the whitelist, change the price
 * curve, price feed, safety ratio, etc.
 */

contract Whitelist is OwnableUpgradeable, IWhitelist, IBaseOracle, CheckContract {
    using SafeMath for uint256;

    struct CollateralParams {
        // Safety ratio
        uint256 safetyRatio; // 10**18 * the ratio. i.e. ratio = .95 * 10**18 for 95%. More risky collateral has a lower ratio
        uint256 recoveryRatio;
        address oracle;
        uint256 decimals;
        address priceCurve;
        uint256 index;
        address defaultRouter;
        bool active;
        bool isWrapped;
    }

    IActivePool activePool;
    IDefaultPool defaultPool;
    IStabilityPool stabilityPool;
    ICollSurplusPool collSurplusPool;
    address borrowerOperationsAddress;
    bool private addressesSet;

    mapping(address => address) validCallers;
    mapping(address => bool) pendingLockCallers;
    mapping(address => bool) cannotUpdateValidCaller;

    mapping(address => CollateralParams) public collateralParams;
    // list of all collateral types in collateralParams (active and deprecated)
    // Addresses for easy access
    address[] public validCollateral; // index maps to token address.

    uint256 maxCollsInTrove; // TODO: update to a reasonable number

    event CollateralAdded(address _collateral);
    event CollateralDeprecated(address _collateral);
    event CollateralUndeprecated(address _collateral);
    event OracleChanged(address _collateral, address _newOracle);
    event PriceCurveChanged(address _collateral, address _newPriceCurve);
    event SafetyRatioChanged(address _collateral, uint256 _newSafetyRatio);
    event RecoveryRatioChanged(address _collateral, uint256 _newRecoveryRatio);

    // Require that the collateral exists in the whitelist. If it is not the 0th index, and the
    // index is still 0 then it does not exist in the mapping.
    // no require here for valid collateral 0 index because that means it exists. 
    modifier exists(address _collateral) {
        _exists(_collateral);
        _;
    }

    // Calling from here makes it not inline, reducing contract size significantly. 
    function _exists(address _collateral) internal view {
        if (validCollateral[0] != _collateral) {
            require(collateralParams[_collateral].index != 0, "collateral does not exist");
        }
    }

    // ----------Only Owner Setter Functions----------

    function setUp() external {
		__Ownable_init();
	}

    function setAddresses(
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _collSurplusPoolAddress,
        address _borrowerOperationsAddress
    ) external override onlyOwner {
        require(!addressesSet, "addresses already set");
        checkContract(_activePoolAddress);
        checkContract(_defaultPoolAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_collSurplusPoolAddress);
        checkContract(_borrowerOperationsAddress);

        activePool = IActivePool(_activePoolAddress);
        defaultPool = IDefaultPool(_defaultPoolAddress);
        stabilityPool = IStabilityPool(_stabilityPoolAddress);
        collSurplusPool = ICollSurplusPool(_collSurplusPoolAddress);
        borrowerOperationsAddress = _borrowerOperationsAddress;
        addressesSet = true;
        maxCollsInTrove = 50;
    }

    function addCollateral(
        address _collateral,
        uint256 _safetyRatio,
        uint256 _recoveryRatio,
        address _oracle,
        uint256 _decimals,
        address _priceCurve, 
        bool _isWrapped, 
        address _routerAddress
    ) external onlyOwner {
        checkContract(_collateral);
        checkContract(_oracle);
        checkContract(_priceCurve);
        checkContract(_routerAddress);
        // If collateral list is not 0, and if the 0th index is not equal to this collateral,
        // then if index is 0 that means it is not set yet.
        require(_safetyRatio < 11e17, "ratio must be less than 1.10"); //=> greater than 1.1 would mean taking out more VST than collateral VC

        if (validCollateral.length != 0) {
            require(validCollateral[0] != _collateral && collateralParams[_collateral].index == 0, "collateral   exists");
        }

        validCollateral.push(_collateral);
        collateralParams[_collateral] = CollateralParams(
            _safetyRatio,
            _recoveryRatio,
            _oracle,
            _decimals,
            _priceCurve,
            validCollateral.length - 1, 
            _routerAddress,
            true,
            _isWrapped
        );

        activePool.addCollateralType(_collateral);
        defaultPool.addCollateralType(_collateral);
        stabilityPool.addCollateralType(_collateral);
        collSurplusPool.addCollateralType(_collateral);

        // throw event
        emit CollateralAdded(_collateral);
        emit SafetyRatioChanged(_collateral, _safetyRatio);
        emit RecoveryRatioChanged(_collateral, _recoveryRatio);
    }

    /**
     * Deprecate collateral by not allowing any more collateral to be added of this type.
     * Still can interact with it via validCollateral and CollateralParams
     */
    function deprecateCollateral(address _collateral) external exists(_collateral) onlyOwner {
        checkContract(_collateral);

        require(collateralParams[_collateral].active, "collateral already deprecated");

        collateralParams[_collateral].active = false;

        // throw event
        emit CollateralDeprecated(_collateral);
    }

    /**
     * Undeprecate collateral by allowing more collateral to be added of this type.
     * Still can interact with it via validCollateral and CollateralParams
     */
    function undeprecateCollateral(address _collateral) external exists(_collateral) onlyOwner {
        checkContract(_collateral);

        require(!collateralParams[_collateral].active, "collateral is already active");

        collateralParams[_collateral].active = true;

        // throw event
        emit CollateralUndeprecated(_collateral);
    }

    /**
     * Function to change oracles
     */
    function changeOracle(address _collateral, address _oracle)
        external
        exists(_collateral)
        onlyOwner
    {
        checkContract(_collateral);
        checkContract(_oracle);
        collateralParams[_collateral].oracle = _oracle;

        // throw event
        emit OracleChanged(_collateral, _oracle);
    }

    /**
     * Function to change price curve
     */
    function changePriceCurve(address _collateral, address _priceCurve)
        external
        exists(_collateral)
        onlyOwner
    {
        checkContract(_collateral);
        checkContract(_priceCurve);

        (uint256 lastFeePercent, uint256 lastFeeTime) = IPriceCurve(collateralParams[_collateral].priceCurve).getFeeCapAndTime();
        IPriceCurve(_priceCurve).setFeeCapAndTime(lastFeePercent, lastFeeTime);
        collateralParams[_collateral].priceCurve = _priceCurve;

        // throw event
        emit PriceCurveChanged(_collateral, _priceCurve);
    }

    /**
     * Function to change Safety ratio.
     */
    function changeSafetyRatio(address _collateral, uint256 _newSafetyRatio)
        external
        exists(_collateral)
        onlyOwner
    {
        require(_newSafetyRatio < 11e17, "ratio must be less than 1.10"); //=> greater than 1.1 would mean taking out more VST than collateral VC
        require(collateralParams[_collateral].safetyRatio < _newSafetyRatio, "New SR must be greater than previous SR");
        collateralParams[_collateral].safetyRatio = _newSafetyRatio;

        // throw event
        emit SafetyRatioChanged(_collateral, _newSafetyRatio);
    }

    /**
     * Function to change Stable Adjusted Safety ratio. 
     */
    function changeRecoveryRatio(address _collateral, uint256 _newRecoveryRatio)
        external
        exists(_collateral)
        onlyOwner
    {
        collateralParams[_collateral].recoveryRatio = _newRecoveryRatio;

        // throw event
        emit RecoveryRatioChanged(_collateral, _newRecoveryRatio);
    }

    // -----------Routers--------------

    function setDefaultRouter(address _collateral, address _router) external override onlyOwner exists(_collateral) {
        checkContract(_router);
        collateralParams[_collateral].defaultRouter = _router;
    }

    function getDefaultRouterAddress(address _collateral) external view override exists(_collateral) returns (address) {
        return collateralParams[_collateral].defaultRouter;
    }


    // ---------- View Functions -----------

    function isWrapped(address _collateral) external view override returns (bool) {
        return collateralParams[_collateral].isWrapped;
    }

    function getValidCollateral() external view override returns (address[] memory) {
        return validCollateral;
    }

    // Get safety ratio used in VC Calculation
    function getSafetyRatio(address _collateral)
        external
        view
        override
        returns (uint256)
    {
        return collateralParams[_collateral].safetyRatio;
    }

    // Get safety ratio used in TCR calculation, as well as for redemptions. 
    // Often similar to Safety Ratio except for stables.
    function getRecoveryRatio(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (uint256)
    {
        return collateralParams[_collateral].recoveryRatio;
    }

    function getOracle(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (address)
    {
        return collateralParams[_collateral].oracle;
    }

    function getPriceCurve(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (address)
    {
        return collateralParams[_collateral].priceCurve;
    }

    function getIsActive(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (bool)
    {
        return collateralParams[_collateral].active;
    }

    function getDecimals(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (uint256)
    {
        return collateralParams[_collateral].decimals;
    }

    function getIndex(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (uint256)
    {
        return (collateralParams[_collateral].index);
    }

    // Returned as fee percentage * 10**18. View function for external callers.
    function getFee(
        address _collateral,
        uint256 _collateralVCInput,
        uint256 _collateralVCSystemBalance,
        uint256 _totalVCBalancePre,
        uint256 _totalVCBalancePost
    ) external view override exists(_collateral) returns (uint256 fee) {
        IPriceCurve priceCurve = IPriceCurve(collateralParams[_collateral].priceCurve);
        return priceCurve.getFee(_collateralVCInput, _collateralVCSystemBalance, _totalVCBalancePre, _totalVCBalancePost);
    }

    // Returned as fee percentage * 10**18. Non view function for just borrower operations to call.
    function getFeeAndUpdate(
        address _collateral,
        uint256 _collateralVCInput,
        uint256 _collateralVCSystemBalance,
        uint256 _totalVCBalancePre,
        uint256 _totalVCBalancePost
    ) external override exists(_collateral) returns (uint256 fee) {
        require(
            msg.sender == borrowerOperationsAddress,
            "caller must be BO"
        );
        IPriceCurve priceCurve = IPriceCurve(collateralParams[_collateral].priceCurve);
        return
            priceCurve.getFeeAndUpdate(
                _collateralVCInput,
                _collateralVCSystemBalance,
                _totalVCBalancePre,
                _totalVCBalancePost
            );
    }

    // should return 10**18 times the price in USD of 1 of the given _collateral
    function  getPrice(address _collateral)
        public
        view
        override
        returns (uint256)
    {
        IPriceFeed collateral_priceFeed = IPriceFeed(collateralParams[_collateral].oracle);
        return collateral_priceFeed.fetchPrice_v();
    }

    // Gets the value of that collateral type, of that amount, in USD terms.
    function getValueUSD(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256)
    {
        return _getValueUSD(_collateral, _amount);
    }

    // Aggregates all usd values of passed in collateral / amounts
    function getValuesUSD(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 USDValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            USDValue = USDValue.add(_getValueUSD(_collaterals[i], _amounts[i]));
        }
    }

    function _getValueUSD(address _collateral, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        uint256 decimals = collateralParams[_collateral].decimals;
        uint256 price = getPrice(_collateral);
        return price.mul(_amount).div(10**decimals);
    }

    // Gets the value of that collateral type, of that amount, in VC terms.
    function getValueVC(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256)
    {
        return _getValueVC(_collateral, _amount);
    }

    function getValuesVC(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 VCValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            VCValue = VCValue.add(_getValueVC(_collaterals[i], _amounts[i]));
        }
    }

    function _getValueVC(address _collateral, uint256 _amount) 
        internal 
        view 
        returns (uint256) {
        // Multiply price by amount and safety ratio to get in VC terms, as well as dividing by amount of decimals to normalize. 
        return ((getPrice(_collateral)).mul(_amount).mul(collateralParams[_collateral].safetyRatio).div(10**(18 + collateralParams[_collateral].decimals)));
    }

    // Gets the value of that collateral type, of that amount, in Recovery VC terms.
    function getValueRVC(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256)
    {
        return _getValueRVC(_collateral, _amount);
    }

    function getValuesRVC(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 RVCValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            RVCValue = RVCValue.add(_getValueRVC(_collaterals[i], _amounts[i]));
        }
    }

    function _getValueRVC(address _collateral, uint256 _amount) 
        internal 
        view 
        returns (uint256) {
        // Multiply price by amount and recovery ratio to get in Recovery VC terms, as well as dividing by amount of decimals to normalize. 
        return ((getPrice(_collateral)).mul(_amount).mul(collateralParams[_collateral].recoveryRatio).div(10**(18 + collateralParams[_collateral].decimals)));
    }

    // Gets the TCR value of that collateral type, of that amount, in TCR VC terms. Also returns the regular Value VC. 
    // Used in the active pool and default pool VC calculations. 
    function getValueVCforTCR(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256, uint256)
    {
        return _getValueVCforTCR(_collateral, _amount);
    }

    function getValuesVCforTCR(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 VCValue, uint256 RVCValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            (uint256 tempVCValue, uint256 tempRVCValue) = _getValueVCforTCR(_collaterals[i], _amounts[i]);
            VCValue = VCValue.add(tempVCValue);
            RVCValue = RVCValue.add(tempRVCValue);
        }
    }

    function _getValueVCforTCR(address _collateral, uint256 _amount) 
        internal 
        view 
        returns (uint256 VC, uint256 VCforTCR) {
        uint256 price = getPrice(_collateral);
        uint256 decimals = collateralParams[_collateral].decimals;
        uint256 safetyRatio = collateralParams[_collateral].safetyRatio;
        uint256 recoveryRatio = collateralParams[_collateral].recoveryRatio;
        VC = price.mul(_amount).mul(safetyRatio).div(10**(18 + decimals));
        VCforTCR = price.mul(_amount).mul(recoveryRatio).div(10**(18 + decimals));
    }


    // ===== Contract Callers ======

    /* msg.sender is the Vesta contract calling this function
     * _caller is the caller of that contract on the Vesta contract
     * this function confirms whether the caller of the Vesta Contract is
     * allowed to call that function
     */
    function isValidCaller(address _caller) external override view returns (bool) {
        return (validCallers[msg.sender] == _caller);
    }


    function getValidCaller(address _contract) external override view returns (address) {
        return validCallers[_contract];
    }

    // Changing/Locking Contract Callers:

    function updateValidCaller(address _contract, address _caller) onlyOwner external {
        require(!cannotUpdateValidCaller[_contract], "cannot update valid caller of this contract");
        validCallers[_contract] = _caller;
    }


    function updatePendingLockCaller(address _contract, bool _lock) onlyOwner external {
        pendingLockCallers[_contract] = _lock;
    }


    function lockCaller(address _contract) onlyOwner external {
        cannotUpdateValidCaller[_contract] = pendingLockCallers[_contract];
    }

    // Max Colls in Trove Functions

    function updateMaxCollsInTrove(uint _newMax) onlyOwner external {
        maxCollsInTrove = _newMax;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface IBaseOracle {
  /// @dev Return the value of the given input as USD per unit.
  /// @param token The ERC-20 token to check the value.
  function getPrice(address token) external view returns (uint);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;


interface IWhitelist {
    function getValidCollateral() view external returns (address[] memory);

    function setAddresses(
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _collSurplusPoolAddress, 
        address _borrowerOperationsAddress
    ) external;

    function getOracle(address _collateral) view external returns (address);
    function getSafetyRatio(address _collateral) view external returns (uint256);
    function getRecoveryRatio(address _collateral) view external returns (uint256);
    function getIsActive(address _collateral) view external returns (bool);
    function getPriceCurve(address _collateral) external view returns (address);
    function getDecimals(address _collateral) external view returns (uint256);
    function getFee(address _collateral, uint _collateralVCInput, uint256 _collateralVCBalancePost, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external view returns (uint256 fee);
    function getFeeAndUpdate(address _collateral, uint _collateralVCInput, uint256 _collateralVCBalancePost, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external returns (uint256 fee);
    function getIndex(address _collateral) external view returns (uint256);
    function isWrapped(address _collateral) external view returns (bool);
    function setDefaultRouter(address _collateral, address _router) external;

    function getValuesVC(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint);
    function getValuesRVC(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint);
    function getValuesVCforTCR(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint VC, uint256 VCforTCR);
    function getValuesUSD(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint256);
    function getValueVC(address _collateral, uint _amount) view external returns (uint);
    function getValueRVC(address _collateral, uint _amount) view external returns (uint);
    function getValueVCforTCR(address _collateral, uint _amount) view external returns (uint VC, uint256 VCforTCR);
    function getValueUSD(address _collateral, uint _amount) view external returns (uint256);
    function getDefaultRouterAddress(address _collateral) external view returns (address);

    function getValidCaller(address _contract) external view returns (address);
    function isValidCaller(address _caller) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface IPriceFeed {

    // --- Events ---
    event LastGoodPriceUpdated(uint _lastGoodPrice);

    // --- Function ---
    // function fetchPrice() external returns (uint);

    function fetchPrice_v() view external returns (uint);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface IPriceCurve {
    function setAddresses(address _whitelistAddress) external;

    function setDecayTime(uint _decayTime) external;

    function setDollarCap(uint _dollarCap) external;

    /** 
     * Returns fee based on inputted collateral VC balance and total VC balance of system. 
     * fee is in terms of percentage * 1e18. 
     * If the fee were 1%, this would be 0.01 * 1e18 = 1e16
     */
    function getFee(uint256 _collateralVCInput, uint256 _collateralVCBalancePost, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external view returns (uint256 fee);

    // Same function, updates the fee as well. Called only by whitelist. 
    function getFeeAndUpdate(uint256 _collateralVCInput, uint256 _totalCollateralVCBalance, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external returns (uint256 fee);

    // Function for setting the old price curve's last fee cap / value to the new fee cap / value. 
    // Called only by whitelist. 
    function setFeeCapAndTime(uint256 _lastFeePercent, uint256 _lastFeeTime) external;

    // Gets the fee cap and time currently. Used for setting new values for next price curve. 
    // returns lastFeePercent, lastFeeTime
    function getFeeCapAndTime() external view returns (uint256 _lastFeePercent, uint256 _lastFeeTime);

    /** 
     * Returns fee based on decay since last fee calculation, which we take to be 
     * a reasonable fee amount. If it has decayed a certain amount since then, we let
     * the new fee amount slide. 
     */
    function calculateDecayedFee() external view returns (uint256 fee);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./IPool.sol";

    
interface IActivePool is IPool {
    // --- Events ---
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolVSTDebtUpdated(uint _VSTDebt);
    event ActivePoolCollateralBalanceUpdated(address _collateral, uint _amount);

    // --- Functions ---
    
    function sendCollaterals(address _to, address[] memory _tokens, uint[] memory _amounts) external;
    function sendCollateralsUnwrap(
        address _from,
        address _to,
        address[] memory _tokens,
        uint[] memory _amounts) external;

    function sendSingleCollateral(address _to, address _token, uint256 _amount) external;

    function sendSingleCollateralUnwrap(address _from, address _to, address _token, uint256 _amount) external;

    function getCollateralVC(address collateralAddress) external view returns (uint);
    function addCollateralType(address _collateral) external;

    function getVCSystem() external view returns (uint256 totalVCSystem);

    function getVCforTCRSystem() external view returns (uint256 totalVC, uint256 totalVCforTCR);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./IPool.sol";

interface IDefaultPool is IPool {
    // --- Events ---
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolVSTDebtUpdated(uint _VSTDebt);
    event DefaultPoolETHBalanceUpdated(uint _ETH);

    // --- Functions ---
    
    function sendCollsToActivePool(address[] memory _collaterals, uint[] memory _amounts, address _borrower) external;
    function addCollateralType(address _collateral) external;
    function getCollateralVC(address collateralAddress) external view returns (uint);

    function getAllAmounts() external view returns (uint256[] memory);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./ICollateralReceiver.sol";

/*
 * The Stability Pool holds VST tokens deposited by Stability Pool depositors.
 *
 * When a trove is liquidated, then depending on system conditions, some of its VST debt gets offset with
 * VST in the Stability Pool:  that is, the offset debt evaporates, and an equal amount of VST tokens in the Stability Pool is burned.
 *
 * Thus, a liquidation causes each depositor to receive a VST loss, in proportion to their deposit as a share of total deposits.
 * They also receive an ETH gain, as the ETH collateral of the liquidated trove is distributed among Stability depositors,
 * in the same proportion.
 *
 * When a liquidation occurs, it depletes every deposit by the same fraction: for example, a liquidation that depletes 40%
 * of the total VST in the Stability Pool, depletes 40% of each deposit.
 *
 * A deposit that has experienced a series of liquidations is termed a "compounded deposit": each liquidation depletes the deposit,
 * multiplying it by some factor in range ]0,1[
 *
 * Please see the implementation spec in the proof document, which closely follows on from the compounded deposit / ETH gain derivations:
 * https://github.com/liquity/liquity/blob/master/papers/Scalable_Reward_Distribution_with_Compounding_Stakes.pdf
 *
 * --- VSTA ISSUANCE TO STABILITY POOL DEPOSITORS ---
 *
 * An VSTA issuance event occurs at every deposit operation, and every liquidation.
 *
 * Each deposit is tagged with the address of the front end through which it was made.
 *
 * All deposits earn a share of the issued VSTA in proportion to the deposit as a share of total deposits. The VSTA earned
 * by a given deposit, is split between the depositor and the front end through which the deposit was made, based on the front end's kickbackRate.
 *
 */
interface IStabilityPool is ICollateralReceiver {

    // --- Events ---
    
    event StabilityPoolETHBalanceUpdated(uint _newBalance);
    event StabilityPoolVSTBalanceUpdated(uint _newBalance);

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event VSTTokenAddressChanged(address _newVSTTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);

    event P_Updated(uint _P);
    event S_Updated(uint _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint _P, uint _S, uint _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint _P, uint _G);
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);
    event FrontEndStakeChanged(address indexed _frontEnd, uint _newFrontEndStake, address _depositor);

    event ETHGainWithdrawn(address indexed _depositor, uint _ETH, uint _VSTLoss);
    event VSTAPaidToDepositor(address indexed _depositor, uint _VSTA);
    event VSTAPaidToFrontEnd(address indexed _frontEnd, uint _VSTA);
    event EtherSent(address _to, uint _amount);

    // --- Functions ---

    /*
     * Called only once on init, to set addresses of other Vesta contracts
     * Callable only by owner, renounces ownership at the end
     */
    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _VSTTokenAddress,
        address _sortedTrovesAddress,
        address _communityIssuanceAddress,
        address _whitelistAddress,
        address _troveManagerLiquidationsAddress
    )
        external;

    /*
     * Initial checks:
     * - Frontend is registered or zero address
     * - Sender is not a registered frontend
     * - _amount is not zero
     * ---
     * - Triggers a VSTA issuance, based on time passed since the last issuance. The VSTA issuance is shared between *all* depositors and front ends
     * - Tags the deposit with the provided front end tag param, if it's a new deposit
     * - Sends depositor's accumulated gains (VSTA, ETH) to depositor
     * - Sends the tagged front end's accumulated VSTA gains to the tagged front end
     * - Increases deposit and tagged front end's stake, and takes new snapshots for each.
     */
    function provideToSP(uint _amount, address _frontEndTag) external;

    /*
     * Initial checks:
     * - _amount is zero or there are no under collateralized troves left in the system
     * - User has a non zero deposit
     * ---
     * - Triggers a VSTA issuance, based on time passed since the last issuance. The VSTA issuance is shared between *all* depositors and front ends
     * - Removes the deposit's front end tag if it is a full withdrawal
     * - Sends all depositor's accumulated gains (VSTA, ETH) to depositor
     * - Sends the tagged front end's accumulated VSTA gains to the tagged front end
     * - Decreases deposit and tagged front end's stake, and takes new snapshots for each.
     *
     * If _amount > userDeposit, the user withdraws all of their compounded deposit.
     */
    function withdrawFromSP(uint _amount) external;


    /*
     * Initial checks:
     * - Frontend (sender) not already registered
     * - User (sender) has no deposit
     * - _kickbackRate is in the range [0, 100%]
     * ---
     * Front end makes a one-time selection of kickback rate upon registering
     */
    function registerFrontEnd(uint _kickbackRate) external;

    /*
     * Initial checks:
     * - Caller is TroveManager
     * ---
     * Cancels out the specified debt against the VST contained in the Stability Pool (as far as possible)
     * and transfers the Trove's ETH collateral from ActivePool to StabilityPool.
     * Only called by liquidation functions in the TroveManager.
     */
    function offset(uint _debt, address[] memory _assets, uint[] memory _amountsAdded) external;

//    /*
//     * Returns the total amount of ETH held by the pool, accounted in an internal variable instead of `balance`,
//     * to exclude edge cases like ETH received from a self-destruct.
//     */
//    function getETH() external view returns (uint);
    
     //*
//     * Calculates and returns the total gains a depositor has accumulated 
//     */
    function  getDepositorGains(address _depositor) external view returns (address[] memory assets, uint[] memory amounts);


    /*
     * Returns the total amount of VC held by the pool, accounted for by multipliying the
     * internal balances of collaterals by the price that is found at the time getVC() is called.
     */
    function getVC() external view returns (uint);

    /*
     * Returns VST held in the pool. Changes when users deposit/withdraw, and when Trove debt is offset.
     */
    function getTotalVSTDeposits() external view returns (uint);

    /*
     * Calculate the VSTA gain earned by a deposit since its last snapshots were taken.
     * If not tagged with a front end, the depositor gets a 100% cut of what their deposit earned.
     * Otherwise, their cut of the deposit's earnings is equal to the kickbackRate, set by the front end through
     * which they made their deposit.
     */
    function getDepositorVSTAGain(address _depositor) external view returns (uint);

    /*
     * Return the VSTA gain earned by the front end.
     */
    function getFrontEndVSTAGain(address _frontEnd) external view returns (uint);

    /*
     * Return the user's compounded deposit.
     */
    function getCompoundedVSTDeposit(address _depositor) external view returns (uint);

    /*
     * Return the front end's compounded stake.
     *
     * The front end's compounded stake is equal to the sum of its depositors' compounded deposits.
     */
    function getCompoundedFrontEndStake(address _frontEnd) external view returns (uint);

    /*
     * Add collateral type to totalColl 
     */
    function addCollateralType(address _collateral) external;

    function getDepositSnapshotS(address depositor, address collateral) external view returns (uint);

    function getCollateral(address _collateral) external view returns (uint);

    function getAllCollateral() external view returns (address[] memory, uint256[] memory);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "../Dependencies/VestaCustomBase.sol";
import "./ICollateralReceiver.sol";


interface ICollSurplusPool is ICollateralReceiver {

    // --- Events ---
    
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);

    event CollBalanceUpdated(address indexed _account);
    event CollateralSent(address _to);

    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _troveManagerRedemptionsAddress,
        address _activePoolAddress,
        address _whitelistAddress
    ) external;

    function getCollVC() external view returns (uint);

    function getAmountClaimable(address _account, address _collateral) external view returns (uint);

    function getCollateral(address _collateral) external view returns (uint);

    function getAllCollateral() external view returns (address[] memory, uint256[] memory);

    function accountSurplus(address _account, address[] memory _tokens, uint[] memory _amounts) external;

    function claimColl(address _account) external;

    function addCollateralType(address _collateral) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

/**
 * Based on the OpenZeppelin IER20 interface:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
 *
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
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

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

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./SafeMath.sol";

library LiquityMath {
    using SafeMath for uint;

    uint internal constant DECIMAL_PRECISION = 1e18;
    uint internal constant HALF_DECIMAL_PRECISION = 5e17;

    function _min(uint _a, uint _b) internal pure returns (uint) {
        return (_a < _b) ? _a : _b;
    }

    function _max(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a : _b;
    }

    /* 
    * Multiply two decimal numbers and use normal rounding rules:
    * -round product up if 19'th mantissa digit >= 5
    * -round product down if 19'th mantissa digit < 5
    *
    * Used only inside the exponentiation, _decPow().
    */
    function decMul(uint x, uint y) internal pure returns (uint decProd) {
        uint prod_xy = x.mul(y);

        decProd = prod_xy.add(HALF_DECIMAL_PRECISION).div(DECIMAL_PRECISION);
    }

    /* 
    * _decPow: Exponentiation function for 18-digit decimal base, and integer exponent n.
    * 
    * Uses the efficient "exponentiation by squaring" algorithm. O(log(n)) complexity. 
    * 
    * Called by two functions that represent time in units of minutes:
    * 1) TroveManager._calcDecayedBaseRate
    * 2) CommunityIssuance._getCumulativeIssuanceFraction 
    * 
    * The exponent is capped to avoid reverting due to overflow. The cap 525600000 equals
    * "minutes in 1000 years": 60 * 24 * 365 * 1000
    * 
    * If a period of > 1000 years is ever used as an exponent in either of the above functions, the result will be
    * negligibly different from just passing the cap, since: 
    *
    * In function 1), the decayed base rate will be 0 for 1000 years or > 1000 years
    * In function 2), the difference in tokens issued at 1000 years and any time > 1000 years, will be negligible
    */
    function _decPow(uint _base, uint _minutes) internal pure returns (uint) {
       
        if (_minutes > 5256e5) {_minutes = 5256e5;}  // cap to avoid overflow
    
        if (_minutes == 0) {return DECIMAL_PRECISION;}

        uint y = DECIMAL_PRECISION;
        uint x = _base;
        uint n = _minutes;

        // Exponentiation-by-squaring
        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n.div(2);
            } else { // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n.sub(1)).div(2);
            }
        }

        return decMul(x, y);
  }

    function _getAbsoluteDifference(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a.sub(_b) : _b.sub(_a);
    }

    //  _coll should be the amount of VC and _debt is debt of VST\
    // new collateral ratio is 10**18 times the collateral ratio. (150% => 1.5e18)
    function _computeCR(uint _coll, uint _debt) internal pure returns (uint) {
        if (_debt != 0) {
            uint newCollRatio = _coll.mul(1e18).div(_debt);
            return newCollRatio;
        }
        // Return the maximal value for uint256 if the Trove has a debt of 0. Represents "infinite" CR.
        else { // if (_debt == 0)
            return 2**256 - 1; 
        }
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;


contract CheckContract {
    /**
     * Check that the account is an already deployed non-destroyed contract.
     * See: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol#L12
     */
    function checkContract(address _account) internal view {
        require(_account != address(0), "Account cannot be zero address");

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(_account) }
        require(size != 0, "Account code size cannot be zero");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./ICollateralReceiver.sol";

// Common interface for the Pools.
interface IPool is ICollateralReceiver {
    
    // --- Events ---
    
    event ETHBalanceUpdated(uint _newBalance);
    event VSTBalanceUpdated(uint _newBalance);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event WhitelistAddressChanged(address _newWhitelistAddress);
    event EtherSent(address _to, uint _amount);
    event CollateralSent(address _collateral, address _to, uint _amount);

    // --- Functions ---

    function getVC() external view returns (uint totalVC);

    function getVCforTCR() external view returns (uint totalVC, uint totalVCforTCR);

    function getCollateral(address collateralAddress) external view returns (uint);

    function getAllCollateral() external view returns (address[] memory, uint256[] memory);

    function getVSTDebt() external view returns (uint);

    function increaseVSTDebt(uint _amount) external;

    function decreaseVSTDebt(uint _amount) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface ICollateralReceiver {
    function receiveCollateral(address[] memory _tokens, uint[] memory _amounts) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./BaseMath.sol";
import "./SafeMath.sol";
import "../Interfaces/IERC20.sol";
import "../Interfaces/IWhitelist.sol";


contract VestaCustomBase is BaseMath {
    using SafeMath for uint256;

    IWhitelist whitelist;

    struct newColls {
        // tokens and amounts should be the same length
        address[] tokens;
        uint256[] amounts;
    }

    // Collateral math

    // gets the sum of _coll1 and _coll2
    function _sumColls(newColls memory _coll1, newColls memory _coll2)
        internal
        view
        returns (newColls memory finalColls)
    {
        uint256 coll2Len = _coll2.tokens.length;
        if (coll2Len == 0) {
            return _coll1;
        }
        newColls memory coll3;

        coll3.tokens = whitelist.getValidCollateral();
        uint256 coll1Len = _coll1.tokens.length;
        uint256 coll3Len = coll3.tokens.length;
        coll3.amounts = new uint256[](coll3Len);

        uint256 n;
        for (uint256 i; i < coll1Len; ++i) {
            uint256 tokenIndex = whitelist.getIndex(_coll1.tokens[i]);
            if (_coll1.amounts[i] != 0) {
                n++;
                coll3.amounts[tokenIndex] = _coll1.amounts[i];
            }
        }

        for (uint256 i; i < coll2Len; ++i) {
            uint256 tokenIndex = whitelist.getIndex(_coll2.tokens[i]);
            if (_coll2.amounts[i] != 0) {
                if (coll3.amounts[tokenIndex] == 0) {
                    coll3.amounts[tokenIndex] = _coll2.amounts[i];
                    n++;
                } else {
                    coll3.amounts[tokenIndex] = coll3.amounts[tokenIndex].add(_coll2.amounts[i]);
                }
            }
        }

        address[] memory sumTokens = new address[](n);
        uint256[] memory sumAmounts = new uint256[](n);
        uint256 j;

        // should only find n amounts over 0
        for (uint256 i; i < coll3Len; ++i) {
            if (coll3.amounts[i] != 0) {
                sumTokens[j] = coll3.tokens[i];
                sumAmounts[j] = coll3.amounts[i];
                j++;
            }
        }
        finalColls.tokens = sumTokens;
        finalColls.amounts = sumAmounts;
    }


    function _getArrayCopy(uint[] memory _arr) internal pure returns (uint[] memory){
        uint256 arrLen = _arr.length;
        uint[] memory copy = new uint[](arrLen);
        for (uint256 i; i < arrLen; ++i) {
            copy[i] = _arr[i];
        }
        return copy;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.11;


contract BaseMath {
    uint constant public DECIMAL_PRECISION = 1e18;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

/**
 * Based on OpenZeppelin's SafeMath:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
 *
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "add overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "sub overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "div by 0");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b != 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "mod by 0");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}