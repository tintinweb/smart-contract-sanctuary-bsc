// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/IAppConf.sol";
import "../libs/IERC20Ex.sol";

import "./Model.sol";

library Lib {
    struct FarmAddr {
        address pancake;
        address farmUser;
        address farmPair;
        address farmReward;
    }
}

// 配置合约
contract AppConf is IAppConf, Ownable {
    mapping(uint8 => Model.Level) levelMap;
    Model.Level[] public allLevels;

    // level => gen => percent
    mapping(uint8 => mapping(uint8 => uint256)) public levelCommissionMap;

    // pair status, 0=noexist, 1=enabled, 2=disabled
    // token0 -> token1 -> status, 0=不存在, 1=开启, 2=关闭
    mapping(address => mapping(address => Model.Pair)) public allPairMap;
    Model.Pair[] public allPairs;

    address public burnAddr;
    address public coolAddr;
    address public fundCoolAddr;
    address public lpCoolAddr;
    address public rankCoolAddr;

    address public rootInviter;

    // 1=level, 2=lp, 3=pair, 4=token
    mapping(uint8 => Model.HashrateConf) hashrateConfMap;

    uint256 public maxGen = 25;

    uint256 public outMultiple = 3000;

    mapping(address => uint8) public farmAddrMap;

    mapping(address => uint8) public whitelistMap;

    mapping(address => uint8) public exchangeMap;

    uint256 public pairQuoteBurnRate = 300;
    uint256 public pairUsdtRate = 750;
    uint256 public pairUsdtSwapRate = 750;
    uint256 public pairSwapBurnRate = 1000;
    address public pairSwapCoolAddr;
    address public swapToken;

    uint256 public rewardPerSecond = 5787000000;

    Lib.FarmAddr farmAddr;
    Model.ClaimProfitRate claimProfitRate;

    uint256 rankTop = 21;

    mapping(address => mapping(address => address[])) swapPathMap;

    uint256 quoteBasePrice = 130433000000000; // usdt price

    constructor() {
        burnAddr = 0x000000000000000000000000000000000000dEaD;
        coolAddr = _msgSender();
        pairSwapCoolAddr = _msgSender();
        rankCoolAddr = address(0);

        rootInviter = _msgSender();

        // swap path
        address tokenIn = 0x0f91b06a6143DCe1AEeDa804e461ABd1622f1Be2;
        address tokenOut = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
        
        address[] memory swapPath = new address[](3);
        swapPath[0] = tokenIn;
        swapPath[1] = tokenOut;
        swapPathMap[tokenIn][tokenOut] = swapPath;

        // claim profit rate
        claimProfitRate.rankRate = 80;
        claimProfitRate.lpRate = 40;
        claimProfitRate.fundRate = 30;
        claimProfitRate.burnRate = 20;

        // farm addr
        farmAddrMap[_msgSender()] = 1;

        farmAddr.pancake = 0xC2cA956daE41834bdAeff50Cce70E4a3aB5DB4B5;
        farmAddr.farmUser = address(0);
        farmAddr.farmPair = 0x730Fee8368094c72b8d3B2e6CA36cF795cCfa421;
        farmAddr.farmReward = address(0);

        // pair
        address token0 = 0x0f91b06a6143DCe1AEeDa804e461ABd1622f1Be2;
        address token1 = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
        allPairMap[token0][token1] = Model.Pair({
            token0: token0,
            token0Symbol: IERC20Ex(token0).symbol(),
            token0Decimals: IERC20Ex(token0).decimals(),
            token1: token1,
            token1Symbol: IERC20Ex(token1).symbol(),
            token1Decimals: IERC20Ex(token1).decimals(),
            status: 1
        });
        allPairs.push(allPairMap[token0][token1]);

        // hashrate
        hashrateConfMap[Model.CATEGORY_PAIR] = Model.HashrateConf({
            multiple: 1000,
            baseHashrate: 1000,
            minTotalHashrate: 10000,
            maxTotalHashrate: 3500000,
            maxReward: 2000,
            rebate: 0,
            tokenRebate: 1,
            invited: 0
        });

        // level
        levelMap[0] = Model.Level({
            name: "V0",
            levelNo: 0,
            commissionGen: 0,
            price: 0,
            needOut: 0
        });
        levelMap[1] = Model.Level({
            name: "V1",
            levelNo: 0,
            commissionGen: 2,
            price: 500,
            needOut: 0
        });
        allLevels.push(levelMap[1]);
        levelMap[2] = Model.Level({
            name: "V2",
            levelNo: 0,
            commissionGen: 5,
            price: 1000,
            needOut: 0
        });
        allLevels.push(levelMap[2]);
        levelMap[3] = Model.Level({
            name: "V3",
            levelNo: 0,
            commissionGen: 10,
            price: 2000,
            needOut: 0
        });
        allLevels.push(levelMap[3]);
        levelMap[4] = Model.Level({
            name: "V4",
            levelNo: 0,
            commissionGen: 25,
            price: 5000, // base USDT
            needOut: 0
        });
        allLevels.push(levelMap[4]);

        // gen commission
        // p1=level, p2=gen
        levelCommissionMap[1][1] = 200;
        levelCommissionMap[1][2] = 150;

        levelCommissionMap[2][1] = 200;
        levelCommissionMap[2][2] = 150;
        levelCommissionMap[2][3] = 120;
        levelCommissionMap[2][4] = 30;
        levelCommissionMap[2][5] = 30;

        levelCommissionMap[3][1] = 200;
        levelCommissionMap[3][2] = 150;
        levelCommissionMap[3][3] = 120;
        levelCommissionMap[3][4] = 30;
        levelCommissionMap[3][5] = 30;
        levelCommissionMap[3][6] = 30;
        levelCommissionMap[3][7] = 30;
        levelCommissionMap[3][8] = 30;
        levelCommissionMap[3][9] = 30;
        levelCommissionMap[3][10] = 30;

        levelCommissionMap[4][1] = 200;
        levelCommissionMap[4][2] = 150;
        levelCommissionMap[4][3] = 120;
        levelCommissionMap[4][4] = 30;
        levelCommissionMap[4][5] = 30;
        levelCommissionMap[4][6] = 30;
        levelCommissionMap[4][7] = 30;
        levelCommissionMap[4][8] = 30;
        levelCommissionMap[4][9] = 30;
        levelCommissionMap[4][10] = 30;
        levelCommissionMap[4][11] = 30;
        levelCommissionMap[4][12] = 30;
        levelCommissionMap[4][13] = 20;
        levelCommissionMap[4][14] = 20;
        levelCommissionMap[4][15] = 20;
        levelCommissionMap[4][16] = 20;
        levelCommissionMap[4][17] = 20;
        levelCommissionMap[4][18] = 20;
        levelCommissionMap[4][19] = 20;
        levelCommissionMap[4][20] = 20;
        levelCommissionMap[4][21] = 20;
        levelCommissionMap[4][22] = 20;
        levelCommissionMap[4][23] = 20;
        levelCommissionMap[4][24] = 20;
        levelCommissionMap[4][25] = 20;
    }

    function setPair(address token0, address token1, uint8 status) public onlyOwner {
        allPairMap[token0][token1] = Model.Pair({
            token0: token0,
            token0Symbol: IERC20Ex(token0).symbol(),
            token0Decimals: IERC20Ex(token0).decimals(),
            token1: token1,
            token1Symbol: IERC20Ex(token1).symbol(),
            token1Decimals: IERC20Ex(token1).decimals(),
            status: status
        });
        allPairs.push(allPairMap[token0][token1]);
    }

    function validPair(address token0, address token1) public view override returns (bool)
    {
        return allPairMap[token0][token1].status == 1;
    }

    function getAllPairs() public view override returns (Model.Pair[] memory) {
        return allPairs;
    }

    function setLevelCommission(uint8 levelNo, uint8 gen, uint256 rate) public onlyOwner {
        levelCommissionMap[levelNo][gen] = rate;
    }

    function getLevelCommissionRate(uint8 levelNo, uint8 gen) public view override returns (uint256)
    {
        return levelCommissionMap[levelNo][gen];
    }

    function setCoolAddr(address _coolAddr) public onlyOwner {
        coolAddr = _coolAddr;
    }

    function getCoolAddr() public view override returns (address) {
        return coolAddr;
    }

    function setRootInviter(address _rootInviter) public onlyOwner {
        rootInviter = _rootInviter;
    }

    function getRootInviter() public view override returns (address) {
        return rootInviter;
    }

    function getHashrateConf(uint8 category) public view override returns (Model.HashrateConf memory)
    {
        return hashrateConfMap[category];
    }

    function setHashrateConf(uint8 category, Model.HashrateConf memory hc) public onlyOwner {
        hashrateConfMap[category].multiple = hc.multiple;
        hashrateConfMap[category].baseHashrate = hc.baseHashrate;
        hashrateConfMap[category].minTotalHashrate = hc.minTotalHashrate;
        hashrateConfMap[category].maxTotalHashrate = hc.maxTotalHashrate;
        hashrateConfMap[category].maxReward = hc.maxReward;
        hashrateConfMap[category].rebate = hc.rebate;
        hashrateConfMap[category].tokenRebate = hc.tokenRebate;
        hashrateConfMap[category].invited = hc.invited;
    }

    function setBurnAddr(address _burnAddr) public onlyOwner {
        burnAddr = _burnAddr;
    }

    function getBurnAddr() public view override returns (address) {
        return burnAddr;
    }

    function getMaxGen() public view override returns (uint256) {
        return maxGen;
    }

    function setMaxGen(uint256 _maxGen) public onlyOwner {
        maxGen = _maxGen;
    }

    function getOutMultiple() public view override returns (uint256) {
        return outMultiple;
    }

    function setOutMultiple(uint256 _outMultiple) public onlyOwner {
        outMultiple = _outMultiple;
    }

    function setFarmAddr(address[] calldata farmAddrs, uint8 status) public onlyOwner
    {
        for (uint256 index = 0; index < farmAddrs.length; index++) {
            farmAddrMap[farmAddrs[index]] = status;
        }
    }

    function validFarm(address addr) public view override returns (bool) {
        return farmAddrMap[addr] == 1;
    }

    function setWhitelist(address addr, uint8 status) public onlyOwner {
        whitelistMap[addr] = status;
    }

    function getPairQuoteBurnRate() public view override returns (uint256) {
        return pairQuoteBurnRate;
    }

    function setPairQuoteBurnRate(uint256 _pairQuoteBurnRate) public onlyOwner {
        pairQuoteBurnRate = _pairQuoteBurnRate;
    }

    function getPairUsdtRate() public view override returns (uint256) {
        return pairUsdtRate;
    }

    function setPairUsdtRate(uint256 _pairUsdtRate) public onlyOwner {
        pairUsdtRate = _pairUsdtRate;
    }

    function getPairUsdtSwapRate() public view override returns (uint256) {
        return pairUsdtSwapRate;
    }

    function setPairUsdtSwapRate(uint256 _pairUsdtSwapRate) public onlyOwner {
        pairUsdtSwapRate = _pairUsdtSwapRate;
    }

    function getPairSwapBurnRate() public view override returns (uint256) {
        return pairSwapBurnRate;
    }

    function setPairSwapBurnRate(uint256 _pairSwapBurnRate) public onlyOwner {
        pairSwapBurnRate = _pairSwapBurnRate;
    }

    function getPairSwapCoolAddr() public view override returns (address) {
        return pairSwapCoolAddr;
    }

    function setPairSwapCoolAddr(address _pairSwapCoolAddr) public onlyOwner {
        pairSwapCoolAddr = _pairSwapCoolAddr;
    }

    function getSwapToken() public view override returns (address) {
        return swapToken;
    }

    function setSwapToken(address _swapToken) public onlyOwner {
        swapToken = _swapToken;
    }

    function getRewardPerSecond() public view override returns (uint256) {
        return rewardPerSecond;
    }

    function setRewardPerSecond(uint256 _rewardPerSecond) public onlyOwner {
        rewardPerSecond = _rewardPerSecond;
    }

    function setFarmAddr(Lib.FarmAddr calldata _farmAddr) public onlyOwner {
        farmAddr.pancake = _farmAddr.pancake;
        farmAddr.farmUser = _farmAddr.farmUser;
        farmAddr.farmPair = _farmAddr.farmPair;
        farmAddr.farmReward = _farmAddr.farmReward;

        farmAddrMap[farmAddr.pancake] = 1;
        farmAddrMap[farmAddr.farmUser] = 1;
        farmAddrMap[farmAddr.farmPair] = 1;
        farmAddrMap[farmAddr.farmReward] = 1;
    }

    function getFarmAddr() public view returns(Lib.FarmAddr memory) {
        return farmAddr;
    }

    function getLPCoolAddr() public view override returns (address) {
        return lpCoolAddr;
    }

    function setLPCoolAddr(address _lpCoolAddr) public onlyOwner {
        lpCoolAddr = _lpCoolAddr;
    }

    function setRankCoolAddr(address _rankCoolAddr) public onlyOwner {
        rankCoolAddr = _rankCoolAddr;
    }

    function getRankCoolAddr() public view override returns (address) {
        return rankCoolAddr;
    }

    function getFundCoolAddr() public view override returns (address) {
        return fundCoolAddr;
    }

    function setFundCoolAddr(address _fundCoolAddr) public onlyOwner {
        fundCoolAddr = _fundCoolAddr;
    }

    function getClaimProfitRate() public view override returns(Model.ClaimProfitRate memory) {
        return claimProfitRate;
    }

    function setClaimProfitRate(Model.ClaimProfitRate calldata rate) public onlyOwner {
        claimProfitRate.rankRate = rate.rankRate;
        claimProfitRate.lpRate = rate.lpRate;
        claimProfitRate.fundRate = rate.fundRate;
        claimProfitRate.burnRate = rate.burnRate;
    }

    function getSwapPath(address tokenIn, address tokenOut) public view returns(address[] memory) {
        return swapPathMap[tokenIn][tokenOut];
    }

    function setSwapPath(address tokenIn, address tokenOut, address[] calldata path) public onlyOwner {
        swapPathMap[tokenIn][tokenOut] = path;
    }

    function getAllLevels() public view override returns(Model.Level[] memory) {
        return allLevels;
    }

    function getLevel(uint8 levelNo) public override view returns(Model.Level memory) {
        return levelMap[levelNo];
    }

    function getRankTop() public view override returns(uint256) {
        return rankTop;
    }

    function setRankTop(uint256 _rankTop) public onlyOwner {
        rankTop = _rankTop;
    }

    function getQuoteBasePrice() public view override returns(uint256) {
        return quoteBasePrice;
    }

    function setQuoteBasePrice(uint256 basePrice) public onlyOwner {
        quoteBasePrice = basePrice;
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
pragma solidity ^0.8.9;

import "../Model.sol";

interface IAppConf {
    function validFarm(address farmAddr) external returns (bool);
    function validPair(address token0, address token1) external view returns (bool);
    function getAllPairs() external view returns (Model.Pair[] memory);

    function getLevelCommissionRate(uint8 levelNo, uint8 gen) external view returns (uint256);
    function getCoolAddr() external view returns (address);
    function getRootInviter() external view returns (address);
    function getHashrateConf(uint8 category) external view returns (Model.HashrateConf memory);

    function getBurnAddr() external view returns (address);
    function getMaxGen() external view returns (uint256);
    function getOutMultiple() external view returns (uint256);

    function getPairQuoteBurnRate() external view returns (uint256);
    function getPairUsdtRate() external view returns (uint256);
    function getPairUsdtSwapRate() external view returns (uint256);
    function getPairSwapBurnRate() external view returns (uint256);
    function getPairSwapCoolAddr() external view returns (address);

    function getSwapToken() external view returns (address);
    function getLPCoolAddr() external view returns (address);
    function getRankCoolAddr() external view returns (address);
    function getFundCoolAddr() external view returns (address);

    function getClaimProfitRate() external view returns(Model.ClaimProfitRate memory);

    function getRewardPerSecond() external view returns (uint256);

    function getSwapPath(address tokenIn, address tokenOut) external view returns(address[] memory);

    function getLevel(uint8 levelNo) external view returns(Model.Level memory);
    function getAllLevels() external view returns(Model.Level[] memory);

    function getRankTop() external returns(uint256);
    function getQuoteBasePrice() external returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Ex is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Model {
    uint8 constant CATEGORY_LEVEL = 1;
    uint8 constant CATEGORY_LP = 2;
    uint8 constant CATEGORY_PAIR = 3;
    uint8 constant CATEGORY_TOKEN = 4;

    struct User {
        address addr;
        address inviterAddr;
        uint8 levelNo;
        uint256 levelPrice;
        uint8 out; // is out
        uint8 outTimes; // out times
        uint256 outAmount; // base USDT
        uint256 totalInvestAmount;
        uint256 totalYieldAmount;
        uint256 totalInviteAmount;
    }

    struct Pair {
        address token0;
        string token0Symbol;
        uint8 token0Decimals;
        address token1;
        string token1Symbol;
        uint8 token1Decimals;
        uint8 status;
    }

    struct Level {
        string name;
        uint8 levelNo;
        uint8 commissionGen;
        uint256 price;
        uint8 needOut;
    }

    struct HashrateConf {
        uint256 multiple; // multple fro usdt
        uint256 baseHashrate; // hashrate base amount
        uint256 minTotalHashrate; // network min hashrate
        uint256 maxTotalHashrate; // network max hashrate
        uint256 maxReward; // network max reward
        uint8 rebate; // hashrate rebate
        uint8 tokenRebate; // token rebate
        uint8 invited; // if 1 for invited user
    }

    struct HashrateRecord {
        uint8 category; // 0=all, 1=level, 2=lp, 3=pair
        uint256 blockNumber;
        uint256 timestamp;
        uint256 totalHashrate;
    }

    struct CommissionRecord {
        address from;
        address to;
        uint256 commission;
    }

    struct ClaimProfitRate {
        uint256 burnRate;
        uint256 rankRate;
        uint256 lpRate;
        uint256 fundRate;
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