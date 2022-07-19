// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;

import "./SafeMath.sol";
import "./TransferHelper.sol";
import "./IBEP20.sol";
import "./Ownable.sol";

interface IAutoPool
{
    function OnSell(address user,uint256 poolamount,uint256 baseamount) external;
    function OnBuy(address user,uint256 poolamount,uint256 baseamount) external;
    function OnTransfer(address sender,address recipient) external;
}

 contract LITTOKEN is Ownable
{
    using SafeMath for uint256;
    string _name;
    string _symbol;
    uint8  _decimals;
    uint256 _totalsupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>uint256) _balances;
    address public _CreditPool;

    mapping(address=>bool) _Exclude;

    address _ammPool;
  
    constructor()
    {
       _name="LIT";
       _symbol="LIT";
       _decimals = 18;
       _totalsupply= 28800 * 1e18;
       _balances[msg.sender] = _totalsupply;
       emit Transfer(address(0), msg.sender, _totalsupply);
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public  view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view  returns (uint256) {
        return _totalsupply;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view  returns (uint256) {
        return _balances[account];
    }
    function TakeOutInContractERC20(address tokenaddress,address to,uint256 amount) public onlyOwner
    {
        IBEP20(tokenaddress).transfer(to, amount);
    }
  
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        return true;
    }

   function transfer(address recipient, uint256 amount) public returns (bool) {
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

    function burnFrom(address sender, uint256 amount) public  returns (bool)
    {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _burn(sender,amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool)
    {
        _burn(msg.sender,amount);
        return true;
    }
 
    function _burn(address sender,uint256 tAmount) private
    {
         require(sender != address(0), "BEP20: transfer from the zero address");
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[address(0)] = _balances[address(0)].add(tAmount);
         emit Transfer(sender, address(0), tAmount);
    }

    function setAmmPool(address pool) public onlyOwner 
    {
        _ammPool=pool;
    }

    function setCreditPool(address credit) public onlyOwner 
    {
        _CreditPool=credit;
    }

    function AddExclued(address ex,bool can) public onlyOwner 
    {
        _Exclude[ex]=can;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        uint256 toamount=amount;
        if(!_Exclude[sender] && !_Exclude[recipient])
        {
            require(block.timestamp>=1658289600,"NotStart");
            uint256 onepct = amount.div(100);
            if(sender== _ammPool)
            {   
                _balances[_CreditPool] = _balances[_CreditPool].add(onepct); 
                emit Transfer(sender, _CreditPool, onepct);
                toamount= toamount.sub(onepct);
                IAutoPool(_CreditPool).OnBuy(recipient, onepct,toamount);
            }
            else if(recipient == _ammPool)
            {
                uint256 cut= onepct.mul(6);
                _balances[_CreditPool] = _balances[_CreditPool].add(cut); 
                emit Transfer(sender, _CreditPool, cut);
                toamount= toamount.sub(cut);
                IAutoPool(_CreditPool).OnSell(sender, cut,amount);
            }
            else
            {
                IAutoPool(_CreditPool).OnTransfer(sender, recipient);
            }
        }
        _balances[sender]= _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(toamount); 
        emit Transfer(sender, recipient, toamount);
    }
}