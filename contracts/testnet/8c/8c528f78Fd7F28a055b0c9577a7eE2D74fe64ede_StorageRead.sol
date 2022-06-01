/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal { _owner = msg.sender; emit OwnershipTransferred(address(0), _owner); }
    
    modifier onlyOwner() { require(isOwner()); _; }
    
    function owner() public view returns (address) { return _owner; }
    function isOwner() public view returns (bool) { return msg.sender == _owner; }
    function renounceOwnership() public onlyOwner { emit OwnershipTransferred(_owner, address(0)); _owner = address(0); }
    function transferOwnership(address newOwner) public onlyOwner { _transferOwnership(newOwner); }
    function _transferOwnership(address newOwner) internal { require(newOwner != address(0)); emit OwnershipTransferred(_owner, newOwner); _owner = newOwner; }

}

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call.value(_amount)("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() external payable {}
  
}

contract StorageRead is Ownable {

  bool public contact; // slot0
  bytes32[] public codex; // slot1
  bytes32[3] private data;

  constructor(bytes32[3] memory _data) public {
    data = _data;
  }

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
    codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content; 
  }

}