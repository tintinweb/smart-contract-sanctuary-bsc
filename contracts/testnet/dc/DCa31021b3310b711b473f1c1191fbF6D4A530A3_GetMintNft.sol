// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetMintNft.sol";

contract GetMintNft {
    struct EachNFT {
        uint16 level;
        uint256 amount;
        string metaData;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        uint16 level;
        uint256 count;
        uint256 amount;
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
        uint256 currentIndex;
        Transaction[] memory items = new Transaction[](
            getCountOfMyNFT(_userAddress)
        );
        uint256 len = collectionContract.TxID();
        for (uint256 j = 1; j <= len; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (_userAddress == nftOwner) {
                Transaction memory _tx = Transaction(
                    collectionContract.getTransaction(j).metaData,
                    collectionContract.getTransaction(j).nftOwner,
                    collectionContract.getTransaction(j).level,
                    collectionContract.getTransaction(j).count,
                    collectionContract.getTransaction(j).amount
                );
                items[currentIndex] = _tx;
                currentIndex++;
            }
        }

        return items;
    }

    function getNFTS() public view returns (EachNFT[] memory) {
        uint256 tokenId = collectionContract.tokenId();
        uint256 itemCount = tokenId - 1;
        uint256 currentIndex;
        EachNFT[] memory items = new EachNFT[](itemCount);
        for (uint256 i = 1; i < itemCount + 1; i++) {
            EachNFT memory nft = EachNFT(
                collectionContract.getNFT(i).level,
                collectionContract.getNFT(i).amount,
                collectionContract.getNFT(i).metaData
            );
            items[currentIndex] = nft;
            currentIndex++;
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
                    collectionContract.getTransaction(j).count,
                    collectionContract.getTransaction(j).amount
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
        uint16 level;
        uint256 amount;
        string metaData;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        uint16 level;
        uint256 count;
        uint256 amount;
    }

    function tokenId() external view returns (uint256);

    function TxID() external view returns (uint256);

    function getNFT(uint256 _tokenid) external view returns (EachNFT memory);

    function getTransaction(uint256 _tokenid)
        external
        view
        returns (Transaction memory);

    function currentNftIds(uint16 _tokenid) external view returns (uint256);
}