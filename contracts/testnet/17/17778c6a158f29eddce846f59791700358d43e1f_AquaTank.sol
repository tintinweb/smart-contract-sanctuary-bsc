// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./Context.sol";
import "./IERC20Metadata.sol";
interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

contract AquaTank is ERC20, Ownable {
    using SafeERC20 for IERC20;
    IPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled;

    constructor(
        string memory _name, 
        string memory _symbol,
        uint256 _initialSupply,
        address pinkAntiBot_ 
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply * (10 ** 18) );
        pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
        antiBotEnabled = true;

    } 

      // Use this function to control whether to use PinkAntiBot or not instead
  // of managing this in the PinkAntiBot contract
    function setEnableAntiBot(bool _enable) external onlyOwner {
      antiBotEnabled = _enable;
    }
//In case users accidentally sent another tokes we can refund their tokens back to their wallet.
    function clearTokens(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(this), "Cannot clear same tokens as Aqua");
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }
    
      // Inside ERC20's _transfer function:
    function _beforeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (antiBotEnabled) {
            pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
        }
    }
}