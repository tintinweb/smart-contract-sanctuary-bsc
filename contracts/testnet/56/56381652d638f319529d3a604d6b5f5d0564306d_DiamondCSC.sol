/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: MIT

interface BEPC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Print(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
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

contract DiamondCSC is Context, BEPC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "Diamond CSC";
    string private _symbol = "DCSC";
    uint256 private _decimals = 18;
    uint256 private _totalSupply;

    address public tokenPool = 0xd5881b890b443be0c609BDFAdE3D8cE886cF9BAc;

    BEPC20 contractPool = BEPC20(tokenPool);

    constructor () {}

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function price() public view virtual returns (uint256) {

        uint256 plata = contractPool.balanceOf(address(this));
        uint256 tokens = _totalSupply;

        if(plata == 0 || tokens == 0){
            return 10**decimals();
        }else{
            return (plata.mul(10**decimals())).div( tokens );

        }

    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address sender, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _totalSupply = _totalSupply - amount;

        emit Burn(sender, amount);

    }

    function _print(address to, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[to];
        _balances[to] = senderBalance.add(amount);
        _totalSupply = _totalSupply.add(amount);

        emit Print(address(this), to, amount);
    }

    function burn() public {
        if(_balances[address(this)] > 0){
            _burn(address(this),_balances[address(this)]);
        }
    }

    function buyToken(uint256 amount) public {

        uint256 valor = (amount.mul( 10 ** decimals() )).div(price());

        if(!contractPool.transferFrom(_msgSender(), address(this), valor))return();
        _print(_msgSender(), amount.mul(95).div(100));
        burn();

    }

    function sellToken(uint256 amount) public {

        uint256 pago = (amount.mul(price())).div(10 ** decimals());

        if(!contractPool.transfer(_msgSender(), pago.mul(90).div(100)))return();
        _burn(_msgSender(), amount);
        burn();

    }

}