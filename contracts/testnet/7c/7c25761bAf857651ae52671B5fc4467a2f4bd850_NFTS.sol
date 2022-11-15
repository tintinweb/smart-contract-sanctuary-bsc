// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./ERC1155.sol";
import "./Owner.sol";

contract NFTS is ERC1155, Owner {

    mapping (uint256 => string) private _uris;

    event Set_TokenUri(
        uint256 tokenId,
        string uri
    );

    constructor() ERC1155("https://game.example/api/item/{id}.json") { // https://uri.example/api/item/{id}.json
        address adminAddress = 0xa2AFecdeC22fd6f4d2677f9239D7362eA61Fdf12;
        _mint(adminAddress, 1, 9999, ""); // Collection - Recreacion Turistica
        _mint(adminAddress, 2, 8888, ""); // Collection - Transporte
        _mint(adminAddress, 3, 7777, ""); // Collection - Hoteleria

        setTokenUri(1, "https://11");
        setTokenUri(2, "https://22");
        setTokenUri(3, "https://33");
    }

    function mint(uint256 _tokenId, uint256 _amount) external isOwner {
        _mint(msg.sender, _tokenId, _amount, "");
    }
    
    function setTokenUri(uint256 _tokenId, string memory _uri) public isOwner {
        _uris[_tokenId] = _uri;
        emit Set_TokenUri(_tokenId, _uri);
    }

    function uri(uint256 _tokenId) override public view returns (string memory) {
        return(_uris[_tokenId]);
    }

}