// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Auth.sol";
import "./IBEP20.sol";
import "./IDexRouter.sol";
import "./IDexPair.sol";

contract LiquidityMigrator is Auth {

	constructor() Auth(msg.sender) {}

	function addLiquidity(address router, address token, uint256 tokenAmount) external payable {
		IBEP20 t = IBEP20(token);
		require(t.balanceOf(msg.sender) >= tokenAmount, "You do not own enough tokens.");
		require(t.transferFrom(msg.sender, address(this), tokenAmount), "We didn't receive the tokens :(");
		_addLiquidity(router, token, msg.value, tokenAmount);
	}

	function _addLiquidity(address router, address token, uint256 eth, uint256 tokenAmount) internal {
		IDexRouter(router).addLiquidityETH{value: eth} (
			token,
			tokenAmount,
			0,
			0,
			msg.sender,
			block.timestamp
		);
	}

	function removeLiquidity(address router, address lpToken, address token, uint256 lpTokenAmount) external {
		IBEP20 lp = IBEP20(lpToken);
		lp.transferFrom(msg.sender, address(this), lpTokenAmount);
		_removeLiquidity(router, lpToken, token, lpTokenAmount);
	}

	function _removeLiquidity(address router, address lpToken, address token, uint256 lpTokenAmount) internal {
		IBEP20(lpToken).approve(router, lpTokenAmount);
		IDexRouter(router).removeLiquidityETHSupportingFeeOnTransferTokens(token, lpTokenAmount, 0, 0, msg.sender, block.timestamp);
	}

	function recoverSpecificToken(address tok) public authorized {
		IBEP20 t = IBEP20(tok);
		t.transfer(msg.sender, t.balanceOf(address(this)));
	}

	function rescue() external authorized {
		payable(msg.sender).transfer(address(this).balance);
	}
}