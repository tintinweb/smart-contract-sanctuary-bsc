/**
 *Submitted for verification at BscScan.com on 2022-10-27
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
        require(c >= a, "s003");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "s004");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "s005");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "s006");
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface structIem {
    struct TokenItem {
        uint256 balanceOf;
        uint256 decimals;
        uint256 totalSupply;
        string name;
        string symbol;
        address[] tokenList;
        string[] nameList;
        string[] symbolList;
        uint256[] decimalsList;
    }

    struct configItem {
        uint256 lanchpadId;
        uint256 startTime;
        uint256 endTime;
        uint256 claimTime;
        uint256 totalAmount;
        uint256 okAmount;
        uint256 amountForClaim;
        uint256 claimedAmount;
        uint256 buyBackAmount;
        address spendToken;
        address claimToken;
    }

    struct configItem2 {
        uint256 minAmountPerAccount;
        uint256 maxAmountPerAccount;
        bool canIdo;
        bool canClaim;
        bool canBuyBack;
        bool useWhiteList;
        whiteListContract whiteListContractAddress;
    }

    struct userInfoItem {
        uint256 spendAmount;
        uint256 claimedSpendTokenAmount;
        uint256 claimedClaimTokenAmount;
        bool claimed;
    }

    struct lanchpadInfoItem {
        address lanchpadAddress;
        configItem LanchpadConfig;
        configItem2 LanchpadConfig2;
        userInfoItem userInfoItem;
        TokenItem lpInfo;
        uint256 claimClaimTokenAmount;
        uint256 claimSpendTokenAmount;
        bool isInWhiteList;
    }
}


interface whiteListContract {
    function isInWhiteList(address _user) external view returns (bool);
}

contract LanchpadItem is Ownable, structIem {
    using SafeMath for uint256;
    configItem public LanchpadConfig;
    configItem2 public LanchpadConfig2;
    mapping(address => userInfoItem) public userList;
    mapping(address => bool) public whiteList;

    event idoEvent(address _user, uint256 _idoAmount, uint256 _time);
    event buyBackEvent(address _user, uint256 _buyBackAmount, uint256 _time);
    event claimEvent(address _user, address _claimToken, uint256 _claimedClaimTokenAmount, address _spendToken, uint256 _claimedSpendTokenAmount, uint256 _time);

    modifier onlyAddress() {
        require(!isContract(msg.sender), "e001");
        _;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setConfig(uint256 _lanchpadId, uint256 _startTime, uint256 _endTime, uint256 _claimTime, uint256 _totalAmount, uint256 _amountForClaim, address _spendToken, address _claimToken) external onlyOwner {
        LanchpadConfig.lanchpadId = _lanchpadId;
        LanchpadConfig.startTime = _startTime;
        LanchpadConfig.endTime = _endTime;
        LanchpadConfig.claimTime = _claimTime;
        LanchpadConfig.totalAmount = _totalAmount;
        LanchpadConfig.amountForClaim = _amountForClaim;
        LanchpadConfig.spendToken = _spendToken;
        LanchpadConfig.claimToken = _claimToken;
    }

    function setUseWhiteList(bool _status, whiteListContract _whiteListContractAddress) external onlyOwner {
        LanchpadConfig2.useWhiteList = _status;
        LanchpadConfig2.whiteListContractAddress = _whiteListContractAddress;
    }

    function setWhiteList(address[] memory _addressList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _addressList.length; i++) {
            whiteList[_addressList[i]] = _status;
        }
    }

    function setTimeLine(uint256 _startTime, uint256 _endTime, uint256 _claimTime) external onlyOwner {
        LanchpadConfig.startTime = _startTime;
        LanchpadConfig.endTime = _endTime;
        LanchpadConfig.claimTime = _claimTime;
    }

    function setTokenList(address _spendToken, address _claimToken) external onlyOwner {
        LanchpadConfig.spendToken = _spendToken;
        LanchpadConfig.claimToken = _claimToken;
    }

    function setAmountList(uint256 _totalAmount, uint256 _amountForClaim) external onlyOwner {
        LanchpadConfig.totalAmount = _totalAmount;
        LanchpadConfig.amountForClaim = _amountForClaim;
    }

    function setStatusList(bool _canIdo, bool _canClaim, bool _canBuyBack) external onlyOwner {
        LanchpadConfig2.canIdo = _canIdo;
        LanchpadConfig2.canClaim = _canClaim;
        LanchpadConfig2.canBuyBack = _canBuyBack;
    }

    function setMinAndMaxAmountPerAccount(uint256 _minAmountPerAccount, uint256 _maxAmountPerAccount) external onlyOwner {
        LanchpadConfig2.minAmountPerAccount = _minAmountPerAccount;
        LanchpadConfig2.maxAmountPerAccount = _maxAmountPerAccount;
    }

    function ido(uint256 _amount) external payable onlyAddress {
        if (LanchpadConfig2.useWhiteList) {
            bool _isInWhiteList = false;
            if (address(LanchpadConfig2.whiteListContractAddress) != address(0)) {
                _isInWhiteList = LanchpadConfig2.whiteListContractAddress.isInWhiteList(msg.sender);
            }
            require(whiteList[msg.sender] || _isInWhiteList, "e000");
        }
        require(_amount >= LanchpadConfig2.minAmountPerAccount, "e001");
        require(userList[msg.sender].spendAmount.add(_amount) <= LanchpadConfig2.maxAmountPerAccount, "e002");
        require(LanchpadConfig2.canIdo, "e003");
        uint256 thisTime = block.timestamp;
        require(thisTime <= LanchpadConfig.endTime && thisTime >= LanchpadConfig.startTime, "e004");
        if (LanchpadConfig.spendToken == address(0)) {
            require(_amount == msg.value, "e005");
        } else {
            IERC20(LanchpadConfig.spendToken).transferFrom(msg.sender, address(this), _amount);
            require(msg.value == 0, "e006");
        }
        LanchpadConfig.okAmount = LanchpadConfig.okAmount.add(_amount);
        userList[msg.sender].spendAmount = userList[msg.sender].spendAmount.add(_amount);
        emit idoEvent(msg.sender, _amount, block.timestamp);
    }

    function buyBack() external onlyAddress {
        require(LanchpadConfig2.canBuyBack && !LanchpadConfig2.canClaim, "e001");
        uint256 thisTime = block.timestamp;
        require(thisTime <= LanchpadConfig.endTime && thisTime >= LanchpadConfig.startTime, "e002");
        require(userList[msg.sender].spendAmount > 0, "e003");
        if (LanchpadConfig.spendToken == address(0)) {
            payable(msg.sender).transfer(userList[msg.sender].spendAmount);
        } else {
            IERC20(LanchpadConfig.spendToken).transfer(msg.sender, userList[msg.sender].spendAmount);
        }
        LanchpadConfig.buyBackAmount = LanchpadConfig.buyBackAmount.add(userList[msg.sender].spendAmount);
        emit buyBackEvent(msg.sender, userList[msg.sender].spendAmount, block.timestamp);
        userList[msg.sender].spendAmount = 0;
    }

    function buyAllBack() external onlyAddress {
        require(LanchpadConfig2.canBuyBack && !LanchpadConfig2.canClaim, "e001");
        uint256 thisTime = block.timestamp;
        require(thisTime >= LanchpadConfig.claimTime, "e002");
        require(userList[msg.sender].spendAmount > 0, "e003");
        if (LanchpadConfig.spendToken == address(0)) {
            payable(msg.sender).transfer(userList[msg.sender].spendAmount);
        } else {
            IERC20(LanchpadConfig.spendToken).transfer(msg.sender, userList[msg.sender].spendAmount);
        }
        LanchpadConfig.buyBackAmount = LanchpadConfig.buyBackAmount.add(userList[msg.sender].spendAmount);
        emit buyBackEvent(msg.sender, userList[msg.sender].spendAmount, block.timestamp);
        userList[msg.sender].spendAmount = 0;
    }

    function getUserCanClaim(address _user) public view returns (uint256 _claimAmount, uint256 _claimAmount2) {
        if (LanchpadConfig.okAmount <= LanchpadConfig.totalAmount) {
            _claimAmount = (userList[_user].spendAmount).mul(LanchpadConfig.amountForClaim).div(LanchpadConfig.totalAmount);
            _claimAmount2 = 0;
        }
        else {
            uint256 overAmount = LanchpadConfig.okAmount.sub(LanchpadConfig.totalAmount);
            _claimAmount = (userList[_user].spendAmount).mul(LanchpadConfig.amountForClaim).div(LanchpadConfig.okAmount);
            _claimAmount2 = (userList[_user].spendAmount).mul(overAmount).div(LanchpadConfig.okAmount);
        }
    }

    function claim() external onlyAddress {
        require(LanchpadConfig2.canClaim, "e001");
        uint256 thisTime = block.timestamp;
        require(thisTime >= LanchpadConfig.claimTime, "e002");
        require(!userList[msg.sender].claimed, "e003");
        (uint256 _claimAmount,uint256 _claimAmount2) = getUserCanClaim(msg.sender);
        IERC20(LanchpadConfig.claimToken).transfer(msg.sender, _claimAmount);
        LanchpadConfig.claimedAmount = LanchpadConfig.claimedAmount.add(_claimAmount);
        userList[msg.sender].claimedClaimTokenAmount = _claimAmount;
        userList[msg.sender].claimedSpendTokenAmount = _claimAmount2;
        userList[msg.sender].claimed = true;
        if (_claimAmount2 > 0) {
            if (LanchpadConfig.spendToken != address(0)) {
                IERC20(LanchpadConfig.spendToken).transfer(msg.sender, _claimAmount2);
            } else {
                payable(msg.sender).transfer(_claimAmount2);
            }
        }
        emit claimEvent(msg.sender, LanchpadConfig.claimToken, _claimAmount, LanchpadConfig.spendToken, _claimAmount2, block.timestamp);
    }

    function claimToken(address _token, uint256 _amount) external onlyOwner {
        if (_token == address(0)) {
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_token).transfer(msg.sender, _amount);
        }
    }

    function claimAllToken(address _token) external onlyOwner {
        if (_token == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
        }
    }

    function getLpInfo(IERC20 _token, address _user) public view returns (TokenItem memory lpInfo) {
        uint256 balanceOf = _token.balanceOf(_user);
        address[] memory tokenList = new address[](2);
        string[] memory nameList = new string[](2);
        string[] memory symbolList = new string[](2);
        uint256[] memory decimalsList = new uint256[](2);
        try IPair(address(_token)).token0() returns (address token){
            address token0 = token;
            address token1 = IPair(address(_token)).token1();
            tokenList[0] = token0;
            tokenList[1] = token1;
            nameList[0] = IERC20(token0).name();
            nameList[1] = IERC20(token1).name();
            symbolList[0] = IERC20(token0).symbol();
            symbolList[1] = IERC20(token1).symbol();
            decimalsList[0] = IERC20(token0).decimals();
            decimalsList[1] = IERC20(token1).decimals();
        } catch {
        }
        lpInfo = TokenItem(balanceOf, _token.decimals(), _token.totalSupply(), _token.name(), _token.symbol(), tokenList, nameList, symbolList, decimalsList);
    }

    function getLanchpadInfo(address _user) external view returns (lanchpadInfoItem memory lanchpadInfoItem_) {
        (uint256 _claimAmount, uint256 _claimAmount2) = getUserCanClaim(_user);
        lanchpadInfoItem_.lanchpadAddress = address(this);
        lanchpadInfoItem_.LanchpadConfig = LanchpadConfig;
        lanchpadInfoItem_.LanchpadConfig2 = LanchpadConfig2;
        lanchpadInfoItem_.userInfoItem = userList[_user];
        lanchpadInfoItem_.claimClaimTokenAmount = _claimAmount;
        lanchpadInfoItem_.claimSpendTokenAmount = _claimAmount2;
        if (LanchpadConfig.spendToken != address(0)) {
            lanchpadInfoItem_.lpInfo = getLpInfo(IERC20(LanchpadConfig.spendToken), _user);
        } else {
            lanchpadInfoItem_.lpInfo = new TokenItem[](1)[0];
        }
        bool _isInWhiteList = false;
        if (address(LanchpadConfig2.whiteListContractAddress) != address(0)) {
            _isInWhiteList = LanchpadConfig2.whiteListContractAddress.isInWhiteList(_user);
        }
        lanchpadInfoItem_.isInWhiteList = (whiteList[_user] || _isInWhiteList);
    }

    receive() payable external {}
}

interface IPair is IERC20 {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract LanchpadFactory is Ownable, structIem {
    using SafeMath for uint256;
    uint256 public index = 0;
    mapping(uint256 => LanchpadItem) public lanchpadList;

    event addLanchpadEvent(uint256 _index, LanchpadItem _LanchpadAddress, uint256[] _startTime_endTime_claimTime, address spendToken, uint256[] _totalAmount_minAmountPerAccount_maxAmountPerAccount, address claimToken, uint256 amountForClaim, bool _useWhiteList,
        whiteListContract _whiteListContractAddress, uint256 _time);

    function addLanchpad(
        uint256[] memory startTime_endTime_claimTime,
        address spendToken,
        uint256[] memory totalAmount_minAmountPerAccount_maxAmountPerAccount,
        address claimToken,
        uint256 amountForClaim,
        bool useWhiteList,
        whiteListContract whiteListContractAddress
    ) external onlyOwner {
        LanchpadItem lanchpad = new LanchpadItem();
        lanchpad.setConfig(index, startTime_endTime_claimTime[0], startTime_endTime_claimTime[1], startTime_endTime_claimTime[2], totalAmount_minAmountPerAccount_maxAmountPerAccount[0], amountForClaim, spendToken, claimToken);
        lanchpad.setStatusList(true, false, false);
        lanchpad.setMinAndMaxAmountPerAccount(totalAmount_minAmountPerAccount_maxAmountPerAccount[1], totalAmount_minAmountPerAccount_maxAmountPerAccount[2]);
        lanchpad.setUseWhiteList(useWhiteList, whiteListContractAddress);
        lanchpad.transferOwnership(msg.sender);
        lanchpadList[index] = lanchpad;
        emit addLanchpadEvent(index, lanchpad, startTime_endTime_claimTime, spendToken, totalAmount_minAmountPerAccount_maxAmountPerAccount, claimToken, amountForClaim, useWhiteList, whiteListContractAddress, block.timestamp);
        index = index.add(1);
    }

    function getLanchpadInfo(uint256 _index, address _user) public view returns (lanchpadInfoItem memory lanchpadInfoItem_) {
        LanchpadItem lanchpad = lanchpadList[_index];
        lanchpadInfoItem_ = lanchpad.getLanchpadInfo(_user);
    }

    function massGetLanchpadInfo(uint256[] memory _indexList, address _user) external view returns (lanchpadInfoItem[] memory lanchpadInfoItemList_) {
        lanchpadInfoItemList_ = new lanchpadInfoItem[](_indexList.length);
        for (uint256 i = 0; i < _indexList.length; i++) {
            lanchpadInfoItemList_[i] = getLanchpadInfo(_indexList[i], _user);
        }
    }

    function getAllLanchpadInfo(address _user) external view returns (lanchpadInfoItem[] memory lanchpadInfoItemList_) {
        uint256[] memory _indexList = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            _indexList[i] = i;
        }
        lanchpadInfoItemList_ = new lanchpadInfoItem[](_indexList.length);
        for (uint256 i = 0; i < _indexList.length; i++) {
            lanchpadInfoItemList_[i] = getLanchpadInfo(_indexList[i], _user);
        }
    }
}