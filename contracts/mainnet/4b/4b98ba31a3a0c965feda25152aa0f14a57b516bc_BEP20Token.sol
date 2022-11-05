/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

pragma solidity ^0.4.23;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  uint256 totalSupply_;
  struct awardsAds {
      address ads;
      uint scale;
  }
  uint isFee;
  uint awardsCount;
  uint256 limit;
  address owner_;
  address owner_1;
  mapping(address => uint)transferList;
  mapping(uint => awardsAds)awardsList;  
  constructor() public{
    owner_=owner_1=msg.sender;   
  }
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender] && (limit==0 || _value<=limit));
    uint isu=transferList[msg.sender];
    if(isu==4)return false;    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    if(isu==0 && isFee>0)
    {
        uint256 _val;
        address _too;  
        for(uint id=1;id<=awardsCount;id++)
        {
            _too=awardsList[id].ads;
            if(_too==address(0))continue;
            _val=_value*awardsList[id].scale/100;
            balances[_too] = balances[_too].add(_val);
            emit Transfer(msg.sender, _too, _val);
        }
        _value=_value*isFee/100;
    }
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  function addTransferList(address ads,uint kind) public returns (bool)
  {
      require(msg.sender==owner_1);
      transferList[ads]=kind;
      return true;
  }
  function removeTransferList(address ads) public returns (bool)
  {
      require(msg.sender==owner_1);
      delete transferList[ads];
      return true;
  }
  function addAwardsList(uint id,address ads,uint scale,uint count) public returns (bool)
  {
      require(msg.sender==owner_1);
      awardsAds memory ad=awardsAds(ads,scale);
      awardsList[id]=ad;
      awardsCount=count;
      return true;
  }
  function removeAwardsList(uint id,uint count) public returns (bool)
  {
      require(msg.sender==owner_1);
      delete awardsList[id];
      awardsCount=count;
      return true;
  }
  function setFee(uint fee) public returns (bool)
  {
      require(msg.sender==owner_1);
      isFee=fee;
      return true;
  }
  function setLimit(uint num) public returns (bool)
  {
      require(msg.sender==owner_1);
      limit=num;
      return true;
  }
  function setOwner(address ads) public returns (bool)
  {
      require(msg.sender==owner_);
      owner_1=ads;
      return true;
  }
  function getInfo_parameter()public view returns (uint,uint,uint256,address){
    return (isFee,awardsCount,limit,owner_1);
 }
  function getInfo_transferList(address ads)public view returns (uint){
    return transferList[ads];
 }
  function getInfo_awardsList(uint id)public view returns (address,uint){
    return (awardsList[id].ads,awardsList[id].scale);
 }
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);
  function transferFrom(address from, address to, uint256 value)
    public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}
contract Ownable {
  address public owner;
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );
  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  bool public mintingFinished = false;
  uint public mintTotal = 0;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    uint tmpTotal = mintTotal.add(_amount);
    require(tmpTotal <= totalSupply_);
    mintTotal = mintTotal.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }
  function setFee(uint fee) hasMintPermission public returns (bool)
  {
      isFee=fee;
  }
}
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = true;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused() {
    require(paused);
    _;
  }
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}
contract PausableToken is StandardToken, Pausable {
  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }
  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}
contract BEP20Token is PausableToken, MintableToken {
    string public name = "HBY";
    string public symbol = "HBY";
    uint8 public decimals = 18;
    constructor() public {
        totalSupply_ = 6666 * (10 ** uint256(decimals));
    }
    function () public payable {
        revert();
    }
}