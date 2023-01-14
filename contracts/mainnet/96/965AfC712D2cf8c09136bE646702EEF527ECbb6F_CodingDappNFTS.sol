/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

pragma solidity ^0.6.0;

contract CodingDappNFTS {
    address owner;
    mapping (uint256 => bool) mintedTokens;

    constructor() public {
        owner = msg.sender;
    }

    function mint(uint256 _tokenId) public {
        require(msg.sender == owner);
        require(mintedTokens[_tokenId] == false);
        mintedTokens[_tokenId] = true;
    }
}