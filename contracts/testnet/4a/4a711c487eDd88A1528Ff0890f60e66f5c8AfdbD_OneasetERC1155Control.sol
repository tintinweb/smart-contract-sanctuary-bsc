// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./Ownable.sol";

contract OneasetERC1155Control is Ownable {

    mapping(uint256 => address) private _mintTokenIds;

    mapping(uint256 => address) private _transferTokenIds;

    mapping(address => bool) private _erc1155OperatorApprovals;

    mapping(address => bool) private _addTransferTokenAperatorApprovals;

    IERC1155 private _erc1155;

    function setErc1155(address contractAddress) public onlyOwner {
        _erc1155 = IERC1155(contractAddress);
    }

    function getErc1155Contract() public view virtual onlyOwner returns (address){
        return address(_erc1155);
    }

    function setErc1155Approval(address operator, bool approved) public virtual onlyOwner {
        require(operator != owner(), "OneasetERC1155Control: can not approve self");
        _erc1155OperatorApprovals[operator] = approved;
    }

    function isErc1155Approved(address operator) public view virtual onlyOwner returns (bool) {
        return _erc1155OperatorApprovals[operator];
    }

    function setAddTransferTokenApproval(address operator, bool approved) public virtual onlyOwner {
        require(operator != owner(), "OneasetERC1155Control: can not approve self");
        _addTransferTokenAperatorApprovals[operator] = approved;
    }

    function isAddTransferTokenApproved(address operator) public view virtual onlyOwner returns (bool) {
        return _addTransferTokenAperatorApprovals[operator];
    }

    modifier approvedErc1155Account() {
        address operator = _msgSender();
        require(_erc1155OperatorApprovals[operator] == true, "OneasetERC1155Control: operator is not approved");
        _;
    }

    modifier approvedAddTransferTokenAccount() {
        address operator = _msgSender();
        require(_addTransferTokenAperatorApprovals[operator] == true, "OneasetERC1155Control: operator is not approved");
        _;
    }

    function mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public approvedErc1155Account {
        require(_mintTokenIds[id] != address(0), "OneasetERC1155Control: id is not add");
        _erc1155.mint(to, id, value, data);
        delete _mintTokenIds[id];
    }

    function adminTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data,
        bytes32 hash,
        bytes memory signature
    ) public approvedErc1155Account {
        require(_transferTokenIds[id] != address(0), "OneasetERC1155Control: id is not add");
        _erc1155.adminTransferFrom(from, to, id, amount, data, hash, signature);
        delete _transferTokenIds[id];
    }

    function getAddress(
        bytes32 hash,
        bytes memory signature
    ) public approvedAddTransferTokenAccount view returns (address) {
        return _erc1155.getAddress(hash, signature);
    }


    function addMintTokenId(uint256 id, address to) public virtual approvedAddTransferTokenAccount {
        _mintTokenIds[id] = to;
    }

    function addTransferTokenId(uint256 id, address to) public virtual approvedAddTransferTokenAccount {
        _transferTokenIds[id] = to;
    }

}