//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "nftBasic.sol";

contract ERC721Factory {
    
    address[] public NFTS;
    
    event NewNFT(address indexed _address, address indexed _creator);
    
    function createNFT(string memory _tokenName, string memory _tokenSymbol) public returns(address) {
        
        NFTTOKEN deployed = new NFTTOKEN(_tokenName,_tokenSymbol);
        //IUniswapV2Pair(pair).initialize(token0, token1);

        NFTS.push(address(deployed));
        
        emit NewNFT(address(deployed), msg.sender);

        return address(deployed);
    }
    
}