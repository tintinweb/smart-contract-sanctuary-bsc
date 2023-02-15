/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

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


interface IERC20 {
    function approve(address spender, uint value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function minAddPoolAmount() external view returns (uint256);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

    enum cardType {Gold, Silver, Bronze}
    enum typeSet {AllSet, GoldSet, SilverSet, BronzeSet, taskUserSet, allGoldUserSet, allSilverUserSet, allBronzeUserSet, fatherAddressSet, GoldLastIndexSet, userGetRewardIndexSet}


interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function mintForMiner(address _to) external returns (bool, uint256);

    function setType(uint256 _tokenId, cardType _type) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

    struct ConfigItem3 {
        bool useShareMode;
        uint256 minShareAmount;
    }

    struct configItem {
        uint256 startBlock;
        uint256 endBlock;
        IERC20 erc20Token;
        IERC20 shareToken;
        IERC721 nftToken;
        uint256 price;
        uint256 bronzeRate;
        uint256 shareRate;
        uint256 allRate;
        address teamAddress;
        bool useShareMode;
    }

    struct userInfoItem {
        configItem config;
        bool isGold;
        bool isSilver;
        bool isBronze;
        bool canInvite;
        address referer;
        address node;
        uint256 taskAmount;
        uint256 tokenId;
        uint256 sonAmount;
        uint256 allReward;
        uint256 allPlatformReward;
        uint256 allGoldNum;
        uint256 allSilverNum;
        uint256 allBronzeNum;
        uint256 idoAmount;
        uint256 shareId;
        address[] taskAddressList;
        address[] allGoldUserSet;
        address[] allSilverUserSet;
        address[] allBronzeUserSet;
        address[] fatherAddressSet;
    }

    struct userInfoItem2 {
        uint256 _claimAmount;
        bool _inWhiteList;
        bool _hasClaimed;
    }

    struct shareItem {
        //address[] _addressList;
        uint256 _shareId;
        uint256 _createTime;
        uint256 _totalAmount;
        uint256 _shareNumber;
        uint256 _claimAmountPerShare;
    }
interface NFTMarketing {
    function config() external view returns (configItem memory);
    function getSet(uint256 _setType, address _user) external view returns (address[] memory _addressList, uint256[] memory _uint256List, uint256 _num, string  memory _typeName);
}

contract NFTMarketingShare is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    NFTMarketing public NFTMarketingAddress;
    using SafeMath for uint256;
    uint256 public shareId;
    uint256[] public shareIdList;
    uint256 public claimedAmount;
    uint256 public sharedAmount;
    mapping(uint256 => shareItem) public shareList;
    mapping(uint256=>EnumerableSet.AddressSet) private shareAddressSet;
    mapping(address => mapping(uint256 => bool)) public claimStatusList;
    mapping(address => bool) public setShareUsersList;
    ConfigItem3 public configForShare; 
    event setShareEvent(uint256 _blockNumber, uint256 _time, address _txOrigin, address _msgSender, uint256 _shareId, uint256 _totalAmount, uint256 _shareNumber, uint256 _claimAmountPerShare);

    constructor (bool _useShareMode, uint256 _minShareAmount, NFTMarketing _NFTMarketingAddress) {
        setShareUsersList[address(_NFTMarketingAddress.config().shareToken)] = true;
        setShareUsersList[msg.sender] = true;
        setConfigForShare(_useShareMode,_minShareAmount);
        setNFTMarketing(_NFTMarketingAddress);
    }

    function setConfigForShare(bool _useShareMode, uint256 _minShareAmount) public onlyOwner {
        configForShare.useShareMode = _useShareMode;
        configForShare.minShareAmount = _minShareAmount;
    }

    function setNFTMarketing(NFTMarketing _NFTMarketingAddress) public onlyOwner {
        NFTMarketingAddress = _NFTMarketingAddress;
    }

    function takeWrongToken(IERC20 _token, uint256 _amount) public onlyOwner {
        if (_amount == 0) {
            _amount = _token.balanceOf(address(this));
        } else {
            require(_amount <= _token.balanceOf(address(this)), "e001");
        }
        _token.transfer(msg.sender, _amount);
    }

    function setSetShareUsersList(address[] memory _usersList, bool _status) public onlyOwner {
        for (uint256 i = 0; i < _usersList.length; i++) {
            setShareUsersList[_usersList[i]] = _status;
        }
    }

    function setShare() public {
        require(setShareUsersList[msg.sender], "sk001");
        configItem memory config = NFTMarketingAddress.config();
        uint256 _shareAmount = getLeftToken(config.shareToken);
        (address[] memory _addressList,, uint256 _shareNumber,) = NFTMarketingAddress.getSet(3,address(this));
        if (_shareNumber > 0 && configForShare.useShareMode && _shareAmount>=configForShare.minShareAmount) {
            uint256 _claimAmountPerShare = _shareAmount.div(_shareNumber);
            shareItem memory x = new shareItem[](1)[0];
            x._shareId = shareId;
            x._createTime = block.timestamp;
            x._totalAmount = _shareAmount;
            x._shareNumber = _shareNumber;
            x._claimAmountPerShare = _claimAmountPerShare;
            //x._addressList = _addressList;
            shareList[shareId] = x;
            shareIdList.push(shareId);
            for (uint256 i=0;i<_shareNumber;i++) {
                shareAddressSet[shareId].add(_addressList[i]);
            }
            emit setShareEvent(block.number, block.timestamp, tx.origin, msg.sender, shareId, _shareAmount, _shareNumber, _claimAmountPerShare);
            shareId = shareId.add(1);
            sharedAmount = sharedAmount.add(_shareAmount);
        }
    }

    function claimById(uint256 _shareId) public returns (uint256){
        uint256 _claimAmount = shareList[_shareId]._claimAmountPerShare;
        configItem memory config = NFTMarketingAddress.config();
        if (shareAddressSet[_shareId].contains(msg.sender) && !claimStatusList[msg.sender][_shareId]) {
            config.shareToken.transfer(msg.sender, _claimAmount);
            claimStatusList[msg.sender][_shareId] = true;
            claimedAmount = claimedAmount.add(_claimAmount);
            return _claimAmount;
        } else {
            return 0;
        }
    }

    function claimByShareIdList(uint256[] memory _shareIdList) public {
        uint256 _times = 0;
        for (uint256 i = 0; i < _shareIdList.length; i++) {
            uint256 _shareId = _shareIdList[i];
            (uint256 _claimAmount) = claimById(_shareId);
            if (_claimAmount > 0) {
                _times = _times.add(1);
            }
        }
        require(_times > 0, "e008");
    }

    function getUserInfoForShare(address _user, uint256 _shareId) public view returns (userInfoItem2 memory _userInfo) {
        _userInfo._claimAmount = shareList[_shareId]._claimAmountPerShare;
        _userInfo._inWhiteList = shareAddressSet[_shareId].contains(_user) && !claimStatusList[_user][_shareId];
        _userInfo._hasClaimed = claimStatusList[_user][_shareId];
    }

    function massGetAllUserInfoForShare(address _user) public view returns (userInfoItem2[] memory _userInfoList) {
        uint256 _num = shareIdList.length;
        _userInfoList = new userInfoItem2[](_num);
        for (uint256 i = 0; i < _num; i++) {
            _userInfoList[i] = getUserInfoForShare(_user, shareIdList[i]);
        }
    }

    function massGetUserInfoForShare(address _user, uint256[] memory _shareIdList) public view returns (userInfoItem2[] memory _userInfoList) {
        uint256 _num = _shareIdList.length;
        _userInfoList = new userInfoItem2[](_num);
        for (uint256 i = 0; i < _num; i++) {
            _userInfoList[i] = getUserInfoForShare(_user, _shareIdList[i]);
        }
    }

    function getLeftToken(IERC20 _token) public view returns (uint256) {
        if (_token.balanceOf(address(this)).add(claimedAmount) > sharedAmount) {
            return _token.balanceOf(address(this)).add(claimedAmount).sub(sharedAmount);
        } else {
            return 0;
        }
    }
}