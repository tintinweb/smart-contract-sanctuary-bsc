/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

pragma solidity 0.5.10; 


contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



contract bnbHoney is owned {

    // level price

    
    bool isContractPaused= false;

    struct plan{

        uint minimum;
        uint rate;
    }

    struct userInfo {
        bool joined;
        uint256  withdrawn;
        
    }
    

    mapping(uint=>plan) public planInfo;
    mapping (address => userInfo) public userInfos;
   
    event investEv( address _user, uint256 _refid, uint256 planID,uint planAmount);


    constructor( ) public {
       
    //   set level price

    planInfo[1].rate =100;
    planInfo[1].minimum=0.01 ether;
    
    planInfo[2].rate=250;
    planInfo[2].minimum=0.02 ether;

    planInfo[3].rate=300;
    planInfo[3].minimum=0.03 ether;

        
    }


    // invest user

    function Invest (uint _planID, uint _refID) payable external returns(bool) {

         require(isContractPaused==false,"contract is locked by owner");
        require(planInfo[_planID].rate>0,"Plan not exisit,please check");
        require(planInfo[_planID].minimum<=msg.value,"invalid amount");

        if (userInfos[msg.sender].joined==false){

            userInfos[msg.sender].joined=true;            
        }
        emit investEv( msg.sender,_refID, _planID,msg.value);

        return true;


    }



    // fallback function

    function () payable external {
       
    }
    

 
    //  withdraw
    event withdrawEv(address user, uint48 _amount);
    function withdrawMyGain(address payable rec, uint48 _amount)external  onlySigner returns(bool) {

        // migrate user if it is not in current contract
   

        require(isContractPaused==false,"contract is locked by owner");
        require(userInfos[rec].joined==true,"invalid user");

        rec.transfer(_amount);
        
	    userInfos[rec].withdrawn+=_amount;
        
        emit withdrawEv(rec,_amount);

        return true;

    }




    function lockContract(bool _value) external onlyOwner returns(bool){

        require(isContractPaused!=_value,"this value is already set");
        isContractPaused=_value;

        return true;

    }


    function reFillSigner(uint amount) public onlyOwner returns(bool){
        address(uint160(signer)).transfer(amount);
        return true;        
    }


    
    
    
    
    
}