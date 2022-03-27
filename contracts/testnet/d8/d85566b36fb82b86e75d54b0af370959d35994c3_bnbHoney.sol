/**
 *Submitted for verification at BscScan.com on 2022-03-27
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
    uint planID;
    uint maxReturnMultiplier;

    uint PERCENT_DIVIDER=100;


    struct systemInfo{

    uint totalSystemFund;
    uint totalSystemWithdrawn;
    uint systemTax;


    }

    systemInfo public systemInfos ;
    
    bool isContractPaused= false;

    struct plan{

        uint minimumInvest;
        uint roiRate;
        uint expireTimestamp;
    }

    struct userInfo {
        bool joined;
        uint256 referral;
        uint256  withdrawn;
        bool     isWithdrawLocked;
    }


    

    mapping(uint=>plan) public businessPlan;
    mapping (address => userInfo) public userInfos;

    event businessPlanAddEv(uint planID, uint rate, uint minimum, uint timestamp);
    event businessPlanUpdateEv(uint planID, uint rate, uint minimum, uint timestamp);
    event changeUserEv(address _old,address _new);
   
    event investEv( address _user,  uint256 planID,uint planAmount,uint expiry);


    constructor(address _user ) public {
       
    //   set level price

    // planInfo[1].rate =100;
    // planInfo[1].minimum=0.01 ether;
    
    // planInfo[2].rate=250;
    // planInfo[2].minimum=0.02 ether;

    // planInfo[3].rate=300;
    // planInfo[3].minimum=0.03 ether;

    systemInfos.systemTax=1; // for

    // default user 

        userInfos[_user].joined=true;
        userInfos[_user].referral=0;

        emit regUserEv(_user, 0);

        
    }


     // user registration 
     event regUserEv(address _user, uint48 referral);
    function regUser(uint48 referral_ID) public payable returns(bool) 
    {   
        require(isContractPaused==false,"contract is locked by owner");
        require(referral_ID!=0,"please set defaultAddress first");
   
  
        require(userInfos[msg.sender].joined == false, "already registered");


        userInfos[msg.sender].joined=true;
        userInfos[msg.sender].referral=referral_ID;

        emit regUserEv(msg.sender, referral_ID);
        return true;
    }


    function addNewPlan(uint planAmount, uint minIvesment,uint timestamp) external onlyOwner returns(bool ) {
        planID++;
        businessPlan[planID].roiRate=planAmount;
        businessPlan[planID].minimumInvest= minIvesment;
        businessPlan[planID].expireTimestamp=timestamp;
        emit businessPlanAddEv(planID,planAmount,minIvesment,timestamp);
        return true;
    }


    function updatePrePlan(uint48 _planID,uint roiRate, uint minInvest,uint timestamp) external onlyOwner returns (bool){

        require(businessPlan[_planID].roiRate>0 && businessPlan[_planID].roiRate!=roiRate,"invalid planID or PlanAmount");
        businessPlan[_planID].roiRate=roiRate;
        emit businessPlanUpdateEv(_planID,roiRate,minInvest,timestamp);
        return true;
    }


    // invest user

    function Invest (uint _planID) payable external returns(bool) {

        require(isContractPaused==false,"contract is locked by owner");
        require(businessPlan[_planID].roiRate>0,"Plan not exisit,please check");
        require(businessPlan[_planID].minimumInvest<=msg.value,"invalid amount");
        require(userInfos[msg.sender].joined==true,"join first");   

        uint systemfee= msg.value* systemInfos.systemTax /100;        
        systemInfos.totalSystemFund+= systemfee;
        uint _planValid = now+businessPlan[_planID].expireTimestamp;
        emit investEv(msg.sender, _planID,msg.value-systemfee,_planValid);

        return true;

    }



    // fallback function

    function () payable external {
       
    }
    

    //  withdraw
    event withdrawEv(address user, uint _amount);
    function withdrawMyGain(address payable rec, uint _amount)external  onlySigner returns(bool) {

        // migrate user if it is not in current contract

        require(isContractPaused==false,"contract is locked by owner");
        require(userInfos[rec].isWithdrawLocked==false,"withdraw is locked");
        require(userInfos[rec].joined==true,"invalid user");

        rec.transfer(_amount);
        
	    userInfos[rec].withdrawn+=_amount;
        
        emit withdrawEv(rec,_amount);

        return true;

    }



//-------------------------------ADMIN CALLER FUNCTION -----------------------------------



   function changeUserAddress(address oldUserAddress, address newUserAddress) external onlyOwner returns(bool){

        userInfos[newUserAddress] = userInfos[oldUserAddress];
        
   
        userInfo memory UserInfo;
            UserInfo = userInfo({
            joined:false,
            referral:0,
            withdrawn:0,
			isWithdrawLocked:false

         });
        
        userInfos[oldUserAddress] = UserInfo;

        emit changeUserEv(oldUserAddress,newUserAddress);
        
        return true;    
    }




    function withdrawSystemFund() external onlyOwner returns(bool){

        uint tot = systemInfos.totalSystemFund;
        uint withdrawn= systemInfos.totalSystemWithdrawn;
        uint avl;
        if(tot>=withdrawn){

            avl = tot-withdrawn;
            if(avl<=address(this).balance){
                     address(uint160(owner)).transfer(avl);
                     systemInfos.totalSystemWithdrawn+avl;
                     return true;
            }else{

                avl= address(this).balance;
                 address(uint160(owner)).transfer(avl);
                 systemInfos.totalSystemWithdrawn+avl;
                 return true;

            }
        }

        return false;

    }


    function updateMultiplier(uint _newMultiplier) external onlyOwner returns(bool){

        maxReturnMultiplier=_newMultiplier;
        return true;
    }


    function changeSystemTaxPrice(uint _price) external onlyOwner returns(bool){

        systemInfos.systemTax=_price;
        return true;
    }


    function unlockWithdraw(address _user) external onlyOwner returns(bool){

        require(userInfos[_user].isWithdrawLocked==true,"user is already unlocked");
        userInfos[_user].isWithdrawLocked=false;
        return true;
    }

    function lockWithdraw() external returns(bool){

        require(userInfos[msg.sender].joined==true,"User is not join or block");
        require(userInfos[msg.sender].isWithdrawLocked==false,"user is already locked");
        userInfos[msg.sender].isWithdrawLocked=false;
        return true;
        
    }

    function blockUser(address _user) external onlyOwner returns(bool){

        require(userInfos[_user].joined==true,"user is already block ");
        userInfos[_user].joined=false;

        return true;
    }

    function unblockUser(address _user) external onlyOwner returns(bool){
        require(userInfos[_user].joined==false,"user is already joined");
        userInfos[_user].joined=true;

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