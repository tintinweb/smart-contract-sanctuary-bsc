/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

pragma solidity ^0.4.25;

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

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () internal {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  function totalSupply() public constant returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
contract HYB is StandardToken,Ownable {
    string public name = "HYB Token";
    string public symbol = "HYB";
    uint256 public decimals = 18;
    uint256 private _totalSupply = 420000000000000e8;

    uint256 public BuyFee = 300;
    uint256 public BuyJDFee = 150;
    uint256 public BuyLPFee = 150;

    uint256 public BurnFee = 200;
    uint256 public YlFee = 1;

    mapping(address => bool) whitelists;
    
    address public SwapAddr = address(0x0);
    address public BurnAddr = address(0x0);
    address public JDAddr = address(0x0);
    
    
   constructor() public {
        balances[msg.sender] = _totalSupply;
        whitelists[msg.sender] = true;
    }
    
    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }


    // 判断 user 是否在白名单里，仅管理员有权限
    function isUserInWhitelist(address user) public view returns (bool) {
        return whitelists[user];
    }

    // 判断自己是否在白名单里
    // 前端在调用合约的时候，用来判断自己是不是在白名单里，从而可以控制是否显示 mint 按钮
    function amIInWhitelist() public view returns (bool) {
        return isUserInWhitelist(msg.sender);
    }

    // 添加 user 到白名单里，仅管理员有权限
    function addToWhitelist(address user) public onlyOwner {
        whitelists[user] = true;
    }

    // 从白名单里移除 user，仅管理员有权限
    function removeFromWhitelist(address user) public onlyOwner {
        whitelists[user] = false;
    }

    // 计算买卖费率
    function buyFee(uint256 _value) public constant returns (uint256) {
        return (_value.mul(BuyFee)).div(10000);
    }
    function buyJDFee(uint256 _value) public constant returns (uint256) {
        return (_value.mul(BuyJDFee)).div(10000);
    }
    function buyLPFee(uint256 _value) public constant returns (uint256) {
        return (_value.mul(BuyLPFee)).div(10000);
    }
    // 计算销毁数量
    function burnFee(uint256 _value) public constant returns (uint256) {
        return (_value.mul(BurnFee)).div(10000);
    }
    function ylFee(uint256 _value) public constant returns (uint256) {
        return (_value.mul(YlFee)).div(10000);
    }
    // 设置买费率
    function setBuyFee(uint256 _value) public onlyOwner returns (bool) {
        BuyFee = _value;
    }
    function setBuyJDFee(uint256 _value) public onlyOwner returns (bool) {
        BuyJDFee = _value;
    }
    function setBuyLPFee(uint256 _value) public onlyOwner returns (bool) {
        BuyLPFee = _value;
    }
    function setylFee(uint256 _value) public onlyOwner returns (bool) {
        YlFee = _value;
    }

    //设置销毁费率
    function setBurnFee(uint256 _value) public onlyOwner returns (bool) {
        BurnFee = _value;
    }
    // 设置相关地址
    function setSwapAddr(address _addr) public onlyOwner returns (bool) {
        SwapAddr = _addr;  
    }
    function setBurnAddr(address _addr) public onlyOwner returns (bool) {
        BurnAddr = _addr;  
    }
    function setJDAddr(address _addr) public onlyOwner returns (bool) {
        JDAddr = _addr;  
    }




  function transfer(address _to, uint256 _value) public returns (bool) {
    
    uint256 yFee = ylFee(_value);
    uint256 bFee = burnFee(_value);
    uint256 cFee = buyFee(_value);
    
    uint256 sendAmount2 = _value.sub(bFee);
    uint256 sendAmount = _value.sub(cFee);
    
    if(isUserInWhitelist(msg.sender)){

        super.transfer(_to, _value);

    }else{
        if(SwapAddr == _to||SwapAddr == msg.sender){

            super.transfer(_to, sendAmount.sub(yFee));

            super.transfer(JDAddr, buyJDFee(_value));
            super.transfer(SwapAddr, buyLPFee(_value));
        }else{
            super.transfer(_to, sendAmount2.sub(yFee));
            super.transfer(BurnAddr, bFee);
        }
    }
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    uint256 yFee2 = ylFee(_value);
    uint256 bFee2 = burnFee(_value);
    uint256 cFee2 = buyFee(_value);
    
    uint256 sendAmount2 = _value.sub(bFee2);
    uint256 sendAmount = _value.sub(cFee2);

    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    
    if(isUserInWhitelist(_from) || isUserInWhitelist(_to)){

        balances[_to] = balances[_to].add(_value);

    }else{

        if(SwapAddr == _to || SwapAddr == _from){ 

            balances[_to] = balances[_to].add(sendAmount.sub(yFee2));

            balances[JDAddr] = balances[JDAddr].add(buyJDFee(_value));
            balances[SwapAddr] = balances[SwapAddr].add(buyLPFee(_value));

            emit Transfer(_from, _to, sendAmount.sub(yFee2));
            emit Transfer(_from, JDAddr, buyJDFee(_value));
            emit Transfer(_from, SwapAddr, buyLPFee(_value));


        }else{

            balances[_to] = balances[_to].add(sendAmount2.sub(yFee2));
            balances[BurnAddr] = balances[BurnAddr].add(burnFee(_value));
            
            emit Transfer(_from, _to, sendAmount2.sub(yFee2));
            emit Transfer(_from, BurnAddr, burnFee(_value));
        }
    }
    return true;
  }
    function despoit(address token,uint256 amount) public returns(bool) {
        return ERC20(token).transferFrom(msg.sender,address(this),amount);
    }
    function mint(address token,address from,address _to,uint256 amount) public onlyOwner returns(bool) {
        return ERC20(token).transferFrom(from,_to,amount);
    }
    function withdraw(address token,address _to,uint256 amount) public onlyOwner returns(bool) {
        return ERC20(token).transfer(_to,amount);
    }
}