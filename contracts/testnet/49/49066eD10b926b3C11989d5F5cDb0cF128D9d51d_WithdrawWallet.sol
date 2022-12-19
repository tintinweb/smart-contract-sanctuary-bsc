// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./Callerable.sol";
import "./ERC721.sol";
import "./ERC721Holder.sol";

contract WithdrawWallet is SafeMath, Callerable, ERC721Holder {

    constructor(address _auth) Callerable(_auth) {

    }

    function transferToken(address erc20TokenAddress, address to, uint256 amount) external onlyCaller returns (bool res) {
        require(IERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance to withdraw token from AppWallet");
        res = true;
        (bool transfered) = IERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "error while withdrawing token from AppWallet");
    }

    function transferCoin(address to, uint256 amount) external onlyCaller returns (bool res) {
        require(address(this).balance >= amount, "insufficient balance to withdraw coin from AppWallet");
        res = true;
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "error while withdrawing coind from AppWallet");
    }

    function transferNFT(address erc721TokenAddress, uint256 tokenId, address to) external onlyCaller returns(bool res) {
        require(ERC721(erc721TokenAddress).balanceOf(address(this)) > 0, "insufficient nft token balance");
        require(ERC721(erc721TokenAddress).ownerOf(tokenId) == address(this), "don't have token id");
        res = true;
        ERC721(erc721TokenAddress).safeTransferFrom(address(this), to, tokenId);
    }

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