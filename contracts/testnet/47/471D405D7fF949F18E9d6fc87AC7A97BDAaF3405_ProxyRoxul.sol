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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import './interface/IEventRoxul.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract EventRoxul is IEventRoxul, Ownable {
    uint256 public timeCloseBet;
    uint256 public timeStart;
    uint256 public timeLastTransaction;
    uint256 public bet;
    uint256 public balance;
    uint256 public betId = 0;

    bool public status;

    mapping(address => uint256) public userBetTime;
    mapping(address => uint256) public userBetId;
    mapping(uint256 => address) public betIdUser;
    mapping(uint256 => uint256) public betBalance;

    constructor() {}

    function setStatus(bool _status) external onlyOwner {
        status = _status;
        timeLastTransaction = 0;

    }

    function setParam(
        uint256 _timeStart,
        uint256 _timeCloseBet,
        uint256 _bet
    ) external override onlyOwner {
        timeStart = _timeStart;
        timeCloseBet = _timeCloseBet;
        bet = _bet;
        status = true;
        timeLastTransaction = 0;
    }

    function deposit(address userAddress) external payable override onlyOwner {
        require(status, 'Event dont start');
        require(block.timestamp >= timeStart, 'Event dont start');
        require(
            block.timestamp <= timeLastTransaction + timeCloseBet || timeLastTransaction < 1,
            'Event alredy closed'
        );
        require(msg.value >= bet, 'Payment bet is incorrect');

        userBetTime[userAddress] = block.timestamp;
        userBetId[userAddress] = betId;
        betIdUser[betId] = userAddress;
        betBalance[betId] = address(this).balance;
        timeLastTransaction = block.timestamp;
        betId++;
    }

    function claimReward(address userAddress) external override onlyOwner {
        require(betBalance[userBetId[userAddress]] > 0, "You alredy claim");
        require(block.timestamp > timeLastTransaction + timeCloseBet, 'Event don`t stop');
        require(betIdUser[betId - 1] == userAddress, 'You dont winner');

        (bool success, ) = (userAddress).call{value: betBalance[betId - 1]}('');
        betBalance[betId - 1] = 0;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IEventRoxul {
    function setParam(uint256 _timeStart, uint256 _timeCloseBet, uint256 _bet) external;

    function setStatus(bool status) external;

    function deposit(address userAddress) external payable;

    function claimReward(address userAddress) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IProxyRoxul {
    struct User {
        uint256 id;
        address refAddress;
        uint256 typeRef; //Basic - 0, Angel - 1, Demigod - 2, God - 3
    }

    event CreateTable(uint256 numberTable, address table);

    event Registration(address user, address referrer, uint256 userId);

    event AddTypeReferrer(address userReferrer, uint256 typeReferrer);

    function addTypeReferrer(address userAddress, uint256 typeReferrer) external;

    function setOption(uint256 numberTable, uint256 _time, bool _lock, bool _eventTable) external;

    function createTable(address _secWallet, address _eventAddress, uint256 _BasicPrice) external;

    function createEvent() external;

    function buyPlace(uint256 numberTable) external payable;

    function betEvent(uint256 numberEvent) external payable;

    function claimRewardEvent(uint256 numberEvent) external;

    function claimRewardShrink(uint256 numberTable, uint256 countShrink) external;

    function startEvent(
        uint256 numberEvent,
        uint256 _timeStart,
        uint256 _timeCloseBet,
        uint256 _bet
    ) external;

    function registr(address _referrerAddress) external payable;

    function isUserExists(address user) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IRoxulExpressBasic {
    struct ShrinkWinner {
        uint256 countLevel;
        uint256 levelLastCompression;
        uint256 random;
        uint256 balance;
        uint256 countWinner;
        uint256 countGamer;
        uint256 countClaimReward;
    }

   
    event BuyNewPlace(
        address indexed user,
        address indexed referrer,
        uint256 level,
        uint256 place
    );

    event Shrink(
        address indexed user,
        uint256 shrinkId
    );

    event ClaimShrinkReward(
        address indexed user,
        uint256 shrinkId,
        uint256 amount

    );
    


    function buyNewPlace(address userAddress, address refAddress, uint256 typeRef) external payable;

    function withdrawLostTokens() external returns (bool);

    function claimShrinkReward(address userAddress, uint256 countShrink) external returns(bool);

    function setTimeStart(uint256 _time) external;

    function setLocked(bool _lock) external;

    function setEventTable(bool _eventTable) external;

    // function paymentID(uint256 level) external view returns (uint256 pay_id);

    // function levelReport(uint256 level) external view returns (uint256 paid, uint256 onwait);

    // function AllLevelReport() external view returns (uint256[] memory);

    // function ReferrerIncome(address _user) external view returns (uint256[] memory);

    // function getContractBalance() external view returns (uint256);

    // function usersactiveMainLevels(address userAddress, uint256 level) external view returns (bool);

    // function allLevelUserCount() external view returns (uint256[] memory);

    // function TotalLevelUserCount(uint256 level) external view returns (uint256 count);

    // function isBoughtLevel(address userAddress) external view returns (bool[] memory);

    // function UserRewards(address userAddress) external view returns (uint64[] memory);

    // function ProgressID(address userAddress) external view returns (uint64[] memory);

    // function UserLevelPlace(address userAddress) external view returns (uint256[] memory);

    // function totalIncome() external view returns (uint256 sum);

    // function timeToOpenLevel(uint256 level) external view returns (uint256 time);

    // function timeLeftToOpenLevel(uint256 level) external view returns (uint256 time);

    // function listOfLevelOpenTime() external view returns (uint256[] memory);

    // function userPaymentCount(address _user) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import 'hardhat/console.sol';

import '@openzeppelin/contracts/access/Ownable.sol';
import './RoxulExpress.sol';
import './EventRoxul.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './interface/IProxyRoxul.sol';

contract ProxyRoxul is IProxyRoxul, Ownable, ReentrancyGuard {
    uint256 public regFee;
    address public secWallet;
    address public regWallet;
    uint256 public lastUserId = 1;

    mapping(uint256 => uint256) priceTable;
    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    mapping(address => bool) userInTable;

    address[] public roxulExp;
    address[] public eventRox;

    constructor(uint256 _regFee, address _secWallet, address _regWallet) {
        regFee = _regFee;
        secWallet = _secWallet;
        regWallet = _regWallet;
    }

    // function getAddressTable(uint256 numberTable) external view returns(address){
    //     return address(roxulExp[numberTable]);
    // }

    function addTypeReferrer(
        address userAddress,
        uint256 typeReferrer
    ) external override onlyOwner {
        require(typeReferrer >= 0 && typeReferrer < 4, 'Incorrect type Referrer');
        User storage user = users[userAddress];
        user.typeRef = typeReferrer;
        emit AddTypeReferrer(userAddress, typeReferrer);
    }

    function createTable(
        address _secWallet,
        address _eventAddress,
        uint256 _BasicPrice
    ) external override onlyOwner {
        RoxulExpress roxulExpress = new RoxulExpress(_secWallet, _BasicPrice, _eventAddress);
        address _addressTable  = address(roxulExpress);
        roxulExp.push(_addressTable);
        // console.log()
        priceTable[roxulExp.length - 1] = _BasicPrice;
        emit CreateTable( roxulExp.length - 1, _addressTable);

    }

    function buyPlace(uint256 numberTable) external payable override nonReentrant {
        require(msg.value >= priceTable[numberTable], 'Wrong value');
        require(isUserExists(msg.sender), 'User not registered');
        IRoxulExpressBasic roxul = IRoxulExpressBasic(roxulExp[numberTable]);
        User memory user = users[msg.sender];
        User memory ref = users[user.refAddress];
        roxul.buyNewPlace{value: msg.value}(msg.sender, user.refAddress, ref.typeRef);
        userInTable[msg.sender] = true;
    }

    function createEvent() external override onlyOwner {
        EventRoxul eventRoxul = new EventRoxul();
        eventRox.push(address(eventRoxul));

    }

    function startEvent(
        uint256 numberEvent,
        uint256 _timeStart,
        uint256 _timeCloseBet,
        uint256 _bet
    ) external override onlyOwner {
        IEventRoxul eventRoxul = IEventRoxul(eventRox[numberEvent]);
        eventRoxul.setParam(_timeStart, _timeCloseBet, _bet);
    }

    function registr(address _referrerAddress) public payable override {
        require(!isUserExists(msg.sender), 'User alredy registred');
        require(msg.sender != _referrerAddress, "Error: incorrect referrer");
        require(msg.value >= regFee, 'Wrong value');
        address referrerAddress = isUserExists(_referrerAddress) ? _referrerAddress : secWallet;
        User storage user = users[msg.sender];
        user.id = lastUserId;
        user.refAddress = referrerAddress;
        user.typeRef = 0;

        idToAddress[lastUserId] = msg.sender;

        lastUserId++;
        sendRegFee();
        emit Registration(msg.sender, referrerAddress, user.id);
    }

    function setOption(uint256 numberTable, uint256 _time, bool _lock, bool _eventTable) external onlyOwner {
        IRoxulExpressBasic roxul = IRoxulExpressBasic(roxulExp[numberTable]);
        roxul.setTimeStart(_time);
        roxul.setLocked(_lock);
        roxul.setEventTable(_eventTable);
    }

    function betEvent(uint256 numberEvent) external payable nonReentrant {
        require(userInTable[msg.sender], 'User dont at table');
        IEventRoxul eventRoxul = IEventRoxul(eventRox[numberEvent]);
        eventRoxul.deposit{value: msg.value}(msg.sender);
    }

    function claimRewardEvent(uint256 numberEvent) external override {
        require(userInTable[msg.sender], 'User dont at table');
        IEventRoxul eventRoxul = IEventRoxul(eventRox[numberEvent]);
        eventRoxul.claimReward(msg.sender);
    }

    function claimRewardShrink(uint256 numberTable, uint256 countShrink) external {
        IRoxulExpressBasic roxul = IRoxulExpressBasic(roxulExp[numberTable]);
        roxul.claimShrinkReward(msg.sender, countShrink);
    }

    function isUserExists(address user) public view override returns (bool) {
        return (users[user].id != 0);
    }

    function sendRegFee() private returns (bool) {
        (bool success, ) = regWallet.call{value: regFee}('');

        return success;
    }

    receive() external payable {}
    
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import './interface/IRoxulExpressBasic.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract RoxulExpress is IRoxulExpressBasic, Ownable {
    uint256 public countLevel = 0;
    uint256 public countPlace = 1;
    uint256 public levelCompression;
    uint256 public timeCompression;
    uint256 public timeLastLevel;
    uint256 public shrinkReward;
    uint256 public idShrink = 0;
    uint256 public timeStart;
    uint256 public lastUserId;
    uint256 public BasicPrice;

    bool locked;
    bool eventTable;

    mapping(uint256 => mapping(uint256 => address)) public levelTable;
    mapping(address => mapping(uint256 => uint256)) public userLevel;
    mapping(uint256 => ShrinkWinner) public idShrinkWinner;
    mapping(uint256 => mapping(address => bool)) public isClaimReward;

    mapping(uint256 => uint256) public levelPlaces;

    address public secWallet;
    address public eventWallet;

    uint256[] public paymentPercent;

    constructor(address _secWallet, uint256 _BasicPrice, address _eventWallet) {
        BasicPrice = _BasicPrice;

        secWallet = _secWallet;
        eventWallet = _eventWallet;

        paymentPercent.push((_BasicPrice * 13) / 100);
        paymentPercent.push((_BasicPrice * 8) / 100);
        paymentPercent.push((_BasicPrice * 5) / 100);
        paymentPercent.push((_BasicPrice * 13) / 100);
        paymentPercent.push((_BasicPrice * 17) / 100);
        paymentPercent.push((_BasicPrice * 26) / 100);

        locked = true;
    }

    function setTimeStart(uint256 _time) external override onlyOwner {
        timeStart = _time;
    }

    function setLocked(bool _lock) external override onlyOwner {
        locked = _lock;
    }

    function setEventTable(bool _eventTable) external override onlyOwner {
        eventTable = _eventTable;
    }

    function buyNewPlace(
        address userAddress,
        address refAddress,
        uint256 typeRef
    ) external payable override onlyOwner {
        require(block.timestamp > timeStart, 'Table is locked');
        require(!locked, 'Table is locked');
        if (countLevel > 0) {
            require(!(userLevel[userAddress][countLevel - 1] > 0), 'User at the previous level');
        }
        require(!(userLevel[userAddress][countLevel] > 0), 'User at the level');

        
        levelPlaces[countLevel] = countPlace;
        levelTable[countLevel][countPlace] = userAddress;
        userLevel[userAddress][countLevel] = countPlace;
        sendDividends(countLevel);
        payReferrer(refAddress, typeRef);

        emit BuyNewPlace(userAddress, refAddress, countLevel, countPlace);

        countPlace++;
        
        if (
            (countLevel - levelCompression < 7) ||
            (block.timestamp < timeLastLevel + timeCompression)
        ) {
            if (countPlace > 2 ** (countLevel - levelCompression)) {
                countLevel++;
                countPlace = 1;
                timeCompression = ((block.timestamp - timeLastLevel) * 25) / 10;
                timeLastLevel = block.timestamp;
            }
        } else {
            uint256 countGamer = 2 ** (countLevel - levelCompression - 1) +
                (levelPlaces[countLevel]) /
                2;

            uint256 countWinner = countGamer % 100 > 0 ? countGamer / 100 + 1 : countGamer / 100;
            uint256 randomPlace = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));

            ShrinkWinner storage winner = idShrinkWinner[idShrink];
            winner.balance = shrinkReward;
            winner.countLevel = countLevel;
            winner.levelLastCompression = levelCompression;
            winner.countGamer = countGamer;
            winner.random = randomPlace;
            winner.countWinner = countWinner;
            shrinkReward = 0;
            levelCompression = countLevel + 1;

            if (!eventTable) {
                countLevel++;
                countPlace = 1;
                timeCompression = ((block.timestamp - timeLastLevel) * 25) / 10;
                timeLastLevel = block.timestamp;
                levelPlaces[countLevel] = countPlace;
                levelTable[countLevel][countPlace] = userAddress;
                userLevel[userAddress][countLevel] = countPlace;
                emit BuyNewPlace(userAddress, refAddress, countLevel, countPlace);
            } else {
                countPlace = 1;
                locked = true;
            }
            countLevel++;
            emit Shrink(userAddress, idShrink);
            idShrink++;

        }
        
    }

    function sendDividends(uint256 level) internal returns (bool success) {
        address userSend = ((level - levelCompression) < 1)
            ? secWallet
            : levelTable[level - 1][(countPlace + 1) / 2];
        uint256 mainPercent = (BasicPrice * 72) / 100;
        (success, ) = (userSend).call{value: mainPercent}('');
        (success, ) = (eventWallet).call{value: BasicPrice / 100}('');
        shrinkReward += BasicPrice / 100;
        return success;
    }

    function withdrawLostTokens() public override onlyOwner returns (bool) {
        uint256 conbalance = address(this).balance;

        (bool success, ) = (secWallet).call{value: conbalance}('');

        return success;
    }

    function payReferrer(
        address referalAddress,
        uint256 typeRef
    ) internal returns (bool success) {
        if (referalAddress != address(secWallet)) {
            if (typeRef < 1) {
                uint256 countPay = countLevel - levelCompression < 3 ? countLevel - levelCompression : 3;
                uint256 unpaidRef = 0;
                for (uint256 index = 1; index < countPay + 1; index++) {
                    if (userLevel[referalAddress][countLevel - index] > 0) {
                        unpaidRef += paymentPercent[index - 1];
                        (success, ) = referalAddress.call{value: paymentPercent[index - 1]}('');
                    }                    
                }
                (success, ) = secWallet.call{value: BasicPrice * 26 / 100 - unpaidRef}('');
            } else {
                (success, ) = referalAddress.call{value: paymentPercent[2 + typeRef]}('');
                (success, ) = secWallet.call{
                    value: ((BasicPrice * 26) / 100 - paymentPercent[2 + typeRef])
                }('');
            }
        } else {
            (success, ) = secWallet.call{value: (BasicPrice * 26) / 100}('');
        }

        return success;
    }

    function claimShrinkReward(address userAddress, uint256 countShrink) external onlyOwner returns(bool success) {
        ShrinkWinner storage winner = idShrinkWinner[countShrink];
        require(!isClaimReward[countShrink][userAddress], 'User Alredy claimed reward!!!');
        // require((winner.countClaimReward < winner.countWinner), 'All Alredy claim reward!!!');
        require(checkWinner(userAddress, winner.countLevel, winner.levelLastCompression, winner.countGamer, winner.countWinner, winner.random), 'User don`t winner');
        (success, ) = (userAddress).call{value: winner.balance / winner.countWinner}('');
        isClaimReward[countShrink][userAddress] = true;
        winner.countClaimReward++;
        if (winner.countClaimReward > winner.countWinner - 1) {
            winner.balance = 0;
        }

        return success;
    }

    function checkWinner(
        address userAddress,
        uint256 level,
        uint256 levelLastComp,
        uint256 countGamer,
        uint256 countWinner,
        uint256 rand
    ) public view returns (bool success) {
        uint256 levelUser;

        if (userLevel[userAddress][level] > 0) {
            levelUser = level;
        } else if (userLevel[userAddress][level- 1] > (levelPlaces[level]) / 2)  {
            levelUser = level- 1;
        } else {
            return false;
        }

        uint256 step = countGamer / countWinner;

        uint256 random = rand % step;

        if (level- levelLastComp - 1 == levelUser ) {
            
            uint256 placeUser = userLevel[userAddress][levelUser] - (levelPlaces[levelUser + 1]) / 2 - 1;

            if( placeUser >= random) {
                success =
                    (placeUser - random)  % step == 0;
            }else {
                success = false;
            }
        } else {
            uint256 placeUser = 2 ** (level- levelLastComp - 1) +
                                userLevel[userAddress][levelUser] -
                                (levelPlaces[levelUser]) / 2 - 1;

            if( placeUser >= random) {
                success = (placeUser - random) % step == 0;
            }else {
                success = false;
            }
            
        }

        return success;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

}