// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetMintLandNft.sol";

contract GetLandNFT {
    IGetMintLandNft private collectionContract;

    constructor(address _collectionAddress) {
        collectionContract = IGetMintLandNft(_collectionAddress);
    }

    function getLandNFTS(uint256 start, uint256 end)
        public
        view
        returns (IGetMintLandNft.EachNFT[] memory)
    {
        uint256 currentIndex;
        IGetMintLandNft.EachNFT[] memory items = new IGetMintLandNft.EachNFT[](
            end - start + 1
        );
        for (uint256 i = start; i <= end; i++) {
            IGetMintLandNft.EachNFT memory nft = IGetMintLandNft.EachNFT(
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

    function getLandTransactions(uint256 start, uint256 end)
        public
        view
        returns (IGetMintLandNft.Transaction[] memory)
    {
        uint256 currentIndex;
        IGetMintLandNft.Transaction[]
            memory items = new IGetMintLandNft.Transaction[](end - start + 1);
        for (uint256 i = start; i <= end; i++) {
            IGetMintLandNft.Transaction memory _tx = IGetMintLandNft
                .Transaction(
                    collectionContract.getTransaction(i).metaData,
                    collectionContract.getTransaction(i).nftOwner,
                    collectionContract.getTransaction(i).didStake,
                    collectionContract.getTransaction(i).level,
                    collectionContract.getTransaction(i).stakedTime,
                    collectionContract.getTransaction(i).tokenId,
                    collectionContract.getTransaction(i).amount,
                    collectionContract.getTransaction(i).nftTokenId
                );
            items[currentIndex] = _tx;
            currentIndex++;
        }
        return items;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetNFTBox.sol";

contract GetMintNFTBOX {
    IGetNFTBox private collectionContract;

    constructor(address _collectionAddress) {
        collectionContract = IGetNFTBox(_collectionAddress);
    }

    function getBoxNFTS() public view returns (IGetNFTBox.EachNFT[] memory) {
        uint256 tokenId = collectionContract.tokenId();
        uint256 itemCount = tokenId - 1;
        uint256 currentIndex;
        IGetNFTBox.EachNFT[] memory items = new IGetNFTBox.EachNFT[](itemCount);
        for (uint256 i = 1; i < itemCount + 1; i++) {
            IGetNFTBox.EachNFT memory nft = IGetNFTBox.EachNFT(
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

    function getBoxTransactions()
        public
        view
        returns (IGetNFTBox.Transaction[] memory)
    {
        uint256 itemCount = collectionContract.TxID();

        uint256 currentIndex;
        IGetNFTBox.Transaction[] memory items = new IGetNFTBox.Transaction[](
            itemCount
        );

        for (uint256 j = 1; j <= itemCount; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (address(0) != nftOwner) {
                IGetNFTBox.Transaction memory _tx = IGetNFTBox.Transaction(
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetResourcesNFT.sol";

//
contract GetResourcesNFT {
    struct EachResourcesNFT {
        uint16 level;
        uint256 amount;
        string metaData;
        uint16 tokenId;
    }

    struct Package {
        uint8 level;
        uint256[4] counts;
        uint256[4] prices;
    }

    struct ResourcesTransaction {
        string metaData;
        address nftOwner;
        uint16 level;
        uint256 count;
        uint256 amount;
        uint16 tokenId;
    }

    IGetMintNft private collectionContract;

    constructor(address _collectionAddress) {
        collectionContract = IGetMintNft(_collectionAddress);
    }

    function getResourcesNFTS()
        public
        view
        returns (EachResourcesNFT[] memory)
    {
        uint256 tokenId = collectionContract.tokenId();
        uint256 itemCount = tokenId - 1;
        uint256 currentIndex;
        EachResourcesNFT[] memory items = new EachResourcesNFT[](itemCount);
        for (uint256 i = 1; i < itemCount + 1; i++) {
            EachResourcesNFT memory nft = EachResourcesNFT(
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

    function getResourcesPackages() public view returns (Package[] memory) {
        Package[] memory details = new Package[](4);
        for (uint256 i = 1; i <= 4; i++) {
            uint256[4] memory counts;
            uint256[4] memory prices;
            for (uint256 j = 0; j < 4; j++) {
                counts[j] = collectionContract.tokenAmounts(uint8(i), j);
                prices[j] = collectionContract.tokenPrices(uint8(i), j);
            }
            details[i - 1] = Package(uint8(i), counts, prices);
        }
        return details;
    }

    function getResourcesTransactions(uint256 start, uint256 end)
        public
        view
        returns (ResourcesTransaction[] memory)
    {
        uint256 currentIndex;
        ResourcesTransaction[] memory items = new ResourcesTransaction[](
            end - start + 1
        );
        for (uint256 j = start; j <= end; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (address(0) != nftOwner) {
                ResourcesTransaction memory _tx = ResourcesTransaction(
                    collectionContract.getTransaction(j).metaData,
                    collectionContract.getTransaction(j).nftOwner,
                    collectionContract.getTransaction(j).level,
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetSegmentNFT.sol";

contract GetSegmentNFT {
    struct EachNFT {
        uint8 level;
        uint8 nftPart;
        uint256 tokenId;
        uint256 amount;
        string metaData;
    }

    struct TranactionsSegment {
        string metaData;
        address nftOwner;
        uint8 level;
        uint8 nftPart;
        uint256 userNftCount;
        uint256 amount;
        uint256 tokenId;
    }

    IGetSegmentNFT private collectionContract;

    constructor(address _collectionAddress) {
        collectionContract = IGetSegmentNFT(_collectionAddress);
    }

    function getSegmentNFTS() public view returns (EachNFT[] memory) {
        uint256 itemCount = 16;
        uint256 currentIndex = 0;
        EachNFT[] memory items = new EachNFT[](itemCount);
        for (uint256 i = 1; i <= 16; i++) {
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

    function getSegmentTransactions(uint256 start, uint256 end)
        public
        view
        returns (TranactionsSegment[] memory)
    {
        uint256 currentIndex;
        TranactionsSegment[] memory items = new TranactionsSegment[](
            end - start + 1
        );
        for (uint256 j = start; j <= end; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (address(0) != nftOwner) {
                TranactionsSegment memory _tx = TranactionsSegment(
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IGetMintSpaceShip.sol";

contract GetShipNFT {
    mapping(uint256 => uint256) public startNftID;

    IGetMintSpaceShip private collectionContract;

    constructor(address _collectionAddress) {
        collectionContract = IGetMintSpaceShip(_collectionAddress);
        startNftID[1] = 12000;
        startNftID[2] = 14000;
        startNftID[3] = 15000;
        startNftID[4] = 16000;
        startNftID[5] = 17000;
    }

    function getShipNFTS()
        public
        view
        returns (IGetMintSpaceShip.EachNFT[] memory)
    {
        uint256 tokenId = collectionContract.tokenId();
        uint256 itemCount = tokenId - 1;
        uint256 currentIndex;
        IGetMintSpaceShip.EachNFT[]
            memory items = new IGetMintSpaceShip.EachNFT[](itemCount);
        for (uint256 i = 1; i < itemCount + 1; i++) {
            IGetMintSpaceShip.EachNFT memory nft = IGetMintSpaceShip.EachNFT(
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

    function getShipTransactions(uint256 start, uint256 end)
        public
        view
        returns (IGetMintSpaceShip.Transaction[] memory)
    {
        uint256 currentIndex;
        IGetMintSpaceShip.Transaction[]
            memory items = new IGetMintSpaceShip.Transaction[](end - start + 1);

        for (uint256 j = start; j <= end; j++) {
            address nftOwner = collectionContract.getTransaction(j).nftOwner;

            if (address(0) != nftOwner) {
                IGetMintSpaceShip.Transaction memory _tx = IGetMintSpaceShip
                    .Transaction(
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
            currentIndex++;
        }
        return items;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGetMintLandNft {
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
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGetMintSpaceShip {
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGetNFTBox {
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

    function tokenID() external view returns (uint256);

    function TxID() external view returns (uint256);

    function getNFT(uint256 id) external view returns (EachNFT memory);

    function getTransaction(uint256 _tokenid)
        external
        view
        returns (Transaction memory);

    function currentNftIds(uint16 _tokenid) external view returns (uint256);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function tokenAmounts(uint8 _tokenid, uint256 _index)
        external
        view
        returns (uint256);

    function tokenPrices(uint8 _tokenid, uint256 _index)
        external
        view
        returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGetSegmentNFT {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GetLandNft.sol";
import "./GetShipNFT.sol";
import "./GetSegmentNFT.sol";
import "./GetResourcesNFT.sol";
import "./GetMintNFTBOX.sol";

contract SpaceSixContracts is
    GetShipNFT(0xa47cf3CE42C2045e071f1119e3e305ef1638a20A),
    GetLandNFT(0xcB9ed56dB9960aa9ea305a1A2776e7eF64aa34d3),
    GetSegmentNFT(0x7FE1a9e8ac319bb886BA249a8e9496CA5ddF4776),
    GetResourcesNFT(0x1399992B1fe7Ea36E643dc2C1C51a1227Ea2aE6e),
    GetMintNFTBOX(0x40a5Fc85D02561dF5fAC18FCFb86Bcd26b26b8Cb)
{}