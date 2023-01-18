// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC1155.sol";
import "./Ownable.sol";

contract BNBMiner is ERC1155, Ownable {
    constructor(string memory bronzeURI, string memory silverURI, string memory goldURI) ERC1155("MyToken") {
        _mint(msg.sender, 0, 100, "", bronzeURI);
        _mint(msg.sender, 1, 50, "", silverURI);
        _mint(msg.sender, 2, 10, "", goldURI);
    }

    function mint(string memory tokenURI, uint256 amount, uint256 id)public onlyOwner{
        _mint(msg.sender, id, amount, "", tokenURI);    
    } 

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, string[] memory tokenURI ,bytes memory data)
        public onlyOwner
    {
        _mintBatch(to, ids, amounts, tokenURI, data);
    }

    function name() public pure returns(string memory){
        return "BNBMiner.app";
    }

    function symbol() public pure returns(string memory){
        return "BNBMiner.app";
    }

}