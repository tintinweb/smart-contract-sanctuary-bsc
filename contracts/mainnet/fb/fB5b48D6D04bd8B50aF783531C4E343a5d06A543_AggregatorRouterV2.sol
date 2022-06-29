// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;
pragma experimental ABIEncoderV2;

import './libraries/SafeMath.sol';
import './libraries/EnumerableSet.sol';
import "./libraries/DisableFlags.sol";
import './modules/Initializable.sol';
import './modules/Configable.sol';
import './interfaces/IBurgerDexManager.sol';
import './interfaces/IBurgerAggregatorV2.sol';
import './interfaces/IDexProtocolV2.sol';

contract AggregatorRouterV2 is Configable, Initializable {
    using SafeMath for uint256;
    using DisableFlags for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IBurgerDexManager public dexManager;
    EnumerableSet.AddressSet private _connectors;

    function initialize() external initializer {
        owner = msg.sender;
        _connectors.add(address(0));
    }

    function configure(IBurgerDexManager _dexManager) external onlyDev {
        dexManager = _dexManager;
    }

    function connectors() public view returns (IERC20[] memory allConnectors) {
        allConnectors = new IERC20[](_connectors.length());
        for (uint256 i = 0; i < allConnectors.length; i++) {
            allConnectors[i] = IERC20(uint256(_connectors._inner._values[i]));
        }
    }

    function batchAddConnector(IERC20[] calldata connectors) external onlyDev {
        for (uint256 i = 0; i < connectors.length; i++) {
            addConnector(connectors[i]);
        }
    }

    function addConnector(IERC20 connector) public onlyDev {
        require(_connectors.add(address(connector)), 'Connector already added');
    }

    function removeConnector(IERC20 connector) external onlyDev {
        require(_connectors.remove(address(connector)), 'Unknown connector');
    }

    function getRoutesDistribution(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 flags
    ) external view returns (IERC20[][] memory routes, uint256[] memory distribution) {
        require(fromToken != destToken, 'Tokens should not be the same');

        uint256 dexsCount = dexManager.dexLength();
        Dex[] memory reserves = getAllReserves(flags, dexsCount);
        IERC20[] memory allConnectors = connectors();
        uint256[] memory routeLiquidity = new uint256[](_connectors.length());
        uint256 totalLiquidity;

        for (uint256 i = 0; i < allConnectors.length; i++) {
            for (uint256 j = 0; j < dexsCount; j++) {
                if (!reserves[j].skip) {
                    uint256 liquidity = IDexProtocolV2(reserves[j].protocal).getLiquidity(
                        reserves[j].dex,
                        fromToken,
                        destToken,
                        allConnectors[i]
                    );
                    routeLiquidity[i] = routeLiquidity[i].add(liquidity);
                    totalLiquidity = totalLiquidity.add(liquidity);
                }
            }
        }

        routes = new IERC20[][](_connectors.length());
        distribution = new uint256[](_connectors.length());
        for (uint256 i = 0; i < allConnectors.length; i++) {
            IERC20[] memory tmp = new IERC20[](3);
            tmp[0] = fromToken;
            tmp[1] = allConnectors[i];
            tmp[2] = destToken;
            routes[i] = tmp;
            distribution[i] = totalLiquidity != 0 ? routeLiquidity[i].mul(1e2).div(totalLiquidity) : 0;
        }

        return (routes, distribution);
    }

    function getRate(IERC20 fromToken, IERC20 destToken, uint256 flags) external view returns (uint256 weightedRate) {
        require(fromToken != destToken, 'Tokens should not be the same');
        uint256 totalWeight;
        uint256 dexsCount = dexManager.dexLength();
        Dex[] memory reserves = getAllReserves(flags, dexsCount);
        IERC20[] memory allConnectors = connectors();

        for (uint256 i = 0; i < allConnectors.length; i++) {
            for (uint256 j = 0; j < dexsCount; j++) {
                if (!reserves[j].skip) {
                    try
                        IDexProtocolV2(reserves[j].protocal).getRate(reserves[j].dex, fromToken, destToken, allConnectors[i])
                    returns (uint256 rate, uint256 weight) {
                        weightedRate = weightedRate.add(rate.mul(weight));
                        totalWeight = totalWeight.add(weight);
                    } catch {} // solhint-disable-line no-empty-blocks
                }
            }
        }
        if (totalWeight > 0) {
            weightedRate = weightedRate.div(totalWeight);
        }
    }

    struct Dex {
        address protocal;
        address dex;
        bool skip;
    }

    function getAllReserves(uint256 flags, uint dexsCount) public view returns (Dex[] memory reserves) {
        reserves = new Dex[](dexsCount);
        for (uint256 i = 0; i < dexsCount; i++) {
            (address protocol, address dex, uint256 disFlag,) = dexManager.dexs(i);
            if (flags.check(disFlag)) {
                reserves[i] = Dex({
                    protocal: address(0),
                    dex: address(0),
                    skip: true
                });
            } else {
               reserves[i] = Dex({
                    protocal: protocol,
                    dex: dex,
                    skip: false
                });
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
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
     *
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
        require(c / a == b, "SafeMath: multiplication overflow");

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <=0.6.12;

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
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
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
        return address(uint256(_at(set._inner, index)));
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
pragma solidity >=0.6.6 <=0.6.12;

library DisableFlags {
    function check(uint256 flags, uint256 flag) internal pure returns(bool) {
        return (flags & flag) != 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;

interface IConfig {
    function dev() external view returns (address);
    function admin() external view returns (address);
    function team() external view returns (address);
}

contract Configable {
    address public config;
    address public owner;

    event ConfigChanged(address indexed _user, address indexed _old, address indexed _new);
    event OwnerChanged(address indexed _user, address indexed _old, address indexed _new);
 
    function setupConfig(address _config) external onlyOwner {
        emit ConfigChanged(msg.sender, config, _config);
        config = _config;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'OWNER FORBIDDEN');
        _;
    }

    function admin() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).admin();
        }
        return owner;
    }

    function dev() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).dev();
        }
        return owner;
    }

    function team() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).team();
        }
        return owner;
    }

    function changeOwner(address _user) external onlyOwner {
        require(owner != _user, 'Owner: NO CHANGE');
        emit OwnerChanged(msg.sender, owner, _user);
        owner = _user;
    }
    
    modifier onlyDev() {
        require(msg.sender == dev() || msg.sender == owner, 'dev FORBIDDEN');
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin() || msg.sender == owner, 'admin FORBIDDEN');
        _;
    }
  
    modifier onlyManager() {
        require(msg.sender == dev() || msg.sender == admin() || msg.sender == owner, 'manager FORBIDDEN');
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;

import "./IERC20.sol";

interface IBurgerDexManager {
    function dexLength() external view returns (uint);
    function dexs(uint _pid) external view returns (address protocol, address dex, uint256 flag, string memory name);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;
pragma experimental ABIEncoderV2;

import './IBurgerDexManager.sol';

interface IBurgerAggregatorV2 {
    struct Dex {
        address protocol;
        address dex;
        bool skip;
    }

    struct Args {
        IERC20 fromToken;
        IERC20 destToken;
        uint256 amount;
        uint256 parts;
        uint256 flags;
        uint256 destTokenEthPriceTimesGasPrice;
        uint256[] distribution;
        int256[][] matrix;
        uint256[] gases;
        uint256 dexsCount;
        Dex[] reserves;
    }

    struct GetReturnMutilState {
        IERC20[]  tokens;
        uint256 amount;
        uint256[]  parts;
        uint256[]  flags;
        uint256[]  destTokenEthPriceTimesGasPrices;
        uint256[]  dist;
    }

    struct SwapState {
        Dex[] reserves;
        uint256 parts;
        uint256 lastNonZeroIndex;
        uint256 remainingAmount;
    }

    function getAllReserves(uint256 flags, uint dexsCount) external view returns (Dex[] memory reserves);

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) external returns (uint256 returnAmount, uint256[] memory distribution);

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    ) external returns (
        uint256 returnAmount,
        uint256 feeAmount,
        uint256 estimateGasAmount,
        uint256[] memory distribution
    );

    function getExpectedReturnWithGasMulti(
        IERC20[] calldata tokens,
        uint256 amount,
        uint256[] calldata parts,
        uint256[] calldata flags,
        uint256[] calldata destTokenEthPriceTimesGasPrices
    ) external returns (
        uint256[] memory returnAmounts,
        uint256 feeAmount,
        uint256 estimateGasAmount,
        uint256[] memory distribution
    );

    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags
    ) external payable returns (uint256 returnAmount);

    function swapMulti(
        IERC20[] calldata tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256[] calldata flags
    ) external payable returns (uint256 returnAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;

import './IERC20.sol';

interface IDexProtocolV2 {
    function getTokenPrice(
        address dexAddr,
        IERC20 fromToken,
        IERC20 destToken
    ) external view returns (uint256 price);

    function calculateOnDex(
        address dexAddr,
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] calldata amounts
    ) external returns (uint256[] memory rets, uint256 gas);

    function swapOnDex(
        address dexAddr,
        address fromToken,
        address destToken,
        uint256 amount,
        address to
    ) external payable;

    function getLiquidity(
        address dexAddr,
        IERC20 fromToken,
        IERC20 destToken,
        IERC20 connector
    ) external view returns (uint256 liquidity);

    function getRate(
        address dexAddr,
        IERC20 fromToken,
        IERC20 destToken,
        IERC20 connector
    ) external view returns (uint256 rate, uint256 weight);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}