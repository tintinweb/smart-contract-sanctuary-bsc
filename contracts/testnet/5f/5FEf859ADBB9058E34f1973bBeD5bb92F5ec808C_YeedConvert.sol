// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../Ownable.sol";

contract YeedConvert is Ownable {

    IERC20 public yeedToken;
    IERC20 public zeedToken = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    IERC20 public hoToken = IERC20(0x41515885251e724233c6cA94530d6dcf3A20dEc7);
    IERC20 public usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);

    address _zeedAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address _hoAddress = 0x41515885251e724233c6cA94530d6dcf3A20dEc7;
    address _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

    
    uint256 public zeedConverAmount = 1 * 10 ** 18;  
    uint256 public hoConverAmount = 2200 * 10 ** 18;    
    uint256 public usdtConverAmount = 2200 * 10 ** 18;  
    
    uint256 public zeedConverRatio = 3;    
    uint256 public hoConverRatio = 6;      
    uint256 public usdtConverRatio = 30;    

    uint256 public releaseAll = 12;
    
    uint256 public releaseAllAmount = 8400 * 10 ** 18;      

    struct UserInfo {
        uint256 whitelistAmount;        
        uint256 whitelistYeedConvert;   
        uint256 whitelistReceived;      

        uint256 yeedConvertAmount;     
        uint256 received;              
    }

    struct Order {
        address _address;               
        uint32 _type;                   
        uint256 _yeedAmount;            
        uint256 _converRatio;           
        address _token;                 
    }

    uint256 public whitelistConverRatio = 3;
    uint256 public whitelistConverAll = 33000 * 10 ** 18;

    mapping (address => UserInfo) userinfoMap;
    mapping (address => uint32) addressFrequency;   

    uint32 public frequency = 1;    
    uint256 public buyMax = 5 * 10 ** 18;      
    bool public openConver = false;
    bool public openWithdraw = false;
    bool public openWhitelistReceived = false;
    bool public openWhitelistConvert = false;
    uint256 public timestamp;
    uint256 public whitelistTimestamp;
    Order[] orders;

    function setZeedConverAmount(uint256 _zeedConverAmount) public onlyOwner {
        zeedConverAmount = _zeedConverAmount;
    }

    function sethoConverAmount(uint256 _hoConverAmount) public onlyOwner {
        hoConverAmount = _hoConverAmount;
    }

    function setUsdtConverAmount(uint256 _usdtConverAmount) public onlyOwner {
        usdtConverAmount = _usdtConverAmount;
    }

    function setUsdtConverRatio(uint256 _usdtConverRatio) public onlyOwner {
        usdtConverRatio = _usdtConverRatio;
    }

    function setHoConverRatio(uint256 _hoConverRatio) public onlyOwner {
        hoConverRatio = hoConverRatio;
    }

    function setZeedConverRatio(uint256 _zeedConverRatio) public onlyOwner {
        zeedConverRatio = _zeedConverRatio;
    }

    function setwhitelistConverRatio(uint256 _whitelistConverRatio) public onlyOwner {
        whitelistConverRatio = _whitelistConverRatio;
    }

    function getTotalOrder () public view returns(uint256 _totalOrder) {
        _totalOrder = orders.length;
    }

    function getOrder (uint256 _index) public view returns (address _address, uint32 _type, uint256 _yeedAmount, uint256 _converRatio, address _token) {
        require(orders.length > _index, "getOrder: not date");
        Order memory order = orders[_index];
        _address = order._address;
        _type = order._type;
        _yeedAmount = order._yeedAmount;
        _converRatio = order._converRatio;
        _token = order._token;
    }
    
    function setBuyMax (uint256 _buyMax) public onlyOwner {
        buyMax = _buyMax * 10 ** 18;
    }
    
    function whilelistConvertYeed (uint256 _yeedAmount) public {
        UserInfo memory userinfo = userinfoMap[msg.sender];
        require(openWhitelistConvert && userinfo.whitelistAmount > 0 && userinfo.whitelistYeedConvert < userinfo.whitelistAmount && (userinfo.whitelistYeedConvert + _yeedAmount) <= userinfo.whitelistAmount, "whilelistConvertYeed: error");
        uint256 _transfer = whitelistConverRatio * _yeedAmount;
        zeedToken.transferFrom(msg.sender, address(this), _transfer);

        userinfo.whitelistYeedConvert += _yeedAmount;
        userinfoMap[msg.sender] = userinfo;
        whitelistConverAll -= _yeedAmount;
        Order memory _order = Order(msg.sender, 2, _yeedAmount, whitelistConverRatio, _zeedAddress);
        orders.push(_order);
    }

    

    function ZeedConvertYeed (uint256 _yeedAmount) public {
        _yeedAmount = _yeedAmount * 10 ** 18;
        require(openConver && _yeedAmount > 0, "ZeedConvertYeed: not started");
        uint256 _frequency = addressFrequency[msg.sender];
        require(frequency > _frequency, "ZeedConvertYeed: buy YEED error");
        require(zeedConverAmount > 0, "ZeedConvertYeed: buy YEED error");

        uint256 _amount = _yeedAmount * zeedConverRatio;
        require(buyMax >= _yeedAmount, "ZeedConvertYeed: Convert over limit");

        zeedToken.transferFrom(msg.sender, address(this), _amount);

        UserInfo memory userinfo = userinfoMap[msg.sender];
        userinfo.yeedConvertAmount += _yeedAmount;
        userinfoMap[msg.sender] = userinfo;
        addressFrequency[msg.sender] += 1;
        zeedConverAmount -= _yeedAmount;

        Order memory _order = Order(msg.sender, 1, _yeedAmount, zeedConverRatio, _zeedAddress);
        orders.push(_order);
    }

    function HoConvertYeed (uint256 _yeedAmount) public {
        _yeedAmount = _yeedAmount * 10 ** 18;
        require(openConver && _yeedAmount > 0, "HoConvertYeed: not started");
        uint256 _frequency = addressFrequency[msg.sender];
        require(frequency > _frequency, "HoConvertYeed: buy YEED error");

        uint256 _amount = _yeedAmount * hoConverRatio;
        require(buyMax >= _yeedAmount, "HoConvertYeed: Convert over limit");
        require(hoConverAmount > 0, "HoConvertYeed: buy YEED error");

        hoToken.transferFrom(msg.sender, address(this), _amount);

        UserInfo memory userinfo = userinfoMap[msg.sender];
        userinfo.yeedConvertAmount += _yeedAmount;
        userinfoMap[msg.sender] = userinfo;
        addressFrequency[msg.sender] += 1;
        hoConverAmount -= _yeedAmount;

        Order memory _order = Order(msg.sender, 1, _yeedAmount, hoConverRatio, _hoAddress);
        orders.push(_order);
    }

    function UsdtConvertYeed (uint256 _yeedAmount) public {
        _yeedAmount = _yeedAmount * 10 ** 18;
        require(openConver && _yeedAmount > 0, "UsdtConvertYeed: not started");
        uint256 _frequency = addressFrequency[msg.sender];
        require(frequency > _frequency, "UsdtConvertYeed: buy YEED error");

        uint256 _amount = _yeedAmount * usdtConverRatio;
        require(buyMax >= _yeedAmount, "UsdtConvertYeed: Convert over limit");
        require(usdtConverAmount > 0, "UsdtConvertYeed: buy YEED error");

        usdtToken.transferFrom(msg.sender, address(this), _amount);

        UserInfo memory userinfo = userinfoMap[msg.sender];
        userinfo.yeedConvertAmount += _yeedAmount;
        userinfoMap[msg.sender] = userinfo;
        addressFrequency[msg.sender] += 1;
        usdtConverAmount -= _yeedAmount;

        Order memory _order = Order(msg.sender, 1, _yeedAmount, usdtConverRatio, _usdtAddress);
        orders.push(_order);
    }

    
    function withdraw () public {
        UserInfo memory userinfo = userinfoMap[msg.sender];
        uint256 _releaseAmount = getReleaseAmount(msg.sender);
        uint256 _amount = getReleaseAmount(msg.sender) - userinfo.received;
        require(openWithdraw && _amount > 0, "withdraw error");

        userinfo.received = _releaseAmount;
        userinfoMap[msg.sender] = userinfo;

        yeedToken.transfer(msg.sender, _amount);
    }

    
    event SetWhitelist(address indexed user, address[] _account, uint256[] _amount);
    function setWhitelist(address[] memory _account, uint256[] memory _amount) public onlyOwner {
        for (uint256 i = 0; i < _account.length; i++) {
            address _address = _account[i];
            UserInfo memory user = userinfoMap[_address];
            user.whitelistAmount = (_amount[i]);
            userinfoMap[_address] = user;
        }

        emit SetWhitelist(msg.sender, _account, _amount);
    }

    
    function OpenWhitelistConvert(bool _open) public onlyOwner {
        openWhitelistConvert = _open;
    }

    
    function OpenConver (bool _open) public onlyOwner {
        openConver = _open;
    }

    
    function activate(uint256 _timestamp) public onlyOwner {
        timestamp = _timestamp;
        openWithdraw = true;
    }

    
    function getRelsase () public view returns(uint256 _release) {
        _release = (block.timestamp - timestamp) / 30 days;
        if (openWithdraw == false) {
            return 0;
        }

        if (_release > releaseAll) {
            _release = releaseAll;
        }
    }

    
    function getReleaseAmount(address _address) public view returns(uint256) {
        UserInfo memory userinfo = userinfoMap[_address];
        if (userinfo.yeedConvertAmount == 0 || openWithdraw == false) {
            return 0;
        }

        uint256 _release = getRelsase() >= releaseAll ? releaseAll:getRelsase();

        return (userinfo.yeedConvertAmount * _release) / releaseAll;
    }

    
    function whitelistWithdraw () public {
        UserInfo memory userinfo = userinfoMap[msg.sender];
        uint256 _releaseAmount = getWhitelistReleaseAmount(msg.sender);
        uint256 _amount = getWhitelistReleaseAmount(msg.sender) - userinfo.whitelistReceived;
        require(openWhitelistReceived && _amount > 0, "withdraw error");

        userinfo.whitelistReceived = _releaseAmount;
        userinfoMap[msg.sender] = userinfo;

        yeedToken.transfer(msg.sender, _amount);
    }

    
    function openWhitelist(uint256 _whitelistTimestamp) public {
        whitelistTimestamp = _whitelistTimestamp;
        openWhitelistReceived = true;
    }

    
    function getWhitelistReleaseAmount(address _address) public view returns(uint256) {
        UserInfo memory userinfo = userinfoMap[_address];
        if (userinfo.whitelistYeedConvert == 0 || openWhitelistReceived == false) {
            return 0;
        }

        uint256 _release = getWhitelistTimestamp() >= releaseAll ? releaseAll : getWhitelistTimestamp();

        return (userinfo.whitelistYeedConvert * _release) / releaseAll;
    }

    
    function getWhitelistTimestamp () public view returns(uint256 _release) {
        _release = (block.timestamp - whitelistTimestamp) / 30 days;
        if (openWhitelistReceived == false) {
            return 0;
        }

        if (_release > releaseAll) {
            _release = releaseAll;
        }
    }

    function getUserInfo (address _address) public view returns(
        uint256 _yeedConvertAmount, 
        uint256 _received, 
        uint256 _releaseAmount, 
        uint256 _whitelistReceived, 
        uint256 _whitelistYeedConvert,
        uint256 _whitelistAmount) {
        UserInfo memory userinfo = userinfoMap[_address];
        _yeedConvertAmount = userinfo.yeedConvertAmount;
        _received = userinfo.received;
        _releaseAmount = getReleaseAmount(_address);
        _whitelistAmount = userinfo.whitelistAmount;
        _whitelistYeedConvert = userinfo.whitelistYeedConvert;
        _whitelistReceived = userinfo.whitelistReceived;
    }

    
    function setFrequency (uint32 _frequency) public onlyOwner {
        frequency = _frequency;
    }

    
    function transferToken(address _address) public onlyOwner {
        usdtToken.transfer(_address, usdtToken.balanceOf(address(this)));
        zeedToken.transfer(_address, zeedToken.balanceOf(address(this)));
        hoToken.transfer(_address, hoToken.balanceOf(address(this)));
        yeedToken.transfer(_address, yeedToken.balanceOf(address(this)));
    }

    function setTokenAddress(IERC20 _yeedToken) public onlyOwner {
        yeedToken = _yeedToken;
    }
}