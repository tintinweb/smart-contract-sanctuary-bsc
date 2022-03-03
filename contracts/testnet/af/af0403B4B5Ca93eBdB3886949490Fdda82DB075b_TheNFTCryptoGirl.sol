pragma solidity 0.6.12;

import "./TheNFTCryptoGirlHelper.sol";

contract TheNFTCryptoGirl is TheNFTCryptoGirlHelper {

    using SafeMath for uint256;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked("https://nft.cryptogirl.finance/nft/", tokenId));
    }
}