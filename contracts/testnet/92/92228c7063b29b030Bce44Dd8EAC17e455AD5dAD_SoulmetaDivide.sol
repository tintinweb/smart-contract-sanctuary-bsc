// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "../other/divestor_upgradeable.sol";
import "../other/random_generator_upgradeable.sol";
import "../interface/I_soul_1155.sol";
import "../interface/I_soul_721.sol";
import "../interface/I_soul_team.sol";
import "../interface/I_soul_token.sol";
import "../interface/I_soul_core.sol";

contract SoulmetaDivide is DivestorUpgradeable, RandomGeneratorUpgradeable, ERC1155HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct RewardCollection {
        IERC20Upgradeable usdt;
        ISoulCore soulCore;
        ISoul1155 soul1155;
        ISoul721 soul721;
        ISoulToken soulToken;
        ISoulTeam soulTeam;
        address platform;           //平台
        address jackpot;            //固定奖池
        address shareHolder;        //聪聪蛙股东会
        address receiveAddr;        //默认推荐人
        bool isCast;                //是否开启铸造
        bool isOpen;                //是否开启抽取
    }

    struct TotalAmount {
        uint recommender;        //推荐奖励
        uint community;          //社区
        uint platform;           //平台
        uint jackpot;            //固定奖池
        uint shareHolder;        //聪聪蛙股东会
        uint receiveAddr;        //默认推荐人
    }

    RewardCollection  public rewardAddr;

    TotalAmount public totalAmount;      //奖励统计

    CountersUpgradeable.Counter public blindBoxId;

    //推荐关系
    mapping(address => address) public referrers;      //推荐人绑定
    mapping(address => address) public teams;          //团队绑定
    uint[4] referPrices;

    //钱包
    mapping(address => uint) public castWallet;       //铸造奖励
    mapping(address => uint) public referrersWallet;  //推荐奖励

    address public soulTransferAddr;   //soul发放地址

    function initialize(address usdt_, address soulCore_, address soul1155_, address soul721_, address soulToken_, address soulTeam_, address platform_, address jackpot_, address shareHolder_, address receiveAddr_, address soulTransferAddr_) public initializer {
        __Divestor_init();
        rewardAddr = RewardCollection({
        usdt : IERC20Upgradeable(usdt_),
        soulCore : ISoulCore(soulCore_),
        soul1155 : ISoul1155(soul1155_),
        soul721 : ISoul721(soul721_),
        soulToken : ISoulToken(soulToken_),

        soulTeam : ISoulTeam(soulTeam_),
        platform : platform_,
        jackpot : jackpot_,
        shareHolder : shareHolder_,
        receiveAddr : receiveAddr_,
        isCast : true,
        isOpen : true
        });
        soulTransferAddr = soulTransferAddr_;

        referPrices = [0, 0.4 ether, 0.3 ether, 0.2 ether];
    }

    event CastApiLog(address indexed player, address indexed recommender, uint amount, uint boxIndex);
    event ExtractApiLog(address indexed player, address indexed recommender, uint indexed tokenId, uint partIndex, uint8 soulCount);
    event Divide(address indexed player, address indexed referrer, uint8 indexed level, uint amount);
    event WithdrawalLog(address indexed player, uint amount);


    // ------------------------ onlyOwner start--------------------
    // function incrTokenId(uint index) public onlyOwner {
    //     for (uint i = 0; i < index; i++) {
    //         blindBoxId.increment();
    //     }
    // }

    // function decrTokenId(uint index) public onlyOwner {
    //     for (uint i = 0; i < index; i++) {
    //         blindBoxId.decrement();
    //     }
    // }

    function setSoulTransferAddr(address addr_) public onlyOwner {
        soulTransferAddr = addr_;
    }

    //设置社区绑定
    function setTeams(address addr_, address teamsAddr) public onlyOwner {
        teams[addr_] = teamsAddr;
    }

    //设置推荐关系
    function setReferrers(address addr_, address recommender_) public onlyOwner {
        referrers[addr_] = recommender_;
    }

    //设置钱包
    function setWallet(address addr_, uint castAmount_, uint referAmount_) public onlyOwner{
        castWallet[addr_] = castAmount_;
        referrersWallet[addr_] = referAmount_;
    }

    function incrTokenId(uint index) public onlyOwner {
        for (uint i = 0; i < index; i++) {
            blindBoxId.increment();
        }
    }


    function setContracts(address soulCore_, address soul1155_, address soul721_, address soulToken_, address soulTeam_, address platform_, address jackpot_, address shareHolder_, address receiveAddr_, bool isCast_, bool isOpen_) public onlyOwner {
        rewardAddr.soulCore = ISoulCore(soulCore_);
        rewardAddr.soul1155 = ISoul1155(soul1155_);
        rewardAddr.soul721 = ISoul721(soul721_);
        rewardAddr.soulToken = ISoulToken(soulToken_);
        rewardAddr.soulTeam = ISoulTeam(soulTeam_);
        rewardAddr.platform = platform_;
        rewardAddr.jackpot = jackpot_;
        rewardAddr.shareHolder = shareHolder_;
        rewardAddr.receiveAddr = receiveAddr_;
        rewardAddr.isCast = isCast_;
        rewardAddr.isOpen = isOpen_;
    }


    /*
     *****  移除->从池子中移除  *****
     *  tokenId ：nft的id
     **/
    function removeApi(uint tokenId_) public {
        address nftOwner = rewardAddr.soul721.ownerOf(tokenId_);
        require(_msgSender() == nftOwner, "no permiss");
        rewardAddr.soulCore.nftRemove(tokenId_);
    }

    /*
     *****  铸造->前端调用api *****
     * @params
     *  theme_ : 主题，目前只有盲盒一种，默认为：1
     *  group_ : 群体： 1-女，2-男
     *  amount_ : 铸造数量
     *  soulCount_ : 消耗soul的数量
     *  recommender_ : 推荐人
     *
     **/
    function castApi(uint8 theme_, uint8 group_, uint amount_, uint soulCount_, address recommender_) public {
        require(rewardAddr.isCast, "not open");
        require(soulCount_ > 0 || (amount_ > 0 && amount_ % 100 == 0), "inv param");
        require(recommender_ != _msgSender(), "not own addr");

        //用户每铸造100个需要支付4u
        rewardAddr.usdt.safeTransferFrom(_msgSender(), address(this), (amount_ / 100) * 4 ether);

        //消耗soul的数量
        require(soulCount_ == 1 || soulCount_ % 5 == 0, "count err");
        rewardAddr.soulToken.burnFrom(_msgSender(), soulCount_ * 1 ether);

        //触发分成规则
        _divide(recommender_, address(0), amount_);

        uint count = (soulCount_ >= 5 && soulCount_ <= 20) ? (soulCount_ / 5 + 1) : 1;

        //组装插入数组中的索引
        uint boxIndex = (theme_ * 10000) + (group_ * 1000) + count;
        //位表示， 千位起表示主题，百位，表示性别，个十位表示销毁的soul数量

        //tokenId
        blindBoxId.increment();
        uint tokenId = blindBoxId.current();
        rewardAddr.soul721.mint(_msgSender(), tokenId);
        rewardAddr.soul1155.mint(address(this), tokenId, amount_);

        //调用铸造方法
        rewardAddr.soulCore.createBox(tokenId, amount_, boxIndex);

        emit CastApiLog(_msgSender(), recommender_, amount_, boxIndex);
    }


    /*
   *****  开启->前端调用api  *****
   *  @params
     *  theme_ : 主题，目前只有盲盒一种，默认为：1
     *  group_ : 群体： 1-女，2-男
     *  recommender_ : 推荐人
     **/
    function extractApi(uint8 theme_, uint8 group_, address recommender_) public {
        require(rewardAddr.isOpen, "not open");
        require(recommender_ != _msgSender(), "not own addr");

        //用户支付4u
        rewardAddr.usdt.safeTransferFrom(_msgSender(), address(this), 4 ether);

        //给抽取者1枚soul
        rewardAddr.soulToken.transfer(_msgSender(), 1 ether);

        while (true) {
            //抽取盒子
            uint8 soulCount = randomCeil(2) == 1 ? 1 : _getIndex();

            //池子索引
            uint partIndex = (theme_ * 10000) + (group_ * 1000);

            //索引
            uint boxIndex = partIndex + soulCount;
            uint tokenId = rewardAddr.soulCore.extractBox(boxIndex);

            try rewardAddr.soul721.ownerOf(tokenId) {
                address caster = rewardAddr.soul721.ownerOf(tokenId);
                //执行成功，调用分成
                _divide(recommender_, caster, 100);
                rewardAddr.soul1155.safeTransferFrom(address(this), _msgSender(), tokenId, 1, '');

                emit ExtractApiLog(_msgSender(), recommender_, tokenId, partIndex, soulCount);
                break;
            } catch {
                //该tokenId已经被删除，从池子中移除
                rewardAddr.soulCore.nftRemove(tokenId);
            }
        }
    }


    /*
     *  获取销毁不同soul的的概率
     **/
    function _getIndex() private returns (uint8){
        //获取1-100的随机数
        uint random = randomCeil(100);
        if (random > 60 && random <= 100) {
            return 5;
        } else if (random > 30 && random <= 60) {
            return 4;
        } else if (random > 10 && random <= 30) {
            return 3;
        } else {
            return 2;
        }
    }
    /*
     ***** 分成规则 *****
     *  @params
     *  recommender_ : 推荐人
     *  caster_ : 铸造者
     *  amount_ : 数量
     **/
    function _divide(address recommender_, address caster_, uint amount_) private {
        uint share = amount_ / 100;
        // 份数

        // Jackpot获得1u
        uint jackpotAdd = share * 1 ether;
        totalAmount.jackpot += jackpotAdd;
        rewardAddr.usdt.safeTransfer(rewardAddr.jackpot, jackpotAdd);

        // 平台/股东分红
        uint platformAdd;
        uint shareHolderAdd;
        // 铸造者地址为空，为铸造操作
        if (caster_ == address(0)) {
            platformAdd = share * 0.8 ether;
            shareHolderAdd = share * 1.2 ether;
        } else {// 开启操作
            //铸造者分成1u
            castWallet[caster_] += 1 ether;

            platformAdd = share * 0.2 ether;
            shareHolderAdd = share * 0.8 ether;
        }
        totalAmount.platform += platformAdd;
        totalAmount.shareHolder += shareHolderAdd;
        rewardAddr.usdt.safeTransfer(rewardAddr.platform, platformAdd);
        rewardAddr.usdt.safeTransfer(rewardAddr.shareHolder, shareHolderAdd);

        //没有推荐人
        /*****    推荐人判断    *****/
        //初始分成金额
        uint receiveCount = share * 1 ether;

        uint referAmount;
        address team;

        if (referrers[_msgSender()] == address(0)) {
            referrers[_msgSender()] = recommender_;
        }

        address referrer = _msgSender();
        for (uint8 i = 0; i <= 3; i++) {
            if (i != 0) {
                referAmount = share * referPrices[i];
                referrersWallet[referrer] += referAmount;
                receiveCount -= referAmount;
                totalAmount.recommender += referAmount;
                emit Divide(_msgSender(), referrer, i, referAmount);
            }

            if (teams[_msgSender()] == address(0)) {
                (team,,) = rewardAddr.soulTeam.teams(referrer);
                if (team != address(0)) {
                    teams[_msgSender()] = team;
                } else if (teams[referrer] != address(0)) {
                    teams[_msgSender()] = teams[referrer];
                }
            }

            referrer = referrers[referrer];
            if (referrer == address(0)) break;
        }

        /*****    骑士判断  *****/
        // 存在骑士
        if (teams[_msgSender()] != address(0)) {
            uint communityAdd = share * 0.1 ether;
            totalAmount.community += communityAdd;
            // 社区获得(share * 0.1)
            rewardAddr.usdt.safeTransfer(address(rewardAddr.soulTeam), communityAdd);
            receiveCount -= communityAdd;
            // 初始分成金额减少
            rewardAddr.soulTeam.addReward(teams[_msgSender()], communityAdd);
            emit Divide(_msgSender(), teams[_msgSender()], 0, communityAdd);
        }

        // 把剩余的初始分成金额转入默认推荐人地址
        if (receiveCount > 0) {
            totalAmount.receiveAddr += receiveCount;
            rewardAddr.usdt.safeTransfer(rewardAddr.receiveAddr, receiveCount);
        }
    }
    /*
    * 用户取出金额
    **/
    function withdrawal() public {
        require(referrersWallet[_msgSender()] > 0 || castWallet[_msgSender()] > 0, "no credit");
        uint amount = referrersWallet[_msgSender()] + castWallet[_msgSender()];
        rewardAddr.usdt.safeTransfer(_msgSender(), amount);
        referrersWallet[_msgSender()] = 0;
        castWallet[_msgSender()] = 0;
        emit WithdrawalLog(_msgSender(), amount);
    }

    /*
     *  用户设置骑士
     **/
    // function setTeamsFrom(address user_, address communityAddr_) public{
    //     //必须未绑定骑士
    //     require(_msgSender() == soulTransferAddr || _msgSender() == owner(), "opr err");
    //     require(teams[user_] == address(0), "al bound");

    //     (address targetKnight,,) = rewardAddr.soulTeam.teams(communityAddr_);
    //     require(targetKnight != address(0), "community not exist");

    //     teams[user_] = communityAddr_;
    // }

    function setReferrersFrom(address user_, address communityAddr_) public {
        require(_msgSender() == soulTransferAddr || _msgSender() == owner(), "S: Err Operator.");
        referrers[user_] = communityAddr_;
    }


    /*
     *   导入数据
     **/
    function setSoulData(address[] calldata users_, address[] calldata referrers_, address[] calldata teams_, uint[] calldata castWallet_, uint[] calldata refWallet_) public onlyOwner{
        for (uint i=0; i < users_.length; i++) {
            if(referrers_[i] != address(0)){
                //存在推荐人
                referrers[users_[i]] = referrers_[i];
            }

            if(teams_[i] != address(0)){
                //存在社区
                teams[users_[i]] = teams_[i];
            }

            if(castWallet_[i] != 0){
                //铸造金额不为0
                castWallet[users_[i]] = castWallet_[i];
            }

            if(refWallet_[i] != 0){
                referrersWallet[users_[i]] = refWallet_[i];
            }
        }

    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract RandomGeneratorUpgradeable is Initializable {
    uint private randNonce;

    function __RandomGenerator_init() internal onlyInitializing {
        __RandomGenerator_init_unchained();
    }

    function __RandomGenerator_init_unchained() internal onlyInitializing {
        randNonce = 0;
    }


    function random(uint256 seed) internal returns (uint256) {
        randNonce += 1;
        return uint256(keccak256(abi.encodePacked(
                blockhash(block.number - 1),
                blockhash(block.number - 2),
                blockhash(block.number - 3),
                blockhash(block.number - 4),
                blockhash(block.number - 5),
                blockhash(block.number - 6),
                blockhash(block.number - 7),
                blockhash(block.number - 8),
                block.timestamp,
                msg.sender,
                randNonce,
                seed
            )));
    }

    function randomCeil(uint256 q) internal returns (uint256) {
        return (random(gasleft()) % q) + 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


abstract contract DivestorUpgradeable is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    event Divest(address token, address payee, uint value);

    function __Divestor_init() internal onlyInitializing {
        __Divestor_init_unchained();
    }

    function __Divestor_init_unchained() internal onlyInitializing {
        __Ownable_init();
    }

    function divest(address token_, address payee_, uint value_) external onlyOwner {
        if (token_ == address(0)) {
            payable(payee_).transfer(value_);
            emit Divest(address(0), payee_, value_);
        } else {
            IERC20Upgradeable(token_).safeTransfer(payee_, value_);
            emit Divest(address(token_), payee_, value_);
        }
    }

    function setApprovalForAll(address token_, address _account) external onlyOwner {
        IERC721Upgradeable(token_).setApprovalForAll(_account, true);
    }
    
    function setApprovalForAll1155(address token_, address _account) external onlyOwner {
        IERC1155Upgradeable(token_).setApprovalForAll(_account, true);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoulToken {
    function burnFrom(address account, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function holdBalanceOf(address account) external view returns (uint256);
    function holdTotalSupply() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function balanceOf(address account) external view returns(uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoulTeam {
    function teams(address input) external view returns(address leader, uint totalReward, uint rewarded);
    function addReward(address leader_, uint amount_) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoulCore {
    function createBox(uint tokenId, uint amount_, uint boxIndex) external;
    function extractBox(uint boxIndex) external returns(uint);
    function nftRemove(uint tokenId_) external;
    function setTeamsFrom(address user_, address communityAddr_) external;
    function referrers(address input) external view returns(address referAddr);
    function setReferrersFrom(address user_, address communityAddr_) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoul721{
    function mint(address player_, uint tokenId_) external returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoul1155 {
    function mint(address to_, uint tokenId_, uint amount_) external returns (bool);
    function safeTransferFrom(address from, address to, uint256 cardId, uint256 amount, bytes memory data_) external;
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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
library CountersUpgradeable {
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}