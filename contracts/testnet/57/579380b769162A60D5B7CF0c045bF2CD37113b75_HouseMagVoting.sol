// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;


contract HouseMagVoting {
address owner;
bool finishVote = false;
 struct User_Vote{
    string name;
  }  
  event Vote(string name, string candidates);
  mapping (string => uint256) public votesReceived;
 
  string[] public candidateList;
  bytes32[] public UserList;
  mapping (bytes32 => User_Vote) public UserData;

  constructor()  {  //bytes32[] memory candidateNames
   //abi candidateList = candidateNames;
    owner = msg.sender;
  }
  
  function totalVotesFor(string memory candidate) view public returns (uint256) {
    require(!finishVote && owner == msg.sender,"Enquanto a votacao esta ativa, somente o oner pode consultar votos");
    require(validCandidate(candidate), "Candidato nao encontrado");
    return votesReceived[candidate];
    
  }
                              
  function voteForCandidate(string[] calldata names, string[][] calldata vote ) public returns (bool){//bytes32[] memory  whatsapps
      require(owner == msg.sender, "Only owner can call this function");
      string memory artistas;
      for(uint i = 0; i < vote.length; i++) {
        artistas = "[";
        for(uint y = 0; y < vote[i].length; y++)
        {  
           artistas = append(artistas, " , ", vote[i][y]);
           votesReceived[vote[i][y]] += 1;         
        }
         artistas = append(artistas, " ] ", "");
        emit Vote(names[i], artistas);
    }
    return true;
  }
  
  
  function validCandidate(string memory candidate) view public returns (bool) {
    for(uint i = 0; i < candidateList.length; i++) {
      if (keccak256(abi.encodePacked((candidateList[i]))) == keccak256(abi.encodePacked((candidate)))) {
        return true;
      }
    }
    return false;
  }
  function append(string memory a, string memory b, string memory c) internal pure returns (string memory) {

    return string(abi.encodePacked(a, b, c));

}

 function endVote()  public returns (bool) {
     finishVote = true;
    return false;
  }
  
}