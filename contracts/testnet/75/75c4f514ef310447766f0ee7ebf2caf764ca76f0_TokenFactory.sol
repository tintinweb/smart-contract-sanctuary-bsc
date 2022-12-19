/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ERC20 {
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _maxSupply;

  string private _name;
  string private _symbol;

  event Mint(address indexed to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 maxSupply_
  ) {
    _name = name_;
    _symbol = symbol_;
    _maxSupply = maxSupply_;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public pure returns (uint8) {
    return 18;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function maxSupply() public view returns (uint256) {
    return _maxSupply;
  }

  function balanceOf(address account) public view virtual returns (uint256) {
    return _balances[account];
  }

  function transfer(address to, uint256 amount) public virtual returns (bool) {
    _transfer(msg.sender, to, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    virtual
    returns (bool)
  {
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public returns (bool) {
    uint256 currentAllowance = allowance(from, msg.sender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "ERC20: insufficient allowance");
      require(from != address(0), "ERC20: approve from the zero address");

      _allowances[from][msg.sender] = currentAllowance - amount;
      emit Approval(from, msg.sender, currentAllowance - amount);
    }
    _transfer(from, to, amount);
    return true;
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {
    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

    _balances[from] = fromBalance - amount;
    _balances[to] += amount;

    emit Transfer(from, to, amount);
  }

  function mint(address account, uint256 amount) external virtual {
    require(
      _totalSupply + amount <= _maxSupply,
      "ERC20: total supply exceeds max supply"
    );
    _totalSupply += amount;
    _balances[account] += amount;

    emit Mint(account, amount);
  }
}

contract TokenFactory {
  address public owner;
  uint256 public fee = 0.1 ether;
  address[] public tokens;

  event TokenCreated(address tokenAddress);
  event FeeUpdated(uint256 amount);
  event OwnerUpdated(address owner);
  event FeesWithdrawn(address to, uint256 amount);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only Owner can call this function");
    _;
  }

  function createToken(
    string memory name,
    string memory symbol,
    uint256 maxSupply
  ) external payable {
    require(msg.value == fee, "Invalid fees");
    ERC20 newToken = new ERC20(name, symbol, maxSupply);
    tokens.push(address(newToken));
    emit TokenCreated(address(newToken));
  }

  function getTokens() external view returns (address[] memory) {
    return tokens;
  }

  function setOwner(address newOwner) external onlyOwner {
    owner = newOwner;
    emit OwnerUpdated(newOwner);
  }

  function setFees(uint256 newFee) external onlyOwner {
    fee = newFee;
    emit FeeUpdated(newFee);
  }

  function withdrawFees() external onlyOwner {
    uint256 fees = address(this).balance;
    (bool sent, ) = payable(owner).call{value: fees}("");
    require(sent, "Failed to withdraw fees");
    emit FeesWithdrawn(owner, fees);
  }
}