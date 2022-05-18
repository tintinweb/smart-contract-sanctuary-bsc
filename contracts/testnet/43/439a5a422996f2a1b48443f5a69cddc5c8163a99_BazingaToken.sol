/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract BazingaToken {
 
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply; 
    address payable public owner; 

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "Bazinga"; 
        symbol = "BAZ";
        decimals = 18; 
        uint256 _initialSupply = 10000000000000000000; 

        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; 
        totalSupply = _initialSupply; 

        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        
        require(allowance[sender][msg.sender] > amount, "ERC20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowance[sender][msg.sender] - amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool success) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[owner] += _amount;

        emit Transfer(address(0), owner, _amount);
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(amount >= 0, "ERC20: Amount must be greater or equal to 0");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[sender] > amount, "ERC20: sender balance does not exceed transfer amount");

        balanceOf[sender] = balanceOf[sender] - amount;
        balanceOf[recipient] = balanceOf[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address _owner, address spender, uint256 amount) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(amount >= 0, "ERC20: Amount must be greater or equal to 0");

        allowance[_owner][spender] = amount;
        emit Approve(_owner, spender, amount);
    }
}