// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FinalStandardSale {
    using Strings for uint256;
    using SafeMath for uint256;

    constructor(address _ownershipContractAddress, address _busdContractAddress)
    {
        blucamonOwnershipContract = _ownershipContractAddress;
        setter = msg.sender;
        busdContract = _busdContractAddress;
    }

    event PurchaseFinalStandardEgg(uint256 blucamonId, uint8 eventIndex);
    event SetSetter(address _newSetter);
    event SetFounder(address _newFounder);
    event SetEvent(
        uint256 _price,
        uint256 _total,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _rarity,
        uint8 _eventIndex
    );
    event SetPrefixTokenUri(string _newPrefixTokenUri);
    event DisableEvent(uint8 _eventIndex);

    struct SaleEvent {
        uint256 price;
        uint256 total;
        uint256 startTime;
        uint256 endTime;
        uint256 currentNumber;
        uint8 rarity;
    }

    address blucamonOwnershipContract;
    address setter;
    address payable founder;
    string prefixTokenUri;
    address public busdContract;

    SaleEvent[] public events;

    modifier onlySetter() {
        require(msg.sender == setter, "S_FSD_100");
        _;
    }

    function setSetter(address _newSetter) external onlySetter {
        setter = _newSetter;
        emit SetSetter(_newSetter);
    }

    function setFounder(address payable _newFounder) external onlySetter {
        founder = _newFounder;
        emit SetFounder(_newFounder);
    }

    function addSaleEvent() internal onlySetter {
        events.push(
            SaleEvent({
                price: 0,
                total: 0,
                startTime: 0,
                endTime: 0,
                currentNumber: 0,
                rarity: 0
            })
        );
    }

    function initSaleEvents() external onlySetter {
        require(events.length == 0, "S_FSD_700");
        addSaleEvent();
        addSaleEvent();
        addSaleEvent();
    }

    function setEvent(
        uint256 _price,
        uint256 _total,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _rarity,
        uint8 _eventIndex
    ) external onlySetter {
        SaleEvent storage saleEvent = getEventForUpdate(_eventIndex);
        require(
            block.timestamp < saleEvent.startTime ||
                block.timestamp >= saleEvent.endTime,
            "S_FSD_302"
        );
        require(
            block.timestamp <= _startTime && _startTime < _endTime,
            "S_FSD_303"
        );
        saleEvent.currentNumber = 0;
        saleEvent.price = _price;
        saleEvent.total = _total;
        saleEvent.startTime = _startTime;
        saleEvent.endTime = _endTime;
        saleEvent.rarity = _rarity;
        emit SetEvent(
            _price,
            _total,
            _startTime,
            _endTime,
            _rarity,
            _eventIndex
        );
    }

    function getEventForUpdate(uint8 _eventIndex)
        internal
        view
        returns (SaleEvent storage)
    {
        require(_eventIndex >= 0 && _eventIndex < events.length, "S_FSD_600");
        return events[_eventIndex];
    }

    function setPrefixTokenUri(string memory _newPrefixTokenUri)
        external
        onlySetter
    {
        prefixTokenUri = _newPrefixTokenUri;
        emit SetPrefixTokenUri(_newPrefixTokenUri);
    }

    function disableEvent(uint8 _eventIndex) external onlySetter {
        SaleEvent storage saleEvent = getEventForUpdate(_eventIndex);
        saleEvent.endTime = 0;
        emit DisableEvent(_eventIndex);
    }

    function purchaseEgg(uint8 _eventIndex) external {
        SaleEvent storage saleEvent = getEventForUpdate(_eventIndex);
        validatePurchasing(saleEvent);
        (bool transferResult, ) = busdContract.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                msg.sender,
                founder,
                saleEvent.price
            )
        );
        require(transferResult, "S_FSD_400");
        saleEvent.currentNumber = saleEvent.currentNumber.add(1);

        uint256 newBlucamonId = getBlucamonId().add(1);
        string memory tokenUri = getTokenUri(newBlucamonId);
        (bool mintResult, ) = blucamonOwnershipContract.call(
            abi.encodeWithSignature(
                "mintBlucamon(address,string,bool,uint8,uint256,uint8)",
                msg.sender,
                tokenUri,
                false,
                saleEvent.rarity,
                0,
                0
            )
        );
        require(mintResult, "S_FSD_500");
        emit PurchaseFinalStandardEgg(newBlucamonId, _eventIndex);
    }

    function getBlucamonId() private returns (uint256) {
        (, bytes memory idData) = blucamonOwnershipContract.call(
            abi.encodeWithSignature("getBlucamonId()")
        );
        return abi.decode(idData, (uint256));
    }

    function getTokenUri(uint256 _id) private view returns (string memory) {
        return string(abi.encodePacked(prefixTokenUri, _id.toString()));
    }

    function validatePurchasing(SaleEvent memory _saleEvent) private view {
        require(_saleEvent.currentNumber < _saleEvent.total, "S_FSD_200");
        require(block.timestamp >= _saleEvent.startTime, "S_FSD_300");
        require(block.timestamp < _saleEvent.endTime, "S_FSD_301");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

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