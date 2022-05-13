pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import "IERC20.sol";
import "Ownable.sol";
import "Pausable.sol";


contract LHTreasure is Pausable, Ownable {
    event Redeem (
        uint256 id,
        string account, 
        address from,
        uint256 amount,
        string operation,
        string param
    );

    event Transfer( 
        address to,
        uint256 amount
    );

    event TransferToken( 
        address to,
        uint256 amount
    );

    event TransferIRC20(
        address token, 
        address to,
        uint256 amount
    );    

    uint256 public min_redeem = 1;
    IERC20 public token; // token contract
    uint256 public last_tx = 0;

    constructor() {}

    function setMinRedeem(uint256 v) public onlyOwner {
        min_redeem = v;
    }

    function setTokenContract(address token_) public onlyOwner {
        token = IERC20(token_);
    }

    function pause() whenNotPaused onlyOwner public {
        _pause();
    }

    function unpause() whenPaused onlyOwner public {
        _unpause();
    }

    function redeem(
        uint256 amount,
        string memory account,
        string memory operation,
        string memory param
    ) public whenNotPaused {
        require(amount >= min_redeem, "Too small amount to redeem");
        require(bytes(account).length != 0, "No account");

        token.transferFrom(msg.sender, address(this), amount);
        last_tx++;

        emit Redeem( last_tx, account, msg.sender, amount, operation, param );

    }

    function transfer(address payable to, uint256 amount) public onlyOwner {
        to.transfer(amount);
        emit Transfer( to, amount );
    }

    function transferTokens(address to, uint256 amount) public onlyOwner {
        token.transferFrom(address(this), to, amount);
        emit TransferToken( to, amount );
    }

    function transferERC20(
        address irc20,
        address to,
        uint256 amount
    ) public onlyOwner {
        IERC20(irc20).transferFrom(address(this), to, amount);
        emit TransferIRC20( irc20, to, amount );
    }
}