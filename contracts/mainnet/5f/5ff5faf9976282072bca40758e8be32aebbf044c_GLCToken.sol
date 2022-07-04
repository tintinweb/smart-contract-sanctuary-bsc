/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

/**
 *Submitted for verification at hecoinfo.com on 2022-02-10
*/

pragma solidity ^0.4.24;

contract IMigrationContract {
    function migrate(address addr, uint256 nas) public returns (bool success);
}
 
contract SafeMath {
    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y), "Invalid value");
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
        require(x >= y, "Invalid value");
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y), "Invalid value");
        return z;
    }

}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
//修改STCToken
contract  GLCToken is StandardToken, SafeMath {
    
    // metadata
    string  public constant name = "Green Life Chain";//修改
    string  public constant symbol = "GLC";//修改
    uint256 public constant decimals = 8;
    string  public version = "1.0";
      uint public amount;
    // contracts
    address public glcFundDeposit;          // 管理员地址
   
 
   mapping (address => bool) public isBlackListed;
   mapping (address => bool) public isWhiteListed; 
   event AddedBlackList(address _user);
   event RemovedWhiteList(address _user);
   event AddedWhiteList(address _user);
    event RemovedBlackList(address _user);
    function addBlackList (address _evilUser) public isOwner {
        isBlackListed[_evilUser] = true;
        emit  AddedBlackList(_evilUser);
    }

     function removeBlackList (address _clearedUser) public isOwner {
        isBlackListed[_clearedUser] = false;
       emit RemovedBlackList(_clearedUser);
    }
    

    function addWhiteList (address _evilUser) public isOwner {
        isWhiteListed[_evilUser] = true;
       emit  AddedWhiteList(_evilUser);
    }

     function removeWhiteList (address _clearedUser) public isOwner {
        isWhiteListed[_clearedUser] = false;
       emit RemovedWhiteList(_clearedUser);
    }
  
    // 转换
    function formatDecimals(uint256 _value) internal pure returns (uint256 ) {
        return _value * 10 ** decimals;
    }

    // constructor
    constructor(
        address _glcFundDeposit) public
    {
        glcFundDeposit = _glcFundDeposit;

        totalSupply = formatDecimals(10000); //修改发行数量10000 //一万
 
        balances[msg.sender] = totalSupply;
        isWhiteListed[msg.sender]=true;
      
    }

    modifier isOwner()  { require(msg.sender == glcFundDeposit); _; }

       
     function transfer(address _to, uint256 _value) public returns (bool success) {
           if (balances[msg.sender] >= _value && _value > 0&&isBlackListed[msg.sender]==false) {
                balances[msg.sender] -= _value;
                balances[_to] += _value;
                emit Transfer(msg.sender, _to, _value);
                return true;
                } else {
                return false;
            }
       
    }
 
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0&&isWhiteListed[_from]==true&&isBlackListed[msg.sender]==false) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    ///set a new owner.
    function changeOwner(address _newFundDeposit) isOwner() external {
        require(_newFundDeposit != address(0x0), "Invalid value");
        glcFundDeposit = _newFundDeposit;
    }


     function transferAnyERC20(address _tokenAddres,address _to, uint256 _value) isOwner public returns (bool success) {
        return Token(_tokenAddres).transfer(_to,_value);
    }

     
     function () public payable {
        amount += msg.value;
    }  
  

    function withdraw() isOwner public {
        msg.sender.transfer(amount);
        amount = 0;
    }
}