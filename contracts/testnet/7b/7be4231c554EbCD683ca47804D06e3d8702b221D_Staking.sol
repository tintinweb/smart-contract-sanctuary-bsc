/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Contract Type : Staking
 * Staking of : NFT Nft_SMR
 * NFT Address : 0x553E10BF1747F10E37885C945dE3657fBC1BaCd2
 * Number of schemes : 1
 * Scheme 1 functions : stake, unstake
*/

interface ERC20{
	function transfer(address recipient, uint256 amount) external returns (bool);
}

interface ERC721{
	function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract Staking {

	address owner;
	struct record { address staker; uint256 stakeTime; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; uint256 amtWithdrawn; }
	mapping(uint256 => record) public addressMap;
	mapping(uint256 => uint256) public tokenStore;
	uint256 public lastToken = 0;
	uint256 public dailyInterestRate = 12600;
	uint256 public dailyInterestRate_1 = 6300;
	mapping(uint256 => uint256) public recordOfNumberOfPreviousStakesForEachToken;
	event Staked (uint256 indexed tokenId);
	event Unstaked (uint256 indexed tokenId);

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

	function minUIntPair(uint _i, uint _j) public pure returns (uint){
		if (_i > _j){
			return _i;
		}else{
			return _j;
		}
	}

/**
 * Function stake
 * Daily Interest Rate : Variable dailyInterestRate
 * This interest rate is modified under certain circumstances, as articulated in the consolidatedInterestRate function
 * Address Map : addressMap
 * The function takes in 1 variable, zero or a positive integer _tokenId. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that (recordOfNumberOfPreviousStakesForEachToken with element _tokenId) is strictly less than 1
 * updates addressMap (Element _tokenId) as Struct comprising (the address that called this function), current time, current time, 0, 0
 * calls ERC721's safeTransferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _tokenId
 * emits event Staked with inputs _tokenId
 * updates tokenStore (Element lastToken) as _tokenId
 * updates lastToken as (_tokenId) + (1)
 * updates recordOfNumberOfPreviousStakesForEachToken (Element _tokenId) as (recordOfNumberOfPreviousStakesForEachToken with element _tokenId) + (1)
*/
	function stake(uint256 _tokenId) public {
		require((recordOfNumberOfPreviousStakesForEachToken[_tokenId] < 1), "This Token can only be staked 1 time");
		addressMap[_tokenId]  = record (msg.sender, block.timestamp, block.timestamp, 0, 0);
		ERC721(0x553E10BF1747F10E37885C945dE3657fBC1BaCd2).safeTransferFrom(msg.sender, address(this), _tokenId);
		emit Staked(_tokenId);
		tokenStore[lastToken]  = _tokenId;
		lastToken  = (_tokenId + 1);
		recordOfNumberOfPreviousStakesForEachToken[_tokenId]  = (recordOfNumberOfPreviousStakesForEachToken[_tokenId] + 1);
	}

/**
 * Function unstake
 * The function takes in 1 variable, zero or a positive integer _tokenId. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element _tokenId
 * creates an internal variable interestToRemove with initial value (thisRecord with element accumulatedInterestToUpdateTime) + ((((minimum of current time, ((thisRecord with element lastUpdateTime) + ((500) * (864)))) - (thisRecord with element lastUpdateTime)) * (consolidatedInterestRate with variable _tokenId as _tokenId)) / (864000000))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as interestToRemove
 * checks that (thisRecord with element staker) is equals to (the address that called this function)
 * calls ERC721's safeTransferFrom function  with variable sender as the address of this contract, variable recipient as the address that called this function, variable amount as _tokenId
 * deletes item _tokenId from mapping addressMap
 * emits event Unstaked with inputs _tokenId
 * repeat lastToken times with loop variable i0 :  (if (tokenStore with element Loop Variable i0) is equals to _tokenId then (updates tokenStore (Element Loop Variable i0) as tokenStore with element (lastToken) - (1); then updates lastToken as (lastToken) - (1); and then terminates the for-next loop))
*/
	function unstake(uint256 _tokenId) public {
		record memory thisRecord = addressMap[_tokenId];
		uint256 interestToRemove = (thisRecord.accumulatedInterestToUpdateTime + (((minUIntPair(block.timestamp, (thisRecord.lastUpdateTime + (500 * 864))) - thisRecord.lastUpdateTime) * consolidatedInterestRate(_tokenId)) / 864000000));
		ERC20(0xd22c5018ecb09f9718CeB2C74C8CE4A0bf658106).transfer(msg.sender, interestToRemove);
		require((thisRecord.staker == msg.sender), "You do not own this token");
		ERC721(0x553E10BF1747F10E37885C945dE3657fBC1BaCd2).safeTransferFrom(address(this), msg.sender, _tokenId);
		delete addressMap[_tokenId];
		emit Unstaked(_tokenId);
		for (uint i0 = 0; i0 < lastToken; i0++){
			if ((tokenStore[i0] == _tokenId)){
				tokenStore[i0]  = tokenStore[(lastToken - 1)];
				lastToken  = (lastToken - 1);
				break;
			}
		}
	}

/**
 * Function updateRecordsWithLatestInterestRates
 * The function takes in 0 variables. It can only be called by other functions in this contract. It does the following :
 * repeat lastToken times with loop variable i0 :  (creates an internal variable thisRecord with initial value addressMap with element tokenStore with element Loop Variable i0; and then updates addressMap (Element tokenStore with element Loop Variable i0) as Struct comprising (thisRecord with element staker), (thisRecord with element stakeTime), (minimum of current time, ((thisRecord with element lastUpdateTime) + ((500) * (864)))), ((thisRecord with element accumulatedInterestToUpdateTime) + ((((minimum of current time, ((thisRecord with element lastUpdateTime) + ((500) * (864)))) - (thisRecord with element lastUpdateTime)) * (consolidatedInterestRate with variable _tokenId as Loop Variable i0)) / (864000000))), (thisRecord with element amtWithdrawn))
*/
	function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < lastToken; i0++){
			record memory thisRecord = addressMap[tokenStore[i0]];
			addressMap[tokenStore[i0]]  = record (thisRecord.staker, thisRecord.stakeTime, minUIntPair(block.timestamp, (thisRecord.lastUpdateTime + (500 * 864))), (thisRecord.accumulatedInterestToUpdateTime + (((minUIntPair(block.timestamp, (thisRecord.lastUpdateTime + (500 * 864))) - thisRecord.lastUpdateTime) * consolidatedInterestRate(i0)) / 864000000)), thisRecord.amtWithdrawn);
		}
	}

/**
 * Function stakedTokenIDsOfAnAddress
 * The function takes in 1 variable, an address _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable tokenIDs with initial value Empty List
 * creates an internal variable _counter with initial value 0
 * repeat lastToken times with loop variable i0 :  (creates an internal variable _tokenID with initial value tokenStore with element Loop Variable i0; and then if (addressMap with element _tokenID with element staker) is equals to _address then (updates tokenIDs (Element _counter) as _tokenID; and then updates _counter as (_counter) + (1)))
 * returns tokenIDs as output
*/
	function stakedTokenIDsOfAnAddress(address _address) public view returns (uint256[] memory) {
		uint256[] memory tokenIDs;
		uint256 _counter = 0;
		for (uint i0 = 0; i0 < lastToken; i0++){
			uint256 _tokenID = tokenStore[i0];
			if ((addressMap[_tokenID].staker == _address)){
				tokenIDs[_counter]  = _tokenID;
				_counter  = (_counter + 1);
			}
		}
		return tokenIDs;
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn
 * The function takes in 1 variable, zero or a positive integer _tokenId. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element _tokenId
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + ((((minimum of current time, ((thisRecord with element lastUpdateTime) + ((500) * (864)))) - (thisRecord with element lastUpdateTime)) * (consolidatedInterestRate with variable _tokenId as _tokenId)) / (864000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(uint256 _tokenId) public view returns (uint256) {
		record memory thisRecord = addressMap[_tokenId];
		return (thisRecord.accumulatedInterestToUpdateTime + (((minUIntPair(block.timestamp, (thisRecord.lastUpdateTime + (500 * 864))) - thisRecord.lastUpdateTime) * consolidatedInterestRate(_tokenId)) / 864000000));
	}

/**
 * Function withdrawDepositWithoutUnstaking
 * The function takes in 2 variables, zero or a positive integer _withdrawalAmt, and zero or a positive integer _tokenId. It can only be called by functions outside of this contract. It does the following :
 * creates an internal variable totalInterestEarnedTillNow with initial value interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn with variable _tokenId as _tokenId
 * checks that _withdrawalAmt is less than or equals to totalInterestEarnedTillNow
 * creates an internal variable thisRecord with initial value addressMap with element _tokenId
 * checks that (thisRecord with element staker) is equals to (the address that called this function)
 * updates addressMap (Element _tokenId) as Struct comprising (thisRecord with element staker), (thisRecord with element stakeTime), (minimum of current time, ((thisRecord with element lastUpdateTime) + ((500) * (864)))), ((totalInterestEarnedTillNow) - (_withdrawalAmt)), ((thisRecord with element amtWithdrawn) + (_withdrawalAmt))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _withdrawalAmt
*/
	function withdrawDepositWithoutUnstaking(uint256 _withdrawalAmt, uint256 _tokenId) external {
		uint256 totalInterestEarnedTillNow = interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(_tokenId);
		require((_withdrawalAmt <= totalInterestEarnedTillNow), "Withdrawn amount must be less than withdrawable amount");
		record memory thisRecord = addressMap[_tokenId];
		require((thisRecord.staker == msg.sender), "You do not own this token");
		addressMap[_tokenId]  = record (thisRecord.staker, thisRecord.stakeTime, minUIntPair(block.timestamp, (thisRecord.lastUpdateTime + (500 * 864))), (totalInterestEarnedTillNow - _withdrawalAmt), (thisRecord.amtWithdrawn + _withdrawalAmt));
		ERC20(0xd22c5018ecb09f9718CeB2C74C8CE4A0bf658106).transfer(msg.sender, _withdrawalAmt);
	}

/**
 * Function consolidatedInterestRate
 * The function takes in 1 variable, zero or a positive integer _tokenId. It can be called by functions both inside and outside of this contract. It does the following :
 * if (8 is less than or equals to _tokenId) and (_tokenId is less than or equals to 15) then (returns dailyInterestRate_1 as output)
 * returns dailyInterestRate as output
*/
	function consolidatedInterestRate(uint256 _tokenId) public view returns (uint256) {
		if (((8 <= _tokenId) && (_tokenId <= 15))){
			return dailyInterestRate_1;
		}
		return dailyInterestRate;
	}

/**
 * Function modifyDailyInterestRateWhere10000IsOnePercent
 * The function takes in 1 variable, zero or a positive integer _dailyInterestRate. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * calls updateRecordsWithLatestInterestRates
 * updates dailyInterestRate as _dailyInterestRate
*/
	function modifyDailyInterestRateWhere10000IsOnePercent(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate  = _dailyInterestRate;
	}

/**
 * Function modifyDailyInterestRateWhere10000IsOnePercent_1
 * The function takes in 1 variable, zero or a positive integer _dailyInterestRate. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * calls updateRecordsWithLatestInterestRates
 * updates dailyInterestRate_1 as _dailyInterestRate
*/
	function modifyDailyInterestRateWhere10000IsOnePercent_1(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate_1  = _dailyInterestRate;
	}

/**
 * Function withdrawToken
 * The function takes in 1 variable, zero or a positive integer _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function withdrawToken(uint256 _amt) public onlyOwner {
		ERC20(0xd22c5018ecb09f9718CeB2C74C8CE4A0bf658106).transfer(msg.sender, _amt);
	}
}