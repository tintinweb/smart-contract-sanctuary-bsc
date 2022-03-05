//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Tokenomics.sol";
import "./RFI.sol";
import "./Expensify.sol";
import "./TxPolice.sol";
import "./Pancake.sol";
import "./Helpers.sol";

contract LESLAR is 
	IERC20Metadata, 
	Context, 
	Ownable,
	Tokenomics, 
	RFI,
	TxPolice,
	Expensify
{
	using SafeMath for uint256;

	constructor() {
		// Set special addresses
		specialAddresses[owner()] = true;
		specialAddresses[address(this)] = true;
		specialAddresses[deadAddr] = true;
		// Set limit exemptions
		LimitExemptions memory exemptions;
		exemptions.all = true;
		limitExemptions[owner()] = exemptions;
		limitExemptions[address(this)] = exemptions;
	}

/* ------------------------------- IERC20 Meta ------------------------------ */

	function name() external pure override returns(string memory) { return NAME;}
	function symbol() external pure override returns(string memory) { return SYMBOL;}
	function decimals() external pure override returns(uint8) { return DECIMALS; }	

/* -------------------------------- Overrides ------------------------------- */

	function beforeTokenTransfer(address from, address to, uint256 amount) 
		internal 
		override 
	{
		// Make sure max transaction and wallet size limits are not exceeded.
		TransactionLimitType[2] memory limits = [
			TransactionLimitType.TRANSACTION, 
			TransactionLimitType.WALLET
		];
		guardMaxLimits(from, to, amount, limits);
		enforceCyclicSellLimit(from, to, amount);
		// Try to execute all our accumulator features.
		triggerFeatures(from);
	}

	function takeFee(address from, address to) 
		internal 
		view 
		override 
		returns(bool) 
	{
		return canTakeFee(from, to);
	}

/* -------------------------- Accumulator Triggers -------------------------- */

	// Will keep track of how often each trigger has been called already.
	uint256 internal triggerCount = 0;
	// Will keep track of trigger indexes, which can be triggered during current tx.
	uint8 internal canTrigger = 0;

	/**
	* @notice Convenience wrapper function which tries to trigger our custom 
	* features.
	*/
	function triggerFeatures(address from) private {
		uint256 contractTokenBalance = balanceOf(address(this));
		// First determine which triggers can be triggered.
		if (!liquidityPools[from]) {
			if (canTax(contractTokenBalance)) {
				canTrigger = 1;
			}
		}

		// Avoid falling into a tx loop.
		if (!inTriggerProcess) {
			if (canTax(contractTokenBalance)) {
				_triggerTax();
				delete canTrigger;
			}
		}
	}

/* ---------------------------- Internal Triggers --------------------------- */

	/**
	* @notice Triggers tax and updates triggerLog
	*/
	function _triggerTax() internal {
		taxify(accumulatedForTax);
		triggerCount = triggerCount.add(1);
	}

/* ---------------------------- External Triggers --------------------------- */

	/**
	* @notice Allows to trigger tax manually.
	*/
	function triggerTax() external onlyOwner {
		uint256 contractTokenBalance = balanceOf(address(this));
		require(canTax(contractTokenBalance), "Not enough tokens accumulated.");
		_triggerTax();
	}
}