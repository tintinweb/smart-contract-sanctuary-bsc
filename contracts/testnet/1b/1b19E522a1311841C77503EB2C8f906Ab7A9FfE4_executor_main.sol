/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRyker {
    function getUserInitialDeposit(address addr) external view returns(uint256 _initialDeposit, uint256 _lastHatch,uint256 _userDefaultAutoTriggerCount );
    function executeAutoCompound(address _addr,uint256 _compoundPrc, uint256 _withdrawPrc) external;
    function chooseWinners() external;
}

contract executor_main {

    using SafeMath for uint256;
    using SafeMath for uint8;

    IRyker private ryker;
    bool private LOCKED;

    uint256 public maxAutoCompoundDays = 365; 
    uint256 public totalAutoCompoundAddresses;
    uint256 public averageGasFee = 0.001 ether;
    uint256 public currentIndex;
    uint256 public iterations = 20;
    uint256 public compoundInterval = 24 hours;
    
    address payable public executor;
    address public rykerContract;

    struct CompoundDetails {
        bool isAutoCompound;
        bool exists;
        uint256 depositedBNB;
        uint256 lastActionTime;
        uint256 numberOfAutoCompounds;
        uint256 currentCompoundCount;
    }

    mapping(address => AutoMineSettings) public autoMineSettingsMap;
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

    function withdrawAndDisableAutoCompound() external nonReentrant {
        address _addr = msg.sender;
        uint256 payout = autoCompoundMap[_addr].depositedBNB;

        // require(payout > 0, "User has nothing to withdraw.");

        AutoMineSettings storage autoMineSettings = autoMineSettingsMap[_addr];
        autoMineSettings.defCompoundPrc = 0;
        autoMineSettings.defWithdrawPrc = 0;
        autoMineSettings.compoundTimesBeforeSecondary = 0;
        autoMineSettings.secondaryCompoundPrc = 0;
        autoMineSettings.secondaryWithdrawPrc = 0;

        autoCompoundMap[_addr].isAutoCompound = false;
        autoCompoundMap[_addr].depositedBNB = 0;
        autoCompoundMap[_addr].currentCompoundCount = 0;
        autoCompoundMap[_addr].numberOfAutoCompounds = 0;

        if(getContractBalance() < payout) {
            payout = getContractBalance();
        }

        payable(address(_addr)).transfer(payout);
    }
    struct AutoMineSettings {
        uint256 defCompoundPrc;
        uint256 defWithdrawPrc;
        uint256 compoundTimesBeforeSecondary;
        uint256 secondaryCompoundPrc;
        uint256 secondaryWithdrawPrc;
   
    }

    function depositAndEnableAutoCompound(uint256 compoundTimesInDays, uint256 _defCompoundPrc, uint256 _defWithdrawPrc, uint256 _compoundTimesBeforeSecondary, uint256 _secondaryCompoundPrc, uint256 _secondaryWithdrawPrc) payable external nonReentrant{
        (uint256 deposits, uint256 lastHatch,) = ryker.getUserInitialDeposit(msg.sender);
        require(compoundTimesInDays > 0 && compoundTimesInDays <= maxAutoCompoundDays, "Value should be equal or greater than 1 day to enable auto-compound.");
        require(deposits > 0, "User does not meet the minimum deposit to enable auto-compound.");
        address _addr = msg.sender;
        uint256 validPrcChk = _defCompoundPrc +  _defWithdrawPrc;
        uint256 validPrcChk2 = _secondaryCompoundPrc +  _secondaryWithdrawPrc;
        
        require(_defCompoundPrc>20 && _secondaryCompoundPrc>20 &&
        validPrcChk == 100 && validPrcChk2 == 100, "invalide default percentages");

        if(autoCompoundMap[_addr].isAutoCompound == true) revert("User already has an existing auto-compound. This needs to be finished before doing another auto-compound cycle.");



        AutoMineSettings storage autoMineSettings = autoMineSettingsMap[_addr];
        autoMineSettings.defCompoundPrc = _defCompoundPrc;
        autoMineSettings.defWithdrawPrc = _defWithdrawPrc;
        autoMineSettings.compoundTimesBeforeSecondary = _compoundTimesBeforeSecondary;
        autoMineSettings.secondaryCompoundPrc = _secondaryCompoundPrc;
        autoMineSettings.secondaryWithdrawPrc = _secondaryWithdrawPrc;


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

    function execAutoCompoundAddresses() external onlyOwner {
        uint256 startIndex = currentIndex;
        execAutoCompound(nextAddressesForAutoCompound());
        uint256 endIndex = currentIndex;
        emit BatchExecuted(startIndex, endIndex);
    }

    function execChooseWinnersOnly() external onlyOwner {
           ryker.chooseWinners();
    }

    function execAutoCompound(address[] memory _addresses) public onlyOwner {
        require(iterations > 0, "Iteration should be greater than 0 to allow execution.");
        require(_addresses.length <= iterations, "Max iterations size reached.");        

        address[] memory executedAddresses = new address[](_addresses.length);
        uint256 executed = 0;

        for(uint256 i = 0; i < iterations && i < _addresses.length; i++){
            address _addr = _addresses[i];
            if( _addr != address(0)){

                AutoMineSettings storage aMsettings = autoMineSettingsMap[_addr];
                uint256 _compoundPrc;
                uint256 _withdrawPrc;
                uint256 currentComp = autoCompoundMap[_addr].currentCompoundCount;
                uint256 compoundTimesBeforeSecondary = aMsettings.compoundTimesBeforeSecondary;
                if (currentComp >= compoundTimesBeforeSecondary && compoundTimesBeforeSecondary > 0 &&
                    currentComp.mod(compoundTimesBeforeSecondary)==0){
                    _compoundPrc = aMsettings.secondaryCompoundPrc;
                    _withdrawPrc = aMsettings.secondaryWithdrawPrc;
                }else{
                    _compoundPrc = aMsettings.defCompoundPrc;
                    _withdrawPrc = aMsettings.defWithdrawPrc;
                }




                ryker.executeAutoCompound(_addr,_compoundPrc,_withdrawPrc);
                autoCompoundMap[_addr].currentCompoundCount += 1;
                autoCompoundMap[_addr].lastActionTime = getCurrentTime();
                autoCompoundMap[_addr].depositedBNB -= averageGasFee;
                executedAddresses[i] = _addr;
                executed++;

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
                
                (, uint256 lastHatch,) = ryker.getUserInitialDeposit(_addr);
                if(getCurrentTime().sub(lastHatch) >= compoundInterval){
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
                
                (, uint256 lastHatch,) = ryker.getUserInitialDeposit(_addr);
                if(getCurrentTime().sub(lastHatch) >= compoundInterval){
                    _addresses[arrayIndex] = _addr;

                   
                    arrayIndex++;
                }    
            }
        }
        return (_addresses);
    }

    function calculateGasFeeEstimate(uint256 _days) public view returns (uint256) {
        return _days.mul(averageGasFee);
    }

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

 
    function getAutoMineSettingsDetails(address _address) external view returns (uint256 _defCompoundPrc, uint256 _defWithdrawPrc, uint256 _compoundTimesBeforeSecondary, uint256 _secondaryCompoundPrc, uint256 _secondaryWithdrawPrc) {
        _defCompoundPrc = autoMineSettingsMap[_address].defCompoundPrc;
        _defWithdrawPrc = autoMineSettingsMap[_address].defWithdrawPrc;
        _compoundTimesBeforeSecondary = autoMineSettingsMap[_address].compoundTimesBeforeSecondary;
        _secondaryCompoundPrc = autoMineSettingsMap[_address].secondaryCompoundPrc;
        _secondaryWithdrawPrc = autoMineSettingsMap[_address].secondaryWithdrawPrc;
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

    function updateExecutor(address _value) public onlyOwner {
        executor = payable(_value);
    }
  
    function setRykerContractAddress(address _rykerContract) public onlyOwner {
        rykerContract = _rykerContract;
        ryker = IRyker(rykerContract);
    }

    // when testing is done, highlight "getCurTimeTest" ctrl+F in IDE and replace all to "getCurTimeTest" <-- this is the function to get the block.timestamp in the contract line:1133.
   
    bool private isTest = false;
    uint256 private currentTestTime;

    // when testing is done, highlight "getCurTimeTest" ctrl+F in IDE and replace all to "getCurTimeTest" <-- this is the function to get the block.timestamp in the contract line:1133.
    function getCurTimeTest() public view returns(uint256) {
        if(isTest){
            return block.timestamp.add(currentTestTime);
        }
        else{
            return block.timestamp;
        }
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