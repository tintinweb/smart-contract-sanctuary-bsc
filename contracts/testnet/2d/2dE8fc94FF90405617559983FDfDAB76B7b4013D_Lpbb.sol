// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./IBEP20.sol";
import "./IDexRouter.sol";
import "./IDexPair.sol";

contract Lpbb {

	address lp;
	address token;
	address router;

	constructor(address l, address t, address r) {
		lp = l;
		token = t;
		router = r;
	}

	function doit() external {
		IBEP20 lpt = IBEP20(lp);
		uint256 total = lpt.balanceOf(address(this));
		_removeLiquidity(total / 100);
		buy(address(this).balance);
		IBEP20(token).transfer(address(0), IBEP20(token).balanceOf(address(this)));
	}

	function _removeLiquidity(uint256 lpTokenAmount) internal {
		IBEP20(lp).approve(router, lpTokenAmount);
		IDexRouter(router).removeLiquidityETHSupportingFeeOnTransferTokens(token, lpTokenAmount, 0, 0, msg.sender, block.timestamp);
	}

	function buy(uint256 amount) internal {
		address[] memory path = new address[](2);
		IDexRouter r = IDexRouter(router);
        path[0] = r.WETH();
        path[1] = token;
        r.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(0),
            block.timestamp + 1
        );
	}
}