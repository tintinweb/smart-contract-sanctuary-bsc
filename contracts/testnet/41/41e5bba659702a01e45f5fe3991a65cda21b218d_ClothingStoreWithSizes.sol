// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ClothingStore.sol";

contract ClothingStoreWithSizes is ClothingStore {
    // Define una estructura para las tallas
    struct Size {
        uint id;
        string name;
        uint quantity;
    }

    // Crea un mapeo para almacenar las tallas de cada producto
    mapping (uint => mapping (uint => Size)) productSizes;
    // Crea una variable para almacenar el último ID de talla asignado
    uint lastSizeId;

    // Añade una talla para un producto específico
    function addSize(uint _productId, string memory _name, uint _quantity) public {
        require(products[_productId].id != 0, "Product not found");
        lastSizeId++;
        productSizes[_productId][lastSizeId] = Size(lastSizeId, _name, _quantity);
    }

    // Actualiza la información de una talla
    function updateSize(uint _productId, uint _sizeId, string memory _name, uint _quantity) public {
        require(products[_productId].id != 0, "Product not found");
        require(productSizes[_productId][_sizeId].id != 0, "Size not found");
        // Actualiza la información de la talla
        productSizes[_productId][_sizeId].name = _name;
        productSizes[_productId][_sizeId].quantity = _quantity;
    }

    // Elimina una talla de un producto
    function deleteSize(uint _productId, uint _sizeId) public {
        require(products[_productId].id != 0, "Product not found");
        require(productSizes[_productId][_sizeId].id != 0, "Size not found");
        // Elimina la talla
        delete productSizes[_productId][_sizeId];
    }

    // Obtiene la información de una talla de un producto
    function getSize(uint _productId, uint _sizeId) public view returns (uint, string memory, uint) {
        require(products[_productId].id != 0, "Product not found");
        require(productSizes[_productId][_sizeId].id != 0, "Size not found");
        // Devuelve la información de la talla
        return (productSizes[_productId][_sizeId].id, productSizes[_productId][_sizeId].name, productSizes[_productId][_sizeId].quantity);
    }
}