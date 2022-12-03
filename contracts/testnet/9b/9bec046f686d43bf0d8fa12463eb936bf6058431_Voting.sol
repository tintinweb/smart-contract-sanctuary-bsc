/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

pragma solidity >=0.7.0 <0.9.0;

contract Voting{

    struct candidate{
        uint id;
        string  name ;
        uint  vote;
    }

    uint index=1;
    mapping (uint=>candidate) public candidate_list;
    mapping(address => bool) public voterLookup;
    address public owner;

    constructor (){
        owner = msg.sender;

        create_candidate("PTI");
        create_candidate("PML");
        create_candidate("PPP");
    }
    modifier isOwner(){
      require( msg.sender== owner,"not a owner");
        _;
    }

    function create_candidate(string memory _name) public isOwner {

              candidate_list[index]=candidate(index,_name,0);
              index++;
    }

    
    function voting (uint _id) public {
           require (!voterLookup[msg.sender]);
            candidate_list[_id].vote++;
            voterLookup[msg.sender]=true;
    }

    function getAllCandidates () public view returns (string[] memory ,uint[] memory){

        string[] memory candidateName=new string[](index);
        uint[]  memory vote=new uint[](index);
        for(uint i=0;i<=index;i++){
           candidateName[i]=candidate_list[i].name;
           vote[i]=  candidate_list[i].vote;
        }
        return (candidateName,vote);
    }

}