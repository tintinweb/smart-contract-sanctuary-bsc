/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT


interface IERC721Receiver {
	/**
	 * @dev Whenever an {IERC721} `tokenIds` token is transferred to this contract via {IERC721-safeTransferFrom}
	 * by `operator` from `from`, this function is called.
	 *
	 * It must return its Solidity selector to confirm the token transfer.
	 * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
	 *
	 * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
	 */
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

	//This function allows the owner to specify an address that will take over ownership rights instead. Please double check the address provided as once the function is executed, only the new owner will be able to change the address back.
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

/**
 * Function stake
 * Daily Interest Rate : Variable dailyInterestRate
 * Address Map : addressMap
 * The function takes in 1 variable, (zero or a positive integer) _tokenIds. It can be called by functions both inside and outside of this contract. It does the following :
 * updates addressMap (Element _tokenIds) as Struct comprising (the address that called this function), current time, current time, 0
 * calls ERC721's safeTransferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _tokenIds
 * emits event Staked with inputs _tokenIds
 * updates tokenStore (Element numberOfTokensCurrentlyStaked) as _tokenIds
 * updates numberOfTokensCurrentlyStaked as (numberOfTokensCurrentlyStaked) + (1)
*/
	function stake(uint256 _tokenIds) public {
		addressMap[_tokenIds]  = record (msg.sender, block.timestamp, block.timestamp, uint256(0));
		ERC721(0xc20F815cfD7D454437410eA8aB0D06D4d9cAEdf0).safeTransferFrom(msg.sender, address(this), _tokenIds);
		emit Staked(_tokenIds);
		tokenStore[numberOfTokensCurrentlyStaked]  = _tokenIds;
		numberOfTokensCurrentlyStaked  = (numberOfTokensCurrentlyStaked + uint256(1));
	}

/**
 * Function unstake
 * The function takes in 1 variable, (zero or a positive integer) _tokenIds. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element _tokenIds
 * creates an internal variable interestToRemove with initial value (thisRecord with element accumulatedInterestToUpdateTime) + ((((current time) - (thisRecord with element lastUpdateTime)) * (dailyInterestRate) * (1000000000000)) / (864))
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to interestToRemove
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as interestToRemove
 * updates totalWithdrawals as (totalWithdrawals) + (interestToRemove)
 * checks that (thisRecord with element staker) is equals to (the address that called this function)
 * calls ERC721's safeTransferFrom function  with variable sender as the address of this contract, variable recipient as the address that called this function, variable amount as _tokenIds
 * deletes item _tokenIds from mapping addressMap
 * emits event Unstaked with inputs _tokenIds
 * repeat numberOfTokensCurrentlyStaked times with loop variable i0 :  (if (tokenStore with element Loop Variable i0) is equals to _tokenIds then (updates tokenStore (Element Loop Variable i0) as tokenStore with element (numberOfTokensCurrentlyStaked) - (1); then updates numberOfTokensCurrentlyStaked as (numberOfTokensCurrentlyStaked) - (1); and then terminates the for-next loop))
*/
	function unstake(uint256 _tokenIds) public {
		record memory thisRecord = addressMap[_tokenIds];
		uint256 interestToRemove = (thisRecord.accumulatedInterestToUpdateTime + (((block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate * uint256(1000000000000)) / uint256(864)));
		require((ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).balanceOf(address(this)) >= interestToRemove), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, interestToRemove);
		totalWithdrawals  = (totalWithdrawals + interestToRemove);
		require((thisRecord.staker == msg.sender), "You do not own this token");
		ERC721(0xc20F815cfD7D454437410eA8aB0D06D4d9cAEdf0).safeTransferFrom(address(this), msg.sender, _tokenIds);
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

/**
 * Function updateRecordsWithLatestInterestRates
 * The function takes in 0 variables. It can only be called by other functions in this contract. It does the following :
 * repeat numberOfTokensCurrentlyStaked times with loop variable i0 :  (creates an internal variable thisRecord with initial value addressMap with element tokenStore with element Loop Variable i0; and then updates addressMap (Element tokenStore with element Loop Variable i0) as Struct comprising (thisRecord with element staker), (thisRecord with element stakeTime), current time, ((thisRecord with element lastUpdateTime) + ((((current time) - (thisRecord with element lastUpdateTime)) * (dailyInterestRate) * (1000000000000)) / (864))))
*/
	function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			record memory thisRecord = addressMap[tokenStore[i0]];
			addressMap[tokenStore[i0]]  = record (thisRecord.staker, thisRecord.stakeTime, block.timestamp, (thisRecord.lastUpdateTime + (((block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate * uint256(1000000000000)) / uint256(864))));
		}
	}

/**
 * Function numberOfStakedtokenIdssOfAnAddress
 * The function takes in 1 variable, (an address) _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable _counter with initial value 0
 * repeat numberOfTokensCurrentlyStaked times with loop variable i0 :  (creates an internal variable _tokenIds with initial value tokenStore with element Loop Variable i0; and then if (addressMap with element _tokenIds with element staker) is equals to _address then (updates _counter as (_counter) + (1)))
 * returns _counter as output
*/
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

/**
 * Function stakedtokenIdssOfAnAddress
 * The function takes in 1 variable, (an address) _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable tokenIdss
 * creates an internal variable _counter with initial value 0
 * repeat numberOfTokensCurrentlyStaked times with loop variable i0 :  (creates an internal variable _tokenIds with initial value tokenStore with element Loop Variable i0; and then if (addressMap with element _tokenIds with element staker) is equals to _address then (updates tokenIdss (Element _counter) as _tokenIds; and then updates _counter as (_counter) + (1)))
 * returns tokenIdss as output
*/
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

/**
 * Function whichStakedtokenIdssOfAnAddress
 * The function takes in 2 variables, (an address) _address, and (zero or a positive integer) _counterIn. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable _counter with initial value 0
 * repeat numberOfTokensCurrentlyStaked times with loop variable i0 :  (creates an internal variable _tokenIds with initial value tokenStore with element Loop Variable i0; and then if (addressMap with element _tokenIds with element staker) is equals to _address then (if _counterIn is equals to _counter then (returns _tokenIds as output); and then updates _counter as (_counter) + (1)))
 * returns 9999999 as output
*/
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

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn
 * The function takes in 1 variable, (zero or a positive integer) _tokenIds. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap with element _tokenIds
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + ((((current time) - (thisRecord with element lastUpdateTime)) * (dailyInterestRate) * (1000000000000)) / (864)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(uint256 _tokenIds) public view returns (uint256) {
		record memory thisRecord = addressMap[_tokenIds];
		return (thisRecord.accumulatedInterestToUpdateTime + (((block.timestamp - thisRecord.lastUpdateTime) * dailyInterestRate * uint256(1000000000000)) / uint256(864)));
	}

/**
 * Function totalAccumulatedInterest
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable total with initial value 0
 * repeat numberOfTokensCurrentlyStaked times with loop variable i0 :  (updates total as (total) + (interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn with variable _tokenIds as Loop Variable i0))
 * returns total as output
*/
	function totalAccumulatedInterest() public view returns (uint256) {
		uint256 total = uint256(0);
		for (uint i0 = 0; i0 < numberOfTokensCurrentlyStaked; i0++){
			total  = (total + interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn(i0));
		}
		return total;
	}

/**
 * Function modifyDailyInterestRate
 * Notes for _dailyInterestRate : 10000 is one coin
 * The function takes in 1 variable, (zero or a positive integer) _dailyInterestRate. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * calls updateRecordsWithLatestInterestRates
 * updates dailyInterestRate as _dailyInterestRate
*/
	function modifyDailyInterestRate(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate  = _dailyInterestRate;
	}

/**
 * Function multipleStake
 * The function takes in 1 variable, (a list of zeros or positive integers) tokenIdss. It can be called by functions both inside and outside of this contract. It does the following :
 * repeat length of tokenIdss times with loop variable i0 :  (calls stake with variable _tokenIds as tokenIdss with element Loop Variable i0)
*/
	function multipleStake(uint256[] memory tokenIdss) public {
		for (uint i0 = 0; i0 < (tokenIdss).length; i0++){
			stake(tokenIdss[i0]);
		}
	}

/**
 * Function multipleUnstake
 * The function takes in 1 variable, (a list of zeros or positive integers) tokenIdss. It can be called by functions both inside and outside of this contract. It does the following :
 * repeat length of tokenIdss times with loop variable i0 :  (calls unstake with variable _tokenIds as tokenIdss with element Loop Variable i0)
*/
	function multipleUnstake(uint256[] memory tokenIdss) public {
		for (uint i0 = 0; i0 < (tokenIdss).length; i0++){
			unstake(tokenIdss[i0]);
		}
	}

/**
 * Function withdrawToken
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to ((_amt) + (totalAccumulatedInterest))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function claim(uint256 _amt) public onlyOwner {
		require((ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).balanceOf(address(this)) >= (_amt + totalAccumulatedInterest())), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x0CAa608A4a553fa446118C61760dEa96a6ba8c58).transfer(msg.sender, _amt);
	}
}