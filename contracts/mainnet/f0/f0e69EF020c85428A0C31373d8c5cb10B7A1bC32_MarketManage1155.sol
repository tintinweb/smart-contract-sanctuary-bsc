/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
    function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external;
    function uri(uint256 id) external view returns (string memory);
    function totalSupply(uint256 id) external view returns (uint256) ;
}

interface ISwap1155 {
    // Views
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenOfOwner(address owner) external view returns (uint256[] memory);
    function tokenURI() external view returns (string memory);
    function bExistsID(uint256 tokenId) external view returns (bool);
    function getSellInfos(uint256[] calldata tokenIdArr) external view returns ( 
        address[] memory addrs,
        uint256[] memory nums,
        uint256[] memory prices,
        uint256[] memory times);
    function ownerOf(uint256 tokenId) external view returns (address);
}


library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

contract MarketManage1155{
    using Address for address;

    string public name = "ForthBox MarketManage1155";
    string public symbol = "FBX MM1155";

    constructor() {
    }

    /* ========== only IERC1155 ========== */
    function totalSupply(address erc1155Adress,uint256 id) external view returns (uint256) {
        require(erc1155Adress.isContract(), "MarketManage1155: not contract address");
        return IERC1155(erc1155Adress).totalSupply(id);
    }

    function totalSupplys(address[] calldata erc1155dressArr,uint256 id) external view returns (uint256[] memory) {
        uint256 num = erc1155dressArr.length;
        uint256[] memory Token_list = new uint256[](uint256(num));
        for(uint256 i=0; i<num; ++i) {
            Token_list[i] = IERC1155(erc1155dressArr[i]).totalSupply(id);
        }
        return Token_list;
    }
    function tokenURI(address erc1155Adress,uint256 id) external view returns (string memory){      
        return IERC1155(erc1155Adress).uri(id);
    }

    function balanceOf(address erc1155Adress,address account,uint256 id) external view returns (uint256) {
        require(erc1155Adress.isContract(), "MarketManage1155: not contract address");
        return IERC1155(erc1155Adress).balanceOf(account,id);
    }

    function balanceOfs(address[] calldata erc1155AdressArr,address account,uint256 id) external view returns (uint256[] memory) {
        uint256 num = erc1155AdressArr.length;
        uint256[] memory Token_list = new uint256[](uint256(num));
        for(uint256 i=0; i<num; ++i) {
            Token_list[i] = IERC1155(erc1155AdressArr[i]).balanceOf(account,id);
        }
        return Token_list;
    }
    /* ========== only ISwap1155 swap ========== */
    function tokenByIndex(address swap1155Adress,uint256 start, uint256 end) external view returns (uint256[] memory) {
        require(swap1155Adress.isContract(), "MarketManage1155: not contract address");
        ISwap1155 swap115Swap = ISwap1155(swap1155Adress);
        require(end < swap115Swap.totalSupply(), "ForthBoxNFT_Swap: global end out of bounds");

        uint256 num = end - start + 1;
        uint256[] memory Token_list = new uint256[](uint256(num));
        for(uint256 i=start; i<=end; ++i) {
            Token_list[i] =swap115Swap.tokenByIndex(i);
        }
        return Token_list;
    }

    function tokenOfOwner(address swap1155Adress,address owner) external view returns (uint256[] memory) {
        require(swap1155Adress.isContract(), "MarketManage1155: not contract address");
        return ISwap1155(swap1155Adress).tokenOfOwner(owner);
    }

    function bExistsID(address swap1155Adress,uint256 tokenId) external view returns (bool) {
        require(swap1155Adress.isContract(), "MarketManage1155: not contract address");
        return ISwap1155(swap1155Adress).bExistsID(tokenId);
    }

    function ownerOf(address swap1155Adress,uint256 tokenId) external view returns (address) {
        require(swap1155Adress.isContract(), "MarketManage1155: not contract address");
        return ISwap1155(swap1155Adress).ownerOf(tokenId);
    }


    function getSellInfos(address swap1155Adress,uint256[] calldata tokenIdArr) external view returns (
        address[] memory addrs,
        uint256[] memory nums,
        uint256[] memory prices,
        uint256[] memory times) {
        require(swap1155Adress.isContract(), "MarketManage1155: not contract address");
        return ISwap1155(swap1155Adress).getSellInfos(tokenIdArr);
    }
}