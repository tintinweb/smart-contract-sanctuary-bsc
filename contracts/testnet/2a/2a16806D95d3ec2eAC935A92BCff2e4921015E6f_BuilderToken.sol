// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./TokenContract.sol";

/*
  ____            _   _       _                   _        ___  
 | __ )   _   _  (_) | |   __| |   ___   _ __    / |      / _ \ 
 |  _ \  | | | | | | | |  / _` |  / _ \ | '__|   | |     | | | |
 | |_) | | |_| | | | | | | (_| | |  __/ | |      | |  _  | |_| |
 |____/   \__,_| |_| |_|  \__,_|  \___| |_|      |_| (_)  \___/ 
                                                     Tokenbank
 ______    ____       ______      __  __      __  __     
/\__  _\  /\  _`\    /\  _  \    /\ \/\ \    /\ \/\ \    
\/_/\ \/  \ \ \L\ \  \ \ \L\ \   \ \ `\\ \   \ \ \/'/'   
   \ \ \   \ \  _ <'  \ \  __ \   \ \ , ` \   \ \ , <    
    \ \ \   \ \ \L\ \  \ \ \/\ \   \ \ \`\ \   \ \ \\`\  
     \ \_\   \ \____/   \ \_\ \_\   \ \_\ \_\   \ \_\ \_\
      \/_/    \/___/     \/_/\/_/    \/_/\/_/    \/_/\/_/

   /\   /\   
  //\\_//\\     ____      🦊✅ 
  \_     _/    /   /      🦊✅ 
   / * * \    /^^^]       🦊✅ 
   \_\O/_/    [   ]       🦊✅ 
    /   \_    [   /       🦊✅ 
    \     \_  /  /        🦊✅ 
     [ [ /  \/ _/         🦊✅ 
    _[ [ \  /_/    

*/
contract BuilderToken is Ownable, Authorized {

  TokenContract public tokenErc20;
  uint256 public _price;
  address public _adminWallet;

  //start
  constructor() {
  }
  
  //receiver
  receive() external payable {}

  // Admin
  function getPrice() public view returns (uint256) { return _price; }
  function setPrice(uint256 price) public isAuthorized(0) { 
    _price = price; 
  }
  function setAdminWallet(address adminWallet) public isAuthorized(0) { 
    _adminWallet = adminWallet;
  }

  //Send to constructor queue Builder Token
  function sendToQueue(
      string memory name, 
      string memory symbol, 
      uint256 supply,
      uint256 feeAdm,
      uint256 feePool,
      uint256 initMax,
      address propWallet_
      ) payable external returns (address) {

      //require (msg.value == 50000000000000000);
      require (msg.value == _price,"No pay");

          /*
             Gas price	        		                  Tbank tool		

          0.01612786 BNB  $6.23			                TBANK = 0.05 BNB 	

          0.063698224899183168 Ether $ 178,00       TBANK = 0.1 ETH

          0.044533115 AVAX $2.56			              TBANK	= 1 AVAX

          0.336123675 FTM  $0.26			              TBANK = 1 FTM 
            
          0.004048465011335702 MATIC $0.004	        TBANK = 0.1 MATIC
          */

      payable(_adminWallet).transfer(address(this).balance);

      // PAYYYY
    //IERC20(_Tbank).transferFrom(msg.sender, address(this), amount);

    // Building contract
    tokenErc20 = new TokenContract(name, symbol, supply, feeAdm, feePool, initMax, propWallet_);

    return address(tokenErc20);

  }

  function safeOtherTokens(address token, address payable receiv, uint amount) external isAuthorized(0) {
    if(token == address(0)) { receiv.transfer(amount); } else { IERC20(token).transfer(receiv, amount); }
  }


  

}