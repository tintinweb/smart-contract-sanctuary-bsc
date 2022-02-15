// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// 预售
contract PreSale is AccessControl{

    using Counters for Counters.Counter;
    Counters.Counter private _orderIds;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    // 购买事件
    event Buy(
        uint256 indexed channelNumber,// 渠道号
        uint256 indexed orderId,// 订单Id
        address indexed owner,// 购买地址
        uint256 quantity, // 购买数量
        uint256 price, // 购买价格
        uint256 payPrice// 支付金额
    );

    // 预售市场
    struct Market{
        address contractAddress;// 支付合约地址
        uint256 quantityTotal; // 预售总数量
        uint256 quantitySale; // 已售数量
        uint256 quantitySurplus; // 剩余数量
        uint256 price; // 单个盲盒预售价格
        uint startTime; // 预售开始时间
        uint endTime; // 预售结束时间
    }

    // 用户购买信息
    struct BuyInfo{
        uint256 quantityTotal; // 购买总数量
        uint256 quantityOpen; // 已开数量
        uint256 quantitySurplus; // 剩余数量
    }

    // 用户拥有信息结果集
    struct BuyInfoResult{
        uint256 marketId; // 市场ID
        uint256 quantityTotal; // 购买总数量
        uint256 quantityOpen; // 已开数量
        uint256 quantitySurplus; // 剩余数量
    }

    // 市场ID==盲盒ID
    // 市场ID集合
    uint[] _marketIds;

    // 用户购买信息 msg.sender=>marketId=>BuyInfo
    mapping(address=> mapping(uint256=>BuyInfo)) _buyInfoMapping;

    // 白名单是否开启 市场ID=>true
    mapping(uint256 => bool) _whiteListEnable;

    // 白名单 市场ID=>用户地址
    mapping(uint256 => mapping(address => bool)) _whiteList;

    // 市场ID
    mapping(uint256 => Market) preSaleMarketMapping;

    // 根据不用的盲盒设置限制购买数
    // 市场ID=>限制次数
    mapping(uint256 => uint256) _limit;

    // 盲盒市场创建
    function createMarket(uint256[] memory _marketId, address[] memory _contractAddress, 
        uint256[] memory _quantityTotal, uint256[] memory _price, 
        uint256[] memory _startTime, uint256[] memory _endTime) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        uint marketIdLength = _marketId.length;
        for (uint i = 0; i < marketIdLength; i++) {
            if(preSaleMarketMapping[_marketId[i]].startTime == 0){
                _marketIds.push(_marketId[i]);
                _limit[_marketId[i]]=999999999;
                preSaleMarketMapping[_marketId[i]] = Market({
                    contractAddress : _contractAddress[i],
                    quantityTotal : _quantityTotal[i],
                    quantitySale : 0,
                    quantitySurplus : 0,
                    price : _price[i],
                    startTime : _startTime[i],
                    endTime : _endTime[i]
                });
            }else{
                preSaleMarketMapping[_marketId[i]].quantityTotal += _quantityTotal[i];
                preSaleMarketMapping[_marketId[i]].price = _price[i];
                preSaleMarketMapping[_marketId[i]].startTime = _startTime[i];
                preSaleMarketMapping[_marketId[i]].endTime = _endTime[i];
            }
            
        }
    }

    // 根据市场ID查询购买现在次数
    function limit(uint _marketId) public view returns(uint256){
        return _limit[_marketId];
    }

    // 市场盲盒信息
    function market(uint256 _marketId) public view returns(Market memory){
        return preSaleMarketMapping[_marketId];
    }

    // 市场盲盒数量增加
    function addQuantity(uint256[] memory _marketId, uint256[] memory _quantity) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        uint marketIdLength = _marketId.length;
        for (uint i = 0; i < marketIdLength; i++) {
            preSaleMarketMapping[_marketId[i]].quantityTotal += _quantity[i];
        }
    }

    // 市场盲盒价格修改
    function setPrice(uint256[] memory _marketId, uint256[] memory _price) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        uint marketIdLength = _marketId.length;
        for (uint i = 0; i < marketIdLength; i++) {
            preSaleMarketMapping[_marketId[i]].price = _price[i];
        }
    }
    // 设置预售开始时间
    function setStartTime(uint256[] memory _marketId, uint[] memory _startTime) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        uint marketIdLength = _marketId.length;
        for (uint i = 0; i < marketIdLength; i++) {
            preSaleMarketMapping[_marketId[i]].startTime = _startTime[i];
        }
    }

    // 设置预售结束时间
    function setEndTime(uint256[] memory _marketId, uint[] memory _endTime) public {
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        uint marketIdLength = _marketId.length;
        for (uint i = 0; i < marketIdLength; i++) {
            preSaleMarketMapping[_marketId[i]].endTime = _endTime[i];
        }
    }

    // 批量设置白名单
    function whiteList(uint256 _marketId, address[] memory _whiteAddressArray) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        uint whiteAddressLength = _whiteAddressArray.length;
        for (uint i = 0; i < whiteAddressLength; i++) {
            _whiteList[_marketId][_whiteAddressArray[i]] = true;
        }
    }

    // 删除白名单
    function delWhiteList(uint256 _marketId, address[] memory _whiteAddressArray) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        uint whiteAddressLength = _whiteAddressArray.length;
        for (uint i = 0; i < whiteAddressLength; i++) {
            delete _whiteList[_marketId][_whiteAddressArray[i]];
        }
    }

    // 查询白名单
    function getWhiteList(uint256 _marketId, address _address) public view returns(bool){
        return _whiteList[_marketId][_address];
    }

    // 根据市场ID设置是否开启白名单
    function whiteListEnable(uint256 _marketId, bool _enbale) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        _whiteListEnable[_marketId] = _enbale;
    }

    // 查询白名单是否开启
    function getWhiteListEnable(uint256 _marketId) public view returns (bool){
        return _whiteListEnable[_marketId];
    }

    // 返回是否是白名单
    function _existsWhite(uint256 _marketId)internal view virtual returns (bool){
        if(_whiteListEnable[_marketId]){
            return _whiteList[_marketId][msg.sender] == true;
        }
        return true;
    }

    // 根据市场ID设置的盲盒限制次数
    function setLimit(uint256 _marketId, uint256 _frequency) public{
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a minter");
        _limit[_marketId] = _frequency;
    }

    // 根据地址获取用户拥有盲盒信息
    function buyInfoItmes(address _address) public view returns(BuyInfoResult[] memory){
        uint marketIdsLength = _marketIds.length;
        BuyInfoResult[] memory items = new BuyInfoResult[](marketIdsLength);
        for (uint i = 0; i < marketIdsLength; i++) {
            items[i] = BuyInfoResult({
                marketId : _marketIds[i],
                quantityTotal : _buyInfoMapping[_address][_marketIds[i]].quantityTotal,
                quantityOpen : _buyInfoMapping[_address][_marketIds[i]].quantityOpen,
                quantitySurplus: _buyInfoMapping[_address][_marketIds[i]].quantitySurplus
            });
        }
        return items;
    }

    // 根据地址和市场ID获取用户拥有盲盒信息
    function buyInfoItmes(address _address, uint256 _marketId) public view returns(BuyInfoResult memory){
        return BuyInfoResult({
                marketId : _marketId,
                quantityTotal : _buyInfoMapping[_address][_marketId].quantityTotal,
                quantityOpen : _buyInfoMapping[_address][_marketId].quantityOpen,
                quantitySurplus: _buyInfoMapping[_address][_marketId].quantitySurplus
            });
    }

    // 根据市场ID查询用户剩余购买次数
    function marketQuantitySurplus(uint256 _marketId, address _address) public view returns(uint256){
        return _limit[_marketId] - _buyInfoMapping[_address][_marketId].quantityTotal;
    }

    // 购买
    function buy(uint256 _channelNumber, uint256 _marketId, uint256 _quantity, uint256 _price) public payable{
        require(_quantity > 0, "purchase quantity must be greater than 0");
        require(_price > 0, "purchase price must be greater than 0");
        require(_existsWhite(_marketId), "msg sender is not white");
        // 检查是否在购买日期内
        require(block.timestamp >= preSaleMarketMapping[_marketId].startTime, "no sale started");
        require(block.timestamp < preSaleMarketMapping[_marketId].endTime, "closed sale");
        // 判断是否超过购买限制
        require(preSaleMarketMapping[_marketId].quantityTotal>=_quantity, "buy quantity exceed quantityTotal");
        // 购买次数限制
        require(_limit[_marketId] >= _buyInfoMapping[msg.sender][_marketId].quantityTotal+_quantity, "limit overrun");

        // 进行支付
        if(preSaleMarketMapping[_marketId].contractAddress == address(0)){ // 支付BNB
            // payable(msg.sender).transfer(msg.value);
            require(msg.value > 0, "purchase quantity must be greater than 0");
            require(msg.value == _price, "msg.value != _price");
            // 检查资金是否一致
            require(msg.value == preSaleMarketMapping[_marketId].price*_quantity, "msg.value != _price");
            _price = msg.value;
        }else{ // 支持合约币
            require(_price == preSaleMarketMapping[_marketId].price*_quantity, "_price != price*_quantity");
            IERC20(preSaleMarketMapping[_marketId].contractAddress).transferFrom(msg.sender, address(this), _price);
        }
        _buyInfoMapping[msg.sender][_marketId].quantityTotal += _quantity;
        _orderIds.increment();
        uint256 orderId = _orderIds.current();
        emit Buy(
            _channelNumber,
            orderId,
            msg.sender,
            _quantity,
            _price,
            msg.value
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}