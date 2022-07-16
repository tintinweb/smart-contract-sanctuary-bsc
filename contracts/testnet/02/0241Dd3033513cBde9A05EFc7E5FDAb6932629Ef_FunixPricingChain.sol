// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/myMath.sol";

contract FunixPricingChain is Ownable {
    enum State {
        CLOSE,
        OPEN
    }

    struct Product {
        uint256 id;
        string ipfsID;
        string name;
        uint256 price;
    }

    struct Session {
        uint256 id;
        uint256 productID;
        State state;
        address[] participants;
        mapping(address => uint256) participant_pricing;
        uint256 timeStarted;
        uint256 timeout;
    }

    event onProductAdded(
        uint256 productID,
        string ipfsID,
        string name,
        uint256 price
    );
    event onCreatedSession(Product p, uint256 sessionID);
    event onStartedSession(uint256 id, State, Product p);
    event onClosedSession(uint256 id, State, Product p);
    event onGuessPrice(address participant, uint256 price, uint256 sessionID);
    event onSetPrice(uint256 productID, uint256 price, uint256 sessionID);
    // Số người tham gia tối đa
    uint8 private participantsLimit = 10;

    // đếm xem có bao nhiêu sản phẩm
    // danh sách sản phẩm, uint là id của sản phẩm
    Product[] private _products;

    // danh sách session
    Session[] private _sessions;

    constructor() {}

    modifier isProductAdded(string memory ipfsID) {
        for (uint256 i = 0; i < _products.length; i++) {
            if (
                keccak256(abi.encodePacked((_products[i].ipfsID))) ==
                keccak256(abi.encodePacked((ipfsID)))
            ) {
                revert("This product has been added");
            }
        }
        _;
    }

    function addProduct(string memory ipfsID, string memory name)
        public
        onlyOwner
        isProductAdded(ipfsID)
        returns (uint256 id)
    {
        Product storage p = _products.push();
        p.id = _products.length - 1;
        p.ipfsID = ipfsID;
        p.name = name;
        emit onProductAdded(p.id, p.ipfsID, p.name, p.price);
        return p.id;
    }

    function getProductByID(uint256 ID)
        public
        view
        returns (
            uint256 id,
            string memory ipfsID,
            uint256 price
        )
    {
        if (ID < 0 || ID >= _products.length) ID = _products.length - 1;
        Product storage p = _products[ID];
        /*Session storage s;
        uint[] memory _prices;
        address[] memory participants;
        // lấy phiên định giá cuối cùng với sản phẩm đó
        for (uint i = _sessions.length - 1; i >= 0; i--) {
            if (_sessions[i].productID == ID) {
                s = _sessions[i];
                _prices = new uint[](s.participants.length);

                for (uint j = 0; j < s.participants.length; j++) {
                    _prices[j] = s.participant_pricing[s.participants[j]];
                }
                participants = s.participants;
                break;
            }
        }*/
        return (p.id, p.ipfsID, p.price);
    }

    function getProduct(string memory _ipfsID)
        public
        view
        returns (
            uint256 id,
            string memory ipfsID,
            string memory name,
            uint256 price
        )
    {
        for (uint256 i = 0; i < _products.length; i++) {
            if (
                keccak256(abi.encodePacked((_products[i].ipfsID))) ==
                keccak256(abi.encodePacked((_ipfsID)))
            ) {
                Product storage p = _products[i];
                return (p.id, p.ipfsID, p.name, p.price);
            }
        }
        revert("Product is not exist");
    }

    function getProducts()
        public
        view
        returns (
            string[] memory ipfsIDs,
            string[] memory names,
            uint256[] memory prices
        )
    {
        string[] memory _ipfsIDs = new string[](_products.length);
        string[] memory _names = new string[](_products.length);
        uint256[] memory _prices = new uint256[](_products.length);
        for (uint256 i = 0; i < _products.length; i++) {
            _ipfsIDs[i] = _products[i].ipfsID;
            _names[i] = _products[i].name;
            _prices[i] = _products[i].price;
        }
        return (_ipfsIDs, _names, _prices);
    }

    modifier productExist(uint256 ID) {
        require(ID >= 0 && ID < _products.length, "ID session is not exist");
        _;
    }
    modifier sessionExist(uint256 ID) {
        require(ID >= 0 && ID < _sessions.length, "ID session is not exist");
        _;
    }

    // tạo phiên đấu giá
    function createSession(uint256 productID)
        public
        productExist(productID)
        onlyOwner
        returns (uint256 id)
    {
        Session storage s = _sessions.push();
        s.productID = productID;
        s.state = State.CLOSE;
        Product memory p;
        for (uint256 i = 0; i < _products.length; i++) {
            if (_products[i].id == productID) p = _products[i];
        }
        emit onCreatedSession(p, _sessions.length - 1);
        return _sessions.length - 1;
    }

    function startSession(uint256 ID, uint256 timeout)
        public
        sessionExist(ID)
        onlyOwner
    {
        _sessions[ID].state = State.OPEN;
        _sessions[ID].timeStarted = block.timestamp;
        _sessions[ID].timeout = timeout;
        emit onStartedSession(
            ID,
            _sessions[ID].state,
            _products[_sessions[ID].productID]
        );
    }

    function closeSession(uint256 ID) public sessionExist(ID) onlyOwner {
        _sessions[ID].state = State.CLOSE;
        emit onClosedSession(
            ID,
            _sessions[ID].state,
            _products[_sessions[ID].productID]
        );
    }

    function getSessions()
        public
        view
        returns (
            uint256[] memory sessionIDs,
            uint256[] memory productIDs,
            string[] memory ipfsIDs,
            string[] memory names,
            uint256[] memory prices,
            State[] memory states,
            uint256[] memory timeStarteds,
            uint256[] memory timeouts
        )
    {
        uint256[] memory _sessionIDs = new uint256[](_sessions.length);
        uint256[] memory _productIDs = new uint256[](_sessions.length);
        string[] memory _ipfsIDs = new string[](_sessions.length);
        string[] memory _names = new string[](_sessions.length);
        uint256[] memory _prices = new uint256[](_sessions.length);
        State[] memory _states = new State[](_sessions.length);
        uint256[] memory _timeStarteds = new uint256[](_sessions.length);
        uint256[] memory _timeouts = new uint256[](_sessions.length);
        for (uint256 i = 0; i < _sessions.length; i++) {
            _sessionIDs[i] = _sessions[i].id;
            _productIDs[i] = _sessions[i].productID;
            _ipfsIDs[i] = _products[_sessions[i].productID].ipfsID;
            _names[i] = _products[_sessions[i].productID].name;
            _prices[i] = _products[_sessions[i].productID].price;
            _states[i] = _sessions[i].state;
            _timeStarteds[i] = _sessions[i].timeStarted;
            _timeouts[i] = _sessions[i].timeout;
        }
        return (
            _sessionIDs,
            _productIDs,
            _ipfsIDs,
            _names,
            _prices,
            _states,
            _timeStarteds,
            _timeouts
        );
    }

    function getSession(uint256 id)
        public
        view
        sessionExist(id)
        returns (
            uint256 sessionID,
            uint256 productID,
            string memory ipfsID,
            string memory name,
            uint256 price,
            State state,
            address[] memory participants,
            uint256[] memory participant_pricings,
            uint256 timeStarted,
            uint256 timeout
        )
    {
        Session storage session = _sessions[id];
        uint256[] memory _participant_pricings = new uint256[](
            session.participants.length
        );
        for (uint256 i = 0; i < session.participants.length; i++) {
            _participant_pricings[i] = session.participant_pricing[
                session.participants[i]
            ];
        }
        return (
            session.id,
            session.productID,
            _products[session.productID].ipfsID,
            _products[session.productID].name,
            _products[session.productID].price,
            session.state,
            session.participants,
            _participant_pricings,
            session.timeStarted,
            session.timeout
        );
    }

    modifier sessionClosed(uint256 sessionID) {
        require(
            _sessions[sessionID].state == State.CLOSE,
            "Session was not closed"
        );
        _;
    }

    function setPrice(
        uint256 sessionID,
        uint256 price,
        uint256 productID
    ) public onlyOwner sessionClosed(sessionID) productExist(productID) {
        _products[productID].price = price;
        emit onSetPrice(productID, price, sessionID);
    }

    // kiểm tra vượt quá số người tham gia định giá 10
    modifier checkParticipantsLimit(uint256 sessionID) {
        require(
            _sessions[sessionID].participants.length < participantsLimit,
            string.concat(
                "reached participants limit: ",
                Strings.toString(participantsLimit)
            )
        );
        _;
    }
    // kiểm tra còn thời hạn hay không
    modifier checkTimeout(uint256 sessionID) {
        if (_sessions[sessionID].timeout > 0)
            require(
                block.timestamp - _sessions[sessionID].timeStarted >
                    _sessions[sessionID].timeout,
                "You've run out of time"
            );
        _;
    }

    function guessPrice(uint256 sessionID, uint256 price)
        public
        sessionExist(sessionID)
        checkParticipantsLimit(sessionID)
        checkTimeout(sessionID)
    {
        Session storage s = _sessions[sessionID];
        require(s.state == State.OPEN, "Session closed");
        s.participant_pricing[msg.sender] = price;

        // nếu trong người này đã pricing rồi thì ko đưa vào danh sách participants
        bool exist = false;
        for (uint256 i = 0; i < s.participants.length; i++) {
            if (s.participants[i] == msg.sender) {
                exist = true;
                break;
            }
        }
        if (!exist) s.participants.push(msg.sender);
        emit onGuessPrice(msg.sender, price, sessionID);
    }

    function calcLastPrice(uint256 sessionID)
        public
        onlyOwner
        returns (int256)
    {
        uint256 P = 0;
        int256 dnew = 0;
        Session storage s = _sessions[sessionID];

        uint256 sum_di = 0;
        uint256 sum_pi = 0;

        for (uint8 i = 0; i < s.participants.length; i++) {
            address addr = s.participants[i];

            uint256 di = (myMath.abs(
                int256(P) - int256(s.participant_pricing[addr])
            ) / P) * 100;
            sum_di += di;
            sum_pi += s.participant_pricing[addr] * (100 - di);
        }

        return dnew;
    }

    function test() public view returns (uint256) {
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library myMath {
    function abs(int number) internal pure returns (uint) {
        return uint(number > 0 ? number : (-number));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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