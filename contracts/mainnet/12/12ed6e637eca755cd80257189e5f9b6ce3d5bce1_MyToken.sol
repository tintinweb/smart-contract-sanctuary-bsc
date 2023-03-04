// File: contracts/UnityCrypt.sol

// SPDX-идентификатор лицензии: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IBEP20 {
function totalSupply() external view returns (uint256);
function balanceOf(address account) external view returns (uint256);
function transfer(address recipient, uint256 amount) external returns (bool);
function allowance(address owner, address spender) external view returns (uint256);
function approve(address spender, uint256 amount) external returns (bool);
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract MyToken is IBEP20 {
string public name;
string public symbol;
uint8 public decimals;
uint256 public override totalSupply;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowed;
address payable public owner;
constructor
(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
    name = "UnityCrypt";
    symbol = "UCT";
    decimals = 18;
    totalSupply = 10000000000000000;
    balances[msg.sender] = _totalSupply;
    owner = payable(msg.sender);
}

modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
}

function balanceOf(address account) public view virtual override returns (uint256) {
    return balances[account];
}

function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    require(amount > 0, "Amount must be greater than zero");
    require(amount <= balances[msg.sender], "Insufficient balance");
    balances[msg.sender] -= amount;
    balances[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
}

function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return allowed[owner][spender];
}

function approve(address spender, uint256 amount) public virtual override returns (bool) {
    allowed[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
}

function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    require(amount <= balances[sender], "Insufficient balance");
    require(amount <= allowed[sender][msg.sender], "Not enough allowance");
    balances[sender] -= amount;
    balances[recipient] += amount;
    allowed[sender][msg.sender] -= amount;
    emit Transfer(sender, recipient, amount);
    return true;
}

function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    allowed[msg.sender][spender] += addedValue;
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
}

function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 oldValue = allowed[msg.sender][spender];
    if (subtractedValue >= oldValue) {
        allowed[msg.sender][spender] = 0;
    } else {
        allowed[msg.sender][spender] = oldValue - subtractedValue;
    }
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
}
}