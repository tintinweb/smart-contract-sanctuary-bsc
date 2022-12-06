/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e003");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e004");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e005");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e006");
        uint256 c = a / b;
        return c;
    }
}

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
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex;
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

interface token1Factory {
    function createToken(
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_
    ) external;
}

interface token2Factory {
    function createToken(
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_
    ) external;
}


interface token3Factory {
    function createToken(
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_,
        address _marketAddress,
        uint256[] memory _buyFeeList,
        uint256[] memory _sellFeeList,
        uint256[] memory _txFeeList
    ) external;
}

interface token4Factory {
    function createToken(
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_,
        address _marketAddress,
        uint256[] memory _buyFeeList,
        uint256[] memory _sellFeeList,
        uint256[] memory _txFeeList
    ) external;
}

contract tokenFactoryList is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    uint256 public index;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    feeItem public feeType;
    EnumerableSet.UintSet private allTokenSet;
    EnumerableSet.AddressSet private allTokenAddressSet;
    mapping(uint256 => tokenItem) public tokenList;
    mapping(address => EnumerableSet.UintSet) private userTokenSet;
    mapping(string => EnumerableSet.UintSet) private factoryNameTokenSet;
    mapping(address=>bool) public noFeeList;
    mapping(address => bool) public factoryAddressList;
    mapping(address => string) public factoryNameList;

    struct feeItem {
        bool _useNFTMode;
        bool _useCOTMode;
        IERC721 _nftToken;
        IERC20 _cotToken;
        uint256 _nftPrice;
        uint256 _cotPrice;
    }

    struct tokenItem {
        address _factoryAddress;
        string _factoryName;
        address _token;
        address _owner;
        string name_;
        string symbol_;
        uint256 decimals_;
        uint256 totalSupply_;
        bool _has_miner_mode;
        uint256 preSupply_;
    }

    event addTokenEvent(address _factoryAddress, string _factoryName, address _token, address _owner, string name_, string symbol_, uint256 decimals_, uint256 totalSupply_, bool _has_miner_mode, uint256 preSupply_, uint256 _time);

    function setFeeType(
        bool _useNFTMode,
        bool _useCOTMode,
        IERC721 _nftToken,
        IERC20 _cotToken,
        uint256 _nftPrice,
        uint256 _cotPrice
    ) external onlyOwner {
        require(_useNFTMode != _useCOTMode, "e001");
        feeType._useNFTMode = _useNFTMode;
        feeType._useCOTMode = _useCOTMode;
        feeType._nftToken = _nftToken;
        feeType._cotToken = _cotToken;
        feeType._nftPrice = _nftPrice;
        feeType._cotPrice = _cotPrice;
    }

    function addWhiteList(address _factoryAddress, string memory _factoryName, bool _inWhiteList) external onlyOwner {
        factoryAddressList[_factoryAddress] = _inWhiteList;
        factoryNameList[_factoryAddress] = _factoryName;
    }

    function setNoFeeList(address[] memory _userList, bool _status) external onlyOwner {
        for (uint256 i=0;i<_userList.length;i++) {
            noFeeList[_userList[i]] = _status;
        }
    }

    function takeFee(address _user) private {
        if (noFeeList[_user]) {
            return;
        }
        if (feeType._useNFTMode) {
            for (uint256 i = 0; i < feeType._nftPrice; i++) {
                feeType._nftToken.safeTransferFrom(_user, deadAddress, feeType._nftToken.tokenOfOwnerByIndex(_user, 0));
            }
        }
        if (feeType._useCOTMode) {
            feeType._cotToken.transferFrom(_user, deadAddress, feeType._cotPrice);
        }
    }

    function createNormalToken(
        address tokenFactoryAddress,
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_
    ) external {
        takeFee(msg.sender);
        if (!_has_miner_mode) {
            token1Factory(tokenFactoryAddress).createToken(newOwner_, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_);
        } else {
            token2Factory(tokenFactoryAddress).createToken(newOwner_, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_);
        }
    }

    function createDeflationaryToken(
        address tokenFactoryAddress,
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_,
        address _marketAddress,
        uint256[] memory _buyFeeList,
        uint256[] memory _sellFeeList,
        uint256[] memory _txFeeList
    ) external {
        takeFee(msg.sender);
        if (!_has_miner_mode) {
            token3Factory(tokenFactoryAddress).createToken(newOwner_, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_, _marketAddress, _buyFeeList, _sellFeeList, _txFeeList);
        } else {
            token4Factory(tokenFactoryAddress).createToken(newOwner_, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_, _marketAddress, _buyFeeList, _sellFeeList, _txFeeList);
        }
    }

    function addToken(
        address _factoryAddress,
        string memory _factoryName,
        address _token,
        address _owner,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_
    ) external {
        require(factoryAddressList[_factoryAddress], "t001");
        tokenList[index] = tokenItem(_factoryAddress, _factoryName, _token, _owner, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_);
        userTokenSet[_owner].add(index);
        allTokenSet.add(index);
        factoryNameTokenSet[_factoryName].add(1);
        index = index.add(1);
        allTokenAddressSet.add(_token);
        emit addTokenEvent(_factoryAddress, _factoryName, _token, _owner, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_, block.timestamp);
    }

    function getUserTokenIndexList(address _user) external view returns (uint256[] memory idList_) {
        idList_ = userTokenSet[_user].values();
    }

    function getUserTokenList(address _user) external view returns (tokenItem[] memory tokenList_) {
        uint256 num = userTokenSet[_user].length();
        uint256[] memory idList = userTokenSet[_user].values();
        tokenList_ = new tokenItem[](num);
        for (uint256 i = 0; i < num; i++) {
            tokenList_[i] = tokenList[idList[i]];
        }
    }

    function getAllTokenAddressSet() external view returns (address[] memory, uint256) {
        return (allTokenAddressSet.values(), allTokenAddressSet.length());
    }

    function getAllTokenAddressSetByIndexList(uint256[] memory idList_) external view returns (address[] memory tokenList_, uint256 _num) {
        _num = idList_.length;
        tokenList_ = new address[](_num);
        for (uint256 i = 0; i < _num; i++) {
            uint256 _index = idList_[i];
            tokenList_[i] = allTokenAddressSet.at(_index);
        }
    }

    function inList(address _token) external view returns (bool) {
        return allTokenAddressSet.contains(_token);
    }
}