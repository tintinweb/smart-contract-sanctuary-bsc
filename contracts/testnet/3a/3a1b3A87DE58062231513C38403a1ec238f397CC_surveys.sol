//SPDX-License-Identifier: mit
pragma solidity ^0.8.0;

import "Ownable.sol";
import "IERC20.sol";
import "Counters.sol";
import "SafeMath.sol";
import "AggregatorV3Interface.sol";

contract surveys is Ownable {
    using SafeMath for uint256;
    // Using counters auto increment utils
    using Counters for Counters.Counter;
    Counters.Counter private _surveyPlanIDs;
    Counters.Counter private _surveyIDs;
    Counters.Counter private _answerIDs;

    // V3
    AggregatorV3Interface internal priceFeed;

    // Validation metrics
    mapping(address => bool) isValidator;
    mapping(address => bool) isKYCVerified;
    mapping(address => mapping(uint256 => bool)) private surveyParticipants;
    //address, surveyID, answerID
    mapping(address => mapping(uint256 => mapping(uint256 => bool)))
        private validatorParticipants;

    mapping(address => uint256) valaidatorEarnings;
    mapping(address => uint256) providerEarnings;

    //Mapping users address to survey ID and balance
    mapping(uint256 => uint256) public surveyBalance;
    mapping(uint256 => uint256) public surveyValidatorsBalance;
    mapping(uint256 => uint256) public surveyParticipantsBalance;
    mapping(uint256 => uint256) public amountEachSurveyValidatorEarns;
    mapping(uint256 => uint256) public amountEachSurveyParticipantEarns;
    //surveybalance[msg.sender][_surveyID] = balance;
    uint256 private platformCommision;
    //Validators address => surveyID => Balance
    mapping(address => mapping(uint256 => uint256)) public validatorsProfit;

    IERC20 public sonergyToken;

    // Survey Plans
    // Prep requirements for adding survey plans
    struct SurveyPlans {
        uint256 planID;
        string planName;
        uint256 minAmount;
        uint256 validatorsProfit;
        uint256 providerProfit;
        bool status;
    }

    mapping(uint256 => SurveyPlans) listOfPlans;

    event planCreated(
        uint256 planID,
        string planName,
        uint256 minAmount,
        uint256 validatorsProfit,
        uint256 providerProfit,
        bool status
    );

    // Validators Registration fees
    uint256 public validatorsFee;
    uint256 public kycVerificationFee;
    address private commisionAddress;

    event kycStatus(address _user, bool isVerified);

    struct SurveyItem {
        string surveyURI;
        address payable owner;
        uint256 surveyID;
        uint256 planID;
        uint256 numOfValidators;
        uint256 numOfcommisioners;
        uint256 numOfresponse;
        uint256 amount;
        bool nftStatus;
        bool exist;
        bool completed;
    }

    // mapping the surveyIDs to the number of existing answers
    mapping(uint256 => uint256) numberOfAnswers;
    //Mapping address to surveys
    mapping(uint256 => SurveyItem) listOfSurveys;

    event SurveyItemCreated(
        string surveyURI,
        address owner,
        uint256 surveyID,
        uint256 planID,
        uint256 numOfValidators,
        uint256 numOfcommisioners,
        uint256 numOfresponse,
        uint256 amount,
        bool nftStatus,
        bool exist,
        bool completed
    );

    struct AnswerItem {
        string answerURI;
        address payable provider;
        address payable validator;
        uint256 surveyID;
        uint256 answerID;
        bool isValidated;
        bool isValid;
    }

    //surveyID'S to answerid
    mapping(uint256 => AnswerItem) listOfAnswers;
    //Users => surveyID's => true

    event AnswerCreated(
        string surveyURI,
        address provider,
        address validator,
        uint256 surveyID,
        uint256 answerID,
        bool isValidated,
        bool isValid
    );

    constructor(
        address _tokenAddress,
        address _commisionAddress,
        address _priceFeedAddress
    ) {
        sonergyToken = IERC20(_tokenAddress);
        commisionAddress = _commisionAddress;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function updateValidatorsFee(uint256 _validatorsFee) public onlyOwner {
        validatorsFee = getSurveyFee(_validatorsFee);
    }

    function updateKYCFee(uint256 _kycVerificationFee) public onlyOwner {
        kycVerificationFee = getSurveyFee(_kycVerificationFee);
    }

    function addSurveyPlans(
        string memory _planName,
        uint256 _minAmount,
        uint256 _validatorsPercentProfit,
        uint256 _providerProfit,
        bool _display
    ) public onlyOwner {
        _surveyPlanIDs.increment();
        uint256 newPlanID = _surveyPlanIDs.current();

        uint256 priceOfPlan = getSurveyFee(_minAmount);

        listOfPlans[newPlanID] = SurveyPlans(
            newPlanID,
            _planName,
            priceOfPlan,
            _validatorsPercentProfit,
            _providerProfit,
            _display
        );

        emit planCreated(
            newPlanID,
            _planName,
            priceOfPlan,
            _validatorsPercentProfit,
            _providerProfit,
            _display
        );
    }

    function getSurveyFee(uint256 usdEntryFee) public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();

        uint256 adjustedprice = uint256(price) * 10**10;

        uint256 usdFee = usdEntryFee * (10**18);

        uint256 costToEnter = (usdFee * 10**18) / adjustedprice;
        return costToEnter;
    }

    function fetchSurveyPlans() public view returns (SurveyPlans[] memory) {
        uint256 totalPlansCount = _surveyPlanIDs.current();
        uint256 itemIndex = 0;

        SurveyPlans[] memory items = new SurveyPlans[](totalPlansCount);
        // Looping through the Plans and returning the active ones
        for (uint256 i = 0; i < totalPlansCount; i++) {
            if (listOfPlans[i + 1].status == true) {
                uint256 currentID = i + 1;
                SurveyPlans storage currentPlan = listOfPlans[currentID];
                items[itemIndex] = currentPlan;
                itemIndex += 1;
            }
        }

        return items;
    }

    function editSurveyPlan(
        uint256 _planID,
        string memory _planName,
        uint256 _minAmount,
        uint256 _validatorsPercentProfit,
        uint256 _providerProfit,
        bool _display
    ) public onlyOwner {
        uint256 priceOfPlan = getSurveyFee(_minAmount);

        listOfPlans[_planID] = SurveyPlans(
            _planID,
            _planName,
            priceOfPlan,
            _validatorsPercentProfit,
            _providerProfit,
            _display
        );

        emit planCreated(
            _planID,
            _planName,
            priceOfPlan,
            _validatorsPercentProfit,
            _providerProfit,
            _display
        );
    }

    function verifyUser() public {
        require(isKYCVerified[msg.sender], "You are already verified");
        require(
            sonergyToken.allowance(msg.sender, address(this)) >=
                kycVerificationFee,
            "Non-sufficient funds to complete KYC"
        );
        isKYCVerified[msg.sender] == true;
        emit kycStatus(msg.sender, true);
    }

    function checkKYCStatus(address _user) public view returns (bool) {
        return isKYCVerified[_user];
    }

    function enrollForSurvey(
        string memory surveyURI,
        address _user,
        uint256 _planID,
        uint256 _numOfValidators,
        uint256 _numOfcommisioners,
        uint256 _amount
    ) public payable {
        // get plan details
        require(
            _planExist(_planID) != false,
            "The Plan entered does not exist or its suspended. "
        );

        uint256 planAmount = listOfPlans[_planID].minAmount;

        require(
            _amount >= planAmount,
            "Amount must be greater then the plan Amount"
        );
        require(
            !isKYCVerified[_user],
            "You need to be verified to add a survey."
        );

        require(
            sonergyToken.allowance(msg.sender, address(this)) >= _amount,
            "Insufficient Sonergy Tokens Available"
        );

        // Initiate funds transfer.
        require(
            sonergyToken.transferFrom(msg.sender, address(this), _amount),
            "Failed to transfer Funds "
        );

        _surveyIDs.increment();
        uint256 newSurveyID = _surveyIDs.current();
        splitFunds(
            _amount,
            _planID,
            newSurveyID,
            _numOfcommisioners,
            _numOfValidators
        );

        // Create a balance for the survey
        listOfSurveys[newSurveyID] = SurveyItem(
            surveyURI,
            payable(msg.sender),
            newSurveyID,
            _planID,
            _numOfValidators,
            _numOfcommisioners,
            0,
            _amount,
            false,
            true,
            false
        );

        // Create number of validators and answer providers

        emit SurveyItemCreated(
            surveyURI,
            payable(msg.sender),
            newSurveyID,
            _planID,
            _numOfValidators,
            _numOfcommisioners,
            0,
            _amount,
            false,
            true,
            false
        );
    }

    function getAmountToEarn(uint256 _surveyId)
        public
        view
        returns (uint256, uint256)
    {
        return (
            amountEachSurveyValidatorEarns[_surveyId],
            amountEachSurveyParticipantEarns[_surveyId]
        );
    }

    function fetchMYSurveys() public view returns (SurveyItem[] memory) {
        uint256 totalSurveyCount = _surveyIDs.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        SurveyItem[] memory items = new SurveyItem[](itemCount);

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].owner == msg.sender) {
                uint256 currentID = i + 1;
                SurveyItem storage currentItem = listOfSurveys[currentID];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchAvailableSurveys() public view returns (SurveyItem[] memory) {
        uint256 totalSurveyCount = _surveyIDs.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].completed == false) {
                itemCount += 1;
            }
        }

        SurveyItem[] memory items = new SurveyItem[](itemCount);

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].completed == false) {
                uint256 currentID = i + 1;
                SurveyItem storage currentItem = listOfSurveys[currentID];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchNFTSurveys() public view returns (SurveyItem[] memory) {
        uint256 totalSurveyCount = _surveyIDs.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].nftStatus == true) {
                itemCount += 1;
            }
        }

        SurveyItem[] memory items = new SurveyItem[](itemCount);

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].nftStatus == true) {
                uint256 currentID = i + 1;
                SurveyItem storage currentItem = listOfSurveys[currentID];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyCompletedSurveys()
        public
        view
        returns (SurveyItem[] memory)
    {
        uint256 totalSurveyCount = _surveyIDs.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].completed == true) {
                itemCount += 1;
            }
        }

        SurveyItem[] memory items = new SurveyItem[](itemCount);

        for (uint256 i = 0; i < totalSurveyCount; i++) {
            if (listOfSurveys[i + 1].completed == true) {
                uint256 currentID = i + 1;
                SurveyItem storage currentItem = listOfSurveys[currentID];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function provideAnswer(uint256 _surveyID, string memory answerURI) public {
        //Check if survey exist
        require(_surveyExist(_surveyID), "Survey ID does not exist on Sonergy");
        // Check if number of answers are complete
        require(
            checkNumberOfAnswers(_surveyID),
            "This survey is already completed"
        );

        require(
            !hasParticipated(_surveyID, msg.sender),
            "You cannot Provide an answer again to this survey"
        );
        // Check if its a KYC Certified user
        // Check number of Sonergy Tokens held
        // Provide Answer
        // Check if you have provided answers already

        surveyParticipants[msg.sender][_surveyID] = true;
        // require(hasProviderAnswer)
        listOfSurveys[_surveyID].numOfresponse += 1;

        _answerIDs.increment();
        uint256 newAnswerID = _answerIDs.current();
        listOfAnswers[newAnswerID] = AnswerItem(
            answerURI,
            payable(msg.sender),
            payable(address(0)),
            _surveyID,
            newAnswerID,
            false,
            false
        );

        sendProviderFunds(msg.sender, _surveyID);

        emit AnswerCreated(
            answerURI,
            payable(msg.sender),
            payable(address(0)),
            _surveyID,
            newAnswerID,
            false,
            false
        );
    }

    function fetchSurveyAnswers(uint256 _surveyID)
        public
        view
        returns (AnswerItem[] memory)
    {
        uint256 totalAnswersCount = _answerIDs.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        uint256 theSurveyId = _surveyID;

        for (uint256 i = 0; i < totalAnswersCount; i++) {
            if (listOfAnswers[i + 1].surveyID == theSurveyId) {
                itemCount += 1;
            }
        }

        AnswerItem[] memory items = new AnswerItem[](itemCount);

        for (uint256 i = 0; i < totalAnswersCount; i++) {
            if (listOfAnswers[i + 1].surveyID == _surveyID) {
                uint256 currentID = i + 1;
                AnswerItem storage currentItem = listOfAnswers[currentID];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function hasParticipated(uint256 _surveyID, address _user)
        internal
        view
        returns (bool)
    {
        if (surveyParticipants[_user][_surveyID]) {
            return true;
        }
        return false;
    }

    function validateAnswer(
        uint256 _answerID,
        uint256 _surveyID,
        bool _isValid
    ) public {
        //Check if its validator
        require(
            sonergyToken.allowance(msg.sender, address(this)) >= validatorsFee,
            "You dont have the required number of SNERY tokens to be a validator."
        );

        require(
            hasValidated(_surveyID, msg.sender),
            "You have validated this answer already"
        );

        listOfAnswers[_answerID].isValidated = true;
        listOfAnswers[_answerID].isValid = _isValid;

        surveyParticipants[msg.sender][_surveyID] = true;

        sendValidatorsFunds(msg.sender, _surveyID);

        // Send validators fee
    }

    function validatorsEarning(address _user) public view returns (uint256) {
        return valaidatorEarnings[_user];
    }

    function providerEarning(address _user) public view returns (uint256) {
        return providerEarnings[_user];
    }

    function sendValidatorsFunds(address _user, uint256 surveyID) internal {
        uint256 plan = listOfSurveys[surveyID].planID;
        uint256 profit = listOfPlans[plan].validatorsProfit;

        if (profit != 0) {
            uint256 numOfresponse = listOfSurveys[surveyID].numOfValidators;
            uint256 balanceInSurvey = surveyBalance[surveyID];

            if (balanceInSurvey > 0 && numOfresponse != 0) {
                uint256 validatorAmt = amountEachSurveyValidatorEarns[surveyID];
                surveyBalance[surveyID] =
                    surveyBalance[surveyID] -
                    validatorAmt;
                sonergyToken.transfer(_user, validatorAmt);
            }
        }
    }

    function sendProviderFunds(address _user, uint256 surveyID) internal {
        uint256 plan = listOfSurveys[surveyID].planID;
        uint256 profit = listOfPlans[plan].providerProfit;
        if (profit != 0) {
            uint256 numOfresponse = listOfSurveys[surveyID].numOfresponse;
            uint256 numberofCommsioners = listOfSurveys[surveyID]
                .numOfcommisioners;
            uint256 balanceInSurvey = surveyBalance[surveyID];

            if (balanceInSurvey > 0 && numOfresponse != numberofCommsioners) {
                uint256 commisionerAmt = amountEachSurveyParticipantEarns[
                    surveyID
                ];
                surveyBalance[surveyID] =
                    surveyBalance[surveyID] -
                    commisionerAmt;
                sonergyToken.transfer(_user, commisionerAmt);
            }
        }
    }

    function hasValidated(uint256 _surveyID, address _user)
        internal
        view
        returns (bool)
    {
        if (surveyParticipants[_user][_surveyID]) {
            return true;
        }
        return false;
    }

    function makeNFT(uint256 _surveyID) public returns (uint256) {
        require(_surveyExist(_surveyID), "Survey does not exist");
        require(
            listOfSurveys[_surveyID].owner == msg.sender,
            "You are not the owner of the survey"
        );

        require(
            checkNumberOfAnswers(_surveyID),
            "Survey is not completed yet."
        );

        listOfSurveys[_surveyID].nftStatus = true;
        return _surveyID;
    }

    function checkNumberOfAnswers(uint256 surveyID) internal returns (bool) {
        uint256 currentAnswers = numberOfAnswers[surveyID];
        uint256 requiredAnswers = listOfSurveys[surveyID].numOfValidators;

        if (currentAnswers == requiredAnswers) {
            listOfSurveys[surveyID].completed = true;
            return false;
        }

        return true;
    }

    function splitFunds(
        uint256 _amount,
        uint256 _planID,
        uint256 newSurveyID,
        uint256 _numberofCommsioners,
        uint256 _numberofValidators
    ) internal {
        uint256 valProfit = listOfPlans[_planID].validatorsProfit;
        uint256 providersProfit = listOfPlans[_planID].providerProfit;

        if (valProfit > 0) {
            if (providersProfit > 0) {
                uint256 validatorsAmt = _amount.mul(valProfit).div(10**2);
                uint256 providersAmt = _amount.mul(providersProfit).div(10**2);

                uint256 balance = _amount.sub(validatorsAmt.add(providersAmt));

                surveyBalance[newSurveyID] += validatorsAmt.add(providersAmt);

                amountEachSurveyValidatorEarns[newSurveyID] += validatorsAmt
                    .div(_numberofValidators);
                amountEachSurveyParticipantEarns[newSurveyID] += providersAmt
                    .div(_numberofCommsioners);

                sonergyToken.transfer(commisionAddress, balance);
            }
        }
    }

    function _surveyExist(uint256 surveyID) internal view returns (bool) {
        if (listOfSurveys[surveyID].exist) {
            return true;
        }
        return false;
    }

    function _planExist(uint256 planID) internal view returns (bool) {
        if (listOfPlans[planID].status) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Context.sol";
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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