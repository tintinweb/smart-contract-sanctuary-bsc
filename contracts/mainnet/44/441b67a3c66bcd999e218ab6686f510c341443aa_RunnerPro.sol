/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

/*
  _____                                  _____           
 |  __ \                                |  __ \          
 | |__) |   _ _ __  _ __   ___ _ __     | |__) | __ ___  
 |  _  / | | | '_ \| '_ \ / _ \ '__|    |  ___/ '__/ _ \ 
 | | \ \ |_| | | | | | | |  __/ |       | |   | | | (_) |
 |_|  \_\__,_|_| |_|_| |_|\___|_|       |_|   |_|  \___/ 
                                                         
  */                                                      
pragma solidity 0.6.0;
/*
 * @creator: Runner Pro
 * @title  : BEP20 Token
 * @dev
 *
 */

abstract contract IBEP20 {

/**
   * @dev Returns the token decimals.
   */
  function decimals()  virtual public view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() virtual public view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() virtual public view returns (string memory);



    
    function totalSupply() virtual public view returns (uint);
    function balanceOf(address tokenOwner) virtual public view returns (uint);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint);
    function transfer(address to, uint tokens) virtual public returns (bool);
    function approve(address spender, uint tokens) virtual public returns (bool);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract SafeMath {
    
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}


contract RunnerPro is IBEP20, SafeMath {
    string public _name;
    string public _symbol;
    uint8 public _decimals; 
    
    uint256 public _totalSupply;
    address public owner;


    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    constructor() public {

        _name = "RunnerPro";
        _symbol = "RPO";
        _decimals = 18;
        owner = msg.sender;
        _totalSupply = 50000000 * 10 ** uint256(_decimals);   // 8 decimals 
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    /**
     * @dev allowance : Check approved balance
     */
    function allowance(address tokenOwner, address spender) virtual override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    /**
   * @dev Returns the token symbol.
   */
  function symbol() virtual override public view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() virtual override public view returns (string memory) {
    return _name;
  }

/**
   * @dev Returns the token decimals.
   */
  function decimals() virtual override public view returns (uint8) {
    return _decimals;
  }
    /**
     * @dev approve : Approve token for spender
     */ 
    function approve(address spender, uint tokens) virtual override public returns (bool success) {
        require(tokens >= 0, "Invalid value");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address to, uint tokens) virtual override public returns (bool success) {
        require(to != address(0), "Null address");                                         
        require(tokens > 0, "Invalid Value");
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    /**
     * @dev transferFrom : Transfer token after approval 
     */ 
    function transferFrom(address from, address to, uint tokens) virtual override public returns (bool success) {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(tokens > 0, "Invalid value"); 
        require(tokens <= balances[from], "Insufficient balance");
        require(tokens <= allowed[from][msg.sender], "Insufficient allowance");
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    /**
     * @dev totalSupply : Display total supply of token
     */ 
    function totalSupply() virtual override public view returns (uint) {
        return _totalSupply;
    }
    
    /**
     * @dev balanceOf : Displya token balance of given address
     */ 
    function balanceOf(address tokenOwner) virtual override public view returns (uint balance) {
        return balances[tokenOwner];
    }
    function renounceOwnership() public  {
        require(msg.sender == owner);
        owner = address(0);
        }
 

}