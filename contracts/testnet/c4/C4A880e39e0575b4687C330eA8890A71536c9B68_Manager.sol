// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/DEXEventsAndErrors.sol";
import "../interfaces/IManager.sol";

contract Manager is IManager, DEXEventsAndErrors {

    address public dao;

    mapping(address => bool) public operators;

    mapping(address => bool) public platformDex;

    mapping(address => bool) public platformNft;

    mapping(address => bool) public allowedNft;

    constructor(address _dao)  {
        dao = _dao;
        operators[_dao] = true;
    }

    modifier onlyDAO() {
        require(msg.sender == dao, "NotDao Address");
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "NotOperator");
        _;
    }

    //接受代币
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }


    function withdrawAll(address payable _to) public onlyDAO {
        _to.transfer(address(this).balance);
    }

    function setDao(address _dao, bool _isOperator) external onlyDAO {
        require(dao != _dao, "dao Address is same");

        delete operators[dao];

        dao = _dao;

        operators[_dao] = _isOperator;

        emit SetDao(_dao, _isOperator);
    }

    function setOperators(address[] memory _addrs, bool _flag) external onlyDAO {
        for (uint256 i = 0; i < _addrs.length; i++) {
            operators[_addrs[i]] = _flag;
            emit SetOperators(_addrs[i], _flag);
        }
    }

    //设置所属平台的DAO合约地址
    function setPlatformDex(address _addr, bool _flag) external onlyOperator {
        platformDex[_addr] = _flag;
        emit SetPlatformDex(_addr, _flag);
    }
    //设置所属平台的NFT合约地址
    function setPlatformNft(address _addr, bool _flag) external onlyOperator {
        platformNft[_addr] = _flag;
        allowedNft[_addr] = _flag;
    }

    function setNftAllowed(address _addr, bool _flag) external onlyOperator {
        allowedNft[_addr] = _flag;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title DEXEventsAndErrors
 * @notice DEXEventsAndErrors contains all events and errors.
 */
interface DEXEventsAndErrors {
    event OrderCancelled(address indexed maker,uint256 indexed saleOrderId, bytes32 orderHash);

    event AllOrdersCancelled(address indexed offerer, uint256 increasedNonce);

    event FixedPriceOrderMatched(
        address indexed maker,
        address indexed taker,
        uint256 indexed saleOrderId,
        uint256 buyNftNumber,
        bytes32 orderHash,
        bytes orderBytes,
        bytes assetsBytes
    );

    event SetDao(address _dao, bool _isOperator);

    event UpdateConduitController(address _conduitController);

    event SetOperators(address _address, bool _flag);

    event SetPlatformDex(address _address, bool _flag);

    event Received(address indexed sender, uint value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IManager {

    function operators(address addr) external view returns (bool);

    function dao() external view returns (address);

    function platformDex(address addr) external view returns (bool);

    function platformNft(address addr) external view returns (bool);

    function allowedNft(address addr) external view returns (bool);

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