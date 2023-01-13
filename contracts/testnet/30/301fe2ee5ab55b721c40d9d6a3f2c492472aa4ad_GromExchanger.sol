// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

contract GromExchanger is Ownable {

    IERC20 private GRToken;

    struct Swap {
        uint amount;
        uint toChain;
    }

    struct Payout {
        uint amount;
        bool done;
    }

    struct User {
        uint swapCount;
        mapping(uint => Swap) swaps;
        mapping(uint => Payout) payouts;
    }

    mapping(address => User) public users;

    event NewSwap(address indexed fromAddress, uint amount, uint toChain);
    event NewPayout(address indexed toAddress, uint amount);

    constructor(IERC20 _GRToken) {
        GRToken = _GRToken;
    }

    function swap(
        uint _amount,
        uint _toChain
    ) external {

        require(_amount > 0, "GromExchanger: Zero amount");

        uint allowance = GRToken.allowance(_msgSender(), address(this));
        require(allowance >= _amount, "GromExchanger: Recheck the token allowance");

        uint swapCount = users[_msgSender()].swapCount;
        users[_msgSender()].swaps[swapCount] = Swap(
            _amount,
           _toChain
        );

        users[_msgSender()].swapCount = swapCount + 1;

        (bool sent) = GRToken.transferFrom(_msgSender(), address(this), _amount);
        require(sent, "GromExchanger: Failed to send tokens");

        emit NewSwap(_msgSender(), _amount, _toChain);
    }

    function payout(
        uint _swapId,
        address _toAddress,
        uint _amount
    ) external onlyOwner {

        require(
            users[_toAddress].payouts[_swapId].done == false,
            "GromExchanger: Already paid"
        );

        require(_amount > 0, "GromExchanger: Zero amount");

        uint balance = GRToken.balanceOf(address(this));
        require(balance >= _amount, "GromExchanger: Insufficient funds");

        users[_toAddress].payouts[_swapId] = Payout(
            _amount,
           true
        );

        (bool sent) = GRToken.transfer(_toAddress, _amount);
        require(sent, "GromExchanger: Failed to send tokens");

        emit NewPayout(_toAddress, _amount);
    }

    function getUserSwap(
        address _userAddress,
        uint256 _swapId
    ) external view returns (Swap memory) {
        return users[_userAddress].swaps[_swapId];
    }

    function getUserPayout(
        address _userAddress,
        uint256 _swapId
    ) external view returns (Payout memory) {
        return users[_userAddress].payouts[_swapId];
    }
}