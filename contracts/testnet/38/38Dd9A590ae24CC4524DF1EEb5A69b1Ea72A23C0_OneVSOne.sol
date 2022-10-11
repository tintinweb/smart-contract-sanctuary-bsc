// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./extensions/ScoreSetter.sol";
import "./RefTracker.sol";
struct Game {
    address playerOne;
    address playerTwo;
    uint256 playerOneScore;
    uint256 playerTwoScore;
    uint256 playerOneBet;
    uint256 playerTwoBet;
    address winner;
    bool closed;
}

contract OneVSOne is ScoreSettable{
    Game[] public games;
    uint256 public gamesCount;

    address refTracker;

    event GameCreated(uint256 id);
    event ScoreSetted(uint256 id, address player, uint256 amount);
    event BetSet(uint256 id, address player, uint256 amount);

    constructor(address _refTracker,address scoreSetter) ScoreSettable(scoreSetter) {
        refTracker = _refTracker;
    }

    function createGame(address playerOne, address playerTwo, address ref) public {
        RefTracker _refTracker = RefTracker(refTracker);
        if(_refTracker.Ref(playerOne) == address(0x0)) {
            _refTracker.setRef(playerOne, ref);
        }

        if(_refTracker.Ref(playerTwo) == address(0x0)) {
            _refTracker.setRef(playerTwo, ref);
        }

        Game memory game;
        game.playerOne = playerOne;
        game.playerTwo = playerTwo;
        games.push(game);
        emit GameCreated(gamesCount);
        gamesCount++;
    }

    function setPlayerOneBet(uint256 id) external payable {
        require(games[id].playerOne == msg.sender,"GAMING ARCADE: SENDER IS NOT PLAYER ONE");
        require(msg.value > 0);
        games[id].playerOneBet = msg.value;
        emit BetSet(id, msg.sender, msg.value);
    } 

    function setPlayerTwoBet(uint256 id) external payable {
        require(games[id].playerTwo == msg.sender,"GAMING ARCADE: SENDER IS NOT PLAYER TWO");
        require(msg.value > 0);
        games[id].playerTwoBet = msg.value;
        emit BetSet(id, msg.sender, msg.value);
    } 

    function setPlayerOneScore(uint256 id, uint256 score) public onlyScoreSetter {
        require(score!=0);
        require(!games[id].closed);
        games[id].playerOneScore = score;
        if(games[id].playerTwoScore != 0 && games[id].playerOneScore > games[id].playerTwoScore ) {
            games[id].winner = games[id].playerOne;
            games[id].closed = true;
            _payout(id, games[id].playerOne);
        }
        else if(games[id].playerTwoScore != 0 && games[id].playerTwoScore > games[id].playerOneScore ) {
            games[id].winner = games[id].playerTwo;
            games[id].closed = true;
            _payout(id, games[id].playerTwo);
        }
        emit ScoreSetted(id, games[id].playerOne, score);
    }

    function setPlayerTwoScore(uint256 id, uint256 score) public onlyScoreSetter {
        require(score!=0);
        require(!games[id].closed);
        games[id].playerTwoScore = score;
        if(games[id].playerOneScore != 0 && games[id].playerOneScore > games[id].playerTwoScore ) {
            games[id].winner = games[id].playerOne;
            games[id].closed = true;
            _payout(id, games[id].playerOne);
        }
        else if(games[id].playerOneScore != 0 && games[id].playerTwoScore > games[id].playerOneScore ) {
            games[id].winner = games[id].playerTwo;
            games[id].closed = true;
            _payout(id, games[id].playerTwo);
        }
        emit ScoreSetted(id, games[id].playerTwo, score);
    }

    function _payout(uint256 id, address winner) internal {
        RefTracker _refTracker = RefTracker(refTracker);
        (uint256 refAmount, uint256 remaining) = _refTracker.estimatePayout(winner, msg.value);
        _refTracker.payout{value:(games[id].playerOneBet+games[id].playerTwoBet)}(winner);
        winner.call{value:remaining}("");
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

abstract contract ScoreSettable {
    address private scoreSetter;

    constructor(address _scoreSetter) {
        scoreSetter = _scoreSetter;
    } 
    modifier onlyScoreSetter() {
        require(msg.sender==scoreSetter,"Mintable: Caller not Score setter");
        _;
    }


    function setScoreSetter(address _scoreSetter) internal {
        scoreSetter = _scoreSetter;
    }

    function ScoreSetter() public view returns (address) {
        return scoreSetter;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

abstract contract Playable {
    address private multiplayer;
    address private oneVSOne;
    address private tournament;

    function setAddresses(address _multiplayer, address _oneVSOne, address _tournament ) internal {
        multiplayer = _multiplayer;
        oneVSOne = _oneVSOne;
        tournament = _tournament;
    } 
    modifier onlyPlayableContract() {
        require(msg.sender==multiplayer || msg.sender == oneVSOne || msg.sender == tournament,"Playable: Caller not Playable contract");
        _;
    }


    /*function setPlayableContract(address _playableContract) internal {
        playableContract = _playableContract;
    }*/

    function Multiplayer() public view returns (address) {
        return multiplayer;
    }

    function OneVSOne () public view returns (address) {
        return oneVSOne;
    }

    function Tournament() public view returns (address) {
        return tournament;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./extensions/Playable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RefTracker is Playable,Ownable {
        mapping(address =>  address) public parentsTree;
        bool public isSetup;

        event PaidReferral(address ref, uint256 val);

        function setAddressesOnSetup(address _multiplayer, address _oneVSOne, address _tournament) public onlyOwner {
            setAddresses(_multiplayer, _oneVSOne, _tournament);
        }

        function setRef(address parent, address user) public {
            if(parentsTree[user] == address(0x0)) {
                parentsTree[user] = parent;
            }

        }

        function payout(address user) public payable onlyPlayableContract {
            uint256 val = msg.value;
            uint256 sentVal;
            address parent = parentsTree[user];
            bool success;

            if(parent!=address(0x0)) {
                val = msg.value/20;
                (success,) = parent.call{value:val}("");
                emit PaidReferral(parent, val);
                sentVal += val;
                parent = parentsTree[parent];
            } else {
                (success,) = msg.sender.call{value:msg.value-sentVal}("");
                return;
            }

            if(parent!=address(0x0)) {
                val = msg.value*3/100;
                (success,) = parent.call{value:val}("");
                emit PaidReferral(parent, val);
                sentVal += val;
                parent = parentsTree[parent];
            } else {
                (success,) = msg.sender.call{value:msg.value-sentVal}("");
                return;
            }

            if(parent!=address(0x0)) {
                val = msg.value/50;
                (success,) = parent.call{value:val}("");
                emit PaidReferral(parent, val);
                sentVal += val;
                parent = parentsTree[parent];
            } else {
                (success,) = msg.sender.call{value:msg.value-sentVal}("");
                return;
            }

            if(parent!=address(0x0)) {
                val = msg.value/200;
                (success,) = parent.call{value:val}("");
                emit PaidReferral(parent, val);
                sentVal += val;
                val = msg.value/100;
                parent = parentsTree[parent];
            } else {
                (success,) = msg.sender.call{value:msg.value-sentVal}("");
                return;
            }

            if(parent!=address(0x0)) {
                val = msg.value/200;
                (success,) = parent.call{value:val}("");
                emit PaidReferral(parent, val);
                sentVal += val;
                parent = parentsTree[parent];
            } else {
                (success,) = msg.sender.call{value:msg.value-sentVal}("");
                return;
            }

        }

        function Ref(address user) public view returns (address) { return parentsTree[user]; }

        function estimatePayout(address user, uint256 amount) external view returns (uint256, uint256) {
            uint256 val = amount;
            uint256 sentVal;
            address parent = parentsTree[user];

            if(parent!=address(0x0)) {
                sentVal += val;
                val = amount/20;
                parent = parentsTree[parent];
            } else {
                return (val, sentVal);
            }

            if(parent!=address(0x0)) {
                sentVal += val;
                val = amount*3/100;
                parent = parentsTree[parent];
            } else {
                return (val, sentVal);
            }

            if(parent!=address(0x0)) {
                sentVal += val;
                val = amount/50;
                parent = parentsTree[parent];
            } else {
                return (val, sentVal);
            }

            if(parent!=address(0x0)) {
                sentVal += val;
                val = amount/100;
                parent = parentsTree[parent];
            } else {
                return (val, sentVal);
            }

            if(parent!=address(0x0)) {
                sentVal += val;
                val = amount/200;
                parent = parentsTree[parent];
            } else {
                return (val, sentVal);
            }

            return (sentVal, amount - sentVal);

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