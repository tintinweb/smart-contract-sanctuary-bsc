/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 *  CompanionBinar__0_03__Contract 
 *
 *  No bugs and backdoors! Your investments are safe!
 *
 *  5% from deposit goes to admin in binary structure.
 *  55% from deposit goes to parent in binary structure.
 *  20% from deposit goes to parents of parent in binary structure
 *  up to root of structure.
 *  20% from deposit goes to main contract.
 *
 *  FIRST COMPANION DEPOSIT IS 0.03 ETHER.
 *  DEPOSIT COST GROWTH EVERY BINARY LEVEL IS 0.03 ETHER.
 *  MAX HIPOTHETIC DEPOSIT COST APROXIMATELY 0.03 * 34 = 1.02 ETHER.
 * 
 *  NO WITHDRAWAL FEES! 
 *
 *  INSTRUCTIONS:
 *
 *  TO INVEST: Minimal binar activation cost is getBinarActivationCost 
 *             return value.
 *  TO WITHDRAW INTEREST: send 0 ETC to contract address.
 *
 *  RECOMMENDED GAS LIMIT 300000.
 */
 
contract CompanionWeeklyBasicNeedsContract  {
    
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

    mapping(uint => address) public binarySlots;
    mapping(address => Companion) public companions;

	uint public TIME_CONTRACT_START;
	uint public timeQuantStart;
	
    uint public currentBinarySlot;
    uint public currentBinaryLevel;
    uint public currentBinaryLevelSlot;
    uint public currentBinaryLevelWidth;

    uint public withdrawnInQuant;
    uint public balanceForQuant;
    uint public historyMaxBalance;

    function charityToContract()  external payable {}
    function getBinarLevel(address addr)  public view returns(uint) {}
    function isCompanionInBinar(address addr)  public view returns(bool){}
    function getParent(address addr)  public view returns(address){}
}

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

contract CompanionBinar__0_03__Contract {

    // max contract balance in ether for overflow protection in calculations only
    // 340 quintillion 282 quadrillion 366 trillion 920 billion 938 million 463 thousand 463
	uint public constant MAX_BALANCE = 340282366920938463463374607431768211456 wei; //(2^128) 
	
	uint public constant ONE_LEVEL_COST = 0.03 ether;

	uint public constant DIRECT_PARENT_PERCENT = 55;
	uint public constant ADMIN_PERCENT = 5;

    address public constant REGISTRY_CONTRACT = 0xc0A966Eb63648D0b6c419dA50488315eF00e2846;

	CompanionContractsRegistryContract private rt = CompanionContractsRegistryContract(REGISTRY_CONTRACT);

    mapping(address => uint) public withdrawSumAndFlag;
    
    modifier isWithdrawnValid() {
        unchecked{        
            (CompanionWeeklyBasicNeedsContract ct, address COMPANION_CONTRACT) = getCompanionContractAndAddress();
            if(COMPANION_CONTRACT.balance < 
                ct.historyMaxBalance() / 2)
            {
            (uint deposit, , uint withdrawn,) = ct.companions(msg.sender);
                require(deposit >= 
                        withdrawn / 2, 
                    "Not enought deposit in main contract, required reinvest.");
            }
        }
        _;
    }
	
	function getCompanionContract() private view returns (CompanionWeeklyBasicNeedsContract) {
		return CompanionWeeklyBasicNeedsContract(rt.mainCompanionContract());
	}
	function getCompanionContractAndAddress() private view returns (CompanionWeeklyBasicNeedsContract, address) {
	    address result = rt.mainCompanionContract();
		return (CompanionWeeklyBasicNeedsContract(result), result);
	}
	function getCompanionContractAddress() public view returns (address) {
		return rt.mainCompanionContract();
	}
    
    function isCompanionRich(address addr) private view returns (bool){
		CompanionWeeklyBasicNeedsContract ct = getCompanionContract();
        (uint deposit, uint withdTime, uint withdrawn,) = ct.companions(addr);
        uint time = block.timestamp;
        if(time < withdTime)time = withdTime;
        unchecked{
            return withdrawn / 2 > deposit && time - withdTime > 365 days;        
        }
    }
    
    
    function getWithdrawSum(address addr) public view returns(uint) {
        unchecked{
            return withdrawSumAndFlag[addr] / 2;
        }
    }
    function getBinarActivationFlag(address addr) public view returns(bool) {
        unchecked{
            return (withdrawSumAndFlag[addr] % 2) == 1;
        }
    }
    function getBinarLevel(address addr) public view returns(uint){
        return getCompanionContract().getBinarLevel(addr);
    }
    function getBinarActivationCost(address addr) public view returns(uint){
        require(isCompanionInBinar(addr), 
            "Companion not registered yet in binary structure");
        unchecked{
            return (getBinarLevel(addr) + 1) * ONE_LEVEL_COST;
        }
    }
    function isCompanionInBinar(address addr) public view returns(bool){
        return getCompanionContract().isCompanionInBinar(addr);
    }
    function setWithdrawSum(address addr, uint sum) private {
        unchecked{
            if(sum > MAX_BALANCE / 2)
                sum = MAX_BALANCE / 2;
            uint value = withdrawSumAndFlag[addr];
            withdrawSumAndFlag[addr] = sum * 2 + (value % 2);
        }
    }
    function setBinarActivationFlag(address addr, bool flag) private {
        unchecked{
            uint value = withdrawSumAndFlag[addr] / 2;
            withdrawSumAndFlag[addr] = (flag ? 1 : 0) + (value * 2);
        }

    }
    
    function doWithdrawn() isWithdrawnValid private {
        require(isCompanionInBinar(msg.sender), 
            "Companion not registered yet in binary structure");
        require(getBinarActivationFlag(msg.sender), 
            "Binary deposit not found");
        
        uint sum = getWithdrawSum(msg.sender);
        uint sum2 = sum;
        if(sum2 > address(this).balance)
            sum2 = address(this).balance;
        unchecked{
            setWithdrawSum(msg.sender, sum-sum2);
        }
        if(sum2 > 0)
            payable(msg.sender).transfer(sum2);
    }

    function makeDepositFor(address addr) private {
        require(isCompanionInBinar(addr), 
            "Companion not registered yet in binary structure");
        require(!getBinarActivationFlag(addr), 
            "Binary deposit already actived, payment not required");
        uint cost = getBinarActivationCost(addr);
        require(msg.value >= cost,
            "Not enough payment, must be at least getBinarActivationCost");
        setBinarActivationFlag(addr, true);
        cost = msg.value;
		
        if(cost > address(this).balance)
            cost = address(this).balance;
		
		(CompanionWeeklyBasicNeedsContract ct, address COMPANION_CONTRACT) = getCompanionContractAndAddress();
        address parent = ct.getParent(addr);

        if(parent == address(0))
        {
            ct.charityToContract{value:cost}();
            return;
        }

        unchecked{
            address current = parent;
            parent = ct.getParent(current);
            uint cost2 = cost * DIRECT_PARENT_PERCENT / 100;
            uint adminFee = cost * ADMIN_PERCENT / 100;
        

            if(parent == address(0))
            {
                cost2 += adminFee;
                cost-=cost2;
                setWithdrawSum(current, getWithdrawSum(current) + cost2);
                ct.charityToContract{value:cost}();
                return;
            }

            setWithdrawSum(current, getWithdrawSum(current) + cost2);
            cost2 += adminFee;
            cost-=cost2;
            
            uint cost3 = cost / 2;
            cost -= cost3;

            ct.charityToContract{value:cost3}();

            bool isSystemRegress = COMPANION_CONTRACT.balance < 
                ct.historyMaxBalance() / 2;
        
            current = parent;
            
            uint lastLevels = 0;
            
            while(parent != address(0)){
                ++lastLevels;
                parent = ct.getParent(parent);            
            }

            uint costPerLevel = cost / lastLevels;
            parent = current;                
            uint totalTax = 0;

            while(parent != address(0))
            {
                cost -= costPerLevel;
                address next = ct.getParent(parent);
                if(next == address(0))
                {
                    setWithdrawSum(parent, getWithdrawSum(parent) + adminFee + costPerLevel);
                    break;
                }
                if(isSystemRegress && !getBinarActivationFlag(parent) && isCompanionRich(parent))
                {
                    uint taxSum = getWithdrawSum(parent) + costPerLevel;
                    uint tax2 = taxSum;
                    if(taxSum > address(this).balance-totalTax)
                        taxSum = address(this).balance-totalTax;
                    setWithdrawSum(parent, tax2-taxSum);
                    totalTax+=taxSum;
                }
                else
                    setWithdrawSum(parent, getWithdrawSum(parent) + costPerLevel);
                parent = next;
            }

            if(totalTax > 0)
            {
                if(totalTax > address(this).balance)
                    totalTax = address(this).balance;
                ct.charityToContract{value:totalTax}();
            }

            if(cost > 0)
                setWithdrawSum(current, getWithdrawSum(current) + cost);
        }
    }

    function makeDeposit() private {
        makeDepositFor(msg.sender);
    }

    function makeDepositOrWithdrawn() private {
        if (msg.value > 0) {
            makeDeposit();
        } else {
            doWithdrawn();
        }
    }

    event ContractOverflow(address indexed msgSender, uint msgValue, uint balance);

    modifier checkOverflow() {
        if(msg.value > 0 && address(this).balance > MAX_BALANCE)
		{
			require(msg.value <= MAX_BALANCE, "Too large income payment"); 
			emit ContractOverflow(msg.sender, msg.value, address(this).balance);
			(CompanionWeeklyBasicNeedsContract ct, address COMPANION_CONTRACT) = getCompanionContractAndAddress();
			uint ctBalance = COMPANION_CONTRACT.balance;
            unchecked{
                uint overflowBalance = address(this).balance - MAX_BALANCE;
                if(ctBalance + overflowBalance > MAX_BALANCE)
                    payable(msg.sender).transfer(overflowBalance);
                else
                    ct.charityToContract{value:overflowBalance}();
            }
		}    
        _;    
    }

    function depositToAddress(address addr) checkOverflow external payable
    {
        makeDepositFor(addr);
    }

    
    receive() checkOverflow external payable 
    {
        makeDepositOrWithdrawn();
    }    
    
}