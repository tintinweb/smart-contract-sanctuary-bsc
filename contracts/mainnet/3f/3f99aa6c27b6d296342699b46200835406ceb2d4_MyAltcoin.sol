/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyAltcoin {

    bool private locked = false;

    modifier nonReentrant() {
        require(!locked, "Reentrant call.");
        locked = true;
        _;
        locked = false;
    }
 
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public maxSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    address taxaccount = 0xeffa50cf7225EB218D3dF872156b69066b0cFbEA; 
    address ownerAccount = 0x073aB83DEF8b5629a4218AFB01Fc144240ECa4f0; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Debug(address indexed sender, address indexed receiver);

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, uint256 _maxSupply) {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0, "Name and symbol cannot be empty.");
        require(_totalSupply > 0, "Supply must not be under 0");
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        maxSupply = _maxSupply;
        balances[ownerAccount] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) nonReentrant public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(_value <= balances[msg.sender], "Insufficient balance");

        uint256 fee = (_value * 5) / 100; 
        uint256 valueAfterFee = _value - fee;
        balances[msg.sender] -= _value; 
        balances[_to] += valueAfterFee; 
        balances[taxaccount] += fee; 

        emit Transfer(msg.sender, _to, valueAfterFee); 
        emit Transfer(msg.sender, taxaccount, fee); 

        return true;
    }

    function approve(address _spender, uint256 _value) nonReentrant public returns (bool) {

        require(_spender != address(0), "Invalid address");

        uint256 ownerBalance = balances[msg.sender];

        require(ownerBalance >= _value, "Insufficient balance to approve");

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) nonReentrant public returns (bool) {

        require(_from != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        require(_value <= balances[_from], "Insufficient balance");
        require(_value <= allowances[_from][msg.sender], "Insufficient allowance");

        uint256 fee = (_value * 5) / 100; 
        uint256 valueAfterFee = _value - fee; 
        balances[_from] -= _value; 
        balances[_to] += valueAfterFee; 
        balances[taxaccount] += fee;
        allowances[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);

        return true;
    } 
    function burn(uint256 _value) nonReentrant public returns (bool) {
        require(_value <= balances[msg.sender], "Insufficient balance");
        require(_value > 0, "Value must be greater than 0");

        balances[msg.sender] -= _value;
        totalSupply -= _value;

        emit Transfer(msg.sender, address(0), _value);
        return true;
    }
    function mint(address _to, uint256 _value) public nonReentrant{
        require(msg.sender == ownerAccount, "Only the owner can mint tokens");
        require(_to != address(0), "Invalid address");
        require(totalSupply + _value <= maxSupply, "Exceeds max supply");

        totalSupply += _value;
        balances[_to] += _value;
        
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);

    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }
    fallback () external payable {
        revert();
    }

    receive() external payable {
        revert();
    }
}