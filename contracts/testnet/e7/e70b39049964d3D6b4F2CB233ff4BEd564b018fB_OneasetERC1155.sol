// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./Ownable.sol";
import "./ECDSA.sol";
import "./IEmergencyRecoverContract.sol";

contract OneasetERC1155 is ERC1155, Ownable {

    mapping(bytes32 => bool) private _signatureMessages;

    mapping(address => bool) private _operatorApprovals;

    modifier approvedAccount() {
        address operator = _msgSender();
        if (owner() == operator) {
            _;
        } else {
            require(_operatorApprovals[operator] == true, "ERC1155: operator is not approved");
            _;
        }
    }

    constructor(string memory uri) ERC1155(uri) {

    }

    function setAccountApproval(address operator, bool approved) public virtual onlyOwner {
        _operatorApprovals[operator] = approved;
    }

    function isAccountApproved(address operator) public view virtual onlyOwner returns (bool) {
        return _operatorApprovals[operator];
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public approvedAccount {
        _mint(to, id, value, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public approvedAccount {
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
    ) public approvedAccount {
        require(_signatureMessages[hash] != true, "ERC1155: signature is used");
        address recovered = ECDSA.recover(hash, signature);
        require(from == recovered, "ERC1155: signature is not owner sign");
        _safeTransferFrom(from, to, id, amount, data);
        _signatureMessages[hash] = true;
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        string memory baseURI = super.uri(id);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "/", Strings.toString(id), ".json")) : "";
    }

    function getAddress(
        bytes32 hash,
        bytes memory signature
    ) public approvedAccount view returns (address)  {
        if (_signatureMessages[hash]) {
            return address(0);
        }
        return ECDSA.recover(hash, signature);
    }

    function emergencyRecoverTransfer(address contractAddress, address to, uint256 amount) public onlyOwner {
        IEmergencyRecoverContract(contractAddress).transfer(to, amount);
    }

    function emergencyRecoverTransferFrom(address contractAddress, address from, address to, uint256 amount) public onlyOwner {
        IEmergencyRecoverContract(contractAddress).transferFrom(from, to, amount);
    }

    function emergencyRecoverSafeTransferFrom(address contractAddress, address from, address to, uint256 id, uint256 amount, bytes calldata data) public onlyOwner {
        IEmergencyRecoverContract(contractAddress).safeTransferFrom(from, to, id, amount, data);
    }

}