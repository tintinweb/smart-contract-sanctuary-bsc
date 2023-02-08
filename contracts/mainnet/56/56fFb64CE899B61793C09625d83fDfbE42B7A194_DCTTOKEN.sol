// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;
import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

interface IAutoPool
{
    function OnBuy(uint256 count) external;
    function OnSell(uint256 count) external;
}
  
contract DCTTOKEN is Ownable
{
    using SafeMath for uint256;
    string constant  _name = 'DreamComeTrue';
    string constant _symbol = 'DCT';
    uint8 immutable _decimals = 18;
    uint256 _totalsupply;
  
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>uint256) _balances;
    mapping(address=>bool) _exclude;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

 
    address _ammPool;
    address _cutPool;
  
    constructor()
    {
        _totalsupply =  50000000 * 1e18;
        _balances[msg.sender] = 50000000 * 1e18;
    
        emit Transfer(address(0), msg.sender, 50000000 * 1e18);
    }

    function takeOutErrorTransfer(address tokenaddress,address target,uint256 amount) public onlyOwner
    {
        IBEP20(tokenaddress).transfer(target,amount);
    }

 
    function setExclude(address user,bool ok) public onlyOwner 
    {
        _exclude[user]=ok;
    }
    function setAmmPool(address amm) public onlyOwner 
    {
        _ammPool=amm;
    }

    function setAutoPool(address autopool) public onlyOwner 
    {
        _cutPool=autopool;
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
 
        if(amount==_balances[sender])
            amount=amount.subwithlesszero(1e16);
        _balances[sender]= _balances[sender].sub(amount);
        uint256 toamount=amount;
        if(!_exclude[sender] && !_exclude[recipient])
        {
            require(block.timestamp >= 1675829970,"notStartYet");
            uint256 onepct = amount.div(100);
             if(recipient == _ammPool)
            {
                _balances[_cutPool] = _balances[_cutPool].add(onepct.mul(7)); 
                emit Transfer(sender, _cutPool, onepct.mul(7));
                 toamount=amount.sub(onepct.mul(7));
                 IAutoPool(_cutPool).OnSell(onepct.mul(7));
            }
            else if(sender == _ammPool)
            {
               _balances[_cutPool] = _balances[_cutPool].add(onepct.mul(3)); 
                emit Transfer(sender, _cutPool, onepct.mul(3));
                 toamount=amount.sub(onepct.mul(3));
                 IAutoPool(_cutPool).OnBuy(onepct.mul(3));
            }
            else
            {
                _balances[address(0)] = _balances[address(0)].add(onepct.mul(2)); 
                emit Transfer(sender, address(0), onepct.mul(2));
                 toamount=amount.sub(onepct.mul(2));
            }
        }

         _balances[recipient] = _balances[recipient].add(toamount); 
         emit Transfer(sender, recipient, toamount);
        
    }
}