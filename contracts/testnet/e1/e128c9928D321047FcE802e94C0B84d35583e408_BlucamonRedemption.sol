// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BlucamonRedemption {
    using Strings for uint256;
    using SafeMath for uint256;

    constructor(
        address _ownershipContractAddress,
        address _treasury,
        address _blucContract
    ) {
        require(_ownershipContractAddress != address(0), "S_RDM_0100");
        require(_treasury != address(0), "S_RDM_0101");
        require(_blucContract != address(0), "S_RDM_0102");
        blucamonOwnershipContract = _ownershipContractAddress;
        setter = msg.sender;
        treasury = _treasury;
        blucContract = _blucContract;
        fragmentRedemptionPrice[1] = 600 ether;
        fragmentRedemptionPrice[2] = 900 ether;
        fragmentRedemptionPrice[3] = 2800 ether;
        fragmentRedemptionPrice[4] = 15000 ether;
    }

    address blucamonOwnershipContract;
    address setter;
    mapping(address => uint256) public whitelistBlucadexId;
    mapping(address => uint256) public fragmentWhitelistBlucadexId;
    mapping(address => uint256) public fragmentWhitelistRarity;
    mapping(uint256 => uint256) public fragmentRedemptionPrice;
    mapping(uint256 => LimitedBlucamon) public limitedBlucamons;
    mapping(uint256 => mapping(address => uint256)) public redemptionCount;
    uint256 public limitedBlucamonCount;
    uint256 public maximumRedemption = 1;
    string prefixTokenUri;
    address public treasury;
    address public blucContract;

    struct LimitedBlucamon {
        string name;
        string img;
        uint256 price;
        uint256 discountedPrice;
        uint256 qty;
        uint256 startTime;
        uint256 endTime;
        string rarity;
        uint256 blucadexId;
        uint256 tokenPrice;
        uint256 discountedTokenPrice;
        bool isVisible;
    }

    modifier onlySetter() {
        require(msg.sender == setter, "S_RDM_0200");
        _;
    }

    function setSetter(address _newSetter) external onlySetter {
        setter = _newSetter;
    }

    function setMaximumRedemption(uint256 _maximumRedemption)
        external
        onlySetter
    {
        maximumRedemption = _maximumRedemption;
    }

    function setPrefixTokenUri(string memory _newPrefixTokenUri)
        external
        onlySetter
    {
        prefixTokenUri = _newPrefixTokenUri;
    }

    function addLimitedBlucamons(
        string[] memory _nameList,
        string[] memory _imgList,
        uint256[] memory _priceList,
        uint256[] memory _discountedPriceList,
        uint256[] memory _qtyList,
        uint256[] memory _startTimeList,
        uint256[] memory _endTimeList,
        string[] memory _rarityList,
        uint256[] memory _blucadexIdList,
        uint256[] memory _tokenPriceList,
        uint256[] memory _discountedTokenPriceList,
        bool[] memory _isVisibleList
    ) external onlySetter {
        validateNewLimitedBlucamonList(
            _nameList,
            _imgList,
            _priceList,
            _discountedPriceList,
            _qtyList,
            _startTimeList,
            _endTimeList,
            _rarityList,
            _blucadexIdList,
            _tokenPriceList,
            _discountedTokenPriceList,
            _isVisibleList
        );
        for (uint256 i = 0; i < _nameList.length; i++) {
            validateNewLimitedBlucamon(
                _priceList[i],
                _discountedPriceList[i],
                _qtyList[i],
                _startTimeList[i],
                _endTimeList[i],
                _tokenPriceList[i],
                _discountedTokenPriceList[i]
            );
            _addNewLimitedBlucamon(
                _nameList[i],
                _imgList[i],
                _priceList[i],
                _discountedPriceList[i],
                _qtyList[i],
                _startTimeList[i],
                _endTimeList[i],
                _rarityList[i],
                _blucadexIdList[i],
                _tokenPriceList[i],
                _discountedTokenPriceList[i],
                _isVisibleList[i]
            );
        }
    }

    function validateNewLimitedBlucamonList(
        string[] memory _nameList,
        string[] memory _imgList,
        uint256[] memory _priceList,
        uint256[] memory _discountedPriceList,
        uint256[] memory _qtyList,
        uint256[] memory _startTimeList,
        uint256[] memory _endTimeList,
        string[] memory _rarityList,
        uint256[] memory _blucadexIdList,
        uint256[] memory _tokenPriceList,
        uint256[] memory _discountedTokenPriceList,
        bool[] memory _isVisibleList
    ) private pure {
        require(
            _nameList.length == _imgList.length &&
                _nameList.length == _priceList.length &&
                _nameList.length == _discountedPriceList.length &&
                _nameList.length == _qtyList.length &&
                _nameList.length == _startTimeList.length &&
                _nameList.length == _endTimeList.length &&
                _nameList.length == _rarityList.length &&
                _nameList.length == _blucadexIdList.length &&
                _nameList.length == _tokenPriceList.length &&
                _nameList.length == _discountedTokenPriceList.length &&
                _nameList.length == _isVisibleList.length,
            "S_RDM_0300"
        );
    }

    function validateNewLimitedBlucamon(
        uint256 _price,
        uint256 _discountedPrice,
        uint256 _qty,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _tokenPrice,
        uint256 _discountedTokenPrice
    ) private pure {
        require(_discountedPrice <= _price, "S_RDM_0400");
        require(_discountedPrice > 0, "S_RDM_0401");
        require(_startTime < _endTime, "S_RDM_0500");
        require(_qty > 0, "S_RDM_0600");
        require(_discountedTokenPrice <= _tokenPrice, "S_RDM_0700");
        require(_discountedTokenPrice > 0, "S_RDM_0701");
    }

    function validateId(uint256 _id) private view {
        require(_id <= limitedBlucamonCount, "S_RDM_0800");
    }

    function _addNewLimitedBlucamon(
        string memory _name,
        string memory _img,
        uint256 _price,
        uint256 _discountedPrice,
        uint256 _qty,
        uint256 _startTime,
        uint256 _endTime,
        string memory _rarity,
        uint256 _blucadexId,
        uint256 _tokenPrice,
        uint256 _discountedTokenPrice,
        bool _isVisible
    ) private {
        limitedBlucamonCount = limitedBlucamonCount.add(1);
        limitedBlucamons[limitedBlucamonCount] = LimitedBlucamon({
            name: _name,
            img: _img,
            price: _price,
            discountedPrice: _discountedPrice,
            qty: _qty,
            startTime: _startTime,
            endTime: _endTime,
            rarity: _rarity,
            blucadexId: _blucadexId,
            tokenPrice: _tokenPrice,
            discountedTokenPrice: _discountedTokenPrice,
            isVisible: _isVisible
        });
    }

    function updateFragmentRedemptionPrices(uint256[] memory _prices)
        external
        onlySetter
    {
        require(_prices.length == 4, "S_RDM_0900");
        for (uint256 i = 0; i < _prices.length; i++) {
            fragmentRedemptionPrice[i] = _prices[i];
        }
    }

    function updateIsVisibles(
        uint256[] memory _idList,
        bool[] memory _isVisibleList
    ) external onlySetter {
        validateUpdateIsVisibles(_idList, _isVisibleList);
        for (uint256 i = 0; i < _idList.length; i++) {
            validateId(_idList[i]);
            limitedBlucamons[_idList[i]].isVisible = _isVisibleList[i];
        }
    }

    function updatePrices(
        uint256[] memory _idList,
        uint256[] memory _priceList,
        uint256[] memory _discountedPriceList
    ) external onlySetter {
        validateUpdatePrices(_idList, _priceList, _discountedPriceList);
        for (uint256 i = 0; i < _idList.length; i++) {
            validatePrice(_idList[i], _priceList[i], _discountedPriceList[i]);
            limitedBlucamons[_idList[i]].price = _priceList[i];
            limitedBlucamons[_idList[i]].discountedPrice = _discountedPriceList[
                i
            ];
        }
    }

    function updateTokenPrices(
        uint256[] memory _idList,
        uint256[] memory _tokenPriceList,
        uint256[] memory _discountedTokenPriceList
    ) external onlySetter {
        validateUpdateTokenPrices(
            _idList,
            _tokenPriceList,
            _discountedTokenPriceList
        );
        for (uint256 i = 0; i < _idList.length; i++) {
            validateTokenPrice(
                _idList[i],
                _tokenPriceList[i],
                _discountedTokenPriceList[i]
            );
            limitedBlucamons[_idList[i]].tokenPrice = _tokenPriceList[i];
            limitedBlucamons[_idList[i]]
                .discountedTokenPrice = _discountedTokenPriceList[i];
        }
    }

    function validateUpdateIsVisibles(
        uint256[] memory _idList,
        bool[] memory _isVisibleList
    ) private pure {
        require(_idList.length == _isVisibleList.length, "S_RDM_1000");
    }

    function validateUpdatePrices(
        uint256[] memory _idList,
        uint256[] memory _priceList,
        uint256[] memory _discountedPriceList
    ) private pure {
        require(
            _idList.length == _priceList.length &&
                _idList.length == _discountedPriceList.length,
            "S_RDM_1100"
        );
    }

    function validateUpdateTokenPrices(
        uint256[] memory _idList,
        uint256[] memory _tokenPriceList,
        uint256[] memory _discountedtokenPriceList
    ) private pure {
        require(
            _idList.length == _tokenPriceList.length &&
                _idList.length == _discountedtokenPriceList.length,
            "S_RDM_1200"
        );
    }

    function validatePrice(
        uint256 _id,
        uint256 _price,
        uint256 _discountedPrice
    ) private view {
        validateId(_id);
        require(_discountedPrice <= _price, "S_RDM_1300");
        require(_discountedPrice > 0, "S_RDM_1301");
    }

    function validateTokenPrice(
        uint256 _id,
        uint256 _tokenPrice,
        uint256 _discountedTokenPrice
    ) private view {
        validateId(_id);
        require(_discountedTokenPrice <= _tokenPrice, "S_RDM_1400");
        require(_discountedTokenPrice > 0, "S_RDM_1401");
    }

    function isClaimed(address _address) external view returns (bool) {
        return whitelistBlucadexId[_address] != 0;
    }

    function isFragmentRedemptionClaimed(address _address)
        external
        view
        returns (bool)
    {
        return fragmentWhitelistBlucadexId[_address] != 0;
    }

    function setNewRedemption(uint256 _limitedBlucamonId, address _address)
        external
        onlySetter
    {
        validateNewRedemption(_limitedBlucamonId, _address);
        whitelistBlucadexId[_address] = limitedBlucamons[_limitedBlucamonId]
            .blucadexId;
        limitedBlucamons[_limitedBlucamonId].qty = limitedBlucamons[
            _limitedBlucamonId
        ].qty.sub(1);
        redemptionCount[_limitedBlucamonId][_address] = redemptionCount[
            _limitedBlucamonId
        ][_address].add(1);
    }

    function setNewFragmentRedemption(
        uint256 _blucadexId,
        uint256 _rarity,
        address _address
    ) external onlySetter {
        require(fragmentWhitelistBlucadexId[_address] != 0, "S_RDM_1500");
        require(fragmentWhitelistRarity[_address] != 0, "S_RDM_1501");
        fragmentWhitelistBlucadexId[_address] = _blucadexId;
        fragmentWhitelistRarity[_address] = _rarity;
    }

    function getLimitedBlucamonDetail(uint256 _limitedBlucamonId)
        public
        view
        returns (LimitedBlucamon memory)
    {
        validateId(_limitedBlucamonId);
        return limitedBlucamons[_limitedBlucamonId];
    }

    function claim() external {
        require(whitelistBlucadexId[msg.sender] != 0, "S_RDM_1600");
        uint256 price = getLimitedBlucamonRedemptionPrice(
            whitelistBlucadexId[msg.sender]
        );
        (bool transferResult, ) = blucContract.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                msg.sender,
                treasury,
                price
            )
        );
        require(transferResult, "S_RDM_1700");
        uint256 newBlucamonId = getBlucamonId().add(1);
        string memory tokenUri = getTokenUri(newBlucamonId);
        (bool mintResult, ) = blucamonOwnershipContract.call(
            abi.encodeWithSignature(
                "mintBlucamon(address,string,bool,uint8,uint256,uint8)",
                msg.sender,
                tokenUri,
                false,
                0,
                whitelistBlucadexId[msg.sender],
                0
            )
        );
        require(mintResult, "S_RDM_1800");
        whitelistBlucadexId[msg.sender] = 0;
    }

    function claimFragmentRedemption() external {
        require(fragmentWhitelistBlucadexId[msg.sender] != 0, "S_RDM_1900");
        require(fragmentWhitelistRarity[msg.sender] != 0, "S_RDM_1901");
        uint256 price = getFragmentRedemptionPrice(
            fragmentWhitelistRarity[msg.sender]
        );
        (bool transferResult, ) = blucContract.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                msg.sender,
                treasury,
                price
            )
        );
        require(transferResult, "S_RDM_2000");
        uint256 newBlucamonId = getBlucamonId().add(1);
        string memory tokenUri = getTokenUri(newBlucamonId);
        (bool mintResult, ) = blucamonOwnershipContract.call(
            abi.encodeWithSignature(
                "mintBlucamon(address,string,bool,uint8,uint256,uint8)",
                msg.sender,
                tokenUri,
                false,
                0,
                whitelistBlucadexId[msg.sender],
                0
            )
        );
        require(mintResult, "S_RDM_2100");
        fragmentWhitelistBlucadexId[msg.sender] = 0;
        fragmentWhitelistRarity[msg.sender] = 0;
    }

    function getLimitedBlucamonRedemptionPrice(uint256 _limitedBlucamonId)
        private
        view
        returns (uint256)
    {
        LimitedBlucamon memory limitedBlucamon = getLimitedBlucamonDetail(
            _limitedBlucamonId
        );

        return limitedBlucamon.discountedTokenPrice;
    }

    function getFragmentRedemptionPrice(uint256 _rarity)
        private
        view
        returns (uint256)
    {
        return fragmentRedemptionPrice[_rarity];
    }

    function validateNewRedemption(uint256 _limitedBlucamonId, address _address)
        public
        view
    {
        require(whitelistBlucadexId[_address] == 0, "S_RDM_2200");
        LimitedBlucamon memory limitedBlucamon = getLimitedBlucamonDetail(
            _limitedBlucamonId
        );
        require(
            redemptionCount[_limitedBlucamonId][_address] < maximumRedemption,
            "S_RDM_2300"
        );
        require(block.timestamp >= limitedBlucamon.startTime, "S_RDM_2400");
        require(block.timestamp <= limitedBlucamon.endTime, "S_RDM_2401");
        require(limitedBlucamon.qty > 0, "S_RDM_2500");
        require(_address != address(0), "S_RDM_2600");
    }

    function getBlucamonId() private returns (uint256) {
        (bool result, bytes memory idData) = blucamonOwnershipContract.call(
            abi.encodeWithSignature("getBlucamonId()")
        );
        require(result, "S_RDM_2700");
        return abi.decode(idData, (uint256));
    }

    function getTokenUri(uint256 _id) private view returns (string memory) {
        return string(abi.encodePacked(prefixTokenUri, _id.toString()));
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