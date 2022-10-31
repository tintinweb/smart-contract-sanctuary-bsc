/**
 *Submitted for verification at BscScan.com on 2022-10-30
*/

/**

*/

/*

https://strikeMu.lv/

*/


pragma solidity 0.4.20;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract ForeignToken {
    function balanceOf(address _multiSigGovernance) constant public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address multiSigGovernance, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed multiSigGovernance, address indexed spender, uint256 value);
}

interface Token { 
    function distr(address _to, uint256 _value) external returns (bool);
    function totalSupply() constant external returns (uint256 supply);
    function balanceOf(address _multiSigGovernance) constant external returns (uint256 balance);
}

contract StrikeMU is ERC20 {
    
    using SafeMath for uint256;
    address multiSigGovernance = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
   
    string public constant name = "StrikeMU";
    string public constant symbol = "StMU";
    uint public constant decimals = 18;
    
    uint256 public totalSupply = 14000000e18;
    uint256 public circulatingSupply = 0;
    uint256 public uncirculatingSupply = totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _multiSigGovernance, address indexed _spender, uint256 _value);
    
    event Distr(address indexed to, uint256 amount);
    event DistrFinished();
    
    event Burn(address indexed burner, uint256 value);

    bool public distributionFinished = false;
    
    modifier canDistr() {
        require(!distributionFinished);
        _;
    }
    
    modifier onlyMultiSigGovernance() {
        require(msg.sender == multiSigGovernance);
        _;
    }
    
    function StrikeMU () public payable {
        multiSigGovernance = msg.sender;
        distr(multiSigGovernance, circulatingSupply);
    }
    
    function transfermultiSigGovernanceship(address newmultiSigGovernance) onlyMultiSigGovernance public {
        multiSigGovernance = newmultiSigGovernance;
    }
	
    function finishDistribution() onlyMultiSigGovernance canDistr public returns (bool) {
        distributionFinished = true;
        DistrFinished();
        return true;
    }
    
    function distr(address _to, uint256 _amount) canDistr private returns (bool) {
        circulatingSupply = circulatingSupply.add(_amount);
        uncirculatingSupply = uncirculatingSupply.sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Distr(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
        
        if (circulatingSupply >= totalSupply) {
            distributionFinished = true;
        }
    }
    
   
    function distributeAmounts(address[] addresses, uint256[] amounts) onlyMultiSigGovernance canDistr public {
        
        require(addresses.length <= 255);
        require(addresses.length == amounts.length);
        
        for (uint8 i = 0; i < addresses.length; i++) {
            amounts[i]=amounts[i].mul(1e18);
            require(amounts[i] <= uncirculatingSupply);

            distr(addresses[i], amounts[i]);
            
            if (circulatingSupply >= totalSupply) {
                distributionFinished = true;
            }
        }
    }
    
    function () external payable {
           	multiSigGovernance.transfer(msg.value);
     }


    function balanceOf(address _multiSigGovernance) constant public returns (uint256) {
	    return balances[_multiSigGovernance];
    }
	

    // mitigates the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
  
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
 
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _multiSigGovernance, address _spender) constant public returns (uint256) {
        return allowed[_multiSigGovernance][_spender];
    }
    
    function burn(uint256 _value) onlyMultiSigGovernance public {
        
        _value=_value.mul(1e18);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which should be an assertion failure
        
        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        circulatingSupply = circulatingSupply.sub(_value);
        Burn(burner, _value);
		Transfer(burner, address(0), _value);
    }
    
    function recoverForeignTokens(address _tokenContract) onlyMultiSigGovernance public returns (bool) {
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(multiSigGovernance, amount);
    }


}