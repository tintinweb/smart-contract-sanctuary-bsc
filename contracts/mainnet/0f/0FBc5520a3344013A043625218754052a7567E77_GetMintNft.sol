// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetMintNft.sol";
import "./interfaces/IGetMintNft.sol";

contract GetMintNft {
    struct EachNFT {
        uint16 level;
        uint256 amount;
        string metaData;
        uint16 tokenId;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        uint16 level;
        uint256 count;
        uint256 amount;
        uint16 tokenId;
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
        uint8 len = uint8(collectionContract.tokenId() - 1);

        uint256 index = 0;
        for (uint256 i = 1; i <= len; i++) {
            if (collectionContract.balanceOf(_userAddress, i) > 0) {
                index++;
            }
        }
        return index;
    }

    function getMyNfts(address _userAddress)
        public
        view
        returns (Transaction[] memory)
    {
        uint256 count = collectionContract.tokenId();
        uint256 len = getCountOfMyNFT(_userAddress);
        Transaction[] memory items = new Transaction[](len);
        uint256 index = 0;
        for (uint256 i = 1; i <= count; i++) {
            if (collectionContract.balanceOf(_userAddress, i) > 0) {
                items[index] = Transaction(
                    collectionContract.getNFT(i).metaData,
                    _userAddress,
                    collectionContract.getNFT(i).level,
                    collectionContract.balanceOf(_userAddress, i),
                    collectionContract.getNFT(i).amount,
                    collectionContract.getNFT(i).tokenId
                );
                index++;
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
                collectionContract.getNFT(i).metaData,
                collectionContract.getNFT(i).tokenId
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
        uint16 level;
        uint256 amount;
        string metaData;
        uint16 tokenId;
    }

    struct Transaction {
        string metaData;
        address nftOwner;
        uint16 level;
        uint256 count;
        uint256 amount;
        uint16 tokenId;
    }

    function tokenId() external view returns (uint256);

    function TxID() external view returns (uint256);

    function getNFT(uint256 _tokenid) external view returns (EachNFT memory);

    function getTransaction(uint256 _tokenid)
        external
        view
        returns (Transaction memory);

    function currentNftIds(uint16 _tokenid) external view returns (uint256);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);
}