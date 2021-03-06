// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 <0.9.0;

interface StakingMP {
    function getUserTotalInvestedTarif(address userAddress, uint256 id) external view returns(uint256);
}

import "./IERC20.sol";
import "./SafeMath.sol";

contract SaleWL {
    using SafeMath for uint256;

    uint256 private _START_TIME;
    uint256 private _SALE_DAYS;
    uint256 private _RATE;
    uint256 private _minBUSD;
    uint256 private _maxBusdUser;
    uint256 private _forSale;
    uint256 private _divider;
    bool private _status;
    address private _owner;
    address private _token;
    uint256 private _totalSold;
    IERC20 constant private busd = IERC20(0x192Ca0E2E677a3846b8223656d21D1ec55547F3f);// Token BUSD

    struct Limit {
        uint256 timestamp;
        uint256 percent;
    }

    Limit[] public limits;

    constructor(
        uint256 start_time,
        uint256 sale_days,
        uint256 rate,
        uint256 minBUSD,
        uint256 maxBusdUser,
        uint256 forSale,
        bool status,
        address owner,
        uint256 divider){
            _START_TIME = start_time;
            _SALE_DAYS = sale_days;
            _RATE = rate;
            _minBUSD = minBUSD.mul(10 ** 18);
            _maxBusdUser = maxBusdUser.mul(10 ** 18);
            _forSale = forSale.mul(10 ** 18);
            _status = status;
            _owner = owner;
            _divider = divider;
    }

    mapping(address => bool) private _whiteList;
    mapping(address => uint256) balances;
    mapping(address => uint256) invested;
    mapping(address => uint256) private tw;

    function invest(uint256 _amount) public {
        require(block.timestamp >= _START_TIME,"Expect the start");
        require(block.timestamp <= _START_TIME.add(_SALE_DAYS),"Sale ended");
        require(_status == true,"Sale ended");
        require(_token != address(0),"Token not specified");
        require(_whiteList[msg.sender] == true,"Your address is not in the whitelist");
        require(getLeftToken() >= _minBUSD.div(_RATE).mul(_divider),"Sale ended");
        require(busd.balanceOf(msg.sender) >= _amount,"You do not have the required amount");
        require(_amount >= _minBUSD,"Minimum amount limitation");
        require(_amount.add(invested[msg.sender]) <= _maxBusdUser,"Maximum amount limitation");
        uint256 tokens = _amount.div(_RATE).mul(_divider);
        require(getLeftToken() >= tokens,"No tokens left");
        uint256 allowance = busd.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        require(busd.transferFrom(msg.sender, address(this),_amount),"Error transferFrom");
        balances[msg.sender] = balances[msg.sender].add(tokens);
        invested[msg.sender] = invested[msg.sender].add(_amount);
        _totalSold = _totalSold.add(tokens);
    }

    function withdrawingUserTokens() public {
        require(block.timestamp >= _START_TIME.add(_SALE_DAYS) || getLeftToken() < _minBUSD.div(_RATE).mul(_divider) || _status == false,"Expect the end of the sell");
        require(_token != address(0),"Token not specified");
        require(getUserWithdrawNow(msg.sender) > 0, "You have not tokens");
        require(getContractBalanceToken() >= getUserWithdrawNow(msg.sender), "Not enough tokens");
        IERC20 token = IERC20(_token);// Token
        require(token.transfer(msg.sender, getUserWithdrawNow(msg.sender)));
        tw[msg.sender] = block.timestamp;
    }

    function withdrawingOwnerBusd() public {
        require(msg.sender == _owner);
        busd.transfer(msg.sender, busd.balanceOf(address(this)));
    }

    function withdrawingOwnerTokens() public {
        require(msg.sender == _owner);
        require(_token != address(0),"Token not specified");
        IERC20 token = IERC20(_token);// Token
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function getUserWithdrawNow(address userAddress) public view returns(uint256) {
        uint256 percent;
        for(uint256 i=0;i<limits.length;i++){
            if(limits[i].timestamp <= block.timestamp){
                if(limits[i].timestamp > tw[userAddress]){
                    percent = percent.add(limits[i].percent);
                }
            }
        }
        return balances[userAddress].mul(percent).div(100);
    }

    function getNextWithdrawalDate() public view returns(uint256) {
        uint256 timestamp;
        for(uint256 i=0;i<limits.length;i++){
            if(limits[i].timestamp <= block.timestamp){
                timestamp = limits[i].timestamp;
                break;
            }
        }
		return timestamp;
	}

    function getListWithdrawalDate() public view returns(Limit[] memory) {
		return limits;
	}

    function getUserTotalInvested(address userAddress) public view returns(uint256) {
		return invested[userAddress];
	}

    function getUserTokens(address userAddress) public view returns(uint256) {
		return balances[userAddress];
	}

    function getContractBalanceToken() public view returns (uint256) {
        require(_token != address(0),"Token not specified");
        IERC20 token = IERC20(_token);// Token
		return token.balanceOf(address(this));
	}

    function getContractBalanceBusd() public view returns (uint256) {
		return busd.balanceOf(address(this));
	}

    function getLeftToken() public view returns (uint256) {
        return _forSale.sub(_totalSold);
    }

    function getStartTime() public view returns (uint256) {
        return _START_TIME;
    }

    function getSaleDays() public view returns (uint256) {
        return _SALE_DAYS;
    }

    function getRate() public view returns (uint256) {
        return _RATE;
    }

    function getDivider() public view returns (uint256) {
        return _divider;
    }

    function getMinBusd() public view returns (uint256) {
        return _minBUSD;
    }

    function getMaxBusdUser() public view returns (uint256) {
        return _maxBusdUser;
    }

    function getForSale() public view returns (uint256) {
        return _forSale;
    }

    function getStatus() public view returns (bool) {
        return _status;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getToken() public view returns (address) {
        return _token;
    }

    function getTotalSold() public view returns (uint256) {
        return _totalSold;
    }

    function setStartTime(uint256 _x) public {
        require(msg.sender == _owner);
        _START_TIME = _x;
    }

    function setSaleDays(uint256 _x) public {
        require(msg.sender == _owner);
        _SALE_DAYS = _x;
    }

    function setRate(uint256 _x) public {
        require(msg.sender == _owner);
        _RATE = _x;
    }

    function setDivider(uint256 _x) public {
        require(msg.sender == _owner);
        _divider = _x;
    }

    function setMinBusd(uint256 _x) public {
        require(msg.sender == _owner);
        _minBUSD = _x.mul(10 ** 18);
    }

    function setMaxBusdUser(uint256 _x) public {
        require(msg.sender == _owner);
        _maxBusdUser = _x.mul(10 ** 18);
    }

    function setForSale(uint256 _x) public {
        require(msg.sender == _owner);
        _forSale = _x.mul(10 ** 18);
    }

    function setTotalSold(uint256 _x) public {
        require(msg.sender == _owner);
        _totalSold = _x.mul(10 ** 18);
    }

    function setStatus(bool _x) public {
        require(msg.sender == _owner);
        _status = _x;
    }

    function setOwner(address _x) public {
        require(msg.sender == _owner);
        _owner = _x;
    }

    function setToken(address _x) public {
        require(msg.sender == _owner);
        _token = _x;
    }

    function insertListAddresses(address[] memory _listAddresses) public {
        require(msg.sender == _owner);
        for(uint i = 0; i < _listAddresses.length; i++) {
            address addr = _listAddresses[i];
            if(_whiteList[addr] != true){
                _whiteList[addr] = true;
            }
        }
    }

    function insertAddress(address _address) public {
        require(msg.sender == _owner);
        require(_whiteList[_address] != true,"Address exists");
        _whiteList[_address] = true;
    }

    function existsAddress(address _address) public view returns(bool){
        if(_whiteList[_address] == true){
            return true;
        }else{
            return false;
        }
    }

    function setLimits(uint256 _timestamp,uint256 _percent) public {
        require(msg.sender == _owner);
        limits.push(Limit({timestamp: _timestamp,percent: _percent}));
    }
}