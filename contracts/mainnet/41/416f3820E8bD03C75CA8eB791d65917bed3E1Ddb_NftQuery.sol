pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT
/**
 * @title NftQuery
 * Efficiently query token information of ERC721 contracts
 */

interface Nft {
    function totalSupply() external view returns (uint);
    function ownerOf(uint tokenId)external view returns (address);
    function balanceOf(address owner) external view returns(uint);
}

contract NftQuery {
    function getHolders(Nft nft, uint start, uint end) public view returns (address[] memory) {
        uint totalSupply = nft.totalSupply();
        if(end == 0 || end > totalSupply) end = totalSupply;
        if(start == 0) start = 1;
        uint total = end + 1 - start;
        address[] memory holders = new address[](total);
        for(uint i = 0; i < total; i++) {
            try nft.ownerOf(start + i) returns (address holder) {
                holders[i] = holder;
            } catch {}
        }
        return holders;
    }
}