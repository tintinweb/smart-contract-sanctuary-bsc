/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT


interface IERC721Receiver {
	
	function onERC721Received(
		address operator,
		address from,
		uint256 tokenIds,
		bytes calldata data
	) external returns (bytes4);
}

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
}

interface ERC721{
	function safeTransferFrom(address from, address to, uint256 tokenIds) external;
}

contract Staking {

	address owner;
	struct record { address staker; uint256 stakeTime; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(uint256 => record) public addressMap;
	mapping(uint256 => uint256) public tokenStore;
	uint256 public numberOfTokensCurrentlyStaked = uint256(0);
	uint256 public dailyInterestRate = uint256(10000000);
	uint256 public totalWithdrawals = uint256(0);
	event Staked (uint256 indexed tokenIds);
	event Unstaked (uint256 indexed tokenIds);

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

	function onERC721Received( address, address, uint256, bytes calldata ) public pure returns (bytes4) {
		return this.onERC721Received.selector;
	}



	function stake(uint256 _tokenIds) public {
		addressMap[_tokenIds]  = record (msg.sender, block.timestamp, block.timestamp, uint256(0));
		ERC721(0x92aCbB04912615002B200b4FdDCf32b134D48a46).safeTransferFrom(msg.sender, address(this), _tokenIds);
		emit Staked(_tokenIds);
		tokenStore[numberOfTokensCurrentlyStaked]  = _tokenIds;
		numberOfTokensCurrentlyStaked  = (numberOfTokensCurrentlyStaked + uint256(1));
	}


	function unstake(uint256 _tokenIds) public {
		record memory thisRecord = addressMap[_tokenIds];
		uint256 interestToRemove = (thisRecord.accumulatedInterestToUpdateTime + (((block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate * uint256(1000000000000)) / uint256(864)));
		require((ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).balanceOf(address(this)) >= interestToRemove), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, interestToRemove);
		totalWithdrawals  = (totalWithdrawals + interestToRemove);
		require((thisRecord.staker == msg.sender), "You do not own this token");
		ERC721(0x92aCbB04912615002B200b4FdDCf32b134D48a46).safeTransferFrom(address(this), msg.sender, _tokenIds);
		delete addressMap[_tokenIds];
		emit Unstaked(_tokenIds);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			if ((tokenStore[i0] == _tokenIds)){
				tokenStore[i0]  = tokenStore[(numberOfTokensCurrentlyStaked - uint256(1))];
				numberOfTokensCurrentlyStaked  = (numberOfTokensCurrentlyStaked - uint256(1));
				break;
			}
		}
	}


	function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			record memory thisRecord = addressMap[tokenStore[i0]];
			addressMap[tokenStore[i0]]  = record (thisRecord.staker, thisRecord.stakeTime, block.timestamp, (thisRecord.lastUpdateTime + (((block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate * uint256(1000000000000)) / uint256(864))));
		}
	}


	function numberOfStakedtokenIdssOfAnAddress(address _address) public view returns (uint256) {
		uint256 _counter = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			uint256 _tokenIds = tokenStore[i0];
			if ((addressMap[_tokenIds].staker == _address)){
				_counter  = (_counter + uint256(1));
			}
		}
		return _counter;
	}


	function stakedtokenIdssOfAnAddress(address _address) public view returns (uint256[] memory) {
		uint256[] memory tokenIdss;
		uint256 _counter = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			uint256 _tokenIds = tokenStore[i0];
			if ((addressMap[_tokenIds].staker == _address)){
				tokenIdss[_counter]  = _tokenIds;
				_counter  = (_counter + uint256(1));
			}
		}
		return tokenIdss;
	}


	function whichStakedtokenIdssOfAnAddress(address _address, uint256 _counterIn) public view returns (uint256) {
		uint256 _counter = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			uint256 _tokenIds = tokenStore[i0];
			if ((addressMap[_tokenIds].staker == _address)){
				if ((_counterIn == _counter)){
					return _tokenIds;
				}
				_counter  = (_counter + uint256(1));
			}
		}
		return uint256(9999999);
	}


	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(uint256 _tokenIds) public view returns (uint256) {
		record memory thisRecord = addressMap[_tokenIds];
		return (thisRecord.accumulatedInterestToUpdateTime + (((block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate * uint256(1000000000000)) / uint256(864)));
	}

	function totalAccumulatedInterest() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			total  = (total + interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(i0));
		}
		return total;
	}


	function modifyDailyInterestRate(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate  = _dailyInterestRate;
	}


	function multipleStake(uint256[] memory tokenIdss) public {
		for (uint i0 = 0; i0 < (tokenIdss).length; i0++){
			stake(tokenIdss[i0]);
		}
	}


	function multipleUnstake(uint256[] memory tokenIdss) public {
		for (uint i0 = 0; i0 < (tokenIdss).length; i0++){
			unstake(tokenIdss[i0]);
		}
	}


	function claim(uint256 _amt) public onlyOwner {
		require((ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).balanceOf(address(this)) >= (_amt + totalAccumulatedInterest())), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, _amt);
	}
}