// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/// @author: Radish

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                                                                    ///
///                                                                                                    ///
///   ██████╗ ███████╗███╗   ███╗ █████╗ ████████╗██╗ ██████╗    ██╗   ██╗ ██████╗ ████████╗███████╗   ///
///   ██╔══██╗██╔════╝████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝    ██║   ██║██╔═══██╗╚══██╔══╝██╔════╝   ///
///   ██████╔╝█████╗  ██╔████╔██║███████║   ██║   ██║██║         ██║   ██║██║   ██║   ██║   █████╗     ///
///   ██╔══██╗██╔══╝  ██║╚██╔╝██║██╔══██║   ██║   ██║██║         ╚██╗ ██╔╝██║   ██║   ██║   ██╔══╝     ///
///   ██║  ██║███████╗██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗     ╚████╔╝ ╚██████╔╝   ██║   ███████╗   ///
///   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝      ╚═══╝   ╚═════╝    ╚═╝   ╚══════╝   ///
///                                                                                                    ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

contract RematicVoteV1 is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    struct QuestionDescriptor {
        string text;
        uint256 kind;
        uint256 numOfChoices;
        string[] choices;
        uint256[] values;
    }

    struct PollDescriptor {
        address manager;
        string title;
        string description;
        address tokenAddress;
        uint256 openTime;
        uint256 closeTime;
        uint256 numOfQuestions;
        uint256[] questions;
        bool isCommunityVote;
        uint256 sizeOfWhitelist;
        uint256 etherBalance;
        uint256 tokenBalanceForQuestions;
        uint256 tokenBalanceForWhitelist;
    }

    event CreatePoll(uint256 id);

    uint256 public POLL_PRICE;
    uint256 public REGISTER_PRICE;
    uint256 public MAX_NUMBER_OF_VOTERS;
    uint256 public MAX_NUMBER_OF_QUESTIONS;
    uint256 public TOKEN_AMOUNT_PER_VOTER;
    uint256 public TOKEN_AMOUNT_PER_QUESTION;
    uint256 public BURN_PERCENT;
    address public TEAM_WALLET;
    address public RMTX_ADDRESS;

    address private signatureVerifier;

    modifier onlyNonManager() {
        require(
            isManager[_msgSender()] == false,
            "Already registered as a manager"
        );
        _;
    }

    modifier onlyManager() {
        require(
            isManager[_msgSender()] == true,
            "Only managers can do this action."
        );
        _;
    }

    modifier rightManager(uint256 _pollId) {
        require(
            _msgSender() == polls[_pollId].manager,
            "You are not a poll manager."
        );
        _;
    }

    modifier enoughValue(uint256 _fee) {
        require(msg.value >= _fee, "The payment amount is not enough.");
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0x0), "The address is not valid.");
        _;
    }

    modifier validPoll(uint256 _pollId) {
        require(_pollId < numOfPolls, "The poll id is not valid.");
        _;
    }

    modifier validQuestion(uint256 _pollId, uint256 _questionId) {
        require(
            _questionId < polls[_pollId].numOfQuestions,
            "The question id is not valid."
        );
        _;
    }

    modifier validTimeSlot(uint256 _openTime, uint256 _closeTime) {
        require(_openTime < _closeTime, "The time slot is not valid.");
        _;
    }

    modifier notStarted(uint256 _pollId) {
        require(
            block.timestamp < polls[_pollId].openTime,
            "The poll is active already."
        );
        _;
    }

    modifier active(uint256 _pollId) {
        require(
            block.timestamp >= polls[_pollId].openTime &&
                block.timestamp <= polls[_pollId].closeTime,
            "The poll is not active."
        );
        _;
    }

    modifier finished(uint256 _pollId) {
        require(
            block.timestamp > polls[_pollId].closeTime,
            "The poll is finished."
        );
        _;
    }

    function initialize() public initializer {
        POLL_PRICE =  0.5 ether;
        REGISTER_PRICE = 0.2 ether;
        MAX_NUMBER_OF_VOTERS = 10000;
        MAX_NUMBER_OF_QUESTIONS = 10;
        TOKEN_AMOUNT_PER_VOTER = 20 * 10**6 * 10**18;
        TOKEN_AMOUNT_PER_QUESTION = 10 * 10**9 * 10**18;
        RMTX_ADDRESS = 0x21d9Cb3F11a19323C9f222A30Cf9471430f4AB54;
        BURN_PERCENT = 70;
        __ReentrancyGuard_init();
        __Ownable_init();
    }

    function setPollPrice(uint256 _price) external onlyOwner {
        POLL_PRICE = _price;
    }

    function setRegisterPrice(uint256 _price) external onlyOwner {
        REGISTER_PRICE = _price;
    }

    function setMaxNumberOfVoters(uint256 _number) external onlyOwner {
        MAX_NUMBER_OF_VOTERS = _number;
    }

    function setTokenAmountPerVoter(uint256 _amount) external onlyOwner {
        TOKEN_AMOUNT_PER_VOTER = _amount;
    }

    function setTokenAmountPerQuestion(uint256 _amount) external onlyOwner {
        TOKEN_AMOUNT_PER_QUESTION = _amount;
    }

    function setBurnPercent(uint256 _percent) external onlyOwner {
        BURN_PERCENT = _percent;
    }

    function setTeamWallet(address _address) external onlyOwner {
        TEAM_WALLET = _address;
    }

    function setSignatureVerifier(address _verifier) external onlyOwner {
        signatureVerifier = _verifier;
    }

    mapping(address => bool) public isManager;
    mapping(address => uint256[]) public managerToPolls;
    mapping(uint256 => address[]) public pollToVoters;

    uint256 public numOfPolls;
    PollDescriptor[] public polls;

    uint256 public numOfQuestions;
    QuestionDescriptor[] public questions;

    uint256 public withdrawableAmount;

    constructor() {}

    function registerManager()
        external
        payable
        nonReentrant
        onlyNonManager
        enoughValue(REGISTER_PRICE)
    {
        isManager[_msgSender()] = true;
        withdrawableAmount += msg.value;
    }

    function createPoll(
        string memory _title,
        string memory _description,
        address _tokenAddr,
        uint256 _openTime,
        uint256 _closeTime
    )
        external
        payable
        nonReentrant
        onlyManager
        enoughValue(POLL_PRICE)
        validTimeSlot(_openTime, _closeTime)
    {
        polls.push(
            PollDescriptor(
                _msgSender(),
                _title,
                _description,
                _tokenAddr,
                _openTime,
                _closeTime,
                0, // Number of questions
                new uint256[](10), // Questions
                false, // isCommunity
                0, // Size of whitelist
                msg.value - POLL_PRICE, // Ether Balance
                0, // Token Balance For Questions
                0 // Token Balance For Whitelist
            )
        );

        managerToPolls[_msgSender()].push(numOfPolls);

        withdrawableAmount += POLL_PRICE;

        emit CreatePoll(numOfPolls++);
    }

    function updatePollDetails(
        uint256 _pollId,
        string memory _title,
        string memory _description,
        uint256 _openTime,
        uint256 _closeTime
    )
        external
        payable
        nonReentrant
        onlyManager
        validPoll(_pollId)
        validTimeSlot(_openTime, _closeTime)
    {
        if (block.timestamp < polls[_pollId].openTime) {
            polls[_pollId].title = _title;
            polls[_pollId].description = _description;
            polls[_pollId].openTime = _openTime;
        }

        if (block.timestamp < polls[_pollId].closeTime) {
            polls[_pollId].closeTime = _closeTime;
        }

        polls[_pollId].etherBalance += msg.value;
    }

    function getPollsByManager()
        external
        view
        onlyManager
        returns (uint256[] memory)
    {
        return managerToPolls[_msgSender()];
    }

    function getActivePollsByManager()
        external
        view
        onlyManager
        returns (uint256[] memory)
    {
        uint256[] memory allPolls = managerToPolls[_msgSender()];

        uint256 count = 0;
        for (uint256 i = 0; i < allPolls.length; i++) {
            if (
                block.timestamp >= polls[allPolls[i]].openTime &&
                block.timestamp <= polls[allPolls[i]].closeTime
            ) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 k = 0;
        for (uint256 i = 0; i < allPolls.length; i++) {
            if (
                block.timestamp >= polls[allPolls[i]].openTime &&
                block.timestamp <= polls[allPolls[i]].closeTime
            ) {
                result[k++] = allPolls[i];
            }
        }

        return result;
    }

    function getFinishedPollsByManager()
        external
        view
        onlyManager
        returns (uint256[] memory)
    {
        uint256[] memory allPolls = managerToPolls[_msgSender()];

        uint256 count = 0;
        for (uint256 i = 0; i < allPolls.length; i++) {
            if (block.timestamp > polls[allPolls[i]].closeTime) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 k = 0;
        for (uint256 i = 0; i < allPolls.length; i++) {
            if (block.timestamp > polls[allPolls[i]].closeTime) {
                result[k++] = allPolls[i];
            }
        }

        return result;
    }

    function getIsCommunityVote(uint256 _pollId) external view returns(bool) {
        PollDescriptor memory _poll = polls[_pollId];
        return _poll.tokenAddress == address(0x0) ? true : false;
    }

    function estimateApproveTokenAmountForWhitelist(
        uint256 _pollId,
        uint256 _newWhitelistSize
    ) external view validPoll(_pollId) rightManager(_pollId) returns (uint256) {
        uint256 curWhitelistSize = polls[_pollId].sizeOfWhitelist;
        if (_newWhitelistSize <= curWhitelistSize) {
            return 0;
        }
        return TOKEN_AMOUNT_PER_VOTER * (_newWhitelistSize - curWhitelistSize);
    }

    function updateWhitelist(
        uint256 _pollId,
        bool _isCommunityVote,
        uint256 _newWhitelistSize
    ) external nonReentrant validPoll(_pollId) rightManager(_pollId) {
        uint256 curWhitelistSize = polls[_pollId].sizeOfWhitelist;

        require(
            IERC20(polls[_pollId].tokenAddress).allowance(
                _msgSender(),
                address(this)
            ) >=
                TOKEN_AMOUNT_PER_VOTER *
                    (
                        _newWhitelistSize > curWhitelistSize
                            ? _newWhitelistSize - curWhitelistSize
                            : 0
                    ),
            "You should approve enough amount tokens to submit whitelist."
        );

        if (_newWhitelistSize > curWhitelistSize) {
            uint256 amount = TOKEN_AMOUNT_PER_VOTER *
                (_newWhitelistSize - curWhitelistSize);
            IERC20(polls[_pollId].tokenAddress).transferFrom(
                _msgSender(),
                address(this),
                TOKEN_AMOUNT_PER_VOTER * (_newWhitelistSize - curWhitelistSize)
            );
            polls[_pollId].tokenBalanceForWhitelist += amount;
        } else if (_newWhitelistSize < curWhitelistSize) {
            uint256 amount = TOKEN_AMOUNT_PER_VOTER *
                (curWhitelistSize - _newWhitelistSize);
            IERC20(polls[_pollId].tokenAddress).transfer(_msgSender(), amount);
            polls[_pollId].tokenBalanceForWhitelist -= amount;
        }

        polls[_pollId].isCommunityVote = _isCommunityVote;
        polls[_pollId].sizeOfWhitelist = _newWhitelistSize;
    }

    function createQuestion(
        uint256 _pollId,
        string memory _text,
        uint256 _kind,
        string[] memory _choices
    )
        external
        nonReentrant
        validPoll(_pollId)
        notStarted(_pollId)
        rightManager(_pollId)
    {
        require(
            polls[_pollId].numOfQuestions < MAX_NUMBER_OF_QUESTIONS,
            "Cannot create questions any more."
        );
        require(
            IERC20(polls[_pollId].tokenAddress).allowance(
                _msgSender(),
                address(this)
            ) >= TOKEN_AMOUNT_PER_QUESTION,
            "You should approve enough amount tokens to create a question."
        );

        if(polls[_pollId].manager != owner()){
            IERC20(polls[_pollId].tokenAddress).transferFrom(
                _msgSender(),
                address(this),
                TOKEN_AMOUNT_PER_QUESTION
            );
        }
        questions.push(
            QuestionDescriptor(
                _text,
                _kind,
                _choices.length, // Number of Choices
                _choices, // Choices
                new uint256[](_choices.length) // Values
            )
        );

        polls[_pollId].questions[
            polls[_pollId].numOfQuestions++
        ] = numOfQuestions++;
        polls[_pollId].tokenBalanceForQuestions += TOKEN_AMOUNT_PER_QUESTION;
    }

    function updateQuestion(
        uint256 _pollId,
        uint256 _questionId,
        string memory _text,
        uint256 _kind,
        string[] memory _choices
    )
        external
        nonReentrant
        validPoll(_pollId)
        notStarted(_pollId)
        rightManager(_pollId)
        validQuestion(_pollId, _questionId)
    {
        uint256 id = polls[_pollId].questions[_questionId];

        questions[id] = QuestionDescriptor(
            _text,
            _kind,
            _choices.length, // Number of Choices
            _choices, // Choices
            new uint256[](_choices.length) // Values
        );
    }

    function deleteQuestion(uint256 _pollId, uint256 _questionId)
        external
        nonReentrant
        validPoll(_pollId)
        notStarted(_pollId)
        rightManager(_pollId)
        validQuestion(_pollId, _questionId)
    {
        if(polls[_pollId].manager != owner()){
            IERC20(polls[_pollId].tokenAddress).transfer(
                _msgSender(),
                TOKEN_AMOUNT_PER_QUESTION
            );
        }
        for (
            uint256 i = _questionId + 1;
            i < polls[_pollId].numOfQuestions;
            i++
        ) {
            polls[_pollId].questions[i - 1] = polls[_pollId].questions[i];
        }

        polls[_pollId].numOfQuestions--;
        polls[_pollId].tokenBalanceForQuestions -= TOKEN_AMOUNT_PER_QUESTION;
    }

    function getQuestionDetails(uint256 _pollId, uint256 _questionId)
        external
        view
        validPoll(_pollId)
        validQuestion(_pollId, _questionId)
        returns (QuestionDescriptor memory)
    {
        return questions[polls[_pollId].questions[_questionId]];
    }

    function getQuestions(uint256 _pollId)
        external
        view
        validPoll(_pollId)
        returns (QuestionDescriptor[] memory)
    {
        QuestionDescriptor[] memory result = new QuestionDescriptor[](
            polls[_pollId].numOfQuestions
        );

        for (uint256 i = 0; i < polls[_pollId].numOfQuestions; i++) {
            result[i] = questions[polls[_pollId].questions[i]];
            for (uint256 j = 0; j < result[i].numOfChoices; j++) {
                result[i].values[j] = 0;
            }
        }

        return result;
    }

    function verifier(
        address _voter,
        uint256 _pollId,
        uint256 _amount,
        bytes calldata _signature
    ) private pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(_voter, _pollId, _amount))
            )
        );
        return hash.recover(_signature);
    }

    function voteQuestions(
        uint256 _pollId,
        uint256[] memory _answers,
        uint256 _amount,
        bytes calldata _signature
    ) external nonReentrant validPoll(_pollId) active(_pollId) {
        require(
            pollToVoters[_pollId].length < polls[_pollId].sizeOfWhitelist,
            "Enough number of voters already voted."
        );

        address voter = _msgSender();

        require(
            verifier(voter, _pollId, _amount, _signature) == signatureVerifier,
            "You're not authorized to vote."
        );

        if(RMTX_ADDRESS == polls[_pollId].tokenAddress){
            require(
                IERC20(polls[_pollId].tokenAddress).balanceOf(voter) > 0,
                "You are not authorized to vote."
            );
        }

        for (uint256 i = 0; i < pollToVoters[_pollId].length; i++) {
            require(pollToVoters[_pollId][i] != voter, "You already voted.");
        }

        for (uint256 i = 0; i < polls[_pollId].numOfQuestions; i++) {
            uint256 id = polls[_pollId].questions[i];
            if (questions[id].kind == 2) {
                uint256 a = 1;
                uint256 b = 2;
                uint256 num = _answers[i];
                for (uint256 j = 0; j < questions[id].numOfChoices; j++) {
                    questions[id].values[num % questions[id].numOfChoices] += a;
                    num /= questions[id].numOfChoices;
                    b += a;
                    a = b - a;
                }
            } else {
                questions[id].values[_answers[i]] += 1;
            }
        }

        if (_amount != 0 && polls[_pollId].etherBalance >= _amount) {
            _safeTransferETH(voter, _amount);
            polls[_pollId].etherBalance -= _amount;
        }

        pollToVoters[_pollId].push(voter);
    }
    
    function getPollIsActive(uint256 _pollId) validPoll(_pollId) external view returns(bool){
        return block.timestamp >= polls[_pollId].openTime && block.timestamp <= polls[_pollId].closeTime;
    }

    function getVoteResult(uint256 _pollId, uint256 _questionId)
        external
        view
        onlyManager
        rightManager(_pollId)
        validPoll(_pollId)
        validQuestion(_pollId, _questionId)
        returns (uint256[] memory)
    {
        return questions[polls[_pollId].questions[_questionId]].values;
    }

    function getActivePollsByVoter(uint256[] memory _candidates)
        external
        view
        returns (uint256[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 0; i < _candidates.length; i++) {
            if (
                _candidates[i] < numOfPolls &&
                block.timestamp >= polls[_candidates[i]].openTime &&
                block.timestamp <= polls[_candidates[i]].closeTime
            ) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 k = 0;
        for (uint256 i = 0; i < _candidates.length; i++) {
            if (
                _candidates[i] < numOfPolls &&
                block.timestamp >= polls[_candidates[i]].openTime &&
                block.timestamp <= polls[_candidates[i]].closeTime
            ) {
                result[k++] = _candidates[i];
            }
        }

        return result;
    }

    function getComingPollsByVoter(uint256[] memory _candidates)
        external
        view
        returns (uint256[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 0; i < _candidates.length; i++) {
            if (
                _candidates[i] < numOfPolls &&
                block.timestamp < polls[_candidates[i]].openTime
            ) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 k = 0;
        for (uint256 i = 0; i < _candidates.length; i++) {
            if (
                _candidates[i] < numOfPolls &&
                block.timestamp < polls[_candidates[i]].openTime
            ) {
                result[k++] = _candidates[i];
            }
        }

        return result;
    }

    function _safeTransferETH(address _to, uint256 _value)
        internal
        returns (bool)
    {
        (bool success, ) = _to.call{value: _value, gas: 30_000}(new bytes(0));
        return success;
    }

    function charge(uint256 _pollId)
        external
        payable
        nonReentrant
        rightManager(_pollId)
    {
        polls[_pollId].etherBalance += msg.value;
    }

    function claim(uint256 _pollId)
        external
        nonReentrant
        rightManager(_pollId)
    {
        _safeTransferETH(_msgSender(), polls[_pollId].etherBalance);
        polls[_pollId].etherBalance = 0;
    }

    function getUnclosedPolls() external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < numOfPolls; i++) {
            if (
                polls[i].tokenBalanceForQuestions +
                    polls[i].tokenBalanceForWhitelist >
                0 &&
                block.timestamp > polls[i].closeTime
            ) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 k = 0;
        for (uint256 i = 0; i < numOfPolls; i++) {
            if (
                polls[i].tokenBalanceForQuestions +
                    polls[i].tokenBalanceForWhitelist >
                0 &&
                block.timestamp > polls[i].closeTime
            ) {
                result[k++] = i;
            }
        }

        return result;
    }

    function closePoll(
        uint256 _pollId,
        uint256 _communitySize,
        bytes calldata _signature
    ) external nonReentrant validPoll(_pollId) finished(_pollId) {
        require(
            _msgSender() == owner() || _msgSender() == polls[_pollId].manager,
            "You're not authorized to close the poll."
        );

        require(
            verifier(_msgSender(), _pollId, _communitySize, _signature) ==
                signatureVerifier,
            "You're not authorized to close the poll."
        );

        if (polls[_pollId].etherBalance > 0) {
            _safeTransferETH(
                polls[_pollId].manager,
                polls[_pollId].etherBalance
            );
        }

        if (
            polls[_pollId].tokenBalanceForQuestions +
                polls[_pollId].tokenBalanceForWhitelist ==
            0
        ) {
            return;
        }

        uint256 tokensPerVote = polls[_pollId].tokenBalanceForWhitelist /
            polls[_pollId].sizeOfWhitelist;

        if (polls[_pollId].isCommunityVote) {
            uint256 returnAmount = polls[_pollId].sizeOfWhitelist;

            if (_communitySize < pollToVoters[_pollId].length) {
                returnAmount -= pollToVoters[_pollId].length;
            } else {
                returnAmount -= _communitySize;
            }

            returnAmount *= tokensPerVote;
            
            if(polls[_pollId].manager != owner()){
                IERC20(polls[_pollId].tokenAddress).transfer(
                    polls[_pollId].manager,
                    returnAmount
                );
            }
            polls[_pollId].tokenBalanceForWhitelist -= returnAmount;
        }

        uint256 totalBalance = polls[_pollId].tokenBalanceForQuestions +
            polls[_pollId].tokenBalanceForWhitelist;

        if(polls[_pollId].manager != owner()){

            IERC20(polls[_pollId].tokenAddress).transfer(
                TEAM_WALLET,
                (totalBalance * (100 - BURN_PERCENT)) / 100
            );

            IERC20(polls[_pollId].tokenAddress).transfer(
                0x000000000000000000000000000000000000dEaD,
                (totalBalance * BURN_PERCENT) / 100
            );
        }
        polls[_pollId].etherBalance = 0;
        polls[_pollId].tokenBalanceForQuestions = 0;
        polls[_pollId].tokenBalanceForWhitelist = 0;
    }

    function withdraw(uint256 _amount)
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {
        require(
            _amount <= withdrawableAmount,
            "You cannot withdraw that much."
        );
        bool success = _safeTransferETH(TEAM_WALLET, _amount);
        withdrawableAmount -= _amount;
        return success;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}