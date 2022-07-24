/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

/*>>>>>>>>>>>>>>>>>>>Welcome to Destiny.<<<<<<<<<<<<<<<<<<<*/
pragma solidity ^0.4.21;

contract DestinyTokenInterface {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
/*>>>>>>>>>>>>>>>>>>Destiny Token is Destiny governance token.<<<<<<<<<<<<<<<<<<*/
contract DestinyToken is DestinyTokenInterface {
    /*>>>>>>>>>>>>>>>>>HOLLE　WORLD<<<<<<<<<<<<<<<<<*/
    uint256 constant private MAX_UINT256 = 2**256 - 1;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    string public name="Destiny Token";

    uint8 public decimals=2;

    string public symbol="DST";

    uint256 public _initialAmount=21000000000;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    /*>>>>>>>>>>>>>>>>>GOOD LUCK<<<<<<<<<<<<<<<<<*/
}
/*>>>>>>>>>>>>>>>>>>>The destiny defined by the God of Destiny, also called destiny? Hold the Destiny Token and define your own destiny !<<<<<<<<<<<<<<<<<<<*/