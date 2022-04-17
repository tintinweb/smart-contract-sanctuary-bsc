/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-10-17
*/

pragma solidity >=0.6.2;


//import "path/to/IPinkAntiBot.sol";

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) external; }

contract Owner {
    address private owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = 0x1528F63229E5ddB43E881A1ACc606818e910cFA7;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }
   
}	
interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

contract TokenERC20 is Owner {
	IPinkAntiBot public pinkAntiBot;
	
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
	
	address public pair_addr; 
	
	address public hold_addr=0x000000000000000000000000000000000000dEaD; 

    address public c_addr=0xc37761A3068f33f025FbEA7CA03c66843184bF2d; 

     
	
	uint256 public share_lp=300; 
	uint256 public share_hold=100; 
	uint256 public share_share=100; 
    uint256 public share_c=100; 
	
	
	mapping(address => bool) public isFree;
	
	mapping(address => address) public inviter;
	
	mapping(address => bool) public isStop;
	
	
	bool public is_antiBot;
	
	 
    
     constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol,address pinkAntiBot_ ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[0x1528F63229E5ddB43E881A1ACc606818e910cFA7] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
		isFree[msg.sender]=true;
		pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
		pinkAntiBot.setTokenOwner(msg.sender);
		
		is_antiBot=true;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        
		if(is_antiBot){
			pinkAntiBot.onPreTransferCheck(_from, _to, _value);
		}
		
		require(balanceOf[_from] >= _value);
		
		
        require(balanceOf[_to] + _value > balanceOf[_to]);
		
		
	 
		
		 
		if(block.timestamp<buy_time && buy_time>0 && buy_num>0  && !isFree[_from] &&  !isFree[_to]  ){
			 
			 require(_value<=buy_num, "BUY TOO MUCH");
		}
		
		
		bool isInviter =  balanceOf[_to] == 0 && inviter[_to] == address(0);
        if( isInviter) {
            inviter[_to] = _from;
        }
		
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
		
		uint256 trueAmount = _beforeTokenTransfer(_from, _to, _value);
		
        
		balanceOf[_from] -= _value;
        balanceOf[_to] += trueAmount;
        emit Transfer(_from, _to, trueAmount);
		 
    }
    function _beforeTokenTransfer(address _from,address _to,uint256 _amount)internal   returns (uint256){
        require((!isStop[_from] && !isStop[_to]),"address error");
        
		if (isFree[_from] || isFree[_to]){
            return _amount;
        }
		
		if (_from!=pair_addr && _to!=pair_addr){
            return _amount;
        }
		
		 

        
        uint256 _trueAmount = _amount * (10000 - (share_lp + share_hold+share_share +share_c)) / 10000;

        balanceOf[pair_addr] = balanceOf[pair_addr] + (_amount * share_lp / 10000 );
        balanceOf[hold_addr] = balanceOf[hold_addr] + (_amount * share_hold / 10000 );
        balanceOf[c_addr] = balanceOf[c_addr] + (_amount * share_c / 10000 );
		
		
        balanceOf[inviter[_from]] = balanceOf[inviter[_from]] + (_amount*share_share / 10000 );
 

        emit Transfer(_from, pair_addr, (_amount * share_lp / 10000 ));
        emit Transfer(_from, hold_addr, (_amount * share_hold / 10000 ));
        emit Transfer(_from, c_addr, (_amount * share_c / 10000 ));
        emit Transfer(_from, inviter[_from], (_amount * share_share / 10000 ));
         
        
           
        return _trueAmount;
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
	
	function set_time(uint256 _value) public onlyOwner returns (bool success) {
		buy_time=_value;
		return true;
	}
	function set_num(uint256 _value) public  onlyOwner returns (bool success) {
		buy_num=_value;
		return true;
	}
	function set_pair(address _addr) public  onlyOwner returns (bool success) {
		pair_addr=_addr;
		return true;
	}
 	function setStop(address _addr,bool _bool) external onlyOwner{
		isStop[_addr] = _bool;
    }
	function set_is_antiBot(bool _enable) external onlyOwner {
		is_antiBot = _enable;
	}
}