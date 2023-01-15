/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Contract Type : Staking
 * Staking of : Native Token
 * Number of schemes : 1
 * Scheme 1 functions : stake, unstake
*/

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Staking {

	address owner;
	uint256 public taxInterestBank0 = uint256(0);
	uint256 public taxPrincipalBank0 = uint256(0);
	struct record { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(address => record) public addressMap;
	mapping(uint256 => address) public addressStore;
	uint256 public numberOfAddressesCurrentlyStaked = uint256(0);
	uint256 public totalWithdrawals = uint256(0);
	event Staked (address indexed account);
	event Unstaked (address indexed account);

	constructor() {
		owner = 0x7dea305A6D6d40433ad522760c2E854472468cb7;
	}

	//This function allows the owner to specify an address that will take over ownership rights instead. Please double check the address provided as once the function is executed, only the new owner will be able to change the address back.
	function changeOwner(address _newOwner) public onlyOwner {
		owner = _newOwner;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function minUIntPair(uint _i, uint _j) internal pure returns (uint){
		if (_i < _j){
			return _i;
		}else{
			return _j;
		}
	}

/**
 * Function stake
 * Daily Interest Rate : 10
 * Minimum Stake Period : 7 days
 * Address Map : addressMap
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that (amount of native currency sent to contract) is strictly greater than 0
 * creates an internal variable thisRecord with initial value addressMap with element the address that called this function
 * checks that (amount of native currency sent to contract) is greater than or equals to 10000000000000000
 * checks that ((amount of native currency sent to contract) + (thisRecord with element stakeAmt)) is less than or equals to 5000000000000000000
 * checks that (thisRecord with element stakeAmt) is equals to 0
 * updates addressMap (Element the address that called this function) as Struct comprising current time, (((amount of native currency sent to contract) * ((1000000) - (20000))) / (1000000)), current time, 0
 * updates addressStore (Element numberOfAddressesCurrentlyStaked) as the address that called this function
 * updates numberOfAddressesCurrentlyStaked as (numberOfAddressesCurrentlyStaked) + (1)
 * updates taxPrincipalBank0 as (taxPrincipalBank0) + (((amount of native currency sent to contract) * (2) * (20000)) / ((1000000) * (2)))
 * emits event Staked with inputs the address that called this function
*/
	function stake() public payable {
		require((msg.value > uint256(0)), "Staked amount needs to be greater than 0");
		record memory thisRecord = addressMap[msg.sender];
		require((msg.value >= uint256(10000000000000000)), "Less than minimum stake amount");
		require(((msg.value + thisRecord.stakeAmt) <= uint256(5000000000000000000)), "More than maximum stake amount");
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		addressMap[msg.sender]  = record (block.timestamp, ((msg.value * (uint256(1000000) - uint256(20000))) / uint256(1000000)), block.timestamp, uint256(0));
		addressStore[numberOfAddressesCurrentlyStaked]  = msg.sender;
		numberOfAddressesCurrentlyStaked  = (numberOfAddressesCurrentlyStaked + uint256(1));
		taxPrincipalBank0  = (taxPrincipalBank0 + ((msg.value * uint256(2) * uint256(20000)) / (uint256(1000000) * uint256(2))));
		emit Staked(msg.sender);
	}

/**
 * Function unstake
 * The function takes in 1 variable, (zero or a positive integer) _unstakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element the address that called this function
 * checks that _unstakeAmt is less than or equals to (thisRecord with element stakeAmt)
 * checks that ((current time) - ((700) * (864))) is greater than or equals to (thisRecord with element stakeTime)
 * creates an internal variable newAccum with initial value (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((36500) * (864)))) - (thisRecord with element lastUpdateTime)) * (100000)) / (86400000000))
 * creates an internal variable interestToRemove with initial value ((newAccum) * (_unstakeAmt)) / (thisRecord with element stakeAmt)
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to (((interestToRemove) * ((1000000) - (20000))) / (1000000))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as ((interestToRemove) * ((1000000) - (20000))) / (1000000)
 * checks that (amount of native currency owned by the address of this contract) is greater than or equals to (((_unstakeAmt) * ((1000000) - (20000))) / (1000000))
 * transfers ((_unstakeAmt) * ((1000000) - (20000))) / (1000000) of the native currency to the address that called this function
 * updates totalWithdrawals as (totalWithdrawals) + (((interestToRemove) * ((1000000) - (20000))) / (1000000))
 * updates taxPrincipalBank0 as (taxPrincipalBank0) + (((thisRecord with element stakeAmt) * (2) * (20000)) / ((1000000) * (2)))
 * updates taxInterestBank0 as (taxInterestBank0) + (((interestToRemove) * (2) * (20000)) / ((1000000) * (2)))
 * if _unstakeAmt is equals to (thisRecord with element stakeAmt) then (repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (if (addressStore with element Loop Variable i0) is equals to (the address that called this function) then (updates addressStore (Element Loop Variable i0) as addressStore with element (numberOfAddressesCurrentlyStaked) - (1); then updates numberOfAddressesCurrentlyStaked as (numberOfAddressesCurrentlyStaked) - (1); and then terminates the for-next loop)))
 * updates addressMap (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), ((thisRecord with element stakeAmt) - (_unstakeAmt)), (thisRecord with element lastUpdateTime), ((newAccum) - (interestToRemove))
 * emits event Unstaked with inputs the address that called this function
*/
	function unstake(uint256 _unstakeAmt) public {
		record memory thisRecord = addressMap[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - (uint256(700) * uint256(864))) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(36500) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(100000)) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		require((ERC20(0xe48DA8CF4Af5EbE6946F36CF1B7B19D41aCa2c26).balanceOf(address(this)) >= ((interestToRemove * (uint256(1000000) - uint256(20000))) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0xe48DA8CF4Af5EbE6946F36CF1B7B19D41aCa2c26).transfer(msg.sender, ((interestToRemove * (uint256(1000000) - uint256(20000))) / uint256(1000000)));
		require((address(this).balance >= ((_unstakeAmt * (uint256(1000000) - uint256(20000))) / uint256(1000000))), "Insufficient amount of native currency in this contract to transfer out. Please contact the contract owner to top up the native currency.");
		payable(msg.sender).transfer(((_unstakeAmt * (uint256(1000000) - uint256(20000))) / uint256(1000000)));
		totalWithdrawals  = (totalWithdrawals + ((interestToRemove * (uint256(1000000) - uint256(20000))) / uint256(1000000)));
		taxPrincipalBank0  = (taxPrincipalBank0 + ((thisRecord.stakeAmt * uint256(2) * uint256(20000)) / (uint256(1000000) * uint256(2))));
		taxInterestBank0  = (taxInterestBank0 + ((interestToRemove * uint256(2) * uint256(20000)) / (uint256(1000000) * uint256(2))));
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
				if ((addressStore[i0] == msg.sender)){
					addressStore[i0]  = addressStore[(numberOfAddressesCurrentlyStaked - uint256(1))];
					numberOfAddressesCurrentlyStaked  = (numberOfAddressesCurrentlyStaked - uint256(1));
					break;
				}
			}
		}
		addressMap[msg.sender]  = record (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), thisRecord.lastUpdateTime, (newAccum - interestToRemove));
		emit Unstaked(msg.sender);
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn
 * The function takes in 1 variable, (an address) _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element _address
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((36500) * (864)))) - (thisRecord with element lastUpdateTime)) * (100000)) / (86400000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(address _address) public view returns (uint256) {
		record memory thisRecord = addressMap[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(36500) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(100000)) / uint256(86400000000)));
	}

/**
 * Function totalStakedAmount
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable total with initial value 0
 * repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (creates an internal variable thisRecord with initial value addressMap with element addressStore with element Loop Variable i0; and then updates total as (total) + (thisRecord with element stakeAmt))
 * returns total as output
*/
	function totalStakedAmount() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			record memory thisRecord = addressMap[addressStore[i0]];
			total  = (total + thisRecord.stakeAmt);
		}
		return total;
	}

/**
 * Function totalAccumulatedInterest
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable total with initial value 0
 * repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (updates total as (total) + (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn with variable _address as addressStore with element Loop Variable i0))
 * returns total as output
*/
	function totalAccumulatedInterest() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			total  = (total + interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(addressStore[i0]));
		}
		return total;
	}

/**
 * Function withdrawPrincipalTax0
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that (the address that called this function) is equals to Address 0x360C3bA65B48d128F33359026b38f36319f1562a
 * checks that (amount of native currency owned by the address of this contract) is greater than or equals to taxPrincipalBank0
 * transfers taxPrincipalBank0 of the native currency to the address that called this function
 * updates taxPrincipalBank0 as 0
*/
	function withdrawPrincipalTax0() public {
		require((msg.sender == address(0x360C3bA65B48d128F33359026b38f36319f1562a)), "Not the withdrawal address");
		require((address(this).balance >= taxPrincipalBank0), "Insufficient amount of native currency in this contract to transfer out. Please contact the contract owner to top up the native currency.");
		payable(msg.sender).transfer(taxPrincipalBank0);
		taxPrincipalBank0  = uint256(0);
	}

/**
 * Function withdrawInterestTax0
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that (the address that called this function) is equals to Address 0x360C3bA65B48d128F33359026b38f36319f1562a
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to taxInterestBank0
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as taxInterestBank0
 * updates taxInterestBank0 as 0
*/
	function withdrawInterestTax0() public {
		require((msg.sender == address(0x360C3bA65B48d128F33359026b38f36319f1562a)), "Not the withdrawal address");
		require((ERC20(0xe48DA8CF4Af5EbE6946F36CF1B7B19D41aCa2c26).balanceOf(address(this)) >= taxInterestBank0), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0xe48DA8CF4Af5EbE6946F36CF1B7B19D41aCa2c26).transfer(msg.sender, taxInterestBank0);
		taxInterestBank0  = uint256(0);
	}

/**
 * Function withdrawToken
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to _amt
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function withdrawToken(uint256 _amt) public onlyOwner {
		require((ERC20(0xe48DA8CF4Af5EbE6946F36CF1B7B19D41aCa2c26).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0xe48DA8CF4Af5EbE6946F36CF1B7B19D41aCa2c26).transfer(msg.sender, _amt);
	}
}