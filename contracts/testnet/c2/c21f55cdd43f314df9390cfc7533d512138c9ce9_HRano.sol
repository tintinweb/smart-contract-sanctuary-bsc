/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

pragma solidity ^0.4.2;

contract HRano {
    string public Name;
    uint256 public phoneNumber;
    string public Street;
    address public WalletAdress;

    function setName(string Me) public {
        Name = Me;
    }

    function setPhoneNumber(uint256 Number) public {
        phoneNumber = Number;
    }

    function setAddress(string myLocation) public {
        Street = myLocation;
    }

   function setWallet(address wallet) public {
       WalletAdress = wallet;
   }

}