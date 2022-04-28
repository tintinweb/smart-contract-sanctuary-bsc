/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-10-17
*/

pragma solidity >=0.6.2;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) external; }

contract Owner {
    address private owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }
   
}	

contract TokenERC20 is Owner {
    string public name;
    string public symbol;
    uint8 public decimals = 18;  // 18 是建议的默认值
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
	
	uint256 public buy_time = 0; 
	uint256 public buy_num = 0; 
	mapping(address => bool) public isFree;
	
	mapping(address => bool) public is_black;
	
	mapping(address => bool) public is_no_share;
	
	mapping(address => address) public inviter;
	
	 
    
     constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
		isFree[msg.sender]=true;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
		
		require(!is_black[_from]);
		require(!is_black[_to]);
		
		  
		if(block.timestamp<buy_time && buy_time>0 && buy_num>0  && !isFree[_from] &&  !isFree[_to]  ){
			 
			 require(_value<=buy_num, "BUY TOO MUCH");
		}
		 
		bool isInviter =  balanceOf[_to] == 0 && inviter[_to] == address(0);
        if( isInviter && !is_no_share[_from]) {
            inviter[_to] = _from;
        }
		
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
		
		
		 
		
		
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    
    function setFree(address _addr,bool _bool) external onlyOwner{
		isFree[_addr] = _bool;
    }
	
	function set_is_black(address _addr,bool _bool) external onlyOwner{
		isFree[_addr] = _bool;
    }
	
	 
	
	
	function set_time(uint256 _value) public onlyOwner returns (bool success) {
		buy_time=_value;
		return true;
	}
	function set_num(uint256 _value) public  onlyOwner returns (bool success) {
		buy_num=_value;
		return true;
	}
	function set_is_no_share(address _addr,bool _bool) public  onlyOwner returns (bool success) {
		 
		is_no_share[_addr] = _bool;
		return true;
	}
	 
}