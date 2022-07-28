/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 *  CompanionContractsRegistryContract 
 *
 *  Global companion contracts registry.
 *
 *  RECOMMENDED GAS LIMIT 200000.
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


    bool public isRegistryValid = true;
    address public mainCompanionContract;
    address public mainBinarContract;
    address public ADMIN_ADDRESS = 0x8B6Fec49ccBaB306dC4159EEe33CA4109e52c484;
    uint public contractsCount = 0;

    modifier isAdmin() {
        require(msg.sender==ADMIN_ADDRESS, "Access denied.");
        _;
    }
	
	function getStatus(address addr) public view returns(string memory) {
	    CompanionContractStatus memory ct = contracts[addr];
	    if(ct.status==0) return "Not exists";
	    if(ct.status==1) return "White";
        if(ct.status==2) return "Gray";
	    if(ct.status==3) return "Black";
        if(ct.status==4) return "Removed";
        return "Unknown";
	}
	function getTypeReadable(address addr) public view returns(string memory) {
	    CompanionContractStatus memory ct = contracts[addr];
	    if(ct.typeCode==0) return "CWBNC";
	    if(ct.typeCode==1) return "Binar";
        if(ct.typeCode==2) return "Registry";
	    if(ct.typeCode==3) return "Crowdfunding";
        if(ct.typeCode==4) return "ACRC";
        return "Unknown";
	}
	function registerContract(address addr) private {
	    CompanionContractStatus memory ct = contracts[addr];
	    if(ct.status == 0){
	        CompanionContractStatus storage ct2 = contracts[addr];
	        ct2.status = 4;
	        ct2.addr = addr;
            unchecked{
	            ct2.index = contractsCount++;
            }
	        contractAddresses.push(addr);
	    }
	}
	function removeFunds() private {
	    if(msg.value > 0 && address(this).balance >= msg.value)
	        payable(msg.sender).transfer(msg.value);
	    if(address(this).balance > 0)
	        payable(ADMIN_ADDRESS).transfer(address(this).balance);
	}
	
    function setStatus(address addr, uint8 status) isAdmin external payable {
        registerContract(addr);
        if(status < 1)status = 4;
        CompanionContractStatus storage ct = contracts[addr];
        ct.status = status;
        removeFunds();
    }   
    function setTypeCode(address addr, uint8 typeCode) isAdmin external payable {
        registerContract(addr);
        CompanionContractStatus storage ct = contracts[addr];
        ct.typeCode = typeCode;
        removeFunds();
    }   
    function setEtcOptimalExRate(address addr, uint value) isAdmin external payable {
        registerContract(addr);
        CompanionContractStatus storage ct = contracts[addr];
        ct.etcOptimalExRate = value;
        removeFunds();
    }   
    function setRecomendedGasPrice(address addr, uint value) isAdmin external payable {
        registerContract(addr);
        CompanionContractStatus storage ct = contracts[addr];
        ct.recommendedGasPrice = value;
        removeFunds();
    }   
    function setMainCompanionContract(address addr) isAdmin external payable {
        registerContract(addr);
        CompanionContractStatus storage ct = contracts[addr];
        ct.typeCode = 0;
        ct.status = 1;
        mainCompanionContract = addr;
        removeFunds();
    }   
    function setMainBinarContract(address addr) isAdmin external payable {
        registerContract(addr);
        CompanionContractStatus storage ct = contracts[addr];
        ct.typeCode = 1;
        ct.status = 1;
        mainBinarContract = addr;
        removeFunds();
    }   
	
    function setFeeGasCorrectionWithd(address addr, uint value) isAdmin external payable {
        registerContract(addr);
        CompanionContractStatus storage ct = contracts[addr];
        ct.feeGasCorrectionWithd = value;
        removeFunds();
    }   
	
    function setFeeGasCorrectionDep(address addr, uint value) isAdmin external payable {
        registerContract(addr);
        CompanionContractStatus storage ct = contracts[addr];
        ct.feeGasCorrectionDep = value;
        removeFunds();
    }   
	
	
    function destroyRegistry() isAdmin external payable {
        isRegistryValid = false;
        removeFunds();
    }   
 	
}