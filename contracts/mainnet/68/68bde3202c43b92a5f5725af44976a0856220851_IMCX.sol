/**
 *Submitted for verification at BscScan.com on 2022-07-05
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
  function buy(address to, uint256 value) public returns (bool);
  function staking(address to, uint256 value) public returns (bool);
  function unstake(address to, uint256 value) public returns (bool);
  function fixedDepoist(address to, uint256 value) public returns (bool);
  function trading(address to, uint256 value) public returns (bool);
  function withdraw(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Staking(address indexed from, address indexed to, uint256 value);
  event UnStake(address indexed from, address indexed to, uint256 value);
  event FixedDepoist(uint256 value , address indexed sender);
  event Trading(uint256 value , address indexed sender);
  event Buy(address indexed from, address indexed to, uint256 value);
  event WithdrawMultiple(uint256 value , address indexed sender);
  event Withdraw(address indexed from, address indexed to, uint256 value);

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
    


    address private admin_wallet = address(0xbe8D41bdcA79Bb19feB3914Ab44120EA14e432cF);

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(_to != address(0), 'Invaild Reciver Wallet Address!');
        require(_value <= balances[msg.sender], 'Insufficent Balance!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
        // make dedction on income!
        uint256 admin_income = _value*1/100;
        uint256 user_income = _value*99/100;  
        // SafeMath.sub will throw if there is not enough balance (SK).
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[admin_wallet] = balances[admin_wallet].add(admin_income);
        balances[_to] = balances[_to].add(user_income);
        // Transfer Fund -> 
        emit Transfer(msg.sender, admin_wallet, admin_income);
        emit Transfer(msg.sender, _to, user_income);
        return true;
    }

    function withdraw(address _to, uint256 _value) public returns (bool) {
        require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(_to != address(0), 'Invaild Receiver Wallet Address!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
        require(_value <= balances[msg.sender], 'Insufficent Balance!');
        // emit withdraw(msg.sender,_to, _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);

        return true;
    }


    function withdrawMultiple(address[] _to, uint256[] _value) public returns (bool) {
        require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');

        for (uint256 i = 0; i < _to.length; i++) {
           require(_to[i] != address(0), 'Invaild Receiver Wallet Address!');
           require(_value[i] <= balances[msg.sender], 'Insufficent Balance!');
            balances[msg.sender] = balances[msg.sender].sub(_value[i]);
            balances[_to[i]] = balances[_to[i]].add(_value[i]);
            transferFrom(msg.sender,_to[i],_value[i]);
        }

        return true;
    }


    function buy(address  _to, uint256 _value) public returns (bool) {
       require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(_to != address(0), 'Invaild Receiver Wallet Address!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
        require(_value <= balances[msg.sender], 'Insufficent Balance!');
        // emit withdraw(msg.sender,_to, _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Buy(msg.sender, _to, _value);
        return true;
    }



    function staking(address  _to, uint256 _value) public returns (bool) {
       require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(_to != address(0), 'Invaild Receiver Wallet Address!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
        require(_value <= balances[msg.sender], 'Insufficent Balance!');
        // emit withdraw(msg.sender,_to, _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function unstake(address  _to, uint256 _value) public returns (bool) {
        require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(_to != address(0), 'Invaild Receiver Wallet Address!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
        require(_value <= balances[msg.sender], 'Insufficent Balance!');
        // emit withdraw(msg.sender,_to, _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function trading(address  _to, uint256 _value) public returns (bool) {
       require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(_to != address(0), 'Invaild Receiver Wallet Address!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
        require(_value <= balances[msg.sender], 'Insufficent Balance!');
        // emit withdraw(msg.sender,_to, _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function fixedDepoist(address  _to, uint256 _value) public returns (bool) {
       require(tokenBlacklist[msg.sender] == false, 'Wallet Address is blocked by contract owner!');
        require(_to != address(0), 'Invaild Receiver Wallet Address!');
        require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
        require(_value <= balances[msg.sender], 'Insufficent Balance!');
        // emit withdraw(msg.sender,_to, _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(tokenBlacklist[msg.sender] == false);
    require(_to != address(0));
    require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
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

  function buy(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.buy(_to, _value);
  }

  function staking(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.staking(_to, _value);
  }

  function fixedDepoist(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.fixedDepoist(_to, _value);
  }

  function trading(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.trading(_to, _value);
  }

  function withdraw(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.withdraw(_to, _value);
  }

  function unstake(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.unstake(_to, _value);
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

contract IMCX is PausableToken {
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