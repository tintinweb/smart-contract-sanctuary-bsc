/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

/* This contracts are offered for learning purposes only, to illustrate certain aspects of development regarding web3,
   they are not audited of course and not for use in any production environment.
   They are not aiming to illustrate true randomness or reentrancy control, as a general rule they use transfer() instead of call() to avoid reentrancy,
   which of course only works is the recipient is not intended to be a contract that executes complex logic on transfer.
*/


// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;


interface IOffering {
    function viewOffering(bytes32 _offeringId) external view returns (uint,uint);
    function viewinitialAmount(bytes32 _offering_Id) external view returns (uint);
    function dailyPayoutAmount(bytes32 _offering_Id) external view returns (uint);
}

    contract oilLandContract{
    // address offeringAddr; 
    // function setOfferingAddr(address _offeringAddress) public payable {
    // offeringAddr = _offeringAddress;
    // }
    // function getOffering(address _offeringContractAdd,bytes32 offering_Id) external view returns (uint) {
    // return (IOffering(_offeringContractAdd).viewdailyPayoutAmount(offering_Id));
    // } 

    // function viewinitialAmount(address _offeringContractAdd,bytes32 offering_Id) external view returns (uint) {
    // return IOffering(_offeringContractAdd).viewinitialAmount(offering_Id);
    // }

    function viewdaily(address _offeringContractAdd,bytes32 offering_Id) external view returns (uint) {
    return (IOffering(_offeringContractAdd).viewinitialAmount(offering_Id));
    }

    function viewinitial(address _offeringContractAdd,bytes32 offering_Id) external view returns (uint) {
    return (IOffering(_offeringContractAdd).dailyPayoutAmount(offering_Id));
    }

    event contractStarted(bytes32 indexed contractId, address indexed leasee, uint indexed startDate, uint endDate,uint dailyPayout);
    event contractClosed(bytes32 indexed contractId, address indexed buyer);
    event BalanceWithdrawn (address indexed beneficiary, uint amount);
    event OperatorChanged (address previousOperator, address newOperator);
    event addNewLease(address leaser);
    address operator;
    uint contractNonce;
    struct leaseContract {
        address leasee;
        bytes32  offeringId;
        uint startDate;
        uint endDate;
        uint dailyPayout;
        bool closed;
    }

    

    mapping (bytes32 => leaseContract) contractRegistry;
    mapping (address => uint) balances;

    constructor (address _operator) {
        operator = _operator;
    }


    function acceptOffer (address _offeringContractAddress,address _leasee, bytes32 _offeringId,uint _contractExpiry) external payable{ 
        uint initialContractAmount;
        uint dailyPayoutAmount;         
        initialContractAmount = IOffering(_offeringContractAddress).viewinitialAmount(_offeringId);
        dailyPayoutAmount =IOffering(_offeringContractAddress).dailyPayoutAmount(_offeringId);
        require (msg.value >= initialContractAmount, "Complete the initial payment for contract acceptance");
        bytes32 contractId = keccak256(abi.encodePacked(_offeringId,contractNonce));
        contractRegistry[contractId].leasee = _leasee;
        contractRegistry[contractId].offeringId = _offeringId;
        contractRegistry[contractId].startDate = block.timestamp;
        contractRegistry[contractId].endDate = contractRegistry[contractId].startDate + _contractExpiry;  
        contractRegistry[contractId].dailyPayout = dailyPayoutAmount;
        contractNonce += 1;
        emit  contractStarted(contractId, _leasee,block.timestamp,_contractExpiry,dailyPayoutAmount);
    }

    // function closeOffering(bytes32 _offeringId) external payable {
    //     require(msg.value >= offeringRegistry[_offeringId].dailyPayoutAmount, "Not enough funds to buy");
    //     require(offeringRegistry[_offeringId].closed != true, "Offering is closed");
    //     ERC721 hostContract = ERC721(offeringRegistry[_offeringId].hostContract);
    //     offeringRegistry[_offeringId].closed = true;
    //     balances[offeringRegistry[_offeringId].offerer] += msg.value;
    //     //hostContract.safeTransferFrom(offeringRegistry[_offeringId].offerer, msg.sender, offeringRegistry[_offeringId].tokenId);
    //     emit OfferingClosed(_offeringId, msg.sender);
    // }

 

    function withdrawBalance(uint256 _dailyProduction,address _leasee,bytes32 contractId) external {
        uint amount = ((contractRegistry[contractId].dailyPayout)/100)*_dailyProduction;        
        payable(_leasee).transfer(amount);
        emit BalanceWithdrawn(msg.sender, amount);
    }

    function changeOperator(address _newOperator) external {
        require(msg.sender == operator,"only the operator can change the current operator");
        address previousOperator = operator;
        operator = _newOperator;
        emit OperatorChanged(previousOperator, operator);
    }

     function viewContract(bytes32 contractId) external view returns (address, uint, uint,uint){
        return (contractRegistry[contractId].leasee,contractRegistry[contractId].startDate,contractRegistry[contractId].endDate,contractRegistry[contractId].dailyPayout);
    }

    function viewBalances(address _address) external view returns (uint) {
        return (balances[_address]);
    }

}