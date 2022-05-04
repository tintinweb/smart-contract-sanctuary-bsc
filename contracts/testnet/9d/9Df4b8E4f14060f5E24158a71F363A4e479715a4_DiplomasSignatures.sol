// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract DiplomasSignatures {
    address[][] private _addresses;
    uint _layers;
    bool[][] _signed;

    constructor(uint layers, address[][] memory addresses) {
        _signed = new bool[][](layers);
        _addresses = new address[][](layers);
        _layers = layers;
        for (uint i = 0; i < layers; i++) {
            bool[] memory signers_line = new bool[](addresses[i].length);
            _addresses[i] = new address[](addresses[i].length);
            for (uint j = 0; j < addresses[i].length; j++) {
                _addresses[i][j] = addresses[i][j];
                signers_line[j] = false;
            }
            _signed[i] = signers_line;
        }
    }

    function getNumberOfLayers() public view returns (uint) {
        return _layers;
    }

    function getAddresses(uint layer) public view returns (address[] memory) {
        return _addresses[layer];
    }

    function getAllAddresses() public view returns (address[][] memory) {
        return _addresses;
    }

    function isSigned(uint layer) public view returns (bool) {
        for (uint i = 0; i < _signed[layer].length; i++) {
            if (!_signed[layer][i]) {
                return false;
            }
        }
        return true;
    }

    function isSigner(address signer) public view returns (bool, uint, uint) {
        for (uint i = 0; i < _layers; i++) {
            for (uint j = 0; j < _addresses[i].length; j++) {
                if (_addresses[i][j] == signer) {
                    return (true, i, j);
                }
            }
        }
        return (false, 0, 0);
    }

    function hasSigned(address signer, uint layer) public view returns (bool) {
        for (uint i = 0; i < _addresses[layer].length; i++) {
            if (_addresses[layer][i] == signer) {
                return _signed[layer][i];
            }
        }
        return false;
    }

    function sign(uint layer) public {
        (bool _isSigner, , uint index_in_layer) = isSigner(msg.sender);
        address[] memory addressesInLayer = getAddresses(layer);
        bool isInLayer = false;
        for (uint i = 0; i < addressesInLayer.length; i++) {
            if (addressesInLayer[i] == msg.sender) {
                isInLayer = true;
                break;
            }
        }
        require (_isSigner, "Only signers can sign");
        require (isInLayer, "Only signers in this layer can sign");
        require(!_signed[layer][index_in_layer], "You have already signed");
        _signed[layer][index_in_layer] = true;
    }
}