/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: no-license
pragma solidity ^0.8.17;

contract unisalePresale {

 constructor() {
     idCounter = 0;
     _createPresale(
        0x3cFb2019B1595c27E87D7a598b4fF79Aa0690a74,
        [uint256(50),uint256(0),uint256(50),uint256(50),0.1 ether,50],
        ["test2","https","youtube","tg"],
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
       // tgLink
       // ybLink
       // twLink
       // startTime
       // endTime
       // totalBnbRaised
       // presaleEnded
      uint id;
      address tokenCa;
      address pool;
      uint[6] launchpadInfo;
      string[4] Additional;
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
   mapping (uint => mapping(address => bool)) public tokensPaid;
   mapping (address => Presale[]) public presaleToOwner;
   mapping (uint => address) public prsIdtoOwner;
   mapping (uint => address[]) public wlAddrs;
   
  
   function _createPresale (
      address tokenCa, 
      uint[6] memory launchpadInfo,
      string[4] memory Additional, uint endTime, uint startTime, address pool) private {
        presales.push(Presale(idCounter, tokenCa, pool, launchpadInfo, Additional, endTime, startTime, 0, false));
        presaleToOwner[msg.sender].push(presales[presales.length - 1]);
        prsIdtoOwner[presales.length - 1] = msg.sender;
        idCounter ++;
   }
 
   function CreatePresale (
      address _tokenCa,
      uint256[6] memory _launchpadInfo,
      string[4] memory _Additional, 
      uint _endTime, uint _startTime,
      address _pool) 
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
   
   function _getOwnerPresalesCount() public view returns (uint) {
        uint count = presaleToOwner[msg.sender].length;
        return count;
   }

   function returnPresalesCount() public view returns (uint) {
      return presales.length;
   }

   function returnPresale(uint _id) public view returns(Presale memory) {
      return presales[_id];
   }

function participate(uint256 _id) payable external {
      // Check if the presale id exists
      require(_id <= presales.length - 1, "Presale not found.");

      // Check presale start and end time
      require(block.timestamp > presales[_id].startTime, "Presale not started yet.");
      require(block.timestamp < presales[_id].endTime, "Presale ended.");

      // Enforce minimum and maximum buy-in amount
      require(msg.value >= presales[_id].launchpadInfo[4], "Value should be more than minBuy!");
      require(msg.value <= presales[_id].launchpadInfo[5] * 1 ether, "Value should be lower than MaxBuy!");

      require(block.timestamp < presales[_id].endTime && presales[_id].totalBnbRaised > presales[_id].launchpadInfo[2], "Presale Not launched.");

      // Check total BNB already contributed
      // require(msg.value + presales[_id].totalBnbRaised <= presales[_id].launchpadInfo[3], "Value must be lower than hardcap!");   
      
      // Send payment
      if (presales[_id].launchpadInfo[1] == 1) {
         require(isAddrWhitelist(_id,msg.sender) == true,"Your address is not in whitelist of this presale.");
         bnbParticipated[_id][msg.sender] = msg.value;
         payTo(companyAcc, msg.value);

      } else if (presales[_id].launchpadInfo[1] == 0){
         // Regular presale
         bnbParticipated[_id][msg.sender] = msg.value;
         payTo(companyAcc, msg.value);
      }
}

   
   function isAddrWhitelist(uint _id, address _user) private view returns (bool) {
      for (uint i = 0; i < wlAddrs[_id].length; i++) {
            if (wlAddrs[_id][i] == _user) {
               return true;
            }
      }
      return false;
   }

   function addWlAddr(uint _id, address _addr) external returns (bool) {
      require(presaleToOwner[msg.sender].length > 0, "you haven't made any presale yet!");
      require(msg.sender == prsIdtoOwner[_id], "You are not founder of this presale.");
      require(isAddrWhitelist(_id,_addr) == false, "Address already exists in whitelist!");
      require(presales[_id].launchpadInfo[1] == 1, "This presale doesn't whitelist method.");
      wlAddrs[_id].push(_addr);
      return true;
   }
   
   function removeWlAddr(uint _id, address _addr) external returns (bool) {
      require(presaleToOwner[msg.sender].length > 0, "you haven't made any presale yet!");
      require(msg.sender == prsIdtoOwner[_id], "You are not founder of this presale.");
      require(isAddrWhitelist(_id,_addr) == true, "Could not find address in this whitelist.");
      require(presales[_id].launchpadInfo[1] == 1, "This presale doesn't whitelist method.");
      for (uint i = 0; i < wlAddrs[_id].length; i++) {
            if (wlAddrs[_id][i] == _addr) {
                 wlAddrs[_id][i] = 0x0000000000000000000000000000000000000000;
                 return true;
            }
      }
      return false;
   }

   function payTokens(uint _id) public returns (bool) {
       require(_id <= presales.length - 1, "Presale not found.");
       
       if (presales[_id].launchpadInfo[1] == 0) {
           require(isAddrWhitelist(_id, msg.sender) == true, "Could not find your address!");
       }

       for (uint num = 0; num < wlAddrs[_id].length; num++) {
         if (tokensPaid[num][msg.sender] == true) {
            require(false, "Your tokens already paid before.");
         }
       }

       tokensPaid[_id][msg.sender] = true;
       return true;
   }

   function payTo(address _to, uint256 _amount) internal returns (bool) {
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success, "Payment failed");
        return true;
   }
 
}