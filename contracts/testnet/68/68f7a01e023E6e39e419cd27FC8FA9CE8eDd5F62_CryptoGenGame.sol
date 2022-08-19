// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract CryptoGenGame is Ownable {

    uint256[] prices = [
        0.00 ether,
        0.04 ether,
        0.06 ether,
        0.10 ether,
        0.13 ether,
        0.15 ether,
        0.20 ether,
        0.30 ether,
        0.50 ether,
        1.00 ether,
        2.00 ether
    ];

    uint256[] times = [
        999 days,
        167 hours, // 7 days
        143 hours, // 6 days
        119 hours, // 5 days
        95 hours,  // 4 days
        71 hours,  // 3 days
        47 hours,  // 2 days
        23 hours,  // 1 day
        11 hours,  // 0 day
        5 hours,   // 0 day
        0
    ];

    uint256[] gameRefPercents = [14, 7, 4];

    uint256 public startDateUnix;
    bool isInitialized;

    // data[level][user_idx] - адреса игроков, на одного игрока может приходиться несколько слотов (что увеличивает его вероятность выигрыша)
    address payable[][] data;
    // count[level][user_idx] - число выплат игроку на уровне
    mapping (uint256 => mapping (uint256 => uint256)) count;
    uint256[11] pushUp;
    uint256[11] pushDown;

    uint256 constant PROJECT_FEE = 10;
    uint256 constant PROJECT_PUSH = 15;
    uint256 constant PERCENTS_DIVIDER = 100;

    struct User {
        address referrer;
        uint256[3] referals;

        uint256[11] _slots;
        uint256[11] _slotsClosed;
        uint256[11] _rewards;
        uint256[11] _gameRefBonuses;
    }

    mapping (address => User) internal users;

    address payable refWallet;
    address payable projectWallet;
    address payable pushWallet;

    // покупка слота
    event Slot(address indexed account, uint8 indexed level, uint256 amount);
    // выплата выигрыша
    event Payment(address indexed recipient, uint8 indexed level, address from, uint256 amount);
    // выплата реферального вознаграждения
    event RefPayment(address indexed recipient, uint8 indexed level, address from, uint256 amount);

    constructor(
        address payable projectAddr, 
        address payable refAddr, 
        address payable pushAddr, 
        uint256 start, 
        address[] memory refs
    ) {
        refWallet = refAddr;
        projectWallet = projectAddr;
        pushWallet = pushAddr;
        startDateUnix = start;

        address payable[] memory s = new address payable[](0);
        for (uint256 i; i < 11; i++) {
            data.push(s);
        }

        // формируем вершину пирамиды
        users[refs[1]].referrer = refs[0];
        users[refs[0]].referals[0]++;

    }

    function setStartDate(uint256 newDate) external onlyOwner {
        startDateUnix = newDate;
    }

    function setLevelTime(uint8 level, uint256 newTime) external onlyOwner {
        require(level>0 && level <=10, "Level must be between 1 and 10");
        times[level] = newTime;
    }
    
    function emergency() external onlyOwner {
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success, "Failed!");
    }

    mapping (address => bool) a;
    function init(address payable[] memory x, uint8[] memory y, uint256[] memory z, bool isLast) external onlyOwner {
        require(!isInitialized);
        for (uint256 i; i < x.length; i++) {
            address payable addr = x[i];
            uint8 lvl = y[i];
            uint256 amount = z[i];
            a[addr] = true;
            users[addr]._slots[lvl] += amount;
            for (uint256 j; j < amount; j++) {
                data[lvl].push(addr);
                if (data[lvl].length > 2) {
                    address payable next = data[lvl][((data[lvl].length-1)/2)-1];
                    data[lvl].push(next);
                }
            }
        }
        isInitialized = isLast;
    }

    function buySlot(uint8 level, address referrer) external payable {
        require(block.timestamp >= startDateUnix + times[level], "Slot not opened yet");
        uint256 amount = msg.value / prices[level];
        require(amount >= 1, "Incorrect value");

        uint256 mod = msg.value % prices[level];
        if (mod > 0) {
            payable(msg.sender).transfer(mod);
        }

        User storage user = users[msg.sender];

        // устанавливаем реферера только при первой покупке
        if (user.referrer == address(0) && referrer != msg.sender) {
			user.referrer = referrer;
			address ref = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (ref != address(0)) {
					users[ref].referals[i]++;
					ref = users[ref].referrer;
				} else break;
			}
		}

        _process(payable(msg.sender), level, amount);

        // здесь может не хватить средств на контракте - pushUp/pushDown финансировался за счет стейкинга?
        uint256 upPrice = prices[level+1];
        uint256 downPrice = prices[level-1];
        if (level < 10 && pushUp[level] >= upPrice && address(this).balance >= upPrice) {
            pushUp[level] -= upPrice;
            _process(pushWallet, level+1, 1);
        } else if (level > 1 && pushDown[level] >= downPrice && address(this).balance >= downPrice) {
            pushDown[level] -= downPrice;
            _process(pushWallet, level-1, 1);
        }
    }

    function _process(address payable account, uint8 level, uint256 amount) internal {
        uint256 value = amount * prices[level];

        // выплата на кошелек проекта
        (projectWallet.send(value * PROJECT_FEE / PERCENTS_DIVIDER));

        User storage user = users[account];

        address payable recipient;
        user._slots[level] += amount;
        emit Slot(account, level, amount);
        uint256 adminFee;

        for (uint256 i = 0; i < amount; i++) {
            // добавили игрока для последующих начислений
            data[level].push(payable(account));

            // играющих слотов на уровне < 3 ИЛИ их четное число
            if (data[level].length < 3 || data[level].length % 2 == 0) {
                if (data[level].length == 2) {
                    recipient = data[level][0];
                    count[level][0]++;
                } else {
                    recipient = projectWallet;
                }
            } else {
                // играющих слотов на уровне >= 3 ИЛИ их нечетное число
                uint256 idx = data[level].length / 2;
                recipient = data[level][idx];
                count[level][idx]++;
                if (count[level][idx] == 4) {
                    users[recipient]._slotsClosed[level]++;
                }

                // непонятная муть с a[]
                uint256 nextId = ((data[level].length-1) / 2)-1;
                address payable next = data[level][nextId];
                if (count[level][nextId] < 4 || a[next]) {
                    data[level].push(next);
                    count[level][data[level].length-1] = count[level][nextId];
                }
            }

            uint256 payment = prices[level] / 2;
            (recipient.send(payment));
            users[recipient]._rewards[level] += payment;
            emit Payment(recipient, level, account, payment);

            uint256 pushValue = prices[level] * PROJECT_PUSH / 2 / PERCENTS_DIVIDER;

            if (level < 10) {
                pushUp[level] += pushValue;
            } else {
                adminFee += pushValue;
            }

            if (level > 1) {
                pushDown[level] += pushValue;
            } else {
                adminFee += pushValue;
            }
        }

        if (adminFee > 0) {
            (pushWallet.send(adminFee));
            adminFee = 0;
        }

        // выплата реферальных вознаграждений
        address upline = users[account].referrer;
        for (uint8 j = 0; j < 3; j++) {
            if (upline != address(0)) {
                uint256 refBonus = value * gameRefPercents[j] / PERCENTS_DIVIDER;

                // если у аплайна куплен хотя бы 1 слот на этом же уровне, то он получает реф.бонус. иначе - нет
                if (users[upline]._slots[level] > 0) {
                    users[upline]._gameRefBonuses[level] += refBonus;
                    (payable(upline).send(refBonus));
                    emit RefPayment(upline, j, account, refBonus);
                } else {
                    adminFee += refBonus;
                }

                upline = users[upline].referrer;
            } else {
                for (uint256 k = j; k < 3; k++) {
                    adminFee += value * gameRefPercents[k] / PERCENTS_DIVIDER;
                }
                break;
            }
        }

        (refWallet.send(adminFee));
    }

    function getSiteInfo() external view returns(
        uint256[11] memory amt, // число купленных слотов
        uint256[11] memory time
    ) {
        for (uint256 i; i < 11; i++) {
            uint siteStartTime = (startDateUnix + times[i]);
            time[i] = block.timestamp < siteStartTime ? siteStartTime : 0; // siteStartTime - block.timestamp
            amt[i] = data[i].length;
        }
    }

    function getUserInfo(address account) external view returns(
        uint256[11] memory slots, 
        uint256[11] memory slotsClosed, 
        uint256[11] memory rewards, 
        uint256[11] memory invested, 
        address[3] memory referrers, 
        uint256[3] memory referrals, 
        uint256[11] memory gameRefBonuses
    ) {
        User storage user = users[account];

        slots = user._slots;
        slotsClosed = user._slotsClosed;
        rewards = user._rewards;

        for (uint256 i; i < 11; i++) {
            invested[i] = user._slots[i] * prices[i];
        }

        referrers[0] = user.referrer;
        referrers[1] = users[referrers[0]].referrer;
        referrers[2] = users[referrers[1]].referrer;

        referrals = user.referals;
        gameRefBonuses = user._gameRefBonuses;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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