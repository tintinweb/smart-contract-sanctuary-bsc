/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IMarketManager{
    struct ManagerData{
        uint256 expiredTime;
        bool _isExists;
    }
    event OwnershipTransferred(address indexed oldOwner,address indexed newOwner);
    event RechargeLog(address indexed _address, IERC20 _token, uint256 _amount);
    event WithdrawLog( address indexed _address,IERC20 _token, uint256 _amount );
    function addManager(address _address,uint256 _day) external returns (bool);
    function addBlackUser(address _address) external returns(bool);
    function removeBlackUser(address _address) external returns(bool);
    function searchOneDay() external view returns(uint256 _price);
    function buyDays(uint256 _day) external;
    function searchOneMonth() external view returns(uint256 _price);
    function buyMonths(uint256 _month)external;
    function searchOneYear()external view returns(uint256 _price);
    function buyYears(uint256 _years) external;
    function getExpiredTime(address _address) external view returns(uint256 _blockTime,uint256 _expiredTime);
    function setPayToken(IERC20 _payToken) external returns(bool);
    function setOneDayCount(uint256 _oneDayPrice) external returns(bool);
    function setGitAddress( string memory _gitAddress ) external returns(bool);
    function setEmail(string memory _newEmail) external returns(bool);
    function transferOwnership(address account_)  external  returns(bool);
    function getLastBlockNumber() external view returns(uint256);
    function getMontyRatio() external view returns( uint256 _ratio,uint256 _decimals );
    function getYearRatio() external view returns( uint256 _ratio, uint256 _decimals);
    function withdraw(uint256 amount) external;
    function withdrawToken(IERC20 __token, uint256 amount) external;
}

contract MarketManager is IMarketManager{
    address public _owner;
    mapping(address => ManagerData) public _ManagerMap;
    mapping (address => bool) public isBlacklist;
    IERC20 public payToken = IERC20(0x7BD9987A65A5f759459B4B00589Da1056AF68248);//IERC20(0x55d398326f99059fF775485246999027B3197955)
    string public gitAddress = "[email protected]:test/test.git";
    uint256 public decimals = 18;
    uint256 public oneDayPrice = 5;
    string public email = "[email protected]";
    uint256 public totalRatio = 10000;
    uint256 public montyRatio = 9500;
    uint256 public yearRatio = 8500;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier notInBlack(){
        require( !isBlacklist[msg.sender], "in blacklist");
        _;
    }

    constructor(){
        _owner = msg.sender;
        _ManagerMap[msg.sender]._isExists = true;
        _ManagerMap[msg.sender].expiredTime = uint256(32503564800);
    }

    function addManager(address _address,uint256 _day)
        external
        onlyOwner
        returns(bool)
    {
        if( _ManagerMap[_address]._isExists ){
            _ManagerMap[_address].expiredTime += _day * 24 * 3600;
        }else{
            _ManagerMap[_address].expiredTime = block.timestamp + _day * 24 * 3600;
            _ManagerMap[_address]._isExists = true;
        }
        return true;
    }

    function addBlackUser(address _address)
        external
        onlyOwner
        returns(bool)
    {
        if( !isBlacklist[_address] ){
            isBlacklist[_address] = true;
        }
        return true;
    }

    function removeBlackUser(address _address)
        external
        onlyOwner
        returns(bool)
    {
        if( isBlacklist[_address] ){
            isBlacklist[_address] = false;
        }
        return true;
    }

    function searchOneDay()
        external
        view
        returns(uint256 _price)
    {
        IERC20 token = IERC20(payToken);
        _price = oneDayPrice * 10 ** token.decimals();
    }

    function buyDays(uint256 _day)
        external
        notInBlack
    {
        IERC20 token = IERC20(payToken);
        uint256 amount = oneDayPrice * _day * 10 ** token.decimals();
        uint256 period =  _day * 24 * 3600;
        buyMethod(amount, period);
    }

    function searchOneMonth()
        external
        view
        returns(uint256 _price)
    {
        IERC20 token = IERC20(payToken);
        _price = oneDayPrice * 30 * 10 ** token.decimals() * montyRatio / totalRatio;
    }

    function buyMonths(uint256 _month)
        external
        notInBlack
    {
        IERC20 token = IERC20(payToken);
        uint256 amount = oneDayPrice * _month * 30 * 10 ** token.decimals() * montyRatio / totalRatio;
        uint256 period =  _month * 30 * 24 * 3600;
        buyMethod(amount, period);
    }

    function searchOneYear()
        external
        view
        returns(uint256 _price)
    {
        IERC20 token = IERC20(payToken);
        _price = oneDayPrice * 365 * 10 ** token.decimals() * yearRatio / totalRatio;
    }

    function buyMethod(uint256 amount, uint256 period)
        internal
    {
        IERC20 token = IERC20(payToken);
        address _sender = msg.sender;
        token.transferFrom(_sender, address(this), amount );
        emit RechargeLog(msg.sender, token, amount);
        if( _ManagerMap[_sender]._isExists ){
            _ManagerMap[_sender].expiredTime + period;
        }else{
            _ManagerMap[_sender].expiredTime = block.timestamp + period;
            _ManagerMap[_sender]._isExists = true;
        }
    }

    function buyYears(uint256 _years)
        external
        notInBlack
    {
        IERC20 token = IERC20(payToken);
        uint256 amount = oneDayPrice * _years * 365 * 10 ** token.decimals() * yearRatio / totalRatio;
        uint256 period =  _years * 365 * 24 * 3600;
        buyMethod(amount, period);
    }

    function getExpiredTime(address _address)
        external
        view
        returns(uint256 _blockTime,uint256 _expiredTime)
    {
        if( isBlacklist[_address] ){
            _blockTime = block.timestamp; 
            _expiredTime = _blockTime - 1;
        }else{
            if( _ManagerMap[_address]._isExists ){
                _blockTime = block.timestamp; 
                _expiredTime = _ManagerMap[_address].expiredTime;
            }else{
                _blockTime = block.timestamp; 
                _expiredTime = _blockTime - 1;
            }
        }
    }

    function setPayToken(IERC20 _payToken)
        external
        onlyOwner
        returns(bool)
    {
        payToken = _payToken;
        return true;
    }

    function setOneDayCount(uint256 _oneDayPrice)
        external
        onlyOwner
        returns(bool)
    {
        oneDayPrice = _oneDayPrice;
        return true;
    }

    function setGitAddress( string memory _gitAddress )
        external
        onlyOwner
        returns(bool)
    {
        gitAddress = _gitAddress;
        return true;
    }

    function setEmail(string memory _newEmail)
        external
        onlyOwner
        returns(bool)
    {
        email = _newEmail;
        return true;
    }

    function transferOwnership(address account_) 
        external 
        onlyOwner
        returns(bool)
    {
        emit OwnershipTransferred(_owner, account_);
        _owner = account_;
        return true;
    }

    function getLastBlockNumber()
        external
        view
        returns(uint256)
    {
        return block.number;
    }

    function setMontyRatio(uint256 _montyRatio)
        external
        onlyOwner
        returns(bool)
    {
        montyRatio = _montyRatio;
        return true;
    }

    function setYearRatio(uint256 _yearRatio)
        external
        onlyOwner
        returns(bool)
    {
        yearRatio = _yearRatio;
        return true;
    }

    function withdraw(uint256 amount) 
        external
        onlyOwner
    {
        payable(msg.sender).transfer(amount);
    }

    function getMontyRatio()
        external
        view
        returns( uint256 _ratio,uint256 _decimals )
    {
        _ratio = 10 ** decimals * montyRatio / totalRatio;
        _decimals = decimals;
    }

    function getYearRatio()
        external
        view
        returns( uint256 _ratio, uint256 _decimals)
    {
        _ratio = 10 ** decimals * yearRatio / totalRatio;
        _decimals = decimals;
    }

    function withdrawToken(IERC20 __token, uint256 amount)
        external
        onlyOwner
    {
        IERC20(__token).transfer(msg.sender, amount);
        emit WithdrawLog( msg.sender, IERC20(__token), amount );
    }

}