pragma solidity ^0.8.0;

contract Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address payable public owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        uint256 _initialSupply = 1000000000;

        owner = payable(msg.sender);
        balanceOf[owner] = _initialSupply;
        totalSupply = _initialSupply; 
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transer(address _to, uint256 _value) public returns(bool) {
        uint256 toBalance = balanceOf[_to];
        uint256 fromBalance = balanceOf[msg.sender];

        require(fromBalance>=_value, "insufficient funds!");
        require(_to != address(0));
        require(_value>0, "_value must be greater than 0");

        balanceOf[msg.sender] = fromBalance - _value;
        balanceOf[_to] = toBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transerFrom(address _from, address _to, uint256 _value) public returns(bool) {
        uint256 senderBalance = balanceOf[_from];
        uint256 receiverBalance = balanceOf[_to];
        uint256 _approve = allowance[_from][_to];
        require(_to != address(0));
        require(_value>0, "_value must be greater than 0");
        require(_approve >= _value, "must be approved before transfer");
        require(senderBalance >= _value, "insufficient funds!");

        balanceOf[_to] = receiverBalance + _value;
        balanceOf[_from] = senderBalance - _value;
        allowance[_from][_to] = _approve - _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        require(_value>0, "_value must be greater than 0");
        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true; 
    }

    function mint(uint256 _amount) public returns(bool) {
        require(msg.sender == owner, "you are not the founder");
        totalSupply += _amount;
        balanceOf[owner] += _amount;
        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
}