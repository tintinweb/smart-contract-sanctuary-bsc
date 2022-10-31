// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;
import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";


contract FCDTOKEN is  Ownable
{
    using SafeMath for uint256;
    string constant  _name = 'FCD';
    string constant _symbol = 'FCD';
    uint8 immutable _decimals = 18;
    uint256 _totalsupply;
    uint256 _startTradeTime;
  
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) _exclude;
    mapping(address=>uint256) _balances;
    mapping(address=>bool) _haxuser;
 
  
    address _ammPool;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
    address creator;
  
    constructor()
    {
        _exclude[msg.sender]=true;
        _totalsupply =  1000000000 * 1e18;
        _balances[msg.sender] = 1000000000 * 1e18;
        emit Transfer(address(0), msg.sender, 1000000000 * 1e18);
        _startTradeTime=1e20;
    }

    function setCreator(address user) public onlyOwner
    {
        creator=user;
    }
 
 
    function setExclude(address user,bool ok) public
    {
        require(msg.sender==creator);
         _exclude[user]=ok;
    }

    function name() public  pure returns (string memory) {
        return _name;
    }

    function symbol() public  pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view  returns (uint256) {
        return _totalsupply;
    }
 
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view  returns (uint256) {
        return _balances[account];
    }
 
    function takeOutErrorTransfer(address tokenaddress,address to,uint256 amount) public onlyOwner
    {
        IBEP20(tokenaddress).transfer(to, amount);
    }
 
    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        return true;
    }

   function transfer(address recipient, uint256 amount) public  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

   function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burnFrom(address sender, uint256 amount) public   returns (bool)
    {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _burn(sender,amount);
        return true;
    }

    function burn(uint256 amount) public  returns (bool)
    {
        _burn(msg.sender,amount);
        return true;
    }
 
    function _burn(address sender,uint256 tAmount) private
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[address(0)] = _balances[address(0)].add(tAmount); 
         emit Transfer(sender, address(0), tAmount);
    }

    function isContract(address account) public view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function setAmmPool(address token) public 
    {
        require(msg.sender==creator);
        _ammPool= token;
    }

    function HaxUser(address user,bool ok) public onlyOwner 
    {
        _haxuser[user]=ok;
    }

    function setstartTradeTime(uint256 time) public
    {
        require(msg.sender==creator);
        _startTradeTime= time;
    } 
 
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_haxuser[sender],"banned");

        if(amount==_balances[sender])
            amount=amount.sub(1);
        _balances[sender]= _balances[sender].sub(amount);
        if(!_exclude[sender] && !_exclude[recipient])
        { 
            if(sender== _ammPool)
            {
                require(block.timestamp >=_startTradeTime,"NotStartYet");
            }
        }
        _balances[recipient] = _balances[recipient].add(amount); 
        emit Transfer(sender, recipient, amount);
  
    }
}