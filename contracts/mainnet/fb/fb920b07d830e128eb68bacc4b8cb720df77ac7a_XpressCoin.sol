/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

pragma solidity ^0.5.17;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/

contract BEP20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract XpressCoin is BEP20 {
    using SafeMath for uint256;
    
    string public constant name                         = "XpressCoin";                   	// Name of the token
    string public constant symbol                       = "XPC";                            // Symbol of token
    uint256 public constant decimals                    = 18;                               // Decimal of token
    uint256 public _totalsupply                      	= 200000000 * 10 ** decimals;       // 200 Million Total supply
    uint256 public _ieo                        			= 50000000 * 10 ** decimals;       	// 50 Million IEO
    uint256 public _marketing                           = 10000000 * 10 ** decimals;        // 10 Million for Marketing
    uint256 public _thinktanker                         = 14000000 * 10 ** decimals;        // 14 Million for thinktanker
    uint256 public _deployer                         	= 90000000 * 10 ** decimals;        // 90 Million for Deployer
    uint256 public _platform                         	= 36000000 * 10 ** decimals;        // 36 Million for Platform
	
    address public owner                                = msg.sender;                       // Owner of smart contract
   
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint)) public _allowances;
    
   
    // Only owner can access the function
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
    
    constructor(address ieo, address marketing, address thinktanker, address platform) public {
        
        // IEO Transfer
        balances[ieo]            	= _ieo;
        emit Transfer(address(this), ieo, _ieo);
         
		// Marketing Transfer
        balances[marketing]         = _marketing;
        emit Transfer(address(this), marketing, _marketing);
		
		// thinktanker Transfer
        balances[thinktanker]       = _thinktanker;
        emit Transfer(address(this), thinktanker, _thinktanker);
		
		// Platform Transfer
        balances[platform]          = _platform;
        emit Transfer(address(this), platform, _platform);
		
		// DEVELOPER Transfer
        balances[msg.sender]        = _deployer;
        emit Transfer(address(this), msg.sender, _deployer);
        
	}    
    
    // Show token balance of address owner
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    } 
        
    // Token transfer function
    // Token amount should be in 18 decimals (eg. 199 * 10 ** 18)
    function transfer(address _to, uint256 _amount )public returns (bool) {
        require(balances[msg.sender] >= _amount && _amount >= 0);
        
        balances[msg.sender]            = balances[msg.sender].sub(_amount);
        balances[_to]                   = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    // Transfer the balance from owner's account to another account
    function transferTokens(address _to, uint256 _amount) private returns (bool success) {
        require( _to != 0x0000000000000000000000000000000000000000);       
        require(balances[address(this)] >= _amount && _amount > 0);
        balances[address(this)] = balances[address(this)].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(address(this), _to, _amount);
        return true;
    }
    
    function allowance(address _owner, address spender) public view returns (uint) {
        return _allowances[_owner][spender];
    }
    
    function approve(address spender, uint amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        require(balances[sender] >= amount && amount >= 0);
        balances[sender]                = balances[sender].sub(amount);
        balances[recipient]             = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    function _approve(address _owner, address spender, uint amount) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    
    function totalSupply() public view returns (uint256 total_Supply) {
        total_Supply = _totalsupply;
    }
         
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
}

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
  
    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }
}