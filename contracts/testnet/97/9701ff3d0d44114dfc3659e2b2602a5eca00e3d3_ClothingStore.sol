/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ClothingStore {
    // Define una estructura para los productos
    struct Product {
        uint id;
        string name;
        string description;
        uint price;
        uint quantity;
    }

    // Crea un mapeo para almacenar los productos
    mapping (uint => Product) products;
    // Crea una variable para almacenar el último ID de producto asignado
    uint lastProductId;

    // Añade un producto a la tienda
    function addProduct(string memory _name, string memory _description, uint _price, uint _quantity) public {
        lastProductId++;
        products[lastProductId] = Product(lastProductId, _name, _description, _price, _quantity);
    }

    // Actualiza la información de un producto
    function updateProduct(uint _id, string memory _name, string memory _description, uint _price, uint _quantity) public {
        // Comprueba si el producto existe
        require(products[_id].id != 0, "Product not found");
        // Actualiza la información del producto
        products[_id].name = _name;
        products[_id].description = _description;
        products[_id].price = _price;
        products[_id].quantity = _quantity;
    }

    // Elimina un producto de la tienda
    function deleteProduct(uint _id) public {
        // Comprueba si el producto existe
        require(products[_id].id != 0, "Product not found");
        // Elimina el producto
        delete products[_id];
    }

    // Obtiene la información de un producto
    function getProduct(uint _id) public view returns (uint, string memory, string memory, uint, uint) {
        // Comprueba si el producto existe
        require(products[_id].id != 0, "Product not found");
        // Devuelve la información del producto
        return (products[_id].id, products[_id].name, products[_id].description, products[_id].price, products[_id].quantity);
    }
}