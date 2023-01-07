// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetMintNft.sol";

contract GetMintNft {
    struct EachNFT {
        uint8 level;
        uint8 nftPart;
        uint256 tokenId;
        uint256 amount;
        string metaData;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        uint8 level;
        uint8 nftPart;
        uint256 amount;
        uint256 tokenId;
    }

    IGetMintNft collectionContract;

    constructor(address _collectionAddress) {
        collectionContract = IGetMintNft(_collectionAddress);
    }

    function getCountOfMyNFT(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 count;

        uint256 len = collectionContract.TxID();
        for (uint256 j = 0; j <= len; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (_userAddress == nftOwner) {
                count++;
            }
        }
        return count;
    }

    function getMyNfts(address _userAddress)
        public
        view
        returns (Transaction[] memory)
    {
        Transaction[] memory items = new Transaction[](
            getCountOfMyNFT(_userAddress)
        );
        uint256 itemCount = 0;
        uint256 len = collectionContract.TxID() + 1;
        for (uint256 j = 1; j <= len; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (_userAddress == nftOwner) {
                Transaction memory _tx = Transaction(
                    collectionContract.getTransaction(j).metaData,
                    collectionContract.getTransaction(j).nftOwner,
                    collectionContract.getTransaction(j).level,
                    collectionContract.getTransaction(j).nftPart,
                    collectionContract.getTransaction(j).amount,
                    collectionContract.getTransaction(j).tokenId
                );
                items[itemCount] = _tx;
                itemCount++;
            }
        }

        return items;
    }

    function getNFTS() public view returns (EachNFT[] memory) {
        uint256 itemCount = 16;
        uint256 currentIndex = 0;
        EachNFT[] memory items = new EachNFT[](itemCount);
        for (uint256 j = 1; j <= 4; j++) {
            for (uint256 x = 1; x <= 4; x++) {
                EachNFT memory nft = EachNFT(
                    collectionContract.getNFT(uint8(j), uint8(x)).level,
                    collectionContract.getNFT(uint8(j), uint8(x)).nftPart,
                    collectionContract.getNFT(uint8(j), uint8(x)).tokenId,
                    collectionContract.getNFT(uint8(j), uint8(x)).amount,
                    collectionContract.getNFT(uint8(j), uint8(x)).metaData
                );
                items[currentIndex] = nft;
                currentIndex++;
            }
        }
        return items;
    }

    function getTransactions() public view returns (Transaction[] memory) {
        uint256 itemCount = collectionContract.TxID();

        uint256 currentIndex;
        Transaction[] memory items = new Transaction[](itemCount);
        for (uint256 j = 1; j <= itemCount; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (address(0) != nftOwner) {
                Transaction memory _tx = Transaction(
                    collectionContract.getTransaction(j).metaData,
                    collectionContract.getTransaction(j).nftOwner,
                    collectionContract.getTransaction(j).level,
                    collectionContract.getTransaction(j).nftPart,
                    collectionContract.getTransaction(j).amount,
                    collectionContract.getTransaction(j).tokenId
                );
                items[currentIndex] = _tx;
            }
            currentIndex++;
        }
        return items;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGetMintNft {
    struct EachNFT {
        uint8 level;
        uint8 nftPart;
        uint256 tokenId;
        uint256 amount;
        string metaData;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        uint8 level;
        uint8 nftPart;
        uint256 amount;
        uint256 tokenId;
    }

    function tokenId() external view returns (uint256);

    function TxID() external view returns (uint256);

    function getNFT(uint8 level, uint8 part)
        external
        view
        returns (EachNFT memory);

    function getTransaction(uint256 _tokenid)
        external
        view
        returns (Transaction memory);

    function currentNftIds(uint16 _tokenid) external view returns (uint256);
}