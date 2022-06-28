/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
    constructor() {
        _setOwner(_msgSender());
    }

  
    function owner() public view virtual returns (address) {
        return _owner;
    }

   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

 
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {
   
    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

  
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

 
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {
  
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

   
    function decimals() public view virtual override returns (uint8) {
        return 18;
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

   
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

  
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

  
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

  
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

  
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

  
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

 
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


interface IComptroller {
    function dividend(address account) external;
}

interface Invitation{
    function getInvitation(address user) external view returns(address inviter, address[] memory invitees);
}


interface AddLp{
    function refresh() external;
}

contract Token is Ownable,ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;
    //address public lpHongAddr = 0xEBD709dD1eacb36f04C8AD2d2e522B09ef279Ed0;
    address public feeAddress = 0x019cD600657e4befe0db3574B5495076CE9c8403;  
    Invitation   public constant invitation = Invitation(0x618418C3f729e35eE315FEd351c3179342059974);
    address public addLpAddr;   
    address public routerAddr = 0xfA1e7160B908F0c34d7B6d7822F41310a6F5b0A4;
    address public reciveTokenAddr = 0x85EC32128C981511A717FF6Fb9178B93CdeA2c17;
    mapping(address => bool) public _dexMap;
    mapping(address => bool) public blackList;
    uint public exchangeFee = 100;
    //lphong
    address public LPAddr;
    uint public _reserve;
    uint public holdAtLeast = 100e18;
    mapping(address=>bool) public  LphongblackList;
    address[] public  hongArr = new address[](0);
    mapping(address=>bool) public hongMap;
    uint public hongIndex = 0;
    uint public  lengthArr = 5;

    
//  constructor(string memory name, string memory symbol) ERC20(name, symbol) {}
    constructor() ERC20("Vulcan", "Vulcan") {
        _mint(reciveTokenAddr, 21000000 * 10 ** decimals());
    }

    function onDistribute() internal{
        
        uint totalLP = IERC20(LPAddr).totalSupply();
        if (totalLP == 0) {
            return;
        }
        uint num = balanceOf(address(this));
        if (num >= holdAtLeast) {
            uint index = hongIndex;
            uint length = hongArr.length;
            if (length - index > lengthArr) {
                length = index + lengthArr;
                hongIndex += lengthArr;
            }else{
                hongIndex = 0;
            }
            
            for (index; index < length; index ++) {
                uint lpBalance = IERC20(LPAddr).balanceOf(hongArr[index]);
                if ((lpBalance == 0) ||(LphongblackList[hongArr[index]])){
                    continue;
                }

                super._transfer(address(this),hongArr[index],num * lpBalance / totalLP);
               
            }
        }
        
    }

 
    function _transfer(address sender, address recipient, uint256 amount) internal override {
     onDistribute();
     if ((!_dexMap[sender]) && (recipient == routerAddr)) {
            if (!hongMap[sender]) {
                hongArr.push(sender);
                hongMap[sender] = true;
            }
            
        }
        // buy
        if (_dexMap[sender] && !_dexMap[recipient]) {
            require(!blackList[recipient],"this address not allow exchange");
            //
            if (recipient == routerAddr){
                //remove lp
                super._transfer(sender, recipient, amount);
                return;
            }
            uint feeAmount = amount * exchangeFee /100;
            //burn
            super._transfer(sender, address(0xdead),feeAmount/6);
            //fee
            super._transfer(sender,feeAddress,feeAmount/6);
            //lphong
            super._transfer(sender,address(this),feeAmount/3);
          
            //transfer
            super._transfer(sender, recipient, amount - feeAmount);

            //childs
            address parent1;
            (parent1,) = invitation.getInvitation(recipient);
            if (parent1 != address(0)) {
                super._transfer(sender,parent1,feeAmount*5/60);
                address parent2;
                (parent2,) = invitation.getInvitation(parent1);
                if (parent2 != address(0)){
                    super._transfer(sender,parent2,feeAmount*6/60);
                    address parent3;
                    (parent3,) = invitation.getInvitation(parent2);
                    if (parent3 != address(0)){
                        super._transfer(sender,parent3,feeAmount*9/60);
                    } else {
                        
                        super._transfer(sender,addLpAddr,feeAmount*9/60);
                    }
                } else {
                   
                    super._transfer(sender,addLpAddr,feeAmount*15/60);
                }
            } else {
               
                super._transfer(sender,addLpAddr,feeAmount*20/60);
            } 
        
        // sell
        }else if (!_dexMap[sender] && _dexMap[recipient]) {
            require(!blackList[sender],"this address not allow exchange");
            if ((sender == routerAddr)||(sender == addLpAddr)){
                super._transfer(sender, recipient, amount);
                return;
            }
             uint feeAmount = amount * exchangeFee /100;
            //burn
            super._transfer(sender, address(0xdead),feeAmount/6);
            //fee
            super._transfer(sender,feeAddress,feeAmount/6);
            //lphong
            super._transfer(sender,address(this),feeAmount/3);
         
            //transfer
            super._transfer(sender, recipient, amount - feeAmount);

            //childs
            address parent1;
            (parent1,) = invitation.getInvitation(sender);
            if (parent1 != address(0)) {
                super._transfer(sender,parent1,feeAmount*5/60);
                address parent2;
                (parent2,) = invitation.getInvitation(parent1);
                if (parent2 != address(0)){
                    super._transfer(sender,parent2,feeAmount*6/60);
                    address parent3;
                    (parent3,) = invitation.getInvitation(parent2);
                    if (parent3 != address(0)){
                        super._transfer(sender,parent3,feeAmount*9/60);
                    } else {
                       
                        super._transfer(sender,addLpAddr,feeAmount*9/60);
                    }
                } else {
                    
                    super._transfer(sender,addLpAddr,feeAmount*15/60);
                }
            } else {
               
                super._transfer(sender,addLpAddr,feeAmount*20/60);
            } 

        // common
        }else{
            super._transfer(sender, recipient, amount);
             AddLp(addLpAddr).refresh();
        }
       
    }
    // setFee address
    function setDexMap(address account, bool state) external onlyOwner {
        _dexMap[account] = state;
        LPAddr = account;

    }
  

    function setFeeAddress(address feeAddr) external onlyOwner {
        feeAddress = feeAddr;
    }

     function setBlackList(address addr,bool b) external onlyOwner {
        blackList[addr] = b;
    }
  
   
  

   
    function setholdAtLeast(uint256 amount)external onlyOwner{
        holdAtLeast = amount;
    }
    function setLpHongBlackList(address addr,bool b)external onlyOwner{
        LphongblackList[addr] = b;
    }

    function getArrHong() external view returns (address[] memory){
        return hongArr;
    }
   
    function SetAddLpAddr(address addr) external onlyOwner{
        addLpAddr = addr;
        LphongblackList[addr] = true;
    }
    

    function setRouterAddr(address addr) external onlyOwner{
        routerAddr = addr;
    }

    function withdraw(address addr,uint amount) external onlyOwner{
        transfer(addr,amount);
    }
    function setFee(uint fee) external onlyOwner {
        exchangeFee = fee;
    }
}