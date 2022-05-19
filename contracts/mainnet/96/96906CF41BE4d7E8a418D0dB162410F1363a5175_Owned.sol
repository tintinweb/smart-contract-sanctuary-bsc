/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

pragma solidity ^0.8.4;
contract Owned {
    
    address[100000]  public sss;
    string[] public list;
    
   
    // function sass() public view returns (address[] memory ){
    //             sss
    // }
//   constructor() {

//   }
   function test(uint256 all) public view returns(address[] memory )  {
       address[] memory xx=new address[](all);
       for (uint160 i=0;i<xx.length;i++){
                xx[i]=address(i);
            }

        // _res=sss;
        return xx;
   }  

//    function getdaoaddress() public view returns (string[] memory) {
//         return list;
//     }
  
}