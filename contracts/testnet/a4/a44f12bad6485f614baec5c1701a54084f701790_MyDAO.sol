/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function _mint(address account, uint256 amount) external returns (uint256);
    function _burn(address account, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyDAO {
    
    IBEP20 public token;

    address public owner;

    enum VotingOptions {
        Yes,
        No
    }

    enum Action {
        Burn,
        Mint
    }
    enum Status {
        Accepted,
        Rejected,
        Pending
    }

    struct Proposal {
        uint256 id;
        
        uint256 mintTokens;

        uint256 burnTokens;

        address author;
     
        uint256 createdAt;
       
        uint256 votesForYes;
        
        uint256 votesForNo;
        
        Status status;
     
        string name;

        bool burned;

        bool minted;
    }

 
    mapping(uint256 => Proposal) public proposals;

  
    mapping(address => mapping(uint256 => bool)) public votesHistory;

 
    mapping(address => uint256) public shares;

    uint256 public totalShares;


    uint256 private constant CREATE_PROPOSAL_MIN_SHARE = 20 * 10**18;

    
    uint256 private constant VOTING_MAX_TIME = 7 days;

    uint256 public proposalIndex;

    constructor(address tokenAddress, address _owner) {
        owner = _owner;
        token = IBEP20(tokenAddress);
      
    }

 
    function deposit(uint256 amount) external {
        shares[msg.sender] += amount;
        totalShares += amount;

        (bool success) = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Deposit fail");
    }

 
    function withdraw(uint256 amount) external {
        require(shares[msg.sender] >= amount, "Amount exceed");

        shares[msg.sender] -= amount;
        totalShares -= amount;

        (bool success) = token.transfer(msg.sender, amount);
        require(success, "Withdraw fail");
    }

    
    function createProposal(string memory name, uint256 _mintTokens, uint256 _burnTokens) external {
        require(
            shares[msg.sender] >= CREATE_PROPOSAL_MIN_SHARE,
            "Not enough shares"
        );

      
        proposals[proposalIndex] = Proposal(
            proposalIndex,
            _mintTokens,
            _burnTokens,
            msg.sender, 
            block.timestamp, 
            0,
            0,
            Status.Pending,
            name,
            false,
            false
        );

        proposalIndex++;
    }

    
    function vote(uint256 proposalId, VotingOptions voteOption) external {
        Proposal storage proposal = proposals[proposalId];

        require(!votesHistory[msg.sender][proposalId], "Already voted");

        require(
      
            block.timestamp <= proposal.createdAt + VOTING_MAX_TIME,
            "Voting period is over"
        );

        votesHistory[msg.sender][proposalId] = true;

        if (voteOption == VotingOptions.Yes) {
          
            proposal.votesForYes += shares[msg.sender];

            if ((proposal.votesForYes * 100) / totalShares > 50) {
                proposal.status = Status.Accepted;
            }
        } else {
         
            proposal.votesForNo += shares[msg.sender];

           
            if ((proposal.votesForNo * 100) / totalShares > 50) {
                proposal.status = Status.Rejected;
            }
        }
    }
function execution(uint256 proposalId, Action action)public {
     require(proposals[proposalId].status ==  Status.Accepted, " This proposal is not accepted yet");
     if(action == Action.Burn &&   proposals[proposalId].burned == false ){
     uint _burnTokens = token.balanceOf(owner) - proposals[proposalId].burnTokens;
     token._burn(owner, _burnTokens);
     proposals[proposalId].burned = true;
     }
     else {
      require(proposals[proposalId].minted == false, "This proposal is already minted" );
     token._mint(owner, proposals[proposalId].mintTokens);
     proposals[proposalId].minted = true;
     }
     
}
    
}