// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract ContractNFT {
    function baseHeroesAttribute(uint256 tokenID)
        external
        view
        virtual
        returns (uint256);

    function safeMint(address to, uint256 attribute) external virtual;

    function totalSupply() external view virtual returns (uint256);
}

contract HeroesTDFusionV2 is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter private _randomCounter;
    Counters.Counter private _indexEventCounter;

    uint256 public transferFeeCounter;

    ContractNFT public SMCNFT;

    IERC20 public htdAddress;
    IERC20 public cgcAddress;

    address public burnAddress;

    struct HeroesDetail {
        uint256 heroesId;
        uint256 heroesOrigin;
        uint256 heroesClass;
        uint256 heroesItem1;
        uint256 heroesItem2;
        uint256 heroesItem3;
        uint256 heroesRune1;
        uint256 heroesRune2;
        uint256 heroesRune3;
        uint256 gen;
        uint256 tag;
        uint256 heroesTargetType;
    }

    // List NFT support for sale
    mapping(address => bool) public supportNfts;

    // Summon Time
    mapping(uint256 => uint256) public heroesSummonTimes;

    //successRate[0] => 5
    mapping(uint256 => uint256) public successRate;
    //dropRate[0] => 35
    mapping(uint256 => uint256) public dropRate;

    struct ItemPair {
        uint256 item1;
        uint256 item2;
    }
    // Item Mix
    mapping(uint256 => ItemPair) public itemMix;

    struct mergeItemResult {
        uint256 item1;
        uint256 item2;
        uint256 item3;
    }

    struct ParentPair {
        uint256 fatherTokenId;
        uint256 motherTokenId;
    }
    mapping(uint256 => ParentPair) public parentPairs;

    struct ParentSummonCountPair {
        uint256 fatherSummonCount;
        uint256 motherSummonCount;
    }
    mapping(uint256 => ParentSummonCountPair) public parentSummonCountPairs;

    struct FeePair {
        uint256 htdAmount;
        uint256 cgcAmount;
    }

    mapping(uint256 => FeePair) public feePairs;

    address[] listAddressFee;

    // max supply for
    uint256 public maxSupplyFor;

    // set summonTime
    uint256 public maxSummontime;

    // set tokenId now
    uint256 public tokenIdNow;

    // Mapping birthday
    mapping(uint256 => uint256) public heroBirthday;

    // Calc time birth for fusion and play game
    uint256 public timeBirth;

    // Is egg hatched
    mapping(uint256 => bool) public isEggHatched;

    event EventFusion(
        uint256 fatherTokenId,
        uint256 motherTokenId,
        uint256 newHeroTokenId,
        uint256 heroTimeFusion,
        uint256 attribute,
        uint256 indexEvent
    );

    constructor() {
        setItemMix();
        maxSupplyFor = 1000;
    }

    /**
     * check address
     */
    modifier validAddress(address addr) {
        require(addr != address(0x0));
        _;
    }

    function validateToken(uint256 tokenIdA, uint256 tokenIdB)
        internal
        view
        returns (bool)
    {
        uint256 smTimeHero1 = heroesSummonTimes[tokenIdA];
        uint256 smTimeHero2 = heroesSummonTimes[tokenIdB];

        require(smTimeHero1 < maxSummontime, "Summontime had reached limit!!");
        require(smTimeHero2 < maxSummontime, "Summontime had reached limit!!");

        ParentPair storage heroAParent = parentPairs[tokenIdA];
        ParentPair storage heroBParent = parentPairs[tokenIdB];

        if (heroBirthday[tokenIdA] == 0 && heroBirthday[tokenIdB] == 0) {
            return true;
        }

        // Case father - father, mother - mother
        require(
            heroAParent.fatherTokenId != heroBParent.fatherTokenId,
            "Same parents!"
        );
        require(
            heroAParent.motherTokenId != heroBParent.motherTokenId,
            "Same parents!"
        );

        // Case father - mother, mother - father
        require(
            heroAParent.fatherTokenId != heroBParent.motherTokenId,
            "Same parents!"
        );
        require(
            heroAParent.motherTokenId != heroBParent.fatherTokenId,
            "Same parents!"
        );

        require(
            heroAParent.motherTokenId != tokenIdA,
            "Cannot summon with themself!"
        );
        require(
            heroAParent.fatherTokenId != tokenIdA,
            "Cannot summon with themself!"
        );

        require(
            heroBParent.motherTokenId != tokenIdB,
            "Cannot summon with themself!"
        );
        require(
            heroBParent.fatherTokenId != tokenIdB,
            "Cannot summon with themself!"
        );

        require(
            heroAParent.motherTokenId != tokenIdB,
            "Cannot summon with parents!"
        );
        require(
            heroAParent.fatherTokenId != tokenIdB,
            "Cannot summon with parents!"
        );

        require(
            heroBParent.motherTokenId != tokenIdA,
            "Cannot summon with parents!"
        );
        require(
            heroBParent.fatherTokenId != tokenIdA,
            "Cannot summon with parents!"
        );

        return true;
    }

    function setAddressHTDandCGC(address _htd, address _cgc)
        external
        onlyOwner
    {
        htdAddress = IERC20(_htd);
        cgcAddress = IERC20(_cgc);
    }

    function setListAddressFee(address[] memory _listAddressFee)
        external
        onlyOwner
    {
        listAddressFee = _listAddressFee;
    }

    function setSummonFee(
        uint256[] memory _listHTDFee,
        uint256[] memory _listCGCFee
    ) external onlyOwner {
        require(_listHTDFee.length == _listCGCFee.length, "List fee invalid!");

        for (uint256 i = 0; i < _listHTDFee.length; i++) {
            FeePair memory obj;
            obj.htdAmount = _listHTDFee[i] * 10**18;
            obj.cgcAmount = _listCGCFee[i] * 10**18;
            feePairs[i] = obj;
        }
    }

    function chargeFee(uint256 tokenIdA, uint256 tokenIdB) internal {
        uint256 smTimeHero1 = heroesSummonTimes[tokenIdA];
        uint256 smTimeHero2 = heroesSummonTimes[tokenIdB];

        uint256 totalHTDFee = feePairs[smTimeHero1].htdAmount +
            feePairs[smTimeHero2].htdAmount;
        uint256 totalCGCFee = feePairs[smTimeHero1].cgcAmount +
            feePairs[smTimeHero2].cgcAmount;

        htdAddress.safeTransferFrom(
            msg.sender,
            listAddressFee[transferFeeCounter],
            totalHTDFee
        );
        cgcAddress.safeTransferFrom(msg.sender, burnAddress, totalCGCFee);

        transferFeeCounter += 1;
        if (transferFeeCounter >= listAddressFee.length) {
            transferFeeCounter = 0;
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Set array nft support
    function addSupportNft(address nft) external onlyOwner validAddress(nft) {
        supportNfts[nft] = true;
    }

    // Remove array nft support
    function removeSupportNft(address nft)
        external
        onlyOwner
        validAddress(nft)
    {
        supportNfts[nft] = false;
    }

    function setSuccessRate(uint256[] memory _rates) external onlyOwner {
        for (uint256 i = 0; i < _rates.length; i++) {
            successRate[i] = _rates[i];
        }
    }

    function setDropRate(uint256[] memory _rates) external onlyOwner {
        for (uint256 i = 0; i < _rates.length; i++) {
            dropRate[i] = _rates[i];
        }
    }

    function setItemMix() public onlyOwner {
        uint256 index = 9;
        uint256 beginJ = 1;
        for (uint256 i = 1; i <= 8; i++) {
            for (uint256 j = beginJ; j <= 8; j++) {
                // uint256[2] memory pair = [i,j];
                ItemPair memory objPair;
                objPair.item1 = i;
                objPair.item2 = j;
                itemMix[index] = objPair;
                index++;
            }
            beginJ++;
        }
    }

    // Set max for
    function setMaxSupplyFor(uint256 _maxSupplyFor) external onlyOwner {
        maxSupplyFor = _maxSupplyFor;
    }

    // Set address burn
    function setAddressBurn(address _addressBurn) external onlyOwner {
        burnAddress = _addressBurn;
    }

    // Set
    function setSummonTime(uint256 _newMaxTime) external onlyOwner {
        maxSummontime = _newMaxTime;
    }

    // Set tokenId Now
    function setTokenIdNow(uint256 _newTokenIdNow) external onlyOwner {
        tokenIdNow = _newTokenIdNow;
    }

    // Set time birth
    function setTimeBirth(uint256 _newTimeBirth) external onlyOwner {
        timeBirth = _newTimeBirth;
    }

    // Set
    function setSmartContractNFT(address _newSMC) external onlyOwner {
        SMCNFT = ContractNFT(_newSMC);
    }

    function hatchEgg(address _nftAddress, uint256 _eggTokenId) public {
        require(supportNfts[_nftAddress] == true, "This NFT is invalid!!!");

        require(isEggHatched[_eggTokenId] == false, "This egg is hatched!!!");

        address owner = IERC721(_nftAddress).ownerOf(_eggTokenId);

        require(msg.sender == owner, "Owner is invalid!");

        uint256 totalTimeBirthDay = heroBirthday[_eggTokenId] + timeBirth;

        require(
            block.timestamp > totalTimeBirthDay,
            "This egg not valid to hatch!! Please wait more time!"
        );

        isEggHatched[_eggTokenId] = true;
    }

    function getHeroesAttribute(uint256 _tokenID)
        public
        view
        returns (HeroesDetail memory heroDetail)
    {
        uint256 nftAttribute = SMCNFT.baseHeroesAttribute(_tokenID);
        string memory stringAttribute = uint2str(nftAttribute);

        HeroesDetail memory objHero;

        objHero.heroesId = stringToUint(substring(stringAttribute, 0, 3)) - 100;
        objHero.heroesOrigin =
            stringToUint(substring(stringAttribute, 3, 5)) -
            10;
        objHero.heroesClass =
            stringToUint(substring(stringAttribute, 5, 7)) -
            10;
        uint256 heroesItem1 = stringToUint(substring(stringAttribute, 7, 9)) -
            10;
        uint256 heroesItem2 = stringToUint(substring(stringAttribute, 9, 11)) -
            10;
        uint256 heroesItem3 = stringToUint(substring(stringAttribute, 11, 13)) -
            10;
        objHero.heroesRune1 =
            stringToUint(substring(stringAttribute, 13, 15)) -
            10;
        objHero.heroesRune2 =
            stringToUint(substring(stringAttribute, 15, 17)) -
            10;
        objHero.heroesRune3 =
            stringToUint(substring(stringAttribute, 17, 19)) -
            10;
        objHero.tag = stringToUint(substring(stringAttribute, 19, 21)) - 10;
        objHero.heroesTargetType = stringToUint(
            substring(stringAttribute, 21, 22)
        );

        uint256[3] memory arrItem = [heroesItem1, heroesItem2, heroesItem3];

        uint256 gen;

        for (uint8 i = 0; i < arrItem.length; i++) {
            if (arrItem[i] > 8) {
                gen += 1;
            }
        }

        objHero.heroesItem1 = heroesItem1;
        objHero.heroesItem2 = heroesItem2;
        objHero.heroesItem3 = heroesItem3;
        objHero.gen = gen;

        return objHero;
    }

    function summonHeroes(
        address nftAddress,
        uint256 tokenIdA,
        uint256 tokenIdB
    ) external whenNotPaused validAddress(nftAddress) {
        require(supportNfts[nftAddress] == true, "This NFT is invalid!!!");

        // Get owner
        address owner1 = IERC721(nftAddress).ownerOf(tokenIdA);
        address owner2 = IERC721(nftAddress).ownerOf(tokenIdB);

        // Check owner
        require(owner2 == owner1, "Invalid owner NFT!!");

        require(msg.sender == owner1, "You are not owner!!");

        HeroesDetail memory hero1 = getHeroesAttribute(tokenIdA);
        HeroesDetail memory hero2 = getHeroesAttribute(tokenIdB);

        require(
            block.timestamp > heroBirthday[tokenIdA] + timeBirth,
            "Need wait hero birthday"
        );
        require(
            block.timestamp > heroBirthday[tokenIdB] + timeBirth,
            "Need wait hero birthday"
        );

        if (hero1.tag >= 10) {
            require(isEggHatched[tokenIdA] == true, "This egg not hatched!!!");
        }
        if (hero2.tag >= 10) {
            require(isEggHatched[tokenIdB] == true, "This egg not hatched!!!");
        }

        require(
            validateToken(tokenIdA, tokenIdB),
            "Token invalid inbreeding!!"
        );

        uint256[6] memory arrRune = [
            hero1.heroesRune1,
            hero1.heroesRune2,
            hero1.heroesRune3,
            hero2.heroesRune1,
            hero2.heroesRune2,
            hero2.heroesRune3
        ];

        uint256[6] memory arrShuffle = shuffle6(arrRune);

        mergeItemResult memory objItemResult = mergeItemHero(
            tokenIdA,
            tokenIdB,
            hero1,
            hero2
        );

        uint256 newTag = 10;
        // uint256 result = mergeAttribute(objNewHero, newItems, newTag);

        uint256 resultAttribute;
        resultAttribute =
            (mergeDetail(hero1.heroesId, hero2.heroesId) + 100) *
            10**19;
        resultAttribute +=
            (mergeDetail(hero1.heroesOrigin, hero2.heroesOrigin) + 10) *
            10**17;
        resultAttribute +=
            (mergeDetail(hero1.heroesClass, hero2.heroesClass) + 10) *
            10**15;
        resultAttribute += (objItemResult.item1 + 10) * 10**13;
        resultAttribute += (objItemResult.item2 + 10) * 10**11;
        resultAttribute += (objItemResult.item3 + 10) * 10**9;
        resultAttribute += (arrShuffle[0] + 10) * 10**7;
        resultAttribute += (arrShuffle[1] + 10) * 10**5;
        resultAttribute += (arrShuffle[2] + 10) * 10**3;
        resultAttribute += (newTag + 10) * 10**1;
        resultAttribute += mergeDetail(
            hero1.heroesTargetType,
            hero2.heroesTargetType
        );

        chargeFee(tokenIdA, tokenIdB);

        // mint NFT
        SMCNFT.safeMint(msg.sender, resultAttribute);

        // add parents summon pair
        ParentSummonCountPair memory objSummonCountParent;
        objSummonCountParent.fatherSummonCount = heroesSummonTimes[tokenIdA];
        objSummonCountParent.motherSummonCount = heroesSummonTimes[tokenIdB];

        // For to check tokenIdNow base in totalSup and max sup - Check case baseAttr == 0
        for (
            uint256 i = SMCNFT.totalSupply();
            i <= SMCNFT.totalSupply() + maxSupplyFor;
            i++
        ) {
            uint256 baseAttrCheck = SMCNFT.baseHeroesAttribute(i);

            if (baseAttrCheck == 0) {
                tokenIdNow = i;
            }
        }

        parentSummonCountPairs[tokenIdNow] = objSummonCountParent;

        // increase summon time
        heroesSummonTimes[tokenIdA] += 1;
        heroesSummonTimes[tokenIdB] += 1;

        // add parents pair
        ParentPair memory objParent;
        objParent.fatherTokenId = tokenIdA;
        objParent.motherTokenId = tokenIdB;

        parentPairs[tokenIdNow] = objParent;

        // Set birthday
        heroBirthday[tokenIdNow] = block.timestamp;

        //  increase tokenId
        // tokenIdNow += 1;

        _indexEventCounter.increment();
        emit EventFusion(
            tokenIdA,
            tokenIdB,
            tokenIdNow - 1,
            block.timestamp,
            resultAttribute,
            _indexEventCounter.current()
        );
    }

    function mergeItemHero(
        uint256 tokenIdA,
        uint256 tokenIdB,
        HeroesDetail memory hero1,
        HeroesDetail memory hero2
    ) internal returns (mergeItemResult memory) {
        uint256 smTimeHero1 = heroesSummonTimes[tokenIdA];
        uint256 smTimeHero2 = heroesSummonTimes[tokenIdB];

        uint256 totalSuccessRate = successRate[smTimeHero1] +
            successRate[smTimeHero2];
        uint256 totalDropRate = dropRate[smTimeHero1] + dropRate[smTimeHero2];

        uint256[3] memory listItemA = [
            hero1.heroesItem1,
            hero1.heroesItem2,
            hero1.heroesItem3
        ];
        uint256[3] memory listItemB = [
            hero2.heroesItem1,
            hero2.heroesItem2,
            hero2.heroesItem3
        ];

        mergeItemResult memory objItemResult;

        for (uint256 i = 0; i < 3; i++) {
            // uint256 listItemA[i] = listItemA[i];
            // uint256 listItemB[i] = listItemB[i];

            // Step 1: Pick A or B
            uint256 itemPick = mergeDetail(listItemA[i], listItemB[i]);
            uint256 itemResult = itemPick;

            if (itemPick > 8) {
                // Check if drop
                uint256 percentResult = random(100);
                if (percentResult <= totalDropRate) {
                    ItemPair storage pairObj = itemMix[itemPick];
                    itemResult = mergeDetail(pairObj.item1, pairObj.item2);
                } else {
                    uint256[4] memory itemLv2 = [
                        itemPick,
                        itemPick,
                        itemPick,
                        itemPick
                    ];

                    if (itemPick == listItemA[i]) {
                        for (uint256 j = 0; j < 3; j++) {
                            if (listItemB[j] > 8) {
                                itemLv2[j + 1] = listItemB[j];
                            } else {
                                itemLv2[j + 1] = itemPick;
                            }
                        }
                    } else if (itemPick == listItemB[i]) {
                        for (uint256 j = 0; j < 3; j++) {
                            if (listItemA[j] > 8) {
                                itemLv2[j + 1] = listItemA[j];
                            } else {
                                itemLv2[j + 1] = itemPick;
                            }
                        }
                    }

                    itemResult = shuffle4(itemLv2)[0];
                }
            } else {
                // Check if success
                uint256 percentResult = random(100);
                if (percentResult <= totalSuccessRate) {
                    mergeItemResult memory itemMerge;
                    uint256 itemMergeResult;
                    if (itemPick == listItemA[i]) {
                        for (uint256 k = 0; k < 3; k++) {
                            if (listItemB[k] < 9) {
                                uint256 minItem = min(itemPick, listItemB[k]);
                                uint256 maxItem = max(itemPick, listItemB[k]);

                                uint256 result = maxItem +
                                    minItem *
                                    8 -
                                    ((minItem * (minItem - 1)) / 2);
                                itemMergeResult = result;
                            } else {
                                itemMergeResult = listItemB[k];
                            }

                            if (k == 0) {
                                itemMerge.item1 = itemMergeResult;
                            } else if (k == 1) {
                                itemMerge.item2 = itemMergeResult;
                            } else {
                                itemMerge.item3 = itemMergeResult;
                            }
                        }
                    } else if (itemPick == listItemB[i]) {
                        for (uint256 k = 0; k < 3; k++) {
                            if (listItemA[k] < 9) {
                                uint256 minItem = min(itemPick, listItemA[k]);
                                uint256 maxItem = max(itemPick, listItemA[k]);
                                uint256 result = maxItem +
                                    minItem *
                                    8 -
                                    ((minItem * (minItem - 1)) / 2);
                                itemMergeResult = result;
                            } else {
                                itemMergeResult = listItemA[k];
                            }

                            if (k == 0) {
                                itemMerge.item1 = itemMergeResult;
                            } else if (k == 1) {
                                itemMerge.item2 = itemMergeResult;
                            } else {
                                itemMerge.item3 = itemMergeResult;
                            }
                        }
                    }
                    uint256[3] memory itemShuffle3 = [
                        itemMerge.item1,
                        itemMerge.item2,
                        itemMerge.item3
                    ];
                    itemResult = shuffle3(itemShuffle3)[0];
                } else {
                    uint256[4] memory itemLv1 = [
                        itemPick,
                        itemPick,
                        itemPick,
                        itemPick
                    ];
                    if (itemPick == listItemA[i]) {
                        for (uint256 j = 0; j < 3; j++) {
                            if (listItemB[j] < 9) {
                                itemLv1[j + 1] = listItemB[j];
                            } else {
                                itemLv1[j + 1] = itemPick;
                            }
                        }
                    } else if (itemPick == listItemB[i]) {
                        for (uint256 j = 0; j < 3; j++) {
                            if (listItemA[j] < 9) {
                                itemLv1[j + 1] = listItemA[j];
                            } else {
                                itemLv1[j + 1] = itemPick;
                            }
                        }
                    }

                    itemResult = shuffle4(itemLv1)[0];
                }
            }

            //newItems[i] = itemResult;
            if (i == 0) {
                objItemResult.item1 = itemResult;
            } else if (i == 1) {
                objItemResult.item2 = itemResult;
            } else if (i == 2) {
                objItemResult.item3 = itemResult;
            }
        }

        return objItemResult;
    }

    function shuffleItem(
        uint256 item1,
        uint256 item2,
        uint256 item3,
        uint256 item4
    ) internal view returns (uint256) {
        uint256[4] memory listItemAdd;
        uint256[4] memory listItemShuffle;
        listItemAdd = [item1, item2, item3, item4];
        listItemShuffle = shuffle4(listItemAdd);
        uint256 itemResult = listItemShuffle[0];

        return itemResult;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return b;
        }
        return a;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return a;
        }
        return b;
    }

    function mergeDetail(uint256 paramA, uint256 paramB)
        internal
        returns (uint256)
    {
        _randomCounter.increment();
        uint256 resultRandom = random(100);

        if (resultRandom >= 50) {
            return paramA;
        }

        return paramB;
    }

    function shuffle6(uint256[6] memory numberArr)
        internal
        view
        returns (uint256[6] memory arr)
    {
        for (uint256 i = numberArr.length - 1; i > 0; i--) {
            uint256 n = random(i + 1);
            (numberArr[n], numberArr[i]) = (numberArr[i], numberArr[n]);
        }

        return numberArr;
    }

    function shuffle4(uint256[4] memory numberArr)
        internal
        view
        returns (uint256[4] memory arr)
    {
        for (uint256 i = numberArr.length - 1; i > 0; i--) {
            uint256 n = random(i + 1);
            (numberArr[n], numberArr[i]) = (numberArr[i], numberArr[n]);
        }

        return numberArr;
    }

    function shuffle3(uint256[3] memory numberArr)
        internal
        view
        returns (uint256[3] memory arr)
    {
        for (uint256 i = numberArr.length - 1; i > 0; i--) {
            uint256 n = random(i + 1);
            (numberArr[n], numberArr[i]) = (numberArr[i], numberArr[n]);
        }

        return numberArr;
    }

    function shuffle2(uint256[2] memory numberArr)
        internal
        view
        returns (uint256[2] memory arr)
    {
        for (uint256 i = numberArr.length - 1; i > 0; i--) {
            uint256 n = random(i + 1);
            (numberArr[n], numberArr[i]) = (numberArr[i], numberArr[n]);
        }

        return numberArr;
    }

    // Random
    function random(uint256 num) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        _randomCounter.current(),
                        block.timestamp,
                        blockhash(block.number - 1),
                        tx.origin // Because may have many random in 1 block
                    )
                )
            ) % num;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function stringToUint(string memory s)
        public
        pure
        returns (uint256 result)
    {
        bytes memory b = bytes(s);
        uint256 i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    // Required function to allow receiving ERC-721 - When safeTransferFrom called auto implement this func if (to) is contract address
    function onERC721Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}