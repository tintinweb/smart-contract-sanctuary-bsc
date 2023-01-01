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
      address [] memory propWallet_
      ) payable external returns (address) {

      require (msg.value == _price,"No pay");

      payable(_adminWallet).transfer(address(this).balance);

    // Building contract
    tokenErc20 = new TokenContract(name, symbol, supply, feeAdm, feePool, initMax, propWallet_);

    return address(tokenErc20);

  }

  function safeOtherTokens(address token, address payable receiv, uint amount) external isAuthorized(0) {
    if(token == address(0)) { receiv.transfer(amount); } else { IERC20(token).transfer(receiv, amount); }
  }


  

}