// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Product.sol";

contract NormalFactory {
    event ProductCreated(address newProduct);

    function createProduct() external {
        bytes memory bytecode = type(Product).creationCode;
        bytes32 salt = keccak256(abi.encodePacked("Product"));
        address newProduct;
        assembly {
            newProduct := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        emit ProductCreated(newProduct);
    }
}