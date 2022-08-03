// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.14;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface SwerriVendor{
    function buySWET(uint256 _busdAmount) external returns(bool success);
    function allowanceForBuy(uint256 _busdAmount) external returns(bool success) ;
}

contract CirclesUpgradableV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable{
    bool public paused;
    uint public numeretor;
    uint public denominator;
    uint public swetBusdRate;
    address public swerriFeesAddress;
    uint public processingFeeNumeretor;
    uint public minimumContributionMultiple;
    uint public swerriInterestShareNumeretor;

    string private privateKey;
    address private busdInstance;
    address private swetInstance;
    address private swetVendorInstance;

    uint public circleId;
    uint public circleCount;

    uint public loanId;

    // uint public voteId;

    struct SwerriVariables{
        uint numeretor;
        uint denominator;
        uint swetBusdRate;
        address swerriFeesAddress;
        uint processingFeeNumeretor;
        uint swerriInterestShareNumeretor;
        uint minimumContributionMultiple;
    }

    SwerriVariables public swerriVariables;

    struct CircleDetailsById{
        uint circleId;
        uint circleMemberCount;
        uint circleBalance;
        uint contributionTimeIterations;
        uint minContribution;
        uint creationDate;
        uint availableCircleBalance;
        uint earningsTimeIterations;
        uint circleEarnings;
        uint circleSwetBalance;
    }

    struct IndivudualsCircleDetails{
        uint circleId;
        uint balanceInCircle;
        uint availableBalanceInCircle;
        uint dateJoined;
        uint individualEarnings;
        uint swetBalance;
    }

    struct LoanDetailsById{
        uint loanId;
        uint circleId;
        uint loanType;
        uint loanAmount;
        uint amountToReceive;
        address payable borrower;
        uint amountNeededToBeGuaranteed;
        uint borrowerContributionAmount;
        uint guaranteedAmount;
        uint noOfGuarantors;
        uint amountRepaid;
        uint loanlength;
        string status;
        bool paid;
    }

    struct LoanTimesById{
        uint loanId;
        uint circleId;
        uint dateRequested;
        uint dateApproved;
        uint dateRejected;
        uint dateDisbursed;
        uint dateRepaid;
    }

    // struct VoteDetailsById {
    //     uint voteId;
    //     uint circleId;
    //     bool forLoan;
    //     uint upvotes;
    //     uint downvotes;
    //     bool approved;
    //     address initiator;
    //     uint dateInitiated;
    //     uint voterCount;
    // }

    mapping(uint => address[]) public membersOfCircle;
    mapping(uint => CircleDetailsById) public circleDetails;

    mapping(string => bool) public voted;
    mapping(string => bool) public rightToVote;
    mapping(string => uint) public balanceUsedToGuarantee;
    mapping(string => uint256) public belongsToWhichCircle;
    mapping(string => bool) public activeLoanInCurrentCircle;
    mapping(string => uint) public amountGuaranteedInCurrentLoan;
    mapping(string => IndivudualsCircleDetails) public individualsCircleDetails;

    mapping(uint => bool) public Loanrepaid;
    mapping(uint => uint) public amountToBePaid;
    mapping(uint => uint) public loanInterestRate;
    mapping(uint => uint) public loanInterestAmount;
    mapping(uint => address[]) public loanGuarantors;
    mapping(uint => LoanDetailsById) public loanDetails;
    mapping(uint => uint) public loanProcessingFeeAmount;
    mapping(uint => LoanTimesById) public loanTimeDetails;

    // mapping(uint => VoteDetailsById) public voteDetails;
    mapping(uint => uint) public voteIdToLoanId;

    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }

    modifier onlyIfCircleExists(uint _circleId) {
        //        "Circle does not exist"
        require(membersOfCircle[_circleId].length > 0, "CDNE");
        _;
    }

    modifier onlyCircleMember(uint _circleId, address _address){
        string memory combinedString = combineKeyString(_address, _circleId, "circle");
        //        Not a member of this circle
        require(belongsToWhichCircle[combinedString] == _circleId, "NAMOTC");
        _;
    }

    modifier onlyNonMember(uint _circleId, address _address){
        string memory combinedString = combineKeyString(_address, _circleId, "circle");
        //        Member already in circle
        require(belongsToWhichCircle[combinedString] == 0, "MAIC");
        _;
    }

    modifier onlyIfCircleDoesNotExist(uint _circleId){
        //        Circle with this ID already exists
        require(membersOfCircle[_circleId].length < 1, "CWTIAE");
        _;
    }

    modifier onlyObserveMinimum(uint _contribution, uint _circleId){
        //        Below minimum contribution
        require(_contribution >= circleDetails[_circleId].minContribution, "BMC");
        _;
    }

    event Paused(address indexed byWho);
    event Unpaused(address indexed byWho);
    // event VoteResultDecided(uint256 voteId, bool success);
    event LoanDisbursed(address indexed receiver, uint256 loanAmount);
    event SwerriFeesAddressChanged(address indexed byWho, address indexed toWhat);
    event CircleCreated(address indexed Creator, uint256 circleId, uint256 minimumContribution, uint256 timeIterations);

    function initialize (string memory _key, uint _circleId, uint _loanId)  public initializer {
        ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
        __Ownable_init();
        __UUPSUpgradeable_init();
        loanId = _loanId;
        privateKey = _key;
        circleId = _circleId;
        circleCount = 0;
        numeretor = 950;
        swetBusdRate = 2;
        denominator = 1000;
        processingFeeNumeretor = 20;
        minimumContributionMultiple = 3;
        swerriInterestShareNumeretor = 30;
        swetInstance = 0x742462Fb196c25731D478Fb3690b19ca4900f800;
        busdInstance = 0x836466e18BAB01a722EC87ca67c3Aac7d02b2B96;
        swerriFeesAddress = 0xA99BFc433D59714D3F182F2Ea3B4d7160A46b26c;
        swetVendorInstance = 0x7f802225bc1cDcBe24cBec17EBaBcc4e7DB37819;
        swerriVariables = SwerriVariables(
            numeretor,
            denominator,
            swetBusdRate,
            swerriFeesAddress,
            processingFeeNumeretor,
            swerriInterestShareNumeretor,
            minimumContributionMultiple
        );
        SwerriVendor(swetVendorInstance).allowanceForBuy(1000000000000000000);
        IBEP20(busdInstance).approve(address(swetVendorInstance), 1000000000000000000);
        paused = false;
    }

    function combineKeyString(address _sender, uint _id, string memory _identifier) public view returns(string memory mappingKey){
        return string.concat(privateKey,Strings.toHexString(uint160(_sender), 20), "#id", Strings.toString(_id), "id#", _identifier);
    }

    function setPaused(bool _paused, bool _attack) external onlyOwner returns(bool success){
        paused = _paused;
        if(_paused == true){
            emit Paused(_msgSender());
        }else{
            emit Unpaused(_msgSender());
        }
        if(_paused == true && _attack == true){
            defendContributions();
        }
        return true;
    }

    function defendContributions() internal returns(bool success){
        for(uint i=1; i < circleId; i++){
            for(uint n=0; n < membersOfCircle[i].length; n++){
                string memory individualCircleString = combineKeyString(membersOfCircle[i][n], i, "circle");
                uint busdBalance = individualsCircleDetails[individualCircleString].availableBalanceInCircle;
                uint swetBalance = individualsCircleDetails[individualCircleString].swetBalance;
                IBEP20(busdInstance).transfer(membersOfCircle[i][n], busdBalance);
                IBEP20(swetInstance).transfer(membersOfCircle[i][n], swetBalance);
            }
        }
        return true;
    }

    function changeSwetBusdRate(uint _newRate) external onlyOwner returns(bool success){
        swetBusdRate = _newRate;
        swerriVariables.swetBusdRate =_newRate;
        return true;
    }

    function changeNumeretor(uint _newNumeretor) external onlyOwner returns(bool success){
        numeretor = _newNumeretor;
        swerriVariables.numeretor =_newNumeretor;
        return true;
    }

    function changeDenominator(uint _newDenominator) external onlyOwner returns(bool success){
        denominator = _newDenominator;
        swerriVariables.denominator =_newDenominator;
        return true;
    }

    function changeSwerriFeesAddress(address _newAddress) external onlyOwner returns(bool success){
        swerriFeesAddress = _newAddress;
        swerriVariables.swerriFeesAddress = _newAddress;
        emit SwerriFeesAddressChanged(_msgSender(), _newAddress);
        return true;
    }

    function changeProcessingFeeNumeretor(uint256 _newNumeretor) external onlyOwner returns(bool success){
        processingFeeNumeretor = _newNumeretor;
        swerriVariables.processingFeeNumeretor = _newNumeretor;
        return true;
    }

    function changeMinimumContributionMultiple(uint _newMultiple) external onlyOwner returns(bool success){
        minimumContributionMultiple = _newMultiple;
        swerriVariables.minimumContributionMultiple = _newMultiple;
        return true;
    }

    function addInterestRate(uint _loanTime, uint _interestRate) external onlyOwner returns(bool success) {
        //        Interest rate is already there
        require(loanInterestRate[_loanTime] == 0, "IRIAT");
        loanInterestRate[_loanTime] = _interestRate;
        return true;
    }

    function changeInterestRate(uint _loanTime, uint _interestRate) external onlyOwner returns(bool success){
        //        Interest rate not found
        require(loanInterestRate[_loanTime] != 0, "IRNF");
        loanInterestRate[_loanTime] = _interestRate;
        return true;
    }

    function changeSwerriInterestShareNumeretor(uint _newNumeretor) external  onlyOwner returns(bool success){
        swerriInterestShareNumeretor = _newNumeretor;
        swerriVariables.swerriInterestShareNumeretor = _newNumeretor;
        return true;
    }

    function getNumberOfIterationsPassed(uint _circleId) external view returns(uint iterations){
        uint iterationTime = circleDetails[_circleId].contributionTimeIterations;
        uint timePassed = block.timestamp - iterationTime;
        uint noOfIterationsDone = timePassed/iterationTime;
        return noOfIterationsDone;
    }

    function convertBusdForSwetAndContribute(address _sender,uint _swetFigure, uint _contribution) internal returns(bool success){
        bool successApprove = IBEP20(busdInstance).approve(address(swetVendorInstance), _contribution);
        //        Approve failed
        require(successApprove, "AF");
        bool successSend = IBEP20(busdInstance).transferFrom(_sender, address(this), _contribution);
        //        Contribution Failed
        require(successSend, "CF");
        bool successBuy = SwerriVendor(swetVendorInstance).buySWET(_swetFigure);
        //        Buy failed
        require(successBuy, "BF");
        return true;
    }

    function setApprovedAndDisburseLoan(uint _loanId, uint _circleId) whenNotPaused internal returns(bool success){
        loanDetails[_loanId].status = "processed";
        loanTimeDetails[_loanId].dateApproved = block.timestamp;
        loanTimeDetails[_loanId].dateDisbursed = block.timestamp;
        string memory combinedString = combineKeyString(loanDetails[_loanId].borrower, _circleId, "circle");
        activeLoanInCurrentCircle[combinedString] = true;
        bool successSend = IBEP20(busdInstance).transfer(loanDetails[_loanId].borrower, loanDetails[_loanId].amountToReceive);
        //        loan failed
        require(successSend, "LF");
        emit LoanDisbursed(loanDetails[_loanId].borrower,loanDetails[_loanId].amountToReceive);
        bool successCollection = collectSwerriLoanFees(_loanId);
        //        fee collection failed
        require(successCollection, "FCF");
        circleDetails[_circleId].availableCircleBalance -= loanDetails[_loanId].guaranteedAmount;
        return true;
    }

    function collectSwerriLoanFees(uint _loanId) internal returns(bool success){
        uint loanInterest = loanInterestAmount[_loanId];
        uint loanProcessingFee = loanProcessingFeeAmount[_loanId];
        uint swerriInterestShare = (swerriVariables.swerriInterestShareNumeretor * loanInterest) / swerriVariables.denominator;
        uint totalSwerriFees = swerriInterestShare + loanProcessingFee;
        bool successSend = IBEP20(busdInstance).transfer(swerriVariables.swerriFeesAddress, totalSwerriFees);
        require(successSend, "FCF");
        return true;
    }

    function calculateAmountToReceiveAndAmountOwed(uint _loanId, uint _loanAmount, uint _loanLength) internal returns(bool success){
        amountToBePaid[_loanId] = _loanAmount;
        uint loanInterest = ((loanInterestRate[_loanLength] - swerriVariables.denominator) * _loanAmount) / swerriVariables.denominator;
        loanInterestAmount[_loanId] = loanInterest;
        uint loanProcessingFee = (_loanAmount * swerriVariables.processingFeeNumeretor) / swerriVariables.denominator;
        loanProcessingFeeAmount[_loanId] = loanProcessingFee;
        uint amountBorrowerReceives = _loanAmount - (loanInterest + loanProcessingFee);
        loanDetails[_loanId].amountToReceive = amountBorrowerReceives;
        return true;
    }

    function calculateAmountToBeGuaranteed(uint _loanId, uint _loanAmount, string memory _combinedCircleString) internal returns(bool success){
        uint individualsBal = individualsCircleDetails[_combinedCircleString].availableBalanceInCircle;
        uint amountNeeded = _loanAmount - individualsBal;
        loanDetails[_loanId].borrowerContributionAmount = individualsBal;
        loanDetails[_loanId].amountNeededToBeGuaranteed = amountNeeded;
        individualsCircleDetails[_combinedCircleString].availableBalanceInCircle -= individualsBal;
        circleDetails[loanDetails[_loanId].circleId].availableCircleBalance -= individualsBal;
        return true;
    }


    function checkAndGiveRightToVote(uint _circleId, address _sender) internal returns(bool success){
        string memory combinedString = combineKeyString(_sender, _circleId, "circle");
        uint iterationTime = circleDetails[_circleId].contributionTimeIterations;
        uint timePassed = block.timestamp - iterationTime;
        uint noOfIterationsDone = timePassed/iterationTime;
        uint contributionsShouldBe = noOfIterationsDone * circleDetails[_circleId].minContribution;
        uint contributionsMade = individualsCircleDetails[combinedString].balanceInCircle;
        if(contributionsMade >= contributionsShouldBe){
            rightToVote[combinedString] = true;
        }else{
            rightToVote[combinedString] = false;
        }
        return true;
    }

    function distributeGuarantorsInterest(uint _loanId) internal returns(bool success){
        uint loanInterest = loanInterestAmount[_loanId];
        uint swerriInterestShare = (swerriVariables.swerriInterestShareNumeretor * loanInterest) / swerriVariables.denominator;
        uint totalGuaranteed = loanDetails[_loanId].guaranteedAmount;
        uint amountOfInterestToBeShared = loanInterest - swerriInterestShare;
        circleDetails[loanDetails[_loanId].circleId].availableCircleBalance += amountOfInterestToBeShared;
        circleDetails[loanDetails[_loanId].circleId].circleBalance += amountOfInterestToBeShared;
        if(loanDetails[_loanId].loanType == 1){
            string memory combinedIndividualCircleString = combineKeyString(loanDetails[_loanId].borrower, loanDetails[_loanId].circleId, "circle");
            individualsCircleDetails[combinedIndividualCircleString].availableBalanceInCircle += amountOfInterestToBeShared;
            individualsCircleDetails[combinedIndividualCircleString].balanceInCircle += amountOfInterestToBeShared;
        }else if(loanDetails[_loanId].loanType == 3){
            for(uint i = 0; i < loanGuarantors[_loanId].length; i++){
                address currentAddress = loanGuarantors[_loanId][i];
                string memory combinedIndividualLoanString = combineKeyString(currentAddress, _loanId, "loan");
                uint individualAmountGuaranteed =  amountGuaranteedInCurrentLoan[combinedIndividualLoanString];
                uint amountToReceiveFromInterest = (individualAmountGuaranteed *  amountOfInterestToBeShared )/ (totalGuaranteed);
                string memory combinedIndividualCircleString = combineKeyString(currentAddress, loanDetails[_loanId].circleId, "circle");
                /// we just add the guarantors amount because their interest is not taken from the contract;
                individualsCircleDetails[combinedIndividualCircleString].availableBalanceInCircle += amountToReceiveFromInterest;
                individualsCircleDetails[combinedIndividualCircleString].balanceInCircle += amountToReceiveFromInterest;
            }
        }
        return true;
    }

    function markAsPaid(uint _loanId) internal returns(bool success){
        loanDetails[_loanId].status = "paid";
        loanDetails[_loanId].paid = true;
        loanTimeDetails[_loanId].dateRepaid = block.timestamp;
        string memory combinedString = combineKeyString(loanDetails[_loanId].borrower, loanDetails[_loanId].circleId, "circle");
        activeLoanInCurrentCircle[combinedString] = false;
        if(loanDetails[_loanId].loanType == 3 || loanDetails[_loanId].loanType == 1){
            bool successDistribution = distributeGuarantorsInterest(_loanId);
            //            interest distribution done
            require(successDistribution, "IDD");
        }
        return true;
    }

    function recalculateBalancesAfterRepayment(uint _loanId, uint _amount) whenNotPaused internal returns(bool success){
        /// loanTypes = individual/circle/members /1/2/3
        string memory combinedBorrowerCircleString = combineKeyString(loanDetails[_loanId].borrower, loanDetails[_loanId].circleId, "circle");
        circleDetails[loanDetails[_loanId].circleId].availableCircleBalance += _amount;
        if(loanDetails[_loanId].loanType == 1){
            individualsCircleDetails[combinedBorrowerCircleString].availableBalanceInCircle += _amount;
            return true;
        }else if(loanDetails[_loanId].loanType == 2){
            /// unclear on how to rebalance circle loans will be added later
            return true;
        }else if(loanDetails[_loanId].loanType == 3){
            uint totalGuaranteed = loanDetails[_loanId].guaranteedAmount;
            uint selfGuaranteedAmount = loanDetails[_loanId].borrowerContributionAmount;
            for(uint i = 0; i < loanGuarantors[_loanId].length; i++){
                address currentAddress = loanGuarantors[_loanId][i];
                string memory combinedIndividualLoanString = combineKeyString(currentAddress, _loanId, "loan");
                uint individualAmountGuaranteed =  amountGuaranteedInCurrentLoan[combinedIndividualLoanString];
                uint amountToReceiveFromRepayment = individualAmountGuaranteed * _amount / (totalGuaranteed + selfGuaranteedAmount);
                string memory combinedIndividualCircleString = combineKeyString(currentAddress, loanDetails[_loanId].circleId, "circle");
                individualsCircleDetails[combinedIndividualCircleString].availableBalanceInCircle += amountToReceiveFromRepayment;
            }
            return true;
        }
    }

    function checkRightToVote(uint _circleId, address _voter) external view returns(bool canVote){
        string memory combinedString = combineKeyString(_voter, _circleId, "circle");
        uint iterationTime = circleDetails[_circleId].contributionTimeIterations;
        uint timePassed = block.timestamp - iterationTime;
        uint noOfIterationsDone = timePassed/iterationTime;
        uint contributionsShouldBe = noOfIterationsDone * circleDetails[_circleId].minContribution;
        uint contributionsMade = individualsCircleDetails[combinedString].balanceInCircle;
        if(contributionsMade >= contributionsShouldBe){
            return true;
        }else{
            return false;
        }
    }

    function createCircle(uint256 _timeIterations, uint256 _minimumContribution, uint256 _contribution, uint256 _earningTimeIterartions) whenNotPaused onlyIfCircleDoesNotExist(circleId) external returns(bool success){
        string memory combinedString = combineKeyString(_msgSender(), circleId, "circle");
        uint contributionFigure = swerriVariables.numeretor * _contribution / swerriVariables.denominator;
        uint swetFigure = _contribution - contributionFigure;
        bool successContribution = convertBusdForSwetAndContribute(_msgSender(),swetFigure, _contribution);
        //        Creation contribution failed
        require(successContribution, "CCF");
        /// adding the caller to the circle based on id
        belongsToWhichCircle[combinedString] = circleId;
        /// adding circle details for the person who made the circle and adding their personal initial balance
        circleDetails[circleId] = CircleDetailsById(circleId,1,contributionFigure, _timeIterations, _minimumContribution, block.timestamp, contributionFigure, _earningTimeIterartions,0,swetFigure);
        /// adding the individuals circle details to the circle
        individualsCircleDetails[combinedString] = IndivudualsCircleDetails(circleId,contributionFigure,contributionFigure, block.timestamp, 0,swetFigure );
        /// adding them to the list of members of that specific circle
        membersOfCircle[circleId].push(_msgSender());
        /// adding the number of circles
        circleCount += 1;
        // giving the creator right to vote
        rightToVote[combinedString] = true;
        emit CircleCreated(_msgSender(), circleId, _minimumContribution, _timeIterations);
        /// adding the circleId
        circleId += 1 ;
        return true;
    }

    function createCircleViaMaster(uint _timeIterations, uint _minimumContribution, uint _contribution, address _creator, uint256 _earningTimeIterartions) whenNotPaused onlyIfCircleDoesNotExist(circleId) external returns(bool success){
        string memory combinedString = combineKeyString(_creator, circleId, "circle");
        uint contributionFigure = swerriVariables.numeretor * _contribution / swerriVariables.denominator;
        uint swetFigure = _contribution - contributionFigure;
        bool successContribution = convertBusdForSwetAndContribute(_msgSender(),swetFigure, _contribution);
        require(successContribution, "CCF");
        /// adding the caller to the circle based on id
        belongsToWhichCircle[combinedString] = circleId;
        /// adding circle details for the person who made the circle and adding their personal initial balance
        circleDetails[circleId] = CircleDetailsById(circleId,1,contributionFigure, _timeIterations, _minimumContribution, block.timestamp, contributionFigure, _earningTimeIterartions,0,swetFigure);
        /// adding the individuals circle details to the circle
        individualsCircleDetails[combinedString] = IndivudualsCircleDetails(circleId,contributionFigure,contributionFigure, block.timestamp, 0,swetFigure );
        /// adding them to the list of members of that specific circle
        membersOfCircle[circleId].push(_creator);
        /// adding the number of circles
        circleCount += 1;
        // giving the creator right to vote
        rightToVote[combinedString] = true;
        emit CircleCreated(_creator, circleId, _minimumContribution, _timeIterations);
        /// adding the circleId
        circleId += 1 ;
        // giving the creator right to vote
        rightToVote[combinedString] = true;
        return true;
    }

    function acceptInviteToNonContributing(uint _circleId) whenNotPaused onlyIfCircleExists(_circleId) onlyNonMember(_circleId, _msgSender())  external returns(bool success){
        string memory combinedString = combineKeyString(_msgSender(), _circleId, "circle");
        individualsCircleDetails[combinedString] = IndivudualsCircleDetails(_circleId,0,0, block.timestamp, 0,0 );
        belongsToWhichCircle[combinedString] = _circleId;
        circleDetails[_circleId].circleMemberCount ++;
        membersOfCircle[_circleId].push(_msgSender());
        return true;
    }

    /// @notice function to add a member to the created circle via master
    function acceptInviteToCircle(uint _circleId, uint _contribution) whenNotPaused onlyIfCircleExists(_circleId) onlyNonMember(_circleId, _msgSender()) onlyObserveMinimum(_contribution, _circleId)  external returns(bool success){
        string memory combinedString = combineKeyString(_msgSender(), _circleId, "circle");
        uint contributionFigure = swerriVariables.numeretor * _contribution / swerriVariables.denominator;
        uint swetFigure = _contribution - contributionFigure;
        bool successContribution = convertBusdForSwetAndContribute(_msgSender(),swetFigure, _contribution);
        require(successContribution, "CCF");
        /// adding the individuals circle details
        individualsCircleDetails[combinedString] = IndivudualsCircleDetails(_circleId,contributionFigure,contributionFigure, block.timestamp, 0,swetFigure );
        /// adding which circle they belong to based on id
        belongsToWhichCircle[combinedString] = _circleId;
        /// adding the amount of total members in that circle
        circleDetails[_circleId].circleMemberCount ++;
        /// adding the circles balance
        circleDetails[_circleId].circleBalance += contributionFigure;
        circleDetails[_circleId].availableCircleBalance  += contributionFigure;
        circleDetails[_circleId].circleSwetBalance += swetFigure;
        /// adding them to the list of members of that specific circle
        membersOfCircle[_circleId].push(_msgSender());
        // giving the creator right to vote
        rightToVote[combinedString] = true;
        return true;
    }

    /// @notice function to add a member to the created circle via master
    function acceptInviteToCircleViaMaster(uint _circleId, uint _contribution, address _belongsTo) whenNotPaused onlyNonMember( _circleId, _belongsTo) onlyObserveMinimum(_contribution, _circleId)  external returns(bool success){
        string memory combinedString = combineKeyString(_belongsTo, _circleId, "circle");
        uint contributionFigure = swerriVariables.numeretor * _contribution / swerriVariables.denominator;
        uint swetFigure = _contribution - contributionFigure;
        bool successContribution = convertBusdForSwetAndContribute(_msgSender(),swetFigure, _contribution);
        require(successContribution, "CCF");
        /// adding the individuals circle details
        individualsCircleDetails[combinedString] = IndivudualsCircleDetails(_circleId,contributionFigure,contributionFigure, block.timestamp, 0,swetFigure);
        /// adding which circle they belong to based on id
        belongsToWhichCircle[combinedString] = _circleId;
        /// adding the amount of total members in that circle
        circleDetails[_circleId].circleMemberCount ++;
        /// adding the circles balance
        circleDetails[_circleId].circleBalance += contributionFigure;
        circleDetails[_circleId].availableCircleBalance  += contributionFigure;
        circleDetails[_circleId].circleSwetBalance += swetFigure;
        /// adding them to the list of members of that specific circle
        membersOfCircle[_circleId].push(_msgSender());
        // giving the creator right to vote
        rightToVote[combinedString] = true;
        return true;
    }

    function contributeToCircle(uint _circleId, uint _contribution) whenNotPaused onlyIfCircleExists(_circleId) onlyCircleMember(_circleId, _msgSender()) onlyObserveMinimum(_contribution, _circleId)  external returns(bool success){
        uint contributionFigure = swerriVariables.numeretor * _contribution / swerriVariables.denominator;
        uint swetFigure = _contribution - contributionFigure;
        bool successContribution = convertBusdForSwetAndContribute(_msgSender(),swetFigure, _contribution);
        require(successContribution, "CCF");
        circleDetails[_circleId].circleBalance += contributionFigure;
        circleDetails[_circleId].availableCircleBalance  += contributionFigure;
        circleDetails[_circleId].circleSwetBalance += swetFigure;
        string memory combinedString = combineKeyString(_msgSender(), _circleId, "circle");
        individualsCircleDetails[combinedString].balanceInCircle += contributionFigure;
        individualsCircleDetails[combinedString].availableBalanceInCircle += contributionFigure;
        individualsCircleDetails[combinedString].swetBalance += swetFigure;
        bool successVotingRights = checkAndGiveRightToVote(_circleId, _msgSender());
        //        Voting Right failed
        require(successVotingRights, "VRF");
        return true;
    }

    function contributeToCircleViaMaster(uint _circleId, uint _contribution, address _belongsTo) whenNotPaused onlyIfCircleExists(_circleId) onlyCircleMember(_circleId, _belongsTo) onlyObserveMinimum(_contribution, _circleId) external returns(bool success){
        uint contributionFigure = swerriVariables.numeretor * _contribution / swerriVariables.denominator;
        uint swetFigure = _contribution - contributionFigure;
        bool successContribution = convertBusdForSwetAndContribute(_msgSender(),swetFigure, _contribution);
        require(successContribution, "CCF");
        circleDetails[_circleId].circleBalance += contributionFigure;
        circleDetails[_circleId].availableCircleBalance  += contributionFigure;
        circleDetails[_circleId].circleSwetBalance += swetFigure;
        string memory combinedString = combineKeyString(_belongsTo, _circleId, "circle");
        individualsCircleDetails[combinedString].balanceInCircle += contributionFigure;
        individualsCircleDetails[combinedString].availableBalanceInCircle += contributionFigure;
        individualsCircleDetails[combinedString].swetBalance += swetFigure;
        bool successVotingRights = checkAndGiveRightToVote(_circleId, _belongsTo);
        require(successVotingRights, "VRF");
        return true;
    }

    function guaranteeLoan(uint _circleId, uint _loanId, uint _amountToGuarantee) onlyIfCircleExists(_circleId) onlyCircleMember(_circleId, _msgSender()) external returns (bool success){
        //        Only for member loans
        require(loanDetails[_loanId].loanType == 3, "OFML");
        //        Borrower cannot guarantee themselves
        require(loanDetails[_loanId].borrower != _msgSender(), "BCGT");
        string memory combinedCircleString = combineKeyString(_msgSender(), _circleId, "circle");
        //        You have a loan
        require(activeLoanInCurrentCircle[combinedCircleString] == false, "YHAL");
        //        Not enough to guarantee this amount
        require(_amountToGuarantee <= individualsCircleDetails[combinedCircleString].availableBalanceInCircle, "NETTA");
        uint leftAmount = loanDetails[_loanId].amountNeededToBeGuaranteed - loanDetails[_loanId].guaranteedAmount;
        if(_amountToGuarantee > leftAmount){
            doGuaranteeLoan(combinedCircleString, _circleId, _loanId, _msgSender(), leftAmount);
            return true;
        }else{
            doGuaranteeLoan(combinedCircleString, _circleId, _loanId, _msgSender(), _amountToGuarantee);
            return true;
        }
    }

    function doGuaranteeLoan(string memory combinedCircleString, uint _circleId, uint _loanId, address _sender, uint _amountToGuarantee) internal{
        individualsCircleDetails[combinedCircleString].availableBalanceInCircle -= _amountToGuarantee;
        circleDetails[_circleId].availableCircleBalance  -= _amountToGuarantee;
        loanGuarantors[_loanId].push(_msgSender());
        string memory combinedLoanString = combineKeyString(_sender, _loanId, "loan");
        amountGuaranteedInCurrentLoan[combinedLoanString] = _amountToGuarantee;
        balanceUsedToGuarantee[combinedCircleString] += _amountToGuarantee;
        loanDetails[_loanId].guaranteedAmount += _amountToGuarantee;
        loanDetails[_loanId].noOfGuarantors ++;
        checkFullyGuaranteed(_loanId, _circleId);
    }

    function checkFullyGuaranteed(uint _loanId, uint _circleId) internal{
        if(loanDetails[_loanId].guaranteedAmount == loanDetails[_loanId].amountNeededToBeGuaranteed){
            bool disburse = setApprovedAndDisburseLoan(_loanId, _circleId);
            //            Loan Disbursment Failed
            require(disburse, "LDF");
        }
    }

    function repayLoan(uint _loanId, uint _amount) whenNotPaused external returns(bool success){
        uint amountRepaid = loanDetails[_loanId].amountRepaid;
        uint _amountToBePaid = amountToBePaid[_loanId];
        //        loan already paid for
        require(_amountToBePaid != amountRepaid, "LAPF");
        uint repaymentBalance = _amountToBePaid - amountRepaid;
        if(_amount > repaymentBalance){
            uint toBeContributed = _amount - repaymentBalance;
            doRepayment(_loanId, toBeContributed, repaymentBalance, _amount,_msgSender());
            return true;
        }else{
            doRepayment(_loanId, 0, _amount, _amount,_msgSender());
            return true;
        }
    }

    function doRepayment(uint _loanId, uint _contributionAmount, uint _repaymentAmount, uint _totalAmount, address _sender) internal{
        bool successSend = IBEP20(busdInstance).transferFrom(_sender, address(this), _totalAmount);
        //        repayment failed
        require(successSend, "RF");
        loanDetails[_loanId].amountRepaid += _repaymentAmount;
        circleDetails[loanDetails[_loanId].circleId].circleBalance += _contributionAmount;
        circleDetails[loanDetails[_loanId].circleId].availableCircleBalance  += _contributionAmount;
        string memory combinedString = combineKeyString(_sender, loanDetails[_loanId].circleId, "circle");
        individualsCircleDetails[combinedString].balanceInCircle += _contributionAmount;
        individualsCircleDetails[combinedString].availableBalanceInCircle += _contributionAmount;
        bool successRecalculation = recalculateBalancesAfterRepayment(_loanId, _totalAmount);
        //        Balance recalculation failure
        require(successRecalculation, "BRF");
        if((amountToBePaid[_loanId] - loanDetails[_loanId].amountRepaid) == 0){
            bool repaid = markAsPaid(_loanId);
            //            Marking as repayment failed
            require(repaid, "MARF");
        }
    }


    function createLoanRequest(uint _circleId, uint _loanAmount, uint _loanType, uint _loanLength) whenNotPaused onlyIfCircleExists(_circleId) onlyCircleMember(_circleId, _msgSender()) external returns (bool success) {
        /// loanTypes = individual/circle/members /1/2/3
        /// status processing/processed/paid/defaulted/rejected
        //        Loan length not available
        require(loanInterestRate[_loanLength] > 0, "LLNA");
        string memory combinedCircleString = combineKeyString(_msgSender(), _circleId, "circle");
        //        Not contributed enough to borrow this
        require(_loanAmount <= (individualsCircleDetails[combinedCircleString].balanceInCircle * minimumContributionMultiple), "NCETBT");
        //        You already have a loan
        require(activeLoanInCurrentCircle[combinedCircleString] == false, "YAHAL");
        if(_loanType == 1){
            //            Not contributed enough for an individual loan of this amount
            require(_loanAmount <= individualsCircleDetails[combinedCircleString].availableBalanceInCircle, "NCEFAILOTA");
            loanDetails[loanId] = LoanDetailsById(loanId, _circleId, _loanType,_loanAmount, 0, payable(_msgSender()),0, _loanAmount, _loanAmount,0,0,_loanLength,"processing",false);
            loanTimeDetails[loanId] = LoanTimesById(loanId, _circleId, block.timestamp,0,0,0,0);
            calculateAmountToReceiveAndAmountOwed(loanId, _loanAmount, _loanLength);
            bool disburse = setApprovedAndDisburseLoan(loanId, _circleId);
            //            Loan Disbursment Failed
            require(disburse, "LDF");
            individualsCircleDetails[combinedCircleString].availableBalanceInCircle -= _loanAmount;
            circleDetails[_circleId].availableCircleBalance -= _loanAmount;
            loanId++;
            return true;
        }else if(_loanType == 2){
            return true;
        }else if(_loanType == 3){
            loanDetails[loanId] = LoanDetailsById(loanId, _circleId, _loanType,_loanAmount, 0, payable(_msgSender()),0, 0, 0,0,0,_loanLength,"processing",false);
            loanTimeDetails[loanId] = LoanTimesById(loanId, _circleId, block.timestamp,0,0,0,0);
            calculateAmountToReceiveAndAmountOwed(loanId, _loanAmount, _loanLength);
            calculateAmountToBeGuaranteed(loanId, _loanAmount, combinedCircleString);
            loanId++;
            return true;
        }
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}