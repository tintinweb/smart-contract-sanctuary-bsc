/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

pragma solidity ^0.8.7;

contract VotingDapp {



     struct Vote {
       bool Isvooted;
       bool authorize;
  }

  constructor()  {
       owner = msg.sender;
  }
   
     mapping (address => Vote) public Voter_detail ;

    mapping (string => uint256) public CandidateNoOfVoting ;
  

 modifier OnlyOwner{
        require(msg.sender == owner, "Only owner can run this function");
        _;
    }




    address public  owner ;
    
    uint256 public voter;
    address  payable  public Donationowner = payable(0xd6580EDc6d8b31B0960359c10452278c2b3171d6);
    string []  public AllCandidate;
   
    string public file;
  
   
    bool Voting_start = false; 




   
   

function addCandidate(string []  memory _candidate) public OnlyOwner {

 AllCandidate = _candidate;

}




function setFile( string  memory _file) public  OnlyOwner {
   file = _file;
}

function place_Vote(uint _place) public{
        
        require(Voter_detail[msg.sender].Isvooted == false , "Already paid" );
      

 if(_place == 1){
                CandidateNoOfVoting[AllCandidate[0]] = CandidateNoOfVoting[AllCandidate[0]] + 1 ; 
                

            }
            else if(_place == 2){
                CandidateNoOfVoting[AllCandidate[1]] = CandidateNoOfVoting[AllCandidate[1]] + 1 ; 
            }
            else if(_place == 3){
                CandidateNoOfVoting[AllCandidate[2]] = CandidateNoOfVoting[AllCandidate[2]] + 1 ;  
            }
            else if(_place == 4){
                CandidateNoOfVoting[AllCandidate[3]] = CandidateNoOfVoting[AllCandidate[3]] + 1 ;  
            }
            else if(_place == 5){
                CandidateNoOfVoting[AllCandidate[4]] = CandidateNoOfVoting[AllCandidate[4]] + 1 ;  
            }
            else if(_place == 6){
                CandidateNoOfVoting[AllCandidate[5]] = CandidateNoOfVoting[AllCandidate[5]] + 1 ;  
            }
            else if(_place == 7){
                CandidateNoOfVoting[AllCandidate[6]] = CandidateNoOfVoting[AllCandidate[6]] + 1 ;  
            }
            else if(_place == 8){
                CandidateNoOfVoting[AllCandidate[7]] = CandidateNoOfVoting[AllCandidate[7]] + 1 ;  
            }
            else if(_place == 9){
                CandidateNoOfVoting[AllCandidate[8]] = CandidateNoOfVoting[AllCandidate[8]] + 1 ;  
            }
            else if(_place == 10){
                CandidateNoOfVoting[AllCandidate[9]] = CandidateNoOfVoting[AllCandidate[9]] + 1 ;  
            }

    
   Voter_detail[msg.sender].Isvooted = true;
    voter++;

    

           
}


      
   
function SetDonationowner( address payable _owner) public   OnlyOwner {
 Donationowner = _owner;

}

function Donate() public payable {

Donationowner.transfer(msg.value);
}

function transferOwnerShip( address _owner) public  OnlyOwner {
    owner = _owner;
}

}