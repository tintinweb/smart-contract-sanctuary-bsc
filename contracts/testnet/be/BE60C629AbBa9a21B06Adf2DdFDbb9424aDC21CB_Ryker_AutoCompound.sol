/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRyker {
    function getUserInitialDeposit(address addr) external view returns(uint256 _initialDeposit, uint256 _lastHatch);
    function executeAutoCompound(address _addr) external;
    function chooseWinners() external;
}

contract Ryker_AutoCompound {

    using SafeMath for uint256;
    using SafeMath for uint8;

    IRyker private ryker;
    bool private LOCKED;

    uint256 public maxAutoCompoundDays = 365; 
    uint256 public totalAutoCompoundAddresses;
    uint256 public averageGasFee = 0.0015 ether; //average gas for compounding.
    uint256 public currentIndex;
    uint256 public iterations = 10;
    uint256 public compoundInterval = 1 days;
    
    address payable public autoCompoundExecutor;
    address public rykerContract;
    bool private exectCompoundV2Enabled;

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

    modifier onlyOwner {
        require(msg.sender == autoCompoundExecutor);
        _;
    }

    event BatchExecuted(uint256 startIndex, uint256 endIndex);
    event AutoCompoundExecuted(uint256 numberOfWallets, address[] _addresses);

    constructor(address payable _autoCompoundExecutor) {
		require(!isContract(_autoCompoundExecutor));
        autoCompoundExecutor = _autoCompoundExecutor;
    }

    modifier nonReentrant {
        require(!LOCKED, "No re-entrancy");
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
        require(deposits > 10 ether, "User is not invested in Ryker BUSD.");
        autoCompoundMap[msg.sender].depositedBNB += msg.value;
    }

    // withdraw BNB from contract. the user is allowed to take his bnb out when auto compound is disabled.
    function withdrawBNB() external nonReentrant {
        address _addr = msg.sender;
        uint256 payout = autoCompoundMap[_addr].depositedBNB;

        require(payout > 0, "User has nothing to withdraw.");

        //if user withdraws BNB, set everything to 0.
        autoCompoundMap[_addr].isAutoCompound = false;
        autoCompoundMap[_addr].depositedBNB = 0;
        autoCompoundMap[_addr].currentCompoundCount = 0;
        autoCompoundMap[_addr].numberOfAutoCompounds = 0;
        payable(address(_addr)).transfer(payout);
    }

    // enable the AutoCompound for x days
    function enableAutoCompound(bool value, uint256 compoundTimesInDays) external {
        (uint256 deposits, uint256 lastHatch) = ryker.getUserInitialDeposit(msg.sender);
        require(compoundTimesInDays > 0 && compoundTimesInDays <= maxAutoCompoundDays, "Value should be equal or greater than 1 day to enable auto-compound.");
        require(deposits >= 10 ether, "User does not meet the minimum deposit to enable auto-compound.");

        address _addr = msg.sender;

        autoCompoundMap[_addr].isAutoCompound = value;
        autoCompoundMap[_addr].numberOfAutoCompounds = compoundTimesInDays;
        autoCompoundMap[_addr].lastActionTime = lastHatch;

        if(autoCompoundMap[_addr].exists == false){ // new user
            autoCompoundIndexes[totalAutoCompoundAddresses] = _addr;
            autoCompoundMap[_addr].exists = true;
            totalAutoCompoundAddresses++;
        }
    }

    // execute this function x number of times per day.
    function execAutoCompoundBatch() external onlyOwner {
        uint256 startIndex = currentIndex;
        
        if(!exectCompoundV2Enabled){
            execAutoCompound(nextBatchForAutoCompound());
        }
        else{
            execAutoCompound(nextBatchForAutoCompoundOption2());
        }
        
        uint256 endIndex = currentIndex;
        emit BatchExecuted(startIndex, endIndex);
    }

    //trigger function
    function execAutoCompound(address[] memory _addresses) internal {
        require(msg.sender == autoCompoundExecutor, "Can only be executed by the autoCompoundExecutor." );
        require(iterations > 0, "Iteration should be greater than 0 to allow execution.");
        require(_addresses.length <= iterations, "Max batch size reached.");        

        address[] memory _executedAddresses = new address[](_addresses.length);
        uint256 executed = 0;

        for(uint256 i = 0; i < iterations && i < _addresses.length; i++){
            address _addr = _addresses[i];
            //call compound function in ryker busd contract. validations are already done before this point.
            ryker.executeAutoCompound(_addr);
            autoCompoundMap[_addr].currentCompoundCount += 1;
            autoCompoundMap[_addr].lastActionTime = getCurTime();
            autoCompoundMap[_addr].depositedBNB -= averageGasFee;
            _executedAddresses[i] = _addr;
            executed++;       
        }

        //contract will run, chooseWinner() function every after execution of the loop.
        ryker.chooseWinners();

        // the executor wallet is be sent amount of gas fee used after every transaction.
        payable(autoCompoundExecutor).transfer(executed.mul(averageGasFee));
        emit AutoCompoundExecuted(executed, _executedAddresses);
    }

    // next addresses for execution
    function nextBatchForAutoCompound() internal returns (address[] memory _addresses) {
        uint256 currIndex = currentIndex; 
        uint256 arrayIndex = 0;

        _addresses = new address[](iterations);  

        for(uint256 i = 0; i < iterations; i++){
            if(currIndex >= totalAutoCompoundAddresses.sub(1)){
                currIndex = 0;
            }

            address _addr = autoCompoundIndexes[currIndex];

            if(    _addr != address(0)     
                && autoCompoundMap[_addr].isAutoCompound == true 
                && autoCompoundMap[_addr].depositedBNB >= averageGasFee 
                && autoCompoundMap[_addr].currentCompoundCount < autoCompoundMap[_addr].numberOfAutoCompounds) {
                
                (, uint256 lastHatch) = ryker.getUserInitialDeposit(_addr);
                if(getCurTime().sub(lastHatch) >= compoundInterval){
                    _addresses[arrayIndex] = _addr;
                    arrayIndex++;
                }    
            }
            currIndex++;
        }
        currentIndex = currIndex;
        return _addresses;
    }

    // next addresses for execution v2
    function nextBatchForAutoCompoundOption2() internal returns (address[] memory _addresses) {
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
                if(getCurTime().sub(lastHatch) >= compoundInterval){
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

            if(_addr != address(0) && autoCompoundMap[_addr].lastActionTime.add(compoundInterval) <= getCurTime() && 
                autoCompoundMap[_addr].isAutoCompound == true && 
                autoCompoundMap[_addr].depositedBNB >= averageGasFee)
                 { 
                _addresses[arrayIndex] = _addr;
                arrayIndex++;
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
        autoCompoundExecutor = payable(_value);
    }
  
    function setRykerContractAddress(address _rykerContract) public onlyOwner {
        rykerContract = _rykerContract;
    }

    function changeCompooundOption(bool value) external onlyOwner {
        exectCompoundV2Enabled = value;
    }
            //remove after testing.
    uint256 private TESTTIME;
    bool private isTEST = false;

    function getCurTime() private view returns(uint256){
        uint256 testtimer;
        if(isTEST){
            testtimer = getCurTime().add(TESTTIME);
            return testtimer;
        }else{
            return block.timestamp;
        }
     
    }
    function setCurTimeForTesting(uint256 timeToAdd) external{
        isTEST = true;
        TESTTIME = timeToAdd;
    }
    

}

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