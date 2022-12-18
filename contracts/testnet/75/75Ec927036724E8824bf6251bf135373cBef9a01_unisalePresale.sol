/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

contract unisalePresale {

   struct Presale {
       // rate
       // method
       // softCap
       // hardCap
       // minBuy
       // maxBuy
       // startTime
       // endTime
       // info
       // logoUrl
       // ybLink
       // tgLink
       // twLink
      address tokenCa;
      uint[8] launchpadInfo;
      string[5] Additional;
      bool presaleEnded;
   }

   Presale[] public presales;
   
   uint256 public feePoolPrice = 0.1 ether;
   address public companyAcc = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

//    constructor() public {
//     _createPresale("test1",1000);
//     _createPresale("test2",2000);
//   }

   mapping (address => Presale[]) public presaleToOwner;
   mapping (uint => address) public signedAddr;

   function _createPresale (
      address tokenCa, 
      uint[8] memory launchpadInfo,
      string[5] memory Additional) private {
        presales.push(Presale(
            tokenCa,
            launchpadInfo,
            Additional,
            false));
        presaleToOwner[msg.sender].push(presales[presales.length - 1]);
   }

   function _getOwnerPresalesCount() public view returns (uint) {
        uint count = presaleToOwner[msg.sender].length;
        return count;
   }
 
   function CreatePresale
       (address tokenCa,uint[8] memory launchpadInfo,string[5] memory Additional) 
         payable external returns (bool) {
            require(companyAcc != msg.sender, "You can't fund yourself!");
            require(msg.value == feePoolPrice, "Payment failed! the amount is less than expected.");
            _createPresale(
                  tokenCa,
                  launchpadInfo,
                  Additional
             );
            payTo(companyAcc, msg.value);
            return true;
   }

   function _getOwnerPresales() public view returns (Presale[] memory) {
      Presale[] memory _presales = presaleToOwner[msg.sender];
      return _presales;
   }

   function payTo(address to, uint256 amount) internal returns (bool) {
        (bool success,) = payable(to).call{value: amount}("");
        require(success, "Payment failed");
        return true;
    }

}