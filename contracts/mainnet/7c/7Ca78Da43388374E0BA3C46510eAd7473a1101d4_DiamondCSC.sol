/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: MIT

interface IBEP20 {

  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint256);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
        return 0;
    }

    uint c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0);
    uint c = a / b;

    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    uint c = a - b;

    return c;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);

    return c;
  }

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract DiamondCSC is Context  {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "Diamond CSC";
    string private _symbol = "DCSC";
    uint256 private _decimals = 18;
    uint256 private _totalSupply;

    address public tokenPool = 0x55d398326f99059fF775485246999027B3197955; // USDT

    IBEP20 contractPool = IBEP20(tokenPool);

    constructor () {}

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance.sub(amount));
        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function price() public view returns (uint256) {

        uint256 plata = contractPool.balanceOf(address(this));
        uint256 tokens = _totalSupply;

        if(plata == 0 || tokens == 0){
            return 10**decimals();
        }else{
            return (plata.mul(10**decimals())).div( tokens );

        }

    }

    function _burn(address sender, uint256 amount) internal {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _totalSupply = _totalSupply - amount;

        emit Transfer(sender,address(0), amount);

    }

    function _print(address to, uint256 amount) internal {
        uint256 senderBalance = _balances[to];
        _balances[to] = senderBalance.add(amount);
        _totalSupply = _totalSupply.add(amount);

        emit Transfer(address(this), to, amount);
    }

    function burn() public {
        if(_balances[address(this)] > 0){
            _burn(address(this),_balances[address(this)]);
        }
    }

    function buyToken(uint256 amount) public {

        uint256 valor = (amount.mul( 10 ** decimals() )).div(price());

        if(!contractPool.transferFrom(_msgSender(), address(this), valor))return();
        _print(_msgSender(), amount.mul(99).div(100));
        burn();

    }

    function sellToken(uint256 amount) public {

        uint256 pago = (amount.mul(price())).div(10 ** decimals());

        if(!contractPool.transfer(_msgSender(), pago.mul(98).div(100)))return();
        _burn(_msgSender(), amount);
        burn();

    }

}