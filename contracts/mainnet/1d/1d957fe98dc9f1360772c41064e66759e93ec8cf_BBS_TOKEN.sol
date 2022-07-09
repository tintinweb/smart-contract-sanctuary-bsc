/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

pragma solidity >=0.4.22 <0.9.0;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
function totalSupply() external view returns (uint256);
function balanceOf(address account) external view returns (uint256);
function transfer(address recipient, uint256 amount) external returns (bool);
function allowance(address owner, address spender) external view returns (uint256);
function approve(address spender, uint256 amount) external returns (bool);
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);}
abstract contract Context {
function _msgSender() internal view virtual returns (address) {
    return msg.sender; }
function _msgData() internal view virtual returns (bytes memory) {
    this;  return msg.data;  } }
contract BBS_TOKEN is Context, IERC20{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
constructor(string memory name_, string memory symbol_, uint8 decimals_){
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    _totalSupply = 500 * (10 ** 12) * (10 ** _decimals);
    _balances[_msgSender()] = _totalSupply;  }
function name() public view virtual returns (string memory) { return _name; }
function symbol() public view virtual returns (string memory) { return _symbol; }
function decimals() public view virtual returns (uint8) { return _decimals; }
function totalSupply() public view virtual override returns (uint256) { return _totalSupply/10 ** 18; }
function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
function transfer(address to, uint256 amount) public virtual override returns (bool) {
    address owner = _msgSender();
    _transfer(owner, to, amount);
    return true; }
function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender]; }
function approve(address spender, uint256 amount) public virtual override returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true; }
function transferFrom(
    address from,
    address to,
    uint256 amount
    ) public virtual override returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true; }
function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;}
function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    address owner = _msgSender();
    uint256 currentAllowance = allowance(owner, spender);
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(owner, spender, currentAllowance - subtractedValue);
    return true;  }
function _transfer(
    address from,
    address to,
    uint256 amount
    ) internal virtual {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    _balances[from] = fromBalance - amount;
    _balances[to] += amount;
    emit Transfer(from, to, amount); }
function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");
    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);  }
function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    _balances[account] = accountBalance - amount;
    _totalSupply -= amount;
    emit Transfer(account, address(0), amount); }
function _approve(
    address owner,
    address spender,
    uint256 amount
    ) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount); }
function _spendAllowance(
    address owner,
    address spender,
    uint256 amount
    ) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
    require(currentAllowance >= amount, "ERC20: insufficient allowance");
    _approve(owner, spender, currentAllowance - amount); } } }