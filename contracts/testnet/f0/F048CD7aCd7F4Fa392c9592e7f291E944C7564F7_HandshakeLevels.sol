// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IDexGoStorage.sol";


/// @custom:security-contact [email protected]

/*
В сети действует правило шести рукопожатий для девяти друзей и правило бонуса за приглашение. После первого прохождения каждый, кто прошел маршрут, имеет возможность пригласить еще друзей. Первые девять человек становятся друзьями первого рукопожатия. После того как первое рукопожатие заполнено, все приглашенные попадают на уровни второго рукопожатия, и так до последнего уровня, что составляет 531441 человек (c каждого из них получает доход первый пригласивший)
Вне зависимости от распределения и количества приглашенных каждый вами приглашенный человек регистрируется за вами для получения бонуса за приглашение
50% суммы от любой покупки, совершенная на любом уровне, распределяется на шесть рукопожатий вверх.
Ближайший друг, который вас пригласил, получает 15% от покупки как бонус за приглашение.
Каждый следующий уровень получает соответственно 8% - 7% - 6% - 5% - 5% 4%  от покупки. Допустим трасса пройдена, и выплата  $100 за прохождение. Ближайший друг, который вас пригласил получит $15, остальные пригласившие получат  соответственно $8 - $7 - $6 - $5 - $5 - $4
Бонусы автоматически переводятся на кошельки участников при покупке (но только для друзей, которые совершили одну и более покупок в месяц)

*/
contract HandshakeLevels is Ownable {
    address public storageContract;
    function setStorageContract(address _storageContract) public onlyOwner {
        storageContract = _storageContract;
    }
    function getStorageContract() public view returns (address) {
        return storageContract;
    }

    uint public maxMembersInLevel = 9;
    uint public maxLevels = 6;

    using SafeMath for uint256;

    mapping(uint8 => uint) public percentPerLevelWei;
    function getPercentPerLevelWei(uint8 position) public view returns (uint) {
        return percentPerLevelWei[position];
    }
    function setPercentPerLevelWei(uint8 position, uint percent) public onlyOwner {
        percentPerLevelWei[position] = percent;
    }
    uint public percentPerInvitationBonusWei = 0.15 ether;
    function getPercentPerInvitationBonusWei() public view returns (uint) {
        return percentPerInvitationBonusWei;
    }
    function setPercentPerInvitationBonusWei(uint percent) public onlyOwner {
        percentPerInvitationBonusWei = percent;
    }

    mapping(address => uint) public fullList;
    function getFullList(address wallet) public view returns (uint) {
        return fullList[wallet];
    }
    uint public countTotal = 0;

    mapping(uint => address) public fullListBack;
    function getFullListBack(uint position) public view returns (address) {
        return fullListBack[position];
    }
    mapping(address => address) public fullListBackAddress;
    function getFullListBack(address wallet) public view returns (address) {
        return fullListBackAddress[wallet];
    }
    mapping(address => address[]) public level0;
    function getLevel0(address wallet) public view returns (address[] memory) {
        return level0[wallet];
    }

    mapping(uint => uint) public fullListCounts; // last digit always 0, represent count for a line
    function getFullListCounts(uint position) public view returns (uint) {
        return fullListCounts[position];
    }


    constructor(address _storageContract) {
        storageContract =_storageContract;
        percentPerLevelWei[0] = 0.08 ether; // because getPercentPerLevelWei(x) started from 1 must start from 1
        percentPerLevelWei[1] = 0.08 ether;
        percentPerLevelWei[2] = 0.07 ether;
        percentPerLevelWei[3] = 0.06 ether;
        percentPerLevelWei[4] = 0.05 ether;
        percentPerLevelWei[5] = 0.05 ether;
        percentPerLevelWei[6] = 0.04 ether;
    }

    event SetHandshake(address indexed wallet, address indexed referrer, uint walletPosition, uint referrerPosition, bool isOverload, uint walletPositionCount);

    function setHandshake(address wallet, address referrer) public returns (uint, uint, bool, uint) {
        require(msg.sender == IDexGoStorage(storageContract).getNftContract() || msg.sender == owner() || msg.sender == IDexGoStorage(storageContract).getDexGo(),'HandshakeLevels: unauthorized sender');

        require(fullList[wallet] == 0,'HandshakeLevels: wallet already in graph');
        require(!Address.isContract(referrer),"HandshakeLevels: Invalid address");
        require(!Address.isContract(wallet),"HandshakeLevels: Invalid address");
        require(wallet != referrer,"HandshakeLevels: Invalid addresses");

        uint walletPosition;
        uint referrerPosition;
        bool isOverload = false;
        uint walletPositionCount;

        fullListBackAddress[wallet] = referrer;
        level0[referrer].push(wallet);

        if (fullList[referrer] == 0) {
            // level 0
            fullListCounts[0] = fullListCounts[0] + 1;
            walletPosition = fullListCounts[0];
            fullList[wallet] = walletPosition;
            fullListBack[walletPosition] = wallet;
        } else {
            referrerPosition = fullList[referrer];
            walletPosition = referrerPosition * 10;
            walletPositionCount = fullListCounts[walletPosition];
            if (walletPositionCount < maxMembersInLevel) {
                fullList[wallet] = walletPosition + walletPositionCount;
                countTotal++;
                fullListBack[walletPosition + walletPositionCount] = wallet;
                fullListCounts[walletPosition] = fullListCounts[walletPosition] + 1;
                walletPosition = walletPosition + walletPositionCount;
            } else {
                isOverload = true;
                while(true) {
                    walletPosition = walletPosition * 10;
                    walletPositionCount = fullListCounts[walletPosition];
                    if (fullListCounts[walletPosition] < maxMembersInLevel) {
                        fullList[wallet] = walletPosition + walletPositionCount;
                        countTotal++;
                        fullListBack[walletPosition + walletPositionCount] = wallet;
                        fullListCounts[walletPosition] = fullListCounts[walletPosition] + 1;
                        walletPosition = walletPosition + walletPositionCount;
                        break;
                    }
                }
            }
        }
        emit SetHandshake(wallet, referrer, walletPosition, referrerPosition, isOverload, walletPositionCount);

        return (walletPosition, referrerPosition, isOverload, walletPositionCount);
    }


    function getHandshakes(address wallet) public view returns (address[] memory, uint) {
        address[] memory levels =  new address [](maxLevels + 1);
        uint countLevels;
        levels[countLevels] = fullListBackAddress[wallet];
        countLevels++;

        uint returnNumForFill = fullList[wallet];
        if (returnNumForFill / 10 > 0) {
            while (returnNumForFill > 0) {
                returnNumForFill = returnNumForFill / 10;
                if (fullListBack[returnNumForFill] != address(0)) {
                    levels[countLevels] = fullListBack[returnNumForFill];
                    countLevels++;
                    if (countLevels -1 == maxLevels) break;
                }
            }
        }

        return (levels, countLevels);
    }

    function getHandshakesNextLevel(address wallet) public view returns (address[] memory, uint) {
        address[] memory members =  new address [](10);
        uint countMembers;

        uint positionNumber = fullList[wallet];
        uint positionNumberNextLine = positionNumber * 10;

        uint count;

        while (count < 10) {
            if (fullListBack[positionNumberNextLine] != address(0)) {
                members[countMembers] = fullListBack[positionNumberNextLine];
                countMembers++;
                positionNumberNextLine++;
            } else break;
            count++;
        }

        return (members, countMembers);
    }

    function _distributeMoney(address sender, uint value, bool isIOS, bool isUSDT) private returns (uint) {
        address[] memory friends;
        uint friendsCount;
        uint valueForFriendTotal = 0;
        if (!isIOS) {
            (friends, friendsCount) = getHandshakes(sender);
            // invitation bonus
            uint valueForFriend;
            if (friends[0] != address(0)) {
                valueForFriend = value * getPercentPerInvitationBonusWei() / 1 ether;
                if (isUSDT) IERC20(IDexGoStorage(storageContract).getUSDT()).transferFrom(sender, friends[0], valueForFriend);
                else Address.sendValue(payable(friends[0]), valueForFriend);
                valueForFriendTotal = valueForFriendTotal + valueForFriend;
            }
            for(uint8 x=1;x<friendsCount;x++) {
                if (friends[x] != address (0) && block.timestamp - IDexGoStorage(storageContract).getLatestPurchaseTime(friends[x]) < 60 * 60 * 24 * 30) { // must make at least one purchase per months to receive reward
                    valueForFriend = value * getPercentPerLevelWei(x) / 1 ether;
                    if (isUSDT) IERC20(IDexGoStorage(storageContract).getUSDT()).transferFrom(sender, friends[x], valueForFriend);
                    else Address.sendValue(payable(friends[x]), valueForFriend);
                    valueForFriendTotal = valueForFriendTotal + valueForFriend;
                }
            }
        }
        require(valueForFriendTotal <= value / 2, "Must be less 50%");

        uint partForRewards = value * 35 / 100;
        if (isUSDT) IERC20(IDexGoStorage(storageContract).getUSDT()).transferFrom(sender, IDexGoStorage(storageContract).getDexGo(), partForRewards);
        else Address.sendValue(payable(IDexGoStorage(storageContract).getDexGo()), partForRewards);

        uint valueForTeam = (value - valueForFriendTotal - partForRewards) ;
        if (isUSDT) IERC20(IDexGoStorage(storageContract).getUSDT()).transferFrom(sender, IDexGoStorage(storageContract).getAccountTeam1(), valueForTeam * 33 / 100);
        else Address.sendValue(payable(IDexGoStorage(storageContract).getAccountTeam1()), valueForTeam * 33 / 100);
        valueForTeam = valueForTeam - valueForTeam * 33 / 100;
        if (isUSDT) IERC20(IDexGoStorage(storageContract).getUSDT()).transferFrom(sender, IDexGoStorage(storageContract).getAccountTeam2(), valueForTeam * 33 / 100);
        else Address.sendValue(payable(IDexGoStorage(storageContract).getAccountTeam2()), valueForTeam * 33 / 100);
        valueForTeam = valueForTeam - valueForTeam * 33 / 100;
        if (isUSDT) IERC20(IDexGoStorage(storageContract).getUSDT()).transferFrom(sender, owner(), valueForTeam);
        else Address.sendValue(payable(owner()), valueForTeam);
        return (value - valueForFriendTotal - partForRewards);
    }

    function distributeMoney(address sender, uint value, bool isIOS, bool isUSDT) public returns (uint)  {
        require(msg.sender == IDexGoStorage(storageContract).getRentAndKm() || msg.sender == storageContract || msg.sender == IDexGoStorage(storageContract).getDexGo() || msg.sender == IDexGoStorage(storageContract).getNftContract(), "ORC");
        return _distributeMoney(sender, value, isIOS, isUSDT);
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        // custom function code
    }
}

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
interface IDexGoStorage {
    function getDexGo() external view returns (address);
    function getNftContract() external view returns (address);
    function getGameServer() external view returns (address);
    function getPriceForType(uint8 typeNft) external view returns (uint256);
    function setPriceForType(uint256 price, uint8 typeNft) external;
    function increaseCounterForType(uint8 typeNft) external;
    function setTypeForId(uint256 tokenId, uint8 typeNft)  external;
    function getPriceInitialForType(uint8 typeNft) external view returns (uint256);
    function getLatestPurchaseTime(address wallet) external view returns (uint256);
    function setLatestPurchaseTime(address wallet, uint timestamp) external;
    function valueInMainCoin(uint8 typeNft) external view returns (uint256);
    function getValueDecrease() external view returns(uint);
    function setInAppPurchaseData(string memory _inAppPurchaseInfo, uint tokenId) external;
    function getLatestPrice() external view returns (uint256, uint8);
    function getInAppPurchaseBlackListWallet(address wallet) external view returns(bool);
    function getInAppPurchaseBlackListTokenId(uint256 tokenId) external view returns(bool);
    function getImageForTypeMaxKm(uint8 typeNft) external view returns (string memory);
    function getDescriptionForType(uint8 typeNft) external view returns (string memory);
    function getNameForType(uint8 typeNft) external view returns (string memory);
    function getAccountTeam1() external view returns (address);
    function getAccountTeam2() external view returns (address);
    function getRentAndKm() external view returns (address);
    function getImageForType25PercentKm(uint8 typeNft) external view returns (string memory);
    function getImageForType50PercentKm(uint8 typeNft) external view returns (string memory);
    function getImageForType75PercentKm(uint8 typeNft) external view returns (string memory);
    function getTypeForId(uint256 tokenId) external view returns (uint8);
    function getIpfsRoot() external view returns (string memory);
    function getNamesChangedForNFT(uint _tokenId) external view returns (string memory);
    function tokenURI(uint256 tokenId)
    external
    view returns (string memory);
    function getHandshakeLevels() external view returns (address);
    function getPastContracts() external view returns (address [] memory);
    function getFixedAmountOwner() external view returns (uint256);
    function getFixedAmountProject() external view returns (uint256);
    function getMinRentalTimeInSeconds() external view returns (uint);
    function setKmForId(uint256 tokenId, uint256 km) external;
    function getKmLeavesForId(uint256 tokenId) external view returns (uint256);
    function getFixedRepairAmountProject() external view returns (uint256);
    function setRepairFinishTime(uint tokenId, uint timestamp) external;
    function getRepairCount(uint tokenId) external view returns (uint);
    function setRepairCount(uint tokenId, uint count) external;
    function getFixedApprovalAmount() external view returns (uint256);
    function getFixedPathApprovalAmount() external view returns (uint256);
    function setKmForPath(uint256 _tokenId, uint km) external;
    function getKmForPath(uint _tokenId) external view returns (uint);
    function getUSDT() external view returns (address);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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