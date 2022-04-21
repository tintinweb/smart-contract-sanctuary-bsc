/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

 contract Referral {
     
      // string[] giver = ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
      // string[] used = ["0x617F2E2fD72FD9D5503197092aC168c91465E7f2","0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678","0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c"]
  
       mapping (address => address) private give_gift_1;
      string[] public all_giver;

    
      
      function add_to_list (string[] memory _giver,string[] memory _used)   public  {
        for(uint8 i;i<_giver.length;i++){
           give_gift_1[parseAddr(_used[i])] = parseAddr(_giver[i]);
           all_giver.push(_giver[i]);
         
        }
      }

   function get_map (address  _address)   public view returns(address) {
 
    // if(bytes(give_gift[_address]).length > bytes("").length){
      return  give_gift_1[_address];
   }
      function pay_to_giver(address _address)   public view   returns(bool)  {
  
      require(get_map(_address) != address(0), "SafeMath: multiplication overflow");
      return true;
   }
    function get_couneter()   public view returns(uint) {
      return all_giver.length;
   }
     function get_all_giver()   public view returns(string[] memory) {
      return all_giver;
   }
  function toString(address account) public pure returns(string memory) {
    return toString2(abi.encodePacked(account));
}



function toString2(bytes memory data) public pure returns(string memory) {
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = "0";
    str[1] = "x";
    for (uint i = 0; i < data.length; i++) {
        str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
        str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
    }
    return string(str);
}

function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
    bytes memory tmp = bytes(_a);
    uint160 iaddr = 0;
    uint160 b1;
    uint160 b2;
    for (uint i = 2; i < 2 + 2 * 20; i += 2) {
        iaddr *= 256;
        b1 = uint160(uint8(tmp[i]));
        b2 = uint160(uint8(tmp[i + 1]));
        if ((b1 >= 97) && (b1 <= 102)) {
            b1 -= 87;
        } else if ((b1 >= 65) && (b1 <= 70)) {
            b1 -= 55;
        } else if ((b1 >= 48) && (b1 <= 57)) {
            b1 -= 48;
        }
        if ((b2 >= 97) && (b2 <= 102)) {
            b2 -= 87;
        } else if ((b2 >= 65) && (b2 <= 70)) {
            b2 -= 55;
        } else if ((b2 >= 48) && (b2 <= 57)) {
            b2 -= 48;
        }
        iaddr += (b1 * 16 + b2);
    }
    return address(iaddr);
}
 }