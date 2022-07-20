// SPDX-License-Identifier: MIT

//Shop Router

pragma solidity ^0.8.11;
pragma abicoder v2;

import "./IERC20.sol";
import "./IERC721.sol";
import "./Ownable.sol";

contract DDrouter is Ownable {

    address shop;

    function multicall(bytes[] calldata data) public payable onlyOwner returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory ret) =
                shop.call(abi.encode(data[i]));
            if (success) {
                results[i] = ret;
            }
        }
    }
    
    function setShop(address _shop) public onlyOwner returns(bool){
        shop = _shop;
        return true;
    }
    
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