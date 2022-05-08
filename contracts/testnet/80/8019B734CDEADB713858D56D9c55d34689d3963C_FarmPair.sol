// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

import "../libs/IBurn.sol";
import "../libs/IERC20Ex.sol";
import "../libs/Initializable.sol";
import "../libs/Recoverable.sol";

import "./interfaces/IAppConf.sol";
import "./interfaces/IFarmUser.sol";
import "./interfaces/IPancake.sol";

import "./FarmHashrate.sol";
import "./Model.sol";

contract FarmPair is FarmHashrate, Initializable, Ownable {
    using SafeERC20 for IERC20Ex;

    // token0 -> token1 -> user -> [amount0, amount1]
    mapping(address => mapping(address => mapping(address => uint256[2]))) public pairPoolMap;

    // useraddr => totalhashrate
    mapping(address => uint256) public userHashrateMap;

    // useraddr -> token0 -> token1 -> hashrate
    mapping(address => mapping(address => mapping(address => uint256))) public pairHashrateMap;

    // userAddr -> token0 -> amount0 -> token1 -> amount1 -> hashrate -> pairUsdtAmount
    event PairStaked(address indexed, address, uint256, address, uint256, uint256, uint256);

    // 佣金, useraddr -> genuseraddr -> commission
    mapping(address => mapping(address => uint256)) commissionMap;

    IAppConf appConf;
    IPancake pancake;
    IFarmUser farmUser;

    function init(IAppConf _appConf) public onlyOwner {
        appConf = _appConf;

        Model.FarmAddr memory farmAddr = appConf.getFarmAddr();
        pancake = IPancake(farmAddr.pancake);
        farmUser = IFarmUser(farmAddr.farmUser);

        initialized = true;
    }

    modifier onlyFarm {
        require(appConf.validFarm(_msgSender()), "call forbidden, invalid farm");
        _;
    }

    function stakePair(uint256 usdtAmount) public needInit {
        require(usdtAmount > 0, "usdtAmount must great than 0");

        address quoteToken = pancake.getQuoteToken(); 
        address usdtToken = pancake.getUsdtToken();
        require(appConf.validPair(quoteToken, usdtToken), "Invalid pool token0_token1");

        // deposit usdt
        IERC20Ex(usdtToken).safeTransferFrom(_msgSender(), address(this), usdtAmount);

        // need invited user
        Model.HashrateConf memory hc = appConf.getHashrateConf(Model.CATEGORY_PAIR);
        if (hc.invited == 1) {
            require(farmUser.existUser(_msgSender()), "user not exists");
        }

        // calc hashrate
        uint256 pairUsdtAmount = (usdtAmount * Model.RATE_BASE) / appConf.getPairUsdtRate();
        uint256 hashrate = calcTokenHashrate(pairUsdtAmount, hc.multiple);
        require(hashrate > 0, "hashrate is 0");

        // swap & burn 
        uint256 swapUsdtAmount = (usdtAmount * appConf.getPairUsdtSwapRate()) / Model.RATE_BASE;
        if (swapUsdtAmount > 0) {
            uint256[] memory swapAmounts = _swap(usdtToken, swapUsdtAmount, appConf.getSwapToken(), 0);
            _burnToken(appConf.getSwapToken(), swapAmounts[swapAmounts.length - 1]);
        }
        
        // burn quote token
        uint256 quoteAmount = pancake.calcTokenAmountBaseUsdt(pairUsdtAmount - usdtAmount, quoteToken);
        _burnTokenFrom(_msgSender(), quoteToken, quoteAmount);

        // update staking info
        {
            // update staking amount
            uint256[2] storage amounts = pairPoolMap[quoteToken][usdtToken][_msgSender()];
            amounts[0] = amounts[0] + quoteAmount;
            amounts[1] = amounts[1] + usdtAmount;

            // update user hashrate
            pairHashrateMap[_msgSender()][quoteToken][usdtToken] = pairHashrateMap[_msgSender()][quoteToken][usdtToken] + hashrate;
            userHashrateMap[_msgSender()] = userHashrateMap[_msgSender()] + hashrate;
            totalHashrate = totalHashrate + hashrate;
        }

        // handle usdt token rebate
        uint256 rebateUsdtAmount = usdtAmount - swapUsdtAmount;
        if (hc.tokenRebate == 0 && rebateUsdtAmount > 0) {
            IERC20Ex(usdtToken).safeTransfer(appConf.getCoolAddr(), rebateUsdtAmount);
        }

        // update invest & invite amount
        farmUser.incrementInvestAmount(_msgSender(), pairUsdtAmount);

        Model.User memory genUser = farmUser.getInviterUser(_msgSender());
        farmUser.incrementInviteAmount(genUser.addr, pairUsdtAmount);

        // to rebate
        {
            uint256 totalUsdtCommission = 0;
            if (hc.tokenRebate == 1 || hc.rebate == 1) {
                for (uint8 gen = 1; gen <= appConf.getMaxGen(); gen++) {
                    if (genUser.addr == appConf.getRootInviter()) {
                        break;
                    }

                    uint256 commissionRate = appConf.getLevelCommissionRate(genUser.levelNo, gen);
                    if (commissionRate == 0) {
                        genUser = farmUser.getInviterUser(genUser.inviterAddr);
                        break;
                    }

                    if (hc.tokenRebate == 1) {
                        uint256 usdtCommission = (rebateUsdtAmount * commissionRate) / Model.RATE_BASE;
                        if (usdtCommission > 0) {
                            IERC20Ex(usdtToken).safeTransfer(genUser.addr, usdtCommission);
                            totalUsdtCommission += usdtCommission;
                        }
                    }

                    if (hc.rebate == 1) {
                        uint256 hashrateCommission = (hashrate * commissionRate) / Model.RATE_BASE;
                        userHashrateMap[genUser.addr] = userHashrateMap[genUser.addr] + hashrateCommission;

                        totalHashrate = totalHashrate + hashrateCommission;
                        commissionMap[_msgSender()][genUser.addr] = commissionMap[_msgSender()][genUser.addr] + hashrateCommission;

                        // record gen user hashrate
                        this.recordUserHashrate(Model.CATEGORY_PAIR, genUser.addr, userHashrateMap[genUser.addr]);
                    }

                    genUser = farmUser.getInviterUser(genUser.inviterAddr);
                }
            }

            uint256 remainingUsdtAmount = rebateUsdtAmount - totalUsdtCommission;
            if (remainingUsdtAmount > 0) {
                IERC20Ex(usdtToken).safeTransfer(appConf.getCoolAddr(), remainingUsdtAmount);
            }
        }

        // record user & newtork hashrate
        this.recordHashrate(Model.CATEGORY_PAIR, _msgSender(), userHashrateMap[_msgSender()], totalHashrate);
        emit PairStaked(_msgSender(), quoteToken, quoteAmount, usdtToken, usdtAmount, hashrate, pairUsdtAmount);
    }

    function calcTokenHashrate(uint256 usdtAmount, uint256 multiple) public view returns (uint256) {
        // hashrate is calculated by usdt
        uint256 hashrate = (usdtAmount * multiple) / (Model.RATE_BASE * (10**pancake.getUsdtDecimals()));
        return hashrate;
    }

    function getStakeAmount(address userAddr, address token0, address token1) public view returns (uint256, uint256) {
        uint256[2] storage amounts = pairPoolMap[token0][token1][userAddr];
        return (amounts[0], amounts[1]);
    }

    function clearHashrate(address userAddr) external override onlyFarm {
        // clear user hashrate
        totalHashrate = totalHashrate - userHashrateMap[userAddr];
        userHashrateMap[userAddr] = 0;

        // clear commission hashrate
        Model.User memory genUser = farmUser.getInviterUser(_msgSender());
        for (uint8 gen = 1; gen <= appConf.getMaxGen(); gen++) {
            if (genUser.addr == appConf.getRootInviter()) {
                break;
            }

            uint256 commission = commissionMap[_msgSender()][genUser.addr];
            if (commission == 0) {
                genUser = farmUser.getInviterUser(genUser.inviterAddr);
                continue;
            }

            userHashrateMap[genUser.addr] = userHashrateMap[genUser.addr] - commission;
            totalHashrate = totalHashrate - commission;

            // reset to 0
            commissionMap[_msgSender()][genUser.addr] = 0;

            this.recordUserHashrate(Model.CATEGORY_PAIR, genUser.addr, userHashrateMap[genUser.addr]);
            genUser = farmUser.getInviterUser(genUser.inviterAddr);
        }

        this.recordHashrate(Model.CATEGORY_PAIR, userAddr, userHashrateMap[userAddr], totalHashrate);
    }

    function _swap(address tokenIn, uint amountIn, address tokenOut, uint amountOutMin) private returns(uint[] memory) {
        address[] memory path = appConf.getSwapPath(tokenIn, tokenOut);
        if (path.length == 0) {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        }

        address router = pancake.getRouterAddr();
        IERC20(tokenIn).approve(router, amountIn);

        uint[] memory amounts = IUniswapV2Router02(router).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), block.timestamp);
        return amounts;
    }

    function _burnToken(address token, uint256 burnAmount) internal {
        address burnAddr = appConf.getBurnAddr();
        if (burnAddr == address(0)) {
            IBurn(token).burn(burnAmount);
        } else {
            IERC20Ex(token).safeTransfer(burnAddr, burnAmount);
        }
    }

    function _burnTokenFrom(address fromAddr, address token, uint256 burnAmount) internal {
        address burnAddr = appConf.getBurnAddr();
        if (burnAddr == address(0)) {
            IBurn(token).burnFrom(fromAddr, burnAmount);
        } else {
            IERC20Ex(token).safeTransferFrom(fromAddr, burnAddr, burnAmount);
        }
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBurn {
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
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

abstract contract Initializable {
 
    bool public initialized = false;

    modifier needInit() {
        require(initialized, "Contract not init.");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Recoverable is Ownable {
    event Received(address indexed, uint256);
    event Recover(address indexed, uint256);
    event RecoverToken(address indexed, uint256);

    receive() external virtual payable {
        // custom function code
        emit Received(_msgSender(), msg.value);   
    }

    function recover(address toAddr) public virtual onlyOwner {
        uint256 balance = address(this).balance;

        Address.sendValue(payable(toAddr), balance);
        emit Recover(toAddr, balance);
    }

    function recoverToken(IERC20 token, address toAddr) public virtual onlyOwner {
        uint256 balance = token.balanceOf(address(this));

        token.transfer(toAddr, balance);
        emit RecoverToken(toAddr, balance);
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
    function getFarmDeltaRate() external returns(uint256);

    function getFarmAddr() external view returns(Model.FarmAddr memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Model.sol";

interface IFarmUser {
    function getInviterUser(address userAddr) external view returns (Model.User memory);
    function bindInviter(address inviterAddr) external;
    function getUserByAddr(address userAddr) external view returns (Model.User memory);
    function existUser(address userAddr) external view returns (bool);
    function incrementInvestAmount(address userAddr, uint256 usdtAmount) external returns (Model.User memory);
    function decrementInvestAmount(address userAddr, uint256 usdtAmount) external returns (Model.User memory);
    function incrementYieldAmount(address userAddr, uint256 usdtAmount) external returns (bool);
    function incrementInviteAmount(address userAddr, uint256 usdtAmount) external;
    function out(address userAddr) external;
    function getAllUsers() external view returns(Model.User[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPancake {
    function getUsdtDecimals() external view returns (uint8);
    function getUsdtToken() external view returns (address);
    function getQuoteToken() external view returns (address);
    function getPriceBaseUsdt(address token) external view returns (uint256);
    function getUsdtLPToken() external view returns (address);
    function getUsdtLPTokenAmounts() external view returns(uint112, uint112);
    function getUsdtLPTokenAmounts(uint256 liqidity) external view returns(uint256, uint256);
    function calcTokenAmountBaseUsdt(uint256 usdtAmount, address token) external view returns (uint256);
    function swapToken(address tokenIn, uint amountIn, address tokenOut, uint amountOutMin, address toAddr) external returns(uint[] memory);
    function getRouterAddr() external view returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IFarmHashrate.sol";
import "./Model.sol";

abstract contract FarmHashrate is IFarmHashrate {

    uint256 public totalHashrate = 0;

    // useraddr -> record
    mapping(address => Model.HashrateRecord[]) public userHashrateRecords;

    Model.HashrateRecord[] public totalHashrateRecords;

    // 获取全网算力
    function getTotalHashrate() public view override returns(uint256) {
        return totalHashrate;
    }

    function getTotalHashrateRecords() public view override returns(Model.HashrateRecord[] memory) {
        return totalHashrateRecords;
    }

    function getUserHashrate(address userAddr) public view override returns(uint256, uint256, uint256) {
        Model.HashrateRecord[] storage records = userHashrateRecords[userAddr];
        if (records.length == 0) {
            return (0, 0, 0);
        }

        return (records[records.length - 1].totalHashrate, records[records.length - 1].blockNumber, records[records.length - 1].timestamp);
    }

    function getUserHashrateRecords(address userAddr) public view override returns(Model.HashrateRecord[] memory) {
        return userHashrateRecords[userAddr];
    }

    function recordHashrate(uint8 category, address userAddr, uint256 userTotalHashrate, uint256 networkHashrate) external override {
        userHashrateRecords[userAddr].push(Model.HashrateRecord({
            category: category,
            blockNumber: block.number,
            timestamp: block.timestamp,
            totalHashrate: userTotalHashrate
        }));
        totalHashrateRecords.push(Model.HashrateRecord({
            category: category,
            blockNumber: block.number,
            timestamp: block.timestamp,
            totalHashrate: networkHashrate
        }));
    }

    function recordUserHashrate(uint8 category, address userAddr, uint256 userTotalHashrate) external override {
        userHashrateRecords[userAddr].push(Model.HashrateRecord({
            category: category,
            blockNumber: block.number,
            timestamp: block.timestamp,
            totalHashrate: userTotalHashrate
        }));
    }

    function recordNetworkHashrate(uint8 category, uint256 networkHashrate) external override {
        totalHashrateRecords.push(Model.HashrateRecord({
            category: category,
            blockNumber: block.number,
            timestamp: block.timestamp,
            totalHashrate: networkHashrate
        }));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Model {
    uint8 constant CATEGORY_LEVEL = 1;
    uint8 constant CATEGORY_LP = 2;
    uint8 constant CATEGORY_PAIR = 3;
    uint8 constant CATEGORY_TOKEN = 4;

    uint256 constant RATE_BASE = 1000;

    struct User {
        address addr;
        address inviterAddr;
        uint8 levelNo;
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
        uint256 minReward; // network min reward
        uint256 maxReward; // network max reward
        uint256 totalReward; // total reward
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

    struct FarmAddr {
        address pancake;
        address farmUser;
        address farmPair;
        address farmReward;
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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Model.sol";

interface IFarmHashrate {
    function getTotalHashrate() external view returns(uint256);
    function getTotalHashrateRecords() external view returns(Model.HashrateRecord[] memory);
    function getUserHashrate(address userAddr) external view returns(uint256, uint256, uint256);
    function getUserHashrateRecords(address userAddr) external view returns(Model.HashrateRecord[] memory);
    function clearHashrate(address userAddr) external;
    function recordHashrate(uint8 category, address userAddr, uint256 userTotalHashrate, uint256 totalHashrate) external;
    function recordUserHashrate(uint8 category, address userAddr, uint256 userTotalHashrate) external;
    function recordNetworkHashrate(uint8 category, uint256 networkHashrate) external;
}