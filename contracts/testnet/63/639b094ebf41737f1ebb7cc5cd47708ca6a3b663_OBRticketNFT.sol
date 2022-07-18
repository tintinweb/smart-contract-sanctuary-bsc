pragma solidity >=0.5.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "./ticketsService.sol";
import "./safemath.sol";
import "./Base64.sol";

/// TODO: Replace this with natspec descriptions
contract OBRticketNFT is ticketsService {

  using Strings for uint256;
  using SafeMath for uint256;
  using SafeMath16 for uint16;

  string _baseImgURL = "https://tshm46ccf7vtlosvbl2h5joaw2ycjqku5mapr4ltblcrm6ly.arweave.net/nI7OeEIv6zW6V_Qr-0fqXAtrAkwVTrAPjxcwrFFn-l4/";

  function changeBaseImgURL (string memory _newURL) external onlyOwner {
    _baseImgURL = _newURL;
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal virtual override (ERC721) {
    require(ownerOf(_tokenId) == _from, "ERC721: transfer from incorrect owner");
    require(_to != address(0), "ERC721: transfer to the zero address");
    require(tickets[_tokenId].counter < maxTransfers, "Transfer is not possible. Maximum number of transfers is reached");

    // Clear approvals from the previous owner
    _approve(address(0), _tokenId);

    _balances[_to] = _balances[_to].add(1);
    _balances[msg.sender] = _balances[msg.sender].sub(1);
    _owners[_tokenId] = _to;
    // tickets[_tokenId].counter.add(1); // increment counter of transfers
    tickets[_tokenId].counter += 1; // increment counter of transfers

    emit Transfer(_from, _to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public {
    _transfer(msg.sender, _to, _tokenId);
  }

  function _baseURI() internal view virtual override (ERC721) returns (string memory) {
      return _baseImgURL;
  }

  function tokenURI(uint256 tokenId) public view virtual override (ERC721) returns (string memory) {
     require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

     string memory pic = "green.png"; // custom ticket picture
     if (tickets[tokenId].duration == _duration30) {pic = "silver.png";}
     if (tickets[tokenId].duration == _duration90) {pic = "gold.png";}
     if (tickets[tokenId].duration == _duration180) {pic = "platinum.png";}
     if (tickets[tokenId].duration == _durationUn) {pic = "diamond.png";}

     string memory imgURL = string(abi.encodePacked(_baseImgURL, pic));

     string memory val1 = string(abi.encodePacked('{ "trait_type": "start date", "value": ', Strings.toString(tickets[tokenId].start),'}'));
     string memory val2 = string(abi.encodePacked('{ "trait_type": "end date", "value": ', Strings.toString(tickets[tokenId].end),'}'));
     string memory val3 = string(abi.encodePacked('{ "trait_type": "duration", "value": ', Strings.toString(tickets[tokenId].duration),'}'));
     string memory val4 = string(abi.encodePacked('{ "trait_type": "ticket number", "value": ', Strings.toString(tickets[tokenId].dna),'}'));
     string memory val5 = string(abi.encodePacked('{ "trait_type": "transfers count", "value": ', Strings.toString(tickets[tokenId].counter),'}'));

     string memory attributes = string(abi.encodePacked(val1, ",", val2, ",", val3, ",", val4, ",", val5));

     string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "OBR ticket", "description": "This ticket allows you to participate in One Billion Run Challenge", "image": "', imgURL, '", "attributes": [', attributes, ']}'))));
     return string(abi.encodePacked('data:application/json;base64,', json));

    }

}