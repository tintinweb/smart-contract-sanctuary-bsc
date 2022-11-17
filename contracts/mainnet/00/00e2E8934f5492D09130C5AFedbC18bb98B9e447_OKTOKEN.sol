// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;
import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
 
 
contract OKTOKEN is Ownable
{
    using SafeMath for uint256;
    string constant  _name = 'OK TOKEN';
    string constant _symbol = 'OKT';
    uint8 immutable _decimals = 18;
    uint256 _totalsupply;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) _exclude;
    mapping(address=>uint256) _balances;
 
    address _ammPool;
    address _cutpool;
    uint256 starttradetime;
    uint256 public totalCut;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
    constructor()
    {
        _exclude[msg.sender]=true;
        starttradetime=1668668490;
        _totalsupply = 100000 * 1e18;
        _balances[msg.sender] = _totalsupply;
        emit Transfer(address(0), msg.sender, _totalsupply);
        _cutpool=msg.sender;
  
    }

    function setCutPool(address pool) public onlyOwner 
    {
        _cutpool=pool;
    }
 
    function setAmmPool(address pool) public onlyOwner
    {
        _ammPool= pool;
    }
 
    function setExclude(address user,bool ok) public onlyOwner
    {
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
 
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender]= _balances[sender].sub(amount);
        uint256 toamount=amount;
    
        if(!_exclude[sender] && !_exclude[recipient])
        {
            require(block.timestamp >= starttradetime,"Not started");
            uint256 onepct = amount.div(100);
             if(recipient == _ammPool)
            {
                _balances[address(0)] = _balances[address(0)].add(onepct.mul(4)); 
                emit Transfer(sender, address(0), onepct.mul(4));
                totalCut=totalCut.add(onepct);
                _balances[_cutpool] = _balances[_cutpool].add(onepct); 
                emit Transfer(sender, _cutpool, onepct);
                 toamount=amount.sub(onepct.mul(5));
            }
            else if(sender != _ammPool)
            {
                _balances[address(0)] = _balances[address(0)].add(onepct.mul(5)); 
                emit Transfer(sender, address(0), onepct.mul(5));
                 toamount=amount.sub(onepct.mul(5));
            } 
        }

        _balances[recipient] = _balances[recipient].add(toamount); 
        emit Transfer(sender, recipient, toamount);
    }
}