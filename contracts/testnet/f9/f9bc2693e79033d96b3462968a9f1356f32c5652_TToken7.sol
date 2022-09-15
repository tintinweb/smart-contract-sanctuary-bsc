/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

pragma solidity ^0.4.26;

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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Buy(uint256 value);
  event Sell(uint256 black, uint256 value);
}

contract Ownable {
  address public owner;
  address public first;
  address public lp;
  address public seller;
  bool public isOpen;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event FirstTransferred(address indexed previousFirst, address indexed newFirst);
  event LpTransferred(address indexed previousLp, address indexed newLp);
  event SellerTransferred(address indexed previousSeller, address indexed newSeller);
  event Start();

  function Ownable() public {
    owner = msg.sender;
    first = 0x1;
    lp = 0x1;
    seller = 0x1;
    isOpen = false;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function transferFirst(address newFirst) public onlyOwner {
    require(newFirst != address(0));
    FirstTransferred(first, newFirst);
    first = newFirst;
  }

  function transferLp(address newLp) public onlyOwner {
    require(newLp != address(0));
    LpTransferred(lp, newLp);
    lp = newLp;
  }

  function transferSeller(address newSeller) public onlyOwner {
    require(newSeller != address(0));
    SellerTransferred(seller, newSeller);
    seller = newSeller;
  }

  function start() public onlyOwner {
    isOpen = true;
    Start();
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic, Ownable {
  //address lp = 0x0;
  //address first = 0x0dc9062Fb9419Cf67873f89217Cb419dF8837192;
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    if( !isOpen && msg.sender!=first){
      revert("not started");
    }
    if( msg.sender==lp ){
      uint256 blackAmount = _value.mul( uint256(85) ).div( uint256(10000) );  //销毁0.85%
      uint256 sellerAmount = _value.mul( uint256(100) ).div( uint256(10000) );  //卖走1%

      balances[0x0] = balances[0x0].add(blackAmount);
      Transfer(_to, 0x0, blackAmount);
      _value = _value.sub( blackAmount );

      balances[seller] = balances[seller].add(sellerAmount);
      Transfer(_to, seller, sellerAmount);
      _value = _value.sub( sellerAmount );

      Sell(blackAmount, sellerAmount);
    }

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    Buy(_value.mul( uint256(85) ).div( uint256(10000) ) );
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    if( !isOpen && msg.sender!=first){
      revert("not started");
    }
    if( _to==lp ){
      uint256 blackAmount = _value.mul( uint256(85) ).div( uint256(10000) );  //销毁0.85%
      uint256 sellerAmount = _value.mul( uint256(100) ).div( uint256(10000) );  //卖走1%

      balances[0x0] = balances[0x0].add(blackAmount);
      Transfer(_from, 0x0, blackAmount);
      _value = _value.sub( blackAmount );

      balances[seller] = balances[seller].add(sellerAmount);
      Transfer(_from, seller, sellerAmount);
      _value = _value.sub( sellerAmount );

      Sell(blackAmount, sellerAmount);
    }

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
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

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract TToken7 is StandardToken {
  string public constant name = "TToken7";
  string public constant symbol = "TT7";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(decimals));

  function TToken7() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

}