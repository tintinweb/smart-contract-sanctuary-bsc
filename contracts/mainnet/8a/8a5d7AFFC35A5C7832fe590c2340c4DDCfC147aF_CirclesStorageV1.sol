// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.14;

// Strings Library
import "@openzeppelin/contracts/utils/Strings.sol";
// Address Library
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
// Initializable Contract
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// Ownable Contract
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// UUPS Upgradeable Contract
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
//  AggregatorV3Interface contract interface
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


interface TransfersContract{
    function convertBusdForSwetBNBAndContribute(address _sender, uint _swetFigure, uint _gasFigure, uint _contribution) external returns (bool success);
    function _sendOutSwet(address payable _member, uint256 _amount) external;
    function _sendOutBusd(address payable _member, uint256 _amount) external;
}

/// BEP20 interface
interface IBEP20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

library CirclesStrings{
    function combineKeyString(address _sender, uint _id, string memory _identifier) public pure returns(string memory mappingKey){
        return string.concat('SWET',Strings.toHexString(uint160(_sender), 20), "#id", Strings.toString(_id), "id#", _identifier);
    }
}

contract CirclesStorageV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable{
    AggregatorV3Interface priceFeed;
    TransfersContract TC;
    address transferContract;
    using AddressUpgradeable for address;

    struct GlobalVariables{
        uint256 circleId;
        uint256 loanId;
        uint256 voteId;
        uint8 paused;
    }
    GlobalVariables public globals;

    struct AddressVariables{
        address feesAddress;
        address busdInstance;
        address swetInstance;
        address vendorInstance;
    }
    AddressVariables public addressVars;

    struct CalcVars{
        ///
        uint8 swetBusdRate;
        //
        uint16 gasNumeretor;
        /// cancelFeeNumeretor
        uint8 cancelFeeNumeretor;
        //minimumContributionMultiple
        uint8 minimumContributionMultiple;
        uint16 numeretor;
        uint16 denominator;
        // slippageNumeretor
        uint16 slippageNumeretor;
        //leavingCircleNumeretor
        uint16 leavingCircleNumeretor;
        //processingFeeNumeretor
        uint16 processingFeeNumeretor;
        //swerriInterestShareNumeretor
        uint16 swerriInterestShareNumeretor;
    }
    CalcVars public calcVars;

    struct CirclesById{
        uint256 circleBalance;
        //contributionTimeIterations
        uint256 contributionTimeIterations;
        //minimumContribution
        uint256 minimumContribution;
        //creationDate
        uint256 creationDate;
        //availableCircleBalance
        uint256 availableCircleBalance;
        //earningsTimeIterations
        uint256 earningsTimeIterations;
        //circleEarnings
        uint256 circleEarnings;
        //circleSwetBalance
        uint256 circleSwetBalance;
    }

    struct IndivudualsCircleDetails{
        uint256 circleId;
        //balanceInCircle
        uint256 balanceInCircle;
        //availableBalanceInCircle
        uint256 availableBalanceInCircle;
        uint256 dateJoined;
        //individualEarnings
        uint256 individualEarnings;
        //swetBalance
        uint256 swetBalance;
    }

    struct LoanById{
        uint256 circleId;
        uint8 loanType;
        uint256 loanAmount;
        uint256 amountToReceive;
        address payable borrower;
        //amountNeededToBeGuaranteed
        uint256 amountNeededToBeGuaranteed;
        // borrowerContributionAmount
        uint256 borrowerContributionAmount;
        //guaranteedAmount
        uint256 guaranteedAmount;
        //amountRepaid
        uint256 amountRepaid;
        uint256 loanlength;
        uint8 status;
        // status 1:processing/2:processed/3:paid/4:defaulted/5:rejected/6:canceled
        //  0 is false 1 is true
        uint8 paid;
    }

    struct LoanTimesById{
        uint256 circleId;
        uint256 requested;
        uint256 dApproved;
        uint256 dRejected;
        uint256 dDisbursed;
        uint256 dRepaid;
    }

    //  0 is false 1 is true
    mapping(uint => uint8) public Loanrepaid;
    mapping(string => uint256) public amountGuaranteedInCurrentLoan;
    mapping(uint256 => uint256) public amountToBePaid;
    mapping(uint256 => uint256) public loanInterestAmount;
    mapping(uint256 => address[]) public loanGuarantors;
    mapping(uint256 => LoanById) public loanDetails;
    mapping(uint256 => uint256) public loanProcessingFeeAmount;
    mapping(uint256 => LoanTimesById) public loanTimeDetails;

    mapping(string => uint256) public positionInMemberArray;
    mapping(uint256 => CirclesById) public circleDetails;
    mapping(string => IndivudualsCircleDetails) public individualsCircleDetails;

    //  0 is false 1 is true
    mapping(string => uint8) public activeLoanInCurrentCircle;
    mapping(string => uint256) public balanceUsedToGuarantee;
    mapping(string => uint256) public belongsToWhichCircle;
    mapping(uint256 => address[]) public members;
    mapping(uint => uint) public loanInterestRate;
    mapping(address => uint) public whitelist;

    mapping(address => bool) public isTc;
    mapping(string => uint) public lastEarningInteraction;

    event Paused(address indexed byWho);
    event Unpaused(address indexed byWho);

    modifier onlyWhitelist(){
        _isWhitelistMember(_msgSender());
        _;
    }

    modifier onlyTransferContract(){
        _isInitiatorContract(_msgSender());
        _;
    }

    function initialize ()  public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        globals.loanId = 1;
        globals.circleId = 1;
        globals.voteId = 1;
        calcVars.numeretor = 1000;
        calcVars.swetBusdRate = 2;
        calcVars.denominator = 1000;
        calcVars.slippageNumeretor = 50;
        calcVars.gasNumeretor = 1000;// 950 changed to 1000 until we can change the address
        calcVars.cancelFeeNumeretor = 10;
        calcVars.processingFeeNumeretor = 20;
        calcVars.leavingCircleNumeretor = 200;
        calcVars.minimumContributionMultiple = 3;
        calcVars.swerriInterestShareNumeretor = 30;
        addressVars.swetInstance = 0x390F2c8D6DC2eEEAE043e0EA08e4C3b37D2BADB9;
        addressVars.busdInstance = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        addressVars.feesAddress = 0x0782CD85D4a0E23c15dF6B33076d9DbC0800EbB3;
        addressVars.vendorInstance = 0x6e061C50b0532A18E9c91B72F9F82Bdc2d24F080;
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    }

    ///@dev return string means Not Paused
    function _isPaused() external view{
        require(globals.paused == 1, "NP");
    }

    ///@dev return string means Member already in circle
    function _isNotCircleMember(uint _circleId, address _address) external view{
        require(belongsToWhichCircle[CirclesStrings.combineKeyString(_address, _circleId, "circle")] == 0, "MAIC");
    }

    ////@dev return string means Circle with this ID already exists
    function _doesCircleNotExist(uint _circleId) external view{
        require(members[_circleId].length < 1, "CWTIAE");
    }

    ///@dev return string means Below minimum contribution
    function _doesObservesMinimum(uint _contribution, uint _circleId) external view{
        require(_contribution >= circleDetails[_circleId].minimumContribution, "BMC");
    }

    ///@dev return string means Not a member of this circle
    function _isCircleMember(uint _circleId, address _address) external view{
        require(belongsToWhichCircle[CirclesStrings.combineKeyString(_address, _circleId, "circle")] == _circleId, "NAMOTC");
    }

    //@dev return string means Paused
    function _isNotPaused() external view{
        require(globals.paused == 0, "P");
    }

    ///@dev return string means Circle does not exist
    function _doesCircleExist(uint _circleId) external view{
        require(members[_circleId].length > 0, "CDNE");
    }

    function changegN(uint16 _newNumeretor) external onlyOwner{
        calcVars.gasNumeretor = _newNumeretor;
    }

    function changeBUSDInstance(address _newAddress) external onlyOwner{
        addressVars.busdInstance = _newAddress;
    }

    function changeSWETInstance(address _newAddress) external onlyOwner{
        addressVars.swetInstance = _newAddress;
    }

    function changeVendorInstance(address _newAddress) external onlyOwner{
        addressVars.vendorInstance = _newAddress;
    }

    function changesBR(uint8 _newRate) external onlyOwner{
        calcVars.swetBusdRate =_newRate;
    }

    function changeNumeretor(uint16 _newNumeretor) external onlyOwner{
        calcVars.numeretor =_newNumeretor;
    }

    function changeDenominator(uint16 _newDenominator) external onlyOwner{
        calcVars.denominator =_newDenominator;
    }

    function changefeesAddress(address _newAddress) external onlyOwner{
        addressVars.feesAddress = _newAddress;
    }

    function changepFN(uint16 _newNumeretor) external onlyOwner{
        calcVars.processingFeeNumeretor = _newNumeretor;
    }

    function changemCN(uint8 _newMultiple) external onlyOwner{
        calcVars.minimumContributionMultiple = _newMultiple;
    }

    function addInterestRate(uint _loanTime, uint _interestRate) external onlyOwner{
        require(loanInterestRate[_loanTime] == 0, "IRIAT");
        loanInterestRate[_loanTime] = _interestRate;
    }

    function changeInterestRate(uint _loanTime, uint _interestRate) external onlyOwner{
        require(loanInterestRate[_loanTime] != 0, "IRNF");
        loanInterestRate[_loanTime] = _interestRate;
    }

    function changesISN(uint16 _newNumeretor) external  onlyOwner{
        calcVars.swerriInterestShareNumeretor = _newNumeretor;
    }

    function changelCN(uint16 _newNumeretor) external onlyOwner {
        calcVars.leavingCircleNumeretor = _newNumeretor;
    }

    function addWhitelistMember(address _newMember) external onlyOwner {
        require(checkIfContract(_newMember), "Externally Owned Accounts cannot be whitelisted");
        require(whitelist[_newMember] == 0, "AWM");
        whitelist[_newMember] = 1;
    }

    function revokeWhitelistMembership(address _member) external onlyOwner {
        require(whitelist[_member] == 1, "NAWM");
        whitelist[_member] = 0;
    }

    function checkIfContract(address _addr) public view returns(bool isContract){
        return _addr.isContract();
    }

    function increaseCircleId() external onlyWhitelist {
        globals.circleId ++;
    }

    function increaseLoanId() external onlyWhitelist {
        globals.loanId ++;
    }

    function increaseVoteId() external onlyWhitelist {
        globals.voteId ++;
    }

    function setTransferContract(address _transferContractAddress) external onlyOwner{
        require(checkIfContract(_transferContractAddress), "Externally Owned Accounts cannot be the TC");
        require(!isTc[_transferContractAddress], "Already the TC");
        isTc[_transferContractAddress] = true;
        transferContract = _transferContractAddress;
        TC = TransfersContract(_transferContractAddress);
    }

    function getLatestBNBPrice() external view returns (int) {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    function setBelongsToWhichCircle(string memory _keyString, uint _circleId) external onlyWhitelist {
        belongsToWhichCircle[_keyString] = _circleId;
    }

    function addToMemberList(address _newMember, uint256 _circleId) external onlyWhitelist {
        members[_circleId].push(_newMember);
    }

    function getMemberArrayLength(uint256 _circleId) external view returns (uint length){
        return members[_circleId].length;
    }

    function getGuaratorsArrayLength(uint _loanId) external view returns(uint length){
        return loanGuarantors[_loanId].length;
    }

    function setPositionInMemberArray(string memory _keyString, uint256 _index) external onlyWhitelist {
        positionInMemberArray[_keyString] = _index;
    }

    function addIndivBalInCircle(string memory _keyString, uint _amount) external onlyWhitelist{
        individualsCircleDetails[_keyString].balanceInCircle += _amount;
    }

    function reduceIndivBalInCircle(string memory _keyString, uint _amount) external onlyWhitelist {
        individualsCircleDetails[_keyString].balanceInCircle -= _amount;
    }

    function addIndivAvailBal(string memory _keyString, uint _amount) external onlyWhitelist {
        individualsCircleDetails[_keyString].availableBalanceInCircle += _amount;
    }

    function reduceIndivAvailBal(string memory _keyString, uint _amount) external onlyWhitelist {
        individualsCircleDetails[_keyString].availableBalanceInCircle -= _amount;
    }

    function _initiateNeededIndividualStructs(uint256 _circleId, uint256 _contributionFigure, string memory _combinedString, uint256 _swetFigure) external onlyWhitelist{
        individualsCircleDetails[_combinedString].circleId = _circleId;
        individualsCircleDetails[_combinedString].balanceInCircle = _contributionFigure;
        individualsCircleDetails[_combinedString].availableBalanceInCircle = _contributionFigure;
        individualsCircleDetails[_combinedString].dateJoined = block.timestamp;
        individualsCircleDetails[_combinedString].individualEarnings = 0;
        individualsCircleDetails[_combinedString].swetBalance = _swetFigure;
    }

    function _initiateNeededCircleStructs(uint256 _timeIterations, uint256 _minimumContribution, uint256 _earningTimeIterartions, uint256 _contributionFigure, uint256 _swetFigure) external onlyWhitelist{
        circleDetails[globals.circleId].creationDate = block.timestamp;
        circleDetails[globals.circleId].circleSwetBalance = _swetFigure;
        circleDetails[globals.circleId].circleBalance = _contributionFigure;
        circleDetails[globals.circleId].minimumContribution = _minimumContribution;
        circleDetails[globals.circleId].availableCircleBalance = _contributionFigure;
        circleDetails[globals.circleId].contributionTimeIterations = _timeIterations;
        circleDetails[globals.circleId].earningsTimeIterations= _earningTimeIterartions;
    }

    function _updateCircleStructsOnContribution(uint _circleId, uint _contribution, uint _swetContribution) external onlyWhitelist {
        circleDetails[_circleId].circleBalance += _contribution;
        circleDetails[_circleId].availableCircleBalance  += _contribution;
        circleDetails[_circleId].circleSwetBalance += _swetContribution;
    }

    function addAvailCircleBalance(uint _circleId, uint _amount) external onlyWhitelist {
        circleDetails[_circleId].availableCircleBalance += _amount;
    }

    function addCircleBalance(uint _circleId, uint _amount) external onlyWhitelist {
        circleDetails[_circleId].circleBalance += _amount;
    }

    function reduceAvailCircleBalance(uint _circleId, uint _amount) external onlyWhitelist{
        circleDetails[_circleId].availableCircleBalance -= _amount;
    }

    function removeMember(uint _circleId, string memory _keyString) external onlyWhitelist{
        belongsToWhichCircle[_keyString] = 0;
        uint index = positionInMemberArray[_keyString];
        members[_circleId][index] = members[_circleId][members[_circleId].length - 1];
        members[_circleId].pop();
    }

    function addIndivEarnings(string memory _keyString, uint _amount) external onlyWhitelist{
        individualsCircleDetails[_keyString].individualEarnings += _amount;
    }

    function reduceIndivEarnings(string memory _keyString, uint _amount) external onlyWhitelist{
        individualsCircleDetails[_keyString].individualEarnings -= _amount;
    }

    function setActiveLoanInCurrentCircle(string memory _keyString, uint8 _value) external onlyWhitelist{
        activeLoanInCurrentCircle[_keyString] = _value;
    }

    function addBalanceUsedToGuarantee(string memory _keyString, uint _amount) external onlyWhitelist{
        balanceUsedToGuarantee[_keyString] += _amount;
    }

    function reduceBalanceUsedToGuarantee(string memory _keyString, uint _amount) external onlyWhitelist{
        balanceUsedToGuarantee[_keyString] -= _amount;
    }

    function addIndivSwetBalance(string memory _keyString, uint _amount) external onlyWhitelist{
        individualsCircleDetails[_keyString].swetBalance += _amount;
    }

    function reduceIndivSwetBalance(string memory _keyString, uint _amount) external onlyWhitelist{
        individualsCircleDetails[_keyString].swetBalance -= _amount;
    }

    function addCircleSwetBalance(uint _circleId, uint _amount) external onlyWhitelist{
        circleDetails[_circleId].circleSwetBalance += _amount;
    }

    function reduceCircleSwetBalance(uint _circleId, uint _amount)external onlyWhitelist{
        circleDetails[_circleId].circleSwetBalance -= _amount;
    }

    function reduceCircleBalance(uint _circleId, uint _amount)external onlyWhitelist{
        circleDetails[_circleId].circleBalance -= _amount;
    }

    function _initiateLoanStructs(uint8 _loanType, uint _circleId, uint _loanAmount, address _borrower, uint _bCA, uint _gA, uint _loanLength) external onlyWhitelist{
        loanDetails[globals.loanId].circleId = _circleId;
        loanDetails[globals.loanId].loanType = _loanType;
        loanDetails[globals.loanId].loanAmount = _loanAmount;
        loanDetails[globals.loanId].borrower = payable(_borrower);
        loanDetails[globals.loanId].borrowerContributionAmount = _bCA;
        loanDetails[globals.loanId].guaranteedAmount = _gA;
        loanDetails[globals.loanId].loanlength = _loanLength;
        loanTimeDetails[globals.loanId].requested = block.timestamp;
        loanTimeDetails[globals.loanId].circleId = _circleId;
        loanDetails[globals.loanId].status = 1;
    }

    function setAmountToBePaid(uint _loanId, uint _amount) external onlyWhitelist{
        amountToBePaid[_loanId] = _amount;
    }

    function setLoanInterestAmount(uint _loanId, uint _amount) external onlyWhitelist{
        loanInterestAmount[_loanId] = _amount;
    }

    function setLoanProcessingFeeAmount(uint _loanId, uint _amount) external onlyWhitelist{
        loanProcessingFeeAmount[_loanId] = _amount;
    }

    function addLoanGuarantors(uint _loanId,address _guarantor) external onlyWhitelist{
        loanGuarantors[_loanId].push(_guarantor);
    }

    function addAmountGuaranteedInLoan(string memory _keyString, uint _amount) external onlyWhitelist{
        amountGuaranteedInCurrentLoan[_keyString] += _amount;
    }

    function setAmountGuaranteedInLoan(string memory _keyString, uint _amount) external onlyWhitelist{
        amountGuaranteedInCurrentLoan[_keyString] = _amount;
    }

    function addAmountGuaranteed(uint _loanId, uint _amount) external onlyWhitelist{
        loanDetails[_loanId].guaranteedAmount += _amount;
    }

    function addAmountRepaid(uint _loanId, uint _amount) external onlyWhitelist{
        loanDetails[_loanId].amountRepaid +=_amount;
    }

    function getKeyString(address _sender, uint _id, string memory _identifier) external pure returns(string memory keyString){
        return CirclesStrings.combineKeyString(_sender, _id, _identifier);
    }

    function approveTransferContractBUSDSpend(uint _amount) external onlyTransferContract returns(bool success){
        IBEP20(addressVars.busdInstance).approve(transferContract,_amount);
        return true;
    }

    function approveTransferContractSWETSpend(uint _amount) external onlyTransferContract returns(bool success){
        IBEP20(addressVars.swetInstance).approve(transferContract,_amount);
        return true;
    }

    function initateBUSDTransfer(address payable _receipient, uint _amount) external onlyTransferContract{
        IBEP20(addressVars.busdInstance).transfer(_receipient,_amount);
    }

    function initateSWETTransfer(address payable _receipient, uint _amount) external onlyTransferContract{
        IBEP20(addressVars.swetInstance).transfer(_receipient,_amount);
    }

    function setBorrowerContributionAmount(uint _loanId, uint _amount) external{
        loanDetails[_loanId].borrowerContributionAmount = _amount;
    }

    function setAmountNeededToBeGuaranteed(uint _loanId, uint _amount) external onlyWhitelist{
        loanDetails[_loanId].amountNeededToBeGuaranteed = _amount;
    }

    function setRepaid(uint _loanId,uint _date) external onlyWhitelist{
        loanTimeDetails[_loanId].dRepaid = _date;
        loanDetails[_loanId].status = 3;
        loanDetails[_loanId].paid = 1;
        Loanrepaid[_loanId] = 1;

    }

    function setDateApproved(uint _loanId,uint _date) external onlyWhitelist{
        loanTimeDetails[_loanId].dApproved = _date;
    }

    function setDisbursed(uint _loanId,uint _date) external onlyWhitelist{
        loanTimeDetails[_loanId].dDisbursed = _date;
        loanDetails[_loanId].status = 2;
    }

    function setAmountToReceive(uint _loanId, uint _amount) external onlyWhitelist{
        loanDetails[_loanId].amountToReceive = _amount;
    }


    function setLoanStatus(uint _loanId, uint8 _status) external onlyWhitelist{
        loanDetails[_loanId].status = _status;
    }

    function getLoanGuarantor(uint _loanId, uint _index) external view returns(address guarantor){
        return loanGuarantors[_loanId][_index];
    }

    function getCircleMember(uint _circleId, uint _index) external view returns(address member){
        return members[_circleId][_index];
    }


    function setPaused(uint8 _paused, uint8 _attack) external onlyOwner{
        globals.paused = _paused;
        if (_paused == 1) {
            emit Paused(_msgSender());
        } else {
            emit Unpaused(_msgSender());
        }
        if (_paused == 1 && _attack == 1) {
            defendContributions();
        }
    }

    function setLastEarningInteraction(string memory _keyString, uint _dateTime) external onlyWhitelist{
        lastEarningInteraction[_keyString] = _dateTime;
    }

    //return string means not whitelist member
    function _isWhitelistMember(address _sender) public view{
        require(whitelist[_sender] == 1, "NWM");
    }

    function _isInitiatorContract(address _sender) internal view{
        require(checkIfContract(_sender), "Externally Owned Accounts cannot be the TC");
        require(isTc[_sender], "Not the TC");
    }

    function defendContributions() internal {
        for (uint i=1; i < globals.circleId; i++) {
            for (uint n=0; n < members[i].length; n++) {
                string memory individualCircleString = CirclesStrings.combineKeyString(members[i][n], i, "circle");
                uint busdBalance = individualsCircleDetails[individualCircleString].availableBalanceInCircle;
                uint swetBalance = individualsCircleDetails[individualCircleString].swetBalance;
                if(busdBalance > 0){
                    TC._sendOutBusd(payable(members[i][n]), busdBalance);
                }
                if(swetBalance > 0){
                    TC._sendOutSwet(payable(members[i][n]), swetBalance);
                }
            }
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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