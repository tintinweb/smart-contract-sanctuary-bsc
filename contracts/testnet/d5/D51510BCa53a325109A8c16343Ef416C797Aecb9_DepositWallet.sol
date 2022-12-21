// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ERC721.sol";
import "./ERC721Holder.sol";

contract DepositWallet is ERC721Holder, Ownable {

    constructor(address _auth) Ownable(_auth) {}

    function withdrawToken(address erc20TokenAddress, address to, uint256 amount) external onlyOwner {
        require(IERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance in app wallet");
        (bool transfered) = IERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "withdrawToken error");
    }

    function withdrawCoin(address to, uint256 value) external onlyOwner {
        require(address(this).balance >= value, "insufficient balance to withdraw coin from AppWallet");
        (bool sent, ) = to.call{value: value}("");
        require(sent, "error while withdrawing coind from AppWallet");
    } 

    function withdrawNFT(address erc721TokenAddress, uint256 tokenId, address to) external onlyOwner {
        require(ERC721(erc721TokenAddress).balanceOf(address(this)) > 0, "insufficient nft token balance");
        require(ERC721(erc721TokenAddress).ownerOf(tokenId) == address(this), "don't have token id");
        ERC721(erc721TokenAddress).safeTransferFrom(address(this), to, tokenId);
    }

}