/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

pragma solidity ^0.8.0;

pragma experimental ABIEncoderV2;

contract SavingsAccount {

  struct Member{
    uint id;
    string name;
    uint balance;
  }

  mapping (uint => Member) public members;
  event savingsEvent(uint indexed _memberId);
  uint public memberCount;

  constructor() public {
    memberCount = 0;
    addMember("chris",9000);
    addMember("yassin",6000);
  }
  
  function addMember(string memory _name,uint _balance) public {
    members[memberCount] = Member(memberCount,_name,_balance);
    memberCount++;
  }
  //return Single structure
  function get(uint _memberId) public view returns(Member memory) {
    return members[_memberId];
  }
  //return Array of structure Value
  function getMember() public view returns (uint[] memory, string[] memory,uint[] memory){
      uint[]    memory id = new uint[](memberCount);
      string[]  memory name = new string[](memberCount);
      uint[]    memory balance = new uint[](memberCount);
      for (uint i = 0; i < memberCount; i++) {
          Member storage member = members[i];
          id[i] = member.id;
          name[i] = member.name;
          balance[i] = member.balance;
      }

      return (id, name,balance);

  }
  //return Array of structure
  function getMembers() public view returns (Member[] memory){
      Member[] memory id = new Member[](memberCount);
      for (uint i = 0; i < memberCount; i++) {
          Member storage member = members[i];
          id[i] = member;
      }
      return id;
  }
}