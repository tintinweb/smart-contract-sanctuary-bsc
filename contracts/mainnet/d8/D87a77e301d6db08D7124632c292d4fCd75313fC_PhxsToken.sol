// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;
import "./IBEP20.sol";
import "./SafeMath.sol";
 
contract PhxsToken is IBEP20
{
    using SafeMath for uint256;
    address _creator;

    string constant  _name = 'PHXS';
    string constant _symbol = 'PHXS';
    uint8 immutable _decimals = 8;

    address public _owner;
 
    uint256 _totalsupply= 30000000 * 1e8; 

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) _minter;
    mapping(address=>bool) _exclude;
    mapping(address=>uint256) _balances;

    address _fee;

    address _ammPool;
  
    constructor()
    {
        _creator = msg.sender;
        _owner=address(0);
        _fee=0x256d3B5197f19dBB47b6625A29388473AC0e4B7D;
        _balances[_creator] = _totalsupply;
        _exclude[msg.sender] =true;
        emit Transfer(address(0), _creator, _totalsupply);
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

    function totalSupply() public view override returns (uint256) {
        return _totalsupply;
    }
 

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
	 
    function takeOutErrorTransfer(address tokenaddress) public
    {
        require(msg.sender==_creator);
        IBEP20(tokenaddress).transfer(_creator, IBEP20(tokenaddress).balanceOf(address(this)));
    }
  
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

 
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        return true;
    }

   function transfer(address recipient, uint256 amount) public override returns (bool) {
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

    function burnFrom(address sender, uint256 amount) public override  returns (bool)
    {
         _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _burn(sender,amount);
        return true;
    }

    function burn(uint256 amount) public override returns (bool)
    {
        _burn(msg.sender,amount);
        return true;
    }

    function setAmmPool(address ammpool) public 
    {
        require(_creator== msg.sender,"onlycreate");
        _ammPool= ammpool;
    }

    function setFee(address fee) public 
    {
        require(_creator== msg.sender,"onlycreate");
        _fee= fee;
    }

    function setExclude(address exclude,bool ok) public
    {
         require(_creator== msg.sender,"onlycreate");
        _exclude[exclude]=ok;
    }
  
    function _burn(address sender,uint256 tAmount) private
    {
         require(sender != address(0), "ERC20: transfer from the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[address(0)] = _balances[address(0)].add(tAmount);
         emit Transfer(sender, address(0), tAmount);
    }


    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
         
        uint256 toamount=amount;
        if(!_exclude[sender] && !_exclude[recipient])
        {
            require(_ammPool !=address(0),"NotStarted");
            if(sender==_ammPool || recipient== _ammPool)
            {
                uint256 onecut= amount.div(20);
                _balances[_fee] = _balances[_fee].add(onecut); 
                emit Transfer(sender, _fee, onecut);
                toamount= toamount.sub(onecut);
            }
        }
        
        _balances[sender]= _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(toamount); 
        emit Transfer(sender, recipient, toamount);
    }

    
}