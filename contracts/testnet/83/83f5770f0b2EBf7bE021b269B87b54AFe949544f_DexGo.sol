// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./BokkyPooBahsDateTimeLibrary.sol";

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "./IDexGoNFT.sol";
import "./IDexGoStorage.sol";
import "./IDexGoRentAndKm.sol";


contract DexGo is Ownable,IERC721Receiver {
    using SafeMath for uint256;

    address public storageContract;
    function setStorageContract(address _storageContract) public onlyOwner {
        storageContract = _storageContract;
    }
    function getStorageContract() public view returns (address) {
        return storageContract;
    }
    constructor(address _storageContract) {
        storageContract =_storageContract;
    }

    // shoes:
    uint8 public constant SHOES0 = 0;
    uint8 public constant SHOES1 = 1;
    uint8 public constant SHOES2 = 2;
    uint8 public constant SHOES3 = 3;
    uint8 public constant SHOES4 = 4;
    uint8 public constant SHOES5 = 5;
    uint8 public constant SHOES6 = 6;
    uint8 public constant SHOES7 = 7;
    uint8 public constant SHOES8 = 8;
    uint8 public constant SHOES9 = 9;
    uint8 public constant MAGIC_BOX = 10;

    uint8 public constant PATH = 100;
    uint8 public constant MOVIE = 200;

    uint256 balanceOfPaths;
    mapping(uint256 => address) public pathsOwners;
    struct Approval {
        uint256 shoesTokenId;
        address sender;
        uint256 pathTokenId;
        string socialPostURL;
    }
    /*Лидер мнений или обычный игрок(прошедший более 2-х маршрутов сам) разрабатывает и открывает другим пользователям маршруты
    лидером мнений по одному, с максимальным выпуском трасс в 20 штук для одного лидера
    % распределения вознаграждения для каждого отрезка пути и для каждой остановки (в сумме 100%)
    Стартовая цена создания маршрута составляет 50 долларов. Однако каждая новая создание увеличивает ее цену на 10% для этого лидера мнений.
    После имплементации маршрута в систему командой проекта, лидер мнений должен купить обувь и пройти маршрут сам.
    С этого момента маршрут активируется и доступен в системе для любого игрока, который купил обувь.
    Чтобы лидеры мнений активнее привлекали игроков к соревнованиям на своих маршрутах и тем самым развивали игровую экономику,
    в dexGo предусмотрен максимальный период простоя маршрута. Если никто не проходит маршрут в течении 90 дней,
    он деактивируется и не может более использоваться в системе.
    Дата создания маршрута влияет на максимальный период простоя и на распределение доходов.
    Чем раньше созданы маршруты, тем больше получает лидер мнений и тем больше у него максимальный период простоя.
    */
    Approval[] public approvalsAddPathStack;
    event RegisterAddPath(uint256 indexed tokenId);
    function registerAddPath(uint256 tokenId, uint kmWei) public payable nonReentrant {
        require(msg.value >= IDexGoStorage(storageContract).getFixedPathApprovalAmount().sub(IDexGoStorage(storageContract).getValueDecrease()), "dexGo: wrong value");

        require(!IDexGoStorage(storageContract).getInAppPurchaseBlackListWallet(msg.sender) && !IDexGoStorage(storageContract).getInAppPurchaseBlackListTokenId(tokenId), "wallet or tokenId blacklisted");
        require(IDexGoStorage(storageContract).getTypeForId(tokenId) == PATH, "DexGo: wrong type");
        IDexGoNFT(IDexGoStorage(storageContract).getNftContract()).approveMainContract(address(this), tokenId);
        IERC721(IDexGoStorage(storageContract).getNftContract()).safeTransferFrom(msg.sender, address(this), tokenId);
        IDexGoStorage(storageContract).setKmForPath(tokenId, kmWei);
        pathsOwners[tokenId] = msg.sender;
        balanceOfPaths++;
        emit RegisterAddPath(tokenId);
        approvalsAddPathStack.push(Approval(type(uint256).max, msg.sender, tokenId, ""));
    }
    mapping(uint256 => uint256) public pathsApproved;
    uint256 pathsApprovedCount;
    function setPathApproved(uint pathTokenId, bool approved) public {
        require(msg.sender == IDexGoStorage(storageContract).getAccountTeam1() || msg.sender == IDexGoStorage(storageContract).getAccountTeam2() || msg.sender == owner() || msg.sender == IDexGoStorage(storageContract).getGameServer(),'only admin accounts can change ');
        require(IDexGoStorage(storageContract).getTypeForId(pathTokenId) == PATH, "DexGo: wrong type");
        require(pathsOwners[pathTokenId] != address (0), "DexGo: path not added");
        require(IDexGoStorage(storageContract).getKmForPath(pathTokenId) > 0.0005 ether, "DexGo: wrong km"); // TODO - temporary low price
        pathsApproved[pathsApprovedCount] = pathTokenId;
        if (approved) pathsApprovedCount++;
        else pathsApprovedCount--;
    }
    function getPathsApproved() public view returns (uint256[] memory) {
        uint256 [] memory result = new uint256 [](pathsApprovedCount);

        for(uint256 x=0;x<pathsApprovedCount;x++) {
            result[x] = pathsApproved[x];
        }
        return result;
    }
    function isPathApproved(uint pathTokenId) public view returns (bool) {
        for(uint256 x=0;x<pathsApprovedCount;x++) {
            if (pathsApproved[x] == pathTokenId) {
                return true;
            }
        }
        return false;
    }


    Approval[] public approvalsReturnPathStack;
    event RegisterReturnPath(uint256 indexed tokenId);
    function registerReturnPath(uint256 tokenId) public nonReentrant {
        require(!IDexGoStorage(storageContract).getInAppPurchaseBlackListWallet(msg.sender) && !IDexGoStorage(storageContract).getInAppPurchaseBlackListTokenId(tokenId), "wallet or tokenId blacklisted");
        require(msg.sender == pathsOwners[tokenId], "DexGo: you are not owner of this NFT");
        require(IDexGoStorage(storageContract).getTypeForId(tokenId) == PATH, "DexGo: wrong type");

        emit RegisterReturnPath(tokenId);
        approvalsReturnPathStack.push(Approval(type(uint256).max, msg.sender, tokenId, ""));
    }
    function approveReturnPath(uint pathTokenId) public {
        require(msg.sender == IDexGoStorage(storageContract).getAccountTeam1() || msg.sender == IDexGoStorage(storageContract).getAccountTeam2() || msg.sender == owner() || msg.sender == IDexGoStorage(storageContract).getGameServer(),'only admin accounts can change ');
        require(IDexGoStorage(storageContract).getTypeForId(pathTokenId) == PATH, "DexGo: wrong type");
        require(pathsOwners[pathTokenId] != address (0), "DexGo: path not added");

        for(uint256 x=0;x<pathsApprovedCount;x++) {
            if (pathsApproved[x] == pathTokenId) {
                pathsApproved[x] = 0;
                pathsApprovedCount--;
                break;
            }
        }

        for(uint256 x=0;x<approvalsReturnPathStack.length;x++) {
            if (approvalsReturnPathStack[x].pathTokenId == pathTokenId) {
                delete approvalsReturnPathStack[x];
                break;
            }
        }
        IERC721(IDexGoStorage(storageContract).getNftContract()).safeTransferFrom(address(this), msg.sender , pathTokenId);
        balanceOfPaths--;
        delete pathsOwners[pathTokenId];
    }

    mapping(uint256 =>  mapping(uint256 => uint256)) public completedCountTotal;  //[pathID][shoesID]
    mapping(uint256 =>  mapping(uint256 => mapping(uint256 => uint256))) public completedCountMonth;  // [pathID][shoesID][yearMonth]

    Approval[] public approvalsPathCompletedStack;
    event RegisterApprovalForPathCompleted(uint256 indexed shoesTokenId, uint256 indexed pathTokenId, string socialPostURL);
    function registerApprovalForPathCompleted(uint256 shoesTokenId, uint256 pathTokenId, string memory socialPostURL) public payable nonReentrant {
        require(!IDexGoStorage(storageContract).getInAppPurchaseBlackListWallet(msg.sender) &&
        !IDexGoStorage(storageContract).getInAppPurchaseBlackListTokenId(shoesTokenId) , "wallet or tokenId blacklisted");
        require(msg.value >= IDexGoStorage(storageContract).getFixedApprovalAmount().sub(IDexGoStorage(storageContract).getValueDecrease()), "dexGo: wrong value");
        require(pathsOwners[pathTokenId] != address (0), "DexGo: path not added");
        require(IDexGoStorage(storageContract).getTypeForId(shoesTokenId) < 10, "DexGo: wrong shoes type");
        require(IDexGoStorage(storageContract).getTypeForId(pathTokenId) == PATH, "DexGo: wrong path type");
        require(isPathApproved(pathTokenId) == true, "DexGo: path must be approved");
        require(IDexGoStorage(storageContract).getKmLeavesForId(shoesTokenId) > IDexGoStorage(storageContract).getKmForPath(pathTokenId), "DexGo: not enough km on shoes to cover path");

        Address.sendValue(payable(IDexGoStorage(storageContract).getNftContract()), IDexGoStorage(storageContract).getFixedApprovalAmount());
        IDexGoNFT(IDexGoStorage(storageContract).getNftContract()).distributeMoney(msg.sender, IDexGoStorage(storageContract).getFixedApprovalAmount());
        IDexGoStorage(storageContract).setKmForId(shoesTokenId, IDexGoStorage(storageContract).getKmLeavesForId(shoesTokenId) - IDexGoStorage(storageContract).getKmForPath(pathTokenId));
        emit RegisterApprovalForPathCompleted(shoesTokenId, pathTokenId, socialPostURL);
        approvalsPathCompletedStack.push(Approval(shoesTokenId, msg.sender, pathTokenId, socialPostURL));
    }
    event ApprovedForPathCompleted(uint256 shoesTokenId, uint256 pathTokenId, uint256 rewardShoesOwner, uint256 rewardPathOwner, uint256 rewardShoesBorrower, address borrower);
    function approvePathCompleted(uint256 shoesTokenId, uint256 pathTokenId, uint16 completedResultInPercents) public nonReentrant {
        require(msg.sender == IDexGoStorage(storageContract).getAccountTeam1() || msg.sender == IDexGoStorage(storageContract).getAccountTeam2() || msg.sender == owner() || msg.sender == IDexGoStorage(storageContract).getGameServer(),'only admin accounts can change ');
        require(IDexGoStorage(storageContract).getTypeForId(pathTokenId) == PATH, "DexGo: wrong type");
        require(pathsOwners[pathTokenId] != address (0), "DexGo: path not added");

//        uint256 [] memory result = new uint256 [](approvalsPathCompletedStack.length);

        for(uint256 x=0;x<approvalsPathCompletedStack.length;x++) {
            if (approvalsPathCompletedStack[x].pathTokenId == pathTokenId && approvalsPathCompletedStack[x].shoesTokenId == shoesTokenId) {
              // match approval stack
                require(
                    !IDexGoStorage(storageContract).getInAppPurchaseBlackListWallet(approvalsPathCompletedStack[x].sender) &&
                !IDexGoStorage(storageContract).getInAppPurchaseBlackListTokenId(approvalsPathCompletedStack[x].shoesTokenId) &&
                !IDexGoStorage(storageContract).getInAppPurchaseBlackListTokenId(approvalsPathCompletedStack[x].pathTokenId)
                , "wallet or tokenId blacklisted");
                delete approvalsPathCompletedStack[x];
                completedCountTotal[pathTokenId][shoesTokenId]++;
                uint256 month = BokkyPooBahsDateTimeLibrary.getMonth(block.timestamp);
                uint256 year = BokkyPooBahsDateTimeLibrary.getYear(block.timestamp);
                completedCountMonth[pathTokenId][shoesTokenId][year * 100 + month]++;
                // path owner - 30%, shoes owner - 70%
                uint256 rewardForPathCompletedResult = rewardForPathCompleted(shoesTokenId, pathTokenId, completedResultInPercents);
                uint256 pathOwnerValue = rewardForPathCompletedResult * 30 / 100;
                Address.sendValue(payable(IERC721(IDexGoStorage(storageContract).getNftContract()).ownerOf(pathTokenId)), pathOwnerValue);

                uint256 shoesOwnerValue = rewardForPathCompletedResult - pathOwnerValue;
                (bool rentable, uint percentInWei, address borrower) = IDexGoRentAndKm(IDexGoStorage(storageContract).getRentAndKm()).rentParameters(shoesTokenId);
                if (rentable) {
                    uint256 borrowerValue = shoesOwnerValue * percentInWei / 1 ether;
                    Address.sendValue(payable(borrower), borrowerValue);
                    Address.sendValue(payable(IERC721(IDexGoStorage(storageContract).getNftContract()).ownerOf(shoesTokenId)), shoesOwnerValue - borrowerValue);
                    emit ApprovedForPathCompleted(shoesTokenId, pathTokenId, shoesOwnerValue - borrowerValue, pathOwnerValue, borrowerValue, borrower);
                } else {
                    Address.sendValue(payable(IERC721(IDexGoStorage(storageContract).getNftContract()).ownerOf(shoesTokenId)), shoesOwnerValue);
                    emit ApprovedForPathCompleted(shoesTokenId, pathTokenId, shoesOwnerValue, pathOwnerValue, 0, borrower);
                }
            }
        }
    }

    /*Во время игры на специальный смарт-контракт ложатся NFT-маршрутов и NFT обуви. Каждая продажа/восстановление обуви, активация маршрута (рекламного или от лидера мнений)
  создает денежный поток . Эти средства также поступают на смарт-контракт. После прохождения маршрута игрок получает определенную часть от сформированных денежных средств
  по принципу:
Все собранные деньги делятся на 6 месяцев, по календарным дням
Остаток за месяц делится на всех, кто прошел маршрут, но не более 1% от остатка и не более чем текущая цена продажи обуви
Каждое повторное прохождение маршрута уменьшает максимум (текущая цена продажи обуви) в 10ть раз
Сумму уменьшает неверно пройденные квизы, плохой результат в мини-игре дополненной реальности а также износ/дата выпуска обуви.
Сумму увеличивает групповое прохождение маршрута, причем часть прибавки получают лучшие по результатам в группе
Не выбранный остаток переносится на следующий месяц
*/
    function rewardForPathCompleted(uint256 shoesTokenId, uint256 pathTokenId, uint16 completedResultInPercents) public view returns (uint256) {
        // TODO - need return path reward and shoes reward, rent must be calculated, km must calculated
        uint256 day = BokkyPooBahsDateTimeLibrary.getDay(block.timestamp);
        uint256 month = BokkyPooBahsDateTimeLibrary.getMonth(block.timestamp);
        uint256 year = BokkyPooBahsDateTimeLibrary.getYear(block.timestamp);

        uint256 forMonthReward = address(this).balance / 6;
        uint256 leavedRewardForAll = forMonthReward / day;
        uint256 reward = leavedRewardForAll;
        uint256 completedCountMonthResult = completedCountMonth[pathTokenId][shoesTokenId][year * 100 + month];
        if (completedCountMonthResult > 0) reward = reward / completedCountMonthResult;
        if (completedCountTotal[pathTokenId][shoesTokenId] > 0) reward = reward / 10;// divide 10
        if (reward > leavedRewardForAll / 100) reward = leavedRewardForAll / 100;
        if (reward > IDexGoStorage(storageContract).getPriceForType(IDexGoStorage(storageContract).getTypeForId(shoesTokenId))) reward = IDexGoStorage(storageContract).getPriceForType(IDexGoStorage(storageContract).getTypeForId(shoesTokenId));

        reward = reward * IDexGoStorage(storageContract).getKmLeavesForId(shoesTokenId) / IDexGoStorage(storageContract).getPriceInitialForType(IDexGoStorage(storageContract).getTypeForId(shoesTokenId));
        reward = reward * 10000 / completedResultInPercents;
        /*
я даю им время на то чтобы получить вознаграждение равномерно:
чтобы попасть в список на который делится вознаграждение:
- дата последней выплаты по добавленным кроссовкам должна быть меньше 2х дней
ИЛИ
- дата добавления кроссовок меньше 2х дней
ИЛИ
- первый кто проходит маршрут

*/
        return reward;
    }

    uint256 balanceOfShoes;
    mapping(uint256 => address) public shoesOwners;
    event AddShoes(uint256 indexed tokenId);
    function addShoes(uint256 tokenId) public nonReentrant {
        require(!IDexGoStorage(storageContract).getInAppPurchaseBlackListWallet(msg.sender) && !IDexGoStorage(storageContract).getInAppPurchaseBlackListTokenId(tokenId), "wallet or tokenId blacklisted");
        require(IDexGoStorage(storageContract).getTypeForId(tokenId) < 10, "DexGo: wrong type");
        IDexGoNFT(IDexGoStorage(storageContract).getNftContract()).approveMainContract(address(this), tokenId);
        IERC721(IDexGoStorage(storageContract).getNftContract()).safeTransferFrom(msg.sender, address(this), tokenId);
        shoesOwners[tokenId] = msg.sender;
        balanceOfShoes++;
        emit AddShoes(tokenId);
    }
    event ReturnShoes(uint256 indexed tokenId);
    function returnShoes(uint256 tokenId) public nonReentrant {
        require(!IDexGoStorage(storageContract).getInAppPurchaseBlackListWallet(msg.sender) && !IDexGoStorage(storageContract).getInAppPurchaseBlackListTokenId(tokenId), "wallet or tokenId blacklisted");
        require(IDexGoStorage(storageContract).getTypeForId(tokenId) < 10, "DexGo: wrong type");
        require(msg.sender == shoesOwners[tokenId], "DexGo: wrong owner");

        IERC721(IDexGoStorage(storageContract).getNftContract()).safeTransferFrom(address(this), msg.sender, tokenId);
        delete shoesOwners[tokenId];
        balanceOfShoes--;
        emit ReturnShoes(tokenId);
    }

    /**
       * Always returns `IERC721Receiver.onERC721Received.selector`.
      */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;
    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

    function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }

    bool public withdrawSuperAdminAllowed = true;
    function setWithdrawSuperAdminAllowed() public onlyOwner {
        if (withdrawSuperAdminAllowed) withdrawSuperAdminAllowed = false;
    }
    function _withdrawSuperAdmin(address token,address nftContract, uint256 amount, uint256 tokenId) public onlyOwner nonReentrant returns (bool) {
        require(withdrawSuperAdminAllowed == true, "not allowed");
        if (amount > 0) {
            if (token == address(0)) {
                Address.sendValue(payable(msg.sender), amount);
                return true;
            } else {
                IERC20(token).transfer(msg.sender, amount);
                return true;
            }
        } else {
            IERC721(nftContract).safeTransferFrom(address(this), msg.sender , tokenId);
        }
        return false;
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        // custom function code
    }


}

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
interface IDexGoStorage {
    function getDexGo() external view returns (address);
    function getNftContract() external view returns (address);
    function getGameServer() external view returns (address);
    function getPriceForType(uint8 typeNft) external view returns (uint256);
    function setPriceForType(uint256 price, uint8 typeNft) external;
    function increaseCounterForType(uint8 typeNft) external;
    function setTypeForId(uint256 tokenId, uint8 typeNft)  external;
    function getPriceInitialForType(uint8 typeNft) external view returns (uint256);
    function getLatestPurchaseTime(address wallet) external view returns (uint256);
    function setLatestPurchaseTime(address wallet, uint timestamp) external;
    function valueInMainCoin(uint8 typeNft) external view returns (uint256);
    function getValueDecrease() external view returns(uint);
    function setInAppPurchaseData(string memory _inAppPurchaseInfo, uint tokenId) external;
    function getLatestPrice() external view returns (uint256, uint8);
    function getInAppPurchaseBlackListWallet(address wallet) external view returns(bool);
    function getInAppPurchaseBlackListTokenId(uint256 tokenId) external view returns(bool);
    function getImageForTypeMaxKm(uint8 typeNft) external view returns (string memory);
    function getDescriptionForType(uint8 typeNft) external view returns (string memory);
    function getNameForType(uint8 typeNft) external view returns (string memory);
    function getAccountTeam1() external view returns (address);
    function getAccountTeam2() external view returns (address);
    function getRentAndKm() external view returns (address);
    function getImageForType25PercentKm(uint8 typeNft) external view returns (string memory);
    function getImageForType50PercentKm(uint8 typeNft) external view returns (string memory);
    function getImageForType75PercentKm(uint8 typeNft) external view returns (string memory);
    function getTypeForId(uint256 tokenId) external view returns (uint8);
    function getIpfsRoot() external view returns (string memory);
    function getNamesChangedForNFT(uint _tokenId) external view returns (string memory);
    function tokenURI(uint256 tokenId)
    external
    view returns (string memory);
    function getHandshakeLevels() external view returns (address);
    function getPastContracts() external view returns (address [] memory);
    function getFixedAmountOwner() external view returns (uint256);
    function getFixedAmountProject() external view returns (uint256);
    function getMinRentalTimeInSeconds() external view returns (uint);
    function setKmForId(uint256 tokenId, uint256 km) external;
    function getKmLeavesForId(uint256 tokenId) external view returns (uint256);
    function getFixedRepairAmountProject() external view returns (uint256);
    function setRepairFinishTime(uint tokenId, uint timestamp) external;
    function getRepairCount(uint tokenId) external view returns (uint);
    function setRepairCount(uint tokenId, uint count) external;
    function getFixedApprovalAmount() external view returns (uint256);
    function getFixedPathApprovalAmount() external view returns (uint256);
    function setKmForPath(uint256 _tokenId, uint km) external;
    function getKmForPath(uint _tokenId) external view returns (uint);
    function getUSDT() external view returns (address);
}

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
interface IDexGoRentAndKm {
  //  function getKmLeavesForId(uint256 tokenId) external view returns (uint256);
//    function setKmForId(uint256 tokenId, uint256 km) external;
    function rentParameters(uint _tokenId) external view returns (bool, uint, address);
}

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
interface IDexGoNFT {
//    function getTypeForId(uint256 tokenId) external view returns (uint8);
//    function getKmLeavesForId(uint256 tokenId) external view returns (uint256);
//    function getPriceForType(uint8 typeNft) external view returns (uint256);
//    function getGameServer() external returns (address);
//    function getApprovedPathOrMovie(uint tokenId) external view returns (bool);
//    function getInAppPurchaseBlackListWallet(address wallet) external view returns(bool);
//    function getInAppPurchaseBlackListTokenId(uint tokenId) external view returns(bool);
    function isApprovedOrOwner(address sender, uint256 tokenId) external view returns(bool);
    function distributeMoney(address sender, uint value) external;
    function getTokenIdCounterCurrent() external view returns (uint);
//    function getPriceInitialForType(uint8 typeNft) external view returns (uint256);
//    function setLatestPurchaseTime(address wallet, uint timestamp) external;
    function approveMainContract(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
//    function ownerOf(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   https://aa.usno.navy.mil/faq/JD_formula.html
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}