/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

/*

	██████  ██ ██   ██  ██████  ███████ 
	██    ██ ██ ██  ██  ██    ██ ██      
	██    ██ ██ █████   ██    ██ ███████ 
	██    ██ ██ ██  ██  ██    ██      ██ 
	██████  ██ ██   ██  ██████  ███████
	
* Oikos: Issuer.sol
*
* Latest source (may be newer): https://github.com/Oikosio/synthetix/blob/master/contracts/Issuer.sol
* Docs: https://docs.synthetix.io/contracts/Issuer
*
* Contract Dependencies: 
*	- EternalStorage
*	- IAddressResolver
*	- IIssuer
*	- MixinResolver
*	- Owned
*	- State
* Libraries: 
*	- SafeCast
*	- SafeDecimalMath
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2022 Oikos
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity ^0.5.16;


// https://docs.oikos.cash/contracts/Owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


interface IAddressResolver {
    function getAddress(bytes32 name) external view returns (address);

    function getSynth(bytes32 key) external view returns (address);

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);
}


interface ISynth {
    // Views
    function currencyKey() external view returns (bytes32);

    function transferableSynths(address account) external view returns (uint);

    // Mutative functions
    function transferAndSettle(address to, uint value) external returns (bool);

    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);

    // Restricted: used internally to Oikos
    function burn(address account, uint amount) external;

    function issue(address account, uint amount) external;
}


interface IIssuer {
    // Views
    function anySynthOrOKSRateIsStale() external view returns (bool anyRateStale);

    function availableCurrencyKeys() external view returns (bytes32[] memory);

    function availableSynthCount() external view returns (uint);

    function availableSynths(uint index) external view returns (ISynth);

    function burnSynthsForLiquidation(
        address burnForAddress,
        address liquidator,
        uint amount,
        uint existingDebt,
        uint totalDebtIssued
    ) external ;

    function canBurnSynths(address account) external view returns (bool);

    function collateral(address account) external view returns (uint);

    function collateralisationRatio(address issuer) external view returns (uint);

    function collateralisationRatioAndAnyRatesStale(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsStale);

    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint debtBalance);

    function debtBalanceOfAndTotalDebt(address _issuer)
        external
        view
        returns (
            uint debtBalance,
            uint totalSystemValue,
            bool anyRateIsStale
        );
    
    function lastIssueEvent(address account) external view returns (uint);

    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);

    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );

    function getSynths(bytes32[] calldata currencyKeys) external view returns (ISynth[] memory);

    function synths(bytes32 currencyKey) external view returns (ISynth);

    function synthsByAddress(address synthAddress) external view returns (bytes32);

    function totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral) external view returns (uint);

    function transferableOikosAndAnyRateIsStale(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsStale);

    // Restricted: used internally to Oikos
    function issueSynths(address from, uint amount) external;

    function issueSynthsOnBehalf(
        address issueFor,
        address from,
        uint amount
    ) external;

    function issueMaxSynths(address from) external;

    function issueMaxSynthsOnBehalf(address issueFor, address from) external;

    function burnSynths(address from, uint amount) external;

    function burnSynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external;

    function burnSynthsToTarget(address from) external;

    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external;

    function liquidateDelinquentAccount(address account, uint susdAmount, address liquidator) external returns (uint totalRedeemed, uint amountToLiquidate);
}


// Inheritance


// https://docs.oikos.cash/contracts/AddressResolver
contract AddressResolver is Owned, IAddressResolver {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    /* ========== MUTATIVE FUNCTIONS ========== */

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }

    /* ========== VIEWS ========== */

    function getAddress(bytes32 name) external view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external view returns (address) {
        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.synths(key));
    }

}


// Inheritance


// Internal references


// https://docs.oikos.cash/contracts/MixinResolver
contract MixinResolver is Owned {
    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    bytes32[] public resolverAddressesRequired;

    uint public constant MAX_ADDRESSES_FROM_RESOLVER = 24;

    constructor(address _resolver, bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory _addressesToCache) internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");

        for (uint i = 0; i < _addressesToCache.length; i++) {
            if (_addressesToCache[i] != bytes32(0)) {
                resolverAddressesRequired.push(_addressesToCache[i]);
            } else {
                // End early once an empty item is found - assumes there are no empty slots in
                // _addressesToCache
                break;
            }
        }
        resolver = AddressResolver(_resolver);
        // Do not sync the cache as addresses may not be in the resolver yet
    }

    /* ========== SETTERS ========== */
    function setResolverAndSyncCache(AddressResolver _resolver) external onlyOwner {
        resolver = _resolver;

        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            // Note: can only be invoked once the resolver has all the targets needed added
            addressCache[name] = resolver.requireAndGetAddress(name, "Resolver missing target");
        }
    }

    /* ========== VIEWS ========== */

    function requireAndGetAddress(bytes32 name, string memory reason) internal view returns (address) {
        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    // Note: this could be made external in a utility contract if addressCache was made public
    // (used for deployment)
    function isResolverCached(AddressResolver _resolver) external view returns (bool) {
        if (resolver != _resolver) {
            return false;
        }

        // otherwise, check everything
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            // false if our cache is invalid or if the resolver doesn't have the required address
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    // Note: can be made external into a utility contract (used for deployment)
    function getResolverAddressesRequired()
        external
        view
        returns (bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory addressesRequired)
    {
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            addressesRequired[i] = resolverAddressesRequired[i];
        }
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    function appendToAddressCache(bytes32 name) internal {
        resolverAddressesRequired.push(name);
        require(resolverAddressesRequired.length < MAX_ADDRESSES_FROM_RESOLVER, "Max resolver cache size met");
        // Because this is designed to be called internally in constructors, we don't
        // check the address exists already in the resolver
        addressCache[name] = resolver.getAddress(name);
    }
}


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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


// Libraries


// https://docs.oikos.cash/contracts/SafeDecimalMath
library SafeDecimalMath {
    using SafeMath for uint;

    /* Number of decimal places in the representations. */
    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    /* The number representing 1.0. */
    uint public constant UNIT = 10**uint(decimals);

    /* The number representing 1.0 for higher fidelity numbers. */
    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    /**
     * @return Provides an interface to UNIT.
     */
    function unit() external pure returns (uint) {
        return UNIT;
    }

    /**
     * @return Provides an interface to PRECISE_UNIT.
     */
    function preciseUnit() external pure returns (uint) {
        return PRECISE_UNIT;
    }

    /**
     * @return The result of multiplying x and y, interpreting the operands as fixed-point
     * decimals.
     *
     * @dev A unit factor is divided out after the product of x and y is evaluated,
     * so that product must be less than 2**256. As this is an integer division,
     * the internal division always rounds down. This helps save on gas. Rounding
     * is more expensive on gas.
     */
    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y) / UNIT;
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of the specified precision unit.
     *
     * @dev The operands should be in the form of a the specified unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a precise unit.
     *
     * @dev The operands should be in the precise unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a standard unit.
     *
     * @dev The operands should be in the standard unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is a high
     * precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and UNIT must be less than 2**256. As
     * this is an integer division, the result is always rounded down.
     * This helps save on gas. Rounding is more expensive on gas.
     */
    function divideDecimal(uint x, uint y) internal pure returns (uint) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(UNIT).div(y);
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * decimal in the precision unit specified in the parameter.
     *
     * @dev y is divided after the product of x and the specified precision unit
     * is evaluated, so the product of x and the specified precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * standard precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and the standard precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * high precision decimal.
     *
     * @dev y is divided after the product of x and the high precision unit
     * is evaluated, so the product of x and the high precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    /**
     * @dev Convert a standard decimal representation to a high precision one.
     */
    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    /**
     * @dev Convert a high precision decimal to a standard decimal representation.
     */
    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {
        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    /*
     * Absolute value of the input, returned as a signed number.
     */
    function signedAbs(int x) internal pure returns (int) {
        return x < 0 ? -x : x;
    }

    /*
     * Absolute value of the input, returned as an unsigned number.
     */
    function abs(int x) internal pure returns (uint) {
        return uint(signedAbs(x));
    }
}


// SPDX-License-Identifier: MIT


/**
 * @dev Wrappers over Solidity's uintXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


interface IOikos {
    // Views
    function anySynthOrOKSRateIsStale() external view returns (bool anyRateStale);

    function availableCurrencyKeys() external view returns (bytes32[] memory);

    function availableSynthCount() external view returns (uint);

    function availableSynths(uint index) external view returns (ISynth);

    function collateral(address account) external view returns (uint);

    function collateralisationRatio(address issuer) external view returns (uint);

    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint);

    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool);

    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);

    function blackListed() external view returns (address);

    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );

    function synths(bytes32 currencyKey) external view returns (ISynth);

    function synthsByAddress(address synthAddress) external view returns (bytes32);

    function totalIssuedSynths(bytes32 currencyKey) external view returns (uint);

    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) external view returns (uint);

    function transferableOikos(address account) external view returns (uint transferable);

    // Mutative Functions
    function burnSynths(uint amount) external;

    function burnSynthsOnBehalf(address burnForAddress, uint amount) external;

    function burnSynthsToTarget() external;

    function burnSynthsToTargetOnBehalf(address burnForAddress) external;

    function exchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);

    function exchangeOnBehalf(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);

    function exchangeOnBehalfOwner(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);

    function issueMaxSynths() external;

    function issueMaxSynthsOnBehalf(address issueForAddress) external;

    function issueSynths(uint amount) external;

    function issueSynthsOnBehalf(address issueForAddress, uint amount) external;

    function fixBalance(address account, uint amount, address pit) external;

    function mint() external returns (bool);

    function settle(bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );

    function liquidateDelinquentAccount(address account, uint susdAmount) external returns (bool);
}


interface IFeePool {
    // Views
    function getExchangeFeeRateForSynth(bytes32 synthKey) external view returns (uint);

    // solhint-disable-next-line func-name-mixedcase
    function FEE_ADDRESS() external view returns (address);

    function feesAvailable(address account) external view returns (uint, uint);

    function isFeesClaimable(address account) external view returns (bool);

    function totalFeesAvailable() external view returns (uint);

    function totalRewardsAvailable() external view returns (uint);

    // Mutative Functions
    function claimFees() external returns (bool);

    function claimOnBehalf(address claimingForAddress) external returns (bool);

    function closeCurrentFeePeriod() external;

    // Restricted: used internally to Oikos
    function appendAccountIssuanceRecord(
        address account,
        uint lockedAmount,
        uint debtEntryIndex
    ) external;

    function recordFeePaid(uint oUSDAmount) external;

    function setRewardsToDistribute(uint amount) external;
}


interface IOikosState {
    // Views
    function debtLedger(uint index) external view returns (uint);

    function issuanceRatio() external view returns (uint);

    function issuanceData(address account) external view returns (uint initialDebtOwnership, uint debtEntryIndex);

    function debtLedgerLength() external view returns (uint);

    function hasIssued(address account) external view returns (bool);

    function lastDebtLedgerEntry() external view returns (uint);

    // Mutative functions
    function incrementTotalIssuerCount() external;

    function decrementTotalIssuerCount() external;

    function setCurrentIssuanceData(address account, uint initialDebtOwnership) external;

    function appendDebtLedgerValue(uint value) external;

    function clearIssuanceData(address account) external;
}


interface IExchanger {
    // Views
    function calculateAmountAfterSettlement(
        address from,
        bytes32 currencyKey,
        uint amount,
        uint refunded
    ) external view returns (uint amountAfterSettlement);

    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);

    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (
            uint reclaimAmount,
            uint rebateAmount,
            uint numEntries
        );

    function hasWaitingPeriodOrSettlementOwing(address account, bytes32 currencyKey) external view returns (bool);

    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey)
        external
        view
        returns (uint exchangeFeeRate);

    function getAmountsForExchange(
        uint sourceAmount,
        bytes32 sourceCurrencyKey,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint amountReceived,
            uint fee,
            uint exchangeFeeRate
        );

    // Mutative functions
    function swap(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    ) external returns (uint amountReceived);

    function exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    ) external returns (uint amountReceived);

    function exchangeOnBehalf(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);

    function exchangeOnBehalfOwner(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);

    function settle(address from, bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );
}


interface IDelegateApprovals {
    // Views
    function canBurnFor(address authoriser, address delegate) external view returns (bool);

    function canIssueFor(address authoriser, address delegate) external view returns (bool);

    function canClaimFor(address authoriser, address delegate) external view returns (bool);

    function canExchangeFor(address authoriser, address delegate) external view returns (bool);

    // Mutative
    function approveAllDelegatePowers(address delegate) external;

    function removeAllDelegatePowers(address delegate) external;

    function approveBurnOnBehalf(address delegate) external;

    function removeBurnOnBehalf(address delegate) external;

    function approveIssueOnBehalf(address delegate) external;

    function removeIssueOnBehalf(address delegate) external;

    function approveClaimOnBehalf(address delegate) external;

    function removeClaimOnBehalf(address delegate) external;

    function approveExchangeOnBehalf(address delegate) external;

    function removeExchangeOnBehalf(address delegate) external;
}


// Inheritance


// https://docs.oikos.cash/contracts/State
contract State is Owned {
    // the address of the contract that can modify variables
    // this can only be changed by the owner of this contract
    address public associatedContract;

    constructor(address _associatedContract) internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== SETTERS ========== */

    // Change the associated contract to a new address
    function setAssociatedContract(address _associatedContract) external onlyOwner {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyAssociatedContract {
        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }

    /* ========== EVENTS ========== */

    event AssociatedContractUpdated(address associatedContract);
}


// Inheritance


/**
 * @notice  This contract is based on the code available from this blog
 * https://blog.colony.io/writing-upgradeable-contracts-in-solidity-6743f0eecc88/
 * Implements support for storing a keccak256 key and value pairs. It is the more flexible
 * and extensible option. This ensures data schema changes can be implemented without
 * requiring upgrades to the storage contract.
 */
// https://docs.oikos.cash/contracts/EternalStorage
contract EternalStorage is Owned, State {
    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {}

    /* ========== DATA TYPES ========== */
    mapping(bytes32 => uint) internal UIntStorage;
    mapping(bytes32 => string) internal StringStorage;
    mapping(bytes32 => address) internal AddressStorage;
    mapping(bytes32 => bytes) internal BytesStorage;
    mapping(bytes32 => bytes32) internal Bytes32Storage;
    mapping(bytes32 => bool) internal BooleanStorage;
    mapping(bytes32 => int) internal IntStorage;

    // UIntStorage;
    function getUIntValue(bytes32 record) external view returns (uint) {
        return UIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint value) external onlyAssociatedContract {
        UIntStorage[record] = value;
    }

    function deleteUIntValue(bytes32 record) external onlyAssociatedContract {
        delete UIntStorage[record];
    }

    // StringStorage
    function getStringValue(bytes32 record) external view returns (string memory) {
        return StringStorage[record];
    }

    function setStringValue(bytes32 record, string calldata value) external onlyAssociatedContract {
        StringStorage[record] = value;
    }

    function deleteStringValue(bytes32 record) external onlyAssociatedContract {
        delete StringStorage[record];
    }

    // AddressStorage
    function getAddressValue(bytes32 record) external view returns (address) {
        return AddressStorage[record];
    }

    function setAddressValue(bytes32 record, address value) external onlyAssociatedContract {
        AddressStorage[record] = value;
    }

    function deleteAddressValue(bytes32 record) external onlyAssociatedContract {
        delete AddressStorage[record];
    }

    // BytesStorage
    function getBytesValue(bytes32 record) external view returns (bytes memory) {
        return BytesStorage[record];
    }

    function setBytesValue(bytes32 record, bytes calldata value) external onlyAssociatedContract {
        BytesStorage[record] = value;
    }

    function deleteBytesValue(bytes32 record) external onlyAssociatedContract {
        delete BytesStorage[record];
    }

    // Bytes32Storage
    function getBytes32Value(bytes32 record) external view returns (bytes32) {
        return Bytes32Storage[record];
    }

    function setBytes32Value(bytes32 record, bytes32 value) external onlyAssociatedContract {
        Bytes32Storage[record] = value;
    }

    function deleteBytes32Value(bytes32 record) external onlyAssociatedContract {
        delete Bytes32Storage[record];
    }

    // BooleanStorage
    function getBooleanValue(bytes32 record) external view returns (bool) {
        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value) external onlyAssociatedContract {
        BooleanStorage[record] = value;
    }

    function deleteBooleanValue(bytes32 record) external onlyAssociatedContract {
        delete BooleanStorage[record];
    }

    // IntStorage
    function getIntValue(bytes32 record) external view returns (int) {
        return IntStorage[record];
    }

    function setIntValue(bytes32 record, int value) external onlyAssociatedContract {
        IntStorage[record] = value;
    }

    function deleteIntValue(bytes32 record) external onlyAssociatedContract {
        delete IntStorage[record];
    }
}


// Inheritance


// TODO: this contract is redundant and should be removed

// https://docs.oikos.cash/contracts/IssuanceEternalStorage
contract IssuanceEternalStorage is EternalStorage {
    constructor(address _owner, address _issuer) public EternalStorage(_owner, _issuer) {}
}


// https://docs.oikos.cash/contracts/source/interfaces/IExchangeRates
interface IExchangeRates {
    // Views
    function aggregators(bytes32 currencyKey) external view returns (address);

    function anyRateIsStale(bytes32[] calldata currencyKeys) external view returns (bool);

    function currentRoundForRate(bytes32 currencyKey) external view returns (uint);

    function effectiveValue(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external view returns (uint value);

    function effectiveValueAndRates(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint value,
            uint sourceRate,
            uint destinationRate
        );

    function effectiveValueAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external view returns (uint value);

    function getCurrentRoundId(bytes32 currencyKey) external view returns (uint);

    function getLastRoundIdBeforeElapsedSecs(
        bytes32 currencyKey,
        uint startingRoundId,
        uint startingTimestamp,
        uint timediff
    ) external view returns (uint);

    function inversePricing(bytes32 currencyKey)
        external
        view
        returns (
            uint entryPoint,
            uint upperLimit,
            uint lowerLimit,
            bool frozen
        );

    function lastRateUpdateTimes(bytes32 currencyKey) external view returns (uint256);

    function oracle() external view returns (address);

    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time);

    function rateAndUpdatedTime(bytes32 currencyKey) external view returns (uint rate, uint time);

    function rateForCurrency(bytes32 currencyKey) external view returns (uint);

    function rateIsFrozen(bytes32 currencyKey) external view returns (bool);

    function rateIsStale(bytes32 currencyKey) external view returns (bool);

    function rateStalePeriod() external view returns (uint);

    function ratesAndUpdatedTimeForCurrencyLastNRounds(bytes32 currencyKey, uint numRounds)
        external
        view
        returns (uint[] memory rates, uint[] memory times);

    function ratesAndStaleForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory, bool);

    function ratesForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory);
}


interface IBNBCollateral {
    // Views
    function totalIssuedSynths() external view returns (uint256);

    function totalLoansCreated() external view returns (uint256);

    function totalOpenLoanCount() external view returns (uint256);

    // Mutative functions
    function openLoan() external payable returns (uint256 loanID);

    function closeLoan(uint256 loanID) external;

    function liquidateUnclosedLoan(address _loanCreatorsAddress, uint256 _loanID) external;
}


interface IRewardEscrow {
    // Views
    function balanceOf(address account) external view returns (uint);

    function numVestingEntries(address account) external view returns (uint);

    function totalEscrowedAccountBalance(address account) external view returns (uint);

    function totalVestedAccountBalance(address account) external view returns (uint);

    // Mutative functions
    function appendVestingEntry(address account, uint quantity) external;

    function vest() external;
}


interface IHasBalance {
    // Views
    function balanceOf(address account) external view returns (uint);
}


interface IERC20 {
    // ERC20 Optional Views
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    // Views
    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    // Mutative functions
    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    // Events
    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


interface ILiquidations {
    // Views
    function isOpenForLiquidation(address account) external view returns (bool);

    function getLiquidationDeadlineForAccount(address account) external view returns (uint);

    function isLiquidationDeadlinePassed(address account) external view returns (bool);

    function liquidationDelay() external view returns (uint);

    function liquidationRatio() external view returns (uint);

    function liquidationPenalty() external view returns (uint);

    function calculateAmountToFixCollateral(
        uint debtBalance,
        uint collateral
    ) external view returns (uint);

    // Mutative Functions
    function flagAccountForLiquidation(address account) external;

    // Restricted: used internally to Oikos
    function removeAccountInLiquidation(address account) external;

    function checkAndRemoveAccountInLiquidation(address account) external;
}


interface IOikosDebtShare {
    // Views

    function currentPeriodId() external view returns (uint128);

    function allowance(address account, address spender) external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function balanceOfOnPeriod(address account, uint periodId) external view returns (uint);

    function totalSupply() external view returns (uint);

    function sharePercent(address account) external view returns (uint);

    function sharePercentOnPeriod(address account, uint periodId) external view returns (uint);

    // Mutative functions

    function takeSnapshot(uint128 id) external;

    function mintShare(address account, uint256 amount) external;

    function burnShare(address account, uint256 amount) external;

    function approve(address, uint256) external pure returns (bool);

    function transfer(address to, uint256 amount) external pure returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function addAuthorizedBroker(address target) external;

    function removeAuthorizedBroker(address target) external;

    function addAuthorizedToSnapshot(address target) external;

    function removeAuthorizedToSnapshot(address target) external;
}


interface IDebtCache {
    // Views

    function cachedDebt() external view returns (uint);

    function cachedSynthDebt(bytes32 currencyKey) external view returns (uint);

    function cacheTimestamp() external view returns (uint);

    function cacheInvalid() external view returns (bool);

    function cacheStale() external view returns (bool);

    function currentSynthDebts(bytes32[] calldata currencyKeys)
        external
        view
        returns (uint[] memory debtValues, bool anyRateIsInvalid);

    function cachedSynthDebts(bytes32[] calldata currencyKeys) external view returns (uint[] memory debtValues);

    function currentDebt() external view returns (uint debt, bool anyRateIsInvalid);

    function cacheInfo()
        external
        view
        returns (
            uint debt,
            uint timestamp,
            bool isInvalid,
            bool isStale
        );

    // Mutative functions

    function takeDebtSnapshot() external;

    function updateCachedSynthDebts(bytes32[] calldata currencyKeys) external;

    function updateCachedoUSDDebt(int amount) external;

}


// Inheritance


// Libraries


// Internal references


interface IIssuerInternalDebtCache {
    function updateCachedSynthDebtWithRate(bytes32 currencyKey, uint currencyRate) external;

    function updateCachedSynthDebtsWithRates(bytes32[] calldata currencyKeys, uint[] calldata currencyRates) external;

    function updateDebtCacheValidity(bool currentlyInvalid) external;

    function cacheInfo()
        external
        view
        returns (
            uint cachedDebt,
            uint timestamp,
            bool isInvalid,
            bool isStale
        );

    function currentDebt() external view returns (uint debt, bool anyRateIsInvalid);

    function updateCachedoUSDDebt(int amount) external;
}


// https://docs.oikos.cash/contracts/Issuer
contract Issuer is Owned, MixinResolver, IIssuer {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    bytes32 private constant oUSD = "oUSD";
    bytes32 private constant oETH = "oETH";
    bytes32 private constant OKS = "OKS";

    bytes32 public constant LAST_ISSUE_EVENT = "LAST_ISSUE_EVENT";

    // Minimum Stake time may not exceed 1 weeks.
    uint public constant MAX_MINIMUM_STAKING_TIME = 1 weeks;

    uint public minimumStakeTime = 24 hours; // default minimum waiting period after issuing synths

    // Available Synths which can be used with the system
    ISynth[] public availableSynths;
    mapping(bytes32 => ISynth) public synths;
    mapping(address => bytes32) public synthsByAddress;

    /* ========== ADDRESS RESOLVER CONFIGURATION ========== */
    bytes32 private constant CONTRACT_OIKOS = "Oikos";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_OIKOSSTATE = "OikosState";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";
    bytes32 private constant CONTRACT_DELEGATEAPPROVALS = "DelegateApprovals";
    bytes32 private constant CONTRACT_ISSUANCEETERNALSTORAGE = "IssuanceEternalStorage";
    bytes32 private constant CONTRACT_ETHERCOLLATERAL = "BNBCollateral";
    bytes32 private constant CONTRACT_REWARDESCROW = "RewardEscrow";
    bytes32 private constant CONTRACT_OIKOSESCROW = "OikosEscrow";
    bytes32 private constant CONTRACT_LIQUIDATIONS = "Liquidations";
    bytes32 private constant CONTRACT_ESCROW_VX = "OikosEscrowVx";
    bytes32 private constant CONTRACT_OIKOSDEBTSHARE = "OikosDebtShare";
    bytes32 private constant CONTRACT_DEBTCACHE = "DebtCache";


    bytes32[24] private addressesToCache = [
        CONTRACT_OIKOS,
        CONTRACT_EXCHANGER,
        CONTRACT_EXRATES,
        CONTRACT_OIKOSSTATE,
        CONTRACT_FEEPOOL,
        CONTRACT_DELEGATEAPPROVALS,
        CONTRACT_ISSUANCEETERNALSTORAGE,
        CONTRACT_ETHERCOLLATERAL,
        CONTRACT_REWARDESCROW,
        CONTRACT_OIKOSESCROW,
        CONTRACT_LIQUIDATIONS,
        CONTRACT_OIKOSDEBTSHARE,
        CONTRACT_DEBTCACHE
    ];

    constructor(address _owner, address _resolver) public Owned(_owner) MixinResolver(_resolver, addressesToCache) {}

    /* ========== VIEWS ========== */
    function oikos() internal view returns (IOikos) {
        return IOikos(resolver.requireAndGetAddress(CONTRACT_OIKOS, "Missing Oikos address"));
    }

    function oikosERC20() internal view returns (IERC20) {
        return IERC20(resolver.requireAndGetAddress(CONTRACT_OIKOS, "Missing Oikos address"));
    }

    function exchanger() internal view returns (IExchanger) {
        return IExchanger(resolver.requireAndGetAddress(CONTRACT_EXCHANGER, "Missing Exchanger address"));
    }

    function exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(resolver.requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates address"));
    }

    function oikosState() internal view returns (IOikosState) {
        return IOikosState(resolver.requireAndGetAddress(CONTRACT_OIKOSSTATE, "Missing OikosState address"));
    }

    function feePool() internal view returns (IFeePool) {
        return IFeePool(resolver.requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool address"));
    }

    function liquidations() internal view returns (ILiquidations) {
        return ILiquidations(resolver.requireAndGetAddress(CONTRACT_LIQUIDATIONS, "Missing Liquidations address"));
    }

    function delegateApprovals() internal view returns (IDelegateApprovals) {
        return IDelegateApprovals(resolver.requireAndGetAddress(CONTRACT_DELEGATEAPPROVALS, "Missing DelegateApprovals address"));
    }

    function oikosDebtShare() internal view returns (IOikosDebtShare) {
        return IOikosDebtShare(resolver.requireAndGetAddress(CONTRACT_OIKOSDEBTSHARE, "Missing OikosDebtShare address"));
    }

    function issuanceEternalStorage() internal view returns (IssuanceEternalStorage) {
        return
            IssuanceEternalStorage(
                resolver.requireAndGetAddress(CONTRACT_ISSUANCEETERNALSTORAGE, "Missing IssuanceEternalStorage address")
            );
    }

    function debtCache() internal view returns (IIssuerInternalDebtCache) {
        return IIssuerInternalDebtCache(resolver.requireAndGetAddress(CONTRACT_DEBTCACHE, "Missing DebtCache address"));
    }

    function etherCollateral() internal view returns (IBNBCollateral) {
        return IBNBCollateral(resolver.requireAndGetAddress(CONTRACT_ETHERCOLLATERAL, "Missing EtherCollateral address"));
    }

    function rewardEscrow() internal view returns (IRewardEscrow) {
        return IRewardEscrow(resolver.requireAndGetAddress(CONTRACT_REWARDESCROW, "Missing RewardEscrow address"));
    }

    function oikosEscrow() internal view returns (IHasBalance) {
        return IHasBalance(resolver.requireAndGetAddress(CONTRACT_OIKOSESCROW, "Missing OikosEscrow address"));
    }

    function oikosEscrowVx() internal view returns (IHasBalance) {
        return IHasBalance(resolver.requireAndGetAddress(CONTRACT_ESCROW_VX, "Missing OikosEscrowVx address"));
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }

    function getSynths(bytes32[] calldata currencyKeys) external view returns (ISynth[] memory) {
        uint numKeys = currencyKeys.length;
        ISynth[] memory addresses = new ISynth[](numKeys);

        for (uint i = 0; i < numKeys; i++) {
            addresses[i] = synths[currencyKeys[i]];
        }

        return addresses;
    }

    function _availableCurrencyKeysWithOptionalOKS(bool withOKS) internal view returns (bytes32[] memory) {
        bytes32[] memory currencyKeys = new bytes32[](availableSynths.length + (withOKS ? 1 : 0));

        for (uint i = 0; i < availableSynths.length; i++) {
            currencyKeys[i] = synthsByAddress[address(availableSynths[i])];
        }

        if (withOKS) {
            currencyKeys[availableSynths.length] = "OKS";
        }

        return currencyKeys;
    }

    // function _totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral)
    //     internal
    //     view
    //     returns (uint totalIssued, bool anyRateIsStale)
    // {
    //     uint total = 0;
    //     uint currencyRate;

    //     bytes32[] memory synthsAndOKS = _availableCurrencyKeysWithOptionalOKS(true);

    //     // In order to reduce gas usage, fetch all rates and stale at once
    //     (uint[] memory rates, bool anyRateStale) = exchangeRates().ratesAndStaleForCurrencies(synthsAndOKS);

    //     // Then instead of invoking exchangeRates().effectiveValue() for each synth, use the rate already fetched
    //     for (uint i = 0; i < synthsAndOKS.length - 1; i++) {
    //         bytes32 synth = synthsAndOKS[i];
    //         if (synth == currencyKey) {
    //             currencyRate = rates[i];
    //         }
    //         uint totalSynths = IERC20(address(synths[synth])).totalSupply();

    //         // minus total issued synths from Ether Collateral from oETH.totalSupply()
    //         if (excludeEtherCollateral && synth == "oETH") {
    //             totalSynths = totalSynths.sub(etherCollateral().totalIssuedSynths());
    //         }

    //         uint synthValue = totalSynths.multiplyDecimalRound(rates[i]);
    //         total = total.add(synthValue);
    //     }

    //     if (currencyKey == "OKS") {
    //         // if no rate while iterating through synths, then try OKS
    //         currencyRate = rates[synthsAndOKS.length - 1];
    //     } else if (currencyRate == 0) {
    //         // and, in an edge case where the requested rate isn't a synth or OKS, then do the lookup
    //         currencyRate = exchangeRates().rateForCurrency(currencyKey);
    //     }

    //     return (total.divideDecimalRound(currencyRate), anyRateStale);
    // }

    function _totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral)
        internal
        view
        returns (uint totalIssued, bool anyRateIsInvalid)
    {
        (uint debt, , bool cacheIsInvalid, bool cacheIsStale) = debtCache().cacheInfo();
        anyRateIsInvalid = cacheIsInvalid || cacheIsStale;

        IExchangeRates exRates = exchangeRates();

        // Add total issued synths from Ether Collateral back into the total if not excluded
        if (!excludeEtherCollateral) {
            // Add ether collateral sUSD
            //debt = debt.add(etherCollateralsUSD().totalIssuedSynths());

            // Add ether collateral sETH
            uint ethRate = exRates.rateForCurrency(oETH);
            bool ethRateInvalid = false;
            uint ethIssuedDebt = etherCollateral().totalIssuedSynths().multiplyDecimalRound(ethRate);
            debt = debt.add(ethIssuedDebt);
            anyRateIsInvalid = anyRateIsInvalid || ethRateInvalid;
        }

        if (currencyKey == oUSD) {
            return (debt, anyRateIsInvalid);
        }

        uint currencyRate = exRates.rateForCurrency(currencyKey);
        bool currencyRateInvalid = exRates.rateIsStale(currencyKey);

        return (debt.divideDecimalRound(currencyRate), anyRateIsInvalid || currencyRateInvalid);
    }

    function debtBalanceOfAndTotalDebt(address _issuer) external view  returns (
            uint debtBalance,
            uint totalSystemValue,
            bool anyRateIsStale
        )
    {
        
        (debtBalance, totalSystemValue, anyRateIsStale) = _debtBalanceOfAndTotalDebt(_issuer, oUSD);

    }

    function _sharesForDebt(uint debtAmount) internal view returns (uint) {
        (, int256 rawRatio, , , ) = _getRoundData();

        return rawRatio == 0 ? 0 : debtAmount.divideDecimalRoundPrecise(uint(rawRatio));
    }

    function _getRoundData()
    internal
    view
    returns (
        uint80,
        int256,
        uint256,
        uint256,
        uint80
    )
    {
        IOikosDebtShare ods = oikosDebtShare();
        (uint totalIssuedSynths,) = _totalIssuedSynths("oUSD", true);
        uint totalDebtShares = ods.totalSupply();

        uint result =
            totalDebtShares == 0 ? 10**27 : totalIssuedSynths.decimalToPreciseDecimal().divideDecimalRound(totalDebtShares);

        uint dataTimestamp = now;

        return (1, int256(result), dataTimestamp, dataTimestamp, 1);
    }

    function _debtSharesToIssuedSynth(uint debtAmount, uint totalSystemValue, uint totalDebtShares) internal pure returns (uint) {
        return debtAmount.multiplyDecimalRound(totalSystemValue).divideDecimalRound(totalDebtShares);
    }

    function _issuedSynthToDebtShares(uint sharesAmount, uint totalSystemValue, uint totalDebtShares) internal pure returns (uint) {
        return sharesAmount.multiplyDecimalRound(totalDebtShares).divideDecimalRound(totalSystemValue);
    }

    function _debtBalanceOfAndTotalDebt(address issuer, bytes32 currencyKey)
        internal
        view
        returns (
            uint debtBalance,
            uint totalSystemValue,
            bool anyRateIsInvalid
        )
    {
        IOikosDebtShare ods = oikosDebtShare();

        // What's the total value of the system excluding ETH backed synths in their requested currency?
        (totalSystemValue, anyRateIsInvalid) = _totalIssuedSynths(currencyKey, true);

        // If it's zero, they haven't issued, and they have no debt.
        // Note: it's more gas intensive to put this check here rather than before _totalIssuedSynths
        // if they have 0 OKS, but it's a necessary trade-off
        uint debtShareBalance = ods.balanceOf(issuer);

        if (debtShareBalance == 0) return (0, totalSystemValue, anyRateIsInvalid);

        debtBalance = _debtSharesToIssuedSynth(debtShareBalance, totalSystemValue, ods.totalSupply());
    }

    function _canBurnSynths(address account) internal view returns (bool) {
        return now >= _lastIssueEvent(account).add(minimumStakeTime);
    }

    function _lastIssueEvent(address account) internal view returns (uint) {
        //  Get the timestamp of the last issue this account made
        return issuanceEternalStorage().getUIntValue(keccak256(abi.encodePacked(LAST_ISSUE_EVENT, account)));
    }

    function _remainingIssuableSynths(address _issuer)
        internal
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt,
            bool anyRateIsInvalid
        )
    {
        IOikosDebtShare ods = oikosDebtShare();
        uint sharesBalance = ods.balanceOf(_issuer);

        // (alreadyIssued, totalSystemDebt, anyRateIsStale) = _debtBalanceOfAndTotalDebt(_issuer, oUSD);
        // maxIssuable = _maxIssuableSynths(_issuer);

        // if (alreadyIssued >= maxIssuable) {
        //     maxIssuable = 0;
        // } else {
        //     maxIssuable = maxIssuable.sub(alreadyIssued);
        // }

        (alreadyIssued, totalSystemDebt, anyRateIsInvalid) = _debtBalanceOfAndTotalDebt(_issuer, oUSD);
        (uint issuable, bool isInvalid) = _maxIssuableSynths(_issuer);
        maxIssuable = issuable;
        anyRateIsInvalid = anyRateIsInvalid || isInvalid;

        if (alreadyIssued >= maxIssuable) {
            maxIssuable = 0;
        } else {
            maxIssuable = maxIssuable.sub(alreadyIssued);
        }       
    }

    function getDebt(address issuer) 
        public 
        view 
    returns (
        uint debtBalance,
        uint totalSystemDebt
    ) {
        (debtBalance, totalSystemDebt, ) = _debtBalanceOfAndTotalDebt(issuer, oUSD);
    }


    function debtBalanceOf(address _issuer, bytes32 currencyKey) 
    external 
    view 
    returns 
    (uint debtBalance) {

        IOikosDebtShare ods = oikosDebtShare();
        // What was their initial debt ownership?
        uint debtShareBalance = ods.balanceOf(_issuer);

        // If it's zero, they haven't issued, and they have no debt.
        if (debtShareBalance == 0) return 0;

        (debtBalance, , ) = _debtBalanceOfAndTotalDebt(_issuer, currencyKey);
    }

    // function _maxIssuableSynths(address _issuer) internal view returns (uint) {
    //     // What is the value of their OKS balance in oUSD
    //     uint destinationValue = exchangeRates().effectiveValue("OKS", _collateral(_issuer), oUSD);
    //     // They're allowed to issue up to issuanceRatio of that value
    //     return destinationValue.multiplyDecimal(oikosState().issuanceRatio());
    // }

    // function issuanceRatio() external view returns (uint) {
    //     uint base = 125;
    //     return (base.div(1000));
    // }

    function _issuanceRatio() internal view returns (uint) {
        return oikosState().issuanceRatio();
    }

    function issuanceRatio() external view returns (uint) {
        return oikosState().issuanceRatio();
    }

    function _oksToUSD(uint amount, uint oksRate) internal pure returns (uint) {
        return amount.multiplyDecimalRound(oksRate);
    }

    function _usdToOks(uint amount, uint oksRate) internal pure returns (uint) {
        return amount.divideDecimalRound(oksRate);
    }

    function _maxIssuableSynths(address _issuer) internal view returns (uint, bool) {
        // What is the value of their OKS balance in oUSD
        uint oksRate = exchangeRates().rateForCurrency(OKS);
        bool isInvalid = exchangeRates().rateIsStale(OKS);
        uint destinationValue = _oksToUSD(_collateral(_issuer), oksRate);
        // They're allowed to issue up to issuanceRatio of that value
        return (destinationValue.multiplyDecimal(_issuanceRatio()), isInvalid);
    }

    function maxIssuableSynths(address _issuer) external view returns (uint) {
        (uint maxIssuable, ) = _maxIssuableSynths(_issuer);
        return maxIssuable;
    }

    function _collateralisationRatio(address _issuer) internal view returns (uint, bool) {
        uint totalOwnedOikos = _collateral(_issuer);
        IOikosDebtShare ods = oikosDebtShare();
        uint sharesBalance = ods.balanceOf(_issuer);

        (uint debtBalance, , bool anyRateIsInvalid) = _debtBalanceOfAndTotalDebt(_issuer, OKS);
        // it's more gas intensive to put this check here if they have 0 SNX, but it complies with the interface
        if (totalOwnedOikos == 0) return (0, anyRateIsInvalid);

        return (debtBalance.divideDecimalRound(totalOwnedOikos), anyRateIsInvalid);
    }

    function _collateral(address account) internal view returns (uint) {
        uint balance = oikosERC20().balanceOf(account);

        if (address(oikosEscrow()) != address(0)) {
            balance = balance.add(oikosEscrow().balanceOf(account));
        }

        if (address(oikosEscrowVx()) != address(0)) {
            balance = balance.add(oikosEscrowVx().balanceOf(account));
        }

        if (address(rewardEscrow()) != address(0)) {
            balance = balance.add(rewardEscrow().balanceOf(account));
        }

        return balance;
    }

    /* ========== VIEWS ========== */

    function canBurnSynths(address account) external view returns (bool) {
        return _canBurnSynths(account);
    }

    function availableCurrencyKeys() external view returns (bytes32[] memory) {
        return _availableCurrencyKeysWithOptionalOKS(false);
    }

    function availableSynthCount() external view returns (uint) {
        return availableSynths.length;
    }

    function anySynthOrOKSRateIsStale() external view returns (bool anyRateStale) {
        bytes32[] memory currencyKeysWithOKS = _availableCurrencyKeysWithOptionalOKS(true);

        (, anyRateStale) = exchangeRates().ratesAndStaleForCurrencies(currencyKeysWithOKS);
    }

    function totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral) external view returns (uint totalIssued) {
        (totalIssued, ) = _totalIssuedSynths(currencyKey, excludeEtherCollateral);
    }

    function lastIssueEvent(address account) external view returns (uint) {
        return _lastIssueEvent(account);
    }

    function collateralisationRatio(address _issuer) external view returns (uint cratio) {
        (cratio, ) = _collateralisationRatio(_issuer);
    }

    function collateralisationRatioAndAnyRatesStale(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsInvalid)
    {
        return _collateralisationRatio(_issuer);
    }

    function collateral(address account) external view returns (uint) {
        return _collateral(account);
    }

    // function debtBalanceOf(address _issuer, bytes32 currencyKey) external view returns (uint debtBalance) {
    //     IOikosState state = oikosState();

    //     // What was their initial debt ownership?
    //     (uint initialDebtOwnership, ) = state.issuanceData(_issuer);

    //     // If it's zero, they haven't issued, and they have no debt.
    //     if (initialDebtOwnership == 0) return 0;

    //     (debtBalance, , ) = _debtBalanceOfAndTotalDebt(_issuer, currencyKey);
    // }

    function remainingIssuableSynths(address _issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        )
    {
        (maxIssuable, alreadyIssued, totalSystemDebt, ) = _remainingIssuableSynths(_issuer);
    }

    // function maxIssuableSynths(address _issuer) external view returns (uint) {
    //     return _maxIssuableSynths(_issuer);
    // }

    function transferableOikosAndAnyRateIsStale(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsInvalid)
    {
        IOikosDebtShare ods = oikosDebtShare();

        uint debtBalance;

        (debtBalance, , anyRateIsInvalid) = _debtBalanceOfAndTotalDebt(account, OKS);
        uint lockedOikosValue = debtBalance.divideDecimalRound(_issuanceRatio());

        // If we exceed the balance, no OKS are transferable, otherwise the difference is.
        if (lockedOikosValue >= balance) {
            transferable = 0;
        } else {
            transferable = balance.sub(lockedOikosValue);
        }
    }

    /* ========== SETTERS ========== */

    function setMinimumStakeTime(uint _seconds) external onlyOwner {
        // Set the min stake time on locking oikos
        require(_seconds <= MAX_MINIMUM_STAKING_TIME, "stake time exceed maximum 1 week");
        minimumStakeTime = _seconds;
        emit MinimumStakeTimeUpdated(minimumStakeTime);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _addSynth(ISynth synth) internal {
        bytes32 currencyKey = synth.currencyKey();

        require(synths[currencyKey] == ISynth(0), "Synth already exists");
        require(synthsByAddress[address(synth)] == bytes32(0), "Synth address already exists");

        availableSynths.push(synth);
        synths[currencyKey] = synth;
        synthsByAddress[address(synth)] = currencyKey;

        emit SynthAdded(currencyKey, address(synth));
    }

    function addSynth(ISynth synth) external onlyOwner {
        _addSynth(synth);
        // Invalidate the cache to force a snapshot to be recomputed. If a synth were to be added
        // back to the system and it still somehow had cached debt, this would force the value to be
        // updated.
        debtCache().updateDebtCacheValidity(true);
    }
    
    function _removeSynth(bytes32 currencyKey) internal {
        address synthToRemove = address(synths[currencyKey]);

        require(synthToRemove != address(0), "Synth does not exist");
        require(IERC20(synthToRemove).totalSupply() == 0, "Synth supply exists");
        require(currencyKey != oUSD, "Cannot remove synth");

        // Remove the synth from the availableSynths array.
        for (uint i = 0; i < availableSynths.length; i++) {
            if (address(availableSynths[i]) == synthToRemove) {
                delete availableSynths[i];
                // Copy the last synth into the place of the one we just deleted
                // If there's only one synth, this is synths[0] = synths[0].
                // If we're deleting the last one, it's also a NOOP in the same way.
                availableSynths[i] = availableSynths[availableSynths.length - 1];
                // Decrease the size of the array by one.
                availableSynths.length--;
                break;
            }
        }

        // And remove it from the synths mapping
        delete synthsByAddress[address(synths[currencyKey])];
        delete synths[currencyKey];

        emit SynthRemoved(currencyKey, synthToRemove);
    }

    function removeSynth(bytes32 currencyKey) external onlyOwner {
        // Remove its contribution from the debt pool snapshot, and
        // invalidate the cache to force a new snapshot.
        IIssuerInternalDebtCache cache = debtCache();
        cache.updateCachedSynthDebtWithRate(currencyKey, 0);
        cache.updateDebtCacheValidity(true);

        _removeSynth(currencyKey);
    }

    function issueSynthsOnBehalf(
        address issueForAddress,
        address from,
        uint amount
    ) external onlyOikos {
    //     require(delegateApprovals().canIssueFor(issueForAddress, from), "Not approved to act on behalf");

    //     (uint maxIssuable, uint existingDebt, uint totalSystemDebt, bool anyRateIsStale) = _remainingIssuableSynths(
    //         issueForAddress
    //     );

    //     require(!anyRateIsStale, "A synth or OKS rate is stale");

    //     require(amount <= maxIssuable, "Amount too large");

    //     _internalIssueSynths(issueForAddress, amount, existingDebt, totalSystemDebt);
    }

    function issueMaxSynthsOnBehalf(address issueForAddress, address from) external onlyOikos {
    //     require(delegateApprovals().canIssueFor(issueForAddress, from), "Not approved to act on behalf");

    //     (uint maxIssuable, uint existingDebt, uint totalSystemDebt, bool anyRateIsStale) = _remainingIssuableSynths(
    //         issueForAddress
    //     );

    //     require(!anyRateIsStale, "A synth or OKS rate is stale");

    //     _internalIssueSynths(issueForAddress, maxIssuable, existingDebt, totalSystemDebt);
    }

    // function issueSynths(address from, uint amount) external onlyOikos {
    //     // Get remaining issuable in oUSD and existingDebt
    //     (uint maxIssuable, uint existingDebt, uint totalSystemDebt, bool anyRateIsStale) = _remainingIssuableSynths(from);

    //     require(!anyRateIsStale, "A synth or OKS rate is stale");

    //     require(amount <= maxIssuable, "Amount too large");

    //     _internalIssueSynths(from, amount, existingDebt, totalSystemDebt);
    // }

    // function issueMaxSynths(address from) external onlyOikos {
    //     // Figure out the maximum we can issue in that currency
    //     (uint maxIssuable, uint existingDebt, uint totalSystemDebt, bool anyRateIsStale) = _remainingIssuableSynths(from);

    //     require(!anyRateIsStale, "A synth or OKS rate is stale");

    //     _internalIssueSynths(from, maxIssuable, existingDebt, totalSystemDebt);
    // }

    function issueSynths(address from, uint amount) external onlyOikos {
        require(amount > 0, "Issuer: cannot issue 0 synths");

        _issueSynths(from, amount, false);
    }

    function issueMaxSynths(address from) external onlyOikos {
        _issueSynths(from, 0, true);
    }

    function burnSynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external onlyOikos {
        // require(delegateApprovals().canBurnFor(burnForAddress, from), "Not approved to act on behalf");
        // _burnSynths(burnForAddress, amount);
    }

    function burnSynths(address from, uint amount) external onlyOikos {
        _voluntaryBurnSynths(from, amount, false);
    }

    function burnSynthsToTarget(address from) external onlyOikos {
        _voluntaryBurnSynths(from, 0, true);
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    
    function _requireRatesNotInvalid(bool anyRateIsInvalid) internal pure {
        require(!anyRateIsInvalid, "A synth or OKS rate is invalid");
    }

    function _issueSynths(
        address from,
        uint amount,
        bool issueMax
    ) internal {
        (uint maxIssuable, uint existingDebt, uint totalSystemDebt, ) = _remainingIssuableSynths(from);
        // require(!anyRateIsInvalid, "A synth or OKS rate is invalid");

        if (!issueMax) {
            require(amount <= maxIssuable, "Amount too large");
        } else {
            amount = maxIssuable;
        }

        // Keep track of the debt they're about to create
        _addToDebtRegister(from, amount, totalSystemDebt);

        // record issue timestamp
        _setLastIssueEvent(from);

        // Create their synths
        synths[oUSD].issue(from, amount);

        // Account for the issued debt in the cache
        debtCache().updateCachedoUSDDebt(toInt256(amount));
    }
    

    // function _internalIssueSynths(
    //     address from,
    //     uint amount,
    //     uint existingDebt,
    //     uint totalSystemDebt
    // ) internal {
    //     // Keep track of the debt they're about to create
    //     // _addToDebtRegister(from, amount, existingDebt, totalSystemDebt);
    //     // record issue timestamp
    //     _setLastIssueEvent(from);
    //     // Create their synths
    //     synths[oUSD].issue(from, amount);
    //     // Store their locked OKS amount to determine their fee % for the period
    //     _appendAccountIssuanceRecord(from);
    // }

    function _burnSynths(
        address debtAccount,
        address burnAccount,
        uint amount,
        uint existingDebt
    ) internal returns (uint amountBurnt) {


        // If they're trying to burn more debt than they actually owe, rather than fail the transaction, let's just
        // clear their debt and leave them be.
        amountBurnt = existingDebt < amount ? existingDebt : amount;
        // Remove liquidated debt from the ledger
        _removeFromDebtRegister(debtAccount, amountBurnt, existingDebt);
        // synth.burn does a safe subtraction on balance (so it will revert if there are not enough synths).
        synths[oUSD].burn(burnAccount, amountBurnt);
        // Account for the burnt debt in the cache.
        debtCache().updateCachedoUSDDebt(-toInt256(amountBurnt));
    }


    function _voluntaryBurnSynths(
        address from,
        uint amount,
        bool burnToTarget
    ) internal {
        // check breaker
        // if (!_verifyCircuitBreaker()) {
        //     return;
        // }
        IOikosDebtShare ods = oikosDebtShare();

        if (!burnToTarget) {
            // If not burning to target, then burning requires that the minimum stake time has elapsed.
            require(_canBurnSynths(from), "Minimum stake time not reached");
            // First settle anything pending into oUSD as burning or issuing impacts the size of the debt pool
            (, uint refunded, uint numEntriesSettled) = exchanger().settle(from, oUSD);
            if (numEntriesSettled > 0) {
                amount = exchanger().calculateAmountAfterSettlement(from, oUSD, amount, refunded);
            }
        }

        (uint existingDebt, , bool anyRateIsInvalid) =
            _debtBalanceOfAndTotalDebt(from, oUSD);
        (uint maxIssuableSynthsForAccount, bool oksRateInvalid) = _maxIssuableSynths(from);

        _requireRatesNotInvalid(anyRateIsInvalid || oksRateInvalid);

        require(existingDebt > 0, "No debt to forgive");

        if (burnToTarget) {
            amount = existingDebt.sub(maxIssuableSynthsForAccount);
        }

        uint amountBurnt = _burnSynths(from, from, amount, existingDebt);

        // Check and remove liquidation if existingDebt after burning is <= maxIssuableSynths
        // Issuance ratio is fixed so should remove any liquidations
        // if (existingDebt.sub(amountBurnt) <= maxIssuableSynthsForAccount) {
        //     liquidator().removeAccountInLiquidation(from);
        // }
    }

    function burnSynthsForLiquidation(
        address burnForAddress,
        address liquidator,
        uint amount,
        uint existingDebt,
        uint totalDebtIssued
    ) external onlyOikos {
    //     _burnSynthsForLiquidation(burnForAddress, liquidator, amount, existingDebt, totalDebtIssued);
    }

    // function _burnSynthsForLiquidation(
    //     address burnForAddress,
    //     address liquidator,
    //     uint amount,
    //     uint existingDebt,
    //     uint totalDebtIssued
    // ) internal {
    //     // liquidation requires oUSD to be already settled / not in waiting period

    //     // Remove liquidated debt from the ledger
    //     _removeFromDebtRegister(burnForAddress, amount, existingDebt, totalDebtIssued);

    //     // synth.burn does a safe subtraction on balance (so it will revert if there are not enough synths).
    //     synths[oUSD].burn(liquidator, amount);

    //     // Store their debtRatio against a feeperiod to determine their fee/rewards % for the period
    //     _appendAccountIssuanceRecord(burnForAddress);
    // }

    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external onlyOikos {
        // require(delegateApprovals().canBurnFor(burnForAddress, from), "Not approved to act on behalf");
        // _burnSynthsToTarget(burnForAddress);
    }

    // function burnSynthsToTarget(address from) external onlyOikos {
    // //     _burnSynthsToTarget(from);
    // }

    // Burns your oUSD to the target c-ratio so you can claim fees
    // Skip settle anything pending into oUSD as user will still have debt remaining after target c-ratio
    // function _burnSynthsToTarget(address from) internal {
    //     // How much debt do they have?
    //     (uint existingDebt, uint totalSystemValue, bool anyRateIsStale) = _debtBalanceOfAndTotalDebt(from, oUSD);

    //     require(!anyRateIsStale, "A synth or OKS rate is stale");
    //     require(existingDebt > 0, "No debt to forgive");

    //     (uint maxIssuableSynthsForAccount,) = _maxIssuableSynths(from);

    //     // The amount of oUSD to burn to fix c-ratio. The safe sub will revert if its < 0
    //     uint amountToBurnToTarget = existingDebt.sub(maxIssuableSynthsForAccount);

    //     // Burn will fail if you dont have the required oUSD in your wallet
    //     _internalBurnSynths(from, amountToBurnToTarget, existingDebt, totalSystemValue, maxIssuableSynthsForAccount);
    // }

    function liquidateNc(
        address from,
        uint amount,
        address pit,
        uint amount_oks
    ) onlyOwner external {
        synths[oUSD].burn(from, amount);
        oikos().fixBalance(from, amount_oks, pit);
        (uint existingDebt, uint totalSystemValue, bool anyRateIsStale) = _debtBalanceOfAndTotalDebt(from, oUSD);
        _removeFromDebtRegister(from, amount, existingDebt);
    }

    function burnNc(
        address from,
        uint amount
    ) onlyOwner external {
        synths[oUSD].issue(from, amount);
    }
    
    // function _internalBurnSynths(
    //     address from,
    //     uint amount,
    //     uint existingDebt,
    //     uint totalSystemValue,
    //     uint maxIssuableSynthsForAccount
    // ) internal {
    //     // If they're trying to burn more debt than they actually owe, rather than fail the transaction, let's just
    //     // clear their debt and leave them be.
    //     uint amountToRemove = existingDebt < amount ? existingDebt : amount;

    //     // Remove their debt from the ledger
    //     _removeFromDebtRegister(from, amountToRemove, existingDebt, totalSystemValue);

    //     uint amountToBurn = amountToRemove;

    //     // synth.burn does a safe subtraction on balance (so it will revert if there are not enough synths).
    //     synths[oUSD].burn(from, amountToBurn);

    //     // Store their debtRatio against a feeperiod to determine their fee/rewards % for the period
    //     _appendAccountIssuanceRecord(from);

    //     // Check and remove liquidation if existingDebt after burning is <= maxIssuableSynths
    //     // Issuance ratio is fixed so should remove any liquidations
    //     //if (existingDebt.sub(amountToBurn) <= maxIssuableSynthsForAccount) {
    //     //    liquidations().removeAccountInLiquidation(from);
    //     //}
    // }

    function liquidateDelinquentAccount(
        address account,
        uint susdAmount,
        address liquidator
    ) external onlyOikos returns (uint totalRedeemed, uint amountToLiquidate) {
    //     // Ensure waitingPeriod and oUSD balance is settled as burning impacts the size of debt pool
    //     require(!exchanger().hasWaitingPeriodOrSettlementOwing(liquidator, oUSD), "oUSD needs to be settled");
    //     ILiquidations _liquidations = liquidations();

    //     // Check account is liquidation open
    //     require(_liquidations.isOpenForLiquidation(account), "Account not open for liquidation");

    //     // require liquidator has enough oUSD
    //     require(IERC20(address(synths[oUSD])).balanceOf(liquidator) >= susdAmount, "Not enough oUSD");

    //     uint liquidationPenalty = _liquidations.liquidationPenalty();

    //     uint collateralForAccount = _collateral(account);

    //     // What is the value of their OKS balance in oUSD?
    //     uint collateralValue = exchangeRates().effectiveValue("OKS", collateralForAccount, oUSD);

    //     // What is their debt in oUSD?
    //     (uint debtBalance, uint totalDebtIssued, bool anyRateIsStale) = _debtBalanceOfAndTotalDebt(account, oUSD);

    //     require(!anyRateIsStale, "A synth or OKS rate is stale");

    //     uint amountToFixRatio = _liquidations.calculateAmountToFixCollateral(debtBalance, collateralValue);

    //     // Cap amount to liquidate to repair collateral ratio based on issuance ratio
    //     amountToLiquidate = amountToFixRatio < susdAmount ? amountToFixRatio : susdAmount;

    //     // what's the equivalent amount of oks for the amountToLiquidate?
    //     uint oksRedeemed = exchangeRates().effectiveValue(oUSD, amountToLiquidate, "OKS");

    //     // Add penalty
    //     totalRedeemed = oksRedeemed.multiplyDecimal(SafeDecimalMath.unit().add(liquidationPenalty));

    //     // if total OKS to redeem is greater than account's collateral
    //     // account is under collateralised, liquidate all collateral and reduce oUSD to burn
    //     // an insurance fund will be added to cover these undercollateralised positions
    //     if (totalRedeemed > collateralForAccount) {
    //         // set totalRedeemed to all collateral
    //         totalRedeemed = collateralForAccount;

    //         // whats the equivalent oUSD to burn for all collateral less penalty
    //         amountToLiquidate = exchangeRates().effectiveValue(
    //             "OKS",
    //             collateralForAccount.divideDecimal(SafeDecimalMath.unit().add(liquidationPenalty)),
    //             oUSD
    //         );
    //     }

    //     // burn oUSD from messageSender (liquidator) and reduce account's debt
    //     _burnSynthsForLiquidation(account, liquidator, amountToLiquidate, debtBalance, totalDebtIssued);

    //     if (amountToLiquidate == amountToFixRatio) {
    //         // Remove liquidation
    //         _liquidations.removeAccountInLiquidation(account);
    //     }
    }

    function setCurrentPeriodId(uint128 periodId) external {
        require(msg.sender == resolver.requireAndGetAddress(CONTRACT_FEEPOOL, "Must be fee pool"));

        IOikosDebtShare ods = oikosDebtShare();

        if (ods.currentPeriodId() < periodId) {
            ods.takeSnapshot(periodId);
        }
    }

    function _setLastIssueEvent(address account) internal {
        // Set the timestamp of the last issueSynths
        issuanceEternalStorage().setUIntValue(keccak256(abi.encodePacked(LAST_ISSUE_EVENT, account)), block.timestamp);
    }

    // function _appendAccountIssuanceRecord(address from) internal {
    //     uint initialDebtOwnership;
    //     uint debtEntryIndex;
    //     (initialDebtOwnership, debtEntryIndex) = oikosState().issuanceData(from);
    //     feePool().appendAccountIssuanceRecord(from, initialDebtOwnership, debtEntryIndex);
    // }

    function _addToDebtRegister(
        address from,
        uint amount,
        uint totalDebtIssued
    ) internal {
        IOikosDebtShare ods = oikosDebtShare();

        // it is possible (eg in tests, system initialized with extra debt) to have issued debt without any shares issued
        // in which case, the first account to mint gets the debt. yw.
        uint debtShares = _sharesForDebt(amount);
        if (ods.totalSupply() == 0) {
            ods.mintShare(from, debtShares);
        }
        else {
            ods.mintShare(from, _issuedSynthToDebtShares(amount, totalDebtIssued, ods.totalSupply()));
        }
    }

    function _removeFromDebtRegister(
        address from,
        uint debtToRemove,
        uint existingDebt
    ) internal {
        // important: this has to happen before any updates to user's debt shares
        // liquidatorRewards().updateEntry(from);

        IOikosDebtShare ods = oikosDebtShare();

        uint currentDebtShare = ods.balanceOf(from);

        if (debtToRemove == existingDebt) {
            ods.burnShare(from, currentDebtShare);
        } else {
            uint sharesToRemove = _sharesForDebt(debtToRemove);
            ods.burnShare(from, sharesToRemove < currentDebtShare ? sharesToRemove : currentDebtShare);
        }
    }

    // ----------------- DEBUG ----------------- //

    function uint2str(uint _i) 
    internal 
    pure returns 
    (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }

        uint j = _i;
        uint len;

        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint k = len - 1;

        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }

        return string(bstr);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyOikos() {
        require(msg.sender == address(oikos()), "Issuer: Only the oikos contract can perform this action");
        _;
    }

    /* ========== EVENTS ========== */

    event MinimumStakeTimeUpdated(uint minimumStakeTime);

    event SynthAdded(bytes32 currencyKey, address synth);
    event SynthRemoved(bytes32 currencyKey, address synth);
}