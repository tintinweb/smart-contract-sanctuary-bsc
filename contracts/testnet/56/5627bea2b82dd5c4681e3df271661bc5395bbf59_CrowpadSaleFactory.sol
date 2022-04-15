/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

library EnumerableSet {
    
    
    
    
    
    
    
    

    struct Set {
        
        bytes32[] _values;
        
        
        mapping(bytes32 => uint256) _indexes;
    }

    
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            
            
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            
            
            
            

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                
                set._values[toDeleteIndex] = lastvalue;
                
                set._indexes[lastvalue] = valueIndex; 
            }

            
            set._values.pop();

            
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

library Clones {
    
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
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
        _transferOwnership(_msgSender());
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20Upgradeable {
    
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

interface ICrowpadSale {

    struct InitParams {
        uint256 saleRate;
        uint256 saleRateDecimals;
        uint256 listingRate;
        uint256 listingRateDecimals;
        uint256 liquidityPercent;
        address payable wallet;
        address router;
        address token;
        address baseToken;
        uint256 softCap;
        uint256 hardCap;
        uint256 minContribution;
        uint256 maxContribution;
        uint256 startTime;
        uint256 endTime;
        uint256 unlockTime;
        bool whitelistEnabled;
    }
    function initialize(
        ICrowpadSale.InitParams calldata params,
        address locker
    ) external;

    function setLogo(string memory logo_) external;
    function addWhitelistAdmin(address account) external;
    function transferOwnership(address account) external;
}

contract CrowpadSaleFactory is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    address payable feeAddress;
    address public implementation;
    address public locker;
    uint256 public deployFee = 0.8 ether;

    address[] private _sales;
    mapping(address => bool) private _salesAdded;
    mapping(address => EnumerableSet.UintSet) private _userSaleIds;
    mapping(address => EnumerableSet.UintSet) private _tokenToSaleIds;

    event NewSaleCreated(address from, address wallet, address deployed);

    event NewSaleMigrated(address from, address deployed);

    constructor(address payable _feeAddress, address _implementation) {
        feeAddress = _feeAddress;
        implementation = _implementation;
	}

    function setDeployFee(uint256 _newDeployFee) external onlyOwner {
        deployFee = _newDeployFee;
    }

    
    function setFeeAddress(address payable _newAddress) external onlyOwner {
        feeAddress = _newAddress;
    }

    function setLocker(address _locker) external onlyOwner {
        locker = _locker;
    }

    
    function createSale(
        ICrowpadSale.InitParams calldata params,
        string memory _logo
    ) public payable {
        require(locker != address(0), "Locker is not configured yet");
        require(msg.value >= deployFee, 'Insufficient funds sent for deploy');
        require(locker != address(0), 'Locker is not set yet');
        address newSaleAddress = Clones.clone(implementation);
        ICrowpadSale newSale = ICrowpadSale(newSaleAddress);
        newSale.initialize(
            params,
            locker
        );
        newSale.setLogo(_logo);
        newSale.addWhitelistAdmin(msg.sender);
        newSale.transferOwnership(msg.sender);
        _addSale(newSaleAddress, msg.sender, params.token);

        emit NewSaleCreated(msg.sender, params.wallet, newSaleAddress);
    }

	
    function withdrawFee() external onlyOwner {
        feeAddress.transfer(address(this).balance);
    }

    function migrateSale(address saleAddress, address owner, address token) external onlyOwner {
        require(!_salesAdded[saleAddress], "Sale was added already");
        _addSale(saleAddress, owner, token);
        emit NewSaleMigrated(owner, saleAddress);
    }

    function unmigrateSale(address saleAddress) external onlyOwner {
        require(_salesAdded[saleAddress], "Sale was not added");
        _salesAdded[saleAddress] = false;
        for (uint256 i = 0; i < _sales.length; i++) {
            if (_sales[i] == saleAddress) {
                _sales[i] = address(0);
            }
        }
    }

    function isPoolGenerated(address pool) public view returns (bool) {
        return _salesAdded[pool];
    }

    function _addSale(
        address sale,
        address owner,
        address token
    ) private returns (uint256 id) {
        id = _sales.length;
        _sales.push(sale);
        _salesAdded[sale] = true;
        _userSaleIds[owner].add(id);
        _tokenToSaleIds[token].add(id);
    }

    function totalSaleCountForToken(address token) public view returns (uint256) {
        return _tokenToSaleIds[token].length();
    }

    function totalSaleCountForUser(address user) public view returns (uint256) {
        return _userSaleIds[user].length();
    }

    function allSales() public view returns (address[] memory) {
        return _sales;
    }

    function getTotalSaleCount() public view returns (uint256) {
        return _sales.length;
    }

    function getSales(
        uint256 start, 
        uint256 end
    ) public view returns (address[] memory) {
        if (end >= _sales.length) {
            end = _sales.length - 1;
        }

        uint256 length = end - start + 1;
        address[] memory sales = new address[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            sales[currentIndex] = _sales[i];
            currentIndex++;
        }
        return sales;
    }

    function getSale(uint256 index) public view returns (address) {
        return _sales[index];
    }

    function getSalesForUser(address user)
        public
        view
        returns (address[] memory)
    {
        uint256 length = _userSaleIds[user].length();
        address[] memory userSales = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            userSales[i] = _sales[_userSaleIds[user].at(i)];
        }
        return userSales;
    }

    function getSalesForToken(
        address token,
        uint256 start,
        uint256 end
    ) public view returns (address[] memory) {
        if (end >= _tokenToSaleIds[token].length()) {
            end = _tokenToSaleIds[token].length() - 1;
        }
        uint256 length = end - start + 1;
        address[] memory sales = new address[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            sales[currentIndex] = _sales[_tokenToSaleIds[token].at(i)];
            currentIndex++;
        }
        return sales;
    }
}