/**
 * Olympus migration
 * Powered by https://hibiki.finance
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Auth.sol";
import "./IBEP20.sol";
import "./IDexPair.sol";

interface IOlympus is IBEP20 {
	function setIsFeeExempt(address holder, bool exempt) external;
}

contract OlympusMigrator is Auth {

	bool public newTokenAvailable = false;
	address public tokenIn;
	address public tokenOut;
	address public tokenInPool;
	mapping (address => uint256) public deposits;
	mapping (address => uint256) public claimable;
	mapping (address => uint256) public redeemed;
	mapping (address => uint64) public lastRedeem;
	mapping (address => uint256) public vested;
	mapping (address => uint112[]) public reserve0Deposits;
	mapping (address => uint112[]) public reserve1Deposits;

	event Deposit(address indexed depositer, uint256 quantity, uint112 reserve0, uint112 reserve1);
	event Redeem(address indexed redeemer, uint256 quantity);

	modifier taxlessTransfer(address from) {
		IOlympus(tokenIn).setIsFeeExempt(from, true);
		_;
		IOlympus(tokenIn).setIsFeeExempt(from, false);
	}

	constructor(address t1, address t2, address lpin) Auth(msg.sender) {
        tokenIn = t1;
		tokenOut = t2;
		tokenInPool = lpin;
    }

	function setNewTokenAvailable(bool av) external authorized {
		newTokenAvailable = av;
	}

	function setClaimAmount(address claimer, uint256 amount, uint256 v) external authorized {
		claimable[claimer] = amount;
		vested[claimer] = v;
	}

	function sendTokens(address sender, address receiver, uint256 amount) internal taxlessTransfer(sender) returns(bool) {
		return IBEP20(tokenIn).transferFrom(sender, receiver, amount);
	}

	function deposit(uint256 amount) external {
		sendTokens(msg.sender, address(this), amount);
		deposits[msg.sender] += amount;
		(uint112 reserve0, uint112 reserve1,) = IDexPair(tokenInPool).getReserves();
		// Record average price at which Olympus was deposited.
		reserve0Deposits[msg.sender].push(reserve0);
		reserve1Deposits[msg.sender].push(reserve1);

		emit Deposit(msg.sender, amount, reserve0, reserve1);
	}

	function redeem() external {
		require(newTokenAvailable, "Not available yet!");
		require(claimable[msg.sender] > 0, "Nothing to redeem!");
		uint256 redeeming = claimable[msg.sender];
		IBEP20(tokenOut).transfer(msg.sender, redeeming);
		claimable[msg.sender] = 0;
		lastRedeem[msg.sender] = uint64(block.timestamp);
		redeemed[msg.sender] += redeeming;

		emit Redeem(msg.sender, redeeming);
	}

	function emergencyRecoverToken(address t) external authorized {
		IBEP20 tok = IBEP20(t);
		tok.transfer(msg.sender, tok.balanceOf(address(this)));
	}

	function getReservesOnDeposit(address a) external view returns (uint112[] memory reserve0, uint112[] memory reserve1) {
		return (reserve0Deposits[a], reserve1Deposits[a]);
	}
}