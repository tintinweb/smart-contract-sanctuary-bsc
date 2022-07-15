// SPDX-License-Identifier: MIT

//migrate Token

pragma solidity ^0.8.11;

import "./IERC20.sol";
import "./IERC721.sol";
import "./Ownable.sol";

contract DDMigrate is Ownable {
    function migrateToken(IERC20 token, address to, uint256 amount, uint256 decimals) public virtual onlyOwner returns(bool){
        token.transfer(to, amount*10**decimals);
        return true;
    }

    function migrateETH(address receiver, uint256 amount) public virtual onlyOwner returns(bool){
        (bool success,) = payable(receiver).call{
            value: amount
        }("");
        return success;
    }

    function migrateNFT(IERC721 token, address to,uint256 tokenId) public virtual onlyOwner returns(bool){
        token.transferFrom(address(this), to, tokenId);
        return true;
    }

    receive() external payable {}

    fallback() external payable {}
}