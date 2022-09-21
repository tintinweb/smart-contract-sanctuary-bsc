//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface Itoken {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 retue);

    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 retue
    );
}
contract DAO {
    // variables
    struct Member {
        address publicAddress;
        uint256 score;
        bool active;
    }

    struct CandidancyProposal {
        address candidate;
        uint256 forVotes;
        uint256 againstVotes;
        address[] sponsors;
        address[] voters;
        mapping(address => bool) voted;
    }

    Member[] public allMembers;
    Itoken public GovernanceToken;
    uint256 SCORE_AFTER_VOTE = 100;
    address public OWNER;
    address public treasureWallet;
    uint256[] public airdropamounts = [10000,5000,2500];
    uint256[] public airdropmembersrequired = [100,1000,10000];

    mapping(address => Member) public members;
    mapping(address => uint256) public _balances;

    mapping(address => CandidancyProposal) public candidancyProposals;

    mapping(address => bool) public blacklisted;

    uint256 public proposalsCreated = 0;

    constructor(address _owner) {
        GovernanceToken = Itoken(0xBc20518069A61bF4d1a05A51056146E5797630FF);
        members[_owner].publicAddress = _owner;
        members[_owner].score = 1;
        members[_owner].active = true;
        OWNER = _owner;
        allMembers.push(members[_owner]);
        treasureWallet = msg.sender;
    }

    function signAsSponsor(address user) public {
        require(members[msg.sender].active,"not a member");
        candidancyProposals[user].sponsors.push(msg.sender);
    }

    function getSponsorsOfProposal(address user)
        public
        view
        returns (address[] memory)
    {
        return candidancyProposals[user].sponsors;
    }
    function calculateResult(address user) public returns (bool ) {
        require(msg.sender == OWNER,"only the owner can call this function");
        uint256 forVotes = candidancyProposals[user].forVotes;
        uint256 againstVotes = candidancyProposals[user].againstVotes;
        if (forVotes > againstVotes) {
            
            members[candidancyProposals[user].candidate].publicAddress = candidancyProposals[user].candidate;
            members[candidancyProposals[user].candidate].score = 0;
            members[candidancyProposals[user].candidate].active = true;
            // add scores for sponsor
            for (
                uint256 i;
                i < candidancyProposals[user].sponsors.length;
                i++
            ) {
                members[candidancyProposals[user].sponsors[i]]
                    .score += SCORE_AFTER_VOTE;
                GovernanceToken.transferFrom(treasureWallet,candidancyProposals[user].sponsors[i],SCORE_AFTER_VOTE*(10**(GovernanceToken.decimals())));
            }
            if(allMembers.length<airdropmembersrequired[0]){
                GovernanceToken.transferFrom(treasureWallet,candidancyProposals[user].candidate,airdropamounts[0]*(10**(GovernanceToken.decimals())));
            }
            else if(allMembers.length<airdropmembersrequired[1]){
                GovernanceToken.transferFrom(treasureWallet,candidancyProposals[user].candidate,airdropamounts[1]*(10**(GovernanceToken.decimals())));
            }
            else if(allMembers.length<airdropmembersrequired[2]){
                GovernanceToken.transferFrom(treasureWallet,candidancyProposals[user].candidate,airdropamounts[2]*(10**(GovernanceToken.decimals())));
            }
            return true;
        } else {
            blacklisted[candidancyProposals[user].candidate] = true;
            return false;
        }
    }

    function voteToCandidancyProposal(bool vote, address user) public {
        // give vote
        require(members[msg.sender].active,"not a member");
        require(!blacklisted[user],"user is blacklisted");
        require(!members[user].active,"user is already a member");
        require(candidancyProposals[user].candidate != msg.sender,"you can't vote for yourself");
        require(!candidancyProposals[user].voted[msg.sender],"you have already voted");

        if (vote) {
            candidancyProposals[user].forVotes += members[msg.sender].score;
        } else {
            candidancyProposals[user].againstVotes += members[msg.sender].score;
        }

        members[msg.sender].score += 1;
        GovernanceToken.transferFrom(treasureWallet,msg.sender,1*(10**(GovernanceToken.decimals())));

        candidancyProposals[user].voters.push(msg.sender);
        candidancyProposals[user].voted[msg.sender] = true;
    }

    function saveCandidancyProposal() public {
        require(!blacklisted[msg.sender],"user is blacklisted");
        require(allMembers.length<airdropmembersrequired[2],"Limit reached");

        candidancyProposals[msg.sender].candidate = msg.sender;
        candidancyProposals[msg.sender].forVotes = 0;
        candidancyProposals[msg.sender].againstVotes = 0;

        proposalsCreated++;
    }

    function trasferOwnership(address user) public {
        require(msg.sender == OWNER,"only the owner can call this function");
        require(user != address(0),"user is not valid");
        OWNER = user;
        members[OWNER].publicAddress = OWNER;
        members[OWNER].score = 0;
        members[OWNER].active = true;
        allMembers.push(members[OWNER]);
    }

    function setScore(uint256 score) public {
        require(msg.sender == OWNER,"only the owner can call this function");
        SCORE_AFTER_VOTE = score;
    }

    function withdrawlostfunds(Itoken token) external {
        require(msg.sender == OWNER,"only the owner can call this function");
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function cliamable(address user) public view returns(uint256 amount){
        if(_balances[user] < members[user].score){
            return  members[user].score-_balances[user];
        }
    return 0;

    }

}