/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Contract Type : Staking
 * Staking of : Coin TokenERC20
 * Coin Address : 0xa9E8d7D2fAC7298003F2ba777229c3EAD36dc757
 * Number of schemes : 1
 * Scheme 1 functions : stake, unstake
*/

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Staking {

	address owner;
	uint256 public interestTaxBank = uint256(0);
	uint256 public principalTaxBank = uint256(0);
	struct record { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; uint256 amtWithdrawn; }
	mapping(address => record) public addressMap;
	mapping(uint256 => address) public addressStore;
	uint256 public numberOfAddressesCurrentlyStaked = uint256(0);
	uint256 public minStakeAmt = uint256(100000000000000000000);
	uint256 public maxStakeAmt = uint256(10000000000000000000000);
	uint256 public principalCommencementTax = uint256(50000);
	uint256 public principalWithdrawalTax = uint256(1000000);
	uint256 public minStakePeriod = (uint256(100) * uint256(864));
	uint256 public interestTax = uint256(50000);
	uint256 public totalWithdrawals = uint256(0);
	uint256 public minCoolDownPeriod = (uint256(100) * uint256(864));
	event Staked (address indexed account);
	event Unstaked (address indexed account);

	constructor() {
		owner = msg.sender;
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
 * This function allows the owner to change the value of minStakeAmt.
 * Notes for _minStakeAmt : 1 Coin TokenERC20 is represented by 10^18.
*/
	function changeValueOf_minStakeAmt (uint256 _minStakeAmt) external onlyOwner {
		 minStakeAmt = _minStakeAmt;
	}

	

/**
 * This function allows the owner to change the value of maxStakeAmt.
 * Notes for _maxStakeAmt : 1 Coin TokenERC20 is represented by 10^18.
*/
	function changeValueOf_maxStakeAmt (uint256 _maxStakeAmt) external onlyOwner {
		 maxStakeAmt = _maxStakeAmt;
	}

	

/**
 * This function allows the owner to change the value of principalCommencementTax.
 * Notes for _principalCommencementTax : 10000 is one percent
*/
	function changeValueOf_principalCommencementTax (uint256 _principalCommencementTax) external onlyOwner {
		 principalCommencementTax = _principalCommencementTax;
	}

	

/**
 * This function allows the owner to change the value of principalWithdrawalTax.
 * Notes for _principalWithdrawalTax : 10000 is one percent
*/
	function changeValueOf_principalWithdrawalTax (uint256 _principalWithdrawalTax) external onlyOwner {
		 principalWithdrawalTax = _principalWithdrawalTax;
	}

	

/**
 * This function allows the owner to change the value of minStakePeriod.
 * Notes for _minStakePeriod : 1 day is represented by 86400 (seconds)
*/
	function changeValueOf_minStakePeriod (uint256 _minStakePeriod) external onlyOwner {
		 minStakePeriod = _minStakePeriod;
	}

	

/**
 * This function allows the owner to change the value of interestTax.
 * Notes for _interestTax : 10000 is one percent
*/
	function changeValueOf_interestTax (uint256 _interestTax) external onlyOwner {
		 interestTax = _interestTax;
	}

	

/**
 * This function allows the owner to change the value of minCoolDownPeriod.
 * Notes for _minCoolDownPeriod : 1 day is represented by 86400 (seconds)
*/
	function changeValueOf_minCoolDownPeriod (uint256 _minCoolDownPeriod) external onlyOwner {
		 minCoolDownPeriod = _minCoolDownPeriod;
	}

/**
 * Function stake
 * Minimum Stake Period : Variable minStakePeriod
 * Address Map : addressMap
 * ERC20 Transfer : 0xa9E8d7D2fAC7298003F2ba777229c3EAD36dc757, _stakeAmt
 * The function takes in 1 variable, (zero or a positive integer) _stakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element the address that called this function
 * checks that _stakeAmt is greater than or equals to minStakeAmt
 * checks that ((_stakeAmt) + (thisRecord with element stakeAmt)) is less than or equals to maxStakeAmt
 * checks that _stakeAmt is strictly greater than 0
 * checks that (thisRecord with element stakeAmt) is equals to 0
 * updates addressStore (Element numberOfAddressesCurrentlyStaked) as the address that called this function
 * updates numberOfAddressesCurrentlyStaked as (numberOfAddressesCurrentlyStaked) + (1)
 * updates addressMap (Element the address that called this function) as Struct comprising current time, (((_stakeAmt) * ((1000000) - (principalCommencementTax))) / (1000000)), current time, 0, 0
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _stakeAmt
 * updates principalTaxBank as (principalTaxBank) + (((_stakeAmt) * (principalCommencementTax)) / (1000000))
 * emits event Staked with inputs the address that called this function
*/
	function stake(uint256 _stakeAmt) public {
		record memory thisRecord = addressMap[msg.sender];
		require((_stakeAmt >= minStakeAmt), "Less than minimum stake amount");
		require(((_stakeAmt + thisRecord.stakeAmt) <= maxStakeAmt), "More than maximum stake amount");
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake staked amount before staking");
		addressStore[numberOfAddressesCurrentlyStaked]  = msg.sender;
		numberOfAddressesCurrentlyStaked  = (numberOfAddressesCurrentlyStaked + uint256(1));
		addressMap[msg.sender]  = record (block.timestamp, ((_stakeAmt * (uint256(1000000) - principalCommencementTax)) / uint256(1000000)), block.timestamp, uint256(0), uint256(0));
		ERC20(0xa9E8d7D2fAC7298003F2ba777229c3EAD36dc757).transferFrom(msg.sender, address(this), _stakeAmt);
		principalTaxBank  = (principalTaxBank + ((_stakeAmt * principalCommencementTax) / uint256(1000000)));
		emit Staked(msg.sender);
	}

/**
 * Function unstake
 * The function takes in 1 variable, (zero or a positive integer) _unstakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element the address that called this function
 * checks that _unstakeAmt is less than or equals to (thisRecord with element stakeAmt)
 * checks that ((current time) - (minStakePeriod)) is greater than or equals to (thisRecord with element stakeTime)
 * checks that ((current time) - (minCoolDownPeriod)) is greater than or equals to (thisRecord with element lastUpdateTime)
 * creates an internal variable interestToRemove with initial value ((thisRecord with element accumulatedInterestToUpdateTime) * (_unstakeAmt)) / (thisRecord with element stakeAmt)
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to (((interestToRemove) * ((1000000) - (interestTax))) / (1000000))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as ((interestToRemove) * ((1000000) - (interestTax))) / (1000000)
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to (((_unstakeAmt) * ((1000000) - (principalWithdrawalTax))) / (1000000))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as ((_unstakeAmt) * ((1000000) - (principalWithdrawalTax))) / (1000000)
 * updates totalWithdrawals as (totalWithdrawals) + (((interestToRemove) * ((1000000) - (interestTax))) / (1000000))
 * updates principalTaxBank as (principalTaxBank) + (((thisRecord with element stakeAmt) * (principalWithdrawalTax)) / (1000000))
 * updates interestTaxBank as (interestTaxBank) + (((interestToRemove) * (interestTax)) / (1000000))
 * updates addressMap (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), ((thisRecord with element stakeAmt) - (_unstakeAmt)), (thisRecord with element lastUpdateTime), ((thisRecord with element accumulatedInterestToUpdateTime) - (interestToRemove)), ((thisRecord with element amtWithdrawn) + (interestToRemove))
 * emits event Unstaked with inputs the address that called this function
 * if _unstakeAmt is equals to (thisRecord with element stakeAmt) then (repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (if (addressStore with element Loop Variable i0) is equals to (the address that called this function) then (updates addressStore (Element Loop Variable i0) as addressStore with element (numberOfAddressesCurrentlyStaked) - (1); then updates numberOfAddressesCurrentlyStaked as (numberOfAddressesCurrentlyStaked) - (1); and then terminates the for-next loop)))
*/
	function unstake(uint256 _unstakeAmt) public {
		record memory thisRecord = addressMap[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - minStakePeriod) >= thisRecord.stakeTime), "Insufficient stake period");
		require(((block.timestamp - minCoolDownPeriod) >= thisRecord.lastUpdateTime), "Insufficient cool down period");
		uint256 interestToRemove = ((thisRecord.accumulatedInterestToUpdateTime * _unstakeAmt) / thisRecord.stakeAmt);
		require((ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).balanceOf(address(this)) >= ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).transfer(msg.sender, ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
		require((ERC20(0xa9E8d7D2fAC7298003F2ba777229c3EAD36dc757).balanceOf(address(this)) >= ((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0xa9E8d7D2fAC7298003F2ba777229c3EAD36dc757).transfer(msg.sender, ((_unstakeAmt * (uint256(1000000) - principalWithdrawalTax)) / uint256(1000000)));
		totalWithdrawals  = (totalWithdrawals + ((interestToRemove * (uint256(1000000) - interestTax)) / uint256(1000000)));
		principalTaxBank  = (principalTaxBank + ((thisRecord.stakeAmt * principalWithdrawalTax) / uint256(1000000)));
		interestTaxBank  = (interestTaxBank + ((interestToRemove * interestTax) / uint256(1000000)));
		addressMap[msg.sender]  = record (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), thisRecord.lastUpdateTime, (thisRecord.accumulatedInterestToUpdateTime - interestToRemove), (thisRecord.amtWithdrawn + interestToRemove));
		emit Unstaked(msg.sender);
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
				if ((addressStore[i0] == msg.sender)){
					addressStore[i0]  = addressStore[(numberOfAddressesCurrentlyStaked - uint256(1))];
					numberOfAddressesCurrentlyStaked  = (numberOfAddressesCurrentlyStaked - uint256(1));
					break;
				}
			}
		}
	}

/**
 * Function deposit
 * ERC20 Transfer : 0x553F5489eB3200aaB20bA424da63297D6f373Dcb, _depositAmt
 * The function takes in 1 variable, (zero or a positive integer) _depositAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _depositAmt
 * creates an internal variable accumulatedParts with initial value 0
 * repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (creates an internal variable aSender with initial value addressStore with element Loop Variable i0; then creates an internal variable thisRecord with initial value addressMap with element aSender; then creates an internal variable stakedPeriod with initial value (minimum of current time, ((thisRecord with element stakeTime) + ((500) * (864)))) - (thisRecord with element stakeTime); then if stakedPeriod is strictly greater than ((36000) * (864)) then (updates stakedPeriod as (36000) * (864)); and then updates accumulatedParts as (accumulatedParts) + ((stakedPeriod) * (thisRecord with element stakeAmt)))
 * repeat numberOfAddressesCurrentlyStaked times with loop variable i0 :  (creates an internal variable aSender with initial value addressStore with element Loop Variable i0; then creates an internal variable thisRecord with initial value addressMap with element aSender; then creates an internal variable stakedPeriod with initial value (minimum of current time, ((thisRecord with element stakeTime) + ((500) * (864)))) - (thisRecord with element stakeTime); then if stakedPeriod is strictly greater than ((36000) * (864)) then (updates stakedPeriod as (36000) * (864)); and then updates addressMap (Element aSender) as Struct comprising (thisRecord with element stakeTime), (thisRecord with element stakeAmt), current time, ((thisRecord with element accumulatedInterestToUpdateTime) + (((stakedPeriod) * (thisRecord with element stakeAmt) * (_depositAmt)) / (accumulatedParts))), (thisRecord with element amtWithdrawn))
*/
	function deposit(uint256 _depositAmt) public {
		ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).transferFrom(msg.sender, address(this), _depositAmt);
		uint256 accumulatedParts = uint256(0);
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			address aSender = addressStore[i0];
			record memory thisRecord = addressMap[aSender];
			uint256 stakedPeriod = (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(500) * uint256(864)))) - thisRecord.stakeTime);
			if ((stakedPeriod > (uint256(36000) * uint256(864)))){
				stakedPeriod  = (uint256(36000) * uint256(864));
			}
			accumulatedParts  = (accumulatedParts + (stakedPeriod * thisRecord.stakeAmt));
		}
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked; i0++){
			address aSender = addressStore[i0];
			record memory thisRecord = addressMap[aSender];
			uint256 stakedPeriod = (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(500) * uint256(864)))) - thisRecord.stakeTime);
			if ((stakedPeriod > (uint256(36000) * uint256(864)))){
				stakedPeriod  = (uint256(36000) * uint256(864));
			}
			addressMap[aSender]  = record (thisRecord.stakeTime, thisRecord.stakeAmt, block.timestamp, (thisRecord.accumulatedInterestToUpdateTime + ((stakedPeriod * thisRecord.stakeAmt * _depositAmt) / accumulatedParts)), thisRecord.amtWithdrawn);
		}
	}

/**
 * Function withdrawInterestWithoutUnstaking
 * The function takes in 1 variable, (zero or a positive integer) _withdrawalAmt. It can only be called by functions outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element the address that called this function
 * creates an internal variable totalInterestEarnedTillNow with initial value thisRecord with element accumulatedInterestToUpdateTime
 * checks that _withdrawalAmt is less than or equals to totalInterestEarnedTillNow
 * updates addressMap (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), (thisRecord with element stakeAmt), current time, ((totalInterestEarnedTillNow) - (_withdrawalAmt)), ((thisRecord with element amtWithdrawn) + (_withdrawalAmt))
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to (((_withdrawalAmt) * ((1000000) - (interestTax))) / (1000000))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as ((_withdrawalAmt) * ((1000000) - (interestTax))) / (1000000)
 * updates interestTaxBank as (interestTaxBank) + (((_withdrawalAmt) * (interestTax)) / (1000000))
 * updates totalWithdrawals as (totalWithdrawals) + (((_withdrawalAmt) * ((1000000) - (interestTax))) / (1000000))
*/
	function withdrawInterestWithoutUnstaking(uint256 _withdrawalAmt) external {
		record memory thisRecord = addressMap[msg.sender];
		uint256 totalInterestEarnedTillNow = thisRecord.accumulatedInterestToUpdateTime;
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		addressMap[msg.sender]  = record (thisRecord.stakeTime, thisRecord.stakeAmt, block.timestamp, (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt));
		require((ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).balanceOf(address(this)) >= ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).transfer(msg.sender, ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
		interestTaxBank  = (interestTaxBank + ((_withdrawalAmt * interestTax) / uint256(1000000)));
		totalWithdrawals  = (totalWithdrawals + ((_withdrawalAmt * (uint256(1000000) - interestTax)) / uint256(1000000)));
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
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn
 * The function takes in 1 variable, (an address) _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element _address
 * returns thisRecord with element accumulatedInterestToUpdateTime as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(address _address) public view returns (uint256) {
		record memory thisRecord = addressMap[_address];
		return thisRecord.accumulatedInterestToUpdateTime;
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
 * Function withdrawPrincipalTax
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to principalTaxBank
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as principalTaxBank
 * updates principalTaxBank as 0
*/
	function withdrawPrincipalTax() public onlyOwner {
		require((ERC20(0xa9E8d7D2fAC7298003F2ba777229c3EAD36dc757).balanceOf(address(this)) >= principalTaxBank), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0xa9E8d7D2fAC7298003F2ba777229c3EAD36dc757).transfer(msg.sender, principalTaxBank);
		principalTaxBank  = uint256(0);
	}

/**
 * Function withdrawInterestTax
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to interestTaxBank
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as interestTaxBank
 * updates interestTaxBank as 0
*/
	function withdrawInterestTax() public onlyOwner {
		require((ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).balanceOf(address(this)) >= interestTaxBank), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).transfer(msg.sender, interestTaxBank);
		interestTaxBank  = uint256(0);
	}

/**
 * Function withdrawToken
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to _amt
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function withdrawToken(uint256 _amt) public onlyOwner {
		require((ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x553F5489eB3200aaB20bA424da63297D6f373Dcb).transfer(msg.sender, _amt);
	}
}