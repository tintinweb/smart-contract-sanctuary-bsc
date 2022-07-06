/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/utils/Strings.sol


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

// File: silly/boop.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)
// Boop Contract made by Yasmin Seidel (JasminDreasond)
// WARNING! This contract is designed to be fun! Don't try to use boops as a financial system!
pragma solidity 0.8.15;


// Contract
contract BEP20Token {

    // Boop Balance
    mapping (address => uint256) public balances;

    // Boop Pair Balance
    mapping (string => uint256) public balances_pair;

    // Info
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address payable public owner;

    // Event
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Constructor
    constructor() {

        owner = payable(msg.sender);
        name = "Tiny Boop";
        symbol = "Boop";
        decimals = 3;
        totalSupply = 0;

    }

    // Info
    function getOwner() public view returns (address) {
        return owner;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function balancePairOf(address sender, address receiver) external view returns (uint256) {

        // Detect Address.
        require(sender != address(0), "Boop Sender address invalid");
        require(receiver != address(0), "Boop Receiver address invalid");

        // Base Values
        string memory _string_sender;
        string memory _string_to;
        string memory _pair_value;

        // Convert to String
        _string_sender = Strings.toHexString(sender);
        _string_to = Strings.toHexString(receiver);

        _pair_value = string(abi.encodePacked(_string_sender,'__'));
        _pair_value = string(abi.encodePacked(_pair_value,_string_to));

        return balances_pair[_pair_value];
    
    }

    // Send boops here!
    function transfer(address _to, uint256 _value) public returns (bool success) {

        // You can only send 3 boops.
        require(_to != address(0), "Boop Receiver address invalid");
        require(_to != address(msg.sender), "Hey! You can't try to boop yourself! >:c");
        require(_value >= 1000, "Calm your crazy paw! Boop Value must be between 1 to 3");
        require(_value <= 3000, "Calm your crazy paw! Boop Value must be between 1 to 3");

        // Base Values
        string memory _string_sender;
        string memory _string_to;
        string memory _pair_value;

        // Convert to String
        _string_sender = Strings.toHexString(msg.sender);
        _string_to = Strings.toHexString(_to);

        _pair_value = string(abi.encodePacked(_string_sender,'__'));
        _pair_value = string(abi.encodePacked(_pair_value,_string_to));

        // Update Boops Supply!
        totalSupply = totalSupply + _value;
        balances[_to] = balances[_to] + _value;
        balances_pair[_pair_value] = balances_pair[_pair_value] + _value;

        // Complete
        emit Transfer(msg.sender, _to, _value);
        return true;

    }
    
}