/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

interface IERC721Receiver {
	
	function onERC721Received(
		address operator,
		address from,
		uint256 tokenId,
		bytes calldata data
	) external returns (bytes4);
}

interface ERC20{
	function transfer(address recipient, uint256 amount) external returns (bool);
}

interface ERC721{
	function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract DDBFESTAKING {

	address owner;
	uint256 public interestTaxBank = uint256(0);
	struct record { address staker; uint256 stakeTime; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(uint256 => record) public addressMap;
	mapping(uint256 => uint256) public tokenStore;
	uint256 public numberOfTokensCurrentlyStaked = uint256(0);
	uint256 public interestTaxWhere10000IsOnePercent = uint256(30000);
	uint256 public dailyInterestRate = uint256(20000);
	uint256 public dailyInterestRate_1 = uint256(10000);
	uint256 public dailyInterestRate_2 = uint256(30000);
	uint256 public minStakePeriod = (uint256(1300) * uint256(864));
	mapping(uint256 => uint256) public recordOfNumberOfPreviousStakesForEachToken;
	uint256 public totalWithdrawals = uint256(0);
	struct referralRecord { bool hasDeposited; address referringAddress; uint256 unclaimedRewards; }
	mapping(address => referralRecord) public referralRecordMap;
	event Staked (uint256 indexed tokenId);
	event Unstaked (uint256 indexed tokenId);

	constructor() {
		owner = msg.sender;
	}

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

	function changeValueOf_interestTaxWhere10000IsOnePercent (uint256 _interestTaxWhere10000IsOnePercent) external onlyOwner {
		 interestTaxWhere10000IsOnePercent = _interestTaxWhere10000IsOnePercent;
	}

	function changeValueOf_minStakePeriod (uint256 _minStakePeriod) external onlyOwner {
		 minStakePeriod = _minStakePeriod;
	}	

	function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public returns (bytes4) {
		return this.onERC721Received.selector;
	}

function withdrawReferral(uint256 _amt) public {
		require((referralRecordMap[msg.sender].unclaimedRewards >= _amt), "Insufficient referral rewards to withdraw");
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, _amt);
		referralRecordMap[msg.sender].unclaimedRewards  = (referralRecordMap[msg.sender].unclaimedRewards - _amt);
	}

	function addReferral() internal {
		address referringAddress = referralRecordMap[msg.sender].referringAddress;
		if (!(referralRecordMap[msg.sender].hasDeposited)){
			referralRecordMap[msg.sender].hasDeposited  = true;
		}
		if ((referringAddress == address(0))){
			return;
		}
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + uint256(220000000000000000));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		if ((referringAddress == address(0))){
			return;
		}
		referralRecordMap[referringAddress].unclaimedRewards  = (referralRecordMap[referringAddress].unclaimedRewards + uint256(140000000000000000));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
	}


	function addReferralAddress(address _referringAddress) external {
		require(referralRecordMap[_referringAddress].hasDeposited, "Referring Address has not made a deposit");
		require(!((_referringAddress == msg.sender)), "Self-referrals are not allowed");
		require((referralRecordMap[msg.sender].referringAddress == address(0)), "User has previously indicated a referral address");
		referralRecordMap[msg.sender].referringAddress  = _referringAddress;
	}

	function stake(uint256 _tokenId) public {
		require((recordOfNumberOfPreviousStakesForEachToken[_tokenId] < uint256(1)), "This Token can only be staked 1 time");
		addressMap[_tokenId]  = record (msg.sender, block.timestamp, block.timestamp, uint256(0));
		ERC721(0x92aCbB04912615002B200b4FdDCf32b134D48a46).safeTransferFrom(msg.sender, address(this), _tokenId);
		emit Staked(_tokenId);
		tokenStore[numberOfTokensCurrentlyStaked]  = _tokenId;
		numberOfTokensCurrentlyStaked  = (numberOfTokensCurrentlyStaked + uint256(1));
		addReferral();
		recordOfNumberOfPreviousStakesForEachToken[_tokenId]  = (recordOfNumberOfPreviousStakesForEachToken[_tokenId] + uint256(1));
	}


	function unstake(uint256 _tokenId) public {
		record memory thisRecord = addressMap[_tokenId];
		require(((block.timestamp - minStakePeriod) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 interestToRemove = (thisRecord.accumulatedInterestToUpdateTime + (((minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(19900) * uint256(864)))) - thisRecord.lastUpdateTime) * consolidatedInterestRate(_tokenId) * uint256(1000000000000)) / uint256(864)));
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, ((interestToRemove * (uint256(1000000) - interestTaxWhere10000IsOnePercent)) / uint256(1000000)));
		interestTaxBank  = (interestTaxBank + ((interestToRemove * interestTaxWhere10000IsOnePercent) / uint256(1000000)));
		totalWithdrawals  = (totalWithdrawals + ((interestToRemove * (uint256(1000000) - interestTaxWhere10000IsOnePercent)) / uint256(1000000)));
		require((thisRecord.staker == msg.sender), "You do not own this token");
		ERC721(0x92aCbB04912615002B200b4FdDCf32b134D48a46).safeTransferFrom(address(this), msg.sender, _tokenId);
		delete addressMap[_tokenId];
		emit Unstaked(_tokenId);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			if ((tokenStore[i0] == _tokenId)){
				tokenStore[i0]  = tokenStore[(numberOfTokensCurrentlyStaked - uint256(1))];
				numberOfTokensCurrentlyStaked  = (numberOfTokensCurrentlyStaked - uint256(1));
				break;
			}
		}
	}


	function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			record memory thisRecord = addressMap[tokenStore[i0]];
			addressMap[tokenStore[i0]]  = record (thisRecord.staker, thisRecord.stakeTime, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(19900) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + (((minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(19900) * uint256(864)))) - thisRecord.lastUpdateTime) * consolidatedInterestRate(i0) * uint256(1000000000000)) / uint256(864))));
		}
	}


	function numberOfStakedTokenIDsOfAnAddress(address _address) public view returns (uint256) {
		uint256 _counter = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			uint256 _tokenID = tokenStore[i0];
			if ((addressMap[_tokenID].staker == _address)){
				_counter  = (_counter + uint256(1));
			}
		}
		return _counter;
	}


	function stakedTokenIDsOfAnAddress(address _address) public view returns (uint256[] memory) {
		uint256[] memory tokenIDs = new uint256[](numberOfStakedTokenIDsOfAnAddress(_address));
		uint256 _counter = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			uint256 _tokenID = tokenStore[i0];
			if ((addressMap[_tokenID].staker == _address)){
				tokenIDs[_counter]  = _tokenID;
				_counter  = (_counter + uint256(1));
			}
		}
		return tokenIDs;
	}


	function whichStakedTokenIDsOfAnAddress(address _address, uint256 _counterIn) public view returns (uint256) {
		uint256 _counter = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			uint256 _tokenID = tokenStore[i0];
			if ((addressMap[_tokenID].staker == _address)){
				if ((_counterIn == _counter)){
					return _tokenID;
				}
				_counter  = (_counter + uint256(1));
			}
		}
		return uint256(9999999);
	}


	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(uint256 _tokenId) public view returns (uint256) {
		record memory thisRecord = addressMap[_tokenId];
		return (thisRecord.accumulatedInterestToUpdateTime + (((minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(19900) * uint256(864)))) - thisRecord.lastUpdateTime) * consolidatedInterestRate(_tokenId) * uint256(1000000000000)) / uint256(864)));
	}


	function consolidatedInterestRate(uint256 _tokenId) public view returns (uint256) {
		if ((_tokenId >= uint256(10))){
			return dailyInterestRate_2;
		}
		if ((_tokenId <= uint256(3))){
			return dailyInterestRate_1;
		}
		return dailyInterestRate;
	}


	function modifyDailyInterestRateWhere10000IsOneCoin(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate  = _dailyInterestRate;
	}


	function modifyDailyInterestRateWhere10000IsOneCoin_1(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate_1  = _dailyInterestRate;
	}


	function modifyDailyInterestRateWhere10000IsOneCoin_2(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate_2  = _dailyInterestRate;
	}


	function withdrawInterestTax() public onlyOwner {
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, interestTaxBank);
		interestTaxBank  = uint256(0);
	}

	function withdrawToken(uint256 _amt) public onlyOwner {
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, _amt);
	}
}