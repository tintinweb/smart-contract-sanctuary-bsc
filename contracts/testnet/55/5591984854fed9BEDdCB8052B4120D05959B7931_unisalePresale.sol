/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

contract unisalePresale {

   struct Presale {
      string name;
      uint amount;
   }

   Presale[] public presales;
   uint256 public feePoolPrice = 0.005 ether;
   address public companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;

   constructor() public {
    _createPresale("test1",1000);
    _createPresale("test2",2000);
  }

   mapping (address => Presale[]) public presaleToOwner;

   function _createPresale(string memory _name, uint _amount) private {
        presales.push(Presale(_name,_amount));
        presaleToOwner[msg.sender].push(presales[presales.length - 1]);
   }

   function _getOwnerPresalesCount() public view returns (uint) {
        uint count = presaleToOwner[msg.sender].length;
        return count;
   }
 
   function CreatePresale(string memory _name, uint _amount) external payable {
      // require(msg.value == feePoolPrice, "not paid");
      _createPresale(_name,_amount);
   }

   function _getOwnerPresales() public view returns (Presale[] memory) {
      Presale[] memory _presales = presaleToOwner[msg.sender];
      return _presales;
   }

    function fundCompanyAcc() payable external returns (bool) {
        require(companyAcc != msg.sender, "You can't fund yourself!");
        payTo(companyAcc, msg.value);
        return true;
    }

   function payTo(address to, uint256 amount) internal returns (bool) {
        (bool success,) = payable(to).call{value: amount}("");
        require(success, "Payment failed");
        return true;
    }

}