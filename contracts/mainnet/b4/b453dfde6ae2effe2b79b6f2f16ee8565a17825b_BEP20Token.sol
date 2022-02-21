/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

pragma solidity ^0.8.9;
// SPDX-License-Identifier: MIT
// @title BEP20 Token
// @created_by  Stonoex

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a, "Addition overflow");
      return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b <= a, "Subtraction overflow");
      return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Multiplication overflow");
        return c;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _newOwner;

    event OwnerShipTransferred(address indexed oldOwner, address indexed newOwner);
    constructor() {
        _owner = _msgSender();
        _newOwner = _msgSender();
        emit OwnerShipTransferred(address(0), _msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function newOwner() public view virtual returns (address) {
        return _newOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "You are not the owner");
        _;
    }

    function transferOwnership(address newOwner_) public onlyOwner{
        require(newOwner_ != address(0), "Invalid address");
        _newOwner = newOwner_;
    }

    function acceptOwnership()public{
        require(newOwner() == _msgSender(), "You are not the new owner");
        _transferOwnership(newOwner());
    }

     function _transferOwnership(address newOwner_) internal{
        emit OwnerShipTransferred(owner(), newOwner_);
        _owner = newOwner_;
    }

}

contract Pausable is Ownable{
    event Pause();
    event Unpause();
     
    bool private _isPaused = true;
     
    function isPaused() public view returns(bool){
        return _isPaused;
    }
    
    modifier whenNotPaused(){
        require(!_isPaused, "Contract is paused.");
        _;
    }
    
    modifier whenPaused(){
        require(_isPaused, "Contract is not paused.");
        _;
    }
    
    function pause()public onlyOwner whenNotPaused{
        _isPaused = true;
        emit Pause();
    }
    
    function unpause()public onlyOwner whenPaused{
        _isPaused = false;
        emit Unpause();
    }
 }




interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract BEP20Token is Context, IBEP20, Ownable, Pausable{
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string  private _name;
    string  private _symbol;
    uint8   private _decimals;
    string  private _docURL;

    event Burn(address indexed account, uint256 value);
    event Mint(address indexed from, address indexed to, uint256 value);

    constructor (string memory name_, string memory symbol_, uint256 totalSupply_, uint8 decimals_)  {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_.mul(10 ** decimals_);
        _decimals = decimals_;
        _balances[_msgSender()] = _balances[_msgSender()].add(_totalSupply);
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function getOwner()  public view virtual override returns (address) {
        return owner();
    }
  
    function name()  public view virtual override returns (string memory) {
        return _name;
    }
    
    function symbol()  public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function decimals()  public view virtual override returns (uint8) {
        return _decimals;
    }
    
    function totalSupply()  public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account)  public view virtual override returns (uint256) {
        return _balances[account];
    }

    function getDocURL() public view returns(string memory){
        return _docURL;
    }
    
    function setDocURL(string memory url) public onlyOwner {
        _docURL = url;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 value) public override returns (bool) {
        _transfer(sender, recipient, value);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(value));
        return true;
    }

     function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from_, address to_, uint256 amount_) internal{
        require(from_ != address(0), "Sender Invalid address");
        require(to_ != address(0), "Recipient Invalid Address");
        _balances[from_] = _balances[from_].sub(amount_);
        _balances[to_] = _balances[to_].add(amount_);
        emit Transfer(from_, to_, amount_);
    }

    function _approve(address owner_, address spender_, uint256 amount_) internal{
        require(owner_ != address(0), "Approve from the zero address");
        require(spender_ != address(0), "Approve to the zero address");
        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

    function burn(uint256 amount_) public onlyOwner whenNotPaused{
        require( _msgSender() != address(0), "Invalid account address");
        _balances[ _msgSender()] = _balances[ _msgSender()].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Burn( _msgSender(), amount_);
    }

    function mint(uint256 amount_)public onlyOwner whenNotPaused{
        _totalSupply = _totalSupply.add(amount_);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount_);
        emit Mint(address(0), _msgSender(), amount_);
    }
}