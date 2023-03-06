// SPDX-License-Identifier: UNLICENSED
/*

.---.  .---.     ,-----.    .-------. .-------.    ____     
|   |  |_ _|   .'  .-,  '.  \  _(`)_ \\  _(`)_ \ .'  __ `.  
|   |  ( ' )  / ,-.|  \ _ \ | (_ o._)|| (_ o._)|/   '  \  \ 
|   '-(_{;}_);  \  '_ /  | :|  (_,_) /|  (_,_) /|___|  /  | 
|      (_,_) |  _`,/ \ _/  ||   '-.-' |   '-.-'    _.-`   | 
| _ _--.   | : (  '\_/ \   ;|   |     |   |     .'   _    | 
|( ' ) |   |  \ `"/  \  ) / |   |     |   |     |  _( )_  | 
(_{;}_)|   |   '. \_/``".'  /   )     /   )     \ (_ o _) / 
'(_,_) '---'     '-----'    `---'     `---'      '.(_,_).'  
                                                            

Hoppa Hall of Fame

Keeps highscore of top 10 players on chain

You can put in any score, you are paying for the transaction

A 2D platform game by Moonshot & Ra8bits

Play: https://moonarcade.games/hoppa

Source: https://github.com/moonshot-platform/hoppa


*/

pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract HallOfFame is Ownable {

    modifier onlyGameMaker() {
        require( gameMakers[ msg.sender ], "Only Game Maker can call this function");
        _;
    }

    constructor() {
        
    }

    uint8 constant NUM_SCORES  = 10;

    struct HighScores {
        address player;
        uint256  score;
        string  initials;
    }

    HighScores[ NUM_SCORES ] public hallOfFame;
    mapping( address => bool ) public gameMakers;

    event HighscoreUpdated( string initials, uint256 score, address player );
    event HighscoreReset( address maker );
    event HighscoreRemoved( address maker , uint8 position );
    
    event GameMakerAdded( address maker );
    event GameMakerRemoved( address maker );
    
    function updateScore(string memory initials, uint256 score) public {
        uint8 position = getPosition(score);
        require( position < NUM_SCORES, "You didn't make it to the top 10");

        for(uint8 i = NUM_SCORES - 1; i > position; i -- ) {
            hallOfFame[i] = hallOfFame[i - 1];
        }

        hallOfFame[ position ] = HighScores(msg.sender, score, initials);

        emit HighscoreUpdated( hallOfFame[ position ].initials, hallOfFame[ position ].score, hallOfFame[ position ].player );
    }

    function removeScore(uint256 score) public onlyGameMaker {
        uint8 position = findScore(score);
        require( position < NUM_SCORES, "There is no such entry");

        for( uint8 i = position; i < (NUM_SCORES-1); i ++ ) {
            hallOfFame[i] = hallOfFame[i + 1];
        }

        hallOfFame[ (NUM_SCORES-1) ] = HighScores( address(0) , 0, "" );

        emit HighscoreRemoved( msg.sender, position );
    }

    function getHallOfFame() public view returns( HighScores[] memory ) {
        HighScores[] memory h = new HighScores[](NUM_SCORES);
        for( uint8 i = 0; i < NUM_SCORES; i ++ ) {
            HighScores storage r = hallOfFame[i];
            h[i] = r;
        }
        return h;
    }

    function clearHallOfFame() public onlyGameMaker {
        for( uint8 i = 0; i < NUM_SCORES; i ++ ) {
            hallOfFame[i] = HighScores( address(0),0, "");
        }

        emit HighscoreReset( msg.sender );
    }

    function addGameMaker( address gamemaker ) public onlyOwner {
        gameMakers[ gamemaker ] = true;

        emit GameMakerAdded( gamemaker );
    }

    function removeGameMaker( address gamemaker ) public onlyOwner {
        gameMakers[ gamemaker ] = false;

        emit GameMakerRemoved( gamemaker );
    }

    function getPosition(uint256 score) private view returns (uint8) {
        for( uint8 i = 0; i < NUM_SCORES; i ++ ) {
            if( score > hallOfFame[i].score ) {
                return i;
            }
        }
        return NUM_SCORES;
    }

    function findScore(uint256 score) private view returns (uint8) {
        for( uint8 i = 0; i < NUM_SCORES; i ++ ) {
            if( score == hallOfFame[i].score ) {
                return i;
            }
        }
        return NUM_SCORES;
    }
}