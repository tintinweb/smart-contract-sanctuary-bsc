/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// Interfaces
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Switch_Bsc {

    // Address of our hotwallet
    address public hotWallet;

    // The token that will be bridged
    IERC20 public myToken;

    // Executed on deployment
    constructor(address _hotWallet, address _myToken) {
        hotWallet = _hotWallet;
        myToken = IERC20(_myToken);
    }

    // Events
    // Emitted after we send the tokens
    event SendTokens(address indexed to, uint256 amount);

    // Modifier
    // Functions that have this modifier can be executed only by the hot wallet
    modifier onlyHotWallet() {
        require(msg.sender == hotWallet, "You are not the hotWallet!");
        _;
    }

    function sendTokens(address _to, uint256 _amount) external onlyHotWallet {
        require(myToken.balanceOf(address(this)) >= _amount, "Balance of the smart contract is too low!");

        myToken.approve(_to, _amount); // Approve the receiver to use tokens

        myToken.transferFrom(address(this), _to, _amount); // Send the tokens

        emit SendTokens(_to, _amount);
    }
}