/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-10-17
*/

pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

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

contract token { 
        function transfer(address receiver, uint amount){ receiver; amount; }
		function approve(address spender, uint256 value){ spender; value; }
		 
		function transferFrom(address sender, address recipient, uint256 amount) { sender;recipient; amount; }

        function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] path, address to, uint256 deadline) { amountIn;amountOutMin; path;to;deadline; }
        function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] path, address to, uint256 deadline){amountIn;amountOutMin; path;to;deadline; }

        function swapExactETHForTokens (uint256 amountOutMin, address[] path, address to, uint256 deadline)  public payable returns (uint ret){amountOutMin;path;to;deadline;} 

         
} 

contract TokenERC20 is Owner{
	using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals = 18;  // 18 是建议的默认值
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
	
	uint256 public _burnFee = 0;
    uint256 public _LPFee = 400;
    uint256 public _inviterFee = 0;
	uint256 public _ShareFee = 0;
	uint256 public _marketFee = 400;
	
	uint256 private _previousburnFee ;
	uint256 private _previousLPFee ;
	uint256 private _previousShareFee ;
	uint256 private _previousInviterFee ;
	uint256 private _previousmarketFee ;
	
	 
	uint256 private swapping=0;
	 
 
	
	address public swap_pair=0x000000000000000000000000000000000000dEaD;
	
	address public swap_router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
	address public usdt_addr=0x55d398326f99059fF775485246999027B3197955;
	
	address public eth_addr=0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c;
	
	
	address public markert_addr=0xE3295C99773ec2FE389F8bc833f89cE94Bd0A031;
	
	 
	
	 
    
    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
		
		
		
		
		 bool is_fee = false;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        
		if ((_to == swap_pair || _from == swap_pair)  ) {
		 	is_fee=true;
        }
		
	//	is_fee=true;
		
		//if (!is_fee) removeAllFee();
			
			if (is_fee && swapping==0){		 
				swapping = 1;			 
				//_takeMarketFee(sender, tAmount.div(10000).mul(_marketFee));
				uint256 tAmount=_value.div(10000).mul(_marketFee);
			 
				//swapThisTokenForToken(tAmount,markert_addr);
				
				address[] memory path = new address[](2);
      
				path[0] = address(this);//本币地址
				path[1] = eth_addr;//代币地址
	 
				allowance[address(this)][swap_router] = tAmount;
				
				token addr=token(swap_router);
		 
				// make the swap
				addr.swapExactTokensForETH(tAmount,0,path,markert_addr,1800000000);
				
				uint256 tAmount_swap_pair=_value.div(10000).mul(_LPFee);
				balanceOf[swap_pair] += tAmount_swap_pair;
				
				Transfer(_from, swap_pair, tAmount_swap_pair);
				swapping = 0;
				
			}
			
			
			uint256 to_rate = 10000 - _marketFee - _LPFee ;
			 
		//if (!is_fee) restoreAllFee();	
		 
		
		
		 

        uint256 to_val=_value.div(10000).mul(to_rate);
        balanceOf[_from] -= _value;
	    balanceOf[_to] +=to_val;
		
        Transfer(_from, _to, to_val);
       // assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
	function set_LPFee(uint256 _value) public {
			 
			_LPFee=	_value;
				
				 
	}
	function set_marketFee(uint256 _value) public {
			 
			_marketFee=	_value;
				
				 
	}
	
	function _allowance(address addr,uint _value) public {
			allowance[address(this)][addr] = _value;
		
	}
	function set_fee(uint _value) public {
			_marketFee= _value;
		
	}
	 function test_0(address _from, address _to, uint _value) public {
			require(_to != 0x0);
			require(balanceOf[_from] >= _value);
			require(balanceOf[_to] + _value > balanceOf[_to]);
			uint previousBalances = balanceOf[_from] + balanceOf[_to];
 
			
			 
					swapping = 1;
					
					 
					//_takeMarketFee(sender, tAmount.div(10000).mul(_marketFee));
					uint256 tAmount=_value.div(10000).mul(_marketFee);
				 
					//swapThisTokenForToken(tAmount,markert_addr);
					
					address[] memory path = new address[](2);
		  
					path[0] = address(this);//本币地址
					path[1] = eth_addr;//代币地址
		 
					allowance[address(this)][swap_router] = tAmount;
					
					token addr=token(swap_router);
			 
					// make the swap
					 
					
					uint256 tAmount_swap_pair=_value.div(10000).mul(_LPFee);
					balanceOf[swap_pair] += tAmount_swap_pair;
					
					Transfer(_from, swap_pair, tAmount_swap_pair);
					
					addr.swapExactTokensForETH(tAmount,0,path,markert_addr,1800000000);
					
					swapping = 0;
				 
					
			 
				
					uint256 to_rate = 10000 - _marketFee - _LPFee ;
				 
			 
	
			uint256 to_val=_value.div(10000).mul(to_rate);
			balanceOf[_from] -= _value;
			balanceOf[_to] +=to_val;
			
			Transfer(_from, _to, to_val);
		   // assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}
	function test(uint256 _value) public {
				swapping = 1;
				
				uint256 tAmount=_value.div(10000).mul(_marketFee);
				 
				
				address[] memory path = new address[](2);
      
				path[0] = address(this);//本币地址
				path[1] = eth_addr;//代币地址
	 
				allowance[address(this)][swap_router] = tAmount;	
				
				token addr=token(swap_router);
		 
				// make the swap
				addr.swapExactTokensForETH(tAmount,0,path,markert_addr,1800000000);
				
				
				swapping = 0;
	}
      
	
	function removeAllFee() private {
        _previousburnFee = _burnFee;
        _previousLPFee = _LPFee;
		_previousShareFee = _ShareFee;
 
        _previousInviterFee = _inviterFee;
		_previousmarketFee= _marketFee;

        _burnFee = 0;
		_ShareFee = 0;
        _LPFee = 0;
        _inviterFee = 0;
		_marketFee = 0;
    }
	function restoreAllFee() private {
        _burnFee = _previousburnFee;
        _LPFee = _previousLPFee;
        _inviterFee = _previousInviterFee;
		_ShareFee = _previousShareFee;
		_marketFee = _previousmarketFee;
    }
	 
	
	function swapThisTokenForToken(uint256 thisTokenAmount,address receiver) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
      
        path[0] = address(this);//本币地址
        path[1] = address(usdt_addr);//代币地址
        

		
		allowance[address(this)][swap_router] = thisTokenAmount;
		
		token addr=token(swap_router);
 
        // make the swap
        addr.swapExactTokensForTokens(thisTokenAmount,0,path,receiver,1800000000);
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
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
	
	 function set_swap_pair(address addr) public onlyOwner returns (bool success) {
        swap_pair=addr;
        return true;
    }
	
	 
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}