// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "./common/WithAdminUpgradeable.sol";
import "../interfaces/IPriceOracle.sol";
import "../interfaces/IGUTUtils.sol";
import "../interfaces/IveGUT.sol";

import "../libraries/LibETH.sol";

interface IERC20Expand {
    function decimals() external view returns (uint8);
}

/**`
 * @title GUTUtils
 * @author Genesis Universe-TEAM
 */
contract GUTUtils is IGUTUtils, WithAdminUpgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /* ========== STATE VARIABLES ========== */
    uint256 public constant DEFAULT_UNIT = 1e18;

    EnumerableSetUpgradeable.AddressSet private _noncirculatingAddress;

    struct PriceParam {
        uint256 priceMultiple;
        uint256 minBoundary;
        uint256 maxBoundary;
        uint256 step;
    }

    PriceParam[] public priceParams;

    uint256[] public drawCounts;
    uint256[] public stakeVeGUT;
    uint256[] public stakeRates;

    uint256 public basePrice;

    address public usdt;
    address public gutToken;
    address public vegutToken;
    address public invitationToken;

    IPriceOracle public priceOracle;

    /* ========== CONSTRUCTOR ========== */

    function initialize(
        address _admin,
        address _priceOracle,
        address _usdt,
        address _gut,
        address _vegut,
        address _invitationToken,
        uint256 _price,
        uint256[] memory _priceParam,
        uint256[] memory _drawCounts,
        uint256[] memory _stakeVeGUT,
        uint256[] memory _stakeRates
    ) public initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __WithAdmin_init_unchained(_admin);

        priceOracle = IPriceOracle(_priceOracle);
        basePrice = _price;

        _setPriceParam(_priceParam);
        _setMemberInfo(_drawCounts, _stakeVeGUT, _stakeRates);

        usdt = _usdt;
        gutToken = _gut;
        vegutToken = _vegut;
        invitationToken = _invitationToken;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setBasePrice(uint256 _price) external onlyAdmin {
        basePrice = _price;
        emit SetBasePrice(_price, block.timestamp);
    }

    function setPriceParam(uint256[] memory _priceParam) external onlyAdmin {
        _setPriceParam(_priceParam);
    }

    function _setPriceParam(uint256[] memory _priceParam) private {
        require(_priceParam.length % 4 == 0, "priceParam verification failed");
        delete priceParams;
        for (uint256 i = 0; i < _priceParam.length; i += 4) {
            priceParams.push(PriceParam(_priceParam[i], _priceParam[i + 1], _priceParam[i + 2], _priceParam[i + 3]));
        }
        emit SetPriceParam(_priceParam, block.timestamp);
    }

    function setMemberInfo(
        uint256[] memory _drawCounts,
        uint256[] memory _stakeVeGUT,
        uint256[] memory _stakeRates
    ) external onlyAdmin {
        _setMemberInfo(_drawCounts, _stakeVeGUT, _stakeRates);
    }

    function _setMemberInfo(
        uint256[] memory _drawCounts,
        uint256[] memory _stakeVeGUT,
        uint256[] memory _stakeRates
    ) private {
        require(
            _drawCounts.length == _stakeVeGUT.length && _stakeVeGUT.length == _stakeRates.length,
            "length should same"
        );
        drawCounts = _drawCounts;
        stakeVeGUT = _stakeVeGUT;
        stakeRates = _stakeRates;
        emit SetMemberInfo(_drawCounts, _stakeVeGUT, _stakeRates);
    }

    function setDrawCounts(uint256[] memory _array) external onlyAdmin {
        require(stakeVeGUT.length == _array.length, "length should same");
        drawCounts = _array;
        emit SetDrawCounts(_array);
    }

    function setStakeVeGUT(uint256[] memory _array) external onlyAdmin {
        require(drawCounts.length == _array.length, "length should same");
        stakeVeGUT = _array;
        emit SetStakeVeGUT(_array);
    }

    function setStakeRates(uint256[] memory _array) external onlyAdmin {
        require(drawCounts.length == _array.length, "length should same");
        stakeRates = _array;
        emit SetStakeRates(_array);
    }

    function addNoncirculatingAddress(address addr) public override onlyAdmin {
        require(_noncirculatingAddress.contains(addr) == false, "The address already exists");
        _noncirculatingAddress.add(addr);
        emit AddNoncirculatingAddress(addr);
    }

    function removeNoncirculatingAddress(address addr) public override onlyAdmin {
        require(_noncirculatingAddress.contains(addr) == true, "Do not have the address");
        _noncirculatingAddress.remove(addr);
        emit RemoveNoncirculatingAddress(addr);
    }

    /* ========== VIEWS ========== */

    function containsNoncirculatingAddress(address value) public view returns (bool) {
        return _noncirculatingAddress.contains(value);
    }

    function lengthNoncirculatingAddress() public view returns (uint256) {
        return _noncirculatingAddress.length();
    }

    function getNoncirculatingAddress(uint256 index) public view returns (address) {
        return _noncirculatingAddress.at(index);
    }

    function getGUTCirculatingSupply() public view override returns (uint256) {
        uint256 circulatingSupply = ERC20Upgradeable(gutToken).totalSupply();
        for (uint256 i = 0; i < _noncirculatingAddress.length(); i++) {
            circulatingSupply = circulatingSupply.sub(
                ERC20Upgradeable(gutToken).balanceOf(_noncirculatingAddress.at(i))
            );
        }
        return circulatingSupply;
    }

    function getExchangePrice(address _token) public view override returns (uint256) {
        (uint256 assetPriceInGUT, uint256 usdtInGUT) = _getGUTAndExchangePrice();
        if (_token == gutToken) {
            return assetPriceInGUT;
        } else if (_token == vegutToken || _token == invitationToken) {
            return assetPriceInGUT.mul(10);
        } else if (_token == usdt) {
            return assetPriceInGUT.mul(usdtInGUT).div(DEFAULT_UNIT);
        } else {
            uint256 tokenPrice = priceOracle.getAssetPrice(_token);
            if (tokenPrice == 0) {
                return tokenPrice;
            } else {
                uint256 decimals = _token == LibETH.BNB ? DEFAULT_UNIT : 10**IERC20Expand(_token).decimals();
                return assetPriceInGUT.mul(usdtInGUT).mul(decimals).div(tokenPrice).div(DEFAULT_UNIT);
            }
        }
    }

    function getExchangePriceWithAmount(address _token, uint256 _amount) public view override returns (uint256) {
        uint256 price;
        if (_token == vegutToken || _token == invitationToken) {
            price = priceOracle.getAssetPrice(gutToken);
            return price == 0 ? price : _amount.mul(DEFAULT_UNIT).div(price).mul(10);
        } else {
            price = priceOracle.getAssetPrice(_token);
            if (price == 0) {
                return price;
            } else {
                uint256 decimals = _token == LibETH.BNB ? DEFAULT_UNIT : 10**IERC20Expand(_token).decimals();
                return _amount.mul(decimals).div(price);
            }
        }
    }

    function _getGUTAndExchangePrice() private view returns (uint256 assetPriceInGUT, uint256 usdtInGUT) {
        assetPriceInGUT = basePrice;
        uint256 multiple = 100;
        usdtInGUT = priceOracle.getAssetPrice(gutToken);
        if (usdtInGUT == 0 || priceParams.length == 0) {
            return (assetPriceInGUT, usdtInGUT);
        }
        uint256 rate = usdtInGUT.mul(multiple).div(DEFAULT_UNIT);
        PriceParam memory param;
        uint256 lastIndex = priceParams.length.sub(1);
        if (rate <= priceParams[0].minBoundary) {
            return (assetPriceInGUT, usdtInGUT);
        } else if (rate >= priceParams[lastIndex].maxBoundary) {
            param = priceParams[lastIndex];
            assetPriceInGUT = _calcPrice(multiple, param.priceMultiple, param.minBoundary, param.maxBoundary);
            return (assetPriceInGUT, usdtInGUT);
        } else {
            uint256 position;
            uint256 minValueInRange;
            for (uint256 i = 0; i < priceParams.length; i++) {
                param = priceParams[i];
                if (rate >= param.minBoundary && rate < param.maxBoundary) {
                    position = (rate.sub(param.minBoundary)).div(param.step);
                    minValueInRange = param.step.mul(position).add(param.minBoundary);
                    assetPriceInGUT = _calcPrice(multiple, param.priceMultiple, param.minBoundary, minValueInRange);
                    break;
                }
            }
        }
        return (assetPriceInGUT, usdtInGUT);
    }

    function _calcPrice(
        uint256 _multiple,
        uint256 _unitPriceMulti,
        uint256 _minBoundary,
        uint256 _minValueInRange
    ) private view returns (uint256) {
        uint256 priceIncrease = _minValueInRange.mul(_multiple).div(_minBoundary);
        uint256 costIncrease = _multiple.add((priceIncrease.sub(_multiple)).div(3));
        return basePrice.mul(_unitPriceMulti).mul(costIncrease).div(_minValueInRange.mul(_multiple));
    }

    function getMemberInfo(address _user)
        external
        view
        override
        returns (
            uint256 _memberLevel,
            uint256 _count,
            uint256 _stakeAwardRate
        )
    {
        uint256 balance = IveGUT(vegutToken).validBalanceOf(_user);
        (uint256 unitPrice, ) = _getGUTAndExchangePrice();
        if (unitPrice == 0 || stakeVeGUT.length == 0) {
            return (_memberLevel, _count, _stakeAwardRate);
        }
        uint256 calcBase = balance.div(unitPrice);
        if (calcBase < stakeVeGUT[0]) {
            return (_memberLevel, _count, _stakeAwardRate);
        }
        uint256 position = binarySearch(stakeVeGUT, calcBase);
        _memberLevel = position;
        _count = drawCounts[position.sub(1)];
        _stakeAwardRate = stakeRates[position.sub(1)];
        return (_memberLevel, _count, _stakeAwardRate);
    }

    function binarySearch(uint256[] memory _array, uint256 _target) public pure returns (uint256) {
        uint256 end = _array.length;
        uint256 start;
        while (start < end) {
            uint256 mid = MathUpgradeable.average(start, end);
            if (_target < _array[mid]) {
                end = mid;
            } else {
                start = mid.add(1);
            }
        }
        return end;
    }

    event AddNoncirculatingAddress(address addr);
    event RemoveNoncirculatingAddress(address addr);
    event SetBasePrice(uint256 unitPrice, uint256 _timestamp);
    event SetPriceParam(uint256[] _priceParam, uint256 _timestamp);
    event SetMemberInfo(uint256[] _drawCounts, uint256[] _stakeVeGUT, uint256[] _stakeRates);
    event SetDrawCounts(uint256[] _drawCounts);
    event SetStakeVeGUT(uint256[] _stakeVeGUT);
    event SetStakeRates(uint256[] _stakeRates);
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
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
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/ContextUpgradeable.sol";
import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../proxy/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

abstract contract WithAdminUpgradeable is Initializable, AccessControlUpgradeable {
    function __WithAdmin_init(address admin) internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __WithAdmin_init_unchained(admin);
    }

    function __WithAdmin_init_unchained(address admin) internal initializer {
        _setupAdmin(admin);
    }

    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "WithAdmin: unauthorized");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "WithAdmin: caller is not the admin");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addAdmin(address account) external onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function removeAdmin(address account) external onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, account);
    }

    function _setupAdmin(address account) internal virtual {
        require(account != address(0), "WithAdmin: Invalid admin");
        _setupRole(DEFAULT_ADMIN_ROLE, account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @title IPriceOracle
 * @author Genesis Universe-TEAM
 */
interface IPriceOracle {
    function getAssetPrice(address _token) external view returns (uint256);

    function getAssetSource(address _token) external view returns (address);

    function setAssetSource(address _token, address _asset) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IGUTUtils {
    function getExchangePriceWithAmount(address _token, uint256 _price) external view returns (uint256);

    function getExchangePrice(address _token) external view returns (uint256);

    function addNoncirculatingAddress(address addr) external;

    function removeNoncirculatingAddress(address addr) external;

    function getGUTCirculatingSupply() external view returns (uint256);

    function getMemberInfo(address _user)
        external
        view
        returns (
            uint256 _memberLevel,
            uint256 _count,
            uint256 _stakeAwardRate
        );
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IveGUT is IERC20 {
    /**
        @notice increases supply to increase staking balances relative to profit
        @param profit uint256
        @return uint256
     */
    function rebase(uint256 profit) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function validBalanceOf(address addr) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @title PriceOracle
 * @author Genesis Universe-TEAM
 */
library LibETH {
    address public constant BNB = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSetUpgradeable.sol";
import "../utils/AddressUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./common/WithAdmin.sol";
import "../interfaces/IveGUT.sol";

contract veGUT is IveGUT, WithAdmin {
    using SafeMath for uint256;

    address internal initializer;
    address public stakingContract;
    mapping(address => uint256) private _lockBalances;
    mapping(address => uint256) private _lockTime;
    //The duration of the lock, 60*60*24=86400
    uint256 public lockDuration = 86400;

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1e10 * 1e18;

    // TOTAL_GONS is a multiple of INITIAL_FRAGMENTS_SUPPLY so that _gonsPerFragment is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // MAX_SUPPLY = maximum integer < (sqrt(4*TOTAL_GONS + 1) - 1) / 2
    uint256 private constant MAX_SUPPLY = ~uint128(0); // (2^128) - 1

    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    mapping(address => mapping(address => uint256)) private _allowedValue;

    constructor(address _admin) {
        _name = "veGUT";
        _symbol = "veGUT";
        _decimals = 18;

        initializer = msg.sender;
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _setupAdmin(_admin);
    }

    /** @notice Set the GUTStaking and initialize
     * @param _stakingContract The GUTStaking's address
     */
    function initialize(address _stakingContract) public {
        require(msg.sender == initializer, "Initializer:  caller is not initializer");

        stakingContract = _stakingContract;
        _gonBalances[stakingContract] = TOTAL_GONS;
        emit Initialize(stakingContract);

        initializer = address(0);
    }

    /** @notice Set transfer lock duration
     * @param newLockDuration The transfer lock duration
     */
    function setDuration(uint256 newLockDuration) public onlyAdmin {
        lockDuration = newLockDuration;
        emit SetDuration(lockDuration);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
        @notice increases supply to increase staking balances relative to profit
        @param profit uint256
        @return uint256
     */
    function rebase(uint256 profit) public override returns (uint256) {
        require(msg.sender == stakingContract, "Message sender must be the staking contract");
        uint256 rebaseAmount;
        uint256 circulating = circulatingSupply();

        if (profit == 0) {
            return _totalSupply;
        } else if (circulating > 0) {
            rebaseAmount = profit.mul(_totalSupply).div(circulating);
        } else {
            rebaseAmount = profit;
        }

        _totalSupply = _totalSupply.add(rebaseAmount);

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        emit Rebase(profit);
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return balanceForGons(_gonBalances[who]);
    }

    function validBalanceOf(address addr) public view override returns (uint256) {
        if (_lockTime[addr] == 0 || block.timestamp > _lockTime[addr]) {
            return balanceOf(addr);
        } else if (balanceOf(addr) > _lockBalances[addr]) {
            return balanceOf(addr).sub(_lockBalances[addr]);
        }
        return 0;
    }

    function gonsForBalance(uint256 amount) public view returns (uint256) {
        return amount.mul(_gonsPerFragment);
    }

    function balanceForGons(uint256 gons) public view returns (uint256) {
        return gons.div(_gonsPerFragment);
    }

    function circulatingSupply() public view override returns (uint256) {
        return _totalSupply.sub(balanceOf(stakingContract));
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        _allowedValue[from][msg.sender] = _allowedValue[from][msg.sender].sub(value);
        emit Approval(from, msg.sender, _allowedValue[from][msg.sender]);

        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _allowedValue[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowedValue[owner_][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _allowedValue[msg.sender][spender] = _allowedValue[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedValue[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 oldValue = _allowedValue[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedValue[msg.sender][spender] = 0;
        } else {
            _allowedValue[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedValue[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");
        uint256 gonValue = gonsForBalance(amount);
        require(_gonBalances[sender] >= gonValue, "Insufficient veGUT balance");

        _beforeTokenTransfer(sender, recipient, amount);
        _gonBalances[sender] = _gonBalances[sender].sub(gonValue);
        _gonBalances[recipient] = _gonBalances[recipient].add(gonValue);
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        _refreshValidBalance(to);
        if (from != stakingContract) {
            _lockBalances[to] = _lockBalances[to].add(amount);
            _lockTime[to] = block.timestamp.add(lockDuration);
        }
    }

    function _refreshValidBalance(address addr) internal {
        if (_lockTime[addr] != 0) {
            if (block.timestamp > _lockTime[addr]) {
                _lockBalances[addr] = 0;
                _lockTime[addr] = 0;
            }
        }
    }

    /* ========== EVENTS ========== */
    event Initialize(address stakingContract);
    event SetDuration(uint256 lockDuration);
    event Rebase(uint256 profit);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract WithAdmin is AccessControl {
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "WithAdmin: unauthorized");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "WithAdmin: caller is not the admin");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addAdmin(address account) external onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function removeAdmin(address account) external onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, account);
    }

    function _setupAdmin(address account) internal virtual {
        require(account != address(0), "WithAdmin: Invalid admin");
        _setupRole(DEFAULT_ADMIN_ROLE, account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../common/WithAdmin.sol";

contract WithAdminMock is WithAdmin {
    constructor(address _admin) {
        _setupAdmin(_admin);
    }

    function foo() public view onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./common/WithAdmin.sol";

/**
 * @title POW
 * @author Genesis Universe-TEAM
 */
contract POW is ERC20, WithAdmin {
    // Create a new role identifier for the minter role
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @param _admin Initialize Admin Role
     */
    constructor(address _admin) ERC20("POW", "POW") {
        _setupAdmin(_admin);
        _setupRole(MINTER_ROLE, _admin);
    }

    /**
     * @dev Create New tokens to an Address
     */
    function mint(address receiver, uint256 tokens) external onlyRole(MINTER_ROLE) {
        _mint(receiver, tokens);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.7/LinkTokenReceiver.sol";

// mock class using ERC20
contract LinkTokenMock is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 initialBalance
    ) public payable ERC20(name, symbol) {
        _mint(initialAccount, initialBalance);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transferInternal(
        address from,
        address to,
        uint256 value
    ) public {
        _transfer(from, to, value);
    }

    function approveInternal(
        address owner,
        address spender,
        uint256 value
    ) public {
        _approve(owner, spender, value);
    }

    function transferAndCall(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public returns (bool success) {
        super.transfer(_to, _value);
        if (isContract(_to)) {
            contractFallback(_to, _value, _data);
        }
        return true;
    }

    function contractFallback(
        address _to,
        uint256 _value,
        bytes memory _data
    ) private {
        LinkTokenReceiver receiver = LinkTokenReceiver(_to);
        receiver.onTokenTransfer(msg.sender, _value, _data);
    }

    function isContract(address _addr) private view returns (bool hasCode) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

abstract contract LinkTokenReceiver {
  /**
   * @notice Called when LINK is sent to the contract via `transferAndCall`
   * @dev The data payload's first 2 words will be overwritten by the `sender` and `amount`
   * values to ensure correctness. Calls oracleRequest.
   * @param sender Address of the sender
   * @param amount Amount of LINK sent (specified in wei)
   * @param data Payload of the transaction
   */
  function onTokenTransfer(
    address sender,
    uint256 amount,
    bytes memory data
  ) public validateFromLINK permittedFunctionsForLINK(data) {
    assembly {
      // solhint-disable-next-line avoid-low-level-calls
      mstore(add(data, 36), sender) // ensure correct sender is passed
      // solhint-disable-next-line avoid-low-level-calls
      mstore(add(data, 68), amount) // ensure correct amount is passed
    }
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, ) = address(this).delegatecall(data); // calls oracleRequest
    require(success, "Unable to create request");
  }

  function getChainlinkToken() public view virtual returns (address);

  /**
   * @notice Validate the function called on token transfer
   */
  function _validateTokenTransferAction(bytes4 funcSelector, bytes memory data) internal virtual;

  /**
   * @dev Reverts if not sent from the LINK token
   */
  modifier validateFromLINK() {
    require(msg.sender == getChainlinkToken(), "Must use LINK token");
    _;
  }

  /**
   * @dev Reverts if the given data does not begin with the `oracleRequest` function selector
   * @param data The data payload of the request
   */
  modifier permittedFunctionsForLINK(bytes memory data) {
    bytes4 funcSelector;
    assembly {
      // solhint-disable-next-line avoid-low-level-calls
      funcSelector := mload(add(data, 32))
    }
    _validateTokenTransferAction(funcSelector, data);
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// mock class using ERC20
contract ERC20Mock is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        address initialAccount,
        uint256 initialBalance
    ) public payable ERC20(name, symbol) {
        _mint(initialAccount, initialBalance);
        _setupDecimals(decimals);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transferInternal(
        address from,
        address to,
        uint256 value
    ) public {
        _transfer(from, to, value);
    }

    function approveInternal(
        address owner,
        address spender,
        uint256 value
    ) public {
        _approve(owner, spender, value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./ERC20.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Receiver.sol";
import "../../introspection/ERC165.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";
import "../../utils/EnumerableSet.sol";
import "../../utils/EnumerableMap.sol";
import "../../utils/Strings.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a prefix in {tokenURI} to each token's URI, or
    * to the token ID if no specific URI is set for that token ID.
    */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../common/WithAdmin.sol";
import "../common/InscribableToken.sol";

/**
 * @title LimitedCard
 * @author Genesis Universe-TEAM
 */
contract LimitedCard is ERC721, WithAdmin, InscribableToken {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OPERATE_ROLE = keccak256("OPERATE_ROLE");

    Counters.Counter private _tokenIdTracker;

    struct LimitedCardInfo {
        uint8 star;
        uint16 name;
    }
    mapping(uint256 => LimitedCardInfo) public cards;

    constructor(address _admin, string memory _baseUri) ERC721("Collection Card", "CT") {
        _setupAdmin(_admin);
        _setBaseURI(_baseUri);
    }

    function setBaseURI(string memory _uri) external onlyAdmin {
        _setBaseURI(_uri);
        emit SetBaseURI(_uri);
    }

    function addMinter(address _minter) external onlyAdmin {
        grantRole(MINTER_ROLE, _minter);
    }

    function addOperator(address _operator) external onlyAdmin {
        grantRole(OPERATE_ROLE, _operator);
    }

    function removeMinter(address _minter) external onlyAdmin {
        revokeRole(MINTER_ROLE, _minter);
    }

    function removeOperator(address _operator) external onlyAdmin {
        revokeRole(OPERATE_ROLE, _operator);
    }

    /**
     * mint cards
     */
    function mint(
        address _to,
        uint8 _star,
        uint16 _name
    ) external onlyRole(MINTER_ROLE) {
        _tokenIdTracker.increment();
        uint256 tokenId = _tokenIdTracker.current();
        _safeMint(_to, tokenId);

        LimitedCardInfo memory limitedCard = LimitedCardInfo({name: _name, star: _star});
        cards[tokenId] = limitedCard;
        emit Mint(tokenId, _to, _star, _name);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "token is not exists");
        LimitedCardInfo memory info = cards[_tokenId];
        return
            string(
                abi.encodePacked(baseURI(), uint256(info.name).toString(), "-", uint256(info.star).toString(), ".json")
            );
    }

    function setProperty(
        uint256 _tokenId,
        bytes32 _key,
        bytes32 _value
    ) external onlyRole(OPERATE_ROLE) {
        require(_exists(_tokenId), "token is not exists");
        _setProperty(_tokenId, _key, _value);
    }

    function setProperties(
        uint256 _tokenId,
        bytes32[] memory _keys,
        bytes32[] memory _values
    ) external onlyRole(OPERATE_ROLE) {
        require(_exists(_tokenId), "token is not exists");
        require(_keys.length == _values.length, "keys length should same as values length");
        for (uint256 i = 0; i < _keys.length; i++) {
            _setProperty(_tokenId, _keys[i], _values[i]);
        }
        emit SetProperties(_tokenId, _keys, _values);
    }

    event Mint(uint256 indexed _tokenId, address indexed _to, uint8 _star, uint16 _name);
    event SetBaseURI(string _uri);
    event SetProperties(uint256 indexed _tokenId, bytes32[] _keys, bytes32[] _values);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../math/SafeMath.sol";

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @title InscribableToken
 * @author https://github.com/immutable/platform-contracts/blob/develop/contracts/gods-unchained/contracts/token/InscribableToken.sol
 */
contract InscribableToken {
    mapping(bytes32 => bytes32) public properties;

    function _setProperty(
        uint256 _id,
        bytes32 _key,
        bytes32 _value
    ) internal {
        properties[getTokenKey(_id, _key)] = _value;
        emit TokenPropertySet(_id, _key, _value);
    }

    function getProperty(uint256 _id, bytes32 _key) public view returns (bytes32 _value) {
        return properties[getTokenKey(_id, _key)];
    }

    function getProperties(uint256 _id, bytes32[] memory _keys) public view returns (bytes32[] memory _values) {
        _values = new bytes32[](_keys.length);
        for (uint256 i = 0; i < _keys.length; i++) {
            _values[i] = getProperty(_id, _keys[i]);
        }
        return _values;
    }

    function _setClassProperty(bytes32 _key, bytes32 _value) internal {
        properties[getClassKey(_key)] = _value;
        emit ClassPropertySet(_key, _value);
    }

    function getTokenKey(uint256 _tokenId, bytes32 _key) public pure returns (bytes32) {
        // one prefix to prevent collisions
        return keccak256(abi.encodePacked(uint256(1), _tokenId, _key));
    }

    function getClassKey(bytes32 _key) public pure returns (bytes32) {
        // zero prefix to prevent collisions
        return keccak256(abi.encodePacked(uint256(0), _key));
    }

    function getClassProperty(bytes32 _key) public view returns (bytes32) {
        return properties[getClassKey(_key)];
    }

    event ClassPropertySet(bytes32 indexed key, bytes32 value);
    event TokenPropertySet(uint256 indexed id, bytes32 indexed key, bytes32 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../common/WithAdmin.sol";
import "../common/InscribableToken.sol";

/**
 * @title GameCard
 * @author Genesis Universe-TEAM
 */
contract GameCard is ERC721, WithAdmin, InscribableToken {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OPERATE_ROLE = keccak256("OPERATE_ROLE");

    Counters.Counter private _tokenIdTracker;

    struct GameCardInfo {
        uint8 star;
        uint8 alignment;
        uint16 name;
        uint8 attack;
        uint8 defense;
        uint8 constitution;
        uint8 agile;
    }
    mapping(uint256 => GameCardInfo) public cards;

    constructor(address _admin, string memory _baseUri) ERC721("Game Card", "GT") {
        _setupAdmin(_admin);
        _setBaseURI(_baseUri);
    }

    function setBaseURI(string memory _uri) external onlyAdmin {
        _setBaseURI(_uri);
        emit SetBaseURI(_uri);
    }

    function addMinter(address _minter) external onlyAdmin {
        grantRole(MINTER_ROLE, _minter);
    }

    function addOperator(address _operator) external onlyAdmin {
        grantRole(OPERATE_ROLE, _operator);
    }

    function removeMinter(address _minter) external onlyAdmin {
        revokeRole(MINTER_ROLE, _minter);
    }

    function removeOperator(address _operator) external onlyAdmin {
        revokeRole(OPERATE_ROLE, _operator);
    }

    function mint(
        address _to,
        uint8 _star,
        uint8 _alignment,
        uint16 _name,
        uint8 _attack,
        uint8 _defense,
        uint8 _constitution,
        uint8 _agile
    ) external onlyRole(MINTER_ROLE) {
        _tokenIdTracker.increment();
        uint256 tokenId = _tokenIdTracker.current();
        _safeMint(_to, tokenId);

        GameCardInfo memory gameCard = GameCardInfo({
            star: _star,
            alignment: _alignment,
            name: _name,
            attack: _attack,
            defense: _defense,
            constitution: _constitution,
            agile: _agile
        });

        cards[tokenId] = gameCard;

        emit Mint(tokenId, _to, _star, _alignment, _name, _attack, _defense, _constitution, _agile);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "token is not exists");
        GameCardInfo memory info = cards[_tokenId];
        return
            string(
                abi.encodePacked(baseURI(), uint256(info.name).toString(), "-", uint256(info.star).toString(), ".json")
            );
    }

    function setCardProperties(
        uint256 _tokenId,
        uint8 _attack,
        uint8 _defense,
        uint8 _constitution,
        uint8 _agile
    ) external onlyRole(OPERATE_ROLE) {
        require(_exists(_tokenId), "token is not exists");
        if (cards[_tokenId].attack != _attack) {
            cards[_tokenId].attack = _attack;
        }
        if (cards[_tokenId].defense != _defense) {
            cards[_tokenId].defense = _defense;
        }
        if (cards[_tokenId].constitution != _constitution) {
            cards[_tokenId].constitution = _constitution;
        }
        if (cards[_tokenId].agile != _agile) {
            cards[_tokenId].agile = _agile;
        }
        emit SetCardProperties(_tokenId, _attack, _defense, _constitution, _agile);
    }

    function setProperty(
        uint256 _tokenId,
        bytes32 _key,
        bytes32 _value
    ) external onlyRole(OPERATE_ROLE) {
        require(_exists(_tokenId), "token is not exists");
        _setProperty(_tokenId, _key, _value);
    }

    function setProperties(
        uint256 _tokenId,
        bytes32[] memory _keys,
        bytes32[] memory _values
    ) external onlyRole(OPERATE_ROLE) {
        require(_exists(_tokenId), "token is not exists");
        require(_keys.length == _values.length, "keys length should same as values length");
        for (uint256 i = 0; i < _keys.length; i++) {
            _setProperty(_tokenId, _keys[i], _values[i]);
        }
        emit SetProperties(_tokenId, _keys, _values);
    }

    event Mint(
        uint256 indexed _tokenId,
        address indexed _to,
        uint8 _star,
        uint8 _alignment,
        uint16 _name,
        uint8 _attack,
        uint8 _defense,
        uint8 _constitution,
        uint8 _agile
    );
    event SetBaseURI(string _baseUri);
    event SetProperties(uint256 indexed _tokenId, bytes32[] _keys, bytes32[] _values);

    event SetCardProperties(uint256 indexed _tokenId, uint8 _attack, uint8 _defense, uint8 _constitution, uint8 _agile);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./common/PausableWithAdmin.sol";

interface IGUTUtils {
    function getMemberInfo(address _user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}

contract StakingRewards is ReentrancyGuard, PausableWithAdmin {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    IGUTUtils public gutUtils;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 7 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    bool public boosted;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    uint256 private constant DEFAULT_BOOSTED_RATE = 100;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _admin,
        address _rewardsToken,
        address _stakingToken,
        address _gutUtils,
        bool _boosted
    ) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        gutUtils = IGUTUtils(_gutUtils);
        boosted = _boosted;
        _setupAdmin(_admin);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        uint256 boostedBalance = _balances[account].mul(getBoostRate(account)).div(DEFAULT_BOOSTED_RATE);
        return
            boostedBalance.mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    function getBoostRate(address account) public view returns (uint256) {
        if (boosted == false) {
            return DEFAULT_BOOSTED_RATE;
        }
        (, , uint256 boostRate) = gutUtils.getMemberInfo(account);
        if (boostRate < DEFAULT_BOOSTED_RATE) {
            boostRate = DEFAULT_BOOSTED_RATE;
        }
        return boostRate;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount, bool claimRewardToken) external nonReentrant whenNotPaused updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);

        if (claimRewardToken) {
            _getReward();
        }
    }

    function withdraw(uint256 amount, bool claimRewardToken) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);

        if (claimRewardToken) {
            _getReward();
        }
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        _getReward();
    }

    function exit() external {
        withdraw(_balances[msg.sender], false);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward) external onlyAdmin updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    // End rewards emission earlier
    function updatePeriodFinish(uint256 timestamp) external onlyAdmin updateReward(address(0)) {
        periodFinish = timestamp;
    }

    // Set boosted
    function updateBoosted(bool flag) external onlyAdmin {
        boosted = flag;
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyAdmin {
        require(tokenAddress != address(stakingToken), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyAdmin {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    function setGUTUtils(address _gutUtils) external onlyAdmin {
        gutUtils = IGUTUtils(_gutUtils);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _getReward() private {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "./WithAdmin.sol";

abstract contract PausableWithAdmin is WithAdmin, Pausable {
    /**
     * @dev triggers stopped state.
     */
    function pause() public onlyAdmin whenNotPaused {
        _pause();
    }

    /**
     * @dev returns to normal state.
     */
    function unpause() public onlyAdmin whenPaused {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GenesisUniverseICO is ReentrancyGuard, Pausable, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _paymentToken;

    uint256 private _startTime;
    uint256 private _endTime;
    uint256 private _price = 5e16;
    uint256 private _icoTokenCount = 40000000e18;
    //Minimum and maximum subscription limits
    uint256 private _lowestAmount = 100e18;
    uint256 private _highestAmount = 50000e18;
    //The total raised amount, used to calculate the subscription ratio
    uint256 private _raisedAmount;
    address public beneficiary;
    bool public isCompleted = false;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _userWithdraw;

    constructor(
        address owner,
        address beneficiaryAddr,
        address paymentToken,
        uint256 startTime,
        uint256 endTime
    ) {
        _paymentToken = IERC20(paymentToken);
        beneficiary = beneficiaryAddr;
        _startTime = startTime;
        _endTime = endTime;
        transferOwnership(owner);
    }

    /** @notice Before starting, the startTime can be modified
     * @param newStartTime The new startTime
     */
    function updateStartTime(uint256 newStartTime) public onlyOwner {
        require(block.timestamp <= _startTime, "Must before startTime");
        _startTime = newStartTime;
        emit UpdateStartTime(newStartTime);
    }

    /** @notice Before starting, the endTime can be modified
     * @param newEndTime The new endTime
     */
    function updateEndTime(uint256 newEndTime) public onlyOwner {
        require(block.timestamp <= _startTime, "Must before startTime");
        _endTime = newEndTime;
        emit UpdateEndTime(newEndTime);
    }

    /** @notice Before starting, the icoTokenCount can be modified
     * @param newTokenCount The new icoTokenCount
     */
    function updateTokenCount(uint256 newTokenCount) public onlyOwner {
        require(block.timestamp <= _startTime, "Must before startTime");
        _icoTokenCount = newTokenCount;
        emit UpdateIcoTokenCount(newTokenCount);
    }

    /** @notice Before starting, the price can be modified
     * @param newPrice The new price
     */
    function updatePrice(uint256 newPrice) public onlyOwner {
        require(block.timestamp <= _startTime, "Must before startTime");
        _price = newPrice;
        emit UpdatePrice(newPrice);
    }

    /** @notice Before starting, the lowestAmount can be modified
     * @param newLowestAmount The new lowestAmount
     */
    function updateLowestAmount(uint256 newLowestAmount) public onlyOwner {
        require(block.timestamp <= _startTime, "Must before startTime");
        _lowestAmount = newLowestAmount;
        emit UpdateLowestAmount(newLowestAmount);
    }

    /** @notice Before starting, the highestAmount can be modified
     * @param newHighestAmount The new highestAmount
     */
    function updateHighestAmount(uint256 newHighestAmount) public onlyOwner {
        require(block.timestamp <= _startTime, "Must before startTime");
        _highestAmount = newHighestAmount;
        emit UpdateHighestAmount(newHighestAmount);
    }

    /** @notice Get all parameters
     * @return startTime ICO start time
     * @return endTime ICO end time
     * @return icoTokenCount The number of GUT tokens in the ICO
     * @return price The GUT token price
     * @return lowestAmount Minimum usdt amount for users to participate in ICO
     * @return highestAmount Maximum usdt amount for users to participate in ICO
     * @return targetRaisedAmount Target amount of usdt raised
     * @return currentRaisedAmount Current amount of usdt raised
     */
    function getIcoInfo()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _startTime,
            _endTime,
            _icoTokenCount,
            _price,
            _lowestAmount,
            _highestAmount,
            _getTargetRaisedAmount(),
            _getCurrentRaisedAmount()
        );
    }

    /** @notice Get the user's amount information
     * @param account The user's address
     * @return balance The amount of usdt paid by the user
     * @return buyReward The number of GUT tokens that users apply for subscription
     * @return successReward The number of GUT tokens that users can successfully subscribe
     */
    function getCustomerAmount(address account)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 buyReward = _balances[account].mul(1e18).div(_price);
        uint256 successReward = getCustomerSuccessReward(account);
        return (_balances[account], buyReward, successReward);
    }

    function getCustomerWithdraw(address account) public view returns (uint256) {
        return _userWithdraw[account];
    }

    /** @notice Users participate in ICO by paying USDT
     * @param amount The amount of USDT paid by the user
     */
    function buy(uint256 amount) public nonReentrant whenNotPaused {
        require(block.timestamp >= _startTime, "Must after startTime");
        require(block.timestamp <= _endTime, "Must before endTime");
        require(
            _balances[msg.sender] + amount >= _lowestAmount,
            "Subscription amount must be greater than lowestAmount"
        );
        require(
            _balances[msg.sender] + amount <= _highestAmount,
            "Subscription amount must be lower than highestAmount"
        );

        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _raisedAmount = _raisedAmount.add(amount);
        _paymentToken.safeTransferFrom(msg.sender, address(this), amount);
        emit CustomerBuy(msg.sender, amount);
    }

    /** @notice After the endTime, set the address of the GUT contract and withdraw usdt to the owner's address
     */
    function withdrawToken() public nonReentrant whenNotPaused onlyOwner {
        require(!isCompleted, "Already been completed");
        require(block.timestamp > _endTime, "Must after endTime");
        uint256 amount = _getTargetRaisedAmount();
        if (amount > _getCurrentRaisedAmount()) {
            amount = _getCurrentRaisedAmount();
        }
        _paymentToken.safeTransfer(beneficiary, amount);
        emit WithdrawToken(beneficiary, amount);
        isCompleted = true;
    }

    /** @notice Calculate the number of GUT tokens successfully subscribed by the user
     * @param account The user's address
     * @return The number of GUT tokens successfully subscribed by the user
     */
    function getCustomerSuccessReward(address account) public view returns (uint256) {
        uint256 targetRaisedAmount = _getTargetRaisedAmount();
        uint256 currentRaisedAmount = _getCurrentRaisedAmount();
        uint256 balance = _balances[account];
        if (targetRaisedAmount >= currentRaisedAmount) {
            return balance.mul(1e18).div(_price);
        } else {
            uint256 a = balance.mul(_icoTokenCount);
            uint256 b = currentRaisedAmount;
            return _ceilDiv(a, b);
        }
    }

    /** @notice Calculate the number of USDT tokens refund to user
     * @param account The user's address
     * @return The number of USDT refund amount
     */
    function getCustomerRefundAmount(address account) public view returns (uint256) {
        if (_userWithdraw[account] > 0) {
            return 0;
        }
        uint256 targetRaisedAmount = _getTargetRaisedAmount();
        uint256 currentRaisedAmount = _getCurrentRaisedAmount();
        if (currentRaisedAmount > targetRaisedAmount) {
            uint256 reward = getCustomerSuccessReward(account);
            return _balances[account].mul(1e18).sub(reward.mul(_price)).div(1e18);
        }
        return 0;
    }

    /** @notice User withdraws the remaining USDT and the successfully subscribed GUT
     */
    function customerWithdraw() public nonReentrant whenNotPaused {
        require(block.timestamp > _endTime, "Must after endTime");
        require(_userWithdraw[msg.sender] == 0, "User has already withdrawn");

        uint256 refundAmount = getCustomerRefundAmount(msg.sender);
        if (refundAmount > 0) {
            _userWithdraw[msg.sender] = refundAmount;
            _paymentToken.safeTransfer(msg.sender, refundAmount);
            emit CustomerWithdraw(msg.sender, refundAmount);
        }
    }

    /**
     * @dev triggers stopped state.
     */
    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @dev returns to normal state.
     */
    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    /** @notice Get target amount of usdt raised
     * @return Target amount of usdt raised
     */
    function _getTargetRaisedAmount() internal view returns (uint256) {
        return _icoTokenCount.mul(_price).div(1e18);
    }

    /** @notice Get current amount of usdt raised
     * @return Current amount of usdt raised
     */
    function _getCurrentRaisedAmount() internal view returns (uint256) {
        return _raisedAmount;
    }

    function _ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }

    /* ========== EVENTS ========== */
    event UpdateStartTime(uint256 startTime);
    event UpdateEndTime(uint256 endTime);
    event UpdatePrice(uint256 price);
    event UpdateIcoTokenCount(uint256 icoTokenCount);
    event UpdateLowestAmount(uint256 lowestAmout);
    event UpdateHighestAmount(uint256 highestAmout);
    event UpdateRaisedAmount(uint256 raisedAmount);
    event CustomerBuy(address user, uint256 amount);
    event WithdrawToken(address beneficiary, uint256 amount);
    event CustomerWithdraw(address user, uint256 amount);
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

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./common/WithAdmin.sol";
import "../interfaces/IGUTInvitationToken.sol";

contract GUTInvitationToken is ERC20Burnable, IGUTInvitationToken, WithAdmin {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    bool public tradable = false;

    constructor(address _admin) ERC20("GUTInvitationToken", "GUTInvitationToken") {
        _setupAdmin(_admin);
    }

    function addOperator(address operator) public override onlyAdmin {
        grantRole(OPERATOR_ROLE, operator);
        emit AddOperator(operator);
    }

    function removeOperator(address operator) public override onlyAdmin {
        revokeRole(OPERATOR_ROLE, operator);
        emit RemoveOperator(operator);
    }

    function setTradable(bool able) public override onlyAdmin {
        tradable = able;
        emit SetTradable(able);
    }

    function managerMint(address addr, uint256 amount) public override onlyRole(OPERATOR_ROLE) {
        _mint(addr, amount);
    }

    function managerBurn(address addr, uint256 amount) public override onlyRole(OPERATOR_ROLE) {
        _burn(addr, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal virtual override {
        if (tradable == false) {
            require(to == address(0) || from == address(0), "cannot transfer");
        }
    }

    event AddOperator(address operator);
    event RemoveOperator(address operator);
    event SetTradable(bool able);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IGUTInvitationToken {
    function addOperator(address operator) external;

    function removeOperator(address operator) external;

    function setTradable(bool able) external;

    function managerMint(address addr, uint256 amount) external;

    function managerBurn(address addr, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "../interfaces/IveGUT.sol";
import "../interfaces/IInvitation.sol";
import "../interfaces/IGUTInvitationToken.sol";
import "../interfaces/IGUTUtils.sol";
import "./common/PausableWithAdminUpgradeable.sol";

contract GUTStaking is Initializable, ReentrancyGuardUpgradeable, ContextUpgradeable, PausableWithAdminUpgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IveGUT;

    uint256 public constant RATIO_BASENUMBER = 1e6;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    struct ExitFeeLevel {
        uint256 number;
        uint256 rate;
    }

    address public gutToken;
    address public vegutToken;
    address public invitationToken;
    IInvitation public invitation;
    IGUTUtils public gutUtils;

    uint256 public defaultExitFee;
    uint256 public exchangeRatio;
    uint256 public burnRatio;

    ExitFeeLevel[] public exitFeeLevelMap;
    uint256[] public invitationBoundLevel;

    function initialize(
        address _admin,
        address _gutToken,
        address _vegutToken,
        address _invitationToken,
        address _invitation,
        address _gutUtils,
        uint256 _defaultExitFee,
        uint256 _exchangeRatio,
        uint256 _burnRatio,
        uint256[] memory _existFeeLevelList,
        uint256[] memory _invitationLevelList
    ) public initializer {
        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __PausableWithAdmin_init_unchained(_admin);

        gutToken = _gutToken;
        vegutToken = _vegutToken;
        invitationToken = _invitationToken;
        invitation = IInvitation(_invitation);
        gutUtils = IGUTUtils(_gutUtils);

        _setDefaultExitFee(_defaultExitFee);
        _setExchangeRatio(_exchangeRatio);
        _setBurnRatio(_burnRatio);

        _setExitFeeLevelMap(_existFeeLevelList);
        _setInvitationBoundLevel(_invitationLevelList);
    }

    /** @notice Set default exit fee
     * @param newDefaultExitFee uint256
     */
    function setDefaultExitFee(uint256 newDefaultExitFee) public onlyAdmin {
        _setDefaultExitFee(newDefaultExitFee);
    }

    /** @notice Set the exchange ratio of GUT and veGUT
     * @param newExchangeRatio uint256
     */
    function setExchangeRatio(uint256 newExchangeRatio) public onlyAdmin {
        _setExchangeRatio(newExchangeRatio);
    }

    /** @notice Set destruction ratio when users unstake
     * @param newBurnRatio uint256
     */
    function setBurnRatio(uint256 newBurnRatio) public onlyAdmin {
        _setBurnRatio(newBurnRatio);
    }

    /** @notice Set user exit fee ratio
     * @dev When you setExitFeeLevelMap, you need to pay attention to defaultExitFee
     * @param levelList uint256[]
     */
    function setExitFeeLevelMap(uint256[] memory levelList) public onlyAdmin {
        _setExitFeeLevelMap(levelList);
    }

    /** @notice Set reward rate for inviting users
     * @param levelList uint256[]
     */
    function setInvitationBoundLevel(uint256[] memory levelList) public onlyAdmin {
        _setInvitationBoundLevel(levelList);
    }

    /**
        @notice increases supply to increase staking balances relative to profit
     */
    function rebase() public whenNotPaused {
        uint256 balance = IERC20Upgradeable(gutToken).balanceOf(address(this)).mul(exchangeRatio);
        uint256 circulating = IveGUT(vegutToken).circulatingSupply();
        if (balance > circulating) {
            IveGUT(vegutToken).rebase(balance.sub(circulating));
        }
    }

    /**
        @notice gut staking
        @param amount staking amount
     */
    function stake(uint256 amount) public nonReentrant whenNotPaused {
        require(amount > 0, "amount must be greater than 0");
        rebase();
        uint256 veGutAmount = amount.mul(exchangeRatio);
        if (invitation.hasInviter(msg.sender)) {
            address inviter = invitation.getInviter(msg.sender);
            invitation.addInviteeTokenCount(inviter, amount);
            uint256 tokenRewardRadio = invitationBoundRatio(inviter);
            if (tokenRewardRadio > 0) {
                uint256 tokenReward = tokenRewardRadio.mul(veGutAmount).div(RATIO_BASENUMBER);
                IGUTInvitationToken(invitationToken).managerMint(inviter, tokenReward);
                invitation.addTotalInvitationToken(inviter, tokenReward);
            }
        }
        IERC20Upgradeable(vegutToken).safeTransfer(msg.sender, veGutAmount);
        IERC20Upgradeable(gutToken).safeTransferFrom(msg.sender, address(this), amount);
        emit Stake(msg.sender, amount);
    }

    /**
        @notice gut unstake
        @param amount unstake amount
     */
    function unstake(uint256 amount) public nonReentrant whenNotPaused {
        require(amount > 0, "amount must be greater than 0");
        require(amount <= IERC20Upgradeable(vegutToken).balanceOf(msg.sender), "amount must be lower than balance");
        if (IERC20(invitationToken).balanceOf(msg.sender) > 0) {
            invitation.addBurnInvitationToken(msg.sender, IERC20Upgradeable(invitationToken).balanceOf(msg.sender));
            IGUTInvitationToken(invitationToken).managerBurn(
                msg.sender,
                IERC20Upgradeable(invitationToken).balanceOf(msg.sender)
            );
        }
        if (invitation.hasInviter(msg.sender)) {
            invitation.subInviteeTokenCount(invitation.getInviter(msg.sender), amount.div(exchangeRatio));
        }
        uint256 exitFee = exitFeeRatio().mul(amount).div(RATIO_BASENUMBER);
        //burn 60%
        uint256 burnToken = exitFee.mul(burnRatio).div(RATIO_BASENUMBER);
        IERC20Upgradeable(vegutToken).safeTransferFrom(msg.sender, address(this), amount);
        //burn vegut
        IERC20Upgradeable(vegutToken).safeTransfer(BURN_ADDRESS, burnToken);
        IERC20Upgradeable(gutToken).safeTransfer(msg.sender, amount.sub(exitFee).div(exchangeRatio));
        rebase();
        emit Unstake(msg.sender, amount);
    }

    function exitFeeRatio() public view returns (uint256) {
        uint256 balance = IERC20Upgradeable(gutToken).balanceOf(address(this));
        uint256 rate = defaultExitFee;
        if (balance == 0 || exitFeeLevelMap.length == 0 || gutUtils.getGUTCirculatingSupply() == 0) {
            return rate;
        }
        uint256 baseNumber = gutUtils.getGUTCirculatingSupply().mul(RATIO_BASENUMBER).div(balance);
        for (uint256 i = 0; i < exitFeeLevelMap.length; i++) {
            rate = exitFeeLevelMap[i].rate;
            if (baseNumber >= exitFeeLevelMap[i].number) {
                break;
            }
        }
        return rate;
    }

    function invitationBoundRatio(address inviterAddr) public view returns (uint256) {
        (uint256 memberLevel, , ) = gutUtils.getMemberInfo(inviterAddr);
        if (memberLevel < invitationBoundLevel.length) {
            return invitationBoundLevel[memberLevel];
        } else {
            return invitationBoundLevel[invitationBoundLevel.length.sub(1)];
        }
    }

    function _setDefaultExitFee(uint256 newDefaultExitFee) private {
        defaultExitFee = newDefaultExitFee;
        emit SetDefaultExitFee(newDefaultExitFee);
    }

    function _setExchangeRatio(uint256 newExchangeRatio) private {
        exchangeRatio = newExchangeRatio;
        emit SetExchangeRatio(newExchangeRatio);
    }

    function _setBurnRatio(uint256 newBurnRatio) private {
        burnRatio = newBurnRatio;
        emit SetBurnRatio(newBurnRatio);
    }

    function _setExitFeeLevelMap(uint256[] memory levelList) internal {
        require(levelList.length % 2 == 0, "exitFee Level data error");
        delete exitFeeLevelMap;
        for (uint256 i = 0; i < levelList.length; i += 2) {
            exitFeeLevelMap.push(ExitFeeLevel(levelList[i], levelList[i + 1]));
        }
        emit SetExitFeeLevelMap(levelList);
    }

    function _setInvitationBoundLevel(uint256[] memory levelList) internal {
        delete invitationBoundLevel;
        invitationBoundLevel = levelList;
        emit SetInvitationBoundLevel(levelList);
    }

    /* ========== EVENTS ========== */
    event SetDefaultExitFee(uint256 newDefaultExitFee);
    event SetExchangeRatio(uint256 newExchangeRatio);
    event SetBurnRatio(uint256 newBurnRatio);
    event SetExitFeeLevelMap(uint256[] levelList);
    event SetInvitationBoundLevel(uint256[] levelList);
    event Stake(address addr, uint256 amount);
    event Unstake(address addr, uint256 amount);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IInvitation {
    function addOperator(address operator) external;

    function removeOperator(address operator) external;

    function setInviter(address inviterAddr) external;

    function addInvitee(address inviterAddr, address inviteeAddr) external;

    function addInviteeTokenCount(address addr, uint256 amount) external;

    function subInviteeTokenCount(address addr, uint256 amount) external;

    function addTotalInvitationToken(address addr, uint256 amount) external;

    function addBurnInvitationToken(address addr, uint256 amount) external;

    function addUsedInvitationToken(address addr, uint256 amount) external;

    function subUsedInvitationToken(address addr, uint256 amount) external;

    function hasInviter(address inviteeAddr) external returns (bool);

    function getInviter(address inviteeAddr) external view returns (address);

    function getInviteeTokenCount(address inviterAddr) external view returns (uint256);

    function getUserInfo(address userAddr)
        external
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "./WithAdminUpgradeable.sol";

abstract contract PausableWithAdminUpgradeable is Initializable, WithAdminUpgradeable, PausableUpgradeable {
    function __PausableWithAdmin_init(address admin) internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __PausableWithAdmin_init_unchained(admin);
    }

    function __PausableWithAdmin_init_unchained(address admin) internal initializer {
        __WithAdmin_init_unchained(admin);
        __Pausable_init_unchained();
    }

    /**
     * @dev triggers stopped state.
     */
    function pause() public onlyAdmin whenNotPaused {
        _pause();
    }

    /**
     * @dev returns to normal state.
     */
    function unpause() public onlyAdmin whenPaused {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./ContextUpgradeable.sol";
import "../proxy/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "../common/PausableWithAdminUpgradeable.sol";

contract PausableWithAdminUpgradeableMock is Initializable, PausableWithAdminUpgradeable {
    function initialize(address admin) public initializer {
        __PausableWithAdmin_init(admin);
    }

    function foo() public view onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "../common/WithAdminUpgradeable.sol";

contract WithAdminUpgradeableMock is Initializable, WithAdminUpgradeable {
    function initialize(address admin) public initializer {
        __WithAdmin_init(admin);
    }

    function foo() public view onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "./common/WithAdminUpgradeable.sol";
import "../interfaces/IInvitation.sol";

contract Invitation is
    IInvitation,
    Initializable,
    ContextUpgradeable,
    ReentrancyGuardUpgradeable,
    WithAdminUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    struct UserInfo {
        address inviterAddr;
        uint256 inviteeCount;
        //The total GUT count of inviting users
        uint256 inviteeTokenCount;
        //The total GUTInvitationToken received count of inviting users
        uint256 totalInvitationToken;
        //The total burned GUTInvitationToken count of user unstake
        uint256 burnInvitationToken;
        //The total GUTInvitationToken count of used
        uint256 usedInvitationToken;
    }
    mapping(address => UserInfo) private _users;

    function initialize(address _admin) public initializer {
        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __WithAdmin_init_unchained(_admin);
    }

    /**
        @notice Add Operator
        @param operator Operator address
     */
    function addOperator(address operator) public override onlyAdmin {
        grantRole(OPERATOR_ROLE, operator);
        emit AddOperator(operator);
    }

    /**
        @notice Remove Operator
        @param operator Operator address
     */
    function removeOperator(address operator) public override onlyAdmin {
        revokeRole(OPERATOR_ROLE, operator);
        emit RemoveOperator(operator);
    }

    /**
        @notice Set the inviter for users
        @param inviterAddr inviter address
     */
    function setInviter(address inviterAddr) public override nonReentrant {
        _addInvitee(inviterAddr, msg.sender);
    }

    /**
        @notice Set invitation relationships for inviter and invitee
        @param inviterAddr inviter address
        @param inviteeAddr invitee address
     */
    function addInvitee(address inviterAddr, address inviteeAddr) public override nonReentrant onlyRole(OPERATOR_ROLE) {
        _addInvitee(inviterAddr, inviteeAddr);
    }

    /**
        @notice Add the inviteeTokenCount to user
        @dev This function is called when the user stake
        @param addr address
        @param amount uint256
     */
    function addInviteeTokenCount(address addr, uint256 amount) public override nonReentrant onlyRole(OPERATOR_ROLE) {
        _users[addr].inviteeTokenCount = _users[addr].inviteeTokenCount.add(amount);
        emit AddInviteeTokenCount(addr, amount);
    }

    /**
        @notice subside the inviteeTokenCount to user
        @dev This function is called when the user unstake
        @param addr address
        @param amount uint256
     */
    function subInviteeTokenCount(address addr, uint256 amount) public override nonReentrant onlyRole(OPERATOR_ROLE) {
        _users[addr].inviteeTokenCount = _users[addr].inviteeTokenCount.sub(amount);
        emit SubInviteeTokenCount(addr, amount);
    }

    /**
        @notice Add the totalInvitationToken to user
        @dev This function is called when user get the GUTInvitationToken in stake
        @param addr address
        @param amount uint256
     */
    function addTotalInvitationToken(address addr, uint256 amount)
        public
        override
        nonReentrant
        onlyRole(OPERATOR_ROLE)
    {
        _users[addr].totalInvitationToken = _users[addr].totalInvitationToken.add(amount);
        emit AddTotalInvitationToken(addr, amount);
    }

    /**
        @notice This function is called when burn the GUTInvitationToken
        @param addr address
        @param amount uint256
     */
    function addBurnInvitationToken(address addr, uint256 amount) public override nonReentrant onlyRole(OPERATOR_ROLE) {
        _users[addr].burnInvitationToken = _users[addr].burnInvitationToken.add(amount);
        emit AddBurnInvitationToken(addr, amount);
    }

    /**
        @notice This function is called when user used the GUTInvitationToken
        @param addr address
        @param amount uint256
     */
    function addUsedInvitationToken(address addr, uint256 amount) public override nonReentrant onlyRole(OPERATOR_ROLE) {
        _users[addr].usedInvitationToken = _users[addr].usedInvitationToken.add(amount);
        emit AddUsedInvitationToken(addr, amount);
    }

    function subUsedInvitationToken(address addr, uint256 amount) public override nonReentrant onlyRole(OPERATOR_ROLE) {
        _users[addr].usedInvitationToken = _users[addr].usedInvitationToken.sub(amount);
        emit SubUsedInvitationToken(addr, amount);
    }

    function hasInviter(address inviteeAddr) public view override returns (bool) {
        return _users[inviteeAddr].inviterAddr != address(0);
    }

    function getInviter(address inviteeAddr) public view override returns (address) {
        return _users[inviteeAddr].inviterAddr;
    }

    /** @notice Get inviteeTokenCount
     * @return inviteeTokenCount The total GUT count of inviting users
     */
    function getInviteeTokenCount(address inviterAddr) public view override returns (uint256) {
        return _users[inviterAddr].inviteeTokenCount;
    }

    /** @notice Get all user info
     * @return inviterAddr inviter address
     * @return inviteeCount invitees count
     * @return inviteeTokenCount The total GUT count of inviting users
     * @return totalInvitationToken The total GUTInvitationToken received count of inviting users
     * @return burnInvitationToken The total burned GUTInvitationToken count of user unstake
     * @return usedInvitationToken The total GUTInvitationToken count of used
     */
    function getUserInfo(address userAddr)
        public
        view
        override
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        UserInfo storage user = _users[userAddr];
        return (
            user.inviterAddr,
            user.inviteeCount,
            user.inviteeTokenCount,
            user.totalInvitationToken,
            user.burnInvitationToken,
            user.usedInvitationToken
        );
    }

    function _addInvitee(address inviterAddr, address inviteeAddr) private {
        if (inviterAddr == address(0)) {
            emit RegisteredInviterFailed(inviterAddr, inviteeAddr, "inviter cannot be zero address");
            return;
        } else if (inviteeAddr == address(0)) {
            emit RegisteredInviterFailed(inviterAddr, inviteeAddr, "invitee cannot be zero address");
            return;
        } else if (inviterAddr == inviteeAddr) {
            emit RegisteredInviterFailed(inviterAddr, inviteeAddr, "inviter cannot be same with invitee");
            return;
        } else if (_users[inviteeAddr].inviterAddr != address(0)) {
            emit RegisteredInviterFailed(inviterAddr, inviteeAddr, "The invitee has been invited");
            return;
        }
        _users[inviteeAddr].inviterAddr = inviterAddr;
        _users[inviterAddr].inviteeCount = _users[inviterAddr].inviteeCount.add(1);
        emit AddInvitee(inviterAddr, inviteeAddr);
    }

    event AddOperator(address operator);
    event RemoveOperator(address operator);
    event AddInvitee(address inviter, address invitee);
    event AddInviteeTokenCount(address addr, uint256 amount);
    event SubInviteeTokenCount(address addr, uint256 amount);
    event AddTotalInvitationToken(address addr, uint256 amount);
    event AddBurnInvitationToken(address addr, uint256 amount);
    event AddUsedInvitationToken(address addr, uint256 amount);
    event SubUsedInvitationToken(address addr, uint256 amount);
    event RegisteredInviterFailed(address inviter, address invitee, string reason);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "../common/PausableWithAdminUpgradeable.sol";
import "../../libraries/LibETH.sol";

/**
 * @title NFT Marketplace
 */
contract Marketplace is
    Initializable,
    ReentrancyGuardUpgradeable,
    ContextUpgradeable,
    PausableWithAdminUpgradeable,
    IERC721ReceiverUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

    /**
     * @dev Accepted ERC20
     */
    mapping(address => bool) public acceptedToken;
    /**
     * @dev Accepted NFT
     */
    mapping(address => bool) public acceptedNFT;

    struct Order {
        // Order ID
        bytes32 id;
        // Owner of the NFT
        address seller;
        // NFT registry address
        address nftAddress;
        // Accepted token
        address currency;
        // Price (in wei) for the published item
        uint256 price;
    }

    /**
     * @dev Marketplace exchange fee receiver.
     */
    address payable public feeReceiver;

    uint256 public feeRate;

    mapping(address => mapping(uint256 => Order)) public orderByAssetId;

    function initialize(
        address _admin,
        address payable _feeReceiver,
        uint256 _feeRate
    ) public initializer {
        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __PausableWithAdmin_init_unchained(_admin);

        _setFeeReceiver(_feeReceiver);

        // Init fee
        _setFeeRate(_feeRate);
    }

    function setFeeReceiver(address payable newFeeReceiver) public onlyAdmin {
        _setFeeReceiver(newFeeReceiver);
    }

    function setFeeRate(uint256 newFeeRate) public onlyAdmin {
        _setFeeRate(newFeeRate);
    }

    function _setFeeReceiver(address payable newFeeReceiver) internal {
        require(newFeeReceiver != address(0), "Marketplace: Invalid feeReceiver");
        feeReceiver = newFeeReceiver;
    }

    function _setFeeRate(uint256 newFeeRate) internal {
        require(newFeeRate < 1000000, "Marketplace: The fee rate should be between 0 and 999,999");
        if (newFeeRate == feeRate) {
            return;
        }
        feeRate = newFeeRate;
        emit ChangedFeeRate(feeRate);
    }

    /**
     * @dev Sell NFT
     */
    function sell(
        address nftAddress,
        uint256 tokenId,
        address currency,
        uint256 price
    ) external nonReentrant whenNotPaused {
        require(acceptedNFT[nftAddress], "Marketplace: The NFT not accepted");
        require(acceptedToken[currency], "Marketplace: The currency not accepted");
        require(tokenId != 0, "Marketplace: tokenId can not be 0");
        require(price > 0, "Marketplace: Price should be bigger than 0");
        address seller = _msgSender();
        bytes32 orderId = keccak256(abi.encodePacked(block.timestamp, seller, tokenId, nftAddress, currency, price));

        orderByAssetId[nftAddress][tokenId] = Order({
            id: orderId,
            seller: seller,
            nftAddress: nftAddress,
            currency: currency,
            price: price
        });

        IERC721Upgradeable(nftAddress).safeTransferFrom(seller, address(this), tokenId);

        emit OrderCreated(orderId, nftAddress, tokenId, seller, currency, price);
    }

    /**
     * @dev Cancel order
     */
    function cancel(address nftAddress, uint256 tokenId) external whenNotPaused {
        Order memory order = orderByAssetId[nftAddress][tokenId];
        address sender = _msgSender();

        require(order.id != 0, "Marketplace: Asset not published");
        require(order.seller == sender || isAdmin(sender), "Marketplace: Unauthorized user");

        bytes32 orderId = order.id;
        address orderSeller = order.seller;
        address orderNftAddress = order.nftAddress;

        IERC721Upgradeable(nftAddress).safeTransferFrom(address(this), orderSeller, tokenId);
        delete orderByAssetId[nftAddress][tokenId];

        emit OrderCancelled(orderId, orderNftAddress, tokenId, orderSeller);
    }

    /**
     * @dev Buy NFT
     */
    function buy(address nftAddress, uint256 tokenId) external payable whenNotPaused {
        Order memory order = orderByAssetId[nftAddress][tokenId];
        address sender = _msgSender();
        address seller = order.seller;
        require(order.id != 0, "Marketplace: Asset not published");
        require(seller != address(0), "Marketplace: Invalid seller");
        require(seller != sender, "Marketplace: Sender cannot be seller");
        if (order.currency == address(0) || order.currency == LibETH.BNB) {
            require(msg.value == order.price, "Marketplace: The price is not correct");
        } else {
            require(msg.value == 0, "Marketplace: The currency not accepted");
        }

        bytes32 orderId = order.id;
        address currency = order.currency;
        uint256 price = order.price;
        delete orderByAssetId[nftAddress][tokenId];

        uint256 shareAmount = 0;
        if (feeRate > 0) {
            shareAmount = price.mul(feeRate).div(1000000);
            // transfer fee
            transfer(currency, sender, feeReceiver, shareAmount);
        }
        transfer(currency, sender, seller, price.sub(shareAmount));

        IERC721Upgradeable(nftAddress).safeTransferFrom(address(this), sender, tokenId);

        emit OrderSuccessful(orderId, nftAddress, tokenId, seller, currency, price, sender);
    }

    function setAcceptedToken(address _tokenAddress, bool _accepted) external onlyAdmin {
        require(
            _tokenAddress == LibETH.BNB || _tokenAddress.isContract(),
            "Marketplace: The accepted token address must be contract"
        );
        bool accepted = acceptedToken[_tokenAddress];
        if (_accepted == accepted) {
            return;
        }

        acceptedToken[_tokenAddress] = _accepted;
        emit ChangedAcceptedToken(_tokenAddress, _accepted);
    }

    /**
     * @notice set accepted NFT address
     * @param _nftAddress NFT address
     */
    function setAcceptedNFT(address _nftAddress, bool _accepted) external onlyAdmin {
        _requireERC721(_nftAddress);
        bool accepted = acceptedNFT[_nftAddress];
        if (_accepted == accepted) {
            return;
        }

        acceptedNFT[_nftAddress] = _accepted;
        emit ChangedAcceptedNFT(_nftAddress, _accepted);
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external view override returns (bytes4) {
        require(orderByAssetId[_msgSender()][tokenId].id != 0);
        return this.onERC721Received.selector;
    }

    function _requireERC721(address nftAddress) internal view {
        require(nftAddress.isContract(), "Marketplace: The NFT Address should be a contract");

        IERC165Upgradeable nftRegistry = IERC165Upgradeable(nftAddress);
        require(
            nftRegistry.supportsInterface(ERC721_Interface),
            "Marketplace: The NFT contract has an invalid ERC721 implementation"
        );
    }

    function transfer(
        address currency,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (currency == address(0) || currency == LibETH.BNB) {
            address payable toPayable = payable(to);
            toPayable.transfer(amount);
        } else {
            IERC20Upgradeable(currency).safeTransferFrom(from, to, amount);
        }
    }

    event OrderCreated(
        bytes32 id,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed seller,
        address currency,
        uint256 price
    );

    event OrderCancelled(bytes32 id, address indexed nftAddress, uint256 indexed tokenId, address indexed seller);

    event OrderSuccessful(
        bytes32 id,
        address nftAddress,
        uint256 indexed tokenId,
        address indexed seller,
        address currency,
        uint256 price,
        address indexed buyer
    );

    event ChangedAcceptedToken(address tokenAddress, bool isAccepted);

    event ChangedAcceptedNFT(address nftAddress, bool isAccepted);

    event ChangedFeeRate(uint256 feeRate);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../../interfaces/ICard.sol";
import "../../interfaces/IBlindBox.sol";
import "../common/WithAdminUpgradeable.sol";

/**
 * @title LETBlindBox
 * @author Genesis Universe-TEAM
 */
contract LETBlindBox is IBlindBox, WithAdminUpgradeable {
    using SafeMath for uint256;

    bytes32 public constant FACTORY = keccak256("FACTORY");
    uint256 public constant MAX_SUPPLY = 12050;
    uint256 public sold;
    ICard public card;

    struct LimitedCardsPoolInfo {
        uint8 star;
        uint256 count;
        uint256 start;
        uint256 end;
    }
    mapping(uint256 => LimitedCardsPoolInfo) public limitedCardPoolMapping;
    mapping(uint256 => uint256) public starToProto;

    function initialize(address _admin, address _nft) public initializer {
        __WithAdmin_init_unchained(_admin);

        card = ICard(_nft);

        _setLimitedCardPoolInfo(1, 8000, 4051, 12050);
        _setLimitedCardPoolInfo(2, 2500, 1551, 4050);
        _setLimitedCardPoolInfo(3, 1000, 551, 1550);
        _setLimitedCardPoolInfo(4, 400, 151, 550);
        _setLimitedCardPoolInfo(5, 150, 1, 150);

        _initProto();
    }

    function _initProto() private {
        for (uint256 star = 1; star <= 5; star++) {
            starToProto[star] = star.mul(1000);
        }
    }

    function setLimitedCardPoolInfo(
        uint8 _star,
        uint256 _count,
        uint256 _start,
        uint256 _end
    ) external onlyAdmin {
        _setLimitedCardPoolInfo(_star, _count, _start, _end);
    }

    function _setLimitedCardPoolInfo(
        uint8 _star,
        uint256 _count,
        uint256 _start,
        uint256 _end
    ) private {
        require(_star <= 5, "star verification failed");
        limitedCardPoolMapping[_star] = LimitedCardsPoolInfo(_star, _count, _start, _end);
        emit SetLimitedCardPoolInfo(_star, _count, _start, _end);
    }

    function addFactory(address _factory) external onlyAdmin {
        grantRole(FACTORY, _factory);
    }

    function removeFactory(address _factory) external onlyAdmin {
        revokeRole(FACTORY, _factory);
    }

    function _getPoolInfoFromPosition(uint256 _position) public view returns (uint8 _star, uint256 _count) {
        LimitedCardsPoolInfo memory poolInfo;
        for (uint8 i = 1; i <= 5; i++) {
            poolInfo = limitedCardPoolMapping[i];
            if (_position >= poolInfo.start && _position <= poolInfo.end) {
                _star = poolInfo.star;
                _count = poolInfo.count;
                break;
            }
        }
    }

    function _validStar(uint8 star) private view returns (uint8 _star) {
        LimitedCardsPoolInfo memory poolInfo;
        for (uint8 i = star - 1; i >= 1; i--) {
            poolInfo = limitedCardPoolMapping[i];
            if (poolInfo.count != 0) {
                _star = i;
                return _star;
            }
        }
        if (poolInfo.count == 0) {
            for (uint8 i = star + 1; i <= 5; i++) {
                poolInfo = limitedCardPoolMapping[i];
                if (poolInfo.count != 0) {
                    _star = i;
                    return _star;
                }
            }
        }
    }

    /**
     * @dev v1 , this will be a automic operation for next version
     * @param _to mint account address
     * @param _randomness random
     */
    function open(
        address _to,
        uint256 _count,
        uint256 _randomness
    ) external override onlyRole(FACTORY) {
        uint256[] memory result = predict(_randomness, _count);
        uint8 star = uint8(result[0]);
        card.mint(_to, star, uint16(result[1]));
        limitedCardPoolMapping[star].count = limitedCardPoolMapping[star].count.sub(1);
    }

    function available() external view override returns (uint256) {
        return MAX_SUPPLY.sub(sold);
    }

    function buy(uint256 _count) external override onlyRole(FACTORY) returns (bool) {
        if (_count == 1 && sold < MAX_SUPPLY) {
            sold = sold.add(1);
            return true;
        }
        return false;
    }

    function predict(uint256 _randomness, uint256) public view override returns (uint256[] memory result) {
        result = new uint256[](2);
        uint256 expandedValue = _randomness.mod(MAX_SUPPLY).add(1);
        (uint8 star, uint256 count) = _getPoolInfoFromPosition(expandedValue);
        if (count == 0) {
            star = _validStar(star);
        }
        result[0] = star;
        result[1] = starToProto[star];
    }

    event SetLimitedCardPoolInfo(uint8 _star, uint256 _count, uint256 _start, uint256 _end);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @title IBlindBox
 * @author Genesis Universe-TEAM
 */
interface ICard {
    function mint(
        address _to,
        uint8 _star,
        uint16 _name
    ) external;

    function mint(
        address _to,
        uint8 _star,
        uint8 _alignment,
        uint16 _name,
        uint8 _attack,
        uint8 _defense,
        uint8 _constitution,
        uint8 _agile
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @title IBlindBox
 * @author Genesis Universe-TEAM
 */
interface IBlindBox {
    function open(
        address _to,
        uint256 _count,
        uint256 _randomness
    ) external;

    function buy(uint256 _count) external returns (bool);

    function available() external view returns (uint256);

    function predict(uint256 _randomness, uint256 _index) external view returns (uint256[] memory _result);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../../interfaces/ICard.sol";
import "../../interfaces/IBlindBox.sol";
import "../common/WithAdminUpgradeable.sol";

/**
 * @title GETBlindBox
 * @author Genesis Universe-TEAM
 */
contract GETBlindBox is IBlindBox, WithAdminUpgradeable {
    using SafeMath for uint256;

    bytes32 public constant FACTORY = keccak256("FACTORY");
    uint256 private constant _MAX_SUPPLY = type(uint256).max;
    ICard public card;

    mapping(uint256 => mapping(uint256 => uint256[])) public starToProto;
    mapping(uint256 => uint256[]) public _starToAlignments;

    uint256 public purchaseLimit;
    uint256 public sold;

    /**
     * @param _admin admin
     * @param _nft limited card address
     */
    function initialize(address _admin, address _nft) public initializer {
        __WithAdmin_init_unchained(_admin);
        purchaseLimit = 5;
        card = ICard(_nft);
        _initProto();
    }

    /**
     * @dev owner should set nft card uri in ipfs at first
     */
    function _initProto() private {
        for (uint256 star = 1; star <= 5; star++) {
            for (uint256 alignment = 1; alignment <= 6; alignment++) {
                starToProto[star][alignment].push(star.mul(1000).add(alignment.mul(100)));
                _starToAlignments[star].push(alignment);
            }
        }
    }

    function addProto(uint256[] memory _stars, uint256[] memory _alignments) external onlyAdmin {
        require(_stars.length == _alignments.length, "length should same");
        for (uint256 i = 0; i < _stars.length; i++) {
            uint256 length = starToProto[_stars[i]][_alignments[i]].length;
            uint256 lastName = starToProto[_stars[i]][_alignments[i]][length.sub(1)];
            starToProto[_stars[i]][_alignments[i]].push(lastName.add(1));
        }
    }

    function addFactory(address _factory) external onlyAdmin {
        grantRole(FACTORY, _factory);
    }

    function removeFactory(address _factory) external onlyAdmin {
        revokeRole(FACTORY, _factory);
    }

    function setPurchaseLimit(uint256 _limit) external onlyAdmin {
        purchaseLimit = _limit;
        emit SetPurchaseLimit(_limit);
    }

    function buy(uint256 _count) external override onlyRole(FACTORY) returns (bool) {
        if (_count == 1 || _count == purchaseLimit) {
            sold = sold.add(_count);
            return true;
        }
        return false;
    }

    /**
     * @dev v1 , this will be a automic operation for next version
     * @param _to mint account address
     * @param _count mint count
     * @param _randomness random
     */
    function open(
        address _to,
        uint256 _count,
        uint256 _randomness
    ) external override onlyRole(FACTORY) {
        for (uint256 i = 0; i < _count; i++) {
            uint256[] memory result = predict(_randomness, i);
            card.mint(
                _to,
                uint8(result[0]),
                uint8(result[1]),
                uint16(result[2]),
                uint8(result[3]),
                uint8(result[4]),
                uint8(result[5]),
                uint8(result[6])
            );
        }
    }

    function _getAlignmentAndName(uint256 _star, uint256 _randomness)
        private
        view
        returns (uint8 _alignment, uint256 _name)
    {
        uint256 length = _starToAlignments[_star].length;
        _alignment = uint8(_randomness.mod(length).add(1));
        uint256[] memory names = starToProto[_star][_alignment];
        _name = names[_randomness.mod(names.length)];
    }

    function _getStarAndTalentTotalByRandom(uint256 _random) private pure returns (uint8 _star, uint256 _talentTotal) {
        uint256 starBase = _random.mod(100).add(1);
        if (starBase >= 1 && starBase <= 50) {
            // 50% 4<=X＜220
            _star = 1;
            _talentTotal = _random.mod(216).add(4);
        } else if (starBase >= 51 && starBase <= 70) {
            // 20% 220≤X＜260
            _star = 2;
            _talentTotal = _random.mod(40).add(220);
        } else if (starBase >= 71 && starBase <= 85) {
            // 15% 260≤X＜300
            _star = 3;
            _talentTotal = _random.mod(40).add(260);
        } else if (starBase >= 86 && starBase <= 95) {
            // 10% 300≤X＜340
            _star = 4;
            _talentTotal = _random.mod(40).add(300);
            //330
        } else if (starBase >= 96 && starBase <= 100) {
            // 5% 340≤X
            _star = 5;
            _talentTotal = _random.mod(60).add(341);
        }
    }

    function _getRandomCardAttr(uint256 _random, uint256 _talentTotal)
        private
        view
        returns (uint256[] memory _attrArray)
    {
        _attrArray = new uint256[](4);
        uint256[] memory _swapAttrArray = new uint256[](5);
        _swapAttrArray[0] = 0;
        uint256 base = _talentTotal >= 100 ? 100 : _talentTotal;
        for (uint256 i = 1; i < 4; i++) {
            _swapAttrArray[i] = uint256(keccak256(abi.encode(_random, i))).mod(base).add(i);
        }
        _swapAttrArray[4] = _talentTotal;
        _swapAttrArray = sortArray(_swapAttrArray);
        _attrArray[0] = _swapAttrArray[1].sub(_swapAttrArray[0]);
        _attrArray[1] = _swapAttrArray[2].sub(_swapAttrArray[1]);
        _attrArray[2] = _swapAttrArray[3].sub(_swapAttrArray[2]);
        _attrArray[3] = _swapAttrArray[4].sub(_swapAttrArray[3]);

        if (_talentTotal >= 100) {
            _attrArray = _calcAttrInRange(_attrArray, 4);
        }
        _attrArray = _dealAttrExcludeZero(_attrArray, _talentTotal);
        _attrArray = shuffle(_attrArray);
        return _attrArray;
    }

    function _calcAttrInRange(uint256[] memory _array, uint256 _averageCalc) private view returns (uint256[] memory) {
        if (_array[_array.length - 1] > 100) {
            uint256 average = _array[_array.length - 1].div(_averageCalc);
            for (uint256 i = 0; i < _array.length; i++) {
                if (_array[i].add(average) <= 100) {
                    _array[i] = _array[i].add(average);
                    _array[_array.length - 1] = _array[_array.length - 1].sub(average);
                }
                _averageCalc++;
            }
            _calcAttrInRange(_array, _averageCalc);
        }
        return _array;
    }

    function _dealAttrExcludeZero(uint256[] memory _array, uint256 _talentTotal)
        private
        pure
        returns (uint256[] memory)
    {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i] == 0) {
                sortArray(_array);
                break;
            }
        }
        uint256 average = _talentTotal.div(4);
        if (_array[0] == 0 && _array[_array.length - 1].sub(average) > 0) {
            _array[0] = _array[0].add(average);
            _array[_array.length - 1] = _array[_array.length - 1].sub(average);
            _dealAttrExcludeZero(_array, _talentTotal);
        }
        return _array;
    }

    function sortArray(uint256[] memory _array) public pure returns (uint256[] memory) {
        for (uint256 i = 0; i < _array.length; i++) {
            for (uint256 j = i + 1; j < _array.length; j++) {
                if (_array[i] > _array[j]) {
                    uint256 temp = _array[i];
                    _array[i] = _array[j];
                    _array[j] = temp;
                }
            }
        }
        return _array;
    }

    function shuffle(uint256[] memory _array) public view returns (uint256[] memory) {
        uint256 timestamp = block.timestamp;
        for (uint256 i = 0; i < _array.length; i++) {
            uint256 n = i + (uint256(keccak256(abi.encodePacked(timestamp))) % (_array.length - i));
            uint256 temp = _array[n];
            _array[n] = _array[i];
            _array[i] = temp;
        }
        return _array;
    }

    function predict(uint256 _randomness, uint256 _index) public view override returns (uint256[] memory result) {
        uint256 expandedValue = uint256(keccak256(abi.encode(_randomness, _index)));
        result = new uint256[](7);
        (uint256 star, uint256 talentTotal) = _getStarAndTalentTotalByRandom(expandedValue);
        (uint256 alignment, uint256 name) = _getAlignmentAndName(star, expandedValue);
        uint256[] memory attrs = _getRandomCardAttr(expandedValue, talentTotal);
        result[0] = star;
        result[1] = alignment;
        result[2] = name;
        result[3] = attrs[0];
        result[4] = attrs[1];
        result[5] = attrs[2];
        result[6] = attrs[3];
    }

    function available() external pure override returns (uint256) {
        return _MAX_SUPPLY;
    }

    event SetPurchaseLimit(uint256 _limit);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract GenesisUniverseToken is ERC20 {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 1e9 * 1e18;

    constructor(
        address _playToEarnAddr,
        address _privateSaleAddr,
        address _teamAddr,
        address _stakingPoolAddr,
        address _marketingAddr,
        address _operationAddr
    ) ERC20("GenesisUniverseToken", "GUT") {
        _mint(_playToEarnAddr, MAX_SUPPLY.mul(50).div(100));
        _mint(_privateSaleAddr, MAX_SUPPLY.mul(15).div(100));
        _mint(_teamAddr, MAX_SUPPLY.mul(15).div(100));
        _mint(_stakingPoolAddr, MAX_SUPPLY.mul(10).div(100));
        _mint(_marketingAddr, MAX_SUPPLY.mul(5).div(100));
        _mint(_operationAddr, MAX_SUPPLY.mul(5).div(100));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title ERC721Mock
 * This mock just provides a public safeMint, mint, and burn functions for testing purposes
 */
contract ERC721Mock is ERC721 {
    constructor(string memory name, string memory symbol) public ERC721(name, symbol) {}

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory uri) public {
        _setTokenURI(tokenId, uri);
    }

    function setBaseURI(string memory baseURI) public {
        _setBaseURI(baseURI);
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        _safeMint(to, tokenId, _data);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}