// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;

import "./SafeMath.sol";
import "./TransferHelper.sol";
import "./IBEP20.sol";
import "./Ownable.sol";

 contract BThorToken is IBEP20,Ownable
{
    using SafeMath for uint256;
 
    string  _name="BSC THOR";
    string  _symbol="BTHOR";
    uint8  _decimals=18;
    uint256 _totalsupply;  

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) _minter;
    mapping(address=>bool) _banneduser;
    mapping(address=>uint256) _balances;
    bool _allowtransfer;
 
    constructor( )
    {
        _minter[msg.sender]=true;
        _allowtransfer=true;
    }

    function BannUser(address user,bool ban) public onlyOwner
    {
        _banneduser[user]=ban;
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

    function totalSupply() public view override returns (uint256) {
        return _totalsupply;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function setAllowtransfer(bool allow) public onlyOwner
	{
		 _allowtransfer =allow;
	}
	
	function addMinter(address account,bool ok) public onlyOwner
	{
		_minter[account]=ok;
	}

    function takeOutErrorTransfer(address token,address user,uint256 amount ) public onlyOwner
    {
        IBEP20(token).transfer(user, amount);
    }

    function mint(address account,uint256 amount) public override
    {
        require(_minter[msg.sender]==true,"Must be minter");
        _mint(account,amount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), 'BEP20: mint to the zero address');
        _totalsupply=_totalsupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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
 
    function _burn(address sender,uint256 tAmount) private
    {
         require(sender != address(0), "BEP20: transfer from the zero address");
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[address(0)] = _balances[address(0)].add(tAmount);
         emit Transfer(sender, address(0), tAmount);
    }


    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(_banneduser[sender]==false,"banned");
        require(_allowtransfer || _minter[sender] || _minter[recipient],"Transfer closed");
        _balances[sender]= _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount); 
        emit Transfer(sender, recipient, amount);
    }
}