// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ICampaignFactory.sol";
import "./IERC20.sol";

contract Campaign{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    enum Status{
        notVerifiedByManager,
        verifiedByManager,
        fundRaising,
        fundRaisingFailed,
        projectInProgress,
        paymentRequestWaiting,
        projectFinished,
        paused
    }

    struct PaymentRequest {
	        string description;
	        uint256 value;
	        bool complete;
	        uint approvalCount;
	    }

    struct ReplaceRequest {
        uint256 price;
        uint256 _investingAmount;
        address currentInvestor;
        bool replaced;
        bool active;
    }

    address payable public creator;
    address payable public buyer;
    address payable[] public investors;
    address public tokenAddress = 0x9C662487c3bebCEaeB12f1E0c244fFED5470e086; // USDC  
    address public campaignFactoryAddress; // addresss of the campaign factory contract
    address public befunderManager; 
    address public befunderRep;
    address[] public approvers;
    IERC20 public Token;
    ICampaignFactory public campaignFactoryContract;
    uint256 public fundingPeriod;
    uint256 public goalAmount;
    uint256 public interestRate;
    string public title;
    string public description;
    string public fileName;
    uint256 public totalFund = 0;
    uint256 public numRequest = 0;
    uint256 public numReplaceRequest = 0;
    mapping(address => uint256) public investorsAmount;
    mapping(address => bool) public investorsList; // should be private
    mapping(address => uint256) public investorsInterest;
    mapping(uint256 => mapping(address => bool)) requestsApproversLists;
    mapping(address => uint256[]) investorsReplaceRequest;
    uint256 public investorsCount = 0;
    uint256 public platformFee; // platform fee should be determined dynamically. but for now we fixed it
    uint256 public prepaymentPercentage;
    uint256 public currentBalance;
    uint256 public fullFund;
    uint256 public milestoneNum;
    uint256 public projectEndTimeStamp = 0;
    uint256 public projectStartTimeStamp = 0;
    uint256 public fundingStartPoint;
    uint256 public fundingEndPoint;
    uint256 public totalInterest = 0;
    //uint256 public decimals = 6;
    //uint256 public maxProjectDays = 720;
    uint256 public feeMax = 1000; // maximum 10 * 100 (for fraction) 
    bool public buyerApproved = false;
    bool public managerApproved = false;
    bool public projectComplete = false;
    bool public prepaymentPaid = false;
    bool public pause = false;

    PaymentRequest[] public requests;
    ReplaceRequest[] public replaceRequests;
    bool internal locked;
    
    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier isCreator() {
	        require(creator == msg.sender, "you are not the project creator.");
	        _;
	    }

    modifier isInvestor(){
        require(investorsList[msg.sender] == true, "You are not investor.");
        _;
    }

    modifier isBuyer(){
        require(buyer == msg.sender, "you are not the buyer.");
        _;
    }

    // modifier isManager(){
    //     require(befunderManager == msg.sender, "you are not the manager.");
    //     _;
    // }

    // event milestonePaymentRequest(string titleOfProject, address addressOfCampaign, address addressOfCreator,
    //  uint256 paymentValue);
    // event replaceRerquest(string titleOfProject, address addressOfCampaign, address addressOfIvestor,
    //      uint256 priceForSell, uint256 investedValue);
    // event approvedByManager(address addressOfCampaignm, address addressOfBuyer, address addressOfCeator,
    //     string titleOfProject, uint256 projectTotalFund );

    constructor (address payable projectCreator, address payable projectBuyer, uint256 _fundingPeriod, 
                uint256 projectTotalFund, string memory projecTitle, string memory projectDescription,
                string memory _fileName, uint256 prepaymentPerc, 
                uint256 milestones, address manager) {
        creator = projectCreator;
        buyer = projectBuyer;
        fundingPeriod = _fundingPeriod; // in hours
        //fullFund = projectTotalFund*10**decimals;
        fullFund = projectTotalFund;
        goalAmount = (fullFund * 80)/100;
        title = projecTitle;
        prepaymentPercentage = prepaymentPerc;
        currentBalance = 0;
        Token = IERC20(tokenAddress);
        campaignFactoryAddress = msg.sender;
        campaignFactoryContract = ICampaignFactory(campaignFactoryAddress);
        milestoneNum = milestones;
        befunderManager = manager;
        description = projectDescription;
        fileName = _fileName;
    }

    function isFundingFinished() public view returns (bool){
			bool Finished = false;
			if (block.timestamp > fundingEndPoint){
				Finished = true;
			}
			if (totalFund >= goalAmount){
				Finished = true;
			}
            return Finished;
		}
        
    function isFundingSuccessful() public view returns (bool){
        bool successful = false;
        if (isFundingFinished()) {
            if (totalFund >= goalAmount){
                successful = true;
            } 
        }
        return successful;
    }

    function getPaymentRequests() public view returns(PaymentRequest[] memory) {
        return requests;
    }

    function managerApprove(address repWallet, uint256 fee) public{
        require(msg.sender == befunderManager, "only manager");
        require(!managerApproved, "the campaign already approved.");
        managerApproved = true;
        befunderRep = repWallet;
        require(fee <= feeMax, "platform fee exceeds the maximum allowed");
        platformFee = fee;
        campaignFactoryContract.updatePendingList(address(this));
        // emit approvedByManager(address(this), buyer, creator, title, totalFund);
    }

    function managerTransfer(address newManager) public{
        require(msg.sender == befunderManager, "only manager.");
        befunderManager = newManager;
    }

    function projectPause() public{
        require(msg.sender == befunderManager, "only manager.");
        if (pause){
            pause = false;
        } else {
            pause = true;
        }
    }

    function changeRepWallet(address newWallet) public {
        require(msg.sender == befunderManager, "only manager.");
        require(!pause, "project is paused.");
        befunderRep = newWallet;
    }
    
    function buyerApprove() public isBuyer{
        require(!pause, "project is paused.");
        require(managerApproved, "the project is not approved by the manager yet.");
        buyerApproved = true;
        fundingStartPoint = block.timestamp;
        fundingEndPoint = fundingStartPoint + fundingPeriod * 1 hours;
    }

    function maxInvest() public view returns(uint256){
        uint256 maximumInvestment = (goalAmount - totalFund);
        return maximumInvestment;
    }

    function contribute(uint256 amount) public nonReentrant {
        //require(msg.value > minContribution);
        //require(block.timestamp <= funding_period, "funding is closed" );
        require(!pause, "project is paused.");
        require(buyerApproved, "the project is not approved by the buyer");
        require(!isFundingFinished(), "Funding closed");
        require(amount > 0, "the investment amount must be bigger than zero");
        require(amount <= maxInvest(), "the money is beyond the maximum possible evalue.");
        Token.safeTransferFrom(msg.sender, address(this), amount);
        investorsAmount[msg.sender] += amount;
        investorsList[msg.sender] = true;
        totalFund += amount;
        investors.push(payable(msg.sender));
        investorsCount++;
        campaignFactoryContract.addInvestorInfo(msg.sender, address(this));
    }


    ////////////////////////////////// just for test. it should be removed 
    // function contractBalance() public view returns(uint256){
    //     return Token.balanceOf(address(this));
    // }

    /////////////////////////////////////////////////////////////////////////////////////// 
    function createRequest(string memory requestDesc, uint256 value) internal {
        require(value <= currentBalance, "not enough balance");
        PaymentRequest memory newRequest = PaymentRequest({
            description: requestDesc,
            value: value,
            complete: false,
            approvalCount: 0
        });
        
        requests.push(newRequest);
        numRequest ++;
        // emit milestonePaymentRequest(title, address(this), creator, value);
    }

    function createReplaceRequest(uint256 value, uint256 principal, address investor) internal {
        ReplaceRequest memory new_ReplaceRequest = ReplaceRequest({
            price: value,
            _investingAmount: principal,
            currentInvestor: investor,
            replaced: false,
            active: true
        });
        replaceRequests.push(new_ReplaceRequest);
        investorsReplaceRequest[investor].push(numReplaceRequest);
        numReplaceRequest ++;
        // emit replaceRerquest(title, address(this), msg.sender, value, principal);
    }

    function investorReplaceRequestIndex(address investorAddress) public isInvestor view returns(uint256[] memory){
        return investorsReplaceRequest[investorAddress];
    }

    function removeReplaceRequest(uint256 index) public isInvestor{
        ReplaceRequest storage _replaceRequest = replaceRequests[index];
        require(_replaceRequest.currentInvestor == msg.sender, "you can not remove this request.");
        _replaceRequest.active = false;
    }

    function paymentRequestForMilestone(string memory desc, uint256 value) public isCreator{
        require(!pause, "project is paused.");
        require(buyerApproved, "the project is not approved by the buyer");
        require(numRequest <= milestoneNum, "you cannot request more.");
        if (numRequest == milestoneNum){
            uint256 payValue = currentBalance;
            createRequest(desc, payValue);
        } else{
            createRequest(desc, value);
        }
        
    }

    function replaceRequest(uint256 sellPrice) public isInvestor{
        require(!pause, "project is paused.");
        require(isFundingFinished(), "Funding is not finished yet.");
        require(isFundingSuccessful(), "Funding was not finished successfully.");
        require(!projectComplete, "project is finished.");
        uint256 investedAmount = investorsAmount[msg.sender];
        createReplaceRequest(sellPrice, investedAmount, msg.sender);
    }

    // function getReplaceRquests() public view returns(bool, ReplaceRequest[] memory replaceRequestLists){
    //     return(_getReplaceRequests(), replaceRequests);
    // }

    function getReplaceRequests() public view returns(bool check){
        require(!pause, "project is paused.");
        check = false;
        if (isFundingFinished() && isFundingSuccessful() && !projectComplete){
            if (replaceRequests.length > 0){
                for (uint256 i=0; i < replaceRequests.length; i++){
                    if (replaceRequests[i].active && !replaceRequests[i].replaced){
                        check = true;    
                    }
                }
            }
            
        }
    }


    function approveRequest(uint256 index) public isInvestor{
        require(!pause, "project is paused.");
        PaymentRequest storage request = requests[index];
        require(!requestsApproversLists[index][msg.sender], "you already approved the request.");
        requestsApproversLists[index][msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 index) public isBuyer nonReentrant {
        //finalizing request
        PaymentRequest storage request = requests[index];
        require(!pause, "project is paused.");
        require(!request.complete, "the request already completed.");
        require(request.approvalCount > (investorsCount / 2));
        //uint256 payment_value = (currentBalance.mul(request.value * 10**18)).div(100);
        require(currentBalance >= request.value, "not enough fund.");
        currentBalance -= request.value;
        Token.safeTransfer(creator, request.value);
        request.complete = true;
    }

    function prepayment() public isCreator nonReentrant{
        require(!pause, "project is paused.");
        require(!prepaymentPaid, "Prepayment is paid already");    
        require(isFundingFinished(), "Funding is not closed.");
        require(isFundingSuccessful(), "Funding failed.");
        require(buyerApproved, "the project is not approved by the buyer");
        uint256 platformTokenBalance = (totalFund * platformFee)/(10000);
        Token.safeTransfer(befunderRep, platformTokenBalance);
        currentBalance  = totalFund - platformTokenBalance;
        uint256 prepaymentValue = (currentBalance * prepaymentPercentage)/(10000);
        require(currentBalance >= prepaymentValue, "not enough fund.");
        currentBalance -= prepaymentValue;
        Token.safeTransfer(creator, prepaymentValue);
        prepaymentPaid = true;
        projectStartTimeStamp = block.timestamp;
    }

    function projectCompleted() public isBuyer nonReentrant{
        require(!pause, "project is paused.");
        require(isFundingFinished(), "Finding is not finished.");
        require(isFundingSuccessful(), "Funding failed.");
        require(!projectComplete, "Project already completed");
        projectComplete = true;
        Token.safeTransferFrom(msg.sender, address(this), fullFund);
        projectEndTimeStamp = block.timestamp; 
        uint256 numDays = (projectEndTimeStamp - projectStartTimeStamp)/86400;
        if (numDays <= 150){
            interestRate = 5;
        } else if ((numDays > 150) && (numDays <= 180)){
            interestRate = 6;
        } else if ((numDays > 180) && (numDays <= 240)){
            interestRate = 7;
        } else if ((numDays > 240) && (numDays <= 300)){
            interestRate = 9;
        } else if ((numDays > 300) && (numDays <= 365)){
            interestRate = 10;
        } else if ((numDays > 365) && (numDays <= 540)){
            interestRate = 12;
        } else if ((numDays > 540) && (numDays <= 720)){
            interestRate = 20;
        }
        //interestRate = 5;
        // uint256 NumDays = 180; //just for simulation  
        for (uint256 i=0; i < investors.length; i++){
            if (investorsList[investors[i]]){
                uint256 principalMoney = investorsAmount[investors[i]];
                uint256 interestedMoney = (interestRate * numDays * principalMoney)/(100 * 360);
                uint256 maxIinterestedMoney = (interestRate * 720 * principalMoney)/(100 * 360);
                if (interestedMoney > maxIinterestedMoney){
                    interestedMoney = maxIinterestedMoney;
                }
                totalInterest += interestedMoney;
                investorsInterest[investors[i]] = (interestedMoney);
            }
        }

        uint256 remainedFund = fullFund - (totalInterest + goalAmount);
        if (remainedFund > 0) {
            Token.safeTransfer(creator, remainedFund);
        }            
        // return (projectComplete, remainedFund);
    }


    function replace(uint256 index_2) public nonReentrant{
        require(!pause, "project is paused.");
        require(isFundingFinished(), "Funding is not finished.");
        require(isFundingSuccessful(), "funding is not finished successfully.");
        require(!projectComplete, "project is finished.");
        ReplaceRequest storage _replaceRequest = replaceRequests[index_2];
        require(_replaceRequest.active, "the request is no longer available.");
        address currentInvestorAddress = _replaceRequest.currentInvestor;
        uint256 price = _replaceRequest.price;
        uint256 investedMoney = investorsAmount[currentInvestorAddress];
        require(Token.balanceOf(msg.sender) >= (investedMoney + price), "not enough fund.");
        Token.safeTransfer(currentInvestorAddress, investedMoney);
        investorsAmount[currentInvestorAddress] = 0;
        investorsList[currentInvestorAddress] = false;
        totalFund -= investedMoney;
        investorsCount--;
        Token.safeTransferFrom(msg.sender, currentInvestorAddress, price);
        Token.safeTransferFrom(msg.sender, address(this), investedMoney);
        investorsAmount[msg.sender] = investedMoney;
        investorsList[msg.sender] = true;
        investors.push(payable(msg.sender));
        totalFund += investedMoney;
        investorsCount++;
        _replaceRequest.replaced = true;
        campaignFactoryContract.addInvestorInfo(msg.sender, address(this));
    }

    function getInvestors() public view returns(address payable[] memory){
        return investors;
    }

    function withdraw() public isInvestor nonReentrant{
        require(!pause, "project is paused.");
        if (isFundingFinished() && !isFundingSuccessful()){
            if (investorsList[msg.sender]){
                uint256 investedMoney = investorsAmount[msg.sender];
                require(investedMoney > 0, "you have no token in the contract.");
                Token.safeTransfer(msg.sender, investedMoney);
                investorsList[msg.sender] = false;
            }    
        }

        if (projectComplete){
            if (investorsList[msg.sender]){
                uint256 investedMoney = investorsAmount[msg.sender];
                uint256 interestedMoney = investorsInterest[msg.sender];
                uint256 repayAmount = investedMoney + interestedMoney;
                Token.safeTransfer(msg.sender, repayAmount);
                investorsList[msg.sender] = false;
            }
        }
    }


    // function withdrawBeforeProject() public isInvestor nonReentrant{
    //     require(!pause, "project is paused.");
    //     require(isFundingFinished() && !isFundingSuccessful(), "funding is finished successfully.");
    //     if (investorsList[msg.sender]){
    //         uint256 investedMoney = investorsAmount[msg.sender];
    //         require(investedMoney > 0, "you have no token in the contract.");
    //         Token.safeTransfer(msg.sender, investedMoney);
    //         investorsList[msg.sender] = false;
    //     }
    // }

    // function withdrawAfterProject() public isInvestor nonReentrant{
    //     // repaying the investors pricipal and interested money
    //     require(!pause, "project is paused.");
    //     require(projectComplete, "Project is not finished yet.");
    //     if (investorsList[msg.sender]){
    //         uint256 investedMoney = investorsAmount[msg.sender];
    //         uint256 interestedMoney = investorsInterest[msg.sender];
    //         uint256 repayAmount = investedMoney + interestedMoney;
    //         Token.safeTransfer(msg.sender, repayAmount);
    //         investorsList[msg.sender] = false;
    //     }            
    // }

    // function transferContractBalance() public nonReentrant{
    //     require(msg.sender == befunderManager,"only manager.");
    //     require(projectComplete, "Project is not finished");
    //     uint256 balanceAmount = Token.balanceOf(address(this));
    //     require(balanceAmount > 0, "not enough tokens in the contract.");
    //     Token.safeTransfer(befunderRep, balanceAmount);
    // }

    function getCampaignInfo() public view returns(string memory, string memory, string memory,
    uint256, uint256, uint256, uint256, uint256, uint256, address, address){
        uint256 crowdFunded = totalFund;
        // bool isManagerApproved = managerApproved;
        // bool isBuyerApproved = buyerApproved;
        // bool isProjectFinished = projectComplete;
        //bool isPrePaymentpaid = prepaymentPaid;
        bool isCrowdfundingFinished;
        bool isCrowdfundingSuccessful;
        if (buyerApproved){
            isCrowdfundingFinished = isFundingFinished();
            isCrowdfundingSuccessful = isFundingSuccessful();    
        } 

        if (!buyerApproved){
            isCrowdfundingFinished = false;
            isCrowdfundingSuccessful = false;
        }
        // return (title, description, fileName, crowdFunded, isManagerApproved, isBuyerApproved, 
        //     isProjectFinished, isCrowdfundingFinished, isCrowdfundingSuccessful);
        uint256 projectState = uint256(getProjectStatus());
        return (title, description, fileName, fullFund, fundingPeriod, crowdFunded, numReplaceRequest,
        platformFee, projectState, creator, buyer);
    }

    function getProjectStatus() public view returns(Status projectStatus){
        if (pause){
            projectStatus = Status.paused;
        }

        if (!pause && !managerApproved){
            projectStatus = Status.notVerifiedByManager;
        }

        if (!pause && !buyerApproved && managerApproved){
            projectStatus = Status.verifiedByManager;
        }

        if (!pause && buyerApproved && !isFundingFinished()){
            projectStatus = Status.fundRaising;
        }

        if (!pause && buyerApproved && isFundingFinished() && !isFundingSuccessful()){
            projectStatus = Status.fundRaisingFailed;
        }

        if (!pause && buyerApproved && isFundingFinished() && isFundingSuccessful()){
            if (numRequest > 0) {
                uint256 completedRequests = 0;
                for (uint256 i=0; i < numRequest; i++){
                    if (!requests[i].complete) {
                        completedRequests ++;
                    }
                }

                if (completedRequests > 0){
                    projectStatus = Status.paymentRequestWaiting;
                } else {
                    projectStatus = Status.projectInProgress; 
                }
            } else {
                projectStatus = Status.projectInProgress;
            }
            
        }

        if (!pause && buyerApproved && isFundingFinished() && isFundingSuccessful() && projectComplete){
            projectStatus = Status.projectFinished;
        }
    }

    function finishingProject() public view returns(bool){
        require(!pause, "project is paused.");
        bool check = false;
        if (!projectComplete && isFundingFinished() && isFundingSuccessful()){
            uint256 contractBalance = Token.balanceOf(address(this));
            if (contractBalance == 0){
                check = true;
            }
        }
        return(check);
    }



}