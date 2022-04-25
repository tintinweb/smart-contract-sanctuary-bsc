// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "../other/divestor_upgradeable.sol";
import "../other/random_generator_upgradeable.sol";
import "../interface/I_soul_1155.sol";
import "../interface/I_soul_721.sol";
import "../interface/I_soul_token.sol";
import "../interface/I_soul_team.sol";

contract SoulCore is DivestorUpgradeable, RandomGeneratorUpgradeable, ERC1155HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Meta {
        IERC20Upgradeable USDT;
        ISoul1155 SOUL_1155;
        ISoul721 SOUL_721;
        ISoulToken SOUL_TOKEN;
        ISoulTeam SOUL_TEAM;
        address Platform;
        address Jackpot;
        address ShareHolder;
        address ReceiveAddr;
        bool isCast;
        bool isOpen;
    }

    Meta public meta;

    struct TotalAmount{
        uint Recommender;
        uint Community;
        uint Platform;
        uint Jackpot;
        uint ShareHolder;
        uint ReceiveAddr;
    }

    TotalAmount public totalAmount;


    mapping(address => address) public referrers;     //绑定推荐人
    mapping(address => address) public teams;     //绑定Team


    mapping(address => uint) public wallet;           //钱包

    function initialize(address USDT_, address SOUL_1155_, address SOUL_721_, address SOUL_TOKEN_, address SOUL_TEAM_, address platform_, address jackpot_, address shareHolder_, address receiveAddr_) public initializer {
        __Divestor_init();
        meta = Meta({
        USDT : IERC20Upgradeable(USDT_),
        SOUL_1155 : ISoul1155(SOUL_1155_),
        SOUL_721 : ISoul721(SOUL_721_),
        SOUL_TOKEN : ISoulToken(SOUL_TOKEN_),
        SOUL_TEAM : ISoulTeam(SOUL_TEAM_),
        Platform : platform_,
        Jackpot : jackpot_,
        ShareHolder : shareHolder_,
        ReceiveAddr : receiveAddr_,
        isCast: true,
        isOpen:true
        });
    }

    //男女盲盒池
    struct nftStruct {
        uint tokenId;
        uint count;
    }

    CountersUpgradeable.Counter public _tokenId;


    uint public totalBlindBox;


    //概率 => 对应tokenId跟数量
    mapping(uint8 => nftStruct[]) public publicPool;   //1-女，2-男
    mapping(uint8 => nftStruct[]) public gentleman;    //男：soulCount做key
    mapping(uint8 => nftStruct[]) public lady;         //女

    event CreateBlindBox(address indexed player, address indexed recommender, uint indexed tokenId, uint8 gender, uint8 soulCount, uint amount);
    event OpenBlindBox(address indexed player, address indexed recommender, uint indexed tokenId, uint8 gender, uint8 soulCount);

    // ------------------------ onlyOwner start--------------------
   //设置社区绑定
    function setTeams(address addr_, address teamsAddr) public onlyOwner {
        teams[addr_] = teamsAddr;
    }


    function setReferrers(address addr_, address recommender_) public onlyOwner {
        referrers[addr_] = recommender_;
    }

    function incrTokenId(uint index) public onlyOwner {
        for (uint i = 0; i < index; i++) {
            _tokenId.increment();
        }
    }

    function decrTokenId(uint index) public onlyOwner {
        for (uint i = 0; i < index; i++) {
            _tokenId.decrement();
        }
    }

    function setContracts(address SOUL_1155, address SOUL_721, address SOUL_TOKEN, address Platform, address Jackpot, address ShareHolder, address ReceiveAddr, bool isCast, bool isOpen) public onlyOwner {
        meta.SOUL_1155 = ISoul1155(SOUL_1155);
        meta.SOUL_721 = ISoul721(SOUL_721);
        meta.SOUL_TOKEN = ISoulToken(SOUL_TOKEN);
        meta.Platform = Platform;
        meta.Jackpot = Jackpot;
        meta.ShareHolder = ShareHolder;
        meta.ReceiveAddr = ReceiveAddr;
        meta.isCast = isCast;
        meta.isOpen = isOpen;
    }

    function setContractsNew(address USDT_, address SOUL_1155, address SOUL_721, address SOUL_TOKEN, address SOUL_TEAM_, address Platform, address Jackpot, address ShareHolder, address ReceiveAddr, bool isCast, bool isOpen) public onlyOwner {
        meta.USDT = IERC20Upgradeable(USDT_);
        meta.SOUL_1155 = ISoul1155(SOUL_1155);
        meta.SOUL_721 = ISoul721(SOUL_721);
        meta.SOUL_TOKEN = ISoulToken(SOUL_TOKEN);
        meta.SOUL_TEAM = ISoulTeam(SOUL_TEAM_);
        meta.Platform = Platform;
        meta.Jackpot = Jackpot;
        meta.ShareHolder = ShareHolder;
        meta.ReceiveAddr = ReceiveAddr;
        meta.isCast = isCast;
        meta.isOpen = isOpen;
    }
    // ---------------------onlyOwner end--------------------

    //铸造盲盒
    function createToken(uint8 gender, uint amount, uint8 soulCount, address recommender) public returns (uint){
        require(meta.isCast, "Not open");

        require(gender == 1 || gender == 2, "Invalid gender");
        //数量， 为100的倍数
        require(amount > 0 && amount % 100 == 0, "Valid quantity must be filled in");

        //推荐人不能是自己
        require(recommender != _msgSender(), "Can not be your own recommender");

        //往当前合约地址付款4U
        meta.USDT.safeTransferFrom(_msgSender(), address(this), (amount / 100) * 4 ether);
        //当前合约获得金额


        //分成规则
        _divide(recommender, address(0), amount);

        _tokenId.increment();
        uint tokenId = _tokenId.current();
        meta.SOUL_721.mint(_msgSender(), tokenId);
        meta.SOUL_1155.mint(address(this), tokenId, amount);


        //消耗soul的数量
        if (soulCount > 0) {
            require(soulCount == 1 || soulCount % 5 == 0, "soulCount err");
            //销毁soul
            meta.SOUL_TOKEN.burnFrom(_msgSender(), uint(soulCount) * 1 ether);
        }


        //插入的数据
        nftStruct memory insert = nftStruct(tokenId, amount);
        if (soulCount != 0) {
            if (gender == 1) {
                //女
                lady[soulCount].push(insert);
            } else {
                gentleman[soulCount].push(insert);
            }
        } else {
            publicPool[gender].push(insert);
        }
        emit CreateBlindBox(_msgSender(), recommender, tokenId, gender, soulCount, amount);

        totalBlindBox += amount;

        return tokenId;
    }


    //抽取
    function extractToken(uint8 gender, address recommender) public returns (uint){
        require(meta.isOpen, "Not open");
        require(gender == 1 || gender == 2, "Invalid gender");
        //推荐人不能是自己
        require(recommender != _msgSender(), "Can not be your own recommender");

        //往当前合约地址付款4U
        meta.USDT.safeTransferFrom(_msgSender(), address(this), 4 ether);
        //当前合约获得金额

        //给抽取者1枚soul========================================
        meta.SOUL_TOKEN.transfer(_msgSender(), 1 ether);

        uint tokenId;

        //随机二选一抽取一个池子
        uint row = randomCeil(2);
        if (row == 1) {
            //免费池
            tokenId = _getFree(gender, recommender, false);
        } else {
            //氪金池
            tokenId = _getCharge(gender, recommender, false);
        }
        require(tokenId != 0, "Unable to extract");

        address caster = meta.SOUL_721.ownerOf(tokenId);
        //需要通过tokenId获取铸造者，用于分成。
        _divide(recommender, caster, 100);


        meta.SOUL_1155.safeTransferFrom(address(this), _msgSender(), tokenId, 1, '');

        totalBlindBox--;

        return tokenId;
    }


    //免费池子的抽取
    /* @param
     * gender_（性别）： 1-女，2-男
     * isJump_（是否跳转，用于判断其他池子跳转过来）： 0-否，1-是
     **/
    function _getFree(uint8 gender_, address recommender_, bool isJump_) private returns (uint){
        uint tokenId;
        uint length = publicPool[gender_].length;
        //免费池的长度
        if (length == 0) {
            if (!isJump_) {
                //跳转到收费池
                tokenId = _getCharge(gender_, recommender_, true);
            }
            return tokenId;
        }

        //免费池存在数据
        uint tokenIndex = randomCeil(length) - 1;
        tokenId = publicPool[gender_][tokenIndex].tokenId;

        //池子数量维护
        _countMaintain(false, gender_, 0, tokenIndex, length);
        //tokenId数量维护

        emit OpenBlindBox(_msgSender(), recommender_, tokenId, gender_, 0);
        return tokenId;
    }



    //氪金池子的抽取
    function _getCharge(uint8 gender_, address recommender_, bool isJump_) private returns (uint){
        uint tokenId;
        uint8 proIndex = _getIndex();
        //获取概率索引
        if (gender_ == 1) {
            //女
            uint length = lady[proIndex].length;
            if (length > 0) {
                //氪金池有数据
                uint tokenIndex = randomCeil(length) - 1;
                //随机从池子中抽取一个tokenId索引
                //获取tokenId
                tokenId = lady[proIndex][tokenIndex].tokenId;

                _countMaintain(true, gender_, proIndex, tokenIndex, length);
                //tokenId数量维护

                emit OpenBlindBox(_msgSender(), recommender_, tokenId, gender_, proIndex);

                return tokenId;
            } else {
                //无数据
                if (!isJump_) {
                    //是，跳转到免费池子
                    tokenId = _getFree(gender_, recommender_, true);
                }
            }
        } else if (gender_ == 2) {
            //男
            uint length = gentleman[proIndex].length;
            if (length > 0) {
                //存在数据
                uint tokenIndex = randomCeil(length) - 1;
                //随机从池子中抽取一个tokenId索引
                tokenId = gentleman[proIndex][tokenIndex].tokenId;

                _countMaintain(true, gender_, proIndex, tokenIndex, length);
                //tokenId数量维护

                emit OpenBlindBox(_msgSender(), recommender_, tokenId, gender_, proIndex);

                return tokenId;
            } else {
                //无数据
                if (!isJump_) {
                    //否，跳转到免费池子
                    tokenId = _getFree(gender_, recommender_, true);
                }
            }

        }

        return tokenId;
    }



    //获取氪金池的key
    function _getIndex() private returns (uint8){
        uint8 index = 1;
        //获取1-100的随机数
        uint random = randomCeil(100);
        if (random > 10 && random <= 30) {
            index = 5;
        } else if (random > 30 && random <= 60) {
            index = 10;
        } else if (random > 60 && random <= 100) {
            index = 20;
        }
        return index;
    }

    mapping(address => uint) public referrersWallet;  //推荐奖金
    /*
     *  status：是否氪金
     *  gender：1-女，2-男
     *  soulCount：氪金的key，同时也是销毁的soul数量
     *  tokenIndex：抽中的数组下标
     *  length：数组长度
     **/
    function _countMaintain(bool status, uint8 gender_, uint8 soulCount, uint tokenIndex_, uint length_) private {
        if (status) {
            //氪金池
            if (gender_ == 1) {
                //女
                lady[soulCount][tokenIndex_].count -= 1;
                if (lady[soulCount][tokenIndex_].count == 0) {
                    //该tokenId全被抽完
                    if (tokenIndex_ != (length_ - 1) && length_ > 1) {
                        lady[soulCount][tokenIndex_].tokenId = lady[soulCount][length_ - 1].tokenId;
                        lady[soulCount][tokenIndex_].count = lady[soulCount][length_ - 1].count;
                    }
                    //移除最后一个tokenId
                    lady[soulCount].pop();
                }
            } else {
                //男
                gentleman[soulCount][tokenIndex_].count -= 1;
                if (gentleman[soulCount][tokenIndex_].count == 0) {
                    if (tokenIndex_ != (length_ - 1) && length_ > 1) {
                        gentleman[soulCount][tokenIndex_].tokenId = gentleman[soulCount][length_ - 1].tokenId;
                        gentleman[soulCount][tokenIndex_].count = gentleman[soulCount][length_ - 1].count;
                    }
                    gentleman[soulCount].pop();
                }
            }
        } else {
            //免费池
            publicPool[gender_][tokenIndex_].count -= 1;
            if (publicPool[gender_][tokenIndex_].count == 0) {
                if (tokenIndex_ != (length_ - 1) && length_ > 1) {
                    publicPool[gender_][tokenIndex_].tokenId = publicPool[gender_][length_ - 1].tokenId;
                    publicPool[gender_][tokenIndex_].count = publicPool[gender_][length_ - 1].count;
                }
                publicPool[gender_].pop();
            }

        }

    }


    /*
     *  recommender : 推荐人
     *  caster : 铸造者
     *  platform : 平台
     *  jackpot : 奖池
     *  shareholder : 股东会
     *  receiveAddr : 默认领取地址
     *  amount : 铸造的数量
    **/
    function _divide(address recommender_, address caster_, uint amount_) private {
        uint share = amount_ / 100;

        //直接给固定奖池转账 ==> soul奖池
        meta.USDT.safeTransfer(meta.Jackpot, share * 1 ether);
        totalAmount.Jackpot += (share * 1 ether);


        //通过铸造者地址区分铸造或者开启
        if (caster_ == address(0)) {
            //铸造者地址为空，为铸造操作
            meta.USDT.safeTransfer(meta.Platform, share * 0.8 ether);
            totalAmount.Platform += (share * 0.8 ether);
            //平台 0.8
            meta.USDT.safeTransfer(meta.ShareHolder, share * 1.2 ether);
            totalAmount.ShareHolder += (share * 1.2 ether);
            //股东会  1.2
        } else {
            //开启，有铸造者地址
            wallet[caster_] += 1 ether;
            //铸造者获得1u
            meta.USDT.safeTransfer(meta.Platform, share * 0.2 ether);
            totalAmount.Platform += (share * 0.2 ether);
            //平台 0.8
            meta.USDT.safeTransfer(meta.ShareHolder, share * 0.8 ether);
            totalAmount.ShareHolder += (share * 0.8 ether);
            //股东会  1.2
        }

        if (recommender_ == address(0)) {
            recommender_ = meta.ReceiveAddr;
        }

        //设定初始分成金额
        uint receiveCount = share * 1 ether;
        //不能用浮点型计算


        //一级推荐人
        address recommender_sec;
        //二级推荐人
        address recommender_ter;


        //判断当前用户是否有推荐关系
        if (referrers[_msgSender()] != address(0)) {
            //之前就存在推荐人，推荐人获得0.4
            referrersWallet[referrers[_msgSender()]] += (share * 0.4 ether);
            //初始分成金额减少  0.4*100
            receiveCount -= (share * 0.4 ether);

            totalAmount.Recommender += (share * 0.4 ether);
            //设定二级推荐人
            recommender_sec = referrers[_msgSender()];
        } else {
            //新推荐
            if (recommender_ != meta.ReceiveAddr) {
                //存在推荐人，推荐人获得0.4
                referrersWallet[recommender_] += (share * 0.4 ether);
                //初始分成金额减少 0.4*100
                receiveCount -= (share * 0.4 ether);

                totalAmount.Recommender += (share * 0.4 ether);
                //设定二级推荐人
                recommender_sec = recommender_;

                //添加推荐关系
                referrers[_msgSender()] = recommender_;
            }
        }

        //二级推荐判断
        if (recommender_sec != address(0) && referrers[recommender_sec] != address(0)) {
            //存在二级推荐人
            referrersWallet[referrers[recommender_sec]] += (share * 0.3 ether);

            //初始分成金额减少 0.3*100
            receiveCount -= (share * 0.3 ether);

            totalAmount.Recommender += (share * 0.3 ether);
            recommender_ter = referrers[recommender_sec];
        }


        //三级推荐人判断
        if (recommender_ter != address(0) && referrers[recommender_ter] != address(0)) {
            //存在三级推荐人，三级推荐人获得0.2
            referrersWallet[referrers[recommender_ter]] += (share * 0.2 ether);

            totalAmount.Recommender += (share * 0.2 ether);
            //初始分成金额减少 0.2*100
            receiveCount -= (share * 0.2 ether);
        }


        //查询用户是否绑定骑士
        address team;

        (address self_leader,,) = meta.SOUL_TEAM.teams(_msgSender());
        if(self_leader != address(0)){
            team = self_leader;
        } else if (teams[_msgSender()] != address(0)) {
            team = teams[_msgSender()];
        } else if (teams[recommender_sec] != address(0)) {
            team = teams[recommender_sec];
        } else if (teams[recommender_ter] != address(0)) {
            team = teams[recommender_ter];
        } else if (teams[referrers[recommender_ter]] != address(0)) {
            team = teams[referrers[recommender_ter]];
        } else {
            (address leader,,) = meta.SOUL_TEAM.teams(recommender_);
            if (leader != address(0)) {
                team = leader;
            }
        }

        if (teams[_msgSender()] == address(0)) {
            teams[_msgSender()] = team;
        }

        if (team != address(0)) {
            //社区获得金额
            totalAmount.Community += (share * 0.1 ether);
            meta.USDT.safeTransfer(address(meta.SOUL_TEAM), share * 0.1 ether);
            meta.SOUL_TEAM.addReward(team, share * 0.1 ether);
            //初始分成金额减少
            receiveCount -= (share * 0.1 ether);
        }


        //初始分成金额是否还有剩余
        if (receiveCount > 0) {
            //将剩余的金额往默认推荐人地址转
            totalAmount.ReceiveAddr += receiveCount;
            meta.USDT.safeTransfer(meta.ReceiveAddr, receiveCount);
        }
    }


    //从钱包中取出金额
    function withdrawal() public {
        require(wallet[_msgSender()] > 0 || referrersWallet[_msgSender()] > 0, "Sorry, your credit is running low");
        uint amount = wallet[_msgSender()] + referrersWallet[_msgSender()];
        meta.USDT.safeTransfer(_msgSender(), amount);
        wallet[_msgSender()] = 0;
        referrersWallet[_msgSender()] = 0;
    }

    function viewPool(uint8 gender_, uint8 soulCount_) public view returns (nftStruct[] memory){
        if(soulCount_ == 0){
            //免费池子
            return publicPool[gender_];
        }else{
            if(gender_ == 1){
                return lady[soulCount_];
            }else if(gender_ == 2){
                return gentleman[soulCount_];
            }
            return publicPool[0];
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
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ISoulTeam {
    function teams(address input) external view returns(address leader, uint totalReward, uint rewarded);
    function addReward(address leader_, uint amount_) external;
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