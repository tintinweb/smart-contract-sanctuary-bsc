/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRyker {
    function getUserInitialDeposit(address addr) external view returns(uint256 _initialDeposit, uint256 _lastHatch);
    function executeAutoCompound(address _addr) external;
    function chooseWinners() external;
}

contract executor_test {

    using SafeMath for uint256;
    using SafeMath for uint8;

    IRyker private ryker;
    bool private LOCKED;

    uint256 public maxAutoCompoundDays = 365; 
    uint256 public totalAutoCompoundAddresses;
    uint256 public averageGasFee = 0.001 ether; //average gas for compounding.
    uint256 public currentIndex;
    uint256 public iterations = 10;
    uint256 public compoundInterval = 24 hours;
    
    address payable public executor;
    address public rykerContract;
    bool private execCompoundV2Enabled;

    struct CompoundDetails {
        bool isAutoCompound;
        bool exists;
        uint256 depositedBNB;
        uint256 lastActionTime;
        uint256 numberOfAutoCompounds;
        uint256 currentCompoundCount;
    }

    mapping(address => CompoundDetails) public autoCompoundMap;
    mapping(uint256 => address) public autoCompoundIndexes;

    event BatchExecuted(uint256 startIndex, uint256 endIndex);
    event AutoCompoundExecuted(uint256 numberOfWallets, address[] _addresses);

    constructor(address payable _executor) {
		require(!isContract(_executor));
        executor = _executor;
    }

    modifier onlyOwner {
        require(msg.sender == executor);
        _;
    }

    modifier nonReentrant {
        require(!LOCKED, "No re-entrancy.");
        LOCKED = true;
        _;
        LOCKED = false;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // deposit BNB in contract. this bnb will be used to auto compound, based on the set average gas fee.
    function depositBNB() payable external nonReentrant {
        (uint256 deposits, ) = ryker.getUserInitialDeposit(msg.sender);
        require(deposits > 0, "User is not invested in Ryker BUSD.");
        autoCompoundMap[msg.sender].depositedBNB += msg.value;
    }

    // withdraw BNB from contract. the user is allowed to take his bnb out when auto compound is disabled.
   function withdrawAndDisableAutoCompound() external nonReentrant {
        address _addr = msg.sender;
        uint256 payout = autoCompoundMap[_addr].depositedBNB;

        require(payout > 0, "User has nothing to withdraw.");

        autoCompoundMap[_addr].isAutoCompound = false;
        autoCompoundMap[_addr].depositedBNB = 0;
        autoCompoundMap[_addr].currentCompoundCount = 0;
        autoCompoundMap[_addr].numberOfAutoCompounds = 0;

        if(getContractBalance() < payout) {
            payout = getContractBalance();
        }

        payable(address(_addr)).transfer(payout);
    }

    function depositAndEnableAutoCompound(uint256 compoundTimesInDays) payable external nonReentrant{
        (uint256 deposits, uint256 lastHatch) = ryker.getUserInitialDeposit(msg.sender);
        require(compoundTimesInDays > 0 && compoundTimesInDays <= maxAutoCompoundDays, "Value should be equal or greater than 1 day to enable auto-compound.");
        require(deposits > 0, "User does not meet the minimum deposit to enable auto-compound.");
        address _addr = msg.sender;

        //isAutoCompound will only be set to false if 1. cycle is done, 2. if disable and withdraw has been triggered.
        if(autoCompoundMap[_addr].isAutoCompound == true) revert("User already has an existing auto-compound. This needs to be finished before doing another auto-compound cycle.");

        autoCompoundMap[_addr].depositedBNB += msg.value;
        autoCompoundMap[_addr].isAutoCompound = true;
        autoCompoundMap[_addr].numberOfAutoCompounds = compoundTimesInDays;
        autoCompoundMap[_addr].lastActionTime = lastHatch;
        autoCompoundMap[_addr].currentCompoundCount = 0;

        if(!autoCompoundMap[_addr].exists){
            autoCompoundIndexes[totalAutoCompoundAddresses] = _addr;
            autoCompoundMap[_addr].exists = true;
            totalAutoCompoundAddresses++;
        }
    }

    // execute this function x number of times per day.
    function execAutoCompoundAddresses() external onlyOwner {
        uint256 startIndex = currentIndex;
        
        if(!execCompoundV2Enabled){
            execAutoCompound(nextAddressesForAutoCompound());
        }
        else{
            execAutoCompound(nextAddressesForAutoCompoundV2());
        }
        
        uint256 endIndex = currentIndex;
        emit BatchExecuted(startIndex, endIndex);
    }

    function execChooseWinnersOnly() external onlyOwner {
           ryker.chooseWinners();
    }

    //trigger function
    function execAutoCompound(address[] memory _addresses) public onlyOwner {
        require(iterations > 0, "Iteration should be greater than 0 to allow execution.");
        require(_addresses.length <= iterations, "Max iterations size reached.");        

        address[] memory executedAddresses = new address[](_addresses.length);
        uint256 executed = 0;

        for(uint256 i = 0; i < iterations && i < _addresses.length; i++){
            address _addr = _addresses[i];
            if( _addr != address(0)){
                //call compound function in ryker busd contract. validations are already done before this point.
                ryker.executeAutoCompound(_addr);
                autoCompoundMap[_addr].currentCompoundCount += 1;
                autoCompoundMap[_addr].lastActionTime = getCurTimeTest();
                autoCompoundMap[_addr].depositedBNB -= averageGasFee;
                executedAddresses[i] = _addr;
                executed++;

                //check if current vs max is equal if yes, disable auto compound but retain the values to be shown in the UI.
                if(autoCompoundMap[_addr].currentCompoundCount == autoCompoundMap[_addr].numberOfAutoCompounds) autoCompoundMap[_addr].isAutoCompound = false;
            }       
        }
        uint256 gasFeeRefund = executed.mul(averageGasFee);

        if(getContractBalance() < gasFeeRefund) {
            gasFeeRefund = getContractBalance();
        }

        payable(executor).transfer(gasFeeRefund);
        emit AutoCompoundExecuted(executed, executedAddresses);
    }

    // next addresses for execution
    function nextAddressesForAutoCompound() internal returns (address[] memory _addresses) {
        uint256 currIndex = currentIndex; 
        uint256 startingIndex = currIndex;
        uint256 arrayIndex = 0;
        bool isBackFromStart = false;
        _addresses = new address[](iterations);  

        for(uint256 i = 0; i < iterations; i++){
            if(currIndex >= totalAutoCompoundAddresses){
                currIndex = 0;
                isBackFromStart = true;
            }

            address _addr = autoCompoundIndexes[currIndex];

            if(    _addr != address(0)     
                && autoCompoundMap[_addr].isAutoCompound == true 
                && autoCompoundMap[_addr].depositedBNB >= averageGasFee 
                && autoCompoundMap[_addr].currentCompoundCount < autoCompoundMap[_addr].numberOfAutoCompounds) {
                
                (, uint256 lastHatch) = ryker.getUserInitialDeposit(_addr);
                if(getCurTimeTest().sub(lastHatch) >= compoundInterval){
                    _addresses[arrayIndex] = _addr;
                    arrayIndex++;
                }    
            }
            currIndex++;
            if(isBackFromStart && currIndex >= startingIndex) break;
        }
        currentIndex = currIndex;
        return _addresses;
    }

    // next addresses for execution v2
    function nextAddressesForAutoCompoundV2() internal returns (address[] memory _addresses) {
        uint256 currIndex = currentIndex; 
        uint256 startingIndex = currIndex;
        bool isBackFromStart = false;
        uint256 arrayIndex = 0;

        _addresses = new address[](iterations);  
        while(arrayIndex < iterations){
            if(currIndex >= totalAutoCompoundAddresses.sub(1)){
                currIndex = 0;
                isBackFromStart = true;
            }

            address _addr = autoCompoundIndexes[currIndex];
            
            if(    _addr != address(0)     
                && autoCompoundMap[_addr].isAutoCompound == true 
                && autoCompoundMap[_addr].depositedBNB >= averageGasFee 
                && autoCompoundMap[_addr].currentCompoundCount < autoCompoundMap[_addr].numberOfAutoCompounds) {
                

                (, uint256 lastHatch) = ryker.getUserInitialDeposit(_addr);
                if(getCurTimeTest().sub(lastHatch) >= compoundInterval){
                    _addresses[arrayIndex] = _addr;
                    arrayIndex++;
                } 
            }
            currIndex++;
            if(isBackFromStart && currIndex >= startingIndex) break;
        }
        currentIndex = currIndex;
        return _addresses;
    }

    function getAddresses(uint256 startIndex, uint256 limit) public view returns (address[] memory _addresses) {
        _addresses = new address[](limit);

        uint256 arrayIndex = 0;
        for(uint256 i = 0; i < limit; i++){
            address _addr = autoCompoundIndexes[startIndex.add(i)];

                if(    _addr != address(0)     
                && autoCompoundMap[_addr].isAutoCompound == true 
                && autoCompoundMap[_addr].depositedBNB >= averageGasFee 
                && autoCompoundMap[_addr].currentCompoundCount < autoCompoundMap[_addr].numberOfAutoCompounds) {
                
                (, uint256 lastHatch) = ryker.getUserInitialDeposit(_addr);
                if(getCurTimeTest().sub(lastHatch) >= compoundInterval){
                    _addresses[arrayIndex] = _addr;
                    arrayIndex++;
                }    
            }
        }
        return _addresses;
    }

    function calculateGasFeeEstimate(uint256 _days) public view returns (uint256) {
        return _days.mul(averageGasFee);
    }

    //check if bnb deposited is still enough to execute auto-compound. If not, UI will show the amount that needs to be added.
    function isCompoundExecutionPossible(address _addr, uint256 _days) public view returns (bool isExecute) {
        if(autoCompoundMap[_addr].isAutoCompound == true && autoCompoundMap[_addr].depositedBNB >= averageGasFee.mul(_days)){
            isExecute = true;
        }
    }
    
    function getAutoCompoundDetails(address _address) external view returns (bool _isAutoCompound, bool _exists, uint256 _depositedBNB,
    uint256 _lastActionTime, uint256 _numberOfAutoCompounds, uint256 _currentCompoundCount) {
        _isAutoCompound = autoCompoundMap[_address].isAutoCompound;
        _exists = autoCompoundMap[_address].exists;
        _depositedBNB = autoCompoundMap[_address].depositedBNB;
        _lastActionTime = autoCompoundMap[_address].lastActionTime;
        _numberOfAutoCompounds = autoCompoundMap[_address].numberOfAutoCompounds;
        _currentCompoundCount = autoCompoundMap[_address].currentCompoundCount;  
    }

    function getCurrentTime() public view returns(uint256){
        return block.timestamp;
    }

    function getContractBalance() public view returns(uint256) {
       return address(this).balance;
    }

    function updateAvgGasFees(uint256 _value) public onlyOwner {
        require(_value <= 0.002 ether, "Required fee not met");
        averageGasFee = _value;
    }

    function updateBatchSize(uint256 _value) public onlyOwner {
        iterations = _value;
    }

    function resetExecutionIndex() public onlyOwner {
        currentIndex = 0;
    }

    function updateAutoCompoundExecutor(address _value) public onlyOwner {
        executor = payable(_value);
    }
  
    function setRykerContractAddress(address _rykerContract) public onlyOwner {
        rykerContract = _rykerContract;
        ryker = IRyker(rykerContract);
    }

    function changeCompooundOption(bool value) external onlyOwner {
        execCompoundV2Enabled = value;
    }
    
//////////////////////////////////////////////////////////////////REMOVE AFTER TESTING////////////////////////////////////////////////////////////////////////
    uint256 private currentTestTime;
    bool private isTest = false;

    // when testing is done, highlight "getCurTimeTest" ctrl+F in IDE and replace all to "getCurrentTime" <-- this is the function to get the block.timestamp in the contract line:1133.
    function getCurTimeTest() public view returns(uint256) {
        if(isTest){
            return block.timestamp.add(currentTestTime);
        }
        else{
            return block.timestamp;
        }
    }

    function setCurTimeForTEST(uint256 timeToAdd) external {
        isTest = true;
        currentTestTime = currentTestTime.add(timeToAdd);
    }

    function enableAutoCompoundWithDepositTEST(bool value, uint256 compoundTimesInDays,address _addr) external {
        (, uint256 lastHatch) = ryker.getUserInitialDeposit(msg.sender);
        autoCompoundMap[_addr].isAutoCompound = value;
        autoCompoundMap[_addr].numberOfAutoCompounds = compoundTimesInDays;
        autoCompoundMap[_addr].lastActionTime = lastHatch;

        if(autoCompoundMap[_addr].exists == false){ // new user
            autoCompoundIndexes[totalAutoCompoundAddresses] = _addr;
            autoCompoundMap[_addr].exists = true;
            
            totalAutoCompoundAddresses++;
        }
        autoCompoundMap[_addr].depositedBNB += compoundTimesInDays* averageGasFee;
    }   
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;

    uint256 c = a * b;
    assert(c / a == b);
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}