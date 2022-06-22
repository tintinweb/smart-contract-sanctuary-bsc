pragma solidity ^0.8.0;

contract CollectionMock {
    mapping(uint256 => address) owners;

    mapping(uint256 => string) tokenUris;

    constructor() {
        owners[500] = 0x1e0B5Fc8a0a326DDE60023083B9e4D87C21f4Ad7;
        owners[501] = 0xEC8606785452802e21d1f90d3DB05465dbf40846;
        owners[502] = 0xFE0B8dEF601B3530035B8Eb6868ED4E4642972DF;
        owners[503] = 0x6e683544a16056a1C79991c0B0e821e1752AdFcc;
        owners[504] = 0x93B4c2ab9b544F3dDBA70f0FDb2589177a6ECdf9;
        tokenUris[501] = 'https://gateway.pinata.cloud/ipfs/Qmf6GmcTsWWgsEoyhpKocHLcCrDBZmFod4spuKGqfAifFG';
        tokenUris[502] = 'https://gateway.pinata.cloud/ipfs/QmTrxU7rF2oSCdLDyzWQtQ21SPFamCg1yQtzhNPRaCFBzE';
        tokenUris[503] = 'https://gateway.pinata.cloud/ipfs/QmaR74k3xkM7wcrQLSapUuks6RUmYiiP6yBPjjbjjgV3Qe';
        tokenUris[504] = 'https://gateway.pinata.cloud/ipfs/QmRcVz42z9ZjZWEnk7TQRMDXksyidwefnkRFKDVC6WDDXB';
        tokenUris[505] = 'https://gateway.pinata.cloud/ipfs/QmY3LkA2cCbe4QPDUbZ3EsjJVu4tyh1WU3RXbMDEmYVTV3';
    }

    function ownerOf(uint256 tokenId) external view returns (address owner) {
        return owners[tokenId];
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return tokenUris[tokenId];
    }
}