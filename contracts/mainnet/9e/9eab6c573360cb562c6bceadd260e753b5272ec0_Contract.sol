/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
		// WBNB_contract.encodeABI(fn_name='transfer', args=['0x0000000000000000000000000000000000000000',0])
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'T');	//TRANSFER FAILED
    }
}

library PancakeLibrary {
    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'I');		//INSUFFICIENT INPUT AMOUNT
        require(reserveIn > 0 && reserveOut > 0, 'L');		//INSUFFICIENT LIQUIDITY
        uint amountInWithFee = amountIn*9975;
        uint numerator = amountInWithFee*reserveOut;
        uint denominator = reserveIn*10000+amountInWithFee;
        amountOut = numerator / denominator;
		//amountIn*9975*reserveOut/(reserveIn*10000+amountIn*9975)
		//amountIn*(1-0.0025)*reserveOut/(reserveIn+amountIn*(1-0.0025))
		//reserveOut-reserveOut*reserveIn/(reserveIn+amountIn*(1-0.0025))
    }
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
}

interface Router {
	function destroy() external;
	function withdraw(address token) external;
	function trade(address _block_number_max, address _address_pair, address _address_input, address _address_output, address _amount_input_sent, address _amount_output_received) external;
	function target_buy(address _block_number_max, address _address_pair, address _address_base, address _address_token, address _trade_amount_base, address _trade_result_minimum, address _LP_amount_base_recorded) external;
	function target_sell(uint block_number_sent, address _address_pair, address _address_token, address _address_base) external;
}

contract Contract is Router {
	
    address internal _creator;
	
    modifier onlyAuthorized()
	{
		require(msg.sender == _creator, 'U');	//UNAUTHORIZED
		_;
    }
	
    constructor ()
	{
		_creator = msg.sender;
    }
	
	function destroy() external virtual onlyAuthorized
	{
		selfdestruct(payable(_creator));
	}
	
	function withdraw(address token) external virtual onlyAuthorized
	{
		uint tokenBalance = IERC20(token).balanceOf(address(this));
		TransferHelper.safeTransfer(token, _creator, tokenBalance);
	}
	
	function trade(address _block_number_max, address _address_pair, address _address_input, address _address_output, address _amount_input_sent, address _amount_output_received) external virtual onlyAuthorized
	{
		uint block_number_max = (uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_block_number_max);
		require(block.number <= block_number_max, 'B');		//BLOCK NUMBER GREATER THAN MAX BLOCK NUMBER
		
		address address_pair = address((uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_address_pair));
		address address_input = address((uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_address_input));
		address address_output = address((uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_address_output));
		uint amount_input_sent = (uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_amount_input_sent);
		
        TransferHelper.safeTransfer(address_input, address_pair, amount_input_sent);
		
        uint balance_previous = IERC20(address_output).balanceOf(address(this));
		
		IPancakePair pair = IPancakePair(address_pair);
		uint trade_amount_input;
		uint trade_amount_output;
		{ // scope to avoid stack too deep errors
			(uint reserve0, uint reserve1,) = pair.getReserves();
			(uint LP_amount_input, uint LP_amount_output) = address_input < address_output ? (reserve0, reserve1) : (reserve1, reserve0);
			trade_amount_input = IERC20(address_input).balanceOf(address_pair)-LP_amount_input;
			trade_amount_output = PancakeLibrary.getAmountOut(trade_amount_input, LP_amount_input, LP_amount_output);
		}
		(uint amount0Out, uint amount1Out) = address_input < address_output ? (uint(0), trade_amount_output) : (trade_amount_output, uint(0));
		
		pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
		
		uint balance_current = IERC20(address_output).balanceOf(address(this));
		
		uint amount_output_received = (uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_amount_output_received);
		require(balance_current-balance_previous >= amount_output_received, 'O');	//INSUFFICIENT OUTPUT AMOUNT
    }
	
	function target_buy(address _block_number_max, address _address_pair, address _address_base, address _address_token, address _trade_amount_base, address _trade_result_minimum, address _LP_amount_base_recorded) external virtual onlyAuthorized
	{
		uint block_number_max = (uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_block_number_max);
		require(block.number <= block_number_max, 'B');		//BLOCK NUMBER GREATER THAN MAX BLOCK NUMBER
		
		address address_pair = address((uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_address_pair));
		address address_base = address((uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_address_base));
		address address_token = address((uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_address_token));
		uint trade_amount_base = (uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_trade_amount_base);
		
		IPancakePair pair = IPancakePair(address_pair);
		uint LP_amount_base;
		uint LP_amount_token;
		if (address_base < address_token)
		{
			(LP_amount_base, LP_amount_token,) = pair.getReserves();
		}
		else
		{
			(LP_amount_token, LP_amount_base,) = pair.getReserves();
		}
		
		uint LP_amount_base_recorded = (uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_LP_amount_base_recorded);
		require(LP_amount_base <= LP_amount_base_recorded, 'R');
		
		TransferHelper.safeTransfer(address_base, address_pair, trade_amount_base);
		
		{ // scope to avoid stack too deep errors
			uint balance_previous = IERC20(address_token).balanceOf(address(this));
			uint trade_amount_token = PancakeLibrary.getAmountOut(trade_amount_base, LP_amount_base, LP_amount_token);
			
			if (address_base < address_token)
			{
				pair.swap(uint(0), trade_amount_token, address(this), new bytes(0));
			}
			else
			{
				pair.swap(trade_amount_token, uint(0), address(this), new bytes(0));
			}
			
			uint balance_current = IERC20(address_token).balanceOf(address(this));
			
			uint trade_result_minimum = (uint160(block.number-1)*23810279889594298738900760033922143475128)^uint160(_trade_result_minimum);
			require(balance_current-balance_previous >= trade_result_minimum, 'O');	//INSUFFICIENT OUTPUT AMOUNT
		}
    }
	
	function target_sell(uint block_number_sent, address _address_pair, address _address_token, address _address_base) external virtual onlyAuthorized
	{
		address address_token = address((uint160(block_number_sent)*23810279889594298738900760033922143475128)^uint160(_address_token));
		
        uint balance = IERC20(address_token).balanceOf(address(this));
		require(balance > 0, 'N');		//NO TOKEN BALANCE (BUY FAILED)
		
		address address_pair = address((uint160(block_number_sent)*23810279889594298738900760033922143475128)^uint160(_address_pair));
		
        TransferHelper.safeTransfer(address_token, address_pair, balance);
		
		address address_base = address((uint160(block_number_sent)*23810279889594298738900760033922143475128)^uint160(_address_base));
		
		IPancakePair pair = IPancakePair(address_pair);
		uint trade_amount_token;
		uint trade_amount_base;
		{ // scope to avoid stack too deep errors
			(uint reserve0, uint reserve1,) = pair.getReserves();
			(uint LP_amount_base, uint LP_amount_token) = address_base < address_token ? (reserve0, reserve1) : (reserve1, reserve0);
			trade_amount_token = IERC20(address_token).balanceOf(address_pair)-LP_amount_token;
			trade_amount_base = PancakeLibrary.getAmountOut(trade_amount_token, LP_amount_token, LP_amount_base);
		}
		(uint amount0Out, uint amount1Out) = address_base < address_token ? (trade_amount_base, uint(0)) : (uint(0), trade_amount_base);
		pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }
}