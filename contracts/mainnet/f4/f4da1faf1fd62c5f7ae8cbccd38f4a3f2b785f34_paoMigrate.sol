// SPDX-License-Identifier: MIT

//migrate PAO and Leopard

pragma solidity ^0.8.11;

import "./IERC20.sol";
import "./ERC721Enumerable.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";

contract paoMigrate is Ownable {
    function migrateToken(IERC20 token, address to, uint256 amount, uint256 decimals) public virtual onlyOwner {
        token.transfer(to, amount*10**decimals);
    }

    function migrateETH(address receiver, uint256 amount) public virtual onlyOwner {
        payable(receiver).call{
            value: amount*10**18
        };
    }

    function migrateNFT(IERC721 token, address to,uint256 tokenId) public virtual onlyOwner{
        token.transferFrom(address(this), to, tokenId);
    }
}