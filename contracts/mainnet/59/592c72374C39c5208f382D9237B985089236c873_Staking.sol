/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Contract Type : Staking
 * Staking of : Coin Algomoon
 * Coin Address : 0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF
 * Number of schemes : 5
 * Scheme 1 functions : stake1, unstake1
 * Scheme 2 functions : stake2, unstake2
 * Scheme 3 functions : stake3, unstake3
 * Scheme 4 functions : stake4, unstake4
 * Scheme 5 functions : stake5, unstake5
*/

interface ERC20{
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Staking {

	address owner;
	struct record1 { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(address => record1) public addressMap1;
	mapping(uint256 => address) public addressStore1;
	uint256 public numberOfAddressesCurrentlyStaked1 = uint256(0);
	uint256 public totalWithdrawals1 = uint256(0);
	struct record2 { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(address => record2) public addressMap2;
	mapping(uint256 => address) public addressStore2;
	uint256 public numberOfAddressesCurrentlyStaked2 = uint256(0);
	uint256 public totalWithdrawals2 = uint256(0);
	struct record3 { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(address => record3) public addressMap3;
	mapping(uint256 => address) public addressStore3;
	uint256 public numberOfAddressesCurrentlyStaked3 = uint256(0);
	uint256 public totalWithdrawals3 = uint256(0);
	struct record4 { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(address => record4) public addressMap4;
	mapping(uint256 => address) public addressStore4;
	uint256 public numberOfAddressesCurrentlyStaked4 = uint256(0);
	uint256 public totalWithdrawals4 = uint256(0);
	struct record5 { uint256 stakeTime; uint256 stakeAmt; uint256 lastUpdateTime; uint256 accumulatedInterestToUpdateTime; }
	mapping(address => record5) public addressMap5;
	mapping(uint256 => address) public addressStore5;
	uint256 public numberOfAddressesCurrentlyStaked5 = uint256(0);
	uint256 public dailyInterestRate5 = uint256(10000);
	uint256 public dailyInterestRate5_1 = uint256(10000);
	uint256 public minStakePeriod5 = (uint256(100) * uint256(864));
	uint256 public totalWithdrawals5 = uint256(0);
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
 * This function allows the owner to change the value of minStakePeriod5.
 * Notes for _minStakePeriod5 : 1 day is represented by 86400 (seconds)
*/
	function changeValueOf_minStakePeriod5 (uint256 _minStakePeriod5) external onlyOwner {
		 minStakePeriod5 = _minStakePeriod5;
	}

/**
 * Function stake1
 * Daily Interest Rate : 2
 * Minimum Stake Period : 90 days
 * Address Map : addressMap1
 * ERC20 Transfer : 0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF, _stakeAmt
 * The function takes in 1 variable, zero or a positive integer _stakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that _stakeAmt is strictly greater than 0
 * creates an internal variable thisRecord with initial value addressMap1 with element the address that called this function
 * checks that (thisRecord with element stakeAmt) is equals to 0
 * updates addressMap1 (Element the address that called this function) as Struct comprising current time, _stakeAmt, current time, 0
 * updates addressStore1 (Element numberOfAddressesCurrentlyStaked1) as the address that called this function
 * updates numberOfAddressesCurrentlyStaked1 as (numberOfAddressesCurrentlyStaked1) + (1)
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _stakeAmt
 * emits event Staked with inputs the address that called this function
*/
	function stake1(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record1 memory thisRecord = addressMap1[msg.sender];
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		addressMap1[msg.sender]  = record1 (block.timestamp, _stakeAmt, block.timestamp, uint256(0));
		addressStore1[numberOfAddressesCurrentlyStaked1]  = msg.sender;
		numberOfAddressesCurrentlyStaked1  = (numberOfAddressesCurrentlyStaked1 + uint256(1));
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transferFrom(msg.sender, address(this), _stakeAmt);
		emit Staked(msg.sender);
	}

/**
 * Function unstake1
 * The function takes in 1 variable, zero or a positive integer _unstakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap1 with element the address that called this function
 * checks that _unstakeAmt is less than or equals to (thisRecord with element stakeAmt)
 * checks that ((current time) - ((9000) * (864))) is greater than or equals to (thisRecord with element stakeTime)
 * creates an internal variable newAccum with initial value (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((9000) * (864)))) - (thisRecord with element lastUpdateTime)) * (20000)) / (86400000000))
 * creates an internal variable interestToRemove with initial value ((newAccum) * (_unstakeAmt)) / (thisRecord with element stakeAmt)
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as (_unstakeAmt) + (interestToRemove)
 * updates totalWithdrawals1 as (totalWithdrawals1) + (interestToRemove)
 * if _unstakeAmt is equals to (thisRecord with element stakeAmt) then (repeat numberOfAddressesCurrentlyStaked1 times with loop variable i0 :  (if (addressStore1 with element Loop Variable i0) is equals to (the address that called this function) then (updates addressStore1 (Element Loop Variable i0) as addressStore1 with element (numberOfAddressesCurrentlyStaked1) - (1); then updates numberOfAddressesCurrentlyStaked1 as (numberOfAddressesCurrentlyStaked1) - (1); and then terminates the for-next loop)))
 * updates addressMap1 (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), ((thisRecord with element stakeAmt) - (_unstakeAmt)), (thisRecord with element lastUpdateTime), ((newAccum) - (interestToRemove))
 * emits event Unstaked with inputs the address that called this function
*/
	function unstake1(uint256 _unstakeAmt) public {
		record1 memory thisRecord = addressMap1[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - (uint256(9000) * uint256(864))) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(9000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(20000)) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transfer(msg.sender, (_unstakeAmt + interestToRemove));
		totalWithdrawals1  = (totalWithdrawals1 + interestToRemove);
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked1; i0++){
				if ((addressStore1[i0] == msg.sender)){
					addressStore1[i0]  = addressStore1[(numberOfAddressesCurrentlyStaked1 - uint256(1))];
					numberOfAddressesCurrentlyStaked1  = (numberOfAddressesCurrentlyStaked1 - uint256(1));
					break;
				}
			}
		}
		addressMap1[msg.sender]  = record1 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), thisRecord.lastUpdateTime, (newAccum - interestToRemove));
		emit Unstaked(msg.sender);
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn1
 * The function takes in 1 variable, an address _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap1 with element _address
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((9000) * (864)))) - (thisRecord with element lastUpdateTime)) * (20000)) / (86400000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn1(address _address) public view returns (uint256) {
		record1 memory thisRecord = addressMap1[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(9000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(20000)) / uint256(86400000000)));
	}

/**
 * Function stake2
 * Daily Interest Rate : 3
 * Minimum Stake Period : 180 days
 * Address Map : addressMap2
 * ERC20 Transfer : 0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF, _stakeAmt
 * The function takes in 1 variable, zero or a positive integer _stakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that _stakeAmt is strictly greater than 0
 * creates an internal variable thisRecord with initial value addressMap2 with element the address that called this function
 * checks that (thisRecord with element stakeAmt) is equals to 0
 * updates addressMap2 (Element the address that called this function) as Struct comprising current time, _stakeAmt, current time, 0
 * updates addressStore2 (Element numberOfAddressesCurrentlyStaked2) as the address that called this function
 * updates numberOfAddressesCurrentlyStaked2 as (numberOfAddressesCurrentlyStaked2) + (1)
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _stakeAmt
 * emits event Staked with inputs the address that called this function
*/
	function stake2(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record2 memory thisRecord = addressMap2[msg.sender];
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		addressMap2[msg.sender]  = record2 (block.timestamp, _stakeAmt, block.timestamp, uint256(0));
		addressStore2[numberOfAddressesCurrentlyStaked2]  = msg.sender;
		numberOfAddressesCurrentlyStaked2  = (numberOfAddressesCurrentlyStaked2 + uint256(1));
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transferFrom(msg.sender, address(this), _stakeAmt);
		emit Staked(msg.sender);
	}

/**
 * Function unstake2
 * The function takes in 1 variable, zero or a positive integer _unstakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap2 with element the address that called this function
 * checks that _unstakeAmt is less than or equals to (thisRecord with element stakeAmt)
 * checks that ((current time) - ((18000) * (864))) is greater than or equals to (thisRecord with element stakeTime)
 * creates an internal variable newAccum with initial value (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((18000) * (864)))) - (thisRecord with element lastUpdateTime)) * (30000)) / (86400000000))
 * creates an internal variable interestToRemove with initial value ((newAccum) * (_unstakeAmt)) / (thisRecord with element stakeAmt)
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as (_unstakeAmt) + (interestToRemove)
 * updates totalWithdrawals2 as (totalWithdrawals2) + (interestToRemove)
 * if _unstakeAmt is equals to (thisRecord with element stakeAmt) then (repeat numberOfAddressesCurrentlyStaked2 times with loop variable i0 :  (if (addressStore2 with element Loop Variable i0) is equals to (the address that called this function) then (updates addressStore2 (Element Loop Variable i0) as addressStore2 with element (numberOfAddressesCurrentlyStaked2) - (1); then updates numberOfAddressesCurrentlyStaked2 as (numberOfAddressesCurrentlyStaked2) - (1); and then terminates the for-next loop)))
 * updates addressMap2 (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), ((thisRecord with element stakeAmt) - (_unstakeAmt)), (thisRecord with element lastUpdateTime), ((newAccum) - (interestToRemove))
 * emits event Unstaked with inputs the address that called this function
*/
	function unstake2(uint256 _unstakeAmt) public {
		record2 memory thisRecord = addressMap2[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - (uint256(18000) * uint256(864))) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(18000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(30000)) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transfer(msg.sender, (_unstakeAmt + interestToRemove));
		totalWithdrawals2  = (totalWithdrawals2 + interestToRemove);
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked2; i0++){
				if ((addressStore2[i0] == msg.sender)){
					addressStore2[i0]  = addressStore2[(numberOfAddressesCurrentlyStaked2 - uint256(1))];
					numberOfAddressesCurrentlyStaked2  = (numberOfAddressesCurrentlyStaked2 - uint256(1));
					break;
				}
			}
		}
		addressMap2[msg.sender]  = record2 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), thisRecord.lastUpdateTime, (newAccum - interestToRemove));
		emit Unstaked(msg.sender);
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn2
 * The function takes in 1 variable, an address _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap2 with element _address
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((18000) * (864)))) - (thisRecord with element lastUpdateTime)) * (30000)) / (86400000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn2(address _address) public view returns (uint256) {
		record2 memory thisRecord = addressMap2[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(18000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(30000)) / uint256(86400000000)));
	}

/**
 * Function stake3
 * Daily Interest Rate : 4
 * Minimum Stake Period : 270 days
 * Address Map : addressMap3
 * ERC20 Transfer : 0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF, _stakeAmt
 * The function takes in 1 variable, zero or a positive integer _stakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that _stakeAmt is strictly greater than 0
 * creates an internal variable thisRecord with initial value addressMap3 with element the address that called this function
 * checks that (thisRecord with element stakeAmt) is equals to 0
 * updates addressMap3 (Element the address that called this function) as Struct comprising current time, _stakeAmt, current time, 0
 * updates addressStore3 (Element numberOfAddressesCurrentlyStaked3) as the address that called this function
 * updates numberOfAddressesCurrentlyStaked3 as (numberOfAddressesCurrentlyStaked3) + (1)
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _stakeAmt
 * emits event Staked with inputs the address that called this function
*/
	function stake3(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record3 memory thisRecord = addressMap3[msg.sender];
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		addressMap3[msg.sender]  = record3 (block.timestamp, _stakeAmt, block.timestamp, uint256(0));
		addressStore3[numberOfAddressesCurrentlyStaked3]  = msg.sender;
		numberOfAddressesCurrentlyStaked3  = (numberOfAddressesCurrentlyStaked3 + uint256(1));
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transferFrom(msg.sender, address(this), _stakeAmt);
		emit Staked(msg.sender);
	}

/**
 * Function unstake3
 * The function takes in 1 variable, zero or a positive integer _unstakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap3 with element the address that called this function
 * checks that _unstakeAmt is less than or equals to (thisRecord with element stakeAmt)
 * checks that ((current time) - ((27000) * (864))) is greater than or equals to (thisRecord with element stakeTime)
 * creates an internal variable newAccum with initial value (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((27000) * (864)))) - (thisRecord with element lastUpdateTime)) * (40000)) / (86400000000))
 * creates an internal variable interestToRemove with initial value ((newAccum) * (_unstakeAmt)) / (thisRecord with element stakeAmt)
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as (_unstakeAmt) + (interestToRemove)
 * updates totalWithdrawals3 as (totalWithdrawals3) + (interestToRemove)
 * if _unstakeAmt is equals to (thisRecord with element stakeAmt) then (repeat numberOfAddressesCurrentlyStaked3 times with loop variable i0 :  (if (addressStore3 with element Loop Variable i0) is equals to (the address that called this function) then (updates addressStore3 (Element Loop Variable i0) as addressStore3 with element (numberOfAddressesCurrentlyStaked3) - (1); then updates numberOfAddressesCurrentlyStaked3 as (numberOfAddressesCurrentlyStaked3) - (1); and then terminates the for-next loop)))
 * updates addressMap3 (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), ((thisRecord with element stakeAmt) - (_unstakeAmt)), (thisRecord with element lastUpdateTime), ((newAccum) - (interestToRemove))
 * emits event Unstaked with inputs the address that called this function
*/
	function unstake3(uint256 _unstakeAmt) public {
		record3 memory thisRecord = addressMap3[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - (uint256(27000) * uint256(864))) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(27000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(40000)) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transfer(msg.sender, (_unstakeAmt + interestToRemove));
		totalWithdrawals3  = (totalWithdrawals3 + interestToRemove);
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked3; i0++){
				if ((addressStore3[i0] == msg.sender)){
					addressStore3[i0]  = addressStore3[(numberOfAddressesCurrentlyStaked3 - uint256(1))];
					numberOfAddressesCurrentlyStaked3  = (numberOfAddressesCurrentlyStaked3 - uint256(1));
					break;
				}
			}
		}
		addressMap3[msg.sender]  = record3 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), thisRecord.lastUpdateTime, (newAccum - interestToRemove));
		emit Unstaked(msg.sender);
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn3
 * The function takes in 1 variable, an address _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap3 with element _address
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((27000) * (864)))) - (thisRecord with element lastUpdateTime)) * (40000)) / (86400000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn3(address _address) public view returns (uint256) {
		record3 memory thisRecord = addressMap3[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(27000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(40000)) / uint256(86400000000)));
	}

/**
 * Function stake4
 * Daily Interest Rate : 5
 * Minimum Stake Period : 360 days
 * Address Map : addressMap4
 * ERC20 Transfer : 0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF, _stakeAmt
 * The function takes in 1 variable, zero or a positive integer _stakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that _stakeAmt is strictly greater than 0
 * creates an internal variable thisRecord with initial value addressMap4 with element the address that called this function
 * checks that (thisRecord with element stakeAmt) is equals to 0
 * updates addressMap4 (Element the address that called this function) as Struct comprising current time, _stakeAmt, current time, 0
 * updates addressStore4 (Element numberOfAddressesCurrentlyStaked4) as the address that called this function
 * updates numberOfAddressesCurrentlyStaked4 as (numberOfAddressesCurrentlyStaked4) + (1)
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _stakeAmt
 * emits event Staked with inputs the address that called this function
*/
	function stake4(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record4 memory thisRecord = addressMap4[msg.sender];
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		addressMap4[msg.sender]  = record4 (block.timestamp, _stakeAmt, block.timestamp, uint256(0));
		addressStore4[numberOfAddressesCurrentlyStaked4]  = msg.sender;
		numberOfAddressesCurrentlyStaked4  = (numberOfAddressesCurrentlyStaked4 + uint256(1));
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transferFrom(msg.sender, address(this), _stakeAmt);
		emit Staked(msg.sender);
	}

/**
 * Function unstake4
 * The function takes in 1 variable, zero or a positive integer _unstakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap4 with element the address that called this function
 * checks that _unstakeAmt is less than or equals to (thisRecord with element stakeAmt)
 * checks that ((current time) - ((36000) * (864))) is greater than or equals to (thisRecord with element stakeTime)
 * creates an internal variable newAccum with initial value (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((36000) * (864)))) - (thisRecord with element lastUpdateTime)) * (50000)) / (86400000000))
 * creates an internal variable interestToRemove with initial value ((newAccum) * (_unstakeAmt)) / (thisRecord with element stakeAmt)
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as (_unstakeAmt) + (interestToRemove)
 * updates totalWithdrawals4 as (totalWithdrawals4) + (interestToRemove)
 * if _unstakeAmt is equals to (thisRecord with element stakeAmt) then (repeat numberOfAddressesCurrentlyStaked4 times with loop variable i0 :  (if (addressStore4 with element Loop Variable i0) is equals to (the address that called this function) then (updates addressStore4 (Element Loop Variable i0) as addressStore4 with element (numberOfAddressesCurrentlyStaked4) - (1); then updates numberOfAddressesCurrentlyStaked4 as (numberOfAddressesCurrentlyStaked4) - (1); and then terminates the for-next loop)))
 * updates addressMap4 (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), ((thisRecord with element stakeAmt) - (_unstakeAmt)), (thisRecord with element lastUpdateTime), ((newAccum) - (interestToRemove))
 * emits event Unstaked with inputs the address that called this function
*/
	function unstake4(uint256 _unstakeAmt) public {
		record4 memory thisRecord = addressMap4[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - (uint256(36000) * uint256(864))) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(36000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(50000)) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transfer(msg.sender, (_unstakeAmt + interestToRemove));
		totalWithdrawals4  = (totalWithdrawals4 + interestToRemove);
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked4; i0++){
				if ((addressStore4[i0] == msg.sender)){
					addressStore4[i0]  = addressStore4[(numberOfAddressesCurrentlyStaked4 - uint256(1))];
					numberOfAddressesCurrentlyStaked4  = (numberOfAddressesCurrentlyStaked4 - uint256(1));
					break;
				}
			}
		}
		addressMap4[msg.sender]  = record4 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), thisRecord.lastUpdateTime, (newAccum - interestToRemove));
		emit Unstaked(msg.sender);
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn4
 * The function takes in 1 variable, an address _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap4 with element _address
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((36000) * (864)))) - (thisRecord with element lastUpdateTime)) * (50000)) / (86400000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn4(address _address) public view returns (uint256) {
		record4 memory thisRecord = addressMap4[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(36000) * uint256(864)))) - thisRecord.lastUpdateTime) * uint256(50000)) / uint256(86400000000)));
	}

/**
 * Function stake5
 * Daily Interest Rate : Variable dailyInterestRate5
 * This interest rate is modified under certain circumstances, as articulated in the consolidatedInterestRate5 function
 * Minimum Stake Period : Variable minStakePeriod5
 * Address Map : addressMap5
 * ERC20 Transfer : 0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF, _stakeAmt
 * The function takes in 1 variable, zero or a positive integer _stakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that _stakeAmt is strictly greater than 0
 * creates an internal variable thisRecord with initial value addressMap5 with element the address that called this function
 * checks that (thisRecord with element stakeAmt) is equals to 0
 * updates addressMap5 (Element the address that called this function) as Struct comprising current time, _stakeAmt, current time, 0
 * updates addressStore5 (Element numberOfAddressesCurrentlyStaked5) as the address that called this function
 * updates numberOfAddressesCurrentlyStaked5 as (numberOfAddressesCurrentlyStaked5) + (1)
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as _stakeAmt
 * emits event Staked with inputs the address that called this function
*/
	function stake5(uint256 _stakeAmt) public {
		require((_stakeAmt > uint256(0)), "Staked amount needs to be greater than 0");
		record5 memory thisRecord = addressMap5[msg.sender];
		require((thisRecord.stakeAmt == uint256(0)), "Need to unstake before restaking");
		addressMap5[msg.sender]  = record5 (block.timestamp, _stakeAmt, block.timestamp, uint256(0));
		addressStore5[numberOfAddressesCurrentlyStaked5]  = msg.sender;
		numberOfAddressesCurrentlyStaked5  = (numberOfAddressesCurrentlyStaked5 + uint256(1));
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transferFrom(msg.sender, address(this), _stakeAmt);
		emit Staked(msg.sender);
	}

/**
 * Function unstake5
 * The function takes in 1 variable, zero or a positive integer _unstakeAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap5 with element the address that called this function
 * checks that _unstakeAmt is less than or equals to (thisRecord with element stakeAmt)
 * checks that ((current time) - (minStakePeriod5)) is greater than or equals to (thisRecord with element stakeTime)
 * creates an internal variable newAccum with initial value (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((100) * (864)))) - (thisRecord with element lastUpdateTime)) * (consolidatedInterestRate5 with variable _stakedAmt as thisRecord with element stakeAmt)) / (86400000000))
 * creates an internal variable interestToRemove with initial value ((newAccum) * (_unstakeAmt)) / (thisRecord with element stakeAmt)
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as (_unstakeAmt) + (interestToRemove)
 * updates totalWithdrawals5 as (totalWithdrawals5) + (interestToRemove)
 * if _unstakeAmt is equals to (thisRecord with element stakeAmt) then (repeat numberOfAddressesCurrentlyStaked5 times with loop variable i0 :  (if (addressStore5 with element Loop Variable i0) is equals to (the address that called this function) then (updates addressStore5 (Element Loop Variable i0) as addressStore5 with element (numberOfAddressesCurrentlyStaked5) - (1); then updates numberOfAddressesCurrentlyStaked5 as (numberOfAddressesCurrentlyStaked5) - (1); and then terminates the for-next loop)))
 * updates addressMap5 (Element the address that called this function) as Struct comprising (thisRecord with element stakeTime), ((thisRecord with element stakeAmt) - (_unstakeAmt)), (thisRecord with element lastUpdateTime), ((newAccum) - (interestToRemove))
 * emits event Unstaked with inputs the address that called this function
*/
	function unstake5(uint256 _unstakeAmt) public {
		record5 memory thisRecord = addressMap5[msg.sender];
		require((_unstakeAmt <= thisRecord.stakeAmt), "Withdrawing more than staked amount");
		require(((block.timestamp - minStakePeriod5) >= thisRecord.stakeTime), "Insufficient stake period");
		uint256 newAccum = (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(100) * uint256(864)))) - thisRecord.lastUpdateTime) * consolidatedInterestRate5(thisRecord.stakeAmt)) / uint256(86400000000)));
		uint256 interestToRemove = ((newAccum * _unstakeAmt) / thisRecord.stakeAmt);
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transfer(msg.sender, (_unstakeAmt + interestToRemove));
		totalWithdrawals5  = (totalWithdrawals5 + interestToRemove);
		if ((_unstakeAmt == thisRecord.stakeAmt)){
			for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked5; i0++){
				if ((addressStore5[i0] == msg.sender)){
					addressStore5[i0]  = addressStore5[(numberOfAddressesCurrentlyStaked5 - uint256(1))];
					numberOfAddressesCurrentlyStaked5  = (numberOfAddressesCurrentlyStaked5 - uint256(1));
					break;
				}
			}
		}
		addressMap5[msg.sender]  = record5 (thisRecord.stakeTime, (thisRecord.stakeAmt - _unstakeAmt), thisRecord.lastUpdateTime, (newAccum - interestToRemove));
		emit Unstaked(msg.sender);
	}

/**
 * Function updateRecordsWithLatestInterestRates
 * The function takes in 0 variables. It can only be called by other functions in this contract. It does the following :
 * repeat numberOfAddressesCurrentlyStaked5 times with loop variable i0 :  (creates an internal variable thisRecord with initial value addressMap5 with element addressStore5 with element Loop Variable i0; and then updates addressMap5 (Element addressStore5 with element Loop Variable i0) as Struct comprising (thisRecord with element stakeTime), (thisRecord with element stakeAmt), (minimum of current time, ((thisRecord with element stakeTime) + ((100) * (864)))), ((thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((100) * (864)))) - (thisRecord with element lastUpdateTime)) * (consolidatedInterestRate5 with variable _stakedAmt as Loop Variable i0)) / (86400000000))))
*/
	function updateRecordsWithLatestInterestRates() internal {
		for (uint i0 = 0; i0 < numberOfAddressesCurrentlyStaked5; i0++){
			record5 memory thisRecord = addressMap5[addressStore5[i0]];
			addressMap5[addressStore5[i0]]  = record5 (thisRecord.stakeTime, thisRecord.stakeAmt, minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(100) * uint256(864)))), (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(100) * uint256(864)))) - thisRecord.lastUpdateTime) * consolidatedInterestRate5(i0)) / uint256(86400000000))));
		}
	}

/**
 * Function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn5
 * The function takes in 1 variable, an address _address. It can be called by functions both inside and outside of this contract. It does the following :
 * creates an internal variable thisRecord with initial value addressMap5 with element _address
 * returns (thisRecord with element accumulatedInterestToUpdateTime) + (((thisRecord with element stakeAmt) * ((minimum of current time, ((thisRecord with element stakeTime) + ((100) * (864)))) - (thisRecord with element lastUpdateTime)) * (consolidatedInterestRate5 with variable _stakedAmt as thisRecord with element stakeAmt)) / (86400000000)) as output
*/
	function interestEarnedUpToNowBeforeTaxesAndNotYetWithdrawn5(address _address) public view returns (uint256) {
		record5 memory thisRecord = addressMap5[_address];
		return (thisRecord.accumulatedInterestToUpdateTime + ((thisRecord.stakeAmt * (minUIntPair(block.timestamp, (thisRecord.stakeTime + (uint256(100) * uint256(864)))) - thisRecord.lastUpdateTime) * consolidatedInterestRate5(thisRecord.stakeAmt)) / uint256(86400000000)));
	}

/**
 * Function consolidatedInterestRate5
 * The function takes in 1 variable, zero or a positive integer _stakedAmt. It can be called by functions both inside and outside of this contract. It does the following :
 * if (8887000000000000000000 is less than or equals to _stakedAmt) and (_stakedAmt is less than or equals to 8889000000000000000000) then (returns dailyInterestRate5_1 as output)
 * returns dailyInterestRate5 as output
*/
	function consolidatedInterestRate5(uint256 _stakedAmt) public view returns (uint256) {
		if (((uint256(8887000000000000000000) <= _stakedAmt) && (_stakedAmt <= uint256(8889000000000000000000)))){
			return dailyInterestRate5_1;
		}
		return dailyInterestRate5;
	}

/**
 * Function modifyDailyInterestRate5
 * Notes for _dailyInterestRate : 10000 is one percent
 * The function takes in 1 variable, zero or a positive integer _dailyInterestRate. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * calls updateRecordsWithLatestInterestRates
 * updates dailyInterestRate5 as _dailyInterestRate
*/
	function modifyDailyInterestRate5(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate5  = _dailyInterestRate;
	}

/**
 * Function modifyDailyInterestRate5_1
 * Notes for _dailyInterestRate : 10000 is one percent
 * The function takes in 1 variable, zero or a positive integer _dailyInterestRate. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * calls updateRecordsWithLatestInterestRates
 * updates dailyInterestRate5_1 as _dailyInterestRate
*/
	function modifyDailyInterestRate5_1(uint256 _dailyInterestRate) public onlyOwner {
		updateRecordsWithLatestInterestRates();
		dailyInterestRate5_1  = _dailyInterestRate;
	}

/**
 * Function withdrawToken
 * The function takes in 1 variable, zero or a positive integer _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function withdrawToken(uint256 _amt) public onlyOwner {
		ERC20(0x9E1067De1af214F2d1354B83Ba5D02C34FB9eEeF).transfer(msg.sender, _amt);
	}
}