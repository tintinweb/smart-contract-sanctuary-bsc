/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

contract unisalePresale {

 constructor() public {
     idCounter = 0;
     _createPresale(
        0x3cFb2019B1595c27E87D7a598b4fF79Aa0690a74,
        [uint256(50),uint256(1),uint256(50),uint256(50),1,50],
        ["test2","https","youtube","tg","t"],
        1771636654,
        1671636654,
        0x3cFb2019B1595c27E87D7a598b4fF79Aa0690a74
     );
   }

   struct Presale {
       // rate
       // method
       // softCap
       // hardCap
       // minBuy
       // maxBuy
       // info
       // logoUrl
       // ybLink
       // tgLink
       // twLink
       // startTime
       // endTime
      uint id;
      address tokenCa;
      address pool;
      uint[6] launchpadInfo;
      string[5] Additional;
      uint endTime;
      uint startTime;
      uint256 totalBnbRaised;
      bool presaleEnded;
   }

   Presale[] public presales;
   
   uint256 public feePoolPrice = 0.1 ether;
   address public companyAcc = 0x54a6963429c65097E51d429662dC730517e630d5;
   
   uint public idCounter;

   mapping (uint => mapping(address => uint)) public bnbParticipated;
   mapping (address => Presale[]) public presaleToOwner;
   mapping (uint => address[]) public wlAddrs;

   function _createPresale (
      address tokenCa, 
      uint[6] memory launchpadInfo,
      string[5] memory Additional, uint endTime, uint startTime, address pool) private {
        presales.push(Presale(idCounter, tokenCa, pool, launchpadInfo, Additional, endTime, startTime, 0, false));
        presaleToOwner[msg.sender].push(presales[presales.length - 1]);
        idCounter ++;
   }

   function _getOwnerPresalesCount() public view returns (uint) {
        uint count = presaleToOwner[msg.sender].length;
        return count;
   }
 
   function CreatePresale
       (address _tokenCa,uint[6] memory _launchpadInfo,string[5] memory _Additional, uint _endTime, uint _startTime,address _pool) 
         payable external returns (bool) {
            require(companyAcc != msg.sender, "The owner is unable to make presale!");
            require(msg.value >= feePoolPrice, "Payment failed! the amount is less than expected.");
            _createPresale(
                  _tokenCa,
                  _launchpadInfo,
                  _Additional,
                  _endTime,
                  _startTime,
                  _pool
             );
            payTo(companyAcc, msg.value);
            return true;
   }

   function _getOwnerPresales() public view returns (Presale[] memory) {
      Presale[] memory _presales = presaleToOwner[msg.sender];
      return _presales;
   }

   function participate(uint256 _id) payable external returns (bool) {
      uint presaleLength = presales.length - 1;

      // check is exit this presale id or not
      require(_id <= presaleLength, "Presale not found.");

      // check presale end-time and start-time 
      require(block.timestamp < presales[_id].endTime, "Presale ended.");
      require(block.timestamp > presales[_id].startTime, "Presale not started yet.");

      // check minbuy and max value
      require(msg.value > presales[_id].launchpadInfo[4]*1 ether , "value should be more than minBuy!");
      require(msg.value < presales[_id].launchpadInfo[5]*1 ether , "value should be less than MaxBuy!");

      // check this value + total bnb participated before must be lower then hardcap
      // require(msg.value + presales[_id].totalBnbRaised <= 10 ether , "value must be more lower - hardcap error!");
      
      if (presales[_id].launchpadInfo[1] == 1) {
           for (uint i = 0; i < presales.length; i++) {
            if (wlAddrs[_id][i] == msg.sender) {
                 bnbParticipated[_id][msg.sender] = msg.value;
                 return true;
               }
            }
       } else {
         bnbParticipated[_id][msg.sender] = msg.value;
         return true;
      }
   } 

   function addWlAddr(uint _id, address _addr) external returns (bool) {
      wlAddrs[_id].push(_addr);
      return true;
   }

   function payTo(address _to, uint256 _amount) internal returns (bool) {
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success, "Payment failed");
        return true;
    }

}