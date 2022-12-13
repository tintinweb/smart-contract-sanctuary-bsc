// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PairPrice.sol";
import "./ModuleBase.sol";
import "./Lockable.sol";
import "./IERC20.sol";
import "./IERC721.sol";

contract MMTProvider is ModuleBase, Lockable {

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {}

    function buyMMT(uint256 usdtAmount) external lock {
        require(IERC20(auth.getUSDTToken()).balanceOf(msg.sender) >= usdtAmount, "insufficient balance");
        require(IERC20(auth.getUSDTToken()).allowance(msg.sender, address(this)) >= usdtAmount, "not approved");
        uint256 mmtOutAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountOut(usdtAmount);
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= mmtOutAmount, "insufficient mmt fund");
        require(IERC20(auth.getFarmToken()).transfer(msg.sender, mmtOutAmount), "buy error 1");
        require(IERC20(auth.getUSDTToken()).transferFrom(msg.sender, address(this), usdtAmount), "buy error 2");
    }

    function withdrawNFT(address erc721TokenAddress, uint256 tokenId, address to) external onlyOwner {
        require(IERC721(erc721TokenAddress).balanceOf(address(this)) > 0, "insufficient nft token balance");
        require(IERC721(erc721TokenAddress).ownerOf(tokenId) == auth.getOwner(), "don't have token id");
        IERC721(erc721TokenAddress).safeTransferFrom(address(this), to, tokenId);
    }

    function withdrawToken(address erc20TokenAddress, address to, uint256 amount) external onlyOwner {
        require(IERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance");
        require(IERC20(erc20TokenAddress).transfer(to, amount), "withdrawToken error");
    }
}