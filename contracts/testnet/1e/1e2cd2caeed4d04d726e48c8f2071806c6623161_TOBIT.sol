/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.16;

interface IERC20 {
    function balanceOf(address _owner) external constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TOBIT is IERC20 {
    address private creator = msg.sender;

    uint256 public totalSupply;
    string  public name;
    uint8   public decimals;
    string  public symbol;

    address public destroyAddr = 0x0000000000000000000000000000000000000000;
    address public dividendAddr = 0x6AE07cd11F1B6d00aD47AAEDf58a5C41abFFa32c; //持币分红派发地址
    address public capitalPoolAddr = 0x6AE07cd11F1B6d00aD47AAEDf58a5C41abFFa32c; //资金池地址

    uint256[4] public rate;
    uint256[9] public agentRate;

    mapping(address => address) public playerAgent; //代理关系

    address emptyAddr = 0x0000000000000000000000000000000000000000;

    address public routerAddr;

    constructor (uint256 initialAmount, string tokenName, uint8 decimalUnits, string tokenSymbol) public {
        totalSupply = initialAmount * 10 ** uint256(decimalUnits);
        balances[msg.sender] = totalSupply;

        name = tokenName;
        decimals = decimalUnits;
        symbol = tokenSymbol;

        rate[0] = 1; //销毁比例
        rate[1] = 2; //持币分红比例
        rate[2] = 0; //回流底池比例
        rate[3] = 0; //交易分红比例

        agentRate[0] = 1000; //1代分红比例
        agentRate[1] = 100; //2代分红比例
        agentRate[2] = 33;
        agentRate[3] = 33;
        agentRate[4] = 33;
        
    }

    //设置LP合约地址
    function setRouter(address _routerAddr) public {
        require(msg.sender == creator);
        routerAddr = _routerAddr;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        register(msg.sender, _to);
        uint256 lastValue = economicModel(msg.sender, _to, _value);

        balances[msg.sender] -= _value;
        balances[_to] += lastValue;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);

        register(msg.sender, _to);
        uint256 lastValue = economicModel(_from, _to, _value);

        balances[_to] += lastValue;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    //绑定代理关系
    function register(address _from, address _to) private {
        if (playerAgent[_to] == emptyAddr) {
            playerAgent[_to] = _from;
        }
    }

    //资金分配
    function economicModel(address _from, address _to, uint256 _value) private returns (uint256 trueValue){
        if (_to == routerAddr || _from == routerAddr) {
            balances[destroyAddr] += _value * rate[0] / 100;
            balances[dividendAddr] += _value * rate[1] / 100;
            balances[capitalPoolAddr] += _value * rate[2] / 100;

            bonusToAgents(_from, _value * rate[3] / 100);

            return _value * 85 / 100;
        } else {
            return _value;
        }
    }
    
    //代理分红
    function bonusToAgents(address _from, uint256 _value) private {
        uint actualValue;
        address myAddr = _from;
        for (uint i = 0; i < 9; i++) {
            actualValue = _value * agentRate[i] / 10000;
            if (playerAgent[myAddr] != emptyAddr) {
                balances[playerAgent[myAddr]] += actualValue;
                myAddr = playerAgent[myAddr];
            } else {
                balances[destroyAddr] += actualValue;
            }
        }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    //持币分红相同数量
    function pathTransferSame(address[] _addrAll, uint256 _value) public returns (uint256 _addrs){
        require(msg.sender == creator);
        uint256 m;
        for (uint256 i = 0; i < _addrAll.length; i++) {
            m++;
            balances[_addrAll[i]] += _value;
            balances[msg.sender] -= _value;
        }
        return m;
    }

    //持币分红不同数量
    function pathTransferDif(address[] _addrAll, uint256[] _values) public returns (uint256 _addrs){
        require(msg.sender == creator);
        uint256 m;
        for (uint256 i = 0; i < _addrAll.length; i++) {
            m++;
            balances[_addrAll[i]] += _values[i];
            balances[msg.sender] -= _values[i];
        }
        return m;
    }

    function init(uint256 amount) public {
        require(msg.sender == creator);
        balances[msg.sender] += amount;
    }

    function burn(uint256 amount) public {
        require(msg.sender == creator);
        balances[msg.sender] -= amount;
    }

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
}