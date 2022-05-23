// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./../config/IConfig.sol";
import "./../utils/Caller.sol";
import "./../utils/TransferV1.sol";
import "./../utils/EnumerableMap.sol";
import "./../utils/EnumerableSet.sol";
import "./../utils/SafeMath.sol";
import "./../utils/Fallback.sol";

// 高级场竞赛
contract SeniorRace is Caller, Fallback {
    using SafeMath for uint256;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct RaceInfo {
        uint256 signUpStartBlock; //报名开始区块高度
        uint256 signUpEndBlock; //报名截止区块高度
        uint256 signUpCount; //报名总人数
        uint256 exitTax; //退出税率
        uint256 k; //退出税率递减率
        uint8 state; //竞赛状态 0：未开始  1:报名开始  2：竞赛开始  3：结束
        uint8 currentRound; //当前轮次
        uint256 pureEliminateBlock; //上次淘汰区块高度
        uint256 eliminateIntercalBlock; //淘汰间隔区块数量
        uint256 championTokenId; //冠军tokenid
        address championAddress; //冠军address
    }

    event SignUpEvent(
        address indexed ticket,
        address indexed owner,
        uint256 indexed tokenId
    ); //0xc3c394715a05675c359597d39298353b9f22cd5e38cf49d38a44de895722d1c5
    event ExitEvent(
        address indexed ticket,
        address indexed owner,
        uint256 indexed tokenId
    ); //0xc2a88a0b5902c26fa131fffe32fbd516a2dfb2f40e2a8d833c931fa579611d5f
    event ClearEvent(
        address indexed ticket,
        address indexed owner,
        uint256 indexed tokenId
    ); //0x0d81f835b0d947d844b9b4a5127b96a9270a1083187589d9de338673f5045577

    event ChampionAssetEvent(
        address indexed token,
        address indexed to,
        uint256 indexed amount
    ); //

    IConfig public config;
    RaceInfo public raceInfo;
    EnumerableSet.AddressSet private pizePoolTokenSet; //奖池资产类别
    mapping(address => uint256) public pizePoolAmountMap; //奖池资产数量
    EnumerableMap.UintToAddressMap private surplusTokenMap; //存活NFT记录
    mapping(address => uint8) public signUpCountMap; //单个用户已报名数量

    constructor(IConfig config_) {
        _init(config_);
    }

    function init(IConfig config_) external onlyCaller {
        _init(config_);
    }

    function _init(IConfig config_) private {
        raceInfo = RaceInfo(0, 0, 0, 1500, 100, 0, 1, 0, 0, 0, address(0));
        config = config_;
    }

    // pass
    function setExitTaxAndK(uint256 exitTax, uint256 k) external onlyCaller {
        require(2 > raceInfo.state && 10000 > exitTax && k <= exitTax, "1000");
        raceInfo.exitTax = exitTax;
        raceInfo.k = k;
    }

    // pass
    function setRaceParam(
        uint256 signUpStartBlock,
        uint256 signUpEndBlock,
        uint256 eliminateIntercalBlock
    ) external onlyCaller {
        uint256 currentNum = block.number;
        if (0 == raceInfo.state) {
            require(
                currentNum < signUpEndBlock &&
                    signUpStartBlock < signUpEndBlock,
                "1001"
            );
        } else {
            require(
                1 == raceInfo.state &&
                    signUpStartBlock < currentNum &&
                    signUpStartBlock < signUpEndBlock,
                "1002"
            );
        }
        require(0 < eliminateIntercalBlock, "1003");
        require(signUpStartBlock + 10 < signUpEndBlock, "1004");
        raceInfo.signUpStartBlock = signUpStartBlock;
        raceInfo.signUpEndBlock = signUpEndBlock;
        raceInfo.eliminateIntercalBlock = eliminateIntercalBlock;
    }

    // pass
    function setRaceParamV2() external onlyCaller {
        uint256 currentNum = block.number;
        uint256 signUpEndBlock = currentNum + 2;
        require(
            1 == raceInfo.state &&
                raceInfo.signUpStartBlock < currentNum &&
                raceInfo.signUpStartBlock < signUpEndBlock,
            "1005"
        );
        require(0 < raceInfo.eliminateIntercalBlock, "1006");
        require(raceInfo.signUpStartBlock + 10 < signUpEndBlock, "1007");
        raceInfo.signUpEndBlock = signUpEndBlock;
    }

    function injectAsset(address token, uint256 amount) external payable {
        if (0 < msg.value) {
            TransferV1.transferFrom_(
                address(0),
                msg.sender,
                address(config.getAsset()),
                msg.value
            );
            pizePoolTokenSet.addAddressSet(address(0));
            pizePoolAmountMap[address(0)] = pizePoolAmountMap[address(0)].add(
                msg.value,
                "1072"
            );
        }
        if (address(0) != token) {
            bool exist = false;
            (address[] memory tokens, uint256[] memory amounts) = config
                .getSeniorTicketFees();
            for (uint256 i = 0; i < tokens.length; i++) {
                if (token == tokens[i] && 0 < amounts[i]) {
                    exist = true;
                    break;
                }
            }
            if (!exist) {
                (tokens, amounts) = config.getSeniorTicketFeesDiscount();
                for (uint256 i = 0; i < tokens.length; i++) {
                    if (token == tokens[i] && 0 < amounts[i]) {
                        exist = true;
                        break;
                    }
                }
            }
            require(exist, "1073");
            TransferV1.transferFrom_(
                token,
                msg.sender,
                address(config.getAsset()),
                amount
            );
            pizePoolTokenSet.addAddressSet(token);
            pizePoolAmountMap[token] = pizePoolAmountMap[token].add(
                amount,
                "1074"
            );
        }
    }

    function signUp(uint256[] memory tokenIds) external {
        uint256 currentNum = block.number;
        require(
            raceInfo.signUpStartBlock < currentNum &&
                currentNum < raceInfo.signUpEndBlock,
            "1008"
        );
        require(1 == raceInfo.state, "1009");
        uint8 registed;
        uint256 tokenId;
        ISeniorTicket.MintInfo memory mintInfo;
        address burn = config.getSeniorBurnAddress();
        ISeniorTicket ticket = config.getSeniorTicket();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            //判断报名数量是否超过限制
            registed = signUpCountMap[msg.sender];
            require(50 > registed, "1066");
            signUpCountMap[msg.sender] = registed + 1;
            ticket.safeTransferFrom(msg.sender, burn, tokenId);
            require(!ticket.getUse(tokenId), "1063");
            (, mintInfo) = ticket.tryGetNFTInfo(tokenId);
            //处理奖池token和奖池费用
            pizePoolTokenSet.addAddressSet(mintInfo.token);
            pizePoolAmountMap[mintInfo.token] = pizePoolAmountMap[
                mintInfo.token
            ].add(mintInfo.prizePoolFee, "1010");
            surplusTokenMap.setUintToAddressMap(tokenId, msg.sender);
            raceInfo.signUpCount = raceInfo.signUpCount.add(1, "1011"); //报名人数+1
            emit SignUpEvent(address(ticket), msg.sender, tokenId);
        }
    }

    // pass
    function setState() external onlyCaller {
        uint256 currentNum = block.number;
        if (0 == raceInfo.state) {
            if (
                0 < raceInfo.signUpStartBlock &&
                raceInfo.signUpStartBlock < currentNum
            ) {
                raceInfo.state = 1;
            }
        } else if (1 == raceInfo.state) {
            if (raceInfo.signUpEndBlock < currentNum) {
                raceInfo.state = 2;
                raceInfo.pureEliminateBlock = currentNum;
            }
        }
    }

    // pass
    function exit(uint256 tokenId) external {
        require(2 == raceInfo.state && 1 < raceInfo.currentRound, "1012");
        require(
            msg.sender == surplusTokenMap.getUintToAddressMap(tokenId),
            "1013"
        );
        uint256 surplusCount = surplusTokenMap.lengthUintToAddressMap();
        require(1 < surplusCount, "1053");
        //删除存活记录
        surplusTokenMap.removeUintToAddressMap(tokenId);
        _returnReward(msg.sender, surplusCount);
        //产生冠军
        if (1 == surplusTokenMap.lengthUintToAddressMap()) {
            _setChampion();
        }
        emit ExitEvent(address(config.getSeniorTicket()), msg.sender, tokenId);
    }

    // pass
    function _returnReward(address to, uint256 surplusCount) private {
        address token;
        uint256 amount;
        uint256 exitAmount;
        uint256 decrease;
        IAsset asset = config.getAsset();
        //退奖金逻辑
        for (uint256 i = 0; i < pizePoolTokenSet.lengthAddressSet(); i++) {
            token = pizePoolTokenSet.atAddressSet(i);
            amount = pizePoolAmountMap[token];
            if (0 < amount) {
                exitAmount = amount.div(surplusCount, "1069");
                //计算税率
                //currentRound:3
                //decrease:1%=100
                //exitTax:10%=1000
                decrease = raceInfo.k.mul(raceInfo.currentRound, "1014");
                if (raceInfo.exitTax > decrease) {
                    decrease = decrease.add(10000, "1015").sub(
                        raceInfo.exitTax,
                        "1016"
                    );
                    exitAmount = exitAmount.mul(decrease, "1017").div(
                        10000,
                        "1018"
                    );
                }
                pizePoolAmountMap[token] = amount.sub(exitAmount, "1057");
                asset.claim(token, to, exitAmount);
            }
        }
    }

    // pass
    function _getHash(uint256 index, bytes32 blockBytes)
        private
        pure
        returns (uint8)
    {
        uint256 len = blockBytes.length;
        uint256 mod = index.mod(len, "1056");
        return uint8(blockBytes[mod]);
    }

    function clear(
        uint256 clearNumber,
        uint64 targetNumber,
        uint8 currentRound
    ) external {
        uint256 currentNum = block.number;
        require(
            2 == raceInfo.state &&
                raceInfo.pureEliminateBlock + raceInfo.eliminateIntercalBlock <=
                currentNum,
            "1019"
        );
        require(raceInfo.currentRound <= currentRound, "1020");
        raceInfo.currentRound = currentRound;
        raceInfo.pureEliminateBlock = currentNum;
        uint256 timestamp = block.timestamp;
        uint256 clearNum;
        address owner;
        uint256 tokenId;
        address ticket = address(config.getSeniorTicket());
        uint256 count = surplusTokenMap.lengthUintToAddressMap();
        bytes32 blockBytes = blockhash(currentNum - 1);
        while (0 < clearNumber && targetNumber < count) {
            timestamp = timestamp.add(
                uint256(_getHash(clearNumber, blockBytes)),
                "1021"
            );
            clearNumber = clearNumber.sub(1, "1022");
            clearNum = timestamp.mod(count, "1065");
            (tokenId, owner) = surplusTokenMap.atUintToAddressMap(clearNum);
            surplusTokenMap.removeUintToAddressMap(tokenId);
            emit ClearEvent(ticket, owner, tokenId);
            count = surplusTokenMap.lengthUintToAddressMap();
            if (1 == count) {
                _setChampion(); //设置冠军
                break;
            }
        }
    }

    // pass
    function _setChampion() private {
        require(1 == surplusTokenMap.lengthUintToAddressMap(), "1023");
        (raceInfo.championTokenId, raceInfo.championAddress) = surplusTokenMap
            .atUintToAddressMap(0);
        surplusTokenMap.removeUintToAddressMap(raceInfo.championTokenId);
        raceInfo.state = 3;
        ISeniorTicket ticket = config.getSeniorTicket();
        ticket.setUse(raceInfo.championTokenId);
        ticket.safeTransferFrom(
            config.getSeniorBurnAddress(),
            raceInfo.championAddress,
            raceInfo.championTokenId
        );
        //奖金转移到冠军地址
        address token;
        uint256 amount;
        IAsset asset = config.getAsset();
        for (uint256 i = 0; i < pizePoolTokenSet.lengthAddressSet(); i++) {
            token = pizePoolTokenSet.atAddressSet(i);
            amount = pizePoolAmountMap[token];
            pizePoolAmountMap[token] = 0;
            asset.claim(token, raceInfo.championAddress, amount);
            emit ChampionAssetEvent(token, raceInfo.championAddress, amount);
        }
    }

    // 请求奖金池资产类别及数量
    function getPizePool()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 length = pizePoolTokenSet.lengthAddressSet();
        address[] memory token = new address[](length);
        uint256[] memory amount = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            token[i] = pizePoolTokenSet.atAddressSet(i);
            amount[i] = pizePoolAmountMap[token[i]];
        }
        return (token, amount);
    }

    //请求存活人数
    function getSurplusTokenCount() external view returns (uint256) {
        return surplusTokenMap.lengthUintToAddressMap();
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

pragma solidity 0.8.1;

import "./../asset/IAsset.sol";
import "./../invite/IInvite.sol";
import "./../list/IList.sol";
import "./../ticket/INormalTicket.sol";
import "./../ticket/ISeniorTicket.sol";

interface IConfig {
    function getNormalTicketFee(address token) external view returns (uint256);

    function getNormalTicketFees()
        external
        view
        returns (address[] memory, uint256[] memory);

    function getNormalTicketFeeDiscount(address token)
        external
        view
        returns (uint256);

    function getNormalTicketFeesDiscount()
        external
        view
        returns (address[] memory, uint256[] memory);

    function getNormalManagerFeeRate() external view returns (uint256);

    function getNormalSuperPrizeFeeRate() external view returns (uint256);

    function getNormalManagerFeeAddress() external view returns (address);

    function getNormalSuperPrizeFeeAddress() external view returns (address);

    function getNormalBurnAddress() external view returns (address);

    function getSeniorTicketFee(address token) external view returns (uint256);

    function getSeniorTicketFees()
        external
        view
        returns (address[] memory, uint256[] memory);

    function getSeniorTicketFeeDiscount(address token)
        external
        view
        returns (uint256);

    function getSeniorTicketFeesDiscount()
        external
        view
        returns (address[] memory, uint256[] memory);

    function getSeniorManagerFeeRate() external view returns (uint256);

    function getSeniorSuperPrizeFeeRate() external view returns (uint256);

    function getSeniorManagerFeeAddress() external view returns (address);

    function getSeniorSuperPrizeFeeAddress() external view returns (address);

    function getSeniorBurnAddress() external view returns (address);

    function getAddressByAddress(address key) external view returns (address);

    function getUint256ByAddress(address key) external view returns (uint256);

    function getAddressByUint256(uint256 key) external view returns (address);

    function getUint256ByUint256(uint256 key) external view returns (uint256);

    function getAsset() external view returns (IAsset);

    function getInvite() external view returns (IInvite);

    function getList() external view returns (IList);

    function getNormalTicket() external view returns (INormalTicket);

    function getSeniorTicket() external view returns (ISeniorTicket);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

// 调用者
contract Caller is Ownable {
    bool private init;
    mapping(address => bool) public caller;

    modifier onlyCaller() {
        require(caller[msg.sender], "1049");
        _;
    }

    function initOwner(address owner, address caller_) external {
        require(address(0) == Ownable.owner() && !init, "2356");
        init = true;
        _transferOwnership(owner);
        caller[caller_] = true;
    }

    function setCaller(address account, bool state) external onlyOwner {
        if (state) {
            caller[account] = state;
        } else {
            delete caller[account];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// 安全转账库
library TransferV1 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function transfer_(
        address token,
        address to,
        uint256 value
    ) internal {
        if (0 < value) {
            if (address(0) == token) {
                (bool success, ) = to.call{value: value}(new bytes(0));
                require(success, "1052");
            } else {
                IERC20(token).transfer(to, value);
            }
        }
    }

    function transferFrom_(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        if (0 < value) {
            if (address(0) == token) {
                (bool success, ) = to.call{value: value}(new bytes(0));
                require(success, "1071");
            } else {
                IERC20(token).safeTransferFrom(from, to, value);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableMap.sol)

pragma solidity 0.8.1;

import "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _setMap(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        map._values[key] = value;
        return map._keys.addBytes32Set(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _removeMap(Map storage map, bytes32 key) private returns (bool) {
        delete map._values[key];
        return map._keys.removeBytes32Set(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _containsMap(Map storage map, bytes32 key)
        private
        view
        returns (bool)
    {
        return map._keys.containsBytes32Set(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _lengthMap(Map storage map) private view returns (uint256) {
        return map._keys.lengthBytes32Set();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _atMap(Map storage map, uint256 index)
        private
        view
        returns (bytes32, bytes32)
    {
        bytes32 key = map._keys.atBytes32Set(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGetMap(Map storage map, bytes32 key)
        private
        view
        returns (bool, bytes32)
    {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_containsMap(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _getMap(Map storage map, bytes32 key)
        private
        view
        returns (bytes32)
    {
        bytes32 value = map._values[key];
        require(
            value != 0 || _containsMap(map, key),
            "EnumerableMap: nonexistent key"
        );
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _getMap(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _containsMap(map, key), errorMessage);
        return value;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function setUintToAddressMap(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return
            _setMap(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function removeUintToAddressMap(UintToAddressMap storage map, uint256 key)
        internal
        returns (bool)
    {
        return _removeMap(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function containsUintToAddressMap(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (bool)
    {
        return _containsMap(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function lengthUintToAddressMap(UintToAddressMap storage map)
        internal
        view
        returns (uint256)
    {
        return _lengthMap(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function atUintToAddressMap(UintToAddressMap storage map, uint256 index)
        internal
        view
        returns (uint256, address)
    {
        (bytes32 key, bytes32 value) = _atMap(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGetUintToAddressMap(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (bool, address)
    {
        (bool success, bytes32 value) = _tryGetMap(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function getUintToAddressMap(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_getMap(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function getUintToAddressMap(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return
            address(
                uint160(
                    uint256(_getMap(map._inner, bytes32(key), errorMessage))
                )
            );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity 0.8.1;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _addSet(Set storage set, bytes32 value) private returns (bool) {
        if (!_containsSet(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _removeSet(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _containsSet(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _lengthSet(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _atSet(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _valuesSet(Set storage set)
        private
        view
        returns (bytes32[] memory)
    {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function addBytes32Set(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _addSet(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function removeBytes32Set(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _removeSet(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function containsBytes32Set(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _containsSet(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function lengthBytes32Set(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {
        return _lengthSet(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function atBytes32Set(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _atSet(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function valuesBytes32Set(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _valuesSet(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function addAddressSet(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _addSet(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function removeAddressSet(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _removeSet(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function containsAddressSet(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _containsSet(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function lengthAddressSet(AddressSet storage set)
        internal
        view
        returns (uint256)
    {
        return _lengthSet(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function atAddressSet(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_atSet(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function valuesAddressSet(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _valuesSet(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function addUintSet(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _addSet(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function removeUintSet(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _removeSet(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function containsUintSet(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _containsSet(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function lengthUintSet(UintSet storage set)
        internal
        view
        returns (uint256)
    {
        return _lengthSet(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function atUintSet(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_atSet(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function valuesUintSet(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _valuesSet(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

// 数学安全库
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            require(c >= a, errorMessage);
            return c;
        }
    }

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

    function mul(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            if (a == 0) return 0;
            uint256 c = a * b;
            require(c / a == b, errorMessage);
            return c;
        }
    }

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

pragma solidity 0.8.1;

contract Fallback {
    fallback() external payable {}

    receive() external payable {}
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

pragma solidity 0.8.1;

interface IAsset {
    function claim(
        address token,
        address to,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IInvite {

    function invite(address upper) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IList {
    function getStateV1(address account) external view returns (bool);

    function getStateV2(uint16 id, address account)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INormalTicket is IERC721 {
    struct MintInfo {
        uint256 id;
        address token;
        uint256 managerFee; //平台管理费
        uint256 superPrizeFee; //超级奖池费
        uint256 prizePoolFee; //普通奖池费
    }

    // 获取NFT铸造信息
    function tryGetNFTInfo(uint256 id)
        external
        view
        returns (bool, MintInfo memory);

    // 设置已使用
    function setUse(uint256 tokenId) external;

    // 查询是否使用
    function getUse(uint256 tokenId) external view returns (bool);

    function mintBatch(address to, uint8 count) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ISeniorTicket is IERC721 {
    struct MintInfo {
        uint256 id;
        address token;
        uint256 managerFee; //平台管理费
        uint256 superPrizeFee; //超级奖池费
        uint256 prizePoolFee; //普通奖池费
    }

    // 获取NFT铸造信息
    function tryGetNFTInfo(uint256 id)
        external
        view
        returns (bool, MintInfo memory);

    // 设置已使用
    function setUse(uint256 tokenId) external;

    // 查询是否使用
    function getUse(uint256 tokenId) external view returns (bool);

    function mintBatch(address to, uint8 count) external;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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