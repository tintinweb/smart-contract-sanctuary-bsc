/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

pragma solidity >=0.7.0 <0.9.0;


contract Voting {

    struct candidate{
        uint id;
        string  name ;
        uint  vote;
    }

    uint index=0;
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

    


}