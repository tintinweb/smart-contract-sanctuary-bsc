// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Contract.sol";

interface BNFT {
    function tokenOfOwnerByIndex(address _owner, uint256 _index)
        external
        view
        returns (uint256);
}

abstract contract BNFTContract {
    address private _businessNFTAddress =
        0x534Cb8D1583E611469948fd92D9c19Ec8eeA96aa;

    function _tokenOfOwnerByIndex(address _owner, uint256 _index)
        internal
        view
        returns (uint256)
    {
        return BNFT(_businessNFTAddress).tokenOfOwnerByIndex(_owner, _index);
    }
}

//产品NFT
contract ProductNFT is ERC721Contract, BNFTContract {
    address private _sender;

    constructor() ERC721Contract("ProductNFT", "PNFT") {
        _sender = _msgSender();
    }

    function mintWithTokenURI(string memory _tokenURI) external returns (bool) {
        uint256 BNFTTokenId = _tokenOfOwnerByIndex(msg.sender, 0);
        require(BNFTTokenId != 0, "Permission denied");
        uint256 tokenId = _getRandomNumber();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return true;
    }

    function removeMinter(address tempAddress) external returns (bool) {
        require(_sender == _msgSender());
        _removeMinter(tempAddress);
        return true;
    }

    function transferOwnership(address newOwner) external {
        require(_sender == _msgSender());
        if (newOwner != address(0)) {
            _sender = newOwner;
        }
    }
}