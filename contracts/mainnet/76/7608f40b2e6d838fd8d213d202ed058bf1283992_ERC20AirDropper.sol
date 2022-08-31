// SPDX-License-Identifier: MIT LICENSE
// Author: Daniel Tham (Singapore)

pragma solidity ^0.8.9;

import "./IERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";


contract ERC20AirDropper is Ownable, ReentrancyGuard {

    address stableFeesToken;
    uint256 public feesAmount;

    struct tokenParams {
        address contractAddress;
        uint256 tokenDecimals;
    }
    mapping (string => tokenParams) public ERC20TokenInfo;


    constructor() {
        stableFeesToken = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
        feesAmount = 1000000000000000000;
  }

    function sendMultiple( string calldata ticker, address[] memory _recipients, uint[] memory _values) public onlyOwner returns (bool) {
        require(_recipients.length == _values.length);
        IERC20 tokenToSend = IERC20(ERC20TokenInfo[ticker].contractAddress);
        for (uint i = 0; i < _values.length; i++) {
            _safeTransferFrom(tokenToSend, msg.sender, _recipients[i], _values[i]);
        }
        return true;
   }

  /*
    Airdrop function which takes in an array of addresses and token amounts
   */
 
    function dropMultiple( string calldata ticker, address[] memory _recipients, uint[] memory _values) public nonReentrant returns (bool) {
        require(_recipients.length == _values.length);
        IERC20 tokenToSend = IERC20(ERC20TokenInfo[ticker].contractAddress);
        for (uint i = 0; i < _values.length; i++) {
            _safeTransferFrom(tokenToSend, msg.sender, _recipients[i], _values[i]);
        }
        IERC20 USDFees = IERC20(stableFeesToken);
        _safeTransferFrom(USDFees, msg.sender, owner(), feesAmount);
        return true;
    }

    function addTokenForDrops(string calldata ticker, address addr, uint256 dec) external {
        ERC20TokenInfo[ticker].contractAddress = addr;
        ERC20TokenInfo[ticker].tokenDecimals = dec;
    }

    function changeFees(address addr, uint256 amount) public onlyOwner {
        stableFeesToken = addr;
        feesAmount = amount;
    }

    function _safeTransferFrom(IERC20 token, address sender, address recipient, uint256 amount) private {
        require(token.transferFrom(sender, recipient, amount), "Token transfer failed");
    }

}