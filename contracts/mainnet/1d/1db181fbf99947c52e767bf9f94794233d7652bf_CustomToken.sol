/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IToken {
    // struct AP {

    // }
    // struct UP {
        

    // }

    struct BP {
        bool supable;
        bool pausable;
        bool blacklistable;
        bool whitelistable;
        bool lockable;
        bool taxable;
    }
    struct Params {
        uint maxSup;
        bool paused;
    }
    struct Rates {
        address rateAdr;
        uint buyRate;
        uint sellRate;
        uint txRate;
    }

    struct PP {
      bool blacklisted;
      bool whitelisted;

      uint lockTime;
      uint lockDuration;
    }

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function burn(uint256 _amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ITools {
  struct AdrP {
    address tOwner;
    address bAdr;
    address fAdr;
    address pair;
  }

  struct UintP { // last buy/sell, total buy/sell amount, etc?
    uint sBlock;
    uint blockDur;

    uint initAmount;
    uint incAmount;

    uint lastTrade;
    uint lastBuy;
    uint lastSell;
    uint tradeDelay;
  }

  struct BoolP {
    bool started;
  }

  function setTokenOwner(address adr) external;
  function beforeTransfer(address sender, address recipient, uint amount) external;
}




interface IPcsF {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}


interface IPcsP {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

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

    // function burn(uint256 _amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/////////////////////////////////////////////////////////////////////////////////////////////////////// EnumerableSet
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
        return _values(set._inner);
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

        assembly {
            result := store
        }

        return result;
    }
}












contract CustomToken {
    using EnumerableSet for EnumerableSet.AddressSet;
 
    address public owner;
 
    string public name;
    string public symbol;
    uint public decimals;
 
    uint private _totalSupply;
 
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
 
    EnumerableSet.AddressSet private _pairs;
    // AP public _AP;
    // UP public _UP;
    IToken.BP public BP;
    IToken.Params public _params;

    mapping (address => IToken.PP) public PP;

    mapping (uint => IToken.Rates) public _ratess;
    uint public _ratessIdx;

    ITools public tools;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    fallback() external payable {}
    receive() external payable {}
 
    modifier onlyOwner() {
        require(owner == msg.sender, "limited usage");
        _;
    }
 
 
    constructor (
        string memory name_, 
        string memory symbol_, 
        address[2] memory adrs, // owner, tool
        uint[3] memory uints, // decimals, amount, maxAmount
        bool[6] memory bools,
        IToken.Rates[] memory ratess_
        ) {
        owner = adrs[0];
 
        name = name_;
        symbol = symbol_;
        decimals = uints[0];
        
        _incSup(owner, uints[1] * 10**decimals);
        
        // params can only be set at the deploy
        adrs;

        
        if (bools[0]) { // supable
          BP.supable = bools[0];
          _params.maxSup = uints[2] * 10**decimals;
          require(_totalSupply <= _params.maxSup, "maxSup");
        }
        BP.pausable = bools[1];
        BP.blacklistable = bools[2];
        BP.whitelistable = bools[3];
        BP.lockable = bools[4];
        if (bools[5]) { // taxable
          BP.taxable = bools[5];
          _setRates(ratess_);
        }

        if (adrs[1] != address(0)) {
          tools = ITools(adrs[1]);
          tools.setTokenOwner(msg.sender);
        }
    }   
        
    // basic
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner_, address spender) public view virtual returns (uint256) {
        return _allowances[owner_][spender];
    }
 
 
 
 
    // approve
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _spendAllowance(address owner_, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            _approve(owner_, spender, currentAllowance - amount);
        }
    }
    function _approve(address owner_, address spender, uint256 amount) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
 
 
 
    // transfer
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
 
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        if (address(tools) != address(0)) {
          tools.beforeTransfer(from, to, amount);
        }

        amount = _beforeTokenTransfer(from, to, amount);
 
        _transferEvent(from, to, amount);
 
        amount = _afterTokenTransfer(from, to, amount);
    }
    function _transferEvent(address from, address to, uint256 amount) internal {
        if (amount == 0) {
          return;
        }
        
        _balances[from] -= amount;
        _balances[to] += amount;
 
        emit Transfer(from, to, amount);
    }
 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual returns (uint) {
        IToken.BP memory bp = BP;
        IToken.PP memory pp = PP[from];

        if (bp.whitelistable) {
          if (pp.whitelisted) {
              return amount;
          }
          if (PP[to].whitelisted) {
              return amount;
          }
        }
 
        if (bp.pausable) {
            require(!_params.paused, "paused");
        }
        if (bp.blacklistable) {
            require(!pp.blacklisted, "blacklisted");
        }
        if (bp.lockable) {
            require(pp.lockTime + pp.lockDuration <= block.timestamp, "lockTime lockDuration");
        }

        if (bp.taxable) {
            uint buySellTx;
            if (_pairs.contains(from)) { // buy 
                buySellTx = 0;
            } else if (_pairs.contains(to)) { // sell
                buySellTx = 1;
            } else {
                buySellTx = 2;
            }

            for (uint idx = 0; idx < _ratessIdx; idx++) {
                IToken.Rates memory rates = _ratess[idx];
                uint taxAmount;
                if (buySellTx == 0) {
                    taxAmount = amount * rates.buyRate / 10000;
                } else if (buySellTx == 1) {
                    taxAmount = amount * rates.sellRate / 10000;
                } else {
                    taxAmount = amount * rates.txRate / 10000;
                }

                amount -= taxAmount;
                _transferEvent(from, rates.rateAdr, taxAmount);
            }
        }
        from;
        to;
 
        return amount;
    }
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual returns (uint) {
        IToken.BP memory bp = BP;
        IToken.PP memory pp = PP[from];
 
        if (bp.whitelistable) {
            if (pp.whitelisted) {
                return amount;
            }
        }
 
        from;
        to;
 
        return amount;
    }
 
    
    /////////////////////////////////////////////////////////////////////////////////// special
    function transferMulti(address[] calldata adrs, uint[] calldata amounts) external { // not gas opt, following usual seq
        for (uint idx = 0; idx < adrs.length; idx++) {
            _transfer(msg.sender, adrs[idx], amounts[idx]);
        }
    }

    /////////////////////////////////////////////////////////////////////////////////// ownership
    function _transferOwnership(address newOwner) internal {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }
    

    /////////////////////////////////////////////////////////////////////////////////// owner
    function setPairs(address[] calldata fAdrs, address[] calldata bAdrs) external onlyOwner {
        for (uint idx = 0; idx < fAdrs.length; idx++) {
            address pair = IPcsF(fAdrs[idx]).getPair(address(this), bAdrs[idx]);
            if (_pairs.contains(pair)) { // no need
                continue;
            }
 
            _pairs.add(pair);
        }
    }
    
    // if you know how to read the code,
    // then you will also know this only works if supable is true
    // and you will also know supable only can be set at deploy time
    function _incSup(address adr, uint amount) internal {
      require(amount > 0, "amount");

      _balances[adr] += amount;
      _totalSupply += amount;

      emit Transfer(address(0), adr, amount);
    }
    function incSup(uint amount) external onlyOwner { // user amount
      require(BP.supable, "supable");
      
      IToken.Params memory params = _params;

      require(amount > 0, "amount");
 
      _incSup(owner, amount * 10**decimals);

      require(_totalSupply <= params.maxSup, "maxSup");
    }
    function setPause(bool flag) external onlyOwner {
        _params.paused = flag;
    }
    function setBlacklists(address[] calldata adrs, bool[] calldata flags) external onlyOwner {
        for (uint idx = 0; idx < adrs.length; idx++) {
          PP[adrs[idx]].blacklisted = flags[idx];
        }
    }
    function setWhitelists(address[] calldata adrs, bool[] calldata flags) external onlyOwner {
        for (uint idx = 0; idx < adrs.length; idx++) {
          PP[adrs[idx]].whitelisted = flags[idx];
        }
    }
    function setLocks(address[] calldata adrs, uint[] calldata durations) external onlyOwner {
        for (uint idx = 0; idx < adrs.length; idx++) {
          PP[adrs[idx]].lockTime = block.timestamp; // update lock time
          PP[adrs[idx]].lockDuration = durations[idx]; // can set to any duration as it could be needed
        }
    }

    function _setRates(IToken.Rates[] memory ratess_) internal {
        _ratessIdx = ratess_.length;

        IToken.Rates memory totRates;
        for (uint idx = 0; idx < _ratessIdx; idx++) { // buy, sell, tx
            IToken.Rates memory rates = ratess_[idx];
            if (rates.rateAdr == address(0)) {
                require(rates.buyRate + rates.sellRate + rates.txRate == 0, "rateAdr 0");
            }

            {
                _ratess[idx].rateAdr = rates.rateAdr;
                _ratess[idx].buyRate = rates.buyRate;
                _ratess[idx].sellRate = rates.sellRate;
                _ratess[idx].txRate = rates.txRate;

                totRates.buyRate += rates.buyRate;
                totRates.sellRate += rates.sellRate;
                totRates.txRate += rates.txRate;
            }
        }

        require(
            (totRates.buyRate <= 2500) &&
            (totRates.sellRate <= 2500) &&
            (totRates.txRate <= 2500)
            , "2500");
        
        
    }

    function setRates(IToken.Rates[] memory ratess_) external onlyOwner {
      _setRates(ratess_);
    }
}