/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

//FilterSwap V1: filterswap.exchange

pragma solidity ^0.8;

contract SieveToken {
    string public name = "Sieve Token";
    string public symbol = "SIEVE";
    uint public totalSupply = 1000000;
    uint8 public decimals = 18;

    address private owner;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor() {
        owner = msg.sender;
        totalSupply = totalSupply * (10 ** decimals);

        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, balanceOf[owner]);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}