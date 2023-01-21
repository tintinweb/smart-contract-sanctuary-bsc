// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";

import "./Whitelist.sol";
import "./TokensRecoverable.sol";

contract MarketingFundWallet is Whitelist, TokensRecoverable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string constant public name = "Marketing Fund Wallet";

    event onDeposit(address indexed token, address indexed from, uint256 amount, uint256 timestamp);
    event onTransfer(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event onTransferTokens(address indexed from, address indexed to, address indexed token, uint256 amount, uint256 timestamp);

    constructor() {
        transferOwnership(msg.sender);
    }

    receive() external payable {
        emit onDeposit(address(0), msg.sender, msg.value, block.timestamp);
    }

    function transfer(address _recipient, uint256 _amount) public onlyWhitelisted {
        payable(_recipient).transfer(_amount);
        emit onTransfer(msg.sender, _recipient, _amount, block.timestamp);
    }

    function transferTokens(address _token, address _recipient, uint256 _amount) public onlyWhitelisted {
        require(IERC20(_token).transfer(_recipient, _amount));
        emit onTransferTokens(msg.sender, _recipient, _token, _amount, block.timestamp);
    }
}