// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IManager.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Manager is IManager {
    address public dao;
    mapping(address => bool) public operators;

    mapping(address => bool) public platformDex;
    mapping(address => bool) public platformNft;
    //maker给指定的地址设置限定价格
    mapping(address => mapping(string=>IManager.LimitPrice)) private _allowedPayment;



    mapping(address => bool) public allowedNft;

    event SetDao(address _dao, bool _isOperator);
    event UpdateConduitController(address _conduitController);
    event SetOperators(address _address, bool _flag);
    event SetPlatformDex(address _address, bool _flag);

    error NotDao();
    error NotMaker();
    error NotOperator();
    error WrongDaoParam();

    modifier onlyDAO() {
        if (msg.sender != dao) {
            revert NotDao();
        }
        _;
    }

    modifier onlyOperator() {
        if (!operators[msg.sender]) {
            revert NotOperator();
        }
        _;
    }

    constructor(address _dao)  {
        dao = _dao;
        operators[_dao] = true;
    }

    function setDao(address _dao, bool _isOperator) external onlyDAO {
        if (dao == _dao) {
            revert WrongDaoParam();
        }

        operators[dao] = false;

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

    //maker指定某些地址可以按照限价单的单价(approvalPrice)购买指定的数量(approvalNumber)
    function setPaymentsAllowed(address[] calldata _payments, LimitPrice[] calldata _limitPrices)
    external
    {
        address maker = msg.sender;
        for (uint256 i = 0; i < _payments.length; i++) {
            LimitPrice memory limitPrice = _limitPrices[i];
            string memory v = string.concat(Strings.toString(limitPrice.nftId),Strings.toString(limitPrice.makerNonce),Strings.toHexString(_payments[i]));
            _allowedPayment[maker][v] = limitPrice;
        }
    }
    //maker取消某些地址授权购买
    function cancelPaymentsAllowed(address[] calldata _payments, LimitPrice[] calldata _limitPrices)
    external
    {
        address maker = msg.sender;
        for (uint256 i = 0; i < _payments.length; i++) {
            LimitPrice memory limitPrice = _limitPrices[i];
            string memory v = string.concat(Strings.toString(limitPrice.nftId),Strings.toString(limitPrice.makerNonce),Strings.toHexString(_payments[i]));
            delete _allowedPayment[maker][v];
        }
    }

    function allowedPayment(address maker,address payment,uint256 nftId,uint64 makerNonce) external view returns (IManager.LimitPrice memory){
        string memory v = string.concat(Strings.toString(nftId),Strings.toString(makerNonce),Strings.toHexString(payment));
        return _allowedPayment[maker][v];
    }

    function allNftAllowed() external view returns (bool) {
        return allowedNft[address(0)];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IManager {

    //限价单
    struct LimitPrice {
        //批准的nftId
        uint256 nftId;
        // nonce
        uint64 makerNonce;
        //批准的个数
        uint256 approvalNumber;
        //批准的价格
        uint256 approvalPrice;
    }

    function operators(address addr) external view returns (bool);

    function dao() external view returns (address);

    function platformDex(address addr) external view returns (bool);

    function platformNft(address addr) external view returns (bool);

    function allowedPayment(address maker,address payment,uint256 nftId,uint64 makerNonce) external view returns (LimitPrice memory);

    function allowedNft(address addr) external view returns (bool);

    function allNftAllowed() external view returns (bool);
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