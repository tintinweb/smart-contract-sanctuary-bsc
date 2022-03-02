/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

pragma solidity >= 0.7.0 < 0.9.0;

contract BToken{
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals;

    constructor (string memory _name, string memory _symbol, uint256 _totalSupply, uint8 _decimals)  {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
        balanceOf[msg.sender] = totalSupply;
    }

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint indexed value
    );

  

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

  function approve(address spender, uint256 _value) public returns(bool success){
        allowance[msg.sender][spender] = _value;
        emit Approval(msg.sender, spender, _value);
        return true;
    }
    function transfer(address _to, uint256 _value) public returns(bool success){
        require(balanceOf[msg.sender] >= _value );
        // Transfer the amount and substract the balance
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender , _to , _value);
        return true;
    }
function transferFrom(address _from, address _to, uint _value) public returns(bool success){
    require(balanceOf[_from] >= _value);
    require(allowance[_from][msg.sender] >= _value);

    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    allowance[_from][msg.sender] -= _value;
    
    return true;

}

}