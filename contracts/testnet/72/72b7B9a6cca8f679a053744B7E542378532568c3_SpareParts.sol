/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

pragma solidity 0.8.7;

contract SpareParts{

bytes32 public agreementFormIPFS;//it holds the details of the agreement between the different managers
SparePart public SP;
address public Engineer;
address public LineManager;
address public InventoryManager;
address public ProcurementManager;
address public PurchaseManager;
address public OEM; //Original Equipment Manufacturer
address public Supplier;

//Sub-contract addresses or child contracts
//  address public ChildContract_FanBlade;
//  address public ChildContract_Spinner;

enum SP_State {NeedsPR, PR_Submitted, PR_Approved, NotAvailableLocally,
               PQ_Submitted,EvaluationSubmitted, EvaluationApproved,SparePartAvailabilityConfirmed,
            PurchaseOderSubmitted,PurchaseOrderApproved, PurchaseOrderConfirmed,
    AvailableInInventory, CollectedByEngineer}//states of the spare part procurement process

struct SparePart {
  string description;//informtation about the spare part
  bytes32 IPFS_Hash;//IPFS hash of the spare part details and photos on the IPFS server
  uint256 timestamp;
  uint256 MISC; //MISC number of spare part
  SP_State state;
  address owner;

}


//constructor
constructor() {
     //ChildContract_Spinner =  0x6a07bB46D93c4BF298E1aCf67bDBd163e7B793c6;
     //ChildContract_FanBlade = 0xdb4B0eAA26928469bC198e2c86219406f79cf0c5;
    Engineer = 0x8B2f2a9a697092df6F220dA1F4d0Ccc5A4cf6000;
    LineManager = 0x8B2f2a9a697092df6F220dA1F4d0Ccc5A4cf6000;
    InventoryManager = 0x8B2f2a9a697092df6F220dA1F4d0Ccc5A4cf6000;
    ProcurementManager = 0x8B2f2a9a697092df6F220dA1F4d0Ccc5A4cf6000;
    PurchaseManager = 0x8B2f2a9a697092df6F220dA1F4d0Ccc5A4cf6000;
    OEM = 0x8B2f2a9a697092df6F220dA1F4d0Ccc5A4cf6000;
    Supplier =  0x8B2f2a9a697092df6F220dA1F4d0Ccc5A4cf6000;
    SP.MISC = 12345;
    SP.state = SP_State.NeedsPR;
    SP.timestamp = block.timestamp;
    SP.owner = OEM; //current owner
    agreementFormIPFS = 'jhfghffs';//might be  needed for agreement between the participants
}


modifier OnlyEngineer(){
    require(msg.sender == Engineer);
    _;
} 

modifier OnlyLineManager(){
    require(msg.sender == LineManager);
    _;
} 


modifier OnlyInventoryManager(){
    require(msg.sender == InventoryManager);
    _;
} 

modifier OnlyProcurementManager(){
    require(msg.sender == ProcurementManager);
    _;
} 

modifier OnlyPurchaseManager(){
    require(msg.sender == PurchaseManager);
    _;
}

modifier OnlySupplier(){
    require(msg.sender == Supplier);
    _;
}

modifier OnlySparepartOwner(){
    require(msg.sender == SP.owner);
    _;
}

//events
event PurchaseRequestSubmittedByEngineer(uint256);
event PurchaseRequestApprovedSuccessfully();
event PurchaseRequestNotApproved();
event ItemNotAvailableLocally();
event ItemAvailableLocally();
event SuppliersPurchaseQuotationsAvailableForEvaluation();
event EvaluationSubmitted();
event EvaluationApprovedByManager();
event SparePartAvailableAtRequestedSupplier();
event PurchaseOrderSubmitted();
event PurchaseOrderApproved();
event PurchaseOrderDeclined();
event PurchaseOrderConfirmed();
event SparePartNowAvailableInInventory();
event SparePartCollectedByEngineer();
event EvaluationNotApprovedByManager();
event SparePartUnavailableAtRequestedSupplier();

//Functions

   //this function is to submit the PR
    function SubmitPurchaseRequest() OnlyEngineer public{
        require(SP.state == SP_State.NeedsPR);
        SP.state = SP_State.PR_Submitted;
        emit PurchaseRequestSubmittedByEngineer(SP.MISC);
    }
    
    //this function is to approve the PR 
    function ApproveRequest(bool result) OnlyLineManager public{
        require(SP.state == SP_State.PR_Submitted);
        if(result)
        {
            SP.state = SP_State.PR_Approved;
            emit PurchaseRequestApprovedSuccessfully();
        }
        else{
        emit PurchaseRequestNotApproved();
        }
       
    }
    
    //this function is to confirm the unavailability of the part in the inventory
    function ConfirmUnavailabilityLocally(bool result) OnlyInventoryManager public{
        require(SP.state == SP_State.PR_Approved);
        if(result)
        {
            SP.state = SP_State.NotAvailableLocally;
            emit ItemNotAvailableLocally();
        }
        else{
        emit ItemAvailableLocally();
        }
    }
    
    //Use the following argument (SHA256) for testing
    //0x64EC88CA00B268E5BA1A35678A1B5316D212F4F366B2477232534A8AECA37F3C
    //["0x64","0xEC","0x88","0xCA","0x00","0xB2","0x68","0xE5","0xBA","0x1A","0x35","0x67","0x8A","0x1B","0x53","0x16","0xD2","0x12","0xF4","0xF3","0x66","0xB2","0x47","0x72","0x32","0x53","0x4A","0x8A","0xEC","0xA3","0x7F","0x3C"]
    //this function provides the ipfs hash of the suppliers quotations
    function SubmitPurchaseQuotationsIPFS(bytes32 ipfs) OnlyProcurementManager public{
        require(SP.state == SP_State.NotAvailableLocally);
        emit SuppliersPurchaseQuotationsAvailableForEvaluation();
        SP.state = SP_State.PQ_Submitted;
    }
    
    //this function allows the engineer to submit the evalutation result
    function SubmitEvaluationResult(bytes32 SupplierCode) OnlyEngineer public{
        require(SP.state == SP_State.PQ_Submitted);
        emit EvaluationSubmitted();
        SP.state = SP_State.EvaluationSubmitted;
    }
    
    //this function approves the evaluation result by the line manager
    function ApproveEvaluation(bool result) OnlyLineManager public{
        require(SP.state == SP_State.EvaluationSubmitted);
        if(result){
        emit EvaluationApprovedByManager();
        SP.state = SP_State.EvaluationApproved;
        }
        else{
            emit EvaluationNotApprovedByManager();
        }
    }
    
    //this function confirms the availability of the chosen spare part 
    function ConfirmSparePartAvailability(bool result) OnlyProcurementManager public{
        require(SP.state == SP_State.EvaluationApproved);
        if(result){
        emit SparePartAvailableAtRequestedSupplier();
        SP.state = SP_State.SparePartAvailabilityConfirmed;
        }
        else{
            emit SparePartUnavailableAtRequestedSupplier();
        }
    }
    
    //this function is used by the engineer to submit the purchase order
    function SubmitPurchaseOrder() OnlyEngineer public{
        require(SP.state == SP_State.SparePartAvailabilityConfirmed);
        SP.state = SP_State.PurchaseOderSubmitted;
        emit PurchaseOrderSubmitted();
    }
    
    //this function is used by the line to approve the PO
    function ApprovePurchaseOrder(bool result) OnlyLineManager public{
        require(SP.state == SP_State.PurchaseOderSubmitted);
        if(result){
        SP.state = SP_State.PurchaseOrderApproved;
        emit PurchaseOrderApproved();
        }
        else{
            emit PurchaseOrderDeclined();
        }
        
    }
    
    //this function is used by the Purchase Manager to confirm the aoproved PO
    function ConfirmPurchaseOrder() OnlyPurchaseManager public{
       require(SP.state == SP_State.PurchaseOrderApproved);
        SP.state = SP_State.PurchaseOrderConfirmed;
         emit PurchaseOrderConfirmed();
    }
    
    //this function is used by the InventoryManager to announce the avalability of the requested SparePart
    function AnnounceAvailabilityInInventory() OnlyInventoryManager public{
        require(SP.state == SP_State.PurchaseOrderConfirmed);
        SP.state = SP_State.AvailableInInventory;
        emit SparePartNowAvailableInInventory();
    }
    
    //this function is used by the Engineer to announce collecting the spare part from the Inventory
    function CollectRequestedSparePart() OnlyEngineer public{
        require(SP.state == SP_State.AvailableInInventory);
        SP.state = SP_State.CollectedByEngineer;
        emit SparePartCollectedByEngineer();
        SP.state = SP_State.NeedsPR; //needs a purchase request to be requested again
    }
 
   
}