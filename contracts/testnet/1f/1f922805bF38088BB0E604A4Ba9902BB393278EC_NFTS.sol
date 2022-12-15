// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./ERC1155.sol";
import "./Owner.sol";

contract NFTS is ERC1155, Owner {

    mapping (uint256 => string) private _uris;

    uint256[] public tokenIds;
    uint256 public tokenIdsLength;

    event Set_TokenUri(
        uint256 tokenId,
        string uri
    );

    constructor() ERC1155("https://gateway.pinata.cloud/ipfs/QmY1qEg8TBambB3Eb2B2TCZxM2Q8esBsZEQfzTvXVMNB14/") {
        address adminAddress = 0xa2AFecdeC22fd6f4d2677f9239D7362eA61Fdf12;
        mint(1, 9999); // Collection - Recreacion Turistica
        mint(2, 8888); // Collection - Transporte
        mint(3, 7777); // Collection - Hoteleria

        setTokenUri(1, "https://gateway.pinata.cloud/ipfs/QmY1qEg8TBambB3Eb2B2TCZxM2Q8esBsZEQfzTvXVMNB14/3.json");
        setTokenUri(2, "https://gateway.pinata.cloud/ipfs/QmY1qEg8TBambB3Eb2B2TCZxM2Q8esBsZEQfzTvXVMNB14/2.json");
        setTokenUri(3, "https://gateway.pinata.cloud/ipfs/QmY1qEg8TBambB3Eb2B2TCZxM2Q8esBsZEQfzTvXVMNB14/1.json");

        safeTransferFrom(msg.sender, adminAddress, 1, 9999, "");
        safeTransferFrom(msg.sender, adminAddress, 2, 8888, "");
        safeTransferFrom(msg.sender, adminAddress, 3, 7777, "");
    }

    function checkTokenIdExist(uint256 _tokenId) private view returns(bool){
        bool exists;
        for (uint256 i=0; i<tokenIds.length; i++) {
            if(tokenIds[i] == _tokenId){
                exists = true;
                break;
            }
        }
        return exists;
    }

    function mint(uint256 _tokenId, uint256 _amount) public isOwner {
        require(_tokenId > 0, "_tokenId is not valid");
        if(!checkTokenIdExist(_tokenId)){
            require(tokenIds.length<20, "cannot add new _tokenId, limit reached");
            tokenIds.push(_tokenId);
            tokenIdsLength++;
        }
        _mint(msg.sender, _tokenId, _amount, "");
    }

    function balancesOf(address _account) external view returns(uint256[] memory, uint256[] memory) {
        uint256[] memory ids = new uint256[](tokenIds.length);
        uint256[] memory balances = new uint256[](tokenIds.length);
        for (uint256 i=0; i<tokenIds.length; i++) {
            ids[i] = tokenIds[i];
            balances[i] = balanceOf(_account, tokenIds[i]);
        }
        return (ids, balances);
    }
    
    function setTokenUri(uint256 _tokenId, string memory _uri) public isOwner {
        _uris[_tokenId] = _uri;
        emit Set_TokenUri(_tokenId, _uri);
    }

    function uri(uint256 _tokenId) override public view returns (string memory) {
        return(_uris[_tokenId]);
    }

}