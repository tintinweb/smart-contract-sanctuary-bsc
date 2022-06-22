// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RematicVoteV1 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

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
        uint256 sizeOfWhitelist;
        uint256 etherBalance;
        uint256 tokenBalance;
    }

    event CreatePoll(uint256 id);

    uint256 public POLL_PRICE = 0.0005 ether;
    uint256 public REGISTER_PRICE = 0.0002 ether;
    uint256 public MAX_NUMBER_OF_VOTERS = 10000;
    uint256 public MAX_NUMBER_OF_QUESTIONS = 10;
    uint256 public TOKEN_AMOUNT_PER_VOTER = 20 * 10**6 * 10**18;
    uint256 public TOKEN_AMOUNT_PER_QUESTION = 10 * 10**9 * 10**18;
    address public TEAM_WALLET = 0x81d0ac4dc36739f387179E3127b26eE91aaD4C40;
    uint256 public BURN_PERCENT = 70;

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

    function setPricePrice(uint256 _price) external onlyOwner {
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

    function setTeamWallet(address _address) external onlyOwner {
        TEAM_WALLET = _address;
    }

    function setBurnPercent(uint256 _percent) external onlyOwner {
        BURN_PERCENT = _percent;
    }

    mapping(address => bool) public isManager;
    mapping(address => uint256[]) public managerToPolls;
    mapping(uint256 => address[]) public pollToVoters;

    uint256 public numOfPolls = 0;
    PollDescriptor[] public polls;

    uint256 public numOfQuestions = 0;
    QuestionDescriptor[] public questions;

    constructor() {}

    function registerManager()
        external
        payable
        nonReentrant
        onlyNonManager
        enoughValue(REGISTER_PRICE)
    {
        isManager[_msgSender()] = true;
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
        validAddress(_tokenAddr)
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
                0, // Size of whitelist
                msg.value - POLL_PRICE, // Ether Balance
                0 // Token Balance
            )
        );

        managerToPolls[_msgSender()].push(numOfPolls);

        emit CreatePoll(numOfPolls++);
    }

    function updatePollDetails(
        uint256 _pollId,
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
        validPoll(_pollId)
        notStarted(_pollId)
        validAddress(_tokenAddr)
        validTimeSlot(_openTime, _closeTime)
    {
        polls[_pollId].title = _title;
        polls[_pollId].description = _description;
        polls[_pollId].tokenAddress = _tokenAddr;
        polls[_pollId].openTime = _openTime;
        polls[_pollId].closeTime = _closeTime;
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

    function updateWhitelist(uint256 _pollId, uint256 _newWhitelistSize)
        external
        nonReentrant
        validPoll(_pollId)
        rightManager(_pollId)
    {
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
            polls[_pollId].tokenBalance += amount;
        } else if (_newWhitelistSize < curWhitelistSize) {
            uint256 amount = TOKEN_AMOUNT_PER_VOTER *
                (curWhitelistSize - _newWhitelistSize);
            IERC20(polls[_pollId].tokenAddress).transfer(_msgSender(), amount);
            polls[_pollId].tokenBalance -= amount;
        }

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

        IERC20(polls[_pollId].tokenAddress).transferFrom(
            _msgSender(),
            address(this),
            TOKEN_AMOUNT_PER_QUESTION
        );

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
        polls[_pollId].tokenBalance += TOKEN_AMOUNT_PER_QUESTION;
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

    function voteQuestions(
        uint256 _pollId,
        uint256[] memory _answers,
        uint256 _amount
    ) external nonReentrant validPoll(_pollId) active(_pollId) {
        address voter = _msgSender();
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
            if (_amount != 0 && polls[_pollId].etherBalance >= _amount) {
                _safeTransferETH(voter, _amount);
                polls[_pollId].etherBalance -= _amount;
            }
        }
        pollToVoters[_pollId].push(voter);
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

    function deleteQuestion(uint256 _pollId, uint256 _questionId)
        external
        nonReentrant
        validPoll(_pollId)
        notStarted(_pollId)
        rightManager(_pollId)
        validQuestion(_pollId, _questionId)
    {
        IERC20(polls[_pollId].tokenAddress).transfer(
            _msgSender(),
            TOKEN_AMOUNT_PER_QUESTION
        );

        for (
            uint256 i = _questionId + 1;
            i < polls[_pollId].numOfQuestions;
            i++
        ) {
            polls[_pollId].questions[i - 1] = polls[_pollId].questions[i];
        }

        polls[_pollId].numOfQuestions--;
        polls[_pollId].tokenBalance -= TOKEN_AMOUNT_PER_QUESTION;
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

    function _safeTransferETH(address _to, uint256 _value)
        internal
        returns (bool)
    {
        (bool success, ) = _to.call{value: _value, gas: 30_000}(new bytes(0));
        return success;
    }

    function charge(uint256 _pollId)
        public
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

    function getFinishedPolls()
        external
        view
        onlyOwner
        returns (uint256[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 0; i < numOfPolls; i++) {
            if (
                polls[i].tokenBalance > 0 &&
                block.timestamp > polls[i].closeTime
            ) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 k = 0;
        for (uint256 i = 0; i < numOfPolls; i++) {
            if (
                polls[i].tokenBalance > 0 &&
                block.timestamp > polls[i].closeTime
            ) {
                result[k++] = i;
            }
        }

        return result;
    }

    function finish(uint256 _pollId)
        external
        onlyOwner
        validPoll(_pollId)
        finished(_pollId)
    {
        _safeTransferETH(TEAM_WALLET, polls[_pollId].etherBalance);

        IERC20(polls[_pollId].tokenAddress).transfer(
            TEAM_WALLET,
            (polls[_pollId].tokenBalance * (100 - BURN_PERCENT)) / 100
        );

        IERC20(polls[_pollId].tokenAddress).transfer(
            0x000000000000000000000000000000000000dEaD,
            (polls[_pollId].tokenBalance * BURN_PERCENT) / 100
        );

        polls[_pollId].etherBalance = 0;
        polls[_pollId].tokenBalance = 0;
    }

    function signature(address _addr, string memory _secretKey)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(_secretKey, _addr);
    }

    function signatureHash(address _addr, string memory _secretKey)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_secretKey, _addr));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
        _transferOwnership(_msgSender());
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}