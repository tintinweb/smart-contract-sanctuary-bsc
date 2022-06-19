/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

library SafeMath {
    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* Modulus */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);
    function decimals() external returns (uint8);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract TokenSale  {

    address payable private primaryAdmin;

    constructor() {
        address payable msgSender = payable(msg.sender);
        primaryAdmin = msgSender;
	}

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return primaryAdmin;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(primaryAdmin == payable(msg.sender), "Ownable: caller is not the owner");
        _;
    }

         /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(primaryAdmin, address(0));
        primaryAdmin = payable(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(primaryAdmin, newOwner);
        primaryAdmin = newOwner;
    }

    struct Projects {
        string projectId;
        string projectName;
        IERC20 projectContract;
        string tokenName;
        string tokenShortName;
        uint256 totalsupply;
        uint decimals;
        uint256 totalTokenSold;
        uint256 totalTokenClaimed;
        uint256 totalBNBCollected;
        bool projectStatus;
        uint lastUpdatedUTCDateTime;
	}

    struct ProjectPhaseDetails { 
        string phaseId;
        string projectId;
        uint startUTCDateTime;
        uint endUTCDateTime;
        uint256 tokenPrice;
        uint256 tokenSaleCap;
        uint256 totalTokenSold;
        uint256 totalTokenClaimed;
        uint256 totalBNBCollected;
        bool phaseStatus;
        uint lastUpdatedUTCDateTime;
	}

    struct ProjectPhaseVestingDetails {
        string phaseId;
        string projectId;
        uint noofPhase;
        uint[20] releaseUTCDateTime;
        uint[20] releasePer;
        uint lastUpdatedUTCDateTime;
	}

    struct UserPurchased {
      string orderId;
      string projectId;
      string phaseId;
      address walletAddress;
      uint256 totalBNBSpended;
      uint256 totalPurchased;
      uint256 totalAvailable;
      uint256 totalClaimed;
      uint lastPurchasedUTCUpdateTime;
      uint lastClaimedUTCUpdateTime;
	}

    mapping (string => UserPurchased) public userpurchaseds;
    mapping (string => Projects) public projects;
	mapping (string => ProjectPhaseDetails) public projectphasedetails;
    mapping (string => ProjectPhaseVestingDetails) public projectphasevestingdetails;

    event Sold(address _buyer, uint256 _numberOfTokens,string _phaseId,string _projectId);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function addProject(string memory _projectId, string memory _projectName) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        Projects storage project = projects[_projectId];
        project.projectId=_projectId;
        project.projectName=_projectName;
        project.projectStatus=true;
        project.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    function updateProject(string memory _projectId, string memory _projectName) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        Projects storage project = projects[_projectId];
        project.projectName=_projectName;
        project.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    function updateProjectTokenomics(string memory _projectId,IERC20 _projectContract,string memory _tokenName,string memory _tokenShortName,uint256 _totalsupply,uint _decimals) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        Projects storage project = projects[_projectId];
        project.projectContract=_projectContract;
        project.tokenName=_tokenName;
        project.tokenShortName=_tokenShortName;
        project.totalsupply=_totalsupply;
        project.decimals=_decimals;
        project.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    function updateProjectStatus(string memory _projectId,bool _projectStatus) public {
        require(primaryAdmin==msg.sender, 'Admin what?');
        Projects storage project = projects[_projectId];
        project.projectStatus=_projectStatus;
        project.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    function addProjectPhase(string memory _phaseId,string memory _projectId,uint _startUTCDateTime,uint _endUTCDateTime,uint256 _tokenPrice,uint256 _tokenSaleCap) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        ProjectPhaseDetails storage projectphasedetail = projectphasedetails[_phaseId];
        projectphasedetail.projectId=_projectId;
        projectphasedetail.phaseId=_phaseId;
        projectphasedetail.startUTCDateTime=_startUTCDateTime;
        projectphasedetail.endUTCDateTime=_endUTCDateTime;
        projectphasedetail.tokenPrice=_tokenPrice;
        projectphasedetail.tokenSaleCap=_tokenSaleCap;
        projectphasedetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    function updateProjectPhase(string memory _phaseId,uint _startUTCDateTime,uint _endUTCDateTime,uint256 _tokenPrice,uint256 _tokenSaleCap) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        ProjectPhaseDetails storage projectphasedetail = projectphasedetails[_phaseId];
        projectphasedetail.startUTCDateTime=_startUTCDateTime;
        projectphasedetail.endUTCDateTime=_endUTCDateTime;
        projectphasedetail.tokenPrice=_tokenPrice;
        projectphasedetail.tokenSaleCap=_tokenSaleCap;
        projectphasedetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    function updateProjectPhaseStatus(string memory _phaseId,bool _phaseStatus) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        ProjectPhaseDetails storage projectphasedetail = projectphasedetails[_phaseId];
        projectphasedetail.phaseStatus=_phaseStatus;
        projectphasedetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    function configureProjectPhaseVesting(string memory _phaseId,string memory _projectId,uint _noofPhase) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        require(_noofPhase < 21 ,'Maximum Vesting Can Be 20');
        if(projectphasevestingdetails[_phaseId].noofPhase==0)
        {
          ProjectPhaseVestingDetails storage projectphasevestingdetail = projectphasevestingdetails[_phaseId];
          projectphasevestingdetail.phaseId=_phaseId;
          projectphasevestingdetail.projectId=_projectId;
          projectphasevestingdetail.noofPhase=_noofPhase;
          projectphasevestingdetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
        }
    }

    function updateProjectPhaseVesting(string memory _phaseId,uint _vestingIndex,uint _releaseUTCDateTime,uint _releasePer) public onlyOwner(){
        require(primaryAdmin==msg.sender, 'Admin what?');
        require(_vestingIndex < 20 ,'Maximum Vesting Index Can Be 19 Bcz Start From 0');
        if(projectphasevestingdetails[_phaseId].releasePer[_vestingIndex]==0)
        {
         ProjectPhaseVestingDetails storage projectphasevestingdetail = projectphasevestingdetails[_phaseId];
         projectphasevestingdetail.releaseUTCDateTime[_vestingIndex]=_releaseUTCDateTime;
         projectphasevestingdetail.releasePer[_vestingIndex]=_releasePer;
         projectphasevestingdetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
        }
    }

    function getProjectPhaseVestingDetails(string memory _phaseId,uint _vestingIndex)public view returns(uint _releaseUTCDateTime, uint _releasePer,uint _lastUpdatedUTCDateTime){
       return (projectphasevestingdetails[_phaseId].releaseUTCDateTime[_vestingIndex], projectphasevestingdetails[_phaseId].releasePer[_vestingIndex],projectphasevestingdetails[_phaseId].lastUpdatedUTCDateTime);
    }

    function getTokenPrice(string memory _phaseId)public view returns(uint256 _tokenPrice){
       return (projectphasedetails[_phaseId].tokenPrice);
    }

    function getEstimatedBNBNeedForToken(string memory _phaseId,uint256 _numberOfTokens)public view returns(uint256 _tokenPrice){
        uint256 _tokenprice=getTokenPrice(_phaseId);
        if (_numberOfTokens == 0) {
            return 0;
        } else {
            uint256 BNBWorth = _numberOfTokens * _tokenprice;
            assert(BNBWorth / _numberOfTokens == _tokenprice);
            return BNBWorth;
        }
    }

    //Guards Against Integer Overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function Participate(string memory _phaseId,string memory _projectId,string memory _orderId,uint256 _numberOfTokens) public payable returns (bool) {
       uint256 _tokenprice=projectphasedetails[_phaseId].tokenPrice;
       require(msg.value == safeMultiply(_numberOfTokens, _tokenprice),'Invalid no of Token ! Mismatch With Price !');
       require(view_GetCurrentTimeStamp() >= projectphasedetails[_phaseId].startUTCDateTime ,'Sale Not Strated Yet !');
       require(projectphasedetails[_phaseId].endUTCDateTime >= view_GetCurrentTimeStamp() ,'Sale Already Closed !');
       require((projectphasedetails[_phaseId].tokenSaleCap-projectphasedetails[_phaseId].totalTokenSold) >= _numberOfTokens ,'Targeted Sale Completed !');
       UserPurchased storage userpurchased = userpurchaseds[_orderId];
       Projects storage project = projects[_projectId];
       ProjectPhaseDetails storage projectphasedetail = projectphasedetails[_phaseId]; 
       userpurchased.orderId=_orderId;
       userpurchased.phaseId=_phaseId;
       userpurchased.projectId=_projectId;
       userpurchased.walletAddress=msg.sender;
       userpurchased.totalPurchased+=_numberOfTokens;
       userpurchased.totalAvailable+=_numberOfTokens;
       userpurchased.totalClaimed+=0;
       userpurchased.totalBNBSpended+=msg.value;
       userpurchased.lastPurchasedUTCUpdateTime=view_GetCurrentTimeStamp();
       project.totalTokenSold+=_numberOfTokens;
       project.totalBNBCollected+=msg.value;
       projectphasedetail.totalTokenSold+=_numberOfTokens;
       projectphasedetail.totalBNBCollected+=msg.value;
       emit Sold(msg.sender, _numberOfTokens,_phaseId,_projectId);
       return true;
    }

    //Owner Can Get Participated BNB & Can Transfer To The Project Owner
    function GetParticipatedBNB() public onlyOwner() {
       require(primaryAdmin==msg.sender, 'Admin what?');
       primaryAdmin.transfer(address(this).balance);
    }

    //Once Claim Need From Smart Contract Admin Need To Update Token on Smart Contract
    function _setupTokenClaim(string memory _projectId,uint _amount) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        projects[_projectId].projectContract.transferFrom(msg.sender, address(this), _amount);
    }

    //Revese Token That Admin Puten on Smart Contract
    function _reverseSetupTokenClaim(string memory _projectId,uint _amount) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        projects[_projectId].projectContract.transfer(primaryAdmin, _amount);
    }

    function Claim(string memory _phaseId,string memory _projectId,uint _vestingIndex,string memory _orderId) public payable returns (bool) {
       require(projectphasevestingdetails[_phaseId].releasePer[_vestingIndex] > 0 ,'Nothing For Claim !');
       require(view_GetCurrentTimeStamp()>=projectphasevestingdetails[_phaseId].releaseUTCDateTime[_vestingIndex] ,'Vesting Not Started Yet !');
       require(userpurchaseds[_phaseId].totalAvailable>0, 'No Vesting Remain !');
       Projects storage project = projects[_projectId];
       ProjectPhaseDetails storage projectphasedetail = projectphasedetails[_phaseId];
       UserPurchased storage userpurchased = userpurchaseds[_orderId];
       ProjectPhaseVestingDetails storage projectphasevestingdetail = projectphasevestingdetails[_phaseId];      
       if(userpurchased.totalAvailable>0){
         uint256 _totalPurchased=userpurchased.totalPurchased;
         uint256 _totalPayableAmount=((_totalPurchased*projectphasevestingdetail.releasePer[_vestingIndex])/100);
         if(userpurchased.totalAvailable>=_totalPayableAmount)
         {
            projects[_projectId].projectContract.transferFrom(address(this),msg.sender, _totalPayableAmount);
            userpurchased.totalAvailable-=_totalPayableAmount;
            userpurchased.totalClaimed+=_totalPayableAmount;
            userpurchased.lastClaimedUTCUpdateTime=view_GetCurrentTimeStamp();
            userpurchased.totalClaimed+=_totalPayableAmount;
            project.totalTokenClaimed+=_totalPayableAmount;
            projectphasedetail.totalTokenClaimed+=_totalPayableAmount;
         }
       }
       return true;
    }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

   //View No Second Between Two Date & Time
    function view_GetNoofSecondBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _second){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate);
        return (datediff);
    }

    //View No Of Hour Between Two Date & Time
    function view_GetNoofHourBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60;
        return (datediff);
    }

    //View No Of Days Between Two Date & Time
    function view_GetNoofDaysBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60 / 24;
        return (datediff);
    }

    //View No Of Week Between Two Date & Time
    function view_GetNoofWeekBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _weeks){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint weekdiff = (datediff) / 7 ;
        return (weekdiff);
    }

    //View No Of Month Between Two Date & Time
    function view_GetNoofMonthBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _months){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint monthdiff = (datediff) / 30 ;
        return (monthdiff);
    }

    //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }
}