/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.6.0;

contract LexeonPackagesPrice {
    address private owner;
    
    uint256 private minimumPackagePrice;

    mapping(uint8 => mapping(uint8 => uint256)) packages;
    
    modifier isPackageExist (uint8 _matrix, uint8 _packageNum) {
        if(_matrix == 1 || _matrix == 3) {
            require(_packageNum >= 1 && _packageNum <= 15, "Learning package does not exist!");
            _;
        } else if (_matrix == 2) {
            require(_packageNum >= 1 && _packageNum <= 8, "Learning package does not exist!");
            _;
        }
    }

    modifier isMatrixExist (uint8 _matrix) {
        require(_matrix >= 1 && _matrix <= 3, "Matrix not exist!");
        _;
    }

    modifier onlyOwner () {
        require(owner == tx.origin, "Only owner of smart contract can call this method!");
        _;
    }

    modifier canNotBeSame (uint8 _matrix, uint8 _packageNum, uint256 _newPrice) {
        require(_newPrice != packages[_matrix][_packageNum], "Please add different package price!");
        _;
    }

    modifier shouldBeGreater (uint256 _newPrice) {
        require(_newPrice >= minimumPackagePrice, "Package price should be equal or greater than minimum price!");
        _;
    }

    constructor () public {
        owner = msg.sender;
        for(uint8 i = 1; i <= 15; i++){
            if(i <= 8) {
                packages[2][i] = 0.01 ether;
            }
            packages[1][i] = 0.01 ether;
            packages[3][i] = 0.01 ether;
        }
    }
    
    function setPrice (uint8 _matrix, uint8 _packageNum, uint256 _newPrice)
    public
    onlyOwner 
    isMatrixExist(_matrix)
    isPackageExist(_matrix, _packageNum)
    canNotBeSame(_matrix, _packageNum, _newPrice)
    shouldBeGreater(_newPrice) {
        packages[_matrix][_packageNum] = _newPrice;
    }

    function getPrice (uint8 _matrix, uint8 _packageNum) 
    public view isMatrixExist(_matrix)
    isPackageExist(_matrix, _packageNum)
    returns(uint256){
        return packages[_matrix][_packageNum];
    }

}