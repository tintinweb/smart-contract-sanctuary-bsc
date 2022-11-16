// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

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
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
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
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

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
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
     * @dev Returns the number of values in the set. O(1).
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { EnumerableSet } from 'openzeppelin-contracts/utils/structs/EnumerableSet.sol';
// import { console } from 'forge-std/console.sol';

import { VBep20Interface, VTokenInterface } from '../interfaces/Venus/VTokenInterfaces.sol';
import { EIP20NonStandardInterface } from '../interfaces/Venus/EIP20NonStandardInterface.sol';
import { ComptrollerInterface } from "../interfaces/Venus/ComptrollerInterface.sol";

// import { IHedgerWhitelist } from './interfaces/IHedgerWhitelist.sol';

contract HedgerWhitelist {
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet private whitelist;

  EnumerableSet.AddressSet private supportedVTokens;
  
  EnumerableSet.AddressSet private delegates;

	address private router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeRouter

	ComptrollerInterface constant private comptroller = ComptrollerInterface(0xfD36E2c2a6789Db23113685031d7F16329158384); // Unitroller proxy

  address private _owner;
  
  bool public isFrozen = false;

  modifier notFrozen() {
    require(!isFrozen, 'Whitelist frozen');
    _;
  }

  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  modifier onlyDelegates() {
    require(owner() == msg.sender || delegates.contains(msg.sender), 'Delegateable: caller is not the owner or delegates');
    _;
  }

  constructor() {
		// whitelist.add(router); // PancakeRouter
    _owner = msg.sender;
	}

  function owner() public view virtual returns (address) {
    return _owner;
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    _owner = newOwner;
  }

  function addDelegate(address newDelegate) public virtual onlyOwner {
    delegates.add(newDelegate);
  }

  function removeDelegate(address newDelegate) public virtual onlyOwner {
    delegates.remove(newDelegate);
  }

  function approved(address addr) public view notFrozen returns (bool) {
    require(whitelist.contains(addr), 'Address not whitelisted');
    return true;
  }

  function add(address addr) public onlyDelegates {
    whitelist.add(addr);
  }

  function addBulk(address[] memory addrs) public onlyDelegates {
    for (uint i = 0; i < addrs.length;) {
      whitelist.add(addrs[i]);
      unchecked {
        i++;
      }
    }
  }

  function remove(address addr) public onlyDelegates {
    whitelist.remove(addr);
  }

  function removeBulk(address[] memory addrs) public onlyDelegates {
    for (uint i = 0; i < addrs.length;) {
      whitelist.remove(addrs[i]);
      unchecked {
        i++;
      }
    }
  }

  function clear() public onlyDelegates {
    address[] memory addrs = dump();
    for (uint256 i = 0; i < addrs.length; i++) {
      whitelist.remove(addrs[i]);
    }
  }

  function freeze() public onlyDelegates {
    isFrozen = true;
  }

  function unfreeze() public onlyDelegates {
    isFrozen = false;
  }

  /// @dev Show all whitelisted addresses
  function dump() public view onlyDelegates returns (address[] memory) {
    return whitelist.values();
  }

	function supportVToken(address vToken) public onlyDelegates {
		supportedVTokens.add(vToken);
		whitelist.add(address(vToken));
		if (vToken != address(0xA07c5b74C9B40447a954e1466938b865b6BBea36)) { // non vBNB
			// underlying token of vToken
			// EIP20NonStandardInterface vuToken = EIP20NonStandardInterface(address(VBep20Interface(vToken).underlying()));
			// console.log(address(vuToken));
			// vuToken.approve(address(vToken), type(uint).max); // For minting vToken
			// vuToken.approve(address(router), type(uint).max); // For swapping vToken
			// console.log(vuToken.allowance(address(this), address(vToken)));
			// console.log(vuToken.allowance(address(this), address(router)));

			whitelist.add(address(VBep20Interface(vToken).underlying()));
		} else {
			// EIP20NonStandardInterface BNB = EIP20NonStandardInterface(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
			// BNB.approve(address(vToken), type(uint).max);
			// BNB.approve(address(router), type(uint).max);
			whitelist.add(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
		}

		address[] memory vTokens = new address[](1);
		vTokens[0] = vToken;
		// comptroller.enterMarkets(vTokens);
    (bool success, bytes memory data) = address(comptroller).delegatecall(
      abi.encodeWithSignature("enterMarkets(address[])", vTokens)
    );
    require(success, 'Delegate call failed');
	}

	function supportVTokens(address[] memory vTokens) public onlyDelegates {
		for (uint i = 0; i < vTokens.length; i++) {
			supportedVTokens.add(vTokens[i]);
			whitelist.add(address(vTokens[i]));
			if (vTokens[i] != address(0xA07c5b74C9B40447a954e1466938b865b6BBea36)) { // non vBNB
				whitelist.add(address(VBep20Interface(vTokens[i]).underlying()));
			} else {
				whitelist.add(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
			}
		}

    // TODO: delegate call comptroller to enter market as msg.sender = address(hedger)
		// comptroller.enterMarkets(vTokens);
    // (bool success, bytes memory data) = address(comptroller).delegatecall(
    //   abi.encodeWithSignature("enterMarkets(address[])", vTokens)
    // );
    // require(success, 'Delegate call failed');
	}

	function unsupportVToken(address vToken) public onlyDelegates {
		supportedVTokens.remove(address(vToken));
		// underlying token of vToken
		EIP20NonStandardInterface vuToken = EIP20NonStandardInterface(address(VBep20Interface(vToken).underlying()));
		// For minting vToken
		vuToken.approve(address(vToken), 0);
		// For swapping vToken
		vuToken.approve(address(router), 0);
	}

	function getSupportedVTokens() public view returns (address[] memory) {
		return supportedVTokens.values();
	}

	function isSupportedVToken(address token) public view returns (bool) {
		return supportedVTokens.contains(token);
	}

	/// @dev Converts the input VToken amount to USDC value 
	function getVTokenValue(VTokenInterface token, uint256 amount) public view returns (uint256) {
		return token.exchangeRateStored() * amount / 1e18;
	}
}

pragma solidity ^0.8.17;

import "./VTokenInterfaces.sol";
import "./PriceOracle.sol";

interface IComptrollerInterfaceG1 {
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
    function setMintedVAIOf(address owner, uint amount) external returns (uint);
}

contract ComptrollerInterfaceG1 {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;
}

interface ComptrollerInterfaceG2 is IComptrollerInterfaceG1 {
    function liquidateVAICalculateSeizeTokens(
        address vTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}

interface IComptrollerInterface is ComptrollerInterfaceG2 {
    function markets(address) external view returns (bool, uint);
    function oracle() external view returns (PriceOracle);
    function getAccountLiquidity(address) external view returns (uint, uint, uint);
    function getAssetsIn(address) external view returns (VTokenInterface[] memory);
    function claimVenus(address) external;
    function venusAccrued(address) external view returns (uint);
    function venusSpeeds(address) external view returns (uint);
    function getAllMarkets() external view returns (VTokenInterface[] memory);
    function venusSupplierIndex(address, address) external view returns (uint);
    function venusInitialIndex() external view returns (uint224);
    function venusBorrowerIndex(address, address) external view returns (uint);
    function venusBorrowState(address) external view returns (uint224, uint32);
    function venusSupplyState(address) external view returns (uint224, uint32);
}

abstract contract ComptrollerInterface is IComptrollerInterface {
    bool public constant isComptroller = true;
}

interface IVAIVault {
    function updatePendingRewards() external;
}

interface IComptroller {
    function liquidationIncentiveMantissa() external view returns (uint);
    /*** Treasury Data ***/
    function treasuryAddress() external view returns (address);
    function treasuryPercent() external view returns (uint);
}

pragma solidity ^0.8.17;

/**
 * @title EIP20NonStandardInterface
 * @dev Version of BEP20 with no return values for `transfer` and `transferFrom`
 *  See https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
 */
interface EIP20NonStandardInterface {

    /**
     * @notice Get the total number of tokens in circulation
     * @return The supply of tokens
     */
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transfer` does not return a value, in violation of the BEP-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
      * @notice Transfer `amount` tokens from `msg.sender` to `dst`
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      */
    function transfer(address dst, uint256 amount) external;

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transferFrom` does not return a value, in violation of the BEP-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      */
    function transferFrom(address src, address dst, uint256 amount) external;

    function approve(address spender, uint256 amount) external returns (bool success);

    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

pragma solidity ^0.8.17;

/**
  * @title Venus's InterestRateModel Interface
  * @author Venus
  */
interface InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    function isInterestRateModel() external returns (bool);

    /**
      * @notice Calculates the current borrow interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @return The borrow rate per block (as a percentage, and scaled by 1e18)
      */
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);

    /**
      * @notice Calculates the current supply interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @param reserveFactorMantissa The current reserve factor the market has
      * @return The supply rate per block (as a percentage, and scaled by 1e18)
      */
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);
}

pragma solidity ^0.8.17;

import "./VTokenInterfaces.sol";

interface PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    // bool public constant isPriceOracle = true;

    /**
      * @notice Get the underlying price of a vToken asset
      * @param vToken The vToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(VTokenInterface vToken) external view returns (uint);
}

pragma solidity ^0.8.17;

import "./ComptrollerInterface.sol";
import "./InterestRateModel.sol";

interface VTokenInterface {
    /**
     * @notice Indicator that this is a VToken contract (for inspection)
     */
    // bool public constant isVToken = true;
    function isVToken() external returns (bool);

    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
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


    /*** Admin Functions ***/

    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint);
    function _acceptAdmin() external returns (uint);
    function _setComptroller(ComptrollerInterface newComptroller) external returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
    function _reduceReserves(uint reduceAmount) external returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) external returns (uint);
}

interface VBep20Interface is VTokenInterface {
    /**
     * @notice Underlying asset for this VToken
     */
    function underlying() external returns (address);

        /*** User Interface ***/

    function mint(uint mintAmount) external returns (uint);
    function mintBehalf(address receiver, uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, VTokenInterface vTokenCollateral) external returns (uint);


    /*** Admin Functions ***/

    function _addReserves(uint addAmount) external returns (uint);
}

interface VDelegatorInterface {
    /**
     * @notice Implementation address for this contract
     */
    function implementation() external returns (address);

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     * @param allowResign Flag to indicate whether to call _resignImplementation on the old implementation
     * @param becomeImplementationData The encoded bytes data to be passed to _becomeImplementation
     */
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) external;

    /**
     * @notice Called by the delegator on a delegate to initialize it for duty
     * @dev Should revert if any issues arise which make it unfit for delegation
     * @param data The encoded bytes data for any initialization
     */
    function _becomeImplementation(bytes memory data) external;

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility
     */
    function _resignImplementation() external;
}