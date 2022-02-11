/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-06
*/

/**
 *Submitted for verification at Etherscan.io on 2021-01-29
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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
    function transferFrom(
        address sender,
        address recipient,
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

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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



contract TokenVesting is Ownable {
  using EnumerableSet for EnumerableSet.AddressSet;
    //represents one indiviaual vesting plan
  struct Vesting {
    uint256 amount;
    uint256 numPeriod;
    uint256 tgePercent; //200 means 20%
    uint256 paidAmount;
    uint256 secondsPerPeriod; //SECONDS_IN_MONTH = 60 * 60 * 24 * 30 = 2592000;  //SECONDS_IN_WEEK = 60 * 60 * 24 * 7 = 604800
    bool valid;
  }

  uint256 public constant SECONDS_IN_YEAR = 60 * 60 * 24 * 30 * 12;

  IERC20 public token;
  Vesting[] public vestings;
  uint256 public tgeTimestamp;
  
  // provide query for vesting schedule based on different vesting mode
  mapping(address => Vesting) public vestingSchedules;

  constructor(address _token, uint256 _tgeTimestamp) {
    token = IERC20(_token);
    tgeTimestamp = _tgeTimestamp;
  }

  //add Linear setting for the map vestingSchedules
  function _addLinearVestingSchedule(address _beneficiary, Vesting memory _vesting) internal {
    vestingSchedules[_beneficiary] = _vesting;
  }

  //_beneficiary, uint256 _amount, uint256 _numPeriod, uint256 _tgePercent, uint256 _paidAmount, uint256 _secondsPerPeriod
  function batchCreateVesting(
    address[] calldata _beneficiary,
    uint256[] calldata _amount,
    uint256[] calldata _numPeriod,
    uint256[] calldata _tgePercent,
    uint256[] calldata _secondsPerPeriod
  ) external onlyOwner {
    require(
      _beneficiary.length == _amount.length &&
      _beneficiary.length == _numPeriod.length &&
      _beneficiary.length == _tgePercent.length &&
      _beneficiary.length == _secondsPerPeriod.length,
      "Parameters length mismatch"
    );

    for (uint256 i = 0; i < _beneficiary.length; i++) {
      _addLinearVestingSchedule(
        _beneficiary[i], 
        Vesting({
          amount: _amount[i],
          numPeriod: _numPeriod[i],
          tgePercent: _tgePercent[i],
          paidAmount: 0,
          secondsPerPeriod: _secondsPerPeriod[i],
          valid: true
        })
      );
    }
  }

  // cancel vesting by address
  function cancelVesting(address _beneficiary) external onlyOwner {
    vestingSchedules[_beneficiary].valid = false;
  }

  function claim() external {
    _claim(_msgSender());
  }

  function batchClaim(address[] calldata _beneficiary) external {
    for (uint256 i = 0; i < _beneficiary.length; i++) {
      _claim(_beneficiary[i]);
    }
  }

  function _claim(address _beneficiary) internal {
    require(vestingSchedules[_beneficiary].valid, "Canceled");
    uint256 amountToPay = getAmountToPay(_beneficiary);
    token.transfer(_beneficiary, amountToPay);
    vestingSchedules[_beneficiary].paidAmount += amountToPay;
  }

  function getAmountToPay(address beneficiary) public view returns (uint256){
    return _getAmountToPay(beneficiary, block.timestamp);
  }

  function _getAmountToPay(address beneficiary, uint256 time) internal view returns (uint256){
    if (time < tgeTimestamp) {
      return 0;
    } else {
      Vesting memory vesting = vestingSchedules[beneficiary];
      uint256 periodToPay = (time - tgeTimestamp)/vesting.secondsPerPeriod;
      uint256 tgeAmountToPay = vesting.amount * vesting.tgePercent / 1000;
      uint256 nonTgeAmountToPay = vesting.amount * (1000 - vesting.tgePercent) * periodToPay / (vesting.numPeriod * 1000);

      return (tgeAmountToPay + nonTgeAmountToPay - vesting.paidAmount);
    }
  }

  function emergencywithdraw() external onlyOwner {
      token.transfer(owner(), token.balanceOf(address(this)));
  }

  function getVesting(address beneficiary)
    public
    view
    returns (
      uint256 amount,
      uint256 numMonthPeriod,
      uint256 tgePercent,
      uint256 paidAmount,
      uint256 secondsPerPeriod,
      bool valid
    )
  {
    Vesting memory vesting = vestingSchedules[beneficiary];
    amount = vesting.amount;
    numMonthPeriod = vesting.numPeriod;
    tgePercent = vesting.tgePercent;
    paidAmount = vesting.paidAmount;
    secondsPerPeriod = vesting.secondsPerPeriod;
    valid = vesting.valid;
  }

  // The function supports snapshot. return how much token can the beneficiary claim from now to TGE + 1 year.
  // 0.25 unit of votingPower = 1 year lock per token 
  function selfViewVotingPower(address beneficiary) public view returns (uint256) {
    Vesting memory vesting = vestingSchedules[beneficiary];
    if (vesting.valid == false) {
      return 0;
    }

    uint256 tgeAmountToPay = vesting.amount * vesting.tgePercent / 1000;
    uint256 nonTgeAmountToPay = vesting.amount * (1000 - vesting.tgePercent) / 1000;
    uint256 periodInYear = SECONDS_IN_YEAR/vesting.secondsPerPeriod;

    uint256 validNonTgeVotingPower = 0;

    if (block.timestamp < tgeTimestamp) {
      // Before TGE time, and vesting schedule is less than 1 year.
      if (vesting.numPeriod < periodInYear) {
        // n year linear unlocked = 0.5 * n year staked 
        validNonTgeVotingPower = nonTgeAmountToPay * vesting.numPeriod / periodInYear / 2;
      // Before TGE time, and vesting schedule is more than 1 year.
      } else {
        validNonTgeVotingPower = nonTgeAmountToPay * periodInYear / vesting.numPeriod / 2;
      }
      // Extra multiplier for time before tge, 10 => 10%
      uint256 extraPreTgeMul = (tgeTimestamp - block.timestamp) * 100 / SECONDS_IN_YEAR;
      // Transfer year lock per token into unit voting power
      return (tgeAmountToPay + validNonTgeVotingPower) * (100 + extraPreTgeMul) * 25 / 10000;
    } else if (tgeTimestamp <= block.timestamp && block.timestamp <= (tgeTimestamp + SECONDS_IN_YEAR)) {
      uint256 periodToEndVotingPerc = 0;
      if (vesting.numPeriod < periodInYear) {
        // current time between TGE and TGE + 1 year; vesting schedule is less than 1 year and finished.
        if (vesting.numPeriod * vesting.secondsPerPeriod < (block.timestamp - tgeTimestamp)) {
          periodToEndVotingPerc = 0;
        // current time between TGE and TGE + 1 year; vesting schedule is less than 1 year and not finished.
        } else {
          periodToEndVotingPerc = 100 * vesting.numPeriod - (100 * (block.timestamp - tgeTimestamp) / vesting.secondsPerPeriod);
        }
      // current time between TGE and TGE + 1 year; vesting schedule is more than 1 year (so not finished).
      } else {
        periodToEndVotingPerc = 100 * (tgeTimestamp + SECONDS_IN_YEAR - block.timestamp)/vesting.secondsPerPeriod;
        //uint256 tgeAmountToPay = 0;
      }
      validNonTgeVotingPower = nonTgeAmountToPay * periodToEndVotingPerc * periodToEndVotingPerc / (vesting.numPeriod * periodInYear) / 20000;
      return validNonTgeVotingPower * 25 / 100;
    } else {
      // (tgeTimestamp + SECONDS_IN_YEAR) <= block.timestamp
      //uint256 tgeAmountToPay = 0;
      //uint256 nonTgeAmountToPay = 0;
      return 0;
    }
  }

  mapping(address => address) public delegation; // user address => delegator
  mapping(address => EnumerableSet.AddressSet) private _delegator;

  // voting power including self and delegation
  function viewVotingPower(address beneficiary) internal view returns (uint256) {
    uint256 t = selfViewVotingPower(beneficiary);
    for (uint256 i = 0; i < _delegator[beneficiary].length(); i++) {
      t += selfViewVotingPower(_delegator[beneficiary].at(i));
    }
    return t;
  }

  function makeDelegation(address delegator) public {
    delegation[_msgSender()] = delegator;
    _delegator[delegator].add(_msgSender());
  }

  function cancelDelegation(address delegator) public {
    delegation[_msgSender()] = address(0);
    _delegator[delegator].remove(_msgSender());
  }

}