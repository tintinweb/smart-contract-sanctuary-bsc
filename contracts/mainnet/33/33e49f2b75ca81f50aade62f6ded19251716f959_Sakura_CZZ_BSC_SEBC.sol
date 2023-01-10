/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract StandardToken {
  mapping(address => uint256) internal _balances;
  mapping(address => mapping (address => uint256)) internal _allowances;
  uint256 internal _totalSupply;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval( address indexed owner, address indexed spender, uint256 value );

  function totalSupply() public view returns (uint256) {
      return _totalSupply;
  }
  function balanceOf(address _owner) public view returns (uint256) {
      return _balances[_owner];
  }
  function allowance( address _owner, address _spender ) public view returns (uint256) { 
      return _allowances[_owner][_spender];
 }
}

contract Ownable {
  address private _owner;
  address private _previousOwner;
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
      _owner = msg.sender;
      emit OwnershipTransferred(address(0), _owner);
  }
  modifier onlyOwner() {
      require(msg.sender == _owner, "Ownable: caller is not the owner");
      _;
  }
  function owner() public view returns (address) {
      return _owner;
  } 
  function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      _previousOwner = _owner;
      _owner = newOwner;
      emit OwnershipTransferred(_previousOwner, _owner);
  }
  function renounceOwnership() public onlyOwner {
      _previousOwner = _owner;
      _owner = address(0);
      emit OwnershipTransferred(_previousOwner, address(0));
  }
}

contract MintableToken is StandardToken, Ownable {
  using SafeMath for uint;
  bool public mintingFinished = false;
  uint public mintTotal = 0;
  event Mint(address indexed account, uint256 amount);
  event Burn(address indexed account, uint256 amount);

  modifier canMint() {
      require(!mintingFinished);
      _;
  }
  function offMint() onlyOwner public  {
      mintingFinished = mintingFinished ? false : true ;
  }
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
      uint tmpTotal = mintTotal.add(_amount);
      require(tmpTotal <= _totalSupply, "BEP20: Mint exceeds amount");
      mintTotal = mintTotal.add(_amount);
      _balances[_to] = _balances[_to].add(_amount);
      emit Mint(_to, _amount);
      return true;
  }
  function burn(address _from, uint256 _amount) onlyOwner public returns (bool) {
      require(_amount <= _balances[_from], "BEP20: Burn exceeds amount");
      mintTotal = mintTotal.sub(_amount);
      _balances[_from] = _balances[_from].sub(_amount);
      emit Burn(_from, _amount);
      return true;
  }
}

contract Pausable is Ownable {
  bool public paused = true;
  mapping (address => bool) private _isSniper;
  address[] private _confirmedSnipers;
  event Pause();
  event Unpause();
  event RemoveSniper(address indexed account);
  event AmnestySniper(address indexed account);
 
  modifier whenNotPaused() {
      require(!paused, "Contract is paused");
      require(!_isSniper[msg.sender], "Account is blacklisted");
      _;
  }
  modifier whenPaused() {
      require(paused);
      _;
  }
  function pause() onlyOwner whenNotPaused public {
      paused = true;
      emit Pause();
  }
  function unpause() onlyOwner whenPaused public {
      paused = false;
      emit Unpause();
  }
  function isRemovedSniper(address account) public view returns (bool) {
      return _isSniper[account];
  }
  function removeSniper(address account) external onlyOwner() {
      require(!_isSniper[account], "Account is already blacklisted");
      _isSniper[account] = true;
      _confirmedSnipers.push(account);
      emit RemoveSniper(account);
  }
  function amnestySniper(address account) external onlyOwner() {
      require(_isSniper[account], "Account is not blacklisted");
      for (uint256 i = 0; i < _confirmedSnipers.length; i++) {
          if (_confirmedSnipers[i] == account) {
              _confirmedSnipers[i] = _confirmedSnipers[_confirmedSnipers.length - 1];
              _isSniper[account] = false;
              _confirmedSnipers.pop();
              break;
          }
      }
      emit AmnestySniper(account);
  }
}

contract PausableToken is StandardToken, Pausable {
  using SafeMath for uint256;
 
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
      require(_to != address(0), "BEP20: transfer to the zero address");
      require(_value > 0, "BEP20: Transfer amount must be greater than zero");
      require(_value <= _balances[msg.sender],  "BEP20: Transfer amount exceeds in wallet");
      _balances[msg.sender] = _balances[msg.sender].sub(_value);
      _balances[_to] = _balances[_to].add(_value);
      emit Transfer(msg.sender, _to, _value);
      return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) { 
      require(_value > 0, "BEP20: Transfer amount must be greater than zero");
      require(_value <= _balances[_from], "BEP20: Transfer amount exceeds value to wallet");
      if (_from == msg.sender) { 
          _allowances[_from][_to] = _allowances[_from][_to].add(_value);
      }
      require(_value <= _allowances[_from][_to], "BEP20: transfer amount exceeds allowance"); 
      _balances[_from] = _balances[_from].sub(_value);
      _balances[_to] = _balances[_to].add(_value);
      _allowances[_from][_to] = _allowances[_from][_to].sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
  }
  function approve( address _spender, uint256 _value) public whenNotPaused returns (bool) {
      require(msg.sender != address(0), "BEP20: approve from the zero address");
      require(_spender != address(0), "BEP20: approve to the zero address");
      _allowances[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
  }
  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
      _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender].add(_addedValue);
      emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
      return true;
  }
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
      uint oldValue = _allowances[msg.sender][_spender];
      if (_subtractedValue > oldValue) {
        _allowances[msg.sender][_spender] = 0;
      } else {
        _allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
      return true;
  }
}

contract Sakura_CZZ_BSC_SEBC is PausableToken, MintableToken {
    string public name = "SAKURA CZZ";
    string public symbol = "SEBC";
    uint8 public decimals = 4;

    constructor() {
        _totalSupply = 100000000 * (10 ** uint256(decimals));
    }

    function withdraw() external payable onlyOwner {
        (bool success, ) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function withdrawToken(address _token) external payable onlyOwner {
        (bool success, ) = _token.call(abi.encodeWithSelector(bytes4(keccak256(bytes('transfer(address,uint256)'))), msg.sender, IBEP20(_token).balanceOf(address(this))));
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}