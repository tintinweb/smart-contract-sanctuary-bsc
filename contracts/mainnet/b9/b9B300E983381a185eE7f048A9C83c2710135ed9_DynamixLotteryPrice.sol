// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Uniswap.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./ILotteryPrice.sol";

contract DynamixLotteryPrice is Ownable, IDynamixLotteryPrice {
    using SafeERC20 for IERC20;
		
	IUniswapV2Router02 public immutable router;

	address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
	address public BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
	address override public DYNA = 0xc41689A727469C1573009757200371edf36D540e;
	
	constructor() {
		router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

	function _getPrice(uint256 numberOfTickets, uint256 ticketPriceInUSD, address token) private view returns(uint256) {
		uint256 totalUSD = numberOfTickets * ticketPriceInUSD;
		
		address[] memory path = new address[](3);
        path[0] = BUSD;
		path[1] = BNB;
		path[2] = token;
		
		uint256[] memory amounts = router.getAmountsOut(totalUSD, path);

		return amounts[2];
	}
	
	// Get Price in $DYNA
	function getDYNAPrice(uint256 numberOfTickets, uint256 ticketPriceInUSD) external view returns(uint256) {
		return _getPrice(numberOfTickets, ticketPriceInUSD, DYNA);
	}

	// Swap and Transfer Token to Lottery
	function swapAndTransfer(address from, uint256 numberOfTickets, address betInToken, address lottery, uint256 ticketPriceInUSD) override external returns(uint256) {
		IERC20 dynaToken = IERC20(DYNA);
		uint256 balanceBefore = dynaToken.balanceOf(lottery);
		
		uint256 totaltoken = _getPrice(numberOfTickets, ticketPriceInUSD, betInToken);

		IERC20 token = IERC20(betInToken);

		if(betInToken == DYNA){
			token.safeTransferFrom(from, lottery, totaltoken);
		}
		else {
			token.safeTransferFrom(from, address(this), totaltoken);
			token.approve(address(router), totaltoken);
		
			address[] memory path = new address[](3);
			path[0] = betInToken;
			path[1] = BNB;
			path[2] = DYNA;
			
			router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
				totaltoken, 
				0, 
				path, 
				lottery, 
				block.timestamp
			);
		}
		
		
		uint256 balanceAfter = dynaToken.balanceOf(lottery);
		
		return (balanceAfter - balanceBefore);
	}
}