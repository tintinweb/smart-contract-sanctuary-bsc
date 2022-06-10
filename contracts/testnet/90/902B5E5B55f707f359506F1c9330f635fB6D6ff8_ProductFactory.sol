// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./CloneFactory.sol";

contract ProductFactory is CloneFactory {
    address public libraryAddress;

    event ProductCreated(address newProduct);

    function setLibraryAddress(address _libraryAddress) external {
        libraryAddress = _libraryAddress;
    }

    function createProduct() external {
        address clone = createClone(libraryAddress);
        emit ProductCreated(clone);
    }
}