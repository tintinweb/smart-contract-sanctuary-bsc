/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.16;

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function power(uint256 a, uint256 b) internal pure returns (uint256){

        if(a == 0) return 0;
        if(b == 0) return 1;

        uint256 c = a ** b;
        require(c > 0, "SafeMathForUint256: modulo by zero");
        return c;
    }
}

library TransferHelper {

    function safeApprove(address token, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransfer(address token, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function burn(address token, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x42966c68, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

}


contract Rolls {
    using SafeMath for uint256;

    mapping (address => mapping(uint256 => StakeRecord)) private addressStakeIdMap;
    mapping (address => uint256) private addressIdMap;

    mapping(address => StakeRecord[]) addressStakeRecords;
    address[] stakeAddresses;

    mapping (uint256 => mapping(uint256 => uint256)) private unitCoinPerBlock;// 产出类型 - 区块高度 - 单位质押量的产币量
    uint256 private lastUnitPerBlock;// 最近记录的区块高度的单位产币量

    uint256 netTotalStake;// LP全网总质押量

    address private _lpContractAddress;
    uint256 private _lpContractDecimal;

    address private owner;// 发行此合约地址

    bool _mining = false;// 启动挖矿
    uint256 startMineTime;// 启动挖矿时间


    modifier onlyOwner() {
        require(msg.sender == owner, "only publisher can operate");
        _;
    }

    GenInfo[] private genInfoArray;
    mapping (uint256 => GenInfo) private genInfoMap;
    struct GenInfo {
        uint256 coinType;// 产出类型  1ROLLS  2GFU
        string name;// 币种名称
        address contractAddress;// 产出合约地址
        uint256 decimals;// 产出币精度 - 真实的精度
        uint256 daily;// 每日产出 - 多了SCALE之后的
        uint256 startHeight;// 开挖高度
        uint256 dayCount;// 产出天数
        uint256 scale;// 放大的数量级
    }

    uint256 STAKE_STATUS_STAKING = 1;// 质押中
    uint256 STAKE_STATUS_CANCELED = 2;// 已赎回
    struct StakeRecord {
        uint256 id;// 质押id
        uint256 stake;// 质押数量
        uint256 stakeHeight;// 质押高度
        uint256 redeemHeight;// 赎回高度
        uint256 time;// 质押时间
        uint256 status;// 状态
    }

    mapping(address => mapping(uint256 => mapping(uint256 => ProfitRecord))) private stakeProfitRecord;
    struct ProfitRecord {
        uint256 coinType;// 产出类型
        uint256 taked;// 已领取收益
        uint256 lastTakeHeight;// 上次提取高度
    }

    mapping (address => mapping(uint256 => mapping(uint256 => ExtractRecord[]))) private addressExtractRecords;

    struct ExtractRecord {
        uint256 qty;// 提取数量
        uint256 time;// 提取时间
    }

    constructor(address lpContractAddress, uint256 lpContractDecimal) {
        _lpContractAddress = lpContractAddress;
        _lpContractDecimal = lpContractDecimal;
        owner = msg.sender;
    }

    function getLpInfo() public view returns (address, uint256) {
        return (_lpContractAddress, _lpContractDecimal);
    }

    // 添加每日产出
    function addGen(uint256 coinType, string memory name, address contractAddress, uint256 daily, uint256 decimals,
        uint256 startHeight, uint256 dayCount, uint256 scale) public onlyOwner {
        GenInfo memory g = GenInfo({
            coinType : coinType,
            name : name,
            contractAddress : contractAddress,
            decimals : decimals,
            daily : daily,
            startHeight : startHeight,
            dayCount : dayCount,
            scale: scale
        });
        genInfoArray.push(g);
        genInfoMap[coinType] = g;
    }

    // 设置每日产出[给ROLLS用]
    function setGen(uint256 coinType, uint256 daily, uint256 dayCount) public onlyOwner {
        uint256 l = genInfoArray.length;
        uint256 currentBlockHeight = getBlockHeight();
        if (netTotalStake > 0 && currentBlockHeight >= 1 && lastUnitPerBlock < currentBlockHeight.sub(1)) {
            for (uint256 j = 0; j < l; j++) {
                for (uint256 i = lastUnitPerBlock.add(1); i < currentBlockHeight; i++) {
                    unitCoinPerBlock[genInfoArray[j].coinType][i] = getUnitGen(genInfoArray[j].coinType, i);
                }
            }
        }
        
        for (uint256 i = 0; i < l; i++) {
            if (genInfoArray[i].coinType != coinType) continue;
            genInfoArray[i].daily = daily;
            genInfoArray[i].dayCount = dayCount;
            break;
        }
        genInfoMap[coinType].daily = daily;
        genInfoMap[coinType].dayCount = dayCount;

        for (uint256 j = 0; j < l; j++) {
            unitCoinPerBlock[genInfoArray[j].coinType][currentBlockHeight] = getUnitGen(genInfoArray[j].coinType, currentBlockHeight);
        }

        lastUnitPerBlock = currentBlockHeight;
    }

    // 启动挖矿
    function startMine() public onlyOwner {
        if (_mining) return;
        _mining = true;
        startMineTime = block.timestamp;
    }

    // 全网总质押  本地址总质押
    function getNetData() public view returns (uint256, uint256) {
        uint256 addressData = getAddressTotalData(msg.sender);
        return (netTotalStake, addressData);
    }

    // 地址总质押量
    function getAddressTotalData(address user) internal view returns (uint256) {
        uint256 l = addressStakeRecords[user].length;
        uint256 totalStake = uint256(0);
        for (uint256 i = 0; i < l; i++) {
            if (addressStakeRecords[user][i].status == STAKE_STATUS_STAKING) {
                totalStake = totalStake.add(addressStakeRecords[user][i].stake);
            }
        }
        return totalStake;
    }

    // 质押量，已领取收益，待领取收益
    function getStakeData(uint256 id, uint256 coinType) public view returns (uint256, uint256, uint256) {
        uint256 currentBlockHeight = getBlockHeight();
        uint256 pendingProfit = getPendingProfit(msg.sender, id, currentBlockHeight, coinType);
        return (addressStakeIdMap[msg.sender][id].stake, stakeProfitRecord[msg.sender][id][coinType].taked, pendingProfit);
    }

    function calculateProfit(address user, uint256 id, uint256 coinType, uint256 start, uint256 end) internal view returns (uint256) {
        uint256 itemu = 0;
        uint256 t = 0;
        if (start > end) {
            return 0;
        }
        for (uint256 i = start; i <= end; i++) {
            itemu = unitCoinPerBlock[coinType][i];
            if (itemu <= 0) {
                itemu = addressStakeIdMap[user][id].stake.mul(getTotalPerBlock(i, coinType));
                itemu = itemu.div(netTotalStake);
                t = t.add(itemu);
            } else {
                t = t.add(itemu.mul(addressStakeIdMap[user][id].stake));
            }
        }
        return t;
    }

    // 单质押记录实时计算未领取收益
    function getPendingProfit(address user, uint256 id, uint256 currentBlockHeight, uint256 coinType) internal view returns (uint256) {
        if (currentBlockHeight <= 0) {
            return 0;
        }
        GenInfo memory g = genInfoMap[coinType];
        uint256 start = stakeProfitRecord[user][id][coinType].lastTakeHeight;
        if (start < g.startHeight) start = g.startHeight;
        if (addressStakeIdMap[user][id].status == STAKE_STATUS_STAKING) {// 质押中
            if (currentBlockHeight > g.startHeight.add(g.dayCount)) {// 此产出币已产完
                return calculateProfit(user, id, coinType, start, g.startHeight.add(g.dayCount).sub(1));
            } else if (currentBlockHeight <= g.startHeight) {// 还没到产出时间
                return 0;
            } else {
                return calculateProfit(user, id, coinType, start, currentBlockHeight.sub(1));
            }
        } else {
            if (addressStakeIdMap[user][id].redeemHeight > g.startHeight.add(g.dayCount)) {// 赎回时的高度已经过了产出期
                return calculateProfit(user, id, coinType, start, g.startHeight.add(g.dayCount).sub(1));
            } else if (addressStakeIdMap[user][id].redeemHeight <= g.startHeight) {// 还没到产出时间
                return 0;
            } else {// 赎回时的高度已处于产出期
                return calculateProfit(user, id, coinType, start, addressStakeIdMap[user][id].redeemHeight.sub(1));
            }
        }
    }

    // 得到当前区块高度
    function getBlockHeight() public view returns (uint256) {
        uint256 ds = block.timestamp.sub(startMineTime);
        return ds.div(300);
    }

    function getUnitPerBlock(uint256 coinType, uint256 blockHeight) public view returns (uint256) {
        return unitCoinPerBlock[coinType][blockHeight];
    }

    function getLastUnitPerBlock() public view returns (uint256) {
        return lastUnitPerBlock;
    }

    // 产币高度对应的每个区块的产币量
    function getTotalPerBlock(uint256 blockHeight, uint256 coinType) internal view returns (uint256) {
        if (!_mining) return uint256(0);
        uint256 end = genInfoMap[coinType].startHeight.add(genInfoMap[coinType].dayCount);
        return blockHeight <= end && blockHeight >= genInfoMap[coinType].startHeight ? genInfoMap[coinType].daily : 0;
    }

    // 质押
    function stake(uint256 amount) public {
        require(TransferHelper.safeTransferFrom(_lpContractAddress, msg.sender, address(this), amount), "asset insufficient");
        uint256 currentBlockHeight = getBlockHeight();
        if (addressStakeRecords[msg.sender].length == 0) {
            stakeAddresses.push(msg.sender);
        }

        uint256 sid = addressIdMap[msg.sender];

        StakeRecord memory o = StakeRecord({
            id: sid,
            stake: amount,
            stakeHeight: currentBlockHeight,
            redeemHeight: 0,
            time: block.timestamp,
            status: STAKE_STATUS_STAKING
        });
        addressStakeRecords[msg.sender].push(o);
        addressStakeIdMap[msg.sender][sid] = o;
        addressIdMap[msg.sender] = sid.add(1);

        uint256 l = genInfoArray.length;
        if (netTotalStake > 0 && currentBlockHeight >= 1 && lastUnitPerBlock < currentBlockHeight.sub(1)) {
            for (uint256 j = 0; j < l; j++) {
                for (uint256 i = lastUnitPerBlock.add(1); i < currentBlockHeight; i++) {
                    unitCoinPerBlock[genInfoArray[j].coinType][i] = getUnitGen(genInfoArray[j].coinType, i);
                }
            }
        }
        netTotalStake = netTotalStake.add(amount);

        for (uint256 j = 0; j < l; j++) {
            unitCoinPerBlock[genInfoArray[j].coinType][currentBlockHeight] = getUnitGen(genInfoArray[j].coinType, currentBlockHeight);
            stakeProfitRecord[msg.sender][sid][genInfoArray[j].coinType].coinType = genInfoArray[j].coinType;
            stakeProfitRecord[msg.sender][sid][genInfoArray[j].coinType].taked = 0;
            stakeProfitRecord[msg.sender][sid][genInfoArray[j].coinType].lastTakeHeight = currentBlockHeight;
        }

        lastUnitPerBlock = currentBlockHeight;
    }

    function getUnitGen(uint256 coinType, uint256 blockHeight) internal view returns (uint256) {
        uint256 blockTotalCoin = getTotalPerBlock(blockHeight, coinType);
        return blockTotalCoin.div(netTotalStake);
    }

    // 赎回
    function take(uint256 id) public {
        require(addressStakeIdMap[msg.sender][id].status == STAKE_STATUS_STAKING, "staking less than 0");
        require(TransferHelper.safeTransfer(_lpContractAddress, msg.sender, addressStakeIdMap[msg.sender][id].stake), "asset insufficient");
        uint256 currentBlockHeight = getBlockHeight();
        uint256 stakes = addressStakeRecords[msg.sender].length;
        for (uint256 i = 0; i < stakes; i++) {
            if (addressStakeRecords[msg.sender][i].id == id) {
                addressStakeRecords[msg.sender][i].status = STAKE_STATUS_CANCELED;
                addressStakeRecords[msg.sender][i].redeemHeight = currentBlockHeight;
                break;
            }
        }
        addressStakeIdMap[msg.sender][id].status = STAKE_STATUS_CANCELED;
        addressStakeIdMap[msg.sender][id].redeemHeight = currentBlockHeight;

        uint256 l = genInfoArray.length;
        if (netTotalStake > 0 && currentBlockHeight >= 1 && lastUnitPerBlock < currentBlockHeight.sub(1)) {
            for (uint256 j = 0; j < l; j++) {
                for (uint256 i = lastUnitPerBlock.add(1); i < currentBlockHeight; i++) {
                    unitCoinPerBlock[genInfoArray[j].coinType][i] = getUnitGen(genInfoArray[j].coinType, i);
                }
            }

        }
        netTotalStake = netTotalStake.sub(addressStakeIdMap[msg.sender][id].stake);

        for (uint256 j = 0; j < l; j++) {
            if (netTotalStake <= 0) {
                unitCoinPerBlock[genInfoArray[j].coinType][currentBlockHeight] = 0;
            } else {
                unitCoinPerBlock[genInfoArray[j].coinType][currentBlockHeight] = getUnitGen(genInfoArray[j].coinType, currentBlockHeight);
            }
        }
        lastUnitPerBlock = currentBlockHeight;
    }

    // 单记录提取收益
    function extract(uint256 id, uint256 coinType) public {
        uint256 currentBlockHeight = getBlockHeight();
        uint256 pendingProfit = getPendingProfit(msg.sender, id, currentBlockHeight, coinType);
        require(pendingProfit.div(uint256(10).power(genInfoMap[coinType].scale)) > 0, "avail less than 0");
        require(TransferHelper.safeTransfer(genInfoMap[coinType].contractAddress, msg.sender, pendingProfit.div(uint256(10).power(genInfoMap[coinType].scale))), "asset insufficient");

        if (netTotalStake > 0 && lastUnitPerBlock < currentBlockHeight) {
            uint256 l = genInfoArray.length;
            for (uint256 j = 0; j < l; j++) {
                for (uint256 i = lastUnitPerBlock.add(1); i <= currentBlockHeight; i++) {
                    unitCoinPerBlock[genInfoArray[j].coinType][i] = getUnitGen(genInfoArray[j].coinType, i);
                }
            }
            lastUnitPerBlock = currentBlockHeight;
        }

        addressExtractRecords[msg.sender][id][coinType].push(ExtractRecord({
        qty: pendingProfit,
        time: block.timestamp
        }));

        stakeProfitRecord[msg.sender][id][coinType].taked = stakeProfitRecord[msg.sender][id][coinType].taked.add(pendingProfit);
        stakeProfitRecord[msg.sender][id][coinType].lastTakeHeight = currentBlockHeight;
    }

    // 同步高度的单位收益，防止高度差太大用户操作失败
    function syncHeight(uint256 heightNum) public {
        uint256 currentBlockHeight = getBlockHeight();
        if (lastUnitPerBlock < currentBlockHeight) {
            uint256 limit = lastUnitPerBlock.add(heightNum);
            if (limit > currentBlockHeight) limit = currentBlockHeight;
            uint256 l = genInfoArray.length;
            for (uint256 j = 0; j < l; j++) {
                for (uint256 i = lastUnitPerBlock.add(1); i <= limit; i++) {
                    if (netTotalStake > 0) {
                        unitCoinPerBlock[genInfoArray[j].coinType][i] = getUnitGen(genInfoArray[j].coinType, i);
                    } else {
                        unitCoinPerBlock[genInfoArray[j].coinType][i] = 0;
                    }
                }
            }
            lastUnitPerBlock = limit;
        }
    }

    // 质押记录
    function stakeRecord() public view returns (StakeRecord[] memory) {
        return addressStakeRecords[msg.sender];
    }

    // 提取记录
    function extractRecord(uint256 id, uint256 coinType) public view returns (ExtractRecord[] memory) {
        return addressExtractRecords[msg.sender][id][coinType];
    }

    // 产出类型
    function genType() public view returns (GenInfo[] memory) {
        return genInfoArray;
    }

    // 转移权限
    function renounceOwnerShip(address user) public onlyOwner {
        owner = user;
    }
}