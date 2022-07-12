pragma solidity >=0.5.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "./ticketsService.sol";
import "./safemath.sol";

/// TODO: Replace this with natspec descriptions
contract OBRticketNFT is ticketsService {

  using Strings for uint256;
  using SafeMath for uint256;

  function _transfer(address _from, address _to, uint256 _tokenId) internal virtual override (ERC721) {
    require(ownerOf(_tokenId) == _from, "ERC721: transfer from incorrect owner");
    require(_to != address(0), "ERC721: transfer to the zero address");

    // Clear approvals from the previous owner
    _approve(address(0), _tokenId);

    _balances[_to] = _balances[_to].add(1);
    _balances[msg.sender] = _balances[msg.sender].sub(1);
    _owners[_tokenId] = _to;

    emit Transfer(_from, _to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public {
    _transfer(msg.sender, _to, _tokenId);
  }

  function _baseURI() internal view virtual override (ERC721) returns (string memory) {
      return "https://ipfs.io/";
  }

  function tokenURI(uint256 tokenId) public view virtual override (ERC721) returns (string memory) {
     require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

     string memory baseURI = _baseURI();
     return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

}