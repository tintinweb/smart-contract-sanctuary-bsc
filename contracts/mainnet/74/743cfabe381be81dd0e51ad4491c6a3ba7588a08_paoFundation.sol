// SPDX-License-Identifier: MIT

//The PAO Fundation

pragma solidity ^0.8.11;

import "./IERC20.sol";
import "./ERC721Enumerable.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";

contract paoFundation is Ownable {
    function fundToken(IERC20 token, address to, uint256 amount, uint256 decimals) public virtual onlyOwner {
        token.transfer(to, amount*10**decimals);
    }

    function fundETH(address receiver, uint256 amount) public virtual onlyOwner {
        payable(receiver).call{
            value: amount*10**18
        };
    }

    function fundNFT(IERC721 token, address to,uint256 tokenId) public virtual onlyOwner {
        token.transferFrom(address(this), to, tokenId);
    }
}