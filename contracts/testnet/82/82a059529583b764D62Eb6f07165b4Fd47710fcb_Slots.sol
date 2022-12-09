pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./IWeeklyLottery.sol";
import "./IMonthlyLottery.sol";
import "./IRandomizer.sol";
import "./IStorage.sol";

contract Slots is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    uint256 public usersCounter;
    uint256 public gamesCounter;
    uint256 public totalBet;

    uint256 public calcFundsState;
    uint256 public LEAVE_COMISSION;

    uint256 public TENTH_USER_COMPENSATION;
    address comissionsAddress;
    address mainRefAddress;
    address public weeklyLottery;
    address public monthLottery;

    bool public canLeave;

    IRandomizer randomizer;

    mapping(address => UserProfile) public userProfiles;
    mapping(address => address) public referrers;
    mapping(address => mapping(uint256 => uint256)) public userStatuses;
    mapping(uint256 => uint256) public lastDrawBlock;

    mapping(string => address) public nicknamesToAddresses;
    mapping(string => bool) public nicknamesUsed;

    mapping(address => uint256) public usersMonthlyCounter;

    mapping(uint256 => Game) public games;
    mapping(uint256 => bool) public accceptedBets;


    struct UserProfile {
        string nickname;
        uint256 gamesPlayed;
        uint256 gamesWon;
        uint256 gamesLost;
        uint256 totalBet;
        uint256 totalWon;
        uint256 totalLost;
        uint256 totalRefEarn;
        bool isRegistered;
    }

    struct Game {
        uint256 id;
        uint256 timestamp;
        address[] players;
    }

    event GameStarted(uint256 gameId, uint256 bet);
    event GameFinished(
        uint256 gameId,
        uint256 bet,
        uint256 reward,
        uint256 lastDrawnBlock,
        address[7] winners,
        address[3] losers
    );
    event UserRegistered(address user, string nickname, address referrer);
    event UserCameIn(address user, uint256 bet, uint256 gameId);
    event UserLeave(address user, uint256 bet, uint256 gameId);
    event UserWon(address user, uint256 bet, uint256 gameId, uint256 reward);
    event UserLost(address user, uint256 bet, uint256 gameId);
    event RefPaid(address user, address referrer, uint256 amount);

    fallback() external payable {}

    receive() external payable {}

    function initialize(address _randomizer, address _comissionsAddress, address _mainReferrer)
        public
        initializer
    {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        randomizer = IRandomizer(_randomizer);
        comissionsAddress = _comissionsAddress;
        mainRefAddress = _mainReferrer;
        canLeave = true;
        TENTH_USER_COMPENSATION = 0.005 ether;
        LEAVE_COMISSION = 100; // 10000 = 100% 100 = 1%
    }

    function betControl(uint256 _bet, bool _accept) external onlyOwner {
        require(_bet > 0, "Slots::Bet must be greater than 0");
        accceptedBets[_bet] = _accept;
    }

    function leaveControl(bool _canLeave) external onlyOwner {
        canLeave = _canLeave;
    }

    function changeCommissionAddress(address _comissionsAddress)
        external
        onlyOwner
    {
        require(
            _comissionsAddress != address(0),
            "Slots::Address must be different than 0"
        );
        comissionsAddress = _comissionsAddress;
    }

    function changeMainRefAddress(address _mainRefAddress)
        external
        onlyOwner
    {
        require(
            _mainRefAddress != address(0),
            "Slots::Address must be different than 0"
        );
        mainRefAddress = _mainRefAddress;
    }

    function changeWeeklyLottery(address _weeklyLottery) external onlyOwner {
        require(
            _weeklyLottery != address(0),
            "Slots::Address must be different than 0"
        );
        weeklyLottery = _weeklyLottery;
    }

    function changeTenthUserCompenstion(uint256 _amount) external onlyOwner {
        TENTH_USER_COMPENSATION = _amount;
    }

    function changeLeaveComission(uint256 _percent) external onlyOwner {
        require(_percent <= 10000, "Slots::Percent cannot be greater than 100% (10000)");
        LEAVE_COMISSION = _percent;
    }

    function changeMonthLottery(address _month) external onlyOwner {
        require(_month != address(0), "Lottery:Slots address is zero");
        monthLottery = _month;
    }

    function changeRandomizer(address _randomizer) external onlyOwner {
        require(
            _randomizer != address(0),
            "Slots::Address must be different than 0"
        );
        randomizer = IRandomizer(_randomizer);
    }

    function getGame(uint256 _bet) public view returns (Game memory) {
        return games[_bet];
    }

    function getStatuses (address _user, uint256[] memory _bets) public view returns (uint256[] memory) {
        uint256[] memory statuses = new uint256[](_bets.length);
        for (uint256 i = 0; i < _bets.length; i++) {
            statuses[i] = userStatuses[_user][_bets[i]];
        }
        return statuses;
    }

    function register(string memory name, address _referrer) external {
        require(
            referrers[msg.sender] == address(0),
            "Slots::Already registered"
        );
        require(userProfiles[msg.sender].isRegistered == false, "Slots::Already registered");
        require(userProfiles[_referrer].isRegistered == true || _referrer == address(0), "Slots::Referrer is not registered");
        require(!nicknamesUsed[name], "Slots::Nickname already used");
        require(_referrer != msg.sender, "Slots::Cannot refer yourself");
        nicknamesToAddresses[name] = msg.sender;
        userProfiles[msg.sender].isRegistered = true;
        userProfiles[msg.sender].nickname = name;

        if (_referrer != address(0)) {
            referrers[msg.sender] = _referrer;
        } else {
            referrers[msg.sender] = mainRefAddress;
        }

        nicknamesUsed[name] = true;
        usersCounter++;

        emit UserRegistered(msg.sender, name, _referrer);
    }

    function comeIn(uint256 _bet) external payable whenNotPaused nonReentrant {
        require(userProfiles[msg.sender].isRegistered, "Slots::Not registered");
        require(accceptedBets[_bet], "Slots::Bet not accepted");
        require(msg.value == _bet, "Slots::Bet amount is not correct");
        uint8 freePlace = _findFreePlace(_bet);
        if (freePlace != 10 && freePlace != 0) {
            require(
                _reentryCheck(games[_bet].players),
                "Slots::Address already in game"
            );
        }
        if (freePlace == 10 || freePlace == 0) {
            _startAndComeIn(_bet);
            _updateUserStatus(msg.sender, _bet, true);
            emit UserCameIn(msg.sender, _bet, games[_bet].id);
        } else if (freePlace == 9) {
            emit UserCameIn(msg.sender, _bet, games[_bet].id);
            _endGame(_bet);
        } else {
            _comeIn(_bet, freePlace);
            _updateUserStatus(msg.sender, _bet, true);
            emit UserCameIn(msg.sender, _bet, games[_bet].id);
        }
        
        _updateUserStats(_bet);
        totalBet += _bet;
    }

    function leave(uint256 _bet) external nonReentrant {
        require(canLeave, "Slots::Cannot leave");
        require(accceptedBets[_bet], "Slots::Bet not accepted");
        uint8 freePlace = _findFreePlace(_bet);
        require(freePlace != 10 && freePlace != 0, "Slots::Game not started");
        require(
            !_reentryCheck(games[_bet].players),
            "Slots::Address not in game"
        );
        _leave(_bet);
        _updateUserStatus(msg.sender, _bet, false);

        emit UserLeave(msg.sender, _bet, games[_bet].id);
    }

    function reentryCheck(uint256 _bet, address _address)
        external
        view
        returns (bool)
    {
        Game memory game = games[_bet];
        address[] memory _players = game.players;
        for (uint8 i = 0; i < _players.length; i++) {
            if (_players[i] == _address) {
                return false;
            }
        }
        return true;
    }

    function getAmountOfPlayers(uint256 _bet)
        external
        view
        returns (uint256 amount)
    {
        Game memory game = games[_bet];
        address[] memory _players = game.players;
        if (_players.length == 0) {
            return 0;
        }
        for (uint8 i = 0; i < 10; i++) {
            if (_players[i] != address(0)) {
                amount++;
            }
        }
    }

    function _findFreePlace(uint256 _bet) internal view returns (uint8) {
        Game memory game = games[_bet];
        if (game.players.length == 0) {
            return 0;
        }
        for (uint8 i = 0; i < 10; i++) {
            if (game.players[i] == address(0)) {
                return i;
            }
        }
        return 10;
    }

    function _startAndComeIn(uint256 _bet) internal {
        gamesCounter++;

        Game memory game = Game(
            gamesCounter,
            block.timestamp,
            new address[](10)
        );
        games[_bet] = game;
        games[_bet].players[0] = msg.sender;
    }

    function _comeIn(uint256 _bet, uint8 _place) internal {
        Game storage game = games[_bet];
        game.players[_place] = msg.sender;
    }

    function _endGame(uint256 _bet) internal {
        Game storage game = games[_bet];
        game.players[9] = msg.sender;
        _calculateResults(_bet);
        lastDrawBlock[_bet] = block.number;
    }

    function _reentryCheck(address[] memory _players)
        internal
        view
        returns (bool)
    {
        for (uint8 i = 0; i < _players.length; i++) {
            if (_players[i] == msg.sender) {
                return false;
            }
        }
        return true;
    }

    function _updateUserStats(uint256 _bet) internal {
        UserProfile storage user = userProfiles[msg.sender];
        user.gamesPlayed++;
        user.totalBet += _bet;
    }

    function _updateUserStatus(address _user, uint256 _bet, bool _isInGame) internal {
        if (_isInGame) {
            userStatuses[_user][_bet] = games[_bet].id;
        } else {
            userStatuses[_user][_bet] = 0;
        }
    }

    function _calculateResults(uint256 _bet) internal {
        address[10] memory players = _sortPlayers(_bet);
        _payProcess(players, _bet);
    }

    function _sortPlayers(uint256 _bet)
        internal
        view
        returns (address[10] memory)
    {
        Game memory game = games[_bet];
        address[10] memory players;
        uint256 firstWinnerIndex = randomizer.random(game.id, 10, address(0));
        players[0] = game.players[firstWinnerIndex];

        address lastPlayer = game.players[firstWinnerIndex];
        uint256 counter;
        for (uint8 i = 1; i < 10; i++) {
            counter++;
            uint256 index = randomizer.random(counter, 10, lastPlayer);
            if (_checkAddressUnique(players, game.players[index])) {
                players[i] = game.players[index];
                lastPlayer = game.players[index];
            } else {
                i--;
            }
        }
        return (players);
    }

    function _checkAddressUnique(address[10] memory _arr, address _addr)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _arr.length; i++) {
            if (_arr[i] == _addr) {
                return false;
            }
        }
        return true;
    }

    function _payProcess(address[10] memory _players, uint256 _bet) internal {
        calcFundsState = _bet * 10;
        _returnBets(_players, _bet);
        _payRewardsAndUpdateStats(_players, _bet);
        _payReferrers(_players, _bet);
        _payWeeklyLottery(_bet);
        _payCompensation();
        _payComission();
    }

    function _returnBets(address[10] memory _players, uint256 _bet) internal {
        for (uint8 i = 0; i < 7; i++) {
            if (_players[i] != address(0)) {
                payable(_players[i]).transfer(_bet);
                calcFundsState -= _bet;
            }
        }
    }

    function _payRewardsAndUpdateStats(
        address[10] memory _players,
        uint256 _bet
    ) internal {
        IWeeklyLottery lottery = IWeeklyLottery(weeklyLottery);
        uint256 reward = _bet / 7;
        address[7] memory winners;
        address[3] memory losers;
        for (uint256 i = 0; i < 7; i++) {
            if (_players[i] != address(0)) {
                payable(_players[i]).transfer(reward);
                winners[i] = _players[i];
                calcFundsState -= reward;
                userProfiles[_players[i]].gamesWon++;
                userProfiles[_players[i]].totalWon += reward;
                _monthLotteryCheck(_players[i]);
                _updateUserStatus(_players[i], _bet, false);
                emit UserWon(_players[i], _bet, games[_bet].id, reward);
            }
        }
        for (uint256 i = 7; i < 10; i++) {
            if (_players[i] != address(0)) {
                lottery.addParticipant(_bet, _players[i]);
                losers[i - 7] = _players[i];
                userProfiles[_players[i]].gamesLost++;
                userProfiles[_players[i]].totalLost += _bet;
                _monthLotteryCheck(_players[i]);
                _updateUserStatus(_players[i], _bet, false);
                emit UserLost(_players[i], _bet, games[_bet].id);
            }
        }

        emit GameFinished(games[_bet].id, _bet, reward, lastDrawBlock[_bet], winners, losers);
    }

    function _payReferrers(address[10] memory _players, uint256 _bet) internal {
        uint256 referrersCount;
        for (uint256 i = 0; i < _players.length; i++) {
            if (referrers[_players[i]] != address(0)) {
                referrersCount++;
            }
        }
        if (referrersCount > 0) {
            uint256 reward = ((_bet * 7) / 10) / referrersCount;
            for (uint256 i = 0; i < _players.length; i++) {
                if (referrers[_players[i]] != address(0)) {
                    payable(referrers[_players[i]]).transfer(reward);
                    emit RefPaid(_players[i], referrers[_players[i]], reward);
                    calcFundsState -= reward;
                    userProfiles[referrers[_players[i]]].totalRefEarn += reward;
                }
            }
        }
    }

    function _payWeeklyLottery(uint256 _bet) internal {
        uint256 weeklyLotterySum = _bet / 2;
        (bool result, ) = weeklyLottery.call{value: weeklyLotterySum}("");
        IWeeklyLottery(weeklyLottery).recordTransfer(_bet, weeklyLotterySum);
        require(result, "Weekly lottery transfer failed");
        calcFundsState -= weeklyLotterySum;
    }

    function _payCompensation() internal {
        calcFundsState -= TENTH_USER_COMPENSATION;
        payable(msg.sender).transfer(TENTH_USER_COMPENSATION);
    }

    function _payComission() internal {
        payable(comissionsAddress).transfer(calcFundsState);
    }

    function _monthLotteryCheck(address _user) internal {
        if (usersMonthlyCounter[_user] == 6) {
            usersMonthlyCounter[_user] = 1;
            IMonthlyLottery(monthLottery).addParticipant(_user);
        } else if (usersMonthlyCounter[_user] == 0) {
            usersMonthlyCounter[_user]++;
            usersMonthlyCounter[_user]++;
        } else {
            usersMonthlyCounter[_user]++;
        }
    }

    function _leave(uint256 _bet) internal {
        Game storage game = games[_bet];
        UserProfile storage user = userProfiles[msg.sender];
        for (uint8 i = 0; i < 10; i++) {
            if (game.players[i] == msg.sender) {
                game.players[i] = address(0);
                uint256 returnedBet = (_bet * LEAVE_COMISSION) / 10000;
                payable(msg.sender).transfer(returnedBet);
                user.gamesPlayed--;
                user.totalBet -= _bet;
                break;
            }
        }
    }
}

pragma solidity ^0.8.0;

interface IWeeklyLottery {
    function addParticipant(uint256 _bet, address _participant) external;
    function recordTransfer(uint256 _bet, uint256 _amount) external;
}

pragma solidity ^0.8.0;

interface IStorage {
    function recordSlotPayment(
        uint256 _bet,
        uint256 _prize,
        address[7] memory _winners,
        address[3] memory _losers
    ) external;

    function recordWeeklyLotteryPayment(
        uint256 _bet,
        address[10] memory _winners,
        uint256[10] memory _prizes
    ) external;

    function recordMonthlyLotteryPayment(
        address[10] memory _winners,
        uint256[10] memory _prizes
    ) external;

    function recordRefPayment(address _user, address _referral, uint256 _amount) external;
}

pragma solidity ^0.8.0;

interface IRandomizer {
    function random(uint256 id, uint256 range, address _address)
        external
        view
        returns (uint256);
}

pragma solidity ^0.8.0;

interface IMonthlyLottery {
    function addParticipant(address _participant) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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