// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./Ownable.sol";
import "./ECDSA.sol";

contract OneasetERC1155 is ERC1155, Ownable {

    mapping(bytes32 => bool) private signatureMessages;


    constructor(string memory uri) ERC1155(uri) {

    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public onlyOwner {
        _mint(to, id, value, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, values, data);
    }

    function burn(
        address owner,
        uint256 id,
        uint256 value
    ) public onlyOwner {
        _burn(owner, id, value);
    }

    function burnBatch(
        address owner,
        uint256[] memory ids,
        uint256[] memory values
    ) public onlyOwner {
        _burnBatch(owner, ids, values);
    }

    function adminTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data,
        bytes32 hash,
        bytes memory signature
    ) public onlyOwner {
        require(signatureMessages[hash] != true, "ERC1155: signature is used");
        address recovered = ECDSA.recover(hash, signature);
        require(from == recovered, "ERC1155: signature is not owner sign");
        _safeTransferFrom(from, to, id, amount, data);
        signatureMessages[hash] = true;
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        string memory baseURI = super.uri(id);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "/", Strings.toString(id), ".json")): "";
    }

    function getAddress(
        bytes32 hash,
        bytes memory signature
    ) public view returns (address) {
        if(signatureMessages[hash]){
            return address(0);
        }
        return ECDSA.recover(hash, signature);
    }

}