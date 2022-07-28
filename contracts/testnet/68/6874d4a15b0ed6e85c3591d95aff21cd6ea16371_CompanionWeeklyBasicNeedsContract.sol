/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 *  CompanionWeeklyBasicNeedsContract 
 *
 *  No bugs and backdoors! Your investments are safe!
 *
 *  NO DEPOSIT FEES! All the money go to contract!
 *
 *  NO WITHDRAWAL FEES! 
 *
 *  HAS COMPENSATION ALGORITHM FOR TRANSACTION FEE IF WITHDRAWAL.
 * 
 *  INSTRUCTIONS:
 *
 *  TO INVEST: send ETC to contract address.
 *  TO WITHDRAW INTEREST: send 0 ETC to contract address.
 * 
 *  Minimal investment is more 0 (Zero) ether, else 
 *  only withdrawal will performed.
 *
 *  RECOMMENDED GAS LIMIT 300000.
 */
 
contract CompanionContractsRegistryContract {
    struct CompanionContractStatus {
        
        uint8 typeCode;
        
		uint8 status;
		
		address addr;
		
		uint index;
		
		uint etcOptimalExRate;
		
		uint recommendedGasPrice;
		
		uint feeGasCorrectionDep;
		uint feeGasCorrectionWithd;
	}
    address[] public contractAddresses;
    mapping(address => CompanionContractStatus) public contracts;


    bool public isRegistryValid;
    address public mainCompanionContract;
    address public mainBinarContract;
    address public ADMIN_ADDRESS;
    uint public contractsCount;
}
 
 
contract CompanionWeeklyBasicNeedsContract {
    
   	struct Companion {
        // containing information about deposit
		// required deposit > withdrawn / 2 at every time quant 
		uint deposit;
		
        // containing information about the time of withdrawn
		uint withdTime;
		
        // containing information on interest paid
		uint withdrawn;
		
		// parent in binary matrix of Companion's
		address parent;
	}

    address[] public binarySlots;
    mapping(address => Companion) public companions;

	uint public constant TIME_QUANT = 7 days; 
	uint public constant TIME_QUANT_SPACER = 4 hours; 
	uint public TIME_CONTRACT_START = block.timestamp;
	uint public timeQuantStart = 1658509200;
	
    uint public constant MAX_BINARY_LEVEL_COUNT = 34;
    uint public currentBinarySlot = 0;
    uint public currentBinaryLevel = 0;
    uint public currentBinaryLevelSlot = 0;
    uint public currentBinaryLevelWidth = 1;
    
    uint public withdrawnInQuant = 0;
    uint public balanceForQuant = 0;
    uint private startGas = 0;
    uint public amountOfCharity = 0;
    uint public historyMaxBalance = 0;
        
    // max contract balance in ether for overflow protection in calculations only
    // 340 quintillion 282 quadrillion 366 trillion 920 billion 938 million 463 thousand 463
	uint public constant MAX_BALANCE = 340282366920938463463374607431768211456 wei; //(2^128) 
	uint public constant feeGasCorrectionDep = 21717;
	uint public feeGasCorrectionDepExternal = 0;
	uint public constant feeGasCorrectionWithd = 50554;
	uint public feeGasCorrectionWithdExternal = 0;
	address public constant REGISTRY_CONTRACT = 0xc0A966Eb63648D0b6c419dA50488315eF00e2846;
	CompanionContractsRegistryContract private rt = CompanionContractsRegistryContract(REGISTRY_CONTRACT);
	

    modifier isUserExists() {
        require(companions[msg.sender].deposit > 0, 
        "Deposit not found");
        _;
    }
    modifier isTimeWithdrawn() {
        require(timeQuantStart > companions[msg.sender].withdTime, 
        "Too fast payout request");
        _;
    }
    modifier isWithdrawnValid() {
        require(companions[msg.sender].deposit >= companions[msg.sender].withdrawn / 2, 
        "Not enought deposit, required reinvest");
        _;
    }
	function updateExternalFee() external payable {
	    updateExternalFeePrivate();
	}    
	function updateExternalFeePrivate() private {
	    (, , , , , , uint feeDep, uint feeWithd) = rt.contracts(address(this));
		feeGasCorrectionDepExternal = feeDep + 1;
		feeGasCorrectionWithdExternal = feeWithd + 1;
	}
	function getFeeGasCorrectionDep() private returns(uint) {
		if(feeGasCorrectionDepExternal==0)
			updateExternalFeePrivate();
		return feeGasCorrectionDep + feeGasCorrectionDepExternal - 1;
	}
	function getFeeGasCorrectionWithd() private returns(uint) {
		if(feeGasCorrectionWithdExternal==0)
			updateExternalFeePrivate();
		return feeGasCorrectionWithd + feeGasCorrectionWithdExternal - 1;
	}
    function isCompanionInBinar(address addr)  public view returns(bool){
        return companions[addr].deposit > 0;
    }
    function getParent(address addr)  public view returns(address){
        return companions[addr].parent;
    }
    function getBinarLevel(address addr)  public view returns(uint){
        uint level = 0;
        address scan = addr;
        address parent = companions[scan].parent;
        while(parent != address(0)){
            ++level;
            scan = parent;
            parent = companions[scan].parent;
        }
        return level;
    }
    
    function getCorrectTimeQuant() public view returns(uint) {
        uint time = block.timestamp;
        if(time < timeQuantStart)
            time = timeQuantStart;
        time = (time - timeQuantStart) / TIME_QUANT;
        return timeQuantStart + time * TIME_QUANT;
    }
    function updateTimeQuant() private {
        uint newQuant = getCorrectTimeQuant();
        if(newQuant == timeQuantStart && balanceForQuant > 0) return;
        timeQuantStart = newQuant;
        balanceForQuant = address(this).balance / 2;
        withdrawnInQuant = 0;
    }
    function getTimeToWithdrawn(address addr, uint personalRating) public view returns(uint)
    {
        uint start = getCorrectTimeQuant();
        uint dest = personalRating * 1 days / 100;
        if(dest > TIME_QUANT - TIME_QUANT_SPACER)
            dest = TIME_QUANT - TIME_QUANT_SPACER;
        dest += start;
        if(companions[addr].withdTime >= start)
            dest += TIME_QUANT;
        uint time = block.timestamp;
        if(dest <= time) return 0;
        return (dest - time) * 100 / 1 days;
    }
    function getPaymentRequired(address addr) public view returns(uint){
        Companion memory cmp = companions[addr];
        if(cmp.deposit >= cmp.withdrawn / 2)
            return 0;
        return cmp.withdrawn / 2 - cmp.deposit;
    }
    function getWithdrawPersonal(address addr, uint personalRating) public view returns(uint){
		uint time = getTimeToWithdrawn(addr, personalRating);
		if(time < 100) return getWithdrawAmount();
		return 0;
	}
	
    function getWithdrawAmount() public view returns(uint){
        uint start = getCorrectTimeQuant();
        uint localWithd = withdrawnInQuant;
        uint localBalance = balanceForQuant;
        if(start != timeQuantStart)
        {
            localWithd = 0;
            localBalance = address(this).balance / 2;
        }
        uint time = block.timestamp;
        if(time < start) time = start;
        uint amount = localBalance * (time - start) / TIME_QUANT;
        if(amount > localWithd)
            amount -= localWithd;
        else
            return 0;
        if(amount > address(this).balance)
            amount = address(this).balance;
        return amount;
    }
    function doWithdrawn() isUserExists isTimeWithdrawn isWithdrawnValid private {

		updateMaxBalance();

        uint time = block.timestamp;
        if(time < timeQuantStart) time = timeQuantStart;
        
        Companion storage cmp = companions[msg.sender];
        cmp.withdTime = time;
        
        uint amount = balanceForQuant * (time - timeQuantStart) / TIME_QUANT;
        if(amount > address(this).balance)
            amount = address(this).balance;
        if(amount > withdrawnInQuant)
            amount -= withdrawnInQuant;
        else
            amount = 0;
		
        if(amount > 0)
        {
            payable(msg.sender).transfer(amount);
            withdrawnInQuant += amount;
			cmp.withdrawn += amount;
        }
        
        uint gasUsed = (startGas - gasleft() + getFeeGasCorrectionWithd()) * tx.gasprice;    
        if(address(this).balance < gasUsed)
            gasUsed = address(this).balance;
        if(gasUsed > 0)
        {
            withdrawnInQuant += gasUsed;
            payable(msg.sender).transfer(gasUsed);
        }
        
    }
    function registerBinarySlot(address addr) private {
        if(currentBinarySlot == 0){
            binarySlots.push(addr);
            currentBinaryLevelSlot = 1;
            currentBinaryLevelWidth = 2;
            currentBinaryLevel = 1;
            currentBinarySlot = 1;
            return;
        }
        Companion storage cmp = companions[addr];
        uint parentLevelSlot = (currentBinaryLevelSlot + 1) / 2 - 1;
        uint parentCompanionIndex = (currentBinarySlot - currentBinaryLevelSlot) / 2;
        address parentCompanionAddress = binarySlots[parentLevelSlot + parentCompanionIndex];
        cmp.parent = parentCompanionAddress;
        
        binarySlots.push(addr);
        currentBinarySlot++;
        if(currentBinarySlot - currentBinaryLevelSlot == currentBinaryLevelWidth)
        {
            currentBinaryLevelSlot = currentBinarySlot;
            currentBinaryLevelWidth *= 2;
            currentBinaryLevel++;
        }
    }
    function updateMaxBalance() private {
        if(historyMaxBalance < address(this).balance)
            historyMaxBalance = address(this).balance;
    }
    
    function makeDeposit(address addr) private {
        
        Companion storage cmp = companions[addr];
        if(cmp.deposit == 0)
            registerBinarySlot(addr);
        
        cmp.deposit += msg.value;
        
        updateMaxBalance();
    }
    function makeDeposit() private {
        Companion storage cmp = companions[msg.sender];
        if(cmp.deposit == 0)
            registerBinarySlot(msg.sender);
        
        cmp.deposit += msg.value;

        updateMaxBalance();

        uint gasUsed = (startGas - gasleft() + getFeeGasCorrectionDep()) * tx.gasprice;    
        cmp.deposit += gasUsed;
    }
    function makeDepositOrWithdrawn() private {
        if (msg.value > 0) {
            require(companions[msg.sender].deposit > 0 || // Existing companions allowed
                    currentBinarySlot >= 512 || // After 512 companions allowed free registration
                    msg.sender == rt.ADMIN_ADDRESS(), // Admin allowed by default
                    "Deposit not found");
            updateTimeQuant();
            makeDeposit();
        } else {
            updateTimeQuant();
            doWithdrawn();
        }
    }

    function charityToContract()  external payable {
        require(        
            address(this).balance <= MAX_BALANCE, 
            "Contract balance overflow");
	    amountOfCharity += msg.value;
		updateMaxBalance();
    }   
    
    
    function depositToAddress(address addr) isUserExists external payable {
        require(        
            address(this).balance <= MAX_BALANCE, 
            "Contract balance overflow");
        require(        
            msg.value > 0, 
            "Withdrawal not allowed");
        updateTimeQuant();
        makeDeposit(addr);
    }


    receive() external payable {
        startGas = gasleft();    
        require(        
            msg.value == 0 ||
            address(this).balance <= MAX_BALANCE, 
            "Contract balance overflow");
        makeDepositOrWithdrawn();
    }    

}