/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

pragma solidity ^0.4.16;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
 
    uint256 c = a / b;
  
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}


contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

 
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }


  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];



    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

 
  function approve(address _spender, uint256 _value) returns (bool) {

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}
contract Ownable {
    
  address public owner;

  function Ownable() {
    owner = 0xA533265B173D83282B06090baCa4f3f22180F1eD;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

 
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}


contract BurnableToken is StandardToken {


  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }

  event Burn(address indexed burner, uint indexed value);

}



contract Crowdsale is Ownable {
    
  using SafeMath for uint;
    
  address multisig;

  uint found;
  uint p2p;
  uint command;
  address restricks;
  address restricksed;
  address restricted;

  
  
  SimpleCoinToken public token = new SimpleCoinToken();

  uint start;
    
  uint period;

  uint rate;

  function Crowdsale() {

    multisig = 0xA533265B173D83282B06090baCa4f3f22180F1eD;
    
    restricted = 0xA533265B173D83282B06090baCa4f3f22180F1eD;

    restricks = 0x3212E3aaa21437db40b525B5b204E11efb1b3247;

    restricksed = 0xB90F6F9c53F619B7655832fAD75A196B8D38761b;

    found = 30;
    p2p = 15;
    command = 70;
    rate = 200000000000000000000000;
    start = 1665418340;
    period = 300;
  }

  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }

  function createTokens() saleIsOn payable {
    multisig.transfer(msg.value);
    uint tokens = rate.mul(msg.value).div(1 ether);
    uint bonusTokens = 0;
    uint tokensWithBonus = tokens.add(bonusTokens);
    token.transfer(msg.sender, tokensWithBonus);
    uint restrictedTokens = tokens.mul(found)/100;
    uint restrictedTokens2 = tokens.mul(p2p)/100;
    uint restrictedTokens3 = tokens.mul(command)/100;
    token.transfer(restricted, restrictedTokens);
    token.transfer(restricks, restrictedTokens2);
    token.transfer(restricksed, restrictedTokens3);
  }

  function() external payable {
    createTokens();
  }
    
}
contract MintableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  
  event MintFinished();
 
  bool public mintingFinished = false;
 
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
 
  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }
 
  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}
contract SimpleCoinToken is MintableToken {
    
  string public constant name = "TOKENBARTER";
   
  string public constant symbol = "TKBR";
    
  uint32 public constant decimals = 18;

  uint256 public INITIAL_SUPPLY = 1000000000000000000000000000;

  function SimpleCoinToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
    
}