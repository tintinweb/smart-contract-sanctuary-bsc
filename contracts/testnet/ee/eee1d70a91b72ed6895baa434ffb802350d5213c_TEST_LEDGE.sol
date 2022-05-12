/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

pragma solidity >=0.5.16;



library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}
}
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

 

pragma solidity >=0.5.16;

 

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
 

pragma solidity >=0.5.16;

 

 

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


 

pragma solidity >=0.5.16;


contract TEST_LEDGE  is Owner  {
    using SafeMath for uint;

   
    mapping(address => uint) public amount_lists;
    mapping(address => uint) public user_amount_lists;
	 
  
 
    address public token=0x599A38C9c548b100B17c70841013cb8e9Bfd18D9;

    address public get_token=0x56032104E6824AC28AB77b066af35F384a411a41;
    
	
	mapping(address =>bool) public is_in_holder_lists;
	 
	address[] public holder_lists;
    mapping(address =>uint256) public holder_lists_index;
	
	uint256 public amount;
	
	uint256 public last_time;
	
	uint256 public day_output=219178082191780800000000;//54794520547945210000000
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'TEST LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
	 
    function set_token(address _addr) external onlyOwner{
		token = _addr;
    }
    function set_get_token(address _addr) external onlyOwner{
		get_token = _addr;
    }
    function set_day_output(uint256 value) external onlyOwner{
		day_output = value;
    }
     
    function add_ledge(address token_addr, uint256 value) public lock returns (bool){
		
		require(value > 0, '');
		require(token_addr == token, 'NO TOKE');
 
		 
		if(last_time==0){
			last_time=block.timestamp;	
		}else{
			share_holder(); 
		}
		amount=amount.add(value);
		if(!is_in_holder_lists[msg.sender]){
			set_holder_lists(msg.sender);
		}
        amount_lists[msg.sender] = amount_lists[msg.sender].add(value);
		
		IERC20(token_addr).transferFrom(msg.sender,address(this),value);
		
		 
         return true;
    }
	 
	
	
	function remove_ledge(address token_addr, uint256 value) public lock returns (bool){
		
		require(value > 0, '');
		require(token == token_addr, 'NO TOKE');
		
		require(amount_lists[msg.sender]>=value, 'NO TOKE');
		
		share_holder(); 
		
		
		IERC20(token_addr).transfer(msg.sender,value);
		
        amount_lists[msg.sender] = amount_lists[msg.sender].sub(value);
		amount=amount.sub(value);
		return true;
		
         
    }
	function get_fee() public lock returns (bool){
		
		 
		
		share_holder(); 
		
		IERC20(get_token).transfer(msg.sender,user_amount_lists[msg.sender]);
		
        user_amount_lists[msg.sender] = 0;
		return true;
		 
		
         
    }
	 function share_holder() private {
		uint256 count= holder_lists.length;
		uint256 i = 0;
		 
		uint256 timestamp=block.timestamp;
		uint256 span=timestamp.sub(last_time);	
		uint256 amount_span=day_output.div(3600*24).mul(span);
		
		uint256 amount_tmp;
		while (i < count) {
            	 
			amount_tmp = amount_span.mul(amount_lists[holder_lists[i]]).div(amount);
			 
			user_amount_lists[holder_lists[i]]=user_amount_lists[holder_lists[i]].add(amount_tmp);
			 
			i++; 
		}
		last_time=timestamp;
	}
	 
	function set_holder_lists(address addr) private {
       if (is_in_holder_lists[addr]) {
            return;
        }
         
 
        add_holder(addr);
        is_in_holder_lists[addr] = true;

    }
	
    
    function add_holder(address addr) internal {
        holder_lists_index[addr] = holder_lists.length;
        holder_lists.push(addr);
    }
    function quit_holder_lists(address addr) private {
        remove_holder(addr);
        is_in_holder_lists[addr] = false;
    }
    function remove_holder(address addr) internal {
        holder_lists[holder_lists_index[addr]] = holder_lists[holder_lists.length - 1];
        holder_lists_index[holder_lists[holder_lists.length - 1]] = holder_lists_index[addr];
        holder_lists.pop();
    }
 
     


   
}