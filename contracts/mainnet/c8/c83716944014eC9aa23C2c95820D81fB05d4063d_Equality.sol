//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

contract Ownable {
  address public owner;
  address private _newOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "caller is not the owner");
    _;
  }

  /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
  function renounceOwnership(string calldata check) public virtual onlyOwner {
    require(keccak256(abi.encodePacked(check)) == keccak256(abi.encodePacked("renounceOwnership")), "security check");
    _setOwner(address(0));
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */

  function transferOwnership(address newOwner) public onlyOwner {
    require(address(0) != newOwner, "new owner is the zero address");
    _newOwner = newOwner;
  }

  function acceptOwnership() public {
    require(_newOwner != address(0), "no new owner has been set up");
    require(msg.sender == _newOwner, "only the new owner can accept ownership");
    _setOwner(_newOwner);
    _newOwner = address(0);
  }

  function _setOwner(address newOwner) internal {
    address oldOwner = owner;
    owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}


abstract contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public virtual view returns (uint256);
  function transfer(address to, uint256 value) public virtual returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public virtual view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
  function approve(address spender, uint256 value) public virtual returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20 {
  uint256 public txFee;
  uint256 public burnFee;
  address public feeAddress;

  mapping (address => mapping (address => uint256)) internal allowed;
  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public override virtual returns (bool) {
    require(_to != address(0), "transfer to the zero address");
    require(_value <= balances[msg.sender], "transfer amount exceeds balance");

    balances[msg.sender] -= _value;

    _value = applyFee(_value, msg.sender);

    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public override view returns (uint256 balance) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) public override virtual returns (bool) {
    require(_to != address(0), "transfer to the zero address");
    require(_from != address(0), "transfer from the zero address");
    require(_value <= balances[_from], "transfer amount exceeds balance");
    require(_value <= allowed[_from][msg.sender], "transfer amount exceeds allowance");
    
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;

    _value = applyFee(_value, _from);

    balances[_to] += _value;
    emit Transfer(_from, _to, _value);
    emit Approval(_from, msg.sender, allowed[_from][msg.sender]);
    return true;
  }

  function applyFee(uint256 _value, address _from) internal returns (uint256) {
    uint256 tempValue = _value;
    if (txFee > 0 && _from != feeAddress) {
      uint256 denverDeflaionaryDecay = tempValue / (uint256(100 / txFee));
      balances[feeAddress] += denverDeflaionaryDecay;
      emit Transfer(_from, feeAddress, denverDeflaionaryDecay);
      _value -= denverDeflaionaryDecay;
    }

    if (burnFee > 0 && _from != feeAddress) {
      uint256 burnValue = tempValue / (uint256(100 / burnFee));
      totalSupply -= burnValue;
      emit Transfer(_from, address(0), burnValue);
      _value -= burnValue;
    }

    return _value;
  }

  function approve(address _spender, uint256 _value) public override virtual returns (bool) {
    require(_spender != address(0), "approve to the zero address");
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public override view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseAllowance(address _spender, uint _addedValue) public virtual returns (bool) {
    allowed[msg.sender][_spender] += _addedValue;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseAllowance(address _spender, uint _subtractedValue) public virtual returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue - _subtractedValue;
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}


contract Equality is StandardToken, Ownable {
  string public name;
  string public symbol;
  uint public decimals;
  event Burn(address indexed burner, uint256 value);

  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _decimals,
    uint256 _supply,
    uint256 _txFee,
    uint256 _burnFee,
    address _feeAddress,
    address tokenOwner
  ) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply = _supply * 10 ** _decimals;
    balances[tokenOwner] = totalSupply;
    owner = tokenOwner;
    
    txFee = _txFee;
    burnFee = _burnFee;
    feeAddress = _feeAddress;
    
    emit Transfer(address(0), tokenOwner, totalSupply);
  }

	function burn(uint256 _value) public{
		_burn(msg.sender, _value);
	}

	function _burn(address _who, uint256 _value) internal {
		require(_value <= balances[_who], "burn amount exceeds balance");
		balances[_who] -= _value;
		totalSupply -= _value;
		emit Burn(_who, _value);
		emit Transfer(_who, address(0), _value);
	}
}