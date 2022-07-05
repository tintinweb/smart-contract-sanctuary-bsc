/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

pragma solidity ^0.8.0;

contract Kuma {
    string public constant name = 'Kuma Token';
    string public constant symbol = 'KUM';

    uint256 _totalSupply = 10000000000000000;
    uint256 _currentSupply = 0;
    uint256 public constant RATE = 10000;
    uint256 public constant decimals = 8;
    address public owner;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;


    receive() external payable {
        createTokens(msg.sender);
    }

    constructor() {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }

    function createTokens(address addr) public payable {
        require(msg.value > 0);
        uint256 tokens = msg.value * RATE * (10 ** decimals) / (1 ether);

        require(tokens + _currentSupply <= _totalSupply);
        balances[owner] = balances[owner] - tokens;
        balances[addr] = balances[addr] + tokens;
        emit Transfer(owner, addr, tokens);

        payable(owner).transfer(msg.value);
        _currentSupply = _currentSupply + tokens;

    }

    function totalSupply() public view returns (uint256 supply) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(
            balances[msg.sender] >= _value
            && _value > 0
        );
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(
            balances[_from] >= _value
            && allowed[_from][msg.sender] >= _value
            && _value > 0
        );
        balances[_from] = balances[_from] - _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(_from, _to, _value);
        return true;

    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}