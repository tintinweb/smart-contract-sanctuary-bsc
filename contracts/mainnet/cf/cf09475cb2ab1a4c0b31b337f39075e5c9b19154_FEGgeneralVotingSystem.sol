/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;
abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IStakeV2 {
    function userStakedFEG(address user) external view returns(uint256 StakedFEG);
}
interface IStakeV1 {
        function yourFEGBalance(address user) external view returns(uint256 FEGBalance);
}

interface IERC20 {
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    
    function calculateFeesBeforeSend(
        address sender,
        address recipient,
        uint256 amount
    ) external view returns (uint256, uint256);
    
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

struct Vote{
    uint256 won;
    uint256 final_ammount1;
    uint256 final_ammount2;
    uint256 final_ammount3;
    uint256 final_ammount4;
    bool open;
    string question;
    string option1;
    string option2;
    string option3;
    string option4;
    address[] voters;
    uint256[] vote; 
}

contract FEGgeneralVotingSystem is ReentrancyGuard{

    
    address private StakeV1 = 0x5bCF1f407c0fc922074283B4e11DaaF539f6644D;
    address private StakeV2 = 0xF8303c3ac316b82bCbB34649e24616AA9ED9E5F4;
    address private FEG = 0xacFC95585D80Ab62f67A14C566C1b7a49Fe91167;

    mapping(address=>bool) owners;
    mapping(uint256=>Vote) votingContracts;
    
    uint256 currentContract = 0;

    constructor(){
        owners[address(msg.sender)] = true;
    }

    function votingpower(address voter) private view returns(uint256){
        uint256 total = IERC20(FEG).balanceOf(voter);
        total += IStakeV1(StakeV1).yourFEGBalance(voter);
        total += IStakeV2(StakeV2).userStakedFEG(voter);
        return total;
    }

    function vote(uint256 voteid,uint256 option) external nonReentrant{
        // Number needs to be the same as the otpion number!!!
        require(!isContract(msg.sender),"Not allowed");
        require( votingContracts[voteid].open,"Vote is already closed");
        address voter = address(msg.sender);
        require(!hasVoted(voter,voteid),"Already voted for this question");
        require(voteid < currentContract,"The vote hasn't yet been created  be patient");
        if(option == 3){
        bytes memory tempEmptyStringTest = bytes( votingContracts[voteid].option3);
        require(tempEmptyStringTest.length != 0,"You can't vote for nothing");
        }
        else if(option == 4){
        bytes memory tempEmptyStringTest = bytes( votingContracts[voteid].option4); 
        require(tempEmptyStringTest.length != 0,"You can't vote for nothing");
        }
        votingContracts[voteid].vote.push(option);
        votingContracts[voteid].voters.push(address(msg.sender));
    }

    function getVote(uint256 id) external view returns(Vote memory){
        return votingContracts[id];
    }

    function max(uint256 a,uint256 b) private pure returns(uint256 maximum){
        return a>=b?a:b;
    }

    function closeVote(uint256 voteid) external {
        require(owners[address(msg.sender)] , "You are not allowed to");
        votingContracts[voteid].open = false;
        (uint256 a,uint256 b,uint256 c,uint256 d,uint256 e) = getLeader(voteid);
        votingContracts[voteid].won = a;
        votingContracts[voteid].final_ammount1 = b;
        votingContracts[voteid].final_ammount2 = c;
        votingContracts[voteid].final_ammount3 = d;
        votingContracts[voteid].final_ammount4 = e;

    }

    function getLeader(uint256 voteid) public view returns(uint256 leadingoption,uint256 final_1,uint256 final_2,uint256 final_3,uint256 final_4){
        if(votingContracts[voteid].won != 0){
            return (votingContracts[voteid].won,votingContracts[voteid].final_ammount1,votingContracts[voteid].final_ammount2,votingContracts[voteid].final_ammount3,votingContracts[voteid].final_ammount4);
        }
        uint256 _option1 = 0;
        uint256 _option2 = 0;
        uint256 _option3 = 0;
        uint256 _option4 = 0;
         for (uint i=0; i<votingContracts[voteid].voters.length; i++) {
            if(votingContracts[voteid].vote[i] == 1){
                _option1 += votingpower(votingContracts[voteid].voters[i]);
             }
            else if(votingContracts[voteid].vote[i] == 2){
                 _option2 += votingpower(votingContracts[voteid].voters[i]);
             }
            else if(votingContracts[voteid].vote[i] == 3){
                 _option3 += votingpower(votingContracts[voteid].voters[i]);
             }
            else if(votingContracts[voteid].vote[i] == 4){
                 _option4 += votingpower(votingContracts[voteid].voters[i]);
             }
            
         }
        uint256 maximum = max(max(_option1,_option2),max(_option3,_option4));
        if(_option1 == maximum){
            return (1,_option1,_option2,_option3,_option4);
        }
        else if(_option2 == maximum){
            return (2,_option1,_option2,_option3,_option4);
        }
        else if(_option3 == maximum){
            return (3,_option1,_option2,_option3,_option4);
        }
        else if(_option4 == maximum){
            return (4,_option1,_option2,_option3,_option4);
        }
    }

    function hasVoted(address voter,uint256 voteid) public view returns(bool){
        for (uint i=0; i<votingContracts[voteid].voters.length; i++) {
            if(votingContracts[voteid].voters[i] == voter){
                return true;
            }
        }
        return false;
    }
    function addOwner(address voter) external{
        require(owners[address(msg.sender)] , "You are not allowed to");
        owners[voter] = true;
    }
    function createVotingSubject(string calldata subject,string calldata _option1,string calldata _option2,string calldata _option3,string calldata _option4) external{
        require(owners[address(msg.sender)],"You are not allowed");
        address[] memory _addr;
        uint256[] memory _vote;
        votingContracts[currentContract] =  Vote(0,0,0,0,0,true,subject,_option1,_option2,_option3,_option4,_addr,_vote);
        currentContract += 1;
    }

    function isContract(address account) internal view returns(bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

}