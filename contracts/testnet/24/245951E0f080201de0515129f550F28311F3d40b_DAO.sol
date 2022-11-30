/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
contract DAO {
    uint256 public periodDuration; // default = 17280 = 4.8 hours in seconds (5 periods per day)
    uint256 public votingPeriodLength; // default = 35 periods (7 days)
    uint256 public summoningTime; // time DAO contract deployed
    uint256 public proposalCount = 0; // total proposals submitted
    uint256 public totalShares = 0; // total shares across all members
    uint256 public totalLoot = 0; // total loot across all members
    uint256[] public proposalQueue;
    address public constant GUILD = address(0xdead);
    address public constant ESCROW = address(0xbeef);
    address public constant TOTAL = address(0xbabe);
    mapping (address => mapping(address => uint256)) public userTokenBalances; // userTokenBalances[userAddress][tokenAddress]
    mapping (uint256 => Proposal) public proposals;
    mapping (address => Member) public members;
    mapping (address => uint256) private _payoutTotals;   // The beneficiaries address and how much they are approved for.
    event SubmitProposal(address proposer, uint256 paymentRequested, string details, bool[6] flags, uint256 proposalId, address indexed senderAddress);
    event SubmitVote(uint256 indexed proposalIndex, address indexed memberAddress, uint8 uintVote);
    event CancelProposal(uint256 indexed proposalId, address applicantAddress);
    event ProcessedProposal(address proposer, uint256 paymentRequested, string details, bool[6] flags, uint256 proposalId, address indexed senderAddress);
    event Deposit(uint256 amount);
    event Withdraw(address proposerAddress, uint256 amount);
    struct Member {
        uint256 shares; // the # of voting shares assigned to this member
        uint256 loot; // the loot amount available to this member (combined with shares on ragequit)
        bool exists; // always true once a member has been created
        uint256 jailed; // set to the proposalIndex of a passing DAO kick proposal for this member. Prevents voting on and sponsoring proposals.
    }
    struct Proposal {
        address proposer; // the account that submitted the proposal (can be non-member)
        uint256 paymentRequested; // amount of tokens requested as payment
        uint256 startingTime; // the time in which voting can start for this proposal
        uint256 yesVotes; // the total number of YES votes for this proposal
        uint256 noVotes; // the total number of NO votes for this proposal
        bool[6] flags; // [sponsored, processed, didPass, cancelled, memberAdd, memberKick]
        string details; // proposal details - could be IPFS hash, plaintext, or JSON
        mapping(address => Vote) votesByMember; // the votes on this proposal by each member
        bool exists; // always true once a member has been created
    }
    enum Vote {
        Null, // default value, counted as abstent
        Yes,
        No
    }
    modifier onlyMember {
        require(members[msg.sender].shares > 0, "Your are not a member of the DAO.");
        _;
    }
    // Members imported as an array. Only members can vote on a proposal.
    constructor(address[] memory approvedMembers) {  //["0x5fbbA5B514b303B1F047CF77888529e7ce91e83A","0x5fbbA5B514b303B1F047CF77888529e7ce91e83A"]
        for(uint256 i=0; i < approvedMembers.length; i++) {
             members[approvedMembers[i]] = Member(1, 0, true, 0);
        }
        summoningTime = block.timestamp;
        periodDuration = 17280; // 5 periods/ day = 17280, 35 periods/day = 102.85714
        votingPeriodLength = 60; // 7 days = 604800, 1 hr = 3600
    }
    // An allowance is given to a proposer when their proposal gets a majority vote and the voting period has expired.
    function _increasePayout(address recipient, uint256 addedValue) internal returns (bool) {
        // The if statement is not helping.
        _payoutTotals[recipient] = addedValue + _payoutTotals[recipient];
        return true;
    }
    function _decreasePayout(address beneficiary, uint256 subtractedValue) internal returns (bool) {
        uint256 currentAllowance = _payoutTotals[beneficiary];
        require(currentAllowance >= subtractedValue, "ERC20: decreased payout below zero");
        uint256 newAllowance = currentAllowance - subtractedValue;
        _payoutTotals[beneficiary] = newAllowance;
        return true;
    }
    function payout(address recipient) public view returns (uint256) {
        return _payoutTotals[recipient];
    }
    // A proposer calls function and if address has an allowance, recieves ETH in return.
    function getPayout(address addressOfProposer) public {
        uint256 allowanceAvailable = _payoutTotals[addressOfProposer];  // Get the available allowance first amd store in uint256.
        require(allowanceAvailable > 0, "You do not have any funds available."); // No if statement is necessary. 
        payable(addressOfProposer).transfer(allowanceAvailable);  // Move down below _decreasePayout to create Re-Entrancy vulnerabilty.
        _decreasePayout(addressOfProposer, allowanceAvailable);
        emit Withdraw(addressOfProposer, allowanceAvailable);
    }
    // Vote on adding new members who want to contribute funds or work.
    // OR kick members who do not contribute.
    function addMember(address newMemAddress, string memory details) public onlyMember {
        _SubmitMemberProposal(newMemAddress, details, 0); // 0 adds a member
    }
    function kickMember(address memToKick, string memory details) public onlyMember {
        _SubmitMemberProposal(memToKick, details, 1);  // 1 kicks a member
    }
    // Create a proposal that shows the address (member to be added) as the proposer. And sets the flags to indicate the type of proposal, either add or kick.
    function _SubmitMemberProposal(address entity, string memory details, uint256 action) internal {
        proposalQueue.push(proposalCount);
        if(action == 0) {
            Proposal storage prop = proposals[proposalCount];
            prop.proposer = entity;
            prop.paymentRequested = 0;
            prop.startingTime = block.timestamp;
            prop.flags = [false, false, false, false, true, false]; // memberAdd
            prop.details = details;
            prop.exists = true;
            emit SubmitProposal(prop.proposer, 0, prop.details, prop.flags, proposalCount, msg.sender);
            proposalCount += 1;
        }
        if(action == 1) {
            Proposal storage prop = proposals[proposalCount];
            prop.proposer = entity;
            prop.paymentRequested = 0;
            prop.startingTime = block.timestamp;
            prop.flags = [false, false, false, false, false, true]; // memberkick
            prop.details = details;
            prop.exists = true;
            emit SubmitProposal(prop.proposer, 0, prop.details, prop.flags, proposalCount, msg.sender);
            proposalCount += 1;
        }
    }
    // SUBMIT PROPOSAL, public function
    // Set applicant, paymentRequested, timelimit, details.
    // All payments made in the native currency.
    function submitProposal(uint256 paymentRequested, string memory details) public returns (uint256 proposalId) {
        address applicant = msg.sender;
        require(applicant != address(0), "applicant cannot be 0");
        require(members[applicant].jailed == 0, "proposal applicant must not be jailed");
        bool[6] memory flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick]
        _submitProposal(paymentRequested, details, flags);
        return proposalCount - 1; // return proposalId - contracts calling submit might want it
    }
    // Internal submit function
    function _submitProposal(uint256 paymentRequested, string memory details, bool[6] memory flags) internal {
        proposalQueue.push(proposalCount);
        Proposal storage prop = proposals[proposalCount];
        prop.proposer = msg.sender;
        prop.paymentRequested = paymentRequested;
        prop.startingTime = block.timestamp;
        prop.flags = flags;
        prop.details = details;
        prop.exists = true;
        address memberAddress = msg.sender;
        emit SubmitProposal(msg.sender, paymentRequested, details, flags, proposalCount, memberAddress);
        proposalCount += 1;
    }
    // Function cancels a proposal if it has not been cancelled already.
    function _cancelProposal(uint256 proposalId) internal onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.flags[3], "proposal has already been cancelled");
        proposal.flags[3] = true; // cancelled

        emit CancelProposal(proposalId, msg.sender);
    }
    // Function which can be called when the proposal voting time has expired. To either act on the proposal or cancel if not a majority yes vote.
    function processProposal(uint256 proposalId) public onlyMember returns (bool) {
        require(proposals[proposalId].exists, "This proposal does not exist.");
        require(proposals[proposalId].flags[1] == false, "This proposal has already been processed");
        require(getCurrentTime() >= proposals[proposalId].startingTime, "voting period has not started");
        require(hasVotingPeriodExpired(proposals[proposalId].startingTime), "proposal voting period has not expired yet");
        require(proposals[proposalId].paymentRequested <= address(this).balance, "DAO balance too low to accept the proposal.");
        for(uint256 i=0; i<proposalQueue.length; i++) {
            if (proposalQueue[i]==proposalId) {
                delete proposalQueue[i];
            }
        }
        Proposal storage prop = proposals[proposalId];
        if(prop.flags[4] == true) { // Member add
            if(prop.yesVotes > prop.noVotes) {
                members[prop.proposer] = Member(1, 0, true, 0);
                prop.flags[1] = true;
                prop.flags[2] = true;
            }
            else{
                prop.flags[1] = true;
                prop.flags[3] = true;
            }
            return true;
        }
        if(prop.flags[5] == true) { // Member kick
            if(prop.yesVotes > prop.noVotes) {
                    members[prop.proposer].shares = 0;
                    prop.flags[1] = true;
                    prop.flags[2] = true;
                }
                else{
                    prop.flags[1] = true;
                    _cancelProposal(proposalId);
                }
        }
        if(prop.flags[4] == false && prop.flags[5] == false) {
            if(prop.yesVotes > prop.noVotes) {
                prop.flags[1] = true;
                prop.flags[2] = true;
                _increasePayout(prop.proposer, prop.paymentRequested);
            }
            else{
                prop.flags[1] = true;
                _cancelProposal(proposalId);
            }
        }
        emit ProcessedProposal(prop.proposer, prop.paymentRequested, prop.details, prop.flags, proposalId, prop.proposer);
        return true;
    }
    // Function to submit a vote to a proposal if you are a member of the DAO and you have not voted yet.
    // Voting period must be in session
    function submitVote(uint256 proposalId, uint8 uintVote) public onlyMember {
        require(members[msg.sender].exists, "Your are not a member of the DAO.");
        require(proposals[proposalId].exists, "This proposal does not exist.");
        require(uintVote < 3, "must be less than 3");
        Vote vote = Vote(uintVote);
        address memberAddress = msg.sender;
        Member storage member = members[memberAddress];
        Proposal storage prop = proposals[proposalId];
        require(getCurrentTime() >= prop.startingTime, "voting period has not started");
        require(!hasVotingPeriodExpired(prop.startingTime), "proposal voting period has expired");
        require(prop.votesByMember[memberAddress] == Vote.Null, "member has already voted");
        require(vote == Vote.Yes || vote == Vote.No, "vote must be either Yes or No");
        prop.votesByMember[memberAddress] = vote;
        if (vote == Vote.Yes) {
            prop.yesVotes = prop.yesVotes + member.shares;
        }
        else if (vote == Vote.No) {
            prop.noVotes = prop.noVotes + member.shares;
        }
        emit SubmitVote(proposalId, memberAddress, uintVote);
    }
    // Function to receive Ether, msg.data must be empty
    receive() external payable {}
    // Deposit function to provide liquidity to DAO contract
    function deposit() public payable returns (uint256) {
        require(msg.value > 0);
        uint256 deposited = msg.value;
        payable(address(this)).transfer(deposited);
        emit Deposit(msg.value);
        return(deposited);
    }
    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }
    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }
    function getProposalQueueLength() public view returns (uint256) {
        return proposalQueue.length;
    }
    function getProposalFlags(uint256 proposalId) public view returns (bool[6] memory) {
        return proposals[proposalId].flags;
    }
    function getUserTokenBalance(address user, address token) public view returns (uint256) {
        return userTokenBalances[user][token];
    }
    function getMemberProposalVote(address memberAddress, uint256 proposalIndex) public view returns (Vote) {
        require(members[memberAddress].exists, "member does not exist");
        require(proposalIndex < proposalQueue.length, "proposal does not exist");
        return proposals[proposalQueue[proposalIndex]].votesByMember[memberAddress];
    }
    // HELPER FUNCTIONS
    function unsafeAddToBalance(address user, address token, uint256 amount) internal {
        userTokenBalances[user][token] += amount;
    }
    function unsafeSubtractFromBalance(address user, address token, uint256 amount) internal {
        userTokenBalances[user][token] -= amount;
    }
    function unsafeInternalTransfer(address from, address to, address token, uint256 amount) internal {
        unsafeSubtractFromBalance(from, token, amount);
        unsafeAddToBalance(to, token, amount);
    }
    function hasVotingPeriodExpired(uint256 startingTime) public view returns (bool) {
        return (getCurrentTime() >= (startingTime + votingPeriodLength));
    }
}