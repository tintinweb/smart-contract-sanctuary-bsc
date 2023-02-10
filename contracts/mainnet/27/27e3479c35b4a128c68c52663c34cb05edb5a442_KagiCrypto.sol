/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

/**

$$\   $$\                 $$\        $$$$$$\                             $$\              
$$ | $$  |                \__|      $$  __$$\                            $$ |            
$$ |$$  /$$$$$$\  $$$$$$\ $$\       $$ /  \__|$$$$$$\ $$\   $$\ $$$$$$\$$$$$$\   $$$$$$\  
$$$$$  / \____$$\$$  __$$\$$ |      $$ |     $$  __$$\$$ |  $$ $$  __$$\_$$  _| $$  __$$\
$$  $$<  $$$$$$$ $$ /  $$ $$ |      $$ |     $$ |  \__$$ |  $$ $$ /  $$ |$$ |   $$ /  $$ |
$$ |\$$\$$  __$$ $$ |  $$ $$ |      $$ |  $$\$$ |     $$ |  $$ $$ |  $$ |$$ |$$\$$ |  $$ |
$$ | \$$\$$$$$$$ \$$$$$$$ $$ |      \$$$$$$  $$ |     \$$$$$$$ $$$$$$$  |\$$$$  \$$$$$$  |
\__|  \__\_______|\____$$ \__|       \______/\__|      \____$$ $$  ____/  \____/ \______/
                 $$\   $$ |                           $$\   $$ $$ |                      
                 \$$$$$$  |                           \$$$$$$  $$ |                      
                  \______/                             \______/\__|                      
*/


// Symbol      : KGC
// Name        : Kagi Crypto
// Total supply: 100 billion
// Decimals    : 18
// ---------------------------------------------------------------------------- >>>>


// Just Send 0 BNB to this contract address
// You will get free KGC automatically
// Each wallet address can only claim once
// The Top 250 Holders will be rewarded monthly for 5 years
// Reward claims will continue to decrease if more and more people make claims
// Keep Watching https://twitter.com/KagiCrypto
// Website : https://kagicrypto.xyz/

// Distribution

/** Tokenomics 100 billion supply

- 70% Community Claim.
- 10% Top 250 holder rewards.
-  5% Development.
-  5% Dex exchange liquidity.
-  5% Kagi Crypto NFT.
-  3% Bounty and Airdrops.
-  2% Team.

/**


 $$$$$$\ $$\         $$\                                            $$\       $$\   $$\         $$\      $$\
$$  __$$\$$ |        \__|                                           $$ |      $$ |  $$ |        $$ |     $$ |
$$ /  \__$$ |$$$$$$\ $$\$$$$$$\$$$$\         $$$$$$\ $$$$$$$\  $$$$$$$ |      $$ |  $$ |$$$$$$\ $$ |$$$$$$$ |
$$ |     $$ |\____$$\$$ $$  _$$  _$$\        \____$$\$$  __$$\$$  __$$ |      $$$$$$$$ $$  __$$\$$ $$  __$$ |
$$ |     $$ |$$$$$$$ $$ $$ / $$ / $$ |       $$$$$$$ $$ |  $$ $$ /  $$ |      $$  __$$ $$ /  $$ $$ $$ /  $$ |
$$ |  $$\$$ $$  __$$ $$ $$ | $$ | $$ |      $$  __$$ $$ |  $$ $$ |  $$ |      $$ |  $$ $$ |  $$ $$ $$ |  $$ |
\$$$$$$  $$ \$$$$$$$ $$ $$ | $$ | $$ |      \$$$$$$$ $$ |  $$ \$$$$$$$ |      $$ |  $$ \$$$$$$  $$ \$$$$$$$ |
 \______/\__|\_______\__\__| \__| \__|       \_______\__|  \__|\_______|      \__|  \__|\______/\__|\_______|
                                                                                                             
                                                                                                             
                                                                                                           
*/


pragma solidity ^0.4.22;

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

contract Owned {
    address public owner;
    address public newOwner;

}
   
contract ForeignToken {
    function balanceOf(address _owner) constant public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Token {
    function distr(address _to, uint256 _value) external returns (bool);
    function totalSupply() constant external returns (uint256 supply);
    function balanceOf(address _owner) constant external returns (uint256 balance);
}

contract KagiCrypto is ERC20 {

 
   
    using SafeMath for uint256;
    address owner = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public blacklist;

    string public constant name = "Kagi Crypto";
    string public constant symbol = "KGC";
    uint public constant decimals = 18;
   
uint256 public totalSupply = 100000000000e18;
   
uint256 public totalDistributed = 30000000000e18;
   
uint256 public totalRemaining = totalSupply.sub(totalDistributed);
   
uint256 public value = 500000e18;



    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
   
    event Distr(address indexed to, uint256 amount);
    event DistrFinished();
   
    event Burn(address indexed burner, uint256 value);

    bool public distributionFinished = false;
   
    modifier canDistr() {
        require(!distributionFinished);
        _;
    }
   
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
   
    modifier onlyWhitelist() {
        require(blacklist[msg.sender] == false);
        _;
    }

    function KGC() onlyOwner public {
        owner = msg.sender;
        balances[owner] = totalDistributed;
    }
   
    function finishDistribution() onlyOwner canDistr public returns (bool) {
        distributionFinished = true;
        emit DistrFinished();
        return true;
    }
   
    function distr(address _to, uint256 _amount) canDistr private returns (bool) {
        totalDistributed = totalDistributed.add(_amount);
        totalRemaining = totalRemaining.sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Distr(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
       
        if (totalDistributed >= totalSupply) {
            distributionFinished = true;
        }
    }
   
    function () external payable {
        getTokens();
     }
   
    function getTokens() payable canDistr onlyWhitelist public {
        if (value > totalRemaining) {
            value = totalRemaining;
        }
       
        require(value <= totalRemaining);
       
        address investor = msg.sender;
        uint256 toGive = value;
       
        distr(investor, toGive);
       
        if (toGive > 0) {
            blacklist[investor] = true;
        }

        if (totalDistributed >= totalSupply) {
            distributionFinished = true;
        }
       
        value = value.div(500000).mul(499999);
    }

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
   
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {
        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
       
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
   
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {
        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
       
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
   
    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
   
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
   
    function getTokenBalance(address tokenAddress, address who) constant public returns (uint){
        ForeignToken t = ForeignToken(tokenAddress);
        uint bal = t.balanceOf(who);
        return bal;
    }
   
    function withdraw() onlyOwner public {
        uint256 BNBBalance = address(this).balance;
        owner.transfer(BNBBalance);
    }
   
    function burn(uint256 _value) onlyOwner public {
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        totalDistributed = totalDistributed.sub(_value);
        emit Burn(burner, _value);
    }
   
    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
}