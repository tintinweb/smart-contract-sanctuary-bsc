/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

pragma solidity >=0.8.17;
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

contract Admin is Context {
  address payable public owner;
  mapping (address => bool) public admin;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event NewAdmin(address indexed admin);
  event AdminRemoved(address indexed admin);

  constructor(){
    owner = payable(_msgSender());
    admin[_msgSender()] = true;
  }

  modifier onlyOwner() {
    if(_msgSender() != owner)revert();
    _;
  }

  modifier onlyAdmin() {
    if(!admin[_msgSender()])revert();
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    if(newOwner == address(0))revert();
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function makeNewAdmin(address payable _newadmin) public onlyOwner {
    require(_newadmin != address(0));
    emit NewAdmin(_newadmin);
    admin[_newadmin] = true;
  }

  function makeRemoveAdmin(address payable _oldadmin) public onlyOwner {
    require(_oldadmin != address(0));
    emit AdminRemoved(_oldadmin);
    admin[_oldadmin] = false;
  }

}

contract Proxy is Admin {

    address public delegate;
    uint public version = 0;

    function upgradeDelegate(address newDelegateAddress) onlyOwner public {
        require(_msgSender() == owner);
        delegate = newDelegateAddress;
        version++;
    }

    fallback() external payable {
        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }

     receive() external payable {
        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }
}

contract TokenPool is Proxy  {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "Diamond Soccer Game Coin";
    string private _symbol = "DSGC";
    uint256 private _decimals = 18;
    uint256 private _totalSupply;

    address public tokenPool = 0x55d398326f99059fF775485246999027B3197955; // USDT token

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

    function balancePool() public view returns (uint256) {
        return contractPool.balanceOf(address(this));
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

        uint256 balanceOfPool = contractPool.balanceOf(address(this));
        uint256 tokens = _totalSupply;

        if(balanceOfPool == 0 || tokens == 0){
            return 10**decimals();
        }else{
            return (balanceOfPool.mul(10**decimals())).div( tokens );

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

        uint256 valor = (amount.mul( 10 ** decimals() )).div(price()); //calcula la cantidad de tokens a obtener

        if(!contractPool.transferFrom(_msgSender(), address(this), amount))return();//precio a pagar

        _print(_msgSender(), valor.mul(99).div(100)); // se crean los tokens y se entregan
        burn();

    }

    function sellToken(uint256 amount) public {


        uint256 pago = (amount.mul(price())).div(10 ** decimals());// se calcula el precio de los tokens a destruir
        if(!contractPool.transfer(_msgSender(), pago.mul(98).div(100)))return();// se transfiere el valor de los tokens

        _burn(_msgSender(), amount); // se destruyen los tokens
        burn();

    }

}