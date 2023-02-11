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
        uint256 userNftCount;
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
        uint8 len = 16;

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
        uint256 count = 4;
        uint256 len = getCountOfMyNFT(_userAddress);
        Transaction[] memory items = new Transaction[](len);
        uint256 index = 0;
        for (uint256 i = 1; i <= count; i++) {
            if (collectionContract.balanceOf(_userAddress, i) > 0) {
                items[index] = Transaction(
                    collectionContract.getNFT(uint8(i)).metaData,
                    _userAddress,
                    collectionContract.getNFT(uint8(i)).level,
                    collectionContract.getNFT(uint8(i)).nftPart,
                    collectionContract.balanceOf(_userAddress, i),
                    collectionContract.getNFT(uint8(i)).amount,
                    collectionContract.getNFT(uint8(i)).tokenId
                );
                index++;
            }
        }
        return items;
    }

    function getNFTS() public view returns (EachNFT[] memory) {
        uint256 itemCount = 4;
        uint256 currentIndex = 0;
        EachNFT[] memory items = new EachNFT[](itemCount);
        for (uint256 i = 1; i <= 4; i++) {
            EachNFT memory nft = EachNFT(
                collectionContract.getNFT(uint8(i)).level,
                collectionContract.getNFT(uint8(i)).nftPart,
                collectionContract.getNFT(uint8(i)).tokenId,
                collectionContract.getNFT(uint8(i)).amount,
                collectionContract.getNFT(uint8(i)).metaData
            );
            items[currentIndex] = nft;
            currentIndex++;
        }
        return items;
    }

    function getTransactions(uint256 start, uint256 end)
        public
        view
        returns (Transaction[] memory)
    {
        uint256 currentIndex;
        Transaction[] memory items = new Transaction[](end - start + 1);
        for (uint256 j = start; j <= end; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (address(0) != nftOwner) {
                Transaction memory _tx = Transaction(
                    collectionContract.getTransaction(j).metaData,
                    collectionContract.getTransaction(j).nftOwner,
                    collectionContract.getTransaction(j).level,
                    collectionContract.getTransaction(j).nftPart,
                    collectionContract.balanceOf(nftOwner, j),
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

    function tokenID() external view returns (uint256);

    function TxID() external view returns (uint256);

    function getNFT(uint8 id) external view returns (EachNFT memory);

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