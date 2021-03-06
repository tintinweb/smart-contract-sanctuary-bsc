/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-08
*/

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract SOP is IERC20,Ownable{
    
    event Auction(uint256 id,address take);
    event Take(uint256 id);
    event DestroyCard(uint256 id);
    event AuctionTransfer(uint256 id,uint256 amount,uint256 person,uint256 team);
    event InnerTransfer(address recipient, uint256 amount);
    event SopBook(address indexed owner,address indexed bookAddr,uint256 ddaAmount,uint256 price,uint256 base);

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _master = address(0xE130EDF73Df4fdA0e7ab8ed7cd247C3397759497);

    uint8 private _usdDecimals=18;
    uint256 private _price = 29840000;
    uint256 private _priceBase = 10 ** 8;

    IERC20 DDA = IERC20(0x5888CeB36582deEB3f318b1DbE2CD353fF37d00c);

    constructor () public{
        _name = "SOP Token";
        _symbol = "SOP";
        _decimals = 6;
        _mint(msg.sender, 150000000 * (10 ** uint256(decimals())));
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function setMaster(address addr) external onlyOwner{
        _master=addr;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function sopBook(address bookAddr,uint256 amount) public {
        require(bookAddr != address(0),"book address is empty");
        require(msg.sender != bookAddr,"Cannot be the same");
        uint256 ddaAmount = amount
            .mul(_priceBase)
            .mul(10 ** uint256(_decimals))
            .div(10 ** uint256(_usdDecimals))
            .div(_price);
        require(DDA.transferFrom(msg.sender,_master,ddaAmount),"DDA transfer error");
        emit SopBook(msg.sender,bookAddr,ddaAmount,_price,_priceBase);
    }

    function innerTransfer(address recipient, uint256 amount) public returns (bool){
        emit InnerTransfer(recipient,amount);
        return true;
    }

    function totalSupply() override public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) override public view returns (uint256) {
        return _balances[account];
    }

    function destroyCard(uint256 id) public returns (bool){
        emit DestroyCard(id);
        return true;
    }

    function make(uint256 amount) public returns (bool){
        _transfer(msg.sender, _master, amount);
        return true;
    }

    function auction(uint256 id,address take) public returns (bool){
        emit Auction(id,take);
        return true;
    }

    function take(uint256 id) public returns (bool){
        emit Take(id);
        return true;
    }

    function auctionTransfer(uint256 id,address recipient,uint256 amount) public returns (bool) {
        require(amount > 0,"error");
        uint256 person = amount.mul(100+1).div(100);
        uint256 team = amount.mul(2).div(100);
        require(DDA.transferFrom(msg.sender,recipient,person),"DDA transfer error");
        _transfer(msg.sender,_master,team);
        emit AuctionTransfer(id,amount,person,team);
        return true;
    }

    function setPrice(uint256 price) external onlyOwner{
        require(price>0,"Rate must more than 0");
        _price=price;
    }

    function getPrice() public view returns (uint256){
        return _price;
    }

    function setPriceBase(uint256 base) external onlyOwner{
        require(base>0,"base must more than 0");
        _priceBase = base;
    }

    function getPriceBase() public view returns (uint256){
        return _priceBase;
    }

    function transfer(address recipient, uint256 amount) override public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) override public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) override public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) override public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}