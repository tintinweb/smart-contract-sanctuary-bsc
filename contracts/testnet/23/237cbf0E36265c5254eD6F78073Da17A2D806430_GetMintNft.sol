// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetMintNft.sol";

contract GetMintNft {
    mapping(uint256 => uint256) public startNftID;
    struct EachNFT {
        uint16 level;
        uint16 count;
        uint256 amount;
        uint256 tokenId;
        string metaData;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        bool didStake;
        uint16 level;
        uint256 stakedTime;
        uint256 tokenId;
        uint256 amount;
        uint256 nftTokenId;
    }

    IGetMintNft collectionContract;

    constructor(address _collectionAddress) {
        collectionContract = IGetMintNft(_collectionAddress);
        startNftID[1] = 12000;
        startNftID[2] = 14000;
        startNftID[3] = 15000;
        startNftID[4] = 16000;
        startNftID[5] = 17000;
    }

    function getCountOfMyNFT(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 count;
        for (uint256 i = 1; i < collectionContract.tokenId(); i++) {
            uint256 start = startNftID[i];
            uint256 len = collectionContract.currentNftIds(uint16(i));
            for (uint256 j = start; j <= len; j++) {
                address nftOwner = collectionContract
                    .getTransaction(j)
                    .nftOwner;

                if (_userAddress == nftOwner) {
                    count++;
                }
            }
        }
        return count;
    }

    function getCountOfNFTs() public view returns (uint256) {
        uint256 count = 0;
        count = collectionContract._tokenIds() - 10000;
        return count;
    }

    function getAllMyNfts(address _userAddress)
        public
        view
        returns (Transaction[] memory)
    {
        uint256 currentIndex;
        Transaction[] memory items = new Transaction[](
            getCountOfMyNFT(_userAddress)
        );

        for (uint256 i = 1; i < collectionContract.tokenId(); i++) {
            uint256 start = startNftID[i];
            uint256 len = collectionContract.currentNftIds(uint16(i));
            for (uint256 j = start; j <= len; j++) {
                address nftOwner = collectionContract
                    .getTransaction(j)
                    .nftOwner;

                if (_userAddress == nftOwner) {
                    Transaction memory _tx = Transaction(
                        collectionContract.getTransaction(j).metaData,
                        collectionContract.getTransaction(j).nftOwner,
                        collectionContract.getTransaction(j).didStake,
                        collectionContract.getTransaction(j).level,
                        collectionContract.getTransaction(j).stakedTime,
                        collectionContract.getTransaction(j).tokenId,
                        collectionContract.getTransaction(j).amount,
                        collectionContract.getTransaction(j).nftTokenId
                    );
                    // return _tx;

                    items[currentIndex] = _tx;
                    // break;
                    currentIndex++;
                }
            }
        }

        // return currentIndex;
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
                collectionContract.getNFT(i).count,
                collectionContract.getNFT(i).amount,
                collectionContract.getNFT(i).tokenId,
                collectionContract.getNFT(i).metaData
            );
            items[currentIndex] = nft;
            currentIndex++;
        }
        return items;
    }

    function getTransactions() public view returns (Transaction[] memory) {
        uint256 itemCount = collectionContract._tokenIds() - 10000;

        uint256 currentIndex;
        Transaction[] memory items = new Transaction[](itemCount + 1);
        for (uint256 i = 1; i <= 5; i++) {
            uint256 start = startNftID[i];
            uint256 len = collectionContract.currentNftIds(uint16(i));
            for (uint256 j = start; j <= len; j++) {
                address nftOwner = collectionContract
                    .getTransaction(j)
                    .nftOwner;

                if (address(0) != nftOwner) {
                    Transaction memory _tx = Transaction(
                        collectionContract.getTransaction(j).metaData,
                        collectionContract.getTransaction(j).nftOwner,
                        collectionContract.getTransaction(j).didStake,
                        collectionContract.getTransaction(j).level,
                        collectionContract.getTransaction(j).stakedTime,
                        collectionContract.getTransaction(j).tokenId,
                        collectionContract.getTransaction(j).amount,
                        collectionContract.getTransaction(j).nftTokenId
                    );
                    items[currentIndex] = _tx;
                }
                // return _tx;

                // break;
                currentIndex++;
            }
        }
        return items;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGetMintNft {
    struct EachNFT {
        uint16 level;
        uint16 count;
        uint256 amount;
        uint256 tokenId;
        string metaData;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        bool didStake;
        uint16 level;
        uint256 stakedTime;
        uint256 tokenId;
        uint256 amount;
        uint256 nftTokenId;
    }

    function tokenId() external view returns (uint256);

    function _tokenIds() external view returns (uint256);

    function getNFT(uint256 _tokenid) external view returns (EachNFT memory);

    function getTransaction(uint256 _tokenid)
        external
        view
        returns (Transaction memory);

    function currentNftIds(uint16 _tokenid) external view returns (uint256);
}