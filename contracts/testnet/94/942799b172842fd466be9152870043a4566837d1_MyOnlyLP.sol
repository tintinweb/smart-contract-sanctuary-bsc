// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./SafeMath.sol";
import "./IPancakeRouter02.sol";

interface IBEP20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address _owner)external view returns(uint256);
    function transfer(address _to, uint256 _value)external returns(bool);
    function approve(address _spender, uint256 _value)external returns(bool);
    function transferFrom(address _from, address _to, uint256 _value)external returns(bool);    
    function allowance(address _owner, address _spender)external view returns(uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract MyOnlyLP is IBEP20 {
    using SafeMath for uint256;
    address payable public creator;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string public name = "My Test TKN 2";
    string public symbol = "TTKN2";
    uint public decimals = 18;
    uint256 public _totalSupply;

    IPancakeRouter02 _pancakeRouter;

    modifier ownerOnly {
        if (msg.sender == creator) {
            _;
        }
    }

    constructor() public{
        creator = msg.sender;
        _totalSupply = 1000000000000000000000000;
        _balances[creator] = _totalSupply;
        _pancakeRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    }

    function totalSupply() external override view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner)external override view returns(uint256 _returnedBalance){
        _returnedBalance = _balances[_owner];
        return _returnedBalance;
    }

    function _transfer(address _from, address _to, uint256 amount) internal {
      require(_from != address(0), "BEP20: Transfer from zero address");
      require(_to != address(0), "BEP20: Transfer to the zero address");
      _balances[_from] = _balances[_from].sub(amount);
      _balances[_to] = _balances[_to].add(amount);
      emit Transfer(_from, _to, amount);
    }

    function transfer(address _to, uint256 _value)external override returns(bool){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");
      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }

    function approve(address _spender, uint256 _value)external override returns(bool success) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)external override returns(bool success){
        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, _allowances[_from][msg.sender].sub(_value));
        return true;
    }

    function allowance(address _owner, address _spender)external override view returns(uint256 remaining){
        return _allowances[_owner][_spender];
    }

    function addMyLiquidity(uint256 _tokensAmoun)public payable ownerOnly returns(bool){
        _pancakeRouter.addLiquidityETH {value: msg.value}(
        address(this),
        _tokensAmoun,
        0,
        0,
        msg.sender,
        block.timestamp
    );
    return true;
    }
}