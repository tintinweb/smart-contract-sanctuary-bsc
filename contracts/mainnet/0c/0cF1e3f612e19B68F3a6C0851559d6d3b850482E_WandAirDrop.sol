// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.9;

import "./IERC20.sol";
import "./Ownable.sol";


contract WandAirDrop is Ownable {

    struct tokenParams {
        address contractAddress;
        uint256 tokenDecimals;
    }
    mapping (string => tokenParams) public ERC20TokenInfo;


  /*
    constructor function to set token address
   */
  constructor() {

  }


  /*
    Airdrop function which takes in an array of addresses and token amounts for SPTR
   */
 
  function sendMultiple( string calldata ticker, address[] memory _recipients, uint[] memory _values) public returns (bool) {
         require(_recipients.length == _values.length);
         IERC20 tokenToSend = IERC20(ERC20TokenInfo[ticker].contractAddress);
         for (uint i = 0; i < _values.length; i++) {
            _safeTransferFrom(tokenToSend, msg.sender, _recipients[i], _values[i]);
         }
         return true;
   }

    function addTokenForDrops(string calldata ticker, address addr, uint256 dec) external onlyOwner {
        ERC20TokenInfo[ticker].contractAddress = addr;
        ERC20TokenInfo[ticker].tokenDecimals = dec;
    }

 function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    )
        private
    {
        require(token.transferFrom(sender, recipient, amount), "Token transfer failed");
    }
}