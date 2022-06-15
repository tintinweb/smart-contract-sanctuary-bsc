/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Oracle.sol


pragma solidity 0.8.13;


contract ResultOracle is Ownable {
    address[] private _judges = new address[](3);
    uint256 private constant NUMBER_OF_JUDGES = 3;

    bool[] private _eighthsRoundResult = new bool[](8);
    bool[] private _fourthRoundResult = new bool[](4);
    bool[] private _semifinalRoundResult = new bool[](2);
    bool private _finalRoundResult;

    mapping(address => bool[]) public _eighthsRoundDebate;
    mapping(address => bool[]) public _fourthRoundDebate;
    mapping(address => bool[]) public _semifinalRoundDebate;
    mapping(address => bool) public _finalRoundDebate;

    mapping(address => bool) private _eighthsRoundVoted;
    mapping(address => bool) private _fourthRoundVoted;
    mapping(address => bool) private _semifinalRoundVoted;
    mapping(address => bool) private _finalRoundVoted;

    bool private _eighthsRoundDefined;
    bool private _fourthRoundDefined;
    bool private _semifinalRoundDefined;
    bool private _finalRoundDefined;

    constructor(address[] memory judges) {
        require(judges.length == NUMBER_OF_JUDGES, "you must set 3 judges");

        for (uint8 i; i < judges.length; ++i) {
            require(judges[i] != address(0), "a judge cant be address zero");
            require(judges[i] != msg.sender, "the owner cant be judge");
            require(
                !isJudge(judges[i]),
                "you can't set the same address twice as a judge"
            );
            _judges[i] = judges[i];

            _eighthsRoundDebate[judges[i]] = new bool[](8);
            _fourthRoundDebate[judges[i]] = new bool[](4);
            _semifinalRoundDebate[judges[i]] = new bool[](2);
        }
    }

    function getEighthsRoundResult() external view returns (bool[] memory) {
        require(_eighthsRoundDefined, "There is no result yet");
        return _eighthsRoundResult;
    }

    function getFourthRoundResult() external view returns (bool[] memory) {
        require(_fourthRoundDefined, "There is no result yet");
        return _fourthRoundResult;
    }

    function getSemifinalRoundResult() external view returns (bool[] memory) {
        require(_semifinalRoundDefined, "There is no result yet");
        return _semifinalRoundResult;
    }

    function getFinalRoundResult() external view returns (bool) {
        require(_finalRoundDefined, "There is no result yet");
        return _finalRoundResult;
    }

    function getJudge(uint256 index) external view returns (address) {
        require(index < NUMBER_OF_JUDGES, "Incorrect index");
        return _judges[index];
    }

    function setNewJudge(uint8 index, address newJudge) external onlyOwner {
        require(index < NUMBER_OF_JUDGES, "Incorrect index");
        require(newJudge != address(0), "a judge cant be address zero");
        require(newJudge != msg.sender, "the owner cant be judge");
        require(
            !isJudge(newJudge),
            "you can't set the same address twice as a judge"
        );
        _judges[index] = newJudge;
    }

    //add judge debate
    function addJudgeDebateToEighthsRound(bool[] memory vote) external {
        require(vote.length == 8, "its an incorrect value");
        require(isJudge(msg.sender), "you are not a judge");
        _eighthsRoundDebate[msg.sender] = vote;
        _eighthsRoundVoted[msg.sender] = true;
    }

    function addJudgeDebateToFourthRound(bool[] memory vote) external {
        require(vote.length == 4, "its an incorrect value");
        require(isJudge(msg.sender), "you are not a judge");
        _fourthRoundDebate[msg.sender] = vote;
        _fourthRoundVoted[msg.sender] = true;
    }

    function addJudgeDebateToSemifinalRound(bool[] memory vote) external {
        require(vote.length == 2, "its an incorrect value");
        require(isJudge(msg.sender), "you are not a judge");
        _semifinalRoundDebate[msg.sender] = vote;
        _semifinalRoundVoted[msg.sender] = true;
    }

    function addJudgeDebateToFinalRound(bool vote) external {
        require(isJudge(msg.sender), "you are not a judge");
        _finalRoundDebate[msg.sender] = vote;
        _finalRoundVoted[msg.sender] = true;
    }

    //set final vote
    function setEighthsRoundResult(bool[] memory vote) external onlyOwner {
        require(vote.length == 8, "its an incorrect value");
        require(
            isJudgesAddedEighthsRoundResults(),
            "the judges did not upload eighths round results"
        );
        require(!_eighthsRoundDefined, "a final vote has already been reached");
        for (uint256 i; i < vote.length; ) {
            uint8 flat;
            if (_eighthsRoundDebate[_judges[0]][i]) ++flat;
            if (_eighthsRoundDebate[_judges[1]][i]) ++flat;
            if (_eighthsRoundDebate[_judges[2]][i]) ++flat;
            if (vote[i]) ++flat;
            if (flat == 4 || flat == 3) {
                _eighthsRoundResult[i] = true;
            } else if (flat == 0 || flat == 1) {
                _eighthsRoundResult[i] = false;
            } else {
                revert("there is no match");
            }
            unchecked {
                ++i;
            }
        }
        _eighthsRoundDefined = true;
    }

    function isJudgesAddedEighthsRoundResults() private view returns (bool) {
        for (uint8 i; i < _judges.length; ++i) {
            if (!_eighthsRoundVoted[_judges[i]]) {
                return false;
            }
        }
        return true;
    }

    function setFourthRoundResult(bool[] memory vote) external onlyOwner {
        require(vote.length == 4, "its an incorrect value");
        require(
            isJudgesAddedFourthRoundResults(),
            "the judges did not upload fourth round results"
        );
        require(!_fourthRoundDefined, "a final vote has already been reached");
        for (uint256 i; i < vote.length; ) {
            uint8 flat;
            if (_fourthRoundDebate[_judges[0]][i]) ++flat;
            if (_fourthRoundDebate[_judges[1]][i]) ++flat;
            if (_fourthRoundDebate[_judges[2]][i]) ++flat;
            if (vote[i]) ++flat;
            if (flat == 4 || flat == 3) {
                _fourthRoundResult[i] = true;
            } else if (flat == 0 || flat == 1) {
                _fourthRoundResult[i] = false;
            } else {
                revert("there is no match");
            }
            unchecked {
                ++i;
            }
        }
        _fourthRoundDefined = true;
    }

    function isJudgesAddedFourthRoundResults() private view returns (bool) {
        for (uint8 i; i < _judges.length; ++i) {
            if (!_fourthRoundVoted[_judges[i]]) {
                return false;
            }
        }
        return true;
    }

    function setSemifinalRoundResult(bool[] memory vote) external onlyOwner {
        require(vote.length == 2, "its an incorrect value");
        require(
            isJudgesAddedSemifinalRoundResults(),
            "the judges did not upload semifinal round results"
        );
        require(
            !_semifinalRoundDefined,
            "a final vote has already been reached"
        );
        for (uint256 i; i < vote.length; ++i) {
            uint8 flat;
            if (_semifinalRoundDebate[_judges[0]][i]) ++flat;
            if (_semifinalRoundDebate[_judges[1]][i]) ++flat;
            if (_semifinalRoundDebate[_judges[2]][i]) ++flat;
            if (vote[i]) ++flat;
            if (flat == 4 || flat == 3) {
                _semifinalRoundResult[i] = true;
            } else if (flat == 0 || flat == 1) {
                _semifinalRoundResult[i] = false;
            } else {
                revert("there is no match");
            }
        }
        _semifinalRoundDefined = true;
    }

    function isJudgesAddedSemifinalRoundResults() private view returns (bool) {
        for (uint8 i; i < _judges.length; ++i) {
            if (!_semifinalRoundVoted[_judges[i]]) {
                return false;
            }
        }
        return true;
    }

    function setFinalRoundResult(bool vote) external onlyOwner {
        require(
            isJudgesAddedFinalRoundResults(),
            "the judges did not upload final round results"
        );
        require(!_finalRoundDefined, "a final vote has already been reached");
        uint8 flat;
        if (_finalRoundDebate[_judges[0]]) ++flat;
        if (_finalRoundDebate[_judges[1]]) ++flat;
        if (_finalRoundDebate[_judges[2]]) ++flat;
        if (vote) ++flat;

        if (flat == 4 || flat == 3) {
            _finalRoundResult = true;
        } else if (flat == 0 || flat == 1) {
            _finalRoundResult = false;
        } else {
            revert("there is no match");
        }
        _finalRoundDefined = true;
    }

    function isJudgesAddedFinalRoundResults() private view returns (bool) {
        for (uint8 i; i < _judges.length; ++i) {
            if (!_finalRoundVoted[_judges[i]]) {
                return false;
            }
        }
        return true;
    }

    function isJudge(address aspirant) private view returns (bool) {
        if (aspirant == _judges[0]) return true;
        if (aspirant == _judges[1]) return true;
        if (aspirant == _judges[2]) return true;
        return false;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        require(!isJudge(newOwner), "Ownable: new owner is a judge address");

        _transferOwnership(newOwner);
    }
}