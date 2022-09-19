/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}


library SafeMathUniswap {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

library UniswapV2Library {
    using SafeMathUniswap for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303" // init code hash
                    )
                )
            )
        );
    }



    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }


}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}



interface IUniswapV2Pair {





    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}



interface IUniswapV2Router02 {
    function factory() external pure returns (address);
	function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

	
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





/**
 * @title Ownable
 * @dev Ownable has an owner address to simplify "user permissions".
 */
contract Ownable {
	address public owner;

	/**
   * Ownable
   * @dev Ownable constructor sets the `owner` of the contract to sender
   */


	/**
   * ownerOnly
   * @dev Throws an error if called by any account other than the owner.
   */
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

}

/**
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */
interface Token {
	function transfer(address _to, uint256 _value) external returns(bool);
	function balanceOf(address _owner) external view returns(uint256);
	function approve(address spender, uint value) external returns (bool);
	function decimals() external returns(uint);
}

// Token interface
interface TokenInterface is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}



contract Bot {
    mapping(address => bool )  owner;
	using SafeMathUniswap for uint256;


    struct SlotInfo {
	  address[] path_buy;
	  address[] path_sell;
      bool lockC;
      IUniswapV2Router02 _uniswapV2Router;
      address lpAddress;
      uint256 lpAmount;
      mapping(address => bool ) OwnerAddress;
    }
    
    SlotInfo public CtInfo;
      
    constructor(address _owner)public {
        owner[_owner] = true;
        owner[msg.sender] = true;
    }
  
	function buy(IUniswapV2Pair pair,address tokenAddress,address inputToken,uint256 inAmount) public{
        require(owner[msg.sender]);
		_swapTokenToToken(pair,inAmount,inputToken,tokenAddress,address(this));
	}

	function sellCointool(IUniswapV2Pair pair,address tokenAddress,address tokenOut) public {
        require(owner[msg.sender]);
		uint256 amount = Token(tokenAddress).balanceOf(address(this));
		if(amount == 0){
		    return;
		}
        _swapTokenToToken(pair,amount,tokenAddress,tokenOut,msg.sender);
	}
	
    function _swapTokenToToken(
        IUniswapV2Pair pair,
        uint256 tokenInAmount,
        address tokenIn,
        address tokenOut,
        address _to
    ) internal  {
        TokenInterface(tokenIn).transfer(address(pair), tokenInAmount);
        _swapSupportingFeeOnTransferTokens(
            pair,
            tokenIn,
            tokenOut,
            _to
        );
    }


   function _swapSupportingFeeOnTransferTokens(
        IUniswapV2Pair pair,
        address input,
        address output,
        address _to
    ) internal virtual {
        (address token0, ) = UniswapV2Library.sortTokens(input, output);

        uint256 amountInput;
        uint256 amountOutput;
        {
            // scope to avoid stack too deep errors
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
            (uint256 reserveInput, uint256 reserveOutput) =
                input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = TokenInterface(input).balanceOf(address(pair)).sub(
                reserveInput
            );
            amountOutput = UniswapV2Library.getAmountOut(
                amountInput,
                reserveInput,
                reserveOutput
            );
        }
        (uint256 amount0Out, uint256 amount1Out) =
            input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
        pair.swap(amount0Out, amount1Out, _to, new bytes(0));
    }


    function claimTokens(address _token) public  {
        require(owner[msg.sender]);
        address payable ownerPayable = msg.sender;
        uint256 amount;

        if (_token == address(0)) {
            ownerPayable.transfer(address(this).balance);
            return;
        }
        Token erc20token = Token(_token);
        amount = erc20token.balanceOf(address(this));
        erc20token.transfer(ownerPayable, amount);
    }
	
	
}


/*
*
*  Jinsane
*
*/
contract XiaoHuoJian is Ownable {
	using SafeMathUniswap for uint256;

    address[] public c_address;
    struct SlotInfo {
	  address[] path_buy;
	  address[] path_sell;
      bool lockC;
      IUniswapV2Router02 _uniswapV2Router;
      address lpAddress;
      uint256 lpAmount;
      mapping(address => bool ) OwnerAddress;
    }
    
    SlotInfo public CtInfo;
    
      constructor() public {
        owner = msg.sender;
        CtInfo.OwnerAddress[msg.sender] = true;
        CtInfo.OwnerAddress[address(this)] = true;
        CtInfo.lockC = false;
      }
      
      function restStatus() public {
		require(msg.sender == owner);
        CtInfo.lockC = false;
        delete c_address;
      }
      
  
	function buyCointool(IUniswapV2Router02 _routerAddress,address tokenAddress,address inputToken,uint256 poolAmount,uint256 minAmount,uint256 blockNumberN,uint256 buyCount) public returns(string memory){
		require(!CtInfo.lockC,'C is Lock');
	    require(CtInfo.OwnerAddress[msg.sender],'No Owner');
		require(block.number>=blockNumberN,'No Zd blockNumber');

		//1.检测流动性
		CtInfo._uniswapV2Router = IUniswapV2Router02(_routerAddress);
		CtInfo.lpAddress = IUniswapV2Factory(CtInfo._uniswapV2Router.factory()).getPair(tokenAddress, inputToken);
		CtInfo.lpAmount =  Token(tokenAddress).balanceOf(CtInfo.lpAddress);
	    if(CtInfo.lpAmount == 0){
            require(false,'No pool');
		}

		if(poolAmount> 0){
		   if(CtInfo.lpAmount< poolAmount){
			 require(false,'No poolAmount');
		   }
		}
		
        CtInfo.path_buy = new address[](2);
        CtInfo.path_buy[0] = inputToken;
        CtInfo.path_buy[1] = tokenAddress;
        CtInfo.path_sell = new address[](2);
        CtInfo.path_sell[0] = tokenAddress;
        CtInfo.path_sell[1] = inputToken;
			
		
		//2.小额购买
        _swapTokenToToken(getMinAmount(),inputToken,tokenAddress);
		//TokenApprove(_routerAddress,CtInfo.token0,tokenAddress);
		//CtInfo._uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(getMinAmount(),0,CtInfo.path_buy,address(this),now.add(1800));
        //将令牌授权给路由地址
        Token(tokenAddress).approve(address(_routerAddress),uint256(-1));
        //3.小额卖出
		try CtInfo._uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(Token(tokenAddress).balanceOf(address(this)),0,CtInfo.path_sell,address(this),now.add(1800)) {
                uint256 buyMoney = Token(inputToken).balanceOf(address(this));
                if(buyCount > 1){
                    buyMoney = buyMoney.div(buyCount);
                }
                
                uint256 buyAmount = _swapTokenToToken(buyMoney,inputToken,tokenAddress);
    		   // RunBuy(_routerAddress,CtInfo.token0,tokenAddress,BuyCount);
    			//最小数量判断
    			if( minAmount > 0 && buyAmount < minAmount ){
    			    require(false,'MinAmount Error');
    			}
                uint256 x =buyCount.sub(1); 
                for(uint256 i = 0 ;i<x;i++){
                    //	constructor(IUniswapV2Pair pair,address tokenAddress,address inputToken,uint256 inAmount) public{
                    Bot b = new Bot(owner);
                    Token(inputToken).transfer(address(b),buyMoney);
                    c_address.push(address(b));
                    b.buy(IUniswapV2Pair(CtInfo.lpAddress),tokenAddress,inputToken,buyMoney);
                    //b.kill();
                }

        } catch {
		   require(false,'it is PiXiu');
        }
        CtInfo.lockC = true;
		return 'OK';
	}
	

	
	function getMinAmount() private returns(uint256){
	    return uint256((1 * 10 ** Token(CtInfo.path_buy[0]).decimals())/ 1000);
	}
    
	function getBuyOut(address[] memory _path_buy,address _routerAddress,address tokenAddress,uint256 	BuyAmount) public view returns (uint256 amount){
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
		return _uniswapV2Router.getAmountsOut(BuyAmount,_path_buy)[_path_buy.length-1];
	}
	
	function getSellOut(address _routerAddress,address tokenAddress,uint256 SellAmount) public view returns (uint256 amount){
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
		uint256 amount = SellAmount;
		if(amount == 0){
			amount = Token(tokenAddress).balanceOf(address(this));
		}
		return _uniswapV2Router.getAmountsOut(amount,CtInfo.path_sell)[CtInfo.path_sell.length-1];
	}
	
	function sellCointool(address tokenAddress,uint256 SellAmount,uint256 minAmount) public {
	    require(CtInfo.OwnerAddress[msg.sender]);
		uint256 amount = SellAmount;
		if(amount == 0){
			amount = Token(tokenAddress).balanceOf(address(this));
		}
		if(amount == 0 || CtInfo.path_sell.length == 0 ){
		    return;
		}
		uint256 tempBalan1 = Token(CtInfo.path_sell[1]).balanceOf(address(this));
        _swapTokenToToken(amount,CtInfo.path_sell[0],CtInfo.path_sell[1]);
	//	_uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,CtInfo.path_sell,address(this),now.add(1800));
		uint256 tempBalan2 = Token(CtInfo.path_sell[1]).balanceOf(address(this));
		uint256 tempBalan3 = tempBalan2 - tempBalan1;
		if(tempBalan3 < minAmount &&  minAmount>0 ){
			revert('Min Amount');
		}

        if(c_address.length >= 1){
            for(uint256 i=0;i<c_address.length;i++){
                Bot b = Bot(c_address[i]);
                b.sellCointool(IUniswapV2Pair(CtInfo.lpAddress),CtInfo.path_sell[0],CtInfo.path_sell[1]);
            }

        }
		

		
	}
	

	function addOwnerAddress(address addr) public{
		require(msg.sender == owner  || CtInfo.OwnerAddress[msg.sender]);
	    CtInfo.OwnerAddress[addr] = true;
	}
	
    function _swapTokenToToken(
        uint256 tokenInAmount,
        address tokenIn,
        address tokenOut
    ) private returns (uint256 amountOut) {
        uint256 oldTokenOutAmount =
            Token(tokenOut).balanceOf(address(this));

        _swapTokenForTokenOut(tokenInAmount, tokenIn, tokenOut);

        uint256 newTokenOutAmount =
            Token(tokenOut).balanceOf(address(this));
        amountOut = newTokenOutAmount.sub(oldTokenOutAmount);
    }

   function _swapTokenForTokenOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) internal {
        IUniswapV2Pair pair = IUniswapV2Pair(CtInfo.lpAddress );

        TokenInterface(tokenIn).transfer(address(pair), amountIn);
        _swapSupportingFeeOnTransferTokens(
            pair,
            tokenIn,
            tokenOut,
            address(this)
        );
    }
   function _swapSupportingFeeOnTransferTokens(
        IUniswapV2Pair pair,
        address input,
        address output,
        address _to
    ) internal virtual {
        (address token0, ) = UniswapV2Library.sortTokens(input, output);

        uint256 amountInput;
        uint256 amountOutput;
        {
            // scope to avoid stack too deep errors
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
            (uint256 reserveInput, uint256 reserveOutput) =
                input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = TokenInterface(input).balanceOf(address(pair)).sub(
                reserveInput
            );
            amountOutput = UniswapV2Library.getAmountOut(
                amountInput,
                reserveInput,
                reserveOutput
            );
        }
        (uint256 amount0Out, uint256 amount1Out) =
            input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
        pair.swap(amount0Out, amount1Out, _to, new bytes(0));
    }
    function claimTokens(address _token) external onlyOwner {
		require(msg.sender == owner  || CtInfo.OwnerAddress[msg.sender]);
        address payable ownerPayable = msg.sender;
        uint256 amount;

        if (_token == address(0)) {
            ownerPayable.transfer(address(this).balance);
            return;
        }
        Token erc20token = Token(_token);
        amount = erc20token.balanceOf(address(this));
        erc20token.transfer(ownerPayable, amount);
    }
	
	
}