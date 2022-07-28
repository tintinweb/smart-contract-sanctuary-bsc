// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interface/I_soul_token.sol";
import "../other/divestor_upgradeable.sol";

interface IWorldCupConsumer {
    function setRequestConfirmations(uint16 requestConfirmations_) external;
    function rollDice(string memory roller_) external returns (uint requestId);
    function getRandom(string memory roller_) external view returns (uint[] memory);
}

contract WorldCup is DivestorUpgradeable {
    // using SafeERC20Upgradeable for IERC20Upgradeable;
    using StringsUpgradeable for uint;

    ISoulToken soulToken;                // soul token 合约地址
    IWorldCupConsumer random;               // 随机数消费者合约

    address public randomAddr;                  // 随机数消费在合约地址
    uint public startTime;                      // 开始时间
    uint public endTime;                        // 结束时间
    uint public competitionType;                // 比赛类型
    uint public matchId;                        // 比赛索引
    uint public championIndex;                  // 冠军池周期索引
    uint public walletAmount;                   // 无赢家可取出代币数量

    struct ChampionInfo {
        uint startTime;
        uint endTime;
        // bool status;
        uint competitionType;
        uint matchId;
        uint championIndex;
    }

    struct Match {
        string roller;               // 比赛骰子id
        uint team1;                  // 队伍1
        uint team2;                  // 队伍2
        uint startTim;               // 开始时间
        uint endTim;                 // 结束时间
    }

    // 即时奖金玩家
    struct Instant {
        address player;
        uint initAmount;
        uint amount;
        uint leverageAmount;
        uint team;
        uint matchId;
    }

    struct Champion {
        uint ssoulAmount;
        uint championIndex;
    }

    // 即时奖金池
    struct InstantPool {
        uint total;
        uint team1Amount;
        uint team2Amount;
        uint ssoulAmount;
    }

    // 冠军池总量 - 积分
    struct ChampionPool {
        uint soulAmount;               // soul 总量
        uint ssoulAmount;              // ssoul 积分
    }

    // 玩家收益信息
    struct PlayerEarningInfo {
        uint leverage;                 // 杠杆
        uint instantEarnings;          // 即时收益
        uint principal;                // 参与的本金
        uint principaled;              // 已领回参与的本金
        uint instantEarningsed;        // 已领即时收益
        uint ssoulAmount;              // ssoul 积分
        uint destroySsoul;             // 需销毁的 ssoul
        uint championEarnings;         // 冠军收益
        uint championEarningsed;       // 已领取冠军收益
    }
    // 销毁
    struct BurnTotal {
        uint soulAmount;
        uint ssoulAmount;
    }

    // 场次id => 场次数据
    mapping(uint => Match) public mapMatch;   // 比赛场次
    // 场次id => 即时奖金玩家数据
    //    mapping(uint => mapping(address => Instant)) public mapInstant; // 即时奖金
    // 场次id => 即时奖金总量
    mapping(uint => InstantPool) public mapInstantTotal; // 即时奖金总池
    // 周期id => 当天冠军奖金总量
    mapping(uint => ChampionPool) public mapChampionTotal; // 冠军奖金 soul 总量
    // 周期id => 当天销毁soul ssoul 数量 
    mapping(uint => BurnTotal) public mapBurnTotal; // 销毁总量
    // 玩家信息
    mapping(address => PlayerEarningInfo) public mapPlayerInfo;
    // 玩家参与场次数据
    mapping(address => Instant[]) public mapPlayerRecord;
    // 玩家参与过的冠军赛 id
    mapping(address => Champion[]) public mapPlayerChampion;

    address public banker;

    event Open(string indexed roller, uint indexed competitionType, uint indexed matchId);

    function initialize(address soul_, address randomConsumer_) public initializer {
        __Divestor_init();
        soulToken = ISoulToken(soul_);
        randomAddr = randomConsumer_;
        random = IWorldCupConsumer(randomConsumer_);
    }

    function setMeta(uint start_, uint end_, uint16 delay_) public onlyOwner {
        startTime = start_;
        endTime = end_;
        random.setRequestConfirmations(delay_);
    }

    // 测试需
    // function setMatchId(uint championId_, uint matchId_) public onlyOwner {
    //     championIndex = championId_;
    //     matchId = matchId_;
    // }

    function setContract(address banker_, address consumer_) public onlyOwner {
        random = IWorldCupConsumer(consumer_);
        banker = banker_;
    }

    function getWallet() public onlyOwner {
        soulToken.transfer(_msgSender(), walletAmount);
        walletAmount = 0;
    }

    // 开启一场比赛
    function openCompetition(uint team1_, uint team2_) public {
        require(_msgSender() == banker || _msgSender() == owner(), "Opr Err");

        uint nowTimestamp = block.timestamp % 1 days;

        require(block.timestamp > startTime && block.timestamp < endTime && nowTimestamp > (startTime % 1 days), "openCompetition: Not_at_game_time");

        // 生产需
        uint[] memory randomNums;
        if (matchId % 127 >= 1) {
            // 判断当前是否有比赛
            randomNums = random.getRandom(mapMatch[matchId].roller);
            // 判断上一场是否无赢家
            if (randomNums[0] > randomNums[1] && mapInstantTotal[matchId].team1Amount == 0) {
                walletAmount += mapInstantTotal[matchId].team2Amount;
            } else if (randomNums[0] < randomNums[1] && mapInstantTotal[matchId].team2Amount == 0) {
                walletAmount += mapInstantTotal[matchId].team1Amount;
            }
        }

        // 开启一场
        matchId += 1;
        // 开启一天比赛周期
        if (matchId % 127 == 1) {
            championIndex += 1;
        }
        // 开启比赛随机数
        string memory roller = string(abi.encodePacked(team1_.toString(), "_vs_", team2_.toString(), "_", block.timestamp.toString()));
        random.rollDice(roller);

        // 该场比赛
        mapMatch[matchId] = Match({
        roller : roller,
        team1 : team1_,
        team2 : team2_,
        startTim : block.timestamp,
        endTim : block.timestamp + 5 minutes
        });

        // 比赛周期 - 127 场比赛
        if (matchId % 127 <= 64 && matchId % 127 != 0) {
            // 128 进 64 强
            competitionType = 128;
        } else if (matchId % 127 > 64 && matchId % 127 <= 96) {
            // 64 进 32 强
            competitionType = 64;
        } else if (matchId % 127 > 96 && matchId % 127 <= 112) {
            // 32 进 16 强
            competitionType = 32;
        } else if (matchId % 127 > 112 && matchId % 127 <= 120) {
            // 16 进 8 强
            competitionType = 16;
        } else if (matchId % 127 > 120 && matchId % 127 <= 124) {
            // 8 进 4 强
            competitionType = 8;
        } else if (matchId % 127 > 124 && matchId % 127 <= 126) {
            // 半决赛
            competitionType = 4;
        } else if (matchId % 127 == 0) {
            // 决赛
            competitionType = 2;
        }

        emit Open(roller, competitionType, matchId);
    }

    /* @param
     * {uint} 投注 soul 数量
     * {uint} 投注 1 队 || 2 队
     */
    // 投注
    function betting(uint amount_, uint team_) public {
        address player = _msgSender();
        // 查询用户soul
        require(amount_ != 0, "betting: Soul_insufficient_balance");
        require(block.timestamp < mapMatch[matchId].endTim - 30 seconds, "betting: END");
        require(team_ == 1 || team_ == 2, "betting: No_team");
        require(getParticipate(player), "betting: Attended");

        // 玩家参与过 结算之前收益
        _setProceeds(player);

        uint leverageNow = mapPlayerInfo[player].leverage == 0 ? 1 : mapPlayerInfo[player].leverage;

        // 转账 - 销毁
        uint burn = amount_ * 5 / 100;
        uint betNums = amount_ * 90 / 100;
        soulToken.burnFrom(player, burn);
        mapBurnTotal[championIndex].soulAmount += burn;
        // 合约池
        soulToken.transferFrom(player, address(this), burn);

        soulToken.transferFrom(player, address(this), betNums);
        // 该场比赛 杠杆 * 数量
        uint leverageAmount = leverageNow * amount_;

        // 当天参加的冠军池积分
        mapChampionTotal[championIndex].ssoulAmount += amount_ * 1000;
        mapInstantTotal[matchId].ssoulAmount += amount_ * 1000;

        // 是否参与本周期冠军积分
        // 当天积分
        uint championlen = mapPlayerChampion[player].length;
        if (championlen != 0 && mapPlayerChampion[player][championlen - 1].championIndex <= championIndex) {
            mapPlayerChampion[player][championlen - 1].ssoulAmount += amount_ * 1000;
        } else {
            mapPlayerChampion[player].push(Champion({
            ssoulAmount : amount_ * 1000,
            championIndex : championIndex
            }));
        }

        // 1 soul - 1000 ssoul
        mapPlayerInfo[player].ssoulAmount += amount_ * 1000;

        uint[7] memory rates = [uint(90), 90, 53, 63, 73, 83, 88];

        uint rate = 0;
        while (rate <= 6) {
            if (competitionType == 2 ** (7 - rate)) break;
            rate++;
        }
        rate = rates[rate];

        if (team_ == 1) {
            mapInstantTotal[matchId].team1Amount += leverageAmount * rate / 100;
        } else {
            mapInstantTotal[matchId].team2Amount += leverageAmount * rate / 100;
        }
        mapPlayerRecord[player].push(Instant({
        player : player,
        initAmount : amount_,
        amount : amount_ * rate / 100,
        leverageAmount : leverageAmount * rate / 100,
        team : team_,
        matchId : matchId
        }));

        // 总量
        mapInstantTotal[matchId].total += amount_ * rate / 100;
        mapChampionTotal[championIndex].soulAmount += amount_ * (90 - rate) / 100;

    }

    // 结算收益
    function _setProceeds(address player) private {
        if (mapPlayerRecord[player].length != 0) {
            uint index = mapPlayerRecord[player][0].matchId;

            uint winner;
            uint[] memory randomNums = random.getRandom(mapMatch[index].roller);
            if (randomNums[0] > randomNums[1]) {
                winner = 1;
            } else {
                winner = 2;
            }

            // 收益
            uint totalBonus;
            // 参赛记录
            if (winner == mapPlayerRecord[player][0].team) {
                // 赢
                uint oldChampion = mapPlayerRecord[player][0].matchId / 127;
                if (oldChampion < (championIndex - 1) && oldChampion != 0) {
                    // 首次投注新周期 重置杠杆
                    mapPlayerInfo[player].leverage = 0;
                } else {
                    mapPlayerInfo[player].leverage += 1;
                }
                // (投注数量 / 赢者池子) * 池子总数量 
                if (winner == 1) {
                    totalBonus = mapPlayerRecord[player][0].leverageAmount * 1 gwei / mapInstantTotal[index].team1Amount * mapInstantTotal[index].total / 1 gwei;
                } else {
                    totalBonus = mapPlayerRecord[player][0].leverageAmount * 1 gwei / mapInstantTotal[index].team2Amount * mapInstantTotal[index].total / 1 gwei;
                }
                // 记录本金
                // mapPlayerInfo[player].principal += mapPlayerRecord[player][0].amount;
                // 记录可领收益
                mapPlayerInfo[player].instantEarnings += totalBonus;
            } else {
                mapPlayerInfo[player].leverage = 0;
                // 输
                // mapPlayerInfo[player].ssoulAmount += mapPlayerRecord[player][0].initAmount * 1000;

            }

            // 删除已结算记录
            mapPlayerRecord[player].pop();
        }

        // uint nowTimestamp = block.timestamp % 1 days;
        // 计算收益 - 冠军赛
        if (matchId == 0) return;
        uint nowChampion = (matchId - 1) / 127 + 1;
        uint len = mapPlayerChampion[player].length;
        for (uint i = 0; i < len;) {
            if (nowChampion > mapPlayerChampion[player][i].championIndex) {
                // 冠军收益 = 当天 ssoul 积分 / 当天冠军池 ssoul 总量 * 当天冠军池 soul 总量
                mapPlayerInfo[player].championEarnings += mapPlayerChampion[player][i].ssoulAmount * 1 gwei / mapChampionTotal[mapPlayerChampion[player][i].championIndex].ssoulAmount * mapChampionTotal[mapPlayerChampion[player][i].championIndex].soulAmount / 1 gwei;
                mapPlayerInfo[player].destroySsoul += mapPlayerChampion[player][i].ssoulAmount;
                // 当天收益结算
                mapPlayerInfo[player].ssoulAmount -= mapPlayerChampion[player][i].ssoulAmount;
                mapPlayerChampion[player][i] = mapPlayerChampion[player][len - 1];
                mapPlayerChampion[player].pop();
                len = mapPlayerChampion[player].length;
            } else {
                i += 1;
            }
        }

    }

    // 领取即时收益
    function getInstantEarnings() public {
        address player = _msgSender();
        // uint nowTimestamp = block.timestamp % 1 days;

        // 结算上一场收益
        _setProceeds(player);

        uint earnings = mapPlayerInfo[player].instantEarnings;
        uint championEarnings = mapPlayerInfo[player].championEarnings;
        // uint principal = mapPlayerInfo[player].principal;

        require(earnings != 0 || championEarnings != 0, "getInstantEarnings: No_bonus");

        // 本金
        // soulToken.transfer(player, principal);
        // 收益
        soulToken.transfer(player, earnings);

        // 已领收益
        mapPlayerInfo[player].instantEarningsed += earnings;
        // mapPlayerInfo[player].principaled += principal;
        mapPlayerInfo[player].instantEarnings = 0;
        // mapPlayerInfo[player].principal = 0;
        if (mapPlayerInfo[player].championEarnings != 0) {
            // 领取冠军收益   
            getChampionEarnings();
        }
    }

    // 领取冠军池收益
    function getChampionEarnings() private {
        // uint nowTimestamp = block.timestamp % 1 days;

        // require(nowTimestamp > (endTime % 1 days), "getChampionEarnings: Collection_has_not_started");

        address player = _msgSender();

        uint earnings = mapPlayerInfo[player].championEarnings;
        uint ssoul = mapPlayerInfo[player].destroySsoul;

        require(earnings != 0, "getChampionEarnings: No_bonus");
        // 销毁凭证
        mapBurnTotal[championIndex].ssoulAmount += ssoul;

        soulToken.transfer(player, earnings);

        // 已领收益
        mapPlayerInfo[player].championEarningsed += earnings;
        mapPlayerInfo[player].championEarnings = 0;

    }

    // 获取是否可以参加该场
    function getParticipate(address player_) public view returns (bool) {
        return mapPlayerRecord[player_].length == 0 || mapPlayerRecord[player_][0].matchId != matchId;
    }

    function getMapPlayerChampion(address player_) public view returns (Champion[] memory) {
        return mapPlayerChampion[player_];
    }

    function getMapPlayerRecord(address player_) public view returns (Instant[] memory) {
        return mapPlayerRecord[player_];
    }

    // 获取销毁总量
    // function getBurnTotal() public view returns (BurnTotal memory) {
    //     BurnTotal memory total;
    //     for (uint i = 1; i <= championIndex; i++) {
    //         total.soulAmount += mapBurnTotal[i].soulAmount;
    //         total.ssoulAmount += mapBurnTotal[i].ssoulAmount;
    //     }
    //     return total;
    // }

    // 获取随机数 某一场比赛
    // function getRandom(uint index_) public view returns(uint[] memory) {
    //     uint[] memory randomNums = random.getRandom(mapMatch[index_].roller);
    //     return randomNums;
    // }

    // 获取比赛信息
    // function getChampionInfo() public view returns(ChampionInfo memory) {
    //     ChampionInfo memory championInfo;
    //     championInfo.startTime = startTime;
    //     championInfo.endTime = endTime;
    //     championInfo.competitionType = competitionType;
    //     championInfo.matchId = matchId;
    //     championInfo.championIndex = championIndex;
    //     return championInfo;
    // }

    // function getEarningsData(address player) public view returns(PlayerEarningInfo memory) {
    //     // 收益
    //     PlayerEarningInfo memory earningInfo;
    //     earningInfo.leverage = mapPlayerInfo[player].leverage;
    //     earningInfo.ssoulAmount = mapPlayerInfo[player].ssoulAmount;
    //     earningInfo.instantEarnings = mapPlayerInfo[player].instantEarnings;
    //     earningInfo.championEarnings = mapPlayerInfo[player].championEarnings;
    //     uint len = mapPlayerChampion[player].length;
    //     if (mapPlayerRecord[player].length != 0) {

    //         uint index = mapPlayerRecord[player][0].matchId;

    //         uint[] memory randomNums = random.getRandom(mapMatch[index].roller);
    //         uint winner;
    //         if (randomNums[0] > randomNums[1]) {
    //             winner = 1;
    //         } else {
    //             winner = 2;
    //         }

    //         uint totalBonus;
    //         // 参赛记录
    //         if (winner == mapPlayerRecord[player][0].team) {
    //             // 赢
    //             uint oldChampion = (mapPlayerRecord[player][0].matchId - mapPlayerRecord[player][0].matchId % 127) * 1 gwei / 127;
    //             if (oldChampion < (championIndex - 1) * 1 gwei && oldChampion != 0) {
    //                 // 首次投注新周期 重置杠杆
    //                 earningInfo.leverage = 0;
    //             } else {
    //                 earningInfo.leverage += 1;
    //             }
    //             // (投注数量 / 赢者池子) * 池子总数量 
    //             if (winner == 1) {
    //                 totalBonus = mapPlayerRecord[player][0].leverageAmount * 1 gwei / mapInstantTotal[index].team1Amount * mapInstantTotal[index].total / 1 gwei;
    //             } else {
    //                 totalBonus = mapPlayerRecord[player][0].leverageAmount * 1 gwei / mapInstantTotal[index].team2Amount * mapInstantTotal[index].total / 1 gwei;
    //             } 
    //             // 可领收益
    //             earningInfo.instantEarnings += totalBonus;
    //         } else {
    //             earningInfo.leverage = 0;
    //             earningInfo.ssoulAmount += mapPlayerRecord[player][0].initAmount * 1000;
    //         }

    //     } 
    //     // uint nowTimestamp = block.timestamp % 1 days;
    //     // 计算收益 - 冠军赛
    //     uint nowChampion = matchId * 1 gwei / 127;
    //     for (uint i = 0; i < len; i++) {
    //         if (nowChampion > mapPlayerChampion[player][i].championIndex * 1 gwei) {
    //             // 冠军收益 = 当天 ssoul 积分 / 当天冠军池 ssoul 总量 * 当天冠军池 soul 总量
    //             earningInfo.championEarnings += earningInfo.ssoulAmount * 1 gwei / mapChampionTotal[mapPlayerChampion[player][i].championIndex].ssoulAmount * mapChampionTotal[mapPlayerChampion[player][i].championIndex].soulAmount / 1 gwei;
    //         }
    //     }

    //     earningInfo.instantEarnings += earningInfo.championEarnings;
    //     earningInfo.instantEarningsed = mapPlayerInfo[player].instantEarningsed + mapPlayerInfo[player].championEarningsed;

    //     return earningInfo;

    // }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ISoulToken is IERC20Metadata {
    function burn(uint256 amount) external returns (bool);
    function burnFrom(address account, uint256 amount) external returns (bool);
    function holdBalanceOf(address account) external view returns (uint256);
    function holdTotalSupply() external view returns (uint256);
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

    function setApprovalForAll20(address token_, address spender_) external onlyOwner {
        IERC20Upgradeable(token_).approve(spender_, type(uint).max);
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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