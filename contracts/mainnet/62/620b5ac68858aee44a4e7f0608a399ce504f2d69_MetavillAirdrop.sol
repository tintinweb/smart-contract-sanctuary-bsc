//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./Ownable.sol";
import "./SafeERC20.sol";

contract MetavillAirdrop is Ownable {
    using SafeERC20 for IERC20;

    address private mvWalletAddress;
    IERC20 private mv;

    constructor(address mvTokenAddress_) {
        require(mvTokenAddress_ != address(0));
        mvWalletAddress = msg.sender;
        mv = IERC20(mvTokenAddress_);
    }
/*
    Tranfer MV token from airdrop address
*/
    function airdrop(address user, uint amount, string memory message) external onlyOwner {
        require(user != address(0));
        mv.safeTransferFrom(mvWalletAddress, user, amount);
    }
    function renounceOwnership() public override {

    }
}