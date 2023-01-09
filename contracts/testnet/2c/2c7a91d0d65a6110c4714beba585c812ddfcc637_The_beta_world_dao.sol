/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
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

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: new_contract/dao.sol


pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
contract The_beta_world_dao{
    address public Owner;
    uint public ProposalFee;
    uint public Vote_balance;
    address public tokenaddress;
    address public NativeToken;
    //uint public totalProposal;
    using Counters for Counters.Counter;
    Counters.Counter public totalProposal;
    IBEP20 NativeContractToken;


    struct Post{
        uint id;
        address creator;
        string Proposal_Url;
        uint endtime;
        bool status;
        uint VoteFor;
        uint VoteAgainst;
    }
    mapping(uint => address[]) public Foraddress;
    mapping(uint => address[]) public Againstaddress;
    mapping(uint256 => Post) public idToPost;
    mapping (address => uint256) public UserpostCount;
    mapping (uint => address[]) public voterlist;


    constructor(address _owner,address _nativeToken,uint _proposalFee, uint _vote_balance){
        Owner = _owner;
        NativeToken = _nativeToken;
        NativeContractToken = IBEP20(_nativeToken);
        ProposalFee = _proposalFee;
        Vote_balance = _vote_balance;
    }

    function ChangeOwner(address NewOwner) public{
        require (msg.sender == Owner,"Not an owner");
        Owner = NewOwner;
    }
    function ChnageToken(address NewToken) public{
        require(msg.sender == Owner, "Not an owner");
        NativeToken = NewToken;
        NativeContractToken = IBEP20(NewToken);
    }
    function ChangeProposalFee (uint NewproposalFee) public{
        require(msg.sender == Owner, "Not an owner");
        ProposalFee = NewproposalFee;
    }
    function ChangeVoteBalance(uint NewVote_balance) public{
        require(msg.sender == Owner, "Not an owner");
        Vote_balance = NewVote_balance;
    }
    function CreateProposal(string memory _Url,uint _endtime) public{
        totalProposal.increment();
        uint NewProposalId = totalProposal.current();
        NativeContractToken.transferFrom(msg.sender,Owner, ProposalFee);
        Post memory post = Post({
            id: NewProposalId,
            creator: msg.sender,
            Proposal_Url: _Url,
            endtime:_endtime,
            status: false,
            VoteFor:0,
            VoteAgainst:0
        });
        idToPost[NewProposalId] = post;
        UserpostCount[msg.sender] +=1;

    }
    function checkVotedvoter(uint id) public view returns (bool){
        uint count = voterlist[id].length;
        if (count ==0) {return false;}else{
        //address [] memory  list = voterlist[id];
            for (uint i = 0; i < count; i++) {
            if (voterlist[id][i] == msg.sender) {
                return true;
            }
        }
        }
        return false;
    }

    function Vote (uint id, uint _Vote) public{
       require(NativeContractToken.balanceOf(msg.sender)>= Vote_balance," Dont have sufficient balance");
        require (checkVotedvoter(id) == false,"already voted");
        require(idToPost[id].endtime > block.timestamp,"voteing is closed");
        uint vote = _Vote;
        if (vote ==0) {
            idToPost[id].VoteFor +=1;
            Foraddress[id].push(msg.sender);
            voterlist[id].push(msg.sender);

        } else {
            idToPost[id].VoteAgainst +=1;
            Againstaddress[id].push(msg.sender);
            voterlist[id].push(msg.sender);
        }
    }

    function isProposalActive(uint id)  public view  returns (bool) {
        idToPost[id].endtime > block.timestamp;
        return true;
    }
    function listActiveProposal() public view returns(Post [] memory){
        uint postidcount = totalProposal.current();
        uint activepostCount =0;
        uint current1 = 0;
        for (uint i=0; i<postidcount; i++) 
        {
            if (idToPost[i+1].endtime > block.timestamp){
                activepostCount +=1;
            }
        }
        Post[] memory item1 = new Post[](activepostCount);
        for (uint i=0; i<postidcount; i++){
            if (idToPost[i+1].endtime > block.timestamp){
                uint currentId1 = idToPost[i+1].id;
                Post storage currentItem = idToPost[currentId1];
                item1[current1] = currentItem;
                current1 +=1;
            }
        }
        return item1;
    }
    function ListMyPost() public view returns (Post [] memory){
        uint postidcount = totalProposal.current();
        uint activepostCount =0;
        uint current1 = 0;
         for (uint i=0; i< postidcount; i++){
            if(idToPost[i+1].creator ==msg.sender){
                activepostCount +=1;
            }
        }
        Post[] memory item1 = new Post[](activepostCount);
        for (uint i=0; i<postidcount; i++){
            if(idToPost[i+1].creator ==msg.sender){
                 uint currentId1 = idToPost[i+1].id;
                Post storage currentItem = idToPost[currentId1];
                item1[current1] = currentItem;
                current1 +=1;
            }
        }
        return item1; 
    } 
    function isproposalPassed(uint id) public view returns (bool){
        uint yes = idToPost[id].VoteFor;
        uint no = idToPost[id].VoteAgainst;
        uint sum = yes + no;
        if(yes > sum/2){
        return true;}
        else
        {return false;}
    }
}