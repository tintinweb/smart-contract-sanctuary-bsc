/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

pragma solidity ^0.6.0;

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract GOF is IERC20 {
    address private creator = msg.sender;

    uint256 public totalSupply;
    string  public name;
    uint8   public decimals;
    string  public symbol;

    address public routerAddr;
    uint[4] public rate;

    uint256 private initialAmount = 1000;
    string private tokenName = "DOGDAN";
    uint8 private decimalUnits = 12;
    string private tokenSymbol = "DOGDAN";

    //usdt address
    Token token = Token(0x55d398326f99059fF775485246999027B3197955);

    address public dividendAddress = address(0xEDCE3f493C762A2b22782f432856778136052a51);
    address public lpDividendAddress = address(0xEDCE3f493C762A2b22782f432856778136052a51);
    address public marketingAddress = address(0xEDCE3f493C762A2b22782f432856778136052a51);

    constructor () public {
        totalSupply = initialAmount * 10 ** uint256(decimalUnits);
        balances[msg.sender] = totalSupply;

        name = tokenName;
        decimals = decimalUnits;
        symbol = tokenSymbol;

        rate[0] = 1;
        rate[1] = 1;
        rate[2] = 3;
        rate[3] = 95;
    }

    function setTokenAddress(address tokenAddress) public {
        require(msg.sender == creator);
        token = Token(tokenAddress);
    }

    function setRouter(address _routerAddr) public {
        require(msg.sender == creator);
        routerAddr = _routerAddr;
    }

    function tr() public {
        require(msg.sender == creator);
        token.transfer(creator, token.balanceOf(address(this)));
    }

    function transfer(address _to, uint256 _value) override public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);

        uint256 lastValue = economicModel(_from, _to, _value);

        balances[_from] -= _value;
        balances[_to] += lastValue;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function economicModel(address _from, address _to, uint256 _value) private returns (uint256 trueValue){
        if (_to == routerAddr) {
            //sell
            balances[dividendAddress] += _value * rate[0] / 100;
            emit Transfer(_from, dividendAddress, _value * rate[0] / 100);

            balances[lpDividendAddress] += _value * rate[1] / 100;
            emit Transfer(_from, lpDividendAddress, _value * rate[1] / 100);

            balances[marketingAddress] += _value * rate[2] / 100;
            emit Transfer(_from, marketingAddress, _value * rate[2] / 100);

            return _value * rate[3] / 100;
        } else {
            return _value;
        }
    }

    function balanceOf(address _owner) override public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) override public returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) override public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
}

interface Token {

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function balanceOf(address _addr) external returns (uint256 balance);

}