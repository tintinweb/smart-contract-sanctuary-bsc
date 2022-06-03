/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract SupplyChain {
    
    event Added(uint256 index);
    event Check(string output);
    
    struct State{
        string description;
        address person;
    }
    
    struct Product{
        string registrationNumber;
        address creator;
        string productName;
        uint256 productId;
        string genericName;
        string dosageStrength;
        string dosageForm;
        string countryOrigin;
        string trader;
        string manufacturer;
        string distributor;
        string importer;
        string manufactureDate;
        string expiryDate;
        uint256 totalStates;
        mapping (uint256 => State) positions;
        uint256 viewCount;
    }
    

    mapping(uint => Product) allProducts;
    uint256 items=0;
    
    function concat(string memory _a, string memory _b) public returns (string memory){
        bytes memory bytes_a = bytes(_a);
        bytes memory bytes_b = bytes(_b);
        string memory length_ab = new string(bytes_a.length + bytes_b.length);
        bytes memory bytes_c = bytes(length_ab);
        uint k = 0;
        for (uint i = 0; i < bytes_a.length; i++) bytes_c[k++] = bytes_a[i];
        for (uint i = 0; i < bytes_b.length; i++) bytes_c[k++] = bytes_b[i];
        return string(bytes_c);
    }
    
    function newItem(string memory _RGNum ,string memory _PNtext, string memory _GNtext,string memory _DSS, string memory _DSF , string memory _COtext,string memory _MR,string memory _TR,string memory _IM,string memory _DI,  string memory _MDdate, string memory _EDtext) public returns (bool) {
        Product memory added = Product({registrationNumber: _RGNum,creator: msg.sender, totalStates: 0, productName: _PNtext, productId: items, genericName: _GNtext,dosageStrength: _DSS,dosageForm: _DSF, countryOrigin: _COtext, manufacturer: _MR , trader: _TR,distributor: _DI,importer:_IM, manufactureDate: _MDdate, expiryDate: _EDtext, viewCount: 0});
        allProducts[items]=added;
        items = items+1;
        emit Added(items);
        return true;
    }


    function addState(uint _productId, string memory info) public returns (string memory) {
        require(_productId<=items);
        
        State memory newState = State({person: msg.sender, description: info});
        
        allProducts[_productId].positions[ allProducts[_productId].totalStates ]=newState;
        
        allProducts[_productId].totalStates = allProducts[_productId].totalStates +1;
        return info;
    }
    
    function searchProduct(uint _productId) public returns (bool) {
        require(_productId<=items);
        allProducts[_productId].viewCount += 1;
        if(allProducts[_productId].viewCount > 1){
            string memory output="QR Code already used!";
            emit Check(output);
            return true;
        }
        string memory output="Item Status: Verified";
        output=concat(output, "<br>Registration Number: ");
        output=concat(output, allProducts[_productId].registrationNumber);
        output=concat(output, "<br>Product Name: ");
        output=concat(output, allProducts[_productId].productName);
        output=concat(output, "<br>Generic Name: ");
        output=concat(output, allProducts[_productId].genericName);
        output=concat(output, "<br>Dosage Strength: ");
        output=concat(output, allProducts[_productId].dosageStrength);
        output=concat(output, "<br>Dosage Form: ");
        output=concat(output, allProducts[_productId].dosageForm);
        output=concat(output, "<br>Country Origin: ");
        output=concat(output, allProducts[_productId].countryOrigin);
        output=concat(output, "<br>Manufacturer: ");
        output=concat(output, allProducts[_productId].manufacturer);
        output=concat(output, "<br>Trader: ");
        output=concat(output, allProducts[_productId].trader);
        output=concat(output, "<br>Distributor: ");
        output=concat(output, allProducts[_productId].distributor);
        output=concat(output, "<br>Importer: ");
        output=concat(output, allProducts[_productId].importer);
        output=concat(output, "<br>Manufacture Date: ");
        output=concat(output, allProducts[_productId].manufactureDate);
        output=concat(output, "<br>Expiry Date: ");
        output=concat(output, allProducts[_productId].expiryDate);

        
        for (uint256 j=0; j<allProducts[_productId].totalStates; j++){
            output=concat(output, allProducts[_productId].positions[j].description);
        }
        emit Check(output);
        return true;
        
    }
    
}