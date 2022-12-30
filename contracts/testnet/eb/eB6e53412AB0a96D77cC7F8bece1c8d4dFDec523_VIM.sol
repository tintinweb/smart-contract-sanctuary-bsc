/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);
}

library SafeMath {
  	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256) {
	    uint256 c = a / b;
		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

abstract contract OwnerHelper {
  	address private _owner;
  	modifier onlyOwner {
		require(msg.sender == _owner, "OwnerHelper: caller is not owner");
		_;
  	}

  	constructor() {
            _owner = msg.sender;
  	}

       function owner() public view virtual returns (address) {
           return _owner;
       }

  	function transferOwnership(address newOwner) onlyOwner public {
            require(newOwner != _owner);
            require(newOwner != address(0x0));
    	    _owner = newOwner;
  	}
}

contract VIM is IBEP20, OwnerHelper {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    uint256 public _totalSupply;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    mapping (address => bool) public _personalTokenLock;

    constructor() {
        _name = "VIM";
        _symbol = "VIZ";
        _decimals = 18;
        _totalSupply = 5000000000 * 10**18;
        _balances[msg.sender] = _totalSupply;
    }
   
    function name() public view returns (string memory) {
        return _name;
    }
       
    function symbol() public view returns (string memory) {
        return _symbol;
    }
   
    function decimals() public view returns (uint8) {
        return _decimals;
    }
   
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }
   
    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
   
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
   
    function approve(address spender, uint amount) external virtual override returns (bool) {
        uint256 currentAllownace = _allowances[msg.sender][spender];
        _approve(msg.sender, spender, currentAllownace, amount);
        return true;
    }
   
    function _approve(address owner, address spender, uint256 currentAmount, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        require(currentAmount == _allowances[owner][spender], "BEP20: invalid currentAmount");
        _allowances[owner][spender] = amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(isTokenLock(sender, recipient) == false, "TokenLock: invalid token transfer");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance.sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
    }
   
    function isTokenLock(address from, address to) public view returns (bool lock) {
        lock = false;
        if(_personalTokenLock[from] == true || _personalTokenLock[to] == true) {
            lock = true;
        }
    }

    function addPersonalTokenLock(address _who) onlyOwner public {
        require(_personalTokenLock[_who] == false, "alredy lock true");
        _personalTokenLock[_who] = true;
    }

	function removePersonalTokenLock(address _who) onlyOwner public {
        require(_personalTokenLock[_who] == true, "alredy lock false");
        _personalTokenLock[_who] = false;
    }

    function isPersonalTokenLock(address _who) view public returns(bool) {
        return _personalTokenLock[_who];
    }
}