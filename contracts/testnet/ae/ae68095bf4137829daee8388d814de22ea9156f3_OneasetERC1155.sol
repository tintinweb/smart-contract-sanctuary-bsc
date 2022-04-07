// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./Ownable.sol";
import "./ECDSA.sol";

contract OneasetERC1155 is ERC1155, Ownable {

    constructor(string memory uri) ERC1155(uri) {

    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    function mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public {
        _mint(to, id, value, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public {
        _mintBatch(to, ids, values, data);
    }

    function burn(
        address owner,
        uint256 id,
        uint256 value
    ) public {
        _burn(owner, id, value);
    }

    function burnBatch(
        address owner,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
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
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        require(from == recovered, "ERC1155: signature is not owner sign");
        _safeTransferFrom(from, to, id, amount, data);
    }

}