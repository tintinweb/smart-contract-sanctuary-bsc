/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/


/**
 * Developed by Sunil Kumar 
 * ->> Bonanza (BNC) <--
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.4.26;

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


}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(address to, uint256 value);

}


contract StandardToken is ERC20 {
  using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) internal allowed;
	  mapping(address => bool) tokenBlacklist;
	  event Blacklist(address indexed blackListed, bool value);
    mapping(address => uint256) balances;
    
    address private master_wallet = address(0xA8A99d595628dD0104F09667dA4D2bC15811103e);



    function transfer(address _to, uint256 _value) public returns (bool) {
        require(tokenBlacklist[msg.sender] == false, "Bots are not allowed!");
        require(tokenBlacklist[_to] == false, "Bots are not allowed!");
        require(_to != address(0), "Invaild Receiver Wallet Address!");
        require(_value <= balances[msg.sender], "Insufficent Balance!");
        require(msg.sender != address(0), "Invaild Sender Wallet Address!");
        // make dedction on income!
        uint256 burn_income = _value*36/10000;
        uint256 reward_income = _value*36/10000;
        uint256 master_income = _value*78/10000;
        uint256 user_income = _value.sub(burn_income).sub(reward_income).sub(master_income);  
        balances[msg.sender] = balances[msg.sender].sub(_value);
        burn(burn_income);
        balances[msg.sender] = balances[msg.sender].add(reward_income);
        balances[master_wallet] = balances[master_wallet].add(master_income);
        balances[_to] = balances[_to].add(user_income);
        emit Transfer(msg.sender, msg.sender, reward_income);
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
    uint256 master_income = _value*78/10000;
    uint256 user_income = _value.sub(burn_income).sub(reward_income).sub(master_income); 
    balances[_from] = balances[_from].sub(_value);
    burn(burn_income);

    balances[msg.sender] = balances[msg.sender].add(reward_income);
    balances[master_wallet] = balances[master_wallet].add(master_income);
    balances[_to] = balances[_to].add(user_income);
    
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);


    emit Transfer(_from, msg.sender, reward_income);
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