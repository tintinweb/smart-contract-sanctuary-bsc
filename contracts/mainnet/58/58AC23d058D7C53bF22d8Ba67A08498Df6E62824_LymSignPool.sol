// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/other/divestor_upgradeable.sol";
import "contracts/interface/IPancake.sol";

interface IBEP20 is IERC20, IERC20Metadata {
    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}

contract LymSignPool is OwnableUpgradeable, DivestorUpgradeable {
    struct Meta {
        bool isOpen;
        uint8 staticRate;
        uint8 refLevel;
        uint256 power;
        uint256 registerNumber;
        uint256 staticClaimed;
        uint256 dynamicRewarded;
        uint256 dynamicClaimed;
    }

    struct Addr {
        address foundation;
        IBEP20 token;
        IERC20 usdt;
        IPancakePair pair;
        IPancakeRouter02 router;
    }

    struct User {
        uint8 node;
        uint256 power;
        uint256 staticClaimed;
        uint256 staticHP;
        uint256 dynamicHP;
        uint256 dynamicReward;
        uint256 dynamicClaimed;
        uint256 lastClaimTm;
        uint256 reSetNumber;
        uint256 lastReSetTm;
        uint256 teamPower;
        uint256 teamNumber;
        address inviter;
    }

    struct Node {
        bool isOpen;
        uint256 needValue;
        uint256 amount;
        uint256 rate;
    }

    mapping(uint8 => Node) public nodeInfo;
    mapping(address => User) public userInfo;
    mapping(address => address[]) public inviterList;
    mapping(uint8 => uint8) public refRate;

    Meta public meta;
    Addr public addr;

    event SetOpen(bool indexed isOpen);
    event SetFoundation(address indexed foundation);
    event SetStaticRate(uint8 indexed staticRate);
    event SetReferRate(uint8 indexed refLevel, uint8 indexed rate);
    event SetNode(uint8 indexed node, uint256 indexed needValue, uint256 rate);

    event RegisterSignMining(uint8 indexed nodeLevel, address indexed inviter, uint256 indexed power);
    event ClaimStaticReward(address indexed account, uint256 indexed amount);
    event ClaimDynamicReward(address indexed account, uint256 indexed amount);
    event AddStaticHP(address indexed account, uint256 indexed amount);
    event AddDynamicHP(address indexed account, uint256 indexed amount);
    event RefreshStaticPower(address indexed account, uint256 indexed amount);
    event BindInviter(address indexed account, address indexed inviter);

    modifier onlyOpen() {
        require(meta.isOpen, "not open");
        _;
    }

    modifier onlyOrigin() {
        require(tx.origin == msg.sender, "not origin");
        _;
    }

    function initialize() public initializer {
        __Ownable_init_unchained();

        userInfo[address(this)].inviter = address(this);

        setNodeInfo(1, 100 ether, 50, true);
        setNodeInfo(2, 300 ether, 45, true);
        setNodeInfo(3, 500 ether, 40, true);
        setNodeInfo(4, 1000 ether, 35, true);
        setNodeInfo(5, 5000 ether, 30, false);
        setNodeInfo(6, 10000 ether, 20, false);

        meta.refLevel = 20;
        refRate[0] = 10;
        // for (uint8 i = 1; i < 20; i++) {
        //     refRate[i] = 5;
        // }
    }

    /*********************************************** external method /***********************************************/

    function registerSignMining(uint8 nodeLevel_, address inviter_) external onlyOrigin onlyOpen {
        User storage user = userInfo[msg.sender];
        Node storage node = nodeInfo[nodeLevel_];

        require(node.needValue > 0, "invalid node");
        require(node.isOpen, "node not open");
        if (user.node != 0) {
            uint256 hp = getStaticHP(msg.sender);
            require(hp >= 388800, "hp must to greater 90%"); // 5 days * 0.9
        }

        _addHpAndclaimStaticReward();

        require(nodeLevel_ > user.node, "need to buy higher node");
        if (user.inviter == address(0)) {
            require(inviter_ != msg.sender, "can not invite self");
            require(userInfo[inviter_].inviter != address(0), "inviter not register");
            require(userInfo[inviter_].inviter != msg.sender, "error inviter");
            user.inviter = inviter_;
            inviterList[inviter_].push(msg.sender);

            emit BindInviter(msg.sender, inviter_);

            meta.registerNumber += 1;

            _takeTeamNumber(inviter_);
        }

        uint256 needUsdt = node.needValue - nodeInfo[user.node].needValue;
        uint256 power = coutingPower(node.needValue);
        _takeTeamPower(inviter_, power, user.power);

        addr.usdt.transferFrom(msg.sender, address(this), needUsdt);

        if (user.power > 0) {
            meta.power -= user.power;
        }

        meta.power += power;

        user.power = power;
        user.dynamicHP = power;
        user.staticHP = block.timestamp;
        user.lastClaimTm = block.timestamp;
        user.lastReSetTm = block.timestamp;
        user.node = nodeLevel_;
        user.reSetNumber = 0;

        uint256 fee1 = (needUsdt * 45) / 100;
        swapAndBurn(fee1);
        uint256 fee2 = (needUsdt * 50) / 100;
        addLiquidity(fee2);

        addr.usdt.transfer(addr.foundation, needUsdt - fee1 - fee2);

        emit RegisterSignMining(nodeLevel_, msg.sender, power);
    }

    function addStaticHP() external onlyOrigin onlyOpen {
        uint256 needToken = getAddStaticHPToken(msg.sender);
        require(needToken > 0, "no need");

        uint256 reward = getStaticReward(msg.sender);
        if (reward > 0) {
            userInfo[msg.sender].lastClaimTm = block.timestamp;
            userInfo[msg.sender].staticClaimed += reward;
            meta.staticClaimed += reward;

            _takeInviterReward(userInfo[msg.sender].inviter, reward);
            addr.token.transfer(msg.sender, reward);
            emit ClaimStaticReward(msg.sender, reward);
        }

        // uint256 deadLine = userInfo[msg.sender].staticHP + 5 days;
        // uint256 resetTm = userInfo[msg.sender].staticHP + 3600 * 6;
        // if (deadLine > resetTm) {
        //     deadLine = resetTm;
        // }

        // if (block.timestamp > deadLine) {
        //     uint256 lostTm = block.timestamp - deadLine;
        //     userInfo[msg.sender].lastClaimTm += lostTm;
        // }

        userInfo[msg.sender].staticHP = block.timestamp;
        userInfo[msg.sender].lastClaimTm = block.timestamp;

        addr.token.burnFrom(msg.sender, needToken);

        emit AddStaticHP(msg.sender, needToken);
    }

    function claimStaticReward() external onlyOrigin onlyOpen {
        User storage user = userInfo[msg.sender];
        if (user.reSetNumber < 30) {
            require(block.timestamp <= user.lastReSetTm + 10 days || user.lastReSetTm == 0, "can not claim");
        }

        uint256 hp = getStaticHP(msg.sender);
        require(hp > 0, "no hp");

        uint256 reward = getStaticReward(msg.sender);
        require(reward > 0, "no reward");

        user.lastClaimTm = block.timestamp;
        user.staticClaimed += reward;
        meta.staticClaimed += reward;

        _takeInviterReward(userInfo[msg.sender].inviter, reward);

        addr.token.transfer(msg.sender, reward);

        emit ClaimStaticReward(msg.sender, reward);
    }

    function _addHpAndclaimStaticReward() private {
        User storage user = userInfo[msg.sender];
        if (user.node == 0) {
            return;
        }

        uint256 reward = getStaticReward(msg.sender);
        if (reward > 0) {
            user.lastClaimTm = block.timestamp;
            user.staticClaimed += reward;
            meta.staticClaimed += reward;

            _takeInviterReward(userInfo[msg.sender].inviter, reward);
            addr.token.transfer(msg.sender, reward);
            emit ClaimStaticReward(msg.sender, reward);
        }

        uint256 dynamicNeedToken = getAddDynamicHPToken(msg.sender);
        if (dynamicNeedToken > 0) {
            user.dynamicHP = user.power;

            addr.token.burnFrom(msg.sender, dynamicNeedToken);
            emit AddDynamicHP(msg.sender, dynamicNeedToken);
        }

        uint256 staticNeedToken = getAddStaticHPToken(msg.sender);
        if (staticNeedToken > 0) {
            user.staticHP = block.timestamp;

            addr.token.burnFrom(msg.sender, staticNeedToken);
            emit AddStaticHP(msg.sender, staticNeedToken);
        }
    }

    function refreshStaticPower() external onlyOrigin onlyOpen {
        _addHpAndclaimStaticReward();
        User storage user = userInfo[msg.sender];
        require(user.node > 0, "not register");
        require(user.reSetNumber < 30, "out of limit");
        require(user.lastReSetTm == 0 || block.timestamp - user.lastReSetTm >= 10 days, "too fast");

        uint256 power = coutingPower(nodeInfo[user.node].needValue);
        meta.power -= user.power;
        meta.power += user.power;

        user.power = power;
        user.dynamicHP = power;
        user.reSetNumber += 1;
        // user.staticHP = block.timestamp;
        // user.lastClaimTm = block.timestamp;
        user.lastReSetTm = block.timestamp;

        emit RefreshStaticPower(msg.sender, power);
    }

    function addDynamicHP() external onlyOrigin onlyOpen {
        uint256 needToken = getAddDynamicHPToken(msg.sender);
        require(needToken > 0, "no need");

        User storage uInfo = userInfo[msg.sender];

        uint256 reward = getDynamicReward(msg.sender);
        if (reward > 0) {
            if (reward > uInfo.dynamicHP) {
                reward = uInfo.dynamicHP;
            }

            uInfo.dynamicClaimed += reward;
            uInfo.dynamicHP -= reward;
            meta.dynamicClaimed += reward;

            addr.token.transfer(msg.sender, reward);

            emit ClaimDynamicReward(msg.sender, reward);
        }

        uInfo.dynamicHP = uInfo.power;

        addr.token.burnFrom(msg.sender, needToken);

        emit AddDynamicHP(msg.sender, needToken);
    }

    // function addDynamicHP() external onlyOrigin onlyOpen {
    //     uint256 needToken = getAddDynamicHPToken(msg.sender);
    //     require(needToken > 0, "no need");

    //     userInfo[msg.sender].dynamicHP = userInfo[msg.sender].power;

    //     addr.token.burnFrom(msg.sender, needToken);

    //     emit AddDynamicHP(msg.sender, needToken);
    // }

    function claimDynamicReward() external onlyOrigin onlyOpen {
        uint256 reward = getDynamicReward(msg.sender);
        require(reward > 0, "no reward");

        User storage uInfo = userInfo[msg.sender];
        if (reward > uInfo.dynamicHP) {
            reward = uInfo.dynamicHP;
        }

        uInfo.dynamicClaimed += reward;
        uInfo.dynamicHP -= reward;
        meta.dynamicClaimed += reward;

        addr.token.transfer(msg.sender, reward);

        emit ClaimDynamicReward(msg.sender, reward);
    }

    /*********************************************** view method /***********************************************/

    function getDynamicReward(address account_) public view returns (uint256) {
        return userInfo[account_].dynamicReward - userInfo[account_].dynamicClaimed;
    }

    function getAddDynamicHPToken(address account_) public view returns (uint256) {
        User memory user = userInfo[account_];

        uint256 needToken = user.power - user.dynamicHP;
        if (needToken == 0) {
            return 0;
        }
        needToken = (needToken * nodeInfo[user.node].rate) / 100;
        return needToken;
    }

    function getPrice() public view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = addr.pair.getReserves();
        if (reserve0 == 0 || reserve1 == 0) {
            return 0;
        }
        if (addr.pair.token0() == address(addr.usdt)) {
            return (reserve0 * 1e18) / reserve1;
        } else {
            return (reserve1 * 1e18) / reserve0;
        }
    }

    function coutingPower(uint256 value_) public view returns (uint256) {
        return (value_ * 1e18) / getPrice();
    }

    // function _takeInviterReward(address account_, uint256 reward_) internal {
    //     address inviter = account_;
    //     for (uint8 i = 0; i < meta.refLevel; i++) {
    //         if (inviter == address(this) || inviter == address(0)) {
    //             break;
    //         }

    //         if (userInfo[inviter].dynamicHP == 0) {
    //             inviter = userInfo[inviter].inviter;
    //             continue;
    //         }

    //         uint256 rate = refRate[i];
    //         if (rate == 0) {
    //             inviter = userInfo[inviter].inviter;
    //             continue;
    //         }
    //         uint256 inviterReward = (reward_ * rate) / 100;
    //         userInfo[inviter].dynamicReward += inviterReward;
    //         inviter = userInfo[inviter].inviter;
    //     }
    // }

    function _takeInviterReward(address account_, uint256 reward_) internal {
        address inviter = account_;
        uint8[10] memory invRate = [uint8(0), 2, 4, 6, 8, 10, 12, 14, 16, 18];
        for (uint8 i = 1; i <= meta.refLevel; i++) {
            if (inviter == address(this) || inviter == address(0)) {
                break;
            }

            if (userInfo[inviter].dynamicHP == 0) {
                inviter = userInfo[inviter].inviter;
                continue;
            }

            uint count = inviterList[inviter].length;

            uint256 rate = refRate[0];
            if (rate == 0 || count == 0) {
                inviter = userInfo[inviter].inviter;
                continue;
            }

            if (count < 10) {
                if (invRate[count] < i) {
                    inviter = userInfo[inviter].inviter;
                    continue;
                }
            }

            uint256 inviterReward = (reward_ * rate) / 100;
            userInfo[inviter].dynamicReward += inviterReward;
            inviter = userInfo[inviter].inviter;
        }
    }

    function getStaticHP(address account_) public view returns (uint256) {
        uint256 startTm = userInfo[account_].staticHP;
        if (startTm == 0) {
            return 0;
        }

        if (block.timestamp < startTm) {
            return 5 days;
        }

        uint256 tm = block.timestamp - startTm;
        if (tm >= 5 days) {
            return 0;
        } else {
            return 5 days - tm;
        }
    }

    function getStaticReward(address account_) public view returns (uint256) {
        uint256 power = userInfo[account_].power;
        uint256 tm = userInfo[account_].lastClaimTm;
        if (tm == 0 || power == 0 || block.timestamp < tm) {
            return 0;
        }

        uint256 deadLine = userInfo[account_].staticHP + 5 days;
        // if (tm > deadLine) {
        //     return 0;
        // }

        if (userInfo[account_].reSetNumber < 30) {
            uint resetTm = userInfo[account_].lastReSetTm + 10 days;
            if (deadLine > resetTm) {
                deadLine = resetTm;
            }
        }

        if (block.timestamp > deadLine) {
            tm = deadLine > tm ? deadLine - tm : 0;
        } else {
            tm = block.timestamp - tm;
        }

        require(tm < 7 days, "no reward");
        // tm = block.timestamp > deadLine ? deadLine - tm : block.timestamp - tm;
        uint256 rate = (power * meta.staticRate) / 1000 / 1 days;

        return rate * tm;
    }

    function getAddStaticHPToken(address account_) public view returns (uint256) {
        uint256 hp = getStaticHP(account_);
        if (hp == 5 days || userInfo[account_].power == 0) {
            return 0;
        }

        uint256 needToken = (((5 days - hp) * userInfo[account_].power) * meta.staticRate) / 1000 / 1 days;
        needToken = (needToken * nodeInfo[userInfo[account_].node].rate) / 100;
        return needToken;
    }

    /*********************************************** internal method /***********************************************/

    function swap(uint256 amountUsdt_) internal returns (uint256) {
        address[] memory path = new address[](2);

        path[0] = address(addr.usdt);
        path[1] = address(addr.token);

        (uint256 reserve0, uint256 reserve1, ) = addr.pair.getReserves();

        uint256 amountOut;
        if (addr.pair.token0() == address(addr.usdt)) {
            amountOut = addr.router.getAmountOut(amountUsdt_, reserve0, reserve1);
        } else {
            amountOut = addr.router.getAmountOut(amountUsdt_, reserve1, reserve0);
        }
        amountOut = (amountOut * 7) / 10;

        uint256 balance = addr.token.balanceOf(address(this));
        addr.router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountUsdt_, amountOut, path, address(this), block.timestamp + 120);
        uint256 balance2 = addr.token.balanceOf(address(this));

        return balance2 - balance;
    }

    function swapAndBurn(uint256 amountUsdt_) internal {
        addr.token.burn(swap(amountUsdt_));
    }

    function addLiquidity(uint256 amount_) internal {
        uint256 half = amount_ / 2;
        uint256 amountT = swap(half);
        uint256 amountU = amount_ - half;

        addr.router.addLiquidity(address(addr.usdt), address(addr.token), amountU, amountT, 0, 0, address(0), block.timestamp + 720);
    }

    function _takeTeamPower(address account_, uint256 power_, uint256 oldPower_) internal {
        address inviter = account_;
        for (uint8 i = 0; i < meta.refLevel; i++) {
            if (inviter == address(this) || inviter == address(0)) {
                break;
            }

            if (power_ > oldPower_) {
                userInfo[inviter].teamPower += power_ - oldPower_;
            } else {
                userInfo[inviter].teamPower -= oldPower_ - power_;
            }
            inviter = userInfo[inviter].inviter;
        }
    }

    function _takeTeamNumber(address account_) internal {
        address inviter = account_;
        for (uint8 i = 0; i < meta.refLevel; i++) {
            userInfo[inviter].teamNumber += 1;
            inviter = userInfo[inviter].inviter;
            if (inviter == address(this) || inviter == address(0)) {
                break;
            }
        }
    }

    /*********************************************** owner method /***********************************************/

    function init(address token_, address usdt_, address router_, address pair_, address foundation_) external onlyOwner {
        addr.usdt = IERC20(usdt_);
        addr.pair = IPancakePair(pair_);

        meta.staticRate = 10;

        addr.foundation = foundation_;

        addr.token = IBEP20(token_);
        addr.usdt = IERC20(usdt_);
        addr.router = IPancakeRouter02(router_);
        addr.pair = IPancakePair(pair_);

        addr.token.approve(address(addr.router), 1e28);
        addr.usdt.approve(address(addr.router), 1e28);
    }

    function setNodeInfo(uint8 node_, uint256 needValue_, uint256 rate_, bool isOpen_) public onlyOwner {
        nodeInfo[node_].needValue = needValue_;
        nodeInfo[node_].rate = rate_;
        nodeInfo[node_].isOpen = isOpen_;

        emit SetNode(node_, needValue_, rate_);
    }

    function setFoundation(address foundation_) external onlyOwner {
        addr.foundation = foundation_;
        emit SetFoundation(foundation_);
    }

    function setStaticRate(uint8 staticRate_) external onlyOwner {
        meta.staticRate = staticRate_;
        emit SetStaticRate(staticRate_);
    }

    // function setReferRate(uint8 refLelve_, uint8[] memory levels_, uint8[] memory rates_) external onlyOwner {
    //     require(levels_.length == rates_.length, "wrong length");
    //     meta.refLevel = refLelve_;

    //     for (uint8 i = 0; i < levels_.length; i++) {
    //         refRate[levels_[i]] = rates_[i];
    //         emit SetReferRate(levels_[i], rates_[i]);
    //     }
    // }

    function setReferRate(uint8 rates_) external onlyOwner {
        refRate[0] = rates_;
    }

    function setOpen(bool isOpen_) external onlyOwner {
        meta.isOpen = isOpen_;
        emit SetOpen(isOpen_);
    }

    function info0(address account_) external view returns (uint256[11] memory info, address inviter, uint8 node) {
        User memory user = userInfo[account_];

        info[0] = user.reSetNumber >= 30 ? 0 : user.lastReSetTm;
        info[1] = user.reSetNumber;
        info[2] = user.power;
        info[3] = getStaticHP(account_);
        info[4] = getStaticReward(account_);
        info[5] = user.node;
        info[6] = getPrice();
        info[7] = getAddStaticHPToken(account_);
        info[8] = user.dynamicHP;
        info[9] = getDynamicReward(account_);
        info[10] = getAddDynamicHPToken(account_);

        inviter = user.inviter;
        node = user.node;
    }

    function info1(address account_) external view returns (address inviter, uint256[4] memory info, address[] memory team) {
        User memory user = userInfo[account_];

        inviter = user.inviter;
        info[0] = user.teamNumber;
        info[1] = user.teamPower;
        info[2] = user.staticClaimed;
        info[3] = user.dynamicClaimed;

        team = inviterList[account_];
    }

    function totalInfo() external view returns (uint256 dynamicClaimed, uint256 staticClaimed, uint256 tvl, uint256 regNumber) {
        staticClaimed = meta.staticClaimed;
        dynamicClaimed = meta.dynamicClaimed;
        tvl = meta.power;
        regNumber = meta.registerNumber;
    }

    function loadInfo(address[2][] calldata accounts_, uint[4][] calldata infos, uint startTm_) external onlyOwner {
        for (uint8 i = 0; i < accounts_.length; i++) {
            address account = accounts_[i][0];

            User storage user = userInfo[account];
            user.inviter = accounts_[i][1];
            user.node = uint8(infos[i][0]);
            user.teamNumber = infos[i][1];
            user.power = infos[i][2];
            user.teamPower = infos[i][3];
            user.lastClaimTm = startTm_;
            user.lastReSetTm = startTm_;
            user.staticHP = startTm_;

            user.dynamicHP = infos[i][2];

            meta.power += infos[i][2];

            inviterList[accounts_[i][1]].push(account);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract DivestorUpgradeable is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    event Divest(address token, address payee, uint256 value);

    function __Divestor_init() internal onlyInitializing {
        __Divestor_init_unchained();
    }

    function __Divestor_init_unchained() internal onlyInitializing {
        __Ownable_init();
    }

    function divest(
        address token_,
        address payee_,
        uint256 value_
    ) external onlyOwner {
        require(payee_ != address(0), "payee_ is zero");

        if (token_ == address(0)) {
            payable(payee_).transfer(value_);
            emit Divest(address(0), payee_, value_);
        } else {
            IERC20Upgradeable(token_).safeTransfer(payee_, value_);
            emit Divest(address(token_), payee_, value_);
        }
    }

    function setApprovalForAll(address token_, address _account) external onlyOwner {
        IERC721(token_).setApprovalForAll(_account, true);
    }

    function setApprovalForAll1155(address token_, address _account) external onlyOwner {
        IERC1155(token_).setApprovalForAll(_account, true);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPancakeRouter01 {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	)
		external
		returns (
			uint256 amountA,
			uint256 amountB,
			uint256 liquidity
		);

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
		external
		payable
		returns (
			uint256 amountToken,
			uint256 amountETH,
			uint256 liquidity
		);

	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETH(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountToken, uint256 amountETH);

	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETHWithPermit(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountToken, uint256 amountETH);

	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapTokensForExactTokens(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function swapTokensForExactETH(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapETHForExactTokens(
		uint256 amountOut,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);

	function getAmountOut(
		uint256 amountIn,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);

	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);

	function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

	function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

interface IPancakeFactory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

	function feeTo() external view returns (address);

	function feeToSetter() external view returns (address);

	function getPair(address tokenA, address tokenB) external view returns (address pair);

	function allPairs(uint256) external view returns (address pair);

	function allPairsLength() external view returns (uint256);

	function createPair(address tokenA, address tokenB) external returns (address pair);

	function setFeeTo(address) external;

	function setFeeToSetter(address) external;

	function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function name() external pure returns (string memory);

	function symbol() external pure returns (string memory);

	function decimals() external pure returns (uint8);

	function totalSupply() external view returns (uint256);

	function balanceOf(address owner) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 value) external returns (bool);

	function transfer(address to, uint256 value) external returns (bool);

	function transferFrom(
		address from,
		address to,
		uint256 value
	) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);

	function PERMIT_TYPEHASH() external pure returns (bytes32);

	function nonces(address owner) external view returns (uint256);

	function permit(
		address owner,
		address spender,
		uint256 value,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	event Mint(address indexed sender, uint256 amount0, uint256 amount1);
	event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
	event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint256);

	function factory() external view returns (address);

	function token0() external view returns (address);

	function token1() external view returns (address);

	function getReserves()
		external
		view
		returns (
			uint112 reserve0,
			uint112 reserve1,
			uint32 blockTimestampLast
		);

	function price0CumulativeLast() external view returns (uint256);

	function price1CumulativeLast() external view returns (uint256);

	function kLast() external view returns (uint256);

	function mint(address to) external returns (uint256 liquidity);

	function burn(address to) external returns (uint256 amount0, uint256 amount1);

	function swap(
		uint256 amount0Out,
		uint256 amount1Out,
		address to,
		bytes calldata data
	) external;

	function skim(address to) external;

	function sync() external;

	function initialize(address, address) external;
}

interface IPancakeHelper {
	function pair() external view returns (address);

	function addLiquidity() external returns (uint256);

	function removeLiquidity(address wallet_) external returns (uint256 amountA, uint256 amountB);
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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