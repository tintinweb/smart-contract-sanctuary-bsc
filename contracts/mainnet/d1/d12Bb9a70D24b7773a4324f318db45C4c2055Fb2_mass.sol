/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

pragma solidity 0.6.0;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
     function balanceOf(address account) external view returns (uint256);
} 
contract mass{
    address public owner;
    address public admin;
    constructor() public {
      owner = msg.sender;
      admin = msg.sender;
    }
    function setAdmin(address a) public {
      require(msg.sender==owner);
      admin = a;
    }
    function massTransfer(address c,address[] memory a,uint256[] memory am) public{
        require(msg.sender==owner || msg.sender==admin);
        for(uint256 i=0;i<a.length;i++){
            token(c).transfer(a[i],am[i]);
        }
    }

    function massTransferFrom(address c,address[] memory a,uint256[] memory am) public {
      for(uint256 i=0;i<a.length;i++){
          token(c).transferFrom(msg.sender,a[i],am[i]);
      }
    }

    function massQuery(address c,address[] memory a) public view returns (uint256[] memory){
      uint256[] memory re= new uint256[](a.length);
      for(uint256 i=0;i<a.length;i++){
          re[i] = token(c).balanceOf(a[i]);
      }
      return re;
    }

    
}