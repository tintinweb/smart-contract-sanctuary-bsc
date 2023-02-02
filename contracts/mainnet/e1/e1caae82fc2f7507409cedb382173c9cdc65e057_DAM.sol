/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
 *Submitted for verification at BscScan.com on 2021-06-30
*/

pragma solidity 0.8.2;

library  SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


contract DAM {
    using SafeMath for *;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address=>uint256)public balanceOf;
    address  private  owner;
    
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    event Approveal(address indexed _owner, address indexed _spender, uint _value);
    
    constructor(string memory _name,string memory _symbol,uint8 _decimals,uint256 _totalSupply)public{
        name=_name;
        symbol=_symbol;
        decimals=_decimals;
        totalSupply=_totalSupply*10**uint256(_decimals);
        balanceOf[msg.sender]=totalSupply;
        owner=msg.sender;
        emit Transfer(address(0x0),owner,totalSupply);
    }
    
    
    function transfer(address _to, uint256 _value)public returns(bool) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
     function _transfer(address _from,address _to, uint256 _value)private returns(bool) {
        require(_to != address(0x0));
		require(_value > 0);
        require (balanceOf[_from]>= _value);  
        require(balanceOf[_to] + _value > balanceOf[_to]); 
        balanceOf[_from] = SafeMath.sub(balanceOf[_from], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);                            // Add the same to the recipient
        emit Transfer(_from, _to, _value);                   // Notify anyone listening that this transfer took place
     }
     function transferFrom(address _from, address _to, uint256 _value)public  returns (bool success) {
        require (_value <= allowance[_from][msg.sender]);     // Check allowance
        _transfer(_from,_to,_value);
        allowance[_from][msg.sender] = SafeMath.sub(allowance[_from][msg.sender], _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value)public returns (bool success) {
		require (_value > 0) ; 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    receive() payable external{
        
    }
    
    // transfer balance to owner
	function withdrawEther(uint256 amount)public payable {
		require(owner==msg.sender);
		payable(owner).transfer(amount);
	}
}