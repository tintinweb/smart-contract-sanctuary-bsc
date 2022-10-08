/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

/**
 *Submitted for verification at Etherscan.io on 2017-07-06
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

}
contract ERC20TOKEN is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	address payable public owner;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public freezeOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint8) public whiteList;
    uint8 public whiteListSwitch;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);
	
	/* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
	
	/* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor (
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol,
        uint8 decimalUnits
        ) {
        balanceOf[msg.sender] = initialSupply * 10 ** uint256(decimalUnits);              // Give the creator all initial tokens
        totalSupply = initialSupply * 10 ** uint256(decimalUnits);                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
		owner = payable(msg.sender);
        whiteListSwitch = 1;
    }

    function _checkWhiteList(address _address) view internal{
        if (whiteListSwitch == 1){
            require(whiteList[_address] == 1 ,"not in white list");
        }
        
    }

    function addToWhiteList(address[] memory _addressArray)  public{
        for (uint i=0 ; i<_addressArray.length ; i++){
            whiteList[_addressArray[i]] = 1;
        }
    }

    function removeFromWhiteList(address _address)  public{
        whiteList[_address] = 0;
    }

    function openWhiteList()  public{
        whiteListSwitch = 1;
    }

    function closeWhiteList()  public{
        whiteListSwitch = 0;
    }    

    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool){
        _checkWhiteList(_to);
        // if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address. Use burn() instead
        // require (_to != address(0x0)," Prevent transfer to 0x0 address. Use burn() instead");
		// if (_value <= 0) throw; 
        require(_value > 0 ,"value must be > 0");
        // if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        require(balanceOf[msg.sender] >= _value,"not enough balance");
        // if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to],"overflows");
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public returns (bool) {
		// if (_value <= 0) throw; 
        require(_value > 0,"value must be >0");
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        _checkWhiteList(_to);

        // if (_to == 0x0) throw;                                // Prevent transfer to 0x0 address. Use burn() instead
		// if (_value <= 0) throw; 
        require(_value > 0,"value must be > 0");
        // if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        require(balanceOf[_from] >= _value,"not enough balance");
        // if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to],"owerflows");
        // if (_value > allowance[_from][msg.sender]) throw;     // Check allowance
        require(_value <= allowance[_from][msg.sender],"not enough allowance");
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool) {
        // if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
        require(balanceOf[msg.sender] >= _value,"balance not enough");
		// if (_value <= 0) throw; 
        require(_value > 0,"value must be > 0");
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
	
	function freeze(uint256 _value) public returns (bool) {
        // if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
        require(balanceOf[msg.sender] >= _value,"not enough balance");
		// if (_value <= 0) throw; 
        require(_value > 0,"value must be > 0");
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply
        emit Freeze(msg.sender, _value);
        return true;
    }
	
	function unfreeze(uint256 _value) public returns (bool) {
        // if (freezeOf[msg.sender] < _value) throw;            // Check if the sender has enough
        require(freezeOf[msg.sender] >= _value ,"freeze balance not enough");
		// if (_value <= 0) throw; 
        require(_value >0,"value must be > 0");
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }
	
	// transfer balance to owner
	function withdrawEther(uint256 amount) public {
		// if(msg.sender != owner)throw;
        require(msg.sender == owner,"address must be owner");
		owner.transfer(amount);
	}
	
	// can accept ether
	// function() payable {
    // }
    // can accept ether
    receive() external payable {}
    fallback() external payable {}
}