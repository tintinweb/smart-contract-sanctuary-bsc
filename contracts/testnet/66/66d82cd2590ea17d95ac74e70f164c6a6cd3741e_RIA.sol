// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./ERC20Capped.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";

contract RIA is ERC20Capped, Ownable {
    using SafeERC20 for IERC20;

    constructor() ERC20("Calvaria: Duels of Eternity", "RIA") ERC20Capped(1000000000 * (10**18)) {}

    receive() external payable {}

    function mint(uint256 amount) external onlyOwner {
        super._mint(owner(), amount);
    }

    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        IERC20 tokenContract = IERC20(token);
        tokenContract.safeTransfer(owner(), amount);
    }

    function withdrawEthers() external onlyOwner {
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }
}