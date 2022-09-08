//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";

contract RoyaltyDatabase is Ownable {

    address private _royaltyRecipient;
    address private _platformRecipient;

    constructor(address recipient) {
        _royaltyRecipient = recipient;
    }

    function setRoyaltyRecipient(address newRecipient) external onlyOwner {
        _royaltyRecipient = newRecipient;
    }

    function setPlatformRecipient(address newRecipient) external onlyOwner {
        _platformRecipient = newRecipient;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function getRoyaltyRecipient() external view returns (address) {
        return _royaltyRecipient == address(0) ? address(this) : _royaltyRecipient;
    }

    function getPlatformRecipient() external view returns (address) {
        return _platformRecipient == address(0) ? address(this) : _platformRecipient;
    }

    receive() external payable {}
}