/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19;

contract TestToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    function requireSufficientBalance(address from, uint256 value) private view {
        require(balanceOf[from] >= value, "Insufficient balance");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier nonReentrant() {
        require(!_locked, "Reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    modifier checkBalanceAndAllowance(address from, address spender, uint256 value) {
        requireSufficientBalance(from, value);
        require(allowance[from][spender] >= value, "Not enough allowance");
        _;
    }

    bool private _locked;

    constructor(string memory _name, string memory _symbol, address _owner, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = _owner;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) external nonReentrant returns (bool) {
        requireSufficientBalance(msg.sender, value);
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }


    function transferFrom(address from, address to, uint256 value) external nonReentrant checkBalanceAndAllowance(from, msg.sender, value) returns (bool) {
        requireSufficientBalance(from, value);
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) external nonReentrant returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _mint(address account, uint256 value) private {
        balanceOf[account] += value;
        totalSupply += value;
        emit Transfer(address(0), account, value);
    }

    function mint(address account, uint256 value) external onlyOwner nonReentrant {
        _mint(account, value);
    }

    function _burn(address account, uint256 value) private {
        require(account != address(0), "Cannot burn from the zero address");
        require(balanceOf[account] >= value, "Insufficient balance");
        balanceOf[account] -= value;
        totalSupply -= value;
        emit Burn(account, value);
        emit Transfer(account, address(0), value);
    }

    function burn(uint256 value) external nonReentrant {
        _burn(msg.sender, value);
    }
    
    function burnFrom(address account, uint256 value) external nonReentrant onlyOwner {
        _burn(account, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) external nonReentrant returns (bool) {
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external nonReentrant returns (bool) {
        allowance[msg.sender][spender] -= subtractedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event OwnershipTransferred(address oldOwner, address newOwner);
}