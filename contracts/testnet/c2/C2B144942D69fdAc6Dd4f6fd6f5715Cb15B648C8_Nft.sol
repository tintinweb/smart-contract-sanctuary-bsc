// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721PresetMinterPauserAutoId.sol";
import "./SafeMath.sol";

contract Nft is ERC721PresetMinterPauserAutoId {
    using SafeMath for uint256;

    string private _baseTokenURI = "https://api.dogepunks3d.com/details/?tokenId=";

    constructor() ERC721PresetMinterPauserAutoId("KOL-NFT", "KNT", _baseTokenURI) {}// KOL-NFT  KNT

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseTokenURI(string memory str) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "setBaseTokenURI: must have ADMIN role to edit.");
        _baseTokenURI = str;
    }
}