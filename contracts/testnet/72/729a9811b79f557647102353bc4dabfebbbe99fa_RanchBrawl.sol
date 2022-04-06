pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../ReentrancyGuard.sol";
import "../IRandomGenerator.sol";
import "./IDoge.sol";
import "./IMilk.sol";

/**
  1、狼羊先组队，参考alleginance，  --完毕
  2、狼+羊+农民 组成可开始的pack，pack给标签start挖矿，或者存的时候开始弄，用户3次approve，我这一次transferFrom，记录starttime --继续中
  3、购买milk，砍头费收？？，开始挖矿了
  4、挖矿参考barn，
  5、攻击参考 alleginance，双重结果概率，暂时不要预言机，攻击时按当前bal计算结果
  6、攻击cd + 挖矿到期时间 二者去最大值，定义结束时间
  7、解散team或收取milk，这块参考barn，后续就可以全部弄好了,要求可以简单调整，减少转移数量
  8、得把rescue 搬过来
 */
contract RanchBrawl is Ownable, IERC721Receiver, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    // Represents the currents state of each pack, one per Land
    // 数据结果，冷却时间，挖矿时间，
    struct TeamPack {
        uint256 landid;
        bool enable;
        address owner;
        uint96 maxAdventure; // 最大旅程记录  max duration
        uint256[] dogeids;
        uint256[] sheepids;
        uint256[] farmerids;
    }

    struct Capacity {
        uint256 landid; // 换个格式
        uint80 startat;
        uint80 exceptEndat; // 默认结束
        uint80 trackedEndat;
        uint80 lastAttack; // 上次攻击时间
        uint96 alphaScore;
        uint8 chance; //  抢夺次数 att actions
        uint256 dailyYield; // 当日产量
        uint256 totalmint; // 产量
        uint256 grabbed; // 抢来的
        uint256 robbed; // 被抢走
    }

    mapping(uint256 => TeamPack) public packs;
    mapping(uint256 => Capacity) public caps;

    // sheep earn 400 $Milk per day
    uint256 public constant DAILY_MILK_RATE = 400 ether;
    uint256 public constant MAXIMUM_PACK = 20;
    uint256 public EXTRA_ATTACK_COST = 1000 ether;
    uint256 public DEFAULT_ATTACK_CHANCE = 3;
    uint256 public DEFAULT_CONSUMPTION_PERDAY = 100 ether;
    uint8 public constant MAX_ALPHA = 8;
    // uint80 public COOL_DOWN = 4 hours; // update tracked edn time when do attack
    uint80 public COOL_DOWN = 10 minutes;
    uint80 public GUARANTEE = 3000; // guarantee grabed+minted

    // there will only ever be (roughly) 2 billion $Milk earned through staking
    uint256 public constant MAXIMUM_GLOBAL_MILK = 2000000000 ether;
    address public burnaddress;

    IERC721 land;
    IDoge doge;
    IERC721 farmer;
    IERC20 public milk;
    IRandomGenerator random;

    event TeamBuilded(address belongto, uint256 indexed landid);
    event TeamDissolved(address belongto, uint256 indexed landid);
    event StartJourney(address indexed owner, uint256 landid, uint80 startAt);
    event EndJourney(
        address indexed owner,
        uint256 landid,
        uint80 startAt,
        uint80 endAt,
        uint256 mintAward,
        uint256 grabbedAward,
        uint256 robbedLost
    );
    event SuccessAttack(
        address indexed attacker,
        uint256 attackerLand,
        address indexed target,
        uint256 targetLand,
        uint80 time,
        uint256 award
    );
    event FaildAttack(
        address indexed attacker,
        uint256 attackerLand,
        address indexed target,
        uint256 targetLand,
        uint80 time
    );

    constructor(
        IERC721 _land,
        IDoge _doge,
        IERC721 _farmer,
        IERC20 _milk,
        IRandomGenerator _random
    ) {
        land = _land;
        doge = _doge;
        farmer = _farmer;
        milk = _milk;
        random = _random;
    }

    // 组队，也可以开始去冒险
    function buildTeam(
        uint256 landid,
        uint256[] calldata _addDogesIds,
        uint256[] calldata _addFarmerids,
        uint8 attackChance,
        uint8 journey,
        bool start
    ) public whenNotPaused {
        TeamPack storage team = packs[landid];
        // team build
        if (team.owner == address(0)) {
            land.safeTransferFrom(msg.sender, address(this), landid, "");
            team.owner = msg.sender;
            emit TeamBuilded(msg.sender, landid);
        }
        if (_addDogesIds.length > 0) {
            for (uint256 i = 0; i < _addDogesIds.length; i++) {
                doge.safeTransferFrom(
                    _msgSender(),
                    address(this),
                    _addDogesIds[i],
                    ""
                ); // add doges
                if (isSheep(_addDogesIds[i])) {
                    team.sheepids.push(_addDogesIds[i]);
                } else {
                    team.dogeids.push(_addDogesIds[i]);
                }
            }
        }
        if (_addFarmerids.length > 0) {
            for (uint256 i = 0; i < _addFarmerids.length; i++) {
                farmer.safeTransferFrom(
                    _msgSender(),
                    address(this),
                    _addFarmerids[i],
                    ""
                ); // add farmer
                team.farmerids.push(_addFarmerids[i]);
            }
        }
        if (start) {
            startJounery(landid, journey, attackChance);
        }
    }

    // notice 不接收指定id移除，只能指定位置移除，待续排列
    function removeMember(
        uint256 landid,
        uint256[] calldata _removeDogeIndexes,
        uint256[] calldata _removeSheepIndexes,
        uint256[] calldata _removeFarmerIndexes,
        uint8 attackChance,
        uint8 journey,
        bool start
    ) public whenNotPaused {
        TeamPack storage team = packs[landid];
        require(team.owner == _msgSender(), "manage your own team");
        // TODO 有问题
        if (_removeDogeIndexes.length > 0) {
            for (uint256 i = 0; i < _removeDogeIndexes.length; i++) {
                uint256 dogeback = team.dogeids[_removeDogeIndexes[i]];
                team.dogeids[_removeDogeIndexes[i]] = team.dogeids[
                    team.dogeids.length - 1
                ];
                team.dogeids.pop();
                doge.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    dogeback,
                    ""
                ); // remove doges
            }
        }
        if (_removeSheepIndexes.length > 0) {
            for (uint256 i = 0; i < _removeSheepIndexes.length; i++) {
                uint256 sheepback = team.sheepids[_removeSheepIndexes[i]];
                team.sheepids[_removeSheepIndexes[i]] = team.sheepids[
                    team.sheepids.length - 1
                ];
                team.sheepids.pop();
                doge.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    sheepback,
                    ""
                ); // remove sheeps
            }
        }
        if (_removeFarmerIndexes.length > 0) {
            for (uint256 i = 0; i < _removeFarmerIndexes.length; i++) {
                uint256 farmerback = team.farmerids[_removeFarmerIndexes[i]];
                team.farmerids[_removeFarmerIndexes[i]] = team.farmerids[
                    team.farmerids.length - 1
                ];
                team.farmerids.pop();
                farmer.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    farmerback,
                    ""
                ); // remove farmer
            }
        }
        if (start) {
            startJounery(landid, journey, attackChance);
        }
    }

    // 遣散队伍，只能不在冒险的时候
    function dissolveTeam(uint256 landid) public {
        TeamPack storage team = packs[landid];
        require(team.owner != address(0), "not a staked land");
        require(team.enable == false, "waiting for return to home");
        require(team.owner == msg.sender, "not owner");
        if (team.dogeids.length > 0) {
            for (uint256 n = team.dogeids.length; n < 1; n--) {
                doge.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    team.dogeids[n-1],
                    ""
                );
            }

            // for (uint256 n = 0; n < team.dogeids.length; n++) {
            //     doge.safeTransferFrom(
            //         address(this),
            //         _msgSender(),
            //         team.dogeids[n],
            //         ""
            //     ); // return nfts
            // }
        }
        if (team.sheepids.length > 0) {
            for (uint256 m = team.sheepids.length; m < 1; m--) {
                doge.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    team.sheepids[m-1],
                    ""
                );
            }
        }
        if (team.farmerids.length > 0) {
            for (uint256 p = team.farmerids.length; p < 1; p--) {
                doge.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    team.farmerids[p-1],
                    ""
                );
            }
        }
        // clear struct
        // TeamPack memory emptyPack;
        // Capacity memory emptyCap;
        // packs[landid] = emptyPack;
        // caps[landid] = emptyCap;
        delete packs[landid];
        delete caps[landid];
        land.safeTransferFrom(address(this), _msgSender(), landid, "");
        emit TeamDissolved(msg.sender, landid);
    }

    // go on a hunting jounery
    // Ranch Expansion  改名
    function startJounery(
        uint256 landid,
        uint8 journey,
        uint8 attackChance
    ) public {
        TeamPack storage team = packs[landid];
        // TODO 付费+准备开启挖矿
        require(journey >= 3, "minimun 3 days");
        require(
            team.dogeids.length +
                team.sheepids.length +
                team.farmerids.length <=
                20,
            "can not afford"
        );
        uint256 attackCost;
        uint256 journeyCost;

        // cost milk by attack chance
        if (attackChance > 0) {
            attackCost += attackChance * EXTRA_ATTACK_COST;
        }
        // cost milk by long journey
        journeyCost += journey * DEFAULT_CONSUMPTION_PERDAY;
        milk.safeTransferFrom(
            _msgSender(),
            burnaddress,
            attackCost + journeyCost
        );
        (uint96 _alphaScore, uint256 _yieldScore) = getTeamScore(landid);
        // get timestamp
        uint80 nowTime = uint80(block.timestamp);
        // build capacity and start mint
        caps[landid] = Capacity({
            landid: team.landid,
            startat: nowTime,
            exceptEndat: nowTime + journey,
            trackedEndat: 0,
            lastAttack: nowTime,
            alphaScore: _alphaScore,
            chance: attackChance, //  抢夺次数
            dailyYield: _yieldScore, // 当日产量，计算的
            totalmint: 0,
            grabbed: 0, // 抢来的
            robbed: 0 // 被抢走的
        });
        team.enable = true;
    }

    function getTeamScore(uint256 landid)
        public
        view
        returns (uint96 alphaScore, uint256 yieldScore)
    {
        // 主要是计算能力
        TeamPack memory team = packs[landid];
        // 重新计算 只计算alpha值
        if (team.dogeids.length > 0) {
            for (uint256 i = 0; i < team.dogeids.length; i++) {
                uint8 alpha = _alphaForDoge(team.dogeids[i]);
                alphaScore += alpha;
            }
        }
        yieldScore = (team.sheepids.length + 1) * DAILY_MILK_RATE; // yield
    }

    // for check balance and indage balance
    function pendingMilk(uint256 landid)
        public
        view
        returns (
            uint256 mintYeild,
            uint256 nowYeild,
            uint256 indanger
        )
    {
        // 计算挖矿,可提取的,可参照原版，每次update，也可以不update直接算
        Capacity memory cap = caps[landid];
        uint80 caluator = uint80(block.timestamp);
        if (caluator >= cap.exceptEndat) {
            caluator = cap.exceptEndat;
        }
        // TODO 到milk硬顶了怎么办 目前产量= (可挖时间 - 开始时间) * 每天产量 / 天
        mintYeild = ((caluator - cap.startat) * cap.dailyYield) / 1 days;
        nowYeild = mintYeild + cap.grabbed - cap.robbed;
        // 危险的就是出去被抢夺的

        uint256 guar = ((mintYeild + cap.grabbed) * (10000 - GUARANTEE)) /
            10000;
        if (guar > cap.robbed) {
            indanger = guar - cap.robbed;
        } else {
            indanger = 0;
        }
    }

    function doAttack(uint256 attacker, uint256 target)
        external
        whenNotPaused
        nonReentrant
    {
        require(packs[target].enable, "target must on journey");
        require(packs[attacker].enable, "attacker must on journey");
        require(msg.sender == packs[target].owner, "team owner can give order");
        Capacity storage attCap = caps[attacker];
        Capacity storage tarCap = caps[target];

        require(attCap.chance > 0, "no enough chance");
        attCap.chance--;
        // withdraw milk will be affected by attack only on success
        uint80 nowTime = uint80(block.timestamp);
        (uint80 success, uint256 grabAmount) = getSuccessRate(attacker, target);
        // settle a bill
        uint256 seed = random.random(grabAmount);
        if (seed % 100 >= success) {
            // TODO end???
            emit FaildAttack(
                packs[attacker].owner,
                attacker,
                packs[target].owner,
                target,
                nowTime
            );
        } else {
            attCap.lastAttack = nowTime;

            if (attCap.trackedEndat == 0) {
                attCap.trackedEndat = nowTime + COOL_DOWN;
            } else {
                attCap.trackedEndat += COOL_DOWN;
            }

            attCap.grabbed += grabAmount;
            tarCap.robbed += grabAmount;

            emit SuccessAttack(
                packs[attacker].owner,
                attacker,
                packs[target].owner,
                target,
                nowTime,
                grabAmount
            );
        }
    }

    // Ranch Collapse, params deal
    function endJourney(uint256 landid, bool dissolve) public nonReentrant {
        TeamPack storage winnerTeam = packs[landid];
        Capacity storage winnerCap = caps[landid];

        require(winnerTeam.owner == msg.sender, "only called by team owner");
        require(winnerTeam.enable == true, "only on journey");
        uint80 end = winnerCap.trackedEndat >= winnerCap.exceptEndat + COOL_DOWN
            ? winnerCap.trackedEndat
            : winnerCap.exceptEndat + COOL_DOWN;
        require(block.timestamp >= end, "waiting for end");
        winnerTeam.enable = false;
        winnerTeam.maxAdventure = 0;

        if (winnerCap.exceptEndat >= winnerCap.trackedEndat) {
            winnerCap.trackedEndat = winnerCap.exceptEndat;
        }
        // mint token, store event
        (uint256 mintYeild, uint256 nowYeild, ) = pendingMilk(landid);
        IMilk(address(milk)).mint(winnerTeam.owner, nowYeild);
        emit EndJourney(
            msg.sender,
            landid,
            winnerCap.startat,
            winnerCap.trackedEndat,
            mintYeild,
            winnerCap.grabbed,
            winnerCap.robbed
        );
        // reset capacity
        delete caps[landid];
        // dissolve team.  reset teampack
        if (dissolve) {
            dissolveTeam(landid);
        }
    }

    // caculate win probability & max grab milk
    function getSuccessRate(uint256 attacker, uint256 target)
        public
        view
        returns (uint80 winProb, uint256 grabAmount)
    {
        (, uint256 nowYeild, uint256 indanger) = pendingMilk(target);
        Capacity memory attCap = caps[attacker];
        Capacity memory tarCap = caps[target];
        // get probability of attack successly
        winProb = uint80(attCap.alphaScore + 50);
        if (attCap.alphaScore > tarCap.alphaScore) {
            // dynamic grab amount = ((aScore - tScore) /2 +5) * nowyeild / 100
            grabAmount =
                (((attCap.alphaScore - tarCap.alphaScore) * 50 + 500) *
                    nowYeild) /
                10000;
        } else {
            // fixed amount 5%
            grabAmount = nowYeild / 20;
        }
        // guarantee is safe
        if (grabAmount >= indanger) grabAmount = indanger;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        // TODO 暂时去除，后面看看
        // require(from == address(0x0), "Cannot send tokens to Brawl directly");
        return IERC721Receiver.onERC721Received.selector;
    }

    function isSheep(uint256 tokenId) public view returns (bool) {
        IDoge.SheepDoge memory d = doge.getTokenTraits(tokenId);
        return d.isSheep;
    }

    function _alphaForDoge(uint256 tokenId) public view returns (uint8) {
        IDoge.SheepDoge memory d = doge.getTokenTraits(tokenId);
        return MAX_ALPHA - d.alphaIndex;
    }

    function checkTeam(uint256 landid)
        public
        view
        returns (
            uint256[] memory dogeids,
            uint256[] memory sheepids,
            uint256[] memory farmerids
        )
    {
        TeamPack memory team = packs[landid];
        dogeids = team.dogeids;
        sheepids = team.sheepids;
        farmerids = team.farmerids;
    }

    function withdraw(address _token, address _to) external onlyOwner {
        if (_token == address(0x0)) {
            _to.call{value: address(this).balance}(new bytes(0));
            // payable(_to).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }

    function withdrawNft(
        IERC721 _token,
        address _to,
        uint256[] calldata tokenids
    ) external onlyOwner {
        for (uint256 i = 0; i < tokenids.length; i++) {
            _token.safeTransferFrom(address(this), _to, tokenids[i]);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
interface IMilk {
    function mint(address to, uint256 amount) external;
}

interface IDoge {
    // struct to store each token's traits
    struct SheepDoge {
        bool isSheep;
        uint8 fur;
        uint8 head;
        uint8 ears;
        uint8 eyes;
        uint8 nose;
        uint8 mouth;
        uint8 neck;
        uint8 feet;
        uint8 alphaIndex;
    }

    function getTokenTraits(uint256 tokenId)
        external
        view
        returns (SheepDoge memory);

    function ownerOf(uint256 tokenId) external view returns (address);

    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (security/ReentrancyGuard.sol)

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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the IRandomGenerator.
 */

interface IRandomGenerator {
    function random(uint256 seed) external view returns (uint256);
    }