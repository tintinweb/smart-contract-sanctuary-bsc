/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

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
        address[] _addressList;
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
    NFTMarketing public NFTMarketingAddress;
    using SafeMath for uint256;
    uint256 public shareId;
    uint256[] public shareIdList;
    uint256 public claimedAmount;
    uint256 public sharedAmount;
    mapping(uint256 => shareItem) public shareList;
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
            x._addressList = _addressList;
            shareList[shareId] = x;
            shareIdList.push(shareId);
            emit setShareEvent(block.number, block.timestamp, tx.origin, msg.sender, shareId, _shareAmount, _shareNumber, _claimAmountPerShare);
            shareId = shareId.add(1);
            sharedAmount = sharedAmount.add(_shareAmount);
        }
    }

    function UserInList(address _user,address[] memory _userList) public pure returns (bool) {
        for (uint256 i=0;i<_userList.length;i++) {
            if (_userList[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function claimById(uint256 _shareId) public returns (uint256){
        uint256 _claimAmount = shareList[_shareId]._claimAmountPerShare;
        configItem memory config = NFTMarketingAddress.config();
        if ((UserInList(msg.sender,shareList[_shareId]._addressList)) && !claimStatusList[msg.sender][_shareId]) {
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
        _userInfo._inWhiteList = (UserInList(msg.sender,shareList[_shareId]._addressList)) && !claimStatusList[_user][_shareId];
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