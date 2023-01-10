/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SoftwareLocker {
    IERC20 public CLFI;
    IERC20 public LFI;

    struct softwareLicence {
    uint256 clfiRate;
    uint256 expiryPeriod;
    }

    uint256 rewardInNumberOfBlockes = 20;

    struct purchaseHistory{
    string softwareLicence;
    uint256 purchaseTime;
    uint256 expiryTime;
    }

    struct stakeRecord{
       string swLicence; 
       uint256 stakeAmount;
       uint256 totalAmount;
       uint256 timeFrame;
       uint256 interestRate;
       uint256 lockTime;
       uint256 period ;
       uint256 lockEndTime;
       uint256 lastUpdatedBlock;
       uint256 claimable;
       uint256 stakeTotalClaimed;
    }

    struct userStruct {
        uint balance;
        uint totalClaimed;
        uint totalClaimable;
        uint lastClaimedTime;
        uint stakeNo ;
    }
    mapping(address => userStruct) public user;

    uint public stakePool ;
    uint256 private stakeCount = 0;
    stakeRecord[] private stakes;
    struct poolNo{
        uint256 no;
        uint256 time;
        uint256 interestRate;   
         }

        struct stakeCheck{
        uint256 lockEndTime ;
    }

  mapping(string=>mapping(address=> stakeCheck))  stakeInfo;

    address public _owner;
    mapping(string => softwareLicence) public licenseRecord;
    mapping(string=>mapping(address=> purchaseHistory)) public licenceOwnership;
    mapping(address=>mapping(uint256=> stakeRecord)) public stakeHistory;
    mapping(uint => poolNo) public timeAndInterest;


    constructor(IERC20 _clfi, IERC20 _lfi) {
        CLFI = _clfi;
        LFI = _lfi;
        _owner = msg.sender;
    } 

       function poolSetting(uint256 _time , uint256 _interestPercent) public onlyOwner{
        uint _no = stakePool;
        timeAndInterest[_no].no = stakePool;
        timeAndInterest[_no].time =  _time;
        timeAndInterest[_no].interestRate = _interestPercent;
        stakePool ++;
       }

       function owner() public view virtual returns (address) {
        return _owner;
    }
        modifier onlyOwner() {
        require(owner() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function addSoftware(string calldata _softwareLicence, uint256 _rate , uint256 _period) public onlyOwner
    {
        licenseRecord[_softwareLicence].clfiRate = _rate;
        licenseRecord[_softwareLicence].expiryPeriod = _period;

    }

    function buySoftware(string calldata _softwareLicence)public {
        uint256 amount = licenseRecord[_softwareLicence].clfiRate;
        require(CLFI.balanceOf(msg.sender) >= amount , "not enough amount to purchase" );
        require(
            licenseRecord[_softwareLicence].clfiRate  <= amount,
            " amount is insufficient for purchase "
        );
        if (licenceOwnership[_softwareLicence][msg.sender].expiryTime == 0){
        CLFI.transferFrom(msg.sender, owner(), amount);
        licenceOwnership[_softwareLicence][msg.sender].softwareLicence = _softwareLicence;
        licenceOwnership[_softwareLicence][msg.sender].purchaseTime = block.timestamp;
        uint256 time = licenseRecord[_softwareLicence].expiryPeriod ;
        licenceOwnership[_softwareLicence][msg.sender].expiryTime = block.timestamp + time ;
        }
        if (licenceOwnership[_softwareLicence][msg.sender].expiryTime <= block.timestamp){
        CLFI.transferFrom(msg.sender, owner(), amount);
        licenceOwnership[_softwareLicence][msg.sender].softwareLicence = _softwareLicence;
        licenceOwnership[_softwareLicence][msg.sender].purchaseTime = block.timestamp;
        uint256 timeA = licenseRecord[_softwareLicence].expiryPeriod ;
        licenceOwnership[_softwareLicence][msg.sender].expiryTime = block.timestamp + timeA ;  
    }
    }

    function viewSoftwareBuy(string calldata _softwareLicence , address _account) public view returns  (bool flag){
       if ( licenceOwnership[_softwareLicence][_account].purchaseTime == 0 || licenceOwnership[_softwareLicence][_account].expiryTime <= block.timestamp){
           return false;
    }
    if (licenceOwnership[_softwareLicence][_account].purchaseTime > 0 && licenceOwnership[_softwareLicence][_account].expiryTime >=block.timestamp ){
          return true;
    }
    }
    function viewStakeFinish(string calldata _softwareLicence , address _account) public view returns  (bool flag){
    if ( stakeInfo[_softwareLicence][_account].lockEndTime == 0 || stakeInfo[_softwareLicence][_account].lockEndTime <= block.number){
           return false;
    }
    if (stakeInfo[_softwareLicence][_account].lockEndTime > 0 && stakeInfo[_softwareLicence][_account].lockEndTime >=block.number ){
          return true;
    }
    }

    function addStake(string calldata _softwareLicence, uint256 _no) public  returns(stakeRecord memory stakeTable){
        require(viewSoftwareBuy(_softwareLicence , msg.sender) == true, "please purchase software package");
    require(stakeInfo[_softwareLicence][msg.sender].lockEndTime == 0 || stakeInfo[_softwareLicence][msg.sender].lockEndTime <= block.timestamp ,"after lock expiry lock again");
        uint256 amount = licenseRecord[_softwareLicence].clfiRate;
        require(CLFI.balanceOf(msg.sender) >= amount , "not enough amount to stake" );
        uint stakeNumber = user[msg.sender].stakeNo;
        stakeHistory[msg.sender][stakeNumber].swLicence = _softwareLicence;
        stakeHistory[msg.sender][stakeNumber].stakeAmount =  amount;
        uint256 IR =  timeAndInterest[_no].interestRate  ;
        stakeHistory[msg.sender][stakeNumber].totalAmount = (amount + (amount * IR/100e18));
        stakeHistory[msg.sender][stakeNumber].lockTime =  block.timestamp ;
        stakeHistory[msg.sender][stakeNumber].period  = timeAndInterest[_no].time;
        stakeHistory[msg.sender][stakeNumber].lockEndTime =  block.timestamp+ timeAndInterest[_no].time;
        stakeInfo[_softwareLicence][msg.sender].lockEndTime = block.timestamp + timeAndInterest[_no].time;
        stakeHistory[msg.sender][stakeNumber].lastUpdatedBlock =  block.number;
        CLFI.transferFrom(msg.sender, owner(), amount);
        user[msg.sender].stakeNo++;
        user[msg.sender].balance += amount;
        return  stakeHistory[msg.sender][stakeNumber];
    }
 

    function viewStake(address userAddress,uint stakeNumber) public view returns (uint amount,uint initiate,uint endtime,uint lastUpdate,uint stakeTotalClaimed,uint claimable){  
             stakeRecord storage user_ = stakeHistory[userAddress][stakeNumber];
            uint256 claimReleaseRate  = 100e18 *rewardInNumberOfBlockes * 3/ stakeHistory[userAddress][stakeNumber].period ;
             if((user_.stakeTotalClaimed >= user_.totalAmount)  || (user_.totalAmount == 0) 
             || ((user_.lastUpdatedBlock + rewardInNumberOfBlockes) <= block.timestamp))  {
            return (user_.totalAmount,user_.lockTime,user_.lockEndTime,user_.lastUpdatedBlock,user_.stakeTotalClaimed,0);
        }
        uint timePeriod = (block.number - user_.lastUpdatedBlock) / rewardInNumberOfBlockes;        
        uint claimAmount = ( user_.totalAmount * (claimReleaseRate * timePeriod)) / 100e18;
        if((user_.stakeTotalClaimed + claimAmount) >=  (user_.totalAmount)
         || (user_.lockEndTime <= block.timestamp)) {
        claimAmount =  user_.totalAmount - user_.stakeTotalClaimed ; 
        }
        return  (user_.totalAmount,                 
                 user_.lockTime,
                 user_.lockEndTime,
                 user_.lastUpdatedBlock,
                 user_.stakeTotalClaimed,
                 claimAmount); 
       
    }
    function viewstakeNumber (address userAddress) public  view  returns (uint stakeNumber){
        return  user[userAddress].stakeNo;
    }

    function updateClaimInfoPerStake( address userAddress,uint stakeNumber) internal returns (uint claimable) {
        stakeRecord storage user_ = stakeHistory[userAddress][stakeNumber];     
        uint timePeriod;
        uint claimAmount; 
        if(user_.lockEndTime<=  block.timestamp) {
        claimAmount =  user_.totalAmount - user_.stakeTotalClaimed ;
        } 
        else if (user_.lockEndTime>= block.timestamp)  
        {    
        uint256 claimReleaseRate  = 100e18 * rewardInNumberOfBlockes * 3/ stakeHistory[userAddress][stakeNumber].period ;
        timePeriod = (block.number - user_.lastUpdatedBlock) / rewardInNumberOfBlockes;  
        claimAmount = ( user_.totalAmount * (claimReleaseRate * timePeriod)) / 100e18;    
        }
        user_.claimable = claimAmount;
        user_.lastUpdatedBlock = block.number; 
        user_.stakeTotalClaimed += claimAmount;
        return claimAmount;    
    }

     modifier updateClaimInfoPerUser( address userAddress)  {
        uint stakeNumber = viewstakeNumber(userAddress);
        uint timePeriod;
        uint claimAmount = 0;
        uint i ;        
        for (i=0  ; i<= user[userAddress].stakeNo ; i++){
        claimAmount = claimAmount + updateClaimInfoPerStake (userAddress,i);   
        }
        
        user[userAddress].totalClaimable = claimAmount;
        user[userAddress].lastClaimedTime = block.timestamp;
    _;        
    }

    function totalclaimlfi() updateClaimInfoPerUser (msg.sender) external  returns (uint totalclaim){
      uint amount =  user[msg.sender].totalClaimable;
      require(amount > 0, " wait for claim or already full claimed");
      LFI.transfer(msg.sender, amount);  
      user[msg.sender].totalClaimed +=amount;
        return amount;
    }

    function getRateSoftware(string calldata _softwareLicence)
        public
        view
        returns (uint256)
    {
        return  licenseRecord[_softwareLicence].clfiRate;
    }

    function getBlocknumber() public view returns (uint){
      return  block.timestamp;
    }
}