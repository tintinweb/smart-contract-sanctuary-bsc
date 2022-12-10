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

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Bc is Ownable {
    event Bet(address indexed from, uint256 indexed id, uint256 _value);

    struct Match {
        bool isActive;
        uint256 price;
        uint256 endAt;
        uint256 royalties;
    }

    struct MatchData {
        uint256 pricePool;
        uint256 inA;
        uint256 inB;
        uint256 inEquality;
    }

    enum ResultMatchh {
        isA,
        isB,
        isEquality
    }

    mapping(uint256 => Match) public matchId;
    mapping(uint256 => ResultMatchh) public idResult;
    mapping(uint256 => MatchData) public idData;

    mapping(uint256 => mapping(address => uint256)) public idAddressNbrbet;
    mapping(uint256 => mapping(address => mapping(uint256 => ResultMatchh)))
        public idAddressBetResult;

    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        public idAddressBetLeverage;

    mapping(uint256 => mapping(address => mapping(uint256 => bool)))
        public idAddressBetIsClaim;

    mapping(address => bool) public addressCanFreeBet;

    constructor() {}

    function bet(
        uint256 _id,
        uint256 _leverage,
        ResultMatchh _resultMatch
    ) public payable {
        Match memory _match = matchId[_id];
        require(_leverage > 0, "wrong leverage");
        require(_match.isActive, "not active");
        require(_match.endAt > block.timestamp, "out time");
        require(_match.price * _leverage == msg.value, "wrong value");

        uint256 _betId = idAddressNbrbet[_id][msg.sender];
        idAddressBetResult[_id][msg.sender][_betId] = _resultMatch;

        if (_resultMatch == ResultMatchh.isA) {
            idData[_id].inA += _leverage;
        } else if (_resultMatch == ResultMatchh.isB) {
            idData[_id].inB += _leverage;
        } else if (_resultMatch == ResultMatchh.isEquality) {
            idData[_id].inEquality += _leverage;
        }

        uint256 royalties = (msg.value * _match.royalties) / 100;
        payable(owner()).transfer(royalties);
        emit Bet(msg.sender, _id, msg.value);

        idData[_id].pricePool += msg.value - royalties;
        idAddressBetLeverage[_id][msg.sender][_betId] += _leverage;

        idAddressNbrbet[_id][msg.sender]++;
    }

    function claim(uint256 _id, uint256 _betId) public {
        require(
            idAddressBetLeverage[_id][msg.sender][_betId] > 0,
            "never participate"
        );
        require(!idAddressBetIsClaim[_id][msg.sender][_betId], "already claim");
        require(matchId[_id].endAt < block.timestamp, "out time");
        ResultMatchh _resultM = idResult[_id];
        require(
            idAddressBetResult[_id][msg.sender][_betId] == idResult[_id],
            "not eligible"
        );

        MatchData memory _data = idData[_id];
        uint256 place;
        if (_resultM == ResultMatchh.isA) {
            place = _data.pricePool / _data.inA;
        } else if (_resultM == ResultMatchh.isB) {
            place = _data.pricePool / _data.inB;
        } else if (_resultM == ResultMatchh.isEquality) {
            place = _data.pricePool / _data.inEquality;
        }

        idAddressBetIsClaim[_id][msg.sender][_betId] = true;
        uint256 gain = place * idAddressBetLeverage[_id][msg.sender][_betId];
        payable(msg.sender).transfer(gain);
    }

    function freeBet(uint256 _id, ResultMatchh _resultMatch) public {
        require(addressCanFreeBet[msg.sender], "cant freebet");

        Match memory _match = matchId[_id];

        require(_match.isActive, "not active");
        require(_match.endAt > block.timestamp, "out time");

        uint256 _betId = idAddressNbrbet[_id][msg.sender];
        idAddressBetResult[_id][msg.sender][_betId] = _resultMatch;

        addressCanFreeBet[msg.sender] = false;
        if (_resultMatch == ResultMatchh.isA) {
            idData[_id].inA++;
        } else if (_resultMatch == ResultMatchh.isB) {
            idData[_id].inB++;
        } else if (_resultMatch == ResultMatchh.isEquality) {
            idData[_id].inEquality++;
        }

        idAddressBetLeverage[_id][msg.sender][_betId]++;
        idAddressNbrbet[_id][msg.sender]++;

        emit Bet(msg.sender, _id, 0);
    }

    function setMatch(
        uint256 _id,
        bool _isActive,
        uint256 _price,
        uint256 _endAt,
        uint256 _royalties
    ) public onlyOwner {
        matchId[_id] = Match(_isActive, _price, _endAt, _royalties);
    }

    function setResult(uint256 _id, ResultMatchh _resultMatch)
        public
        onlyOwner
    {
        idResult[_id] = _resultMatch;
    }

    function setFreeBet(address _bettor, bool _canFB) public onlyOwner {
        addressCanFreeBet[_bettor] = _canFB;
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }
}