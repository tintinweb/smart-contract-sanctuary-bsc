// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./Whitelist.sol";

contract FeeRecipient is Whitelist {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;

    event onPushPayment(address indexed _recipient, uint256 _amount1, uint256 _timestamp);

    event onPay(address indexed _caller, address recipient, uint256 amount, uint256 timestamp);
    event onPayTokens(address indexed _caller, address recipient, address tokenAddress, uint256 amount, uint256 timestamp);

    constructor(address payable _mainUser) {
        addAddressToWhitelist(msg.sender);
        addAddressToWhitelist(_mainUser);
    }

    receive() external payable {

    }

    // Base Balance
    function baseBalance() public view returns (uint256 _balance) {
        return (address(this).balance);
    }

    // Token Balance
    function tokenBalance(address _token) public view returns (uint256 _balance) {
        return IERC20(_token).balanceOf(address(this));
    }

    // Pay tokens to another address
    function pay(address payable _recipient, uint256 _amount) external onlyWhitelisted() returns (bool _success) {

        uint256 _tokens = baseBalance();
        require(_amount < _tokens, "INSUFFICIENT_BALANCE");

        // Send the tokens to the Party Lord
        (_recipient).transfer(_amount);

        // Tell the network, successful event
        emit onPay(msg.sender, _recipient, _amount, block.timestamp);
        return true;
    }

    // Pay tokens to another address
    function payTokens(address _token, address payable _recipient, uint256 _amount) external onlyWhitelisted() returns (bool _success) {
        token = IERC20(_token);

        uint256 _tokens = tokenBalance(_token);
        require(_amount < _tokens, "INSUFFICIENT_BALANCE");

        // Send the tokens to the Party Lord
        IERC20(_token).transfer(_recipient, _amount);

        // Tell the network, successful event
        emit onPayTokens(msg.sender, _recipient, _token, _amount, block.timestamp);
        return true;
    }

    // Distribute funds
    function withdraw(address _token, address payable _recipient) external onlyWhitelisted() returns (bool _success) {
        
        // Get the payout values to transfer
        uint256 _base = baseBalance();
        uint256 _tokens = tokenBalance(_token);

        // Send the tokens to the Party Lord
        IERC20(_token).transfer(_recipient, _tokens);

        // Transfer any base to the Party Lord
        _recipient.transfer(_base);

        // Tell the network, successful event
        emit onPushPayment(_recipient, _tokens, block.timestamp);
        return true;
    }
}