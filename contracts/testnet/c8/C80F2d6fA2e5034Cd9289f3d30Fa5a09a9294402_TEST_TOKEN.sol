/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

pragma solidity >=0.5.16;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
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

// File: contracts\libraries\Math.sol

pragma solidity >=0.5.16;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
// File: contracts\libraries\UQ112x112.sol

pragma solidity >=0.5.16;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

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
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


// File: contracts\PancakeERC20.sol

pragma solidity >=0.5.16;


contract TEST_TOKEN     {
    using SafeMath for uint;

    string public constant name = 'TEST-LP';
    string public constant symbol = 'TEST-LP';
    uint8 public constant decimals = 8;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
	mapping(address => uint) public user_amount_1;
	mapping(address => uint) public user_amount_2;
	
	mapping(address =>bool) public is_in_holder_lists;
	 
	address[] public holder_lists;
    mapping(address =>uint256) public holder_lists_index;
	
	
	uint public trade_max_amount=0;
	uint public trade_cur_amount=0;
	 
	
    mapping(address => mapping(address => uint)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
	
	uint public constant MINIMUM_LIQUIDITY = 0;
    
    address public factory;
    address public token1=0x5cc3Bb015860854D3e1D2AbafAc8feB2E6CDbBF3;
    address public token2=0x7E1F3dCDE19B74B95c18cD0A84a3efA81c0Df8eA;
	
	uint public amount1;
    uint public amount2;

    uint public amount1_r;
    uint public amount2_r;

    address public hole_address=0x000000000000000000000000000000000000dEaD;
	
	
	uint public k;

    uint public price_1;
    uint public price_2;
	
	 
 
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'TEST LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    event Mint(address indexed  sender, uint  amount0, uint amount1);
    event Burn(address  indexed sender, uint  amount0, uint amount1, address indexed  to);
    event Swap(
        address indexed sender,
        address token_1,
        address token_2,
        uint amount0Out,
        uint amount1Out,
        address   to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
	
	
    
    mapping(address => uint) public nonces;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
         
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
         
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
		
		
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
   //     if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
     //   }
        _transfer(from, to, value);
        return true;
    }

 

 
    
 
	 
	function addLiquidity(uint amount_1,uint amount_2,address to,uint deadline) external  {
		require(amount_1 > 0, 'amount_1>0');
		require(amount_2 > 0, 'amount_2>0');
	    require(block.timestamp<deadline, "TIME PAST");
		 _addLiquidity(amount_1, amount_2,to);
    }
 
	function _addLiquidity(uint amount_1,uint amount_2,address to) private {

		uint balance_1 = amount1;
        uint balance_2 = amount2;
		IERC20(token1).transferFrom(msg.sender,address(this),amount_1);
        IERC20(token2).transferFrom(msg.sender,address(this),amount_2);
		
		uint _totalSupply = totalSupply; 
		uint liquidity;
		if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount_1.mul(amount_1)).sub(MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min(amount_1.mul(_totalSupply) / balance_1, amount_2.mul(_totalSupply) / balance_2);
        }
		
		
		set_holder_lists(to);
		amount1=amount1.add(amount_1);
		amount2=amount2.add(amount_2);
		
		
		
		
		require(liquidity > 0, 'INSUFFICIENT_LIQUIDITY_MINTED');
		_mint(to, liquidity);
		emit Mint(msg.sender, amount_1, amount_2);
	}
     
	function removeLiquidity(uint amount,address to) external  {
		require(amount > 0, 'amount>0');
		 
	    burn(amount,to);
    }
     
	 
    // this low-level function should be called from a contract which performs important safety checks
    function burn(uint amount,address to) private lock returns (uint amount_1, uint amount_2) {
        
 
        uint balance0 = amount1;
        uint balance1 = amount2;
        uint liquidity = balanceOf[msg.sender];
		
		require(liquidity >= amount, 'TEST: INSUFFICIENT_LIQUIDITY_BURNED');
   
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
       
	    amount_1 = amount.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount_2 = amount.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
		
 
        require(amount_1 > 0 && amount_2 > 0, 'TEST: INSUFFICIENT_LIQUIDITY_BURNED');
       
	    _burn(msg.sender, amount);
		
        amount1=amount1.sub(amount_1);
		amount2=amount2.sub(amount_2);
		 
		if(liquidity==amount){
			amount_1 = amount_1.add(user_amount_1[msg.sender]);  
        	amount_2 = amount_2.add(user_amount_2[msg.sender]);  
            user_amount_1[msg.sender]=0;
            user_amount_2[msg.sender]=0;
			
			//quit_holder_lists(msg.sender);
		}
		
		IERC20(token1).transfer(to,amount_1);
        IERC20(token2).transfer(to,amount_2);
 	 
		 
		
	 
        emit Burn(msg.sender, amount_1, amount_2, to);
		
 
    }
      
    function swap(address token_1,address token_2,uint amount_1, uint amount_2, address to,uint deadline) lock  external   {
		uint price=0;
        uint get_amount=0;
        if(address(token_1)==address(token1) && address(token_2)==address(token2)){
            k=amount1*amount2;
            get_amount=amount2-k.div(amount1.add(amount_1));
 
        }
		if(address(token_1)==address(token2) && address(token_2)==address(token1)){
            k=amount1*amount2;
            get_amount=amount1-k.div(amount2.add(amount_1));
        }
	 
	 
	 	if(trade_max_amount>0 && address(token_1)==address(token1)){
			 require(trade_max_amount>trade_cur_amount, 'get_amount');
		}
		
		
        require(get_amount>0, 'get_amount');
		
		require(deadline>block.timestamp, 'deadline');

	 
		require(get_amount>=amount_2, 'TEST: amount_2');
			
		uint amount_2_max = IERC20(token_2).balanceOf(address(this));
		require(amount_2_max>=get_amount, 'TEST: amount_2_max');
 
        if(address(token_1)==address(token1)){
            			
		    IERC20(token_2).transfer(to,get_amount.mul(9970).div(10000));
			
			IERC20(token_1).transferFrom(msg.sender,address(this), amount_1);
			
			share_holder(token_2,get_amount.mul(30).div(10000)); 
			
			amount1=amount1.add(amount_1);
			amount2=amount2.sub(get_amount);
        }
         if(address(token_1)==address(token2)){
            
            IERC20(token_1).transferFrom(msg.sender,address(this), amount_1.div(2));
            IERC20(token_1).transferFrom(msg.sender,hole_address, amount_1.div(2));

            IERC20(token_2).transfer(to,get_amount.mul(9970).div(10000));

            
			share_holder(token_1,amount_1.div(2));
            share_holder(token_2,get_amount.mul(30).div(10000)); 
			
        
			amount1=amount1.sub(get_amount); 
 
        }   
		if(trade_max_amount>0 && address(token_1)==address(token1)){
			trade_cur_amount=trade_cur_amount.add(get_amount);	
		}
		
        emit Swap(msg.sender, token_1, token_2, amount_1, amount_2, to);
    }
    function share_holder(address token,uint256 all_amount) private {
		uint256 count = holder_lists.length;
		uint256 i = 0;
		while (i < count) {
            	 
			uint256 amount = all_amount.mul(balanceOf[holder_lists[i]]).div(totalSupply);
			if(address(token)==address(token1)){
				user_amount_1[holder_lists[i]]=user_amount_1[holder_lists[i]].add(amount);
			}
			if(address(token)==address(token2)){
				user_amount_2[holder_lists[i]]=user_amount_2[holder_lists[i]].add(amount);
			}
            i++;
			 
		}
	}
 

	 
    function set_holder_lists(address addr) private {
       if (is_in_holder_lists[addr]) {
            return;
        }
         
 
        add_holder(addr);
        is_in_holder_lists[addr] = true;

    }
    function set_holder_lists_1(address addr) external {
       if (is_in_holder_lists[addr]) {
            return;
        }
        
        if (balanceOf[addr] == 0) return;
         
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
	
	 function set_trade_max_amount(uint256 amount) external {
         trade_max_amount=amount;
    }
	 
      


   
}