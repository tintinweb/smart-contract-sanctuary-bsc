/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// File: contracts/interfaces/INVEG.sol


pragma solidity >=0.8.0;

interface INVEG {
  function  approveFrom(address owner, address spender, uint256 _amount) external returns(bool);
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/NewNeloverseDAO.sol


pragma solidity >=0.8.0;




contract NeloverseDAO is ReentrancyGuard {
    /// @notice GLOBAL CONSTANTS
    uint public constant MINIMUM_ACCEPTANCE_THRESHOLD = 1000; /// @notice The minimum acceptance threshold.
    uint public constant MINIMUM_PROPOSAL_DAYS = 0; /// @notice The minimum proposal period.
    address public nvegContract; /// @notice NVEG contract address.

    /// @notice INTERNAL ACCOUNTING
    uint256 private proposalCount = 1; /// @notice total proposals submitted.
    uint256 private memberCount = 1; /// @notice total member.
    uint256[] private proposalQueue;

    mapping (uint256 => Proposal) private proposals;
    mapping(uint256 => mapping(address => Member)) private oldMembers;
    mapping(address => Member) private members;

    /// @notice EVENTS
    event SubmitProposal(address proposer, uint256 acceptanceThreshold, uint256 _days, string details, bool[4] flags, uint256 proposalId, uint256 proposalType);
    event SubmitVote(uint256 indexed proposalIndex, address indexed memberAddress, uint8 uintVote, uint256 votedScore);
    event ProcessedProposal(address proposer, uint256 acceptanceThreshold, uint256 _days, string details, bool[4] flags, uint256 proposalId);
    event AddMember(uint256 shares, uint256 memberId, address memberAddress);
    event Withdraw(address memberAddress, uint256 shares);

    /// @notice Vote types of the proposal.
    enum Vote {
        Null, // default value, counted as abstent.
        Yes,
        No
    }

    /// @notice Possible states that a proposal may be in.
    enum ProposalState {
        Active,
        Finished,
        Passed,
        Rejected,
        Enacted
    }

    /// @notice Possible types of the proposal.
    enum ProposalType {
        Common,
        Governance
    }

    /// @notice Struct of member.
    struct Member {
        uint256 shares; // the # of voting shares assigned to this member.
        uint256[] votedProposal; // the total proposals which you voted.
        mapping(uint256 => uint256) votedScore; // the score which you voted for each proposal.
        bool exists; // the flag to checking you a member or not.
    }

    /// @notice Struct of proposal
    struct Proposal {
        address proposer; /// @notice the account that submitted the proposal (can be non-member).
        uint256 startingTime; /// @notice the time in which voting can start for this proposal.
        uint256 endingTime; /// @notice the time in which voting can end for this proposal.
        uint256 yesVotes; /// @notice the total number of YES votes for this proposal.
        uint256 noVotes; /// @notice the total number of NO votes for this proposal.
        uint256 acceptanceThreshold; /// @notice the total points you need to pass for this proposal.
        uint256 votingYesScore; /// @notice the total yes voting points for this proposal.
        uint256 votingNoScore; /// @notice the total no voting points for this proposal.
        bool[4] flags; /// @notice [sponsored, processed, didPass, cancelled].
        string details; /// @notice proposal details - could be IPFS hash, plaintext, or JSON.
        mapping(address => Vote) votesByMember; /// @notice the votes on this proposal by each member.
        bool exists; /// @notice always true once a proposal has been created.
        bool enacted; /// @notice always false once a proposal has been created.
        uint256 proposalType; /// @notice type of proposal.
        address targetAddress; /// @notice address of target smart contract just need for Governance.
    }

    // CONSTRUCTOR
    constructor(address _nvegContract) {
        nvegContract = _nvegContract;
    }

    modifier onlyValid(uint256 proposalId) {
        require(proposalCount >= proposalId && proposalId > 0, "NeloverseDAO: Invalid proposal id.");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender].exists, "NeloverseDAO: You are not a member.");
        require(members[msg.sender].shares > 0, "NeloverseDAO: You are not a member.");
        _;
    }

    modifier isHaveEnoughNVEG(uint256 _amount) {
        require(IERC20(nvegContract).balanceOf(msg.sender) > 0 && _amount <= IERC20(nvegContract).balanceOf(msg.sender), "NeloverseDAO: You don't have NVEG.");
        require(INVEG(nvegContract).approveFrom(msg.sender, address(this), _amount), "NeloverseDAO: Falied to approve.");
        require(IERC20(nvegContract).transferFrom(msg.sender, address(this), _amount), "NeloverseDAO: Falied to transfer token.");
        _;
    }

    modifier isValidThresholdAndDays(uint256 acceptanceThreshold, uint256 _days) {
        require(acceptanceThreshold >= MINIMUM_ACCEPTANCE_THRESHOLD, "NeloverseDAO: Acceptance Threshold must be at greater than 1000");
        require(_days >= MINIMUM_PROPOSAL_DAYS, "NeloverseDAO: Proposal days must be at least 3 days.");
        _;
    }

    /// @notice PUBLIC FUNCTIONS
    /// @notice SUBMIT PROPOSAL
    /// @notice Set applicant, timelimit, details, proposal types.
    function submitProposal(uint256 acceptanceThreshold, uint256 _days, string memory details, uint8 _proposalType, address _targetAddress) external isValidThresholdAndDays(acceptanceThreshold, _days) returns (uint256 proposalId) {
        require(msg.sender != address(0), "NeloverseDAO: Applicant cannot be 0.");
        require(_proposalType < 2, "NeloverseDAO: Proposal Type must be less than 2.");
        bool[4] memory flags; /// @notice [sponsored, processed, didPass, cancelled]
        if (_proposalType == 1) {
            require(_targetAddress != address(0), "NeloverseDAO: Target Address cannot be 0.");
            require(IERC20(nvegContract).balanceOf(msg.sender) >= 100*10**9, "NeloverseDAO: You need at least 100 NVEG to submit Governance proposal.");
        }

        _submitProposal(acceptanceThreshold, _days, details, flags, _proposalType, _targetAddress);
        return proposalCount; /// @notice return proposalId - contracts calling submit might want it
    }

    /// @notice Function which can be called when the proposal voting time has expired. To either act on the proposal or cancel if not a majority yes vote.
    function processProposal(uint256 proposalId) external onlyValid(proposalId) returns (bool) {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        require(proposals[proposalId].flags[1] == false, "NeloverseDAO: This proposal has already been processed.");
        require(getCurrentTime() >= proposals[proposalId].startingTime, "NeloverseDAO: Voting period has not started.");
        require(hasVotingPeriodExpired(proposals[proposalId].startingTime, proposals[proposalId].endingTime), "NeloverseDAO: Proposal voting period has not expired yet.");
        for (uint256 i = 0; i < proposalQueue.length; i++) {
            if (proposalQueue[i] == proposalId) {
                delete proposalQueue[i];
            }
        }
        Proposal storage prop = proposals[proposalId];
        if (prop.flags[3] == false) {
            if (prop.yesVotes > prop.noVotes && prop.votingYesScore >= prop.acceptanceThreshold) {
                prop.flags[1] = true;
                prop.flags[2] = true;
            } else {
                prop.flags[1] = true;
                prop.flags[2] = false;
            }
        }
        emit ProcessedProposal(prop.proposer, prop.acceptanceThreshold, prop.endingTime, prop.details, prop.flags, proposalId);
        return true; 
    }

    /// @notice Function to submit a vote to a proposal.
    /// @notice Voting period must be in session
    function submitVote(uint256 proposalId, uint8 uintVote) external onlyMember onlyValid(proposalId) {
        require(uintVote < 3, "NeloverseDAO: Vote must be less than 3.");

        _submitVote(proposalId, uintVote);
    }

    /// @notice Function to update the action status of proposal, it have been done or not.
    function actionProposal(uint256 proposalId) external onlyValid(proposalId) {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        require(proposals[proposalId].flags[1] == true && proposals[proposalId].flags[2] == true, "NeloverseDAO: This proposal not approve.");
        require(proposals[proposalId].enacted == false, "NeloverseDAO: This proposal already did.");
        proposals[proposalId].enacted = true;
    }

    /// @notice Register a member.
    function addMember(uint256 _amount) external isHaveEnoughNVEG(_amount) returns(uint256 _memberId) {
        require(!members[msg.sender].exists, "NeloverseDAO: You already a member.");
        members[msg.sender].shares = weiToEther(_amount);
        members[msg.sender].exists = true;
        _memberId = memberCount;
        emit AddMember(members[msg.sender].shares, _memberId, msg.sender);
        memberCount += 1;
        return _memberId;
    }

    /// @notice Getting more VP when you have more NVEG.
    function getMoreVP(uint256 _amount) external nonReentrant onlyMember isHaveEnoughNVEG(_amount) {
        members[msg.sender].shares += weiToEther(_amount);
    }

    /// @notice Withdraw NVEG.
    function withdraw(uint256 _amount) external nonReentrant onlyMember {
        Member storage member = members[msg.sender];
        if (member.votedProposal.length > 0) {
            for (uint256 i = 0; i < member.votedProposal.length; i++) {
                Proposal storage proposal = proposals[member.votedProposal[i]];
                if (proposal.flags[3] == false) {
                    require(hasVotingPeriodExpired(proposal.startingTime, proposal.endingTime), "NeloverseDAO: Proposal you voted not expired.");
                }
            }
        }
        require(_amount <= member.shares * 10**9, "NeloverseDAO: Your amount is over your balance.");
        require(IERC20(nvegContract).balanceOf(address(this)) >= _amount, "NeloverseDAO: Don't have enough NVEG to withdraw.");
        require(IERC20(nvegContract).transfer(msg.sender, _amount), "NeloverseDAO: Falied to transfer token.");
        member.shares -= weiToEther(_amount);
        if (member.shares <= 0) {
            member.exists = false;
        }
        emit Withdraw(msg.sender, _amount);
    }

    /// @notice INTERNAL FUNCTION
    /// @notice SUBMIT PROPOSAL
    function _submitProposal(uint256 acceptanceThreshold, uint256 _days, string memory details, bool[4] memory flags, uint8 _proposalType, address _targetAddress) internal {
        proposalQueue.push(proposalCount);
        Proposal storage prop = proposals[proposalCount];
        prop.proposer = msg.sender;
        prop.startingTime = block.timestamp;
        prop.endingTime = endDate(_days);
        prop.flags = flags;
        prop.details = details;
        prop.acceptanceThreshold = acceptanceThreshold;
        prop.exists = true;
        prop.enacted = false;
        prop.proposalType = _proposalType;
        prop.targetAddress = _targetAddress;
        emit SubmitProposal(msg.sender, acceptanceThreshold, _days, details, flags, proposalCount, _proposalType);
        proposalCount += 1;
    }

    /// @notice submit vote for proposal.
    function _submitVote(uint256 proposalId, uint8 uintVote) internal {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        Vote vote = Vote(uintVote);
        Proposal storage prop = proposals[proposalId];
        Member storage member = members[msg.sender];
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");

        if (!contains(member.votedProposal, proposalId)) {
            member.votedProposal.push(proposalId);
            member.votedScore[proposalId] = member.shares;
        }

        require(_state(proposalId) == ProposalState.Active, "NeloverseDAO: Proposal voting period has not started.");
        require(!hasVotingPeriodExpired(prop.startingTime, prop.endingTime), "NeloverseDAO: Proposal voting period has expired.");
        require(vote == Vote.Yes || vote == Vote.No, "NeloverseDAO: Vote must be either Yes or No.");

        if (vote == Vote.Yes) {
            require(prop.votesByMember[msg.sender] != Vote.Yes, "NeloverseDAO: You already voted Yes.");
            if (prop.votesByMember[msg.sender] == Vote.No) {
                prop.noVotes -= 1;
                prop.votingNoScore = prop.votingNoScore - member.votedScore[proposalId];
            }

            prop.yesVotes += 1;
            prop.votingYesScore = prop.votingYesScore + member.votedScore[proposalId];
        } else if (vote == Vote.No) {
            require(prop.votesByMember[msg.sender] != Vote.No, "NeloverseDAO: You already voted No.");
            if (prop.votesByMember[msg.sender] == Vote.Yes) {
                prop.yesVotes -= 1;
                prop.votingYesScore = prop.votingYesScore - member.votedScore[proposalId];
            }

            prop.noVotes += 1;
            prop.votingNoScore = prop.votingNoScore + member.votedScore[proposalId];
        }

        prop.votesByMember[msg.sender] = vote;
        emit SubmitVote(proposalId, msg.sender, uintVote, member.votedScore[proposalId]);
    }

    function getMemberProposalVote(uint256 proposalId) public view returns (Vote) {
        require(proposalCount >= proposalId && proposalId > 0, "NeloverseDAO: Invalid proposal id.");
        uint256 _proposalIndex = proposalId - 1;
        require(_proposalIndex < proposalQueue.length, "NeloverseDAO: Proposal does not exist in Queue.");
        return Vote(proposals[proposalQueue[_proposalIndex]].votesByMember[msg.sender]);
    }

    /// @notice GETTER FUNCTIONS
    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getProposalQueueLength() public view returns (uint256) {
        return proposalQueue.length;
    }

    function getMember(address _owner) public view returns (uint256, uint256[] memory, bool) {
        return (members[_owner].shares, members[_owner].votedProposal, members[_owner].exists);
    }

    function getProposalFlags(uint256 proposalId) public onlyValid(proposalId) view returns (bool[4] memory _flags) {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        _flags = proposals[proposalId].flags;

        return _flags;
    }

    function getProposalState(uint256 proposalId) public onlyValid(proposalId) view returns (ProposalState) {
        return _state(proposalId);
    }

    function checkProposalId(uint256 proposalId) public view returns (bool) {
        return proposalCount >= proposalId && proposalId > 0;
    }

    function getProposalTargetAddress(uint256 proposalId) public view returns (address) {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        require(ProposalType(proposals[proposalId].proposalType) == ProposalType.Governance, "NeloverseDAO: This proposal not a Governance Proposal.");

        return proposals[proposalId].targetAddress;
    }

    function getActionProposalStatus(uint256 proposalId) public onlyValid(proposalId) view returns (bool) {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        bool enacted = proposals[proposalId].enacted;

        return enacted;
    }

    function getProposalDetail(uint256 proposalId) public onlyValid(proposalId) view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, string memory, bool, uint256) {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        Proposal storage prop = proposals[proposalId];
        return (prop.startingTime, prop.endingTime, prop.yesVotes, prop.noVotes, prop.acceptanceThreshold, prop.votingYesScore, prop.votingNoScore, prop.details, prop.enacted, prop.proposalType);
    }

    /// @notice INTERNAL HELPER FUNCTIONS
    function endDate(uint256 _days) internal view returns (uint256) {
        return block.timestamp + _days * 1 days;
    }

    function weiToEther(uint256 valueWei) internal pure returns (uint256) {
       return valueWei/(10**9);
    }

    function hasVotingPeriodExpired(uint256 startingTime, uint256 endingTime) public view returns (bool) {
        return (getCurrentTime() >= (startingTime + endingTime));
    }

    function _state(uint256 proposalId) internal view returns (ProposalState _stateStatus) {
        require(proposals[proposalId].exists, "NeloverseDAO: This proposal does not exist.");
        Proposal storage proposal = proposals[proposalId];

        if (!hasVotingPeriodExpired(proposal.startingTime, proposal.endingTime) && getCurrentTime() >= proposal.startingTime) {
            _stateStatus = ProposalState.Active;
        } else if (hasVotingPeriodExpired(proposal.startingTime, proposal.endingTime) && proposal.flags[2] == true) {
            _stateStatus = ProposalState.Passed;
        } else if (hasVotingPeriodExpired(proposal.startingTime, proposal.endingTime) && proposal.flags[2] == false) {
            _stateStatus = ProposalState.Rejected;
        } else if (hasVotingPeriodExpired(proposal.startingTime, proposal.endingTime) && proposal.enacted == true) {
            _stateStatus = ProposalState.Enacted;
        } else if (hasVotingPeriodExpired(proposal.startingTime, proposal.endingTime)) {
            _stateStatus = ProposalState.Finished;
        }
    }

    function contains(uint256[] memory _votedProposal, uint256 proposalId) internal pure returns (bool) {
        bool isHave = false;
        for (uint256 i = 0; i < _votedProposal.length; i++) {
            if (_votedProposal[i] == proposalId) {
                isHave = true;
            }
        }
        return isHave;
    }
}