// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../security/SoftAdministered.sol";
import "../Interfaces/IOracle.sol";

contract Transactions is SoftAdministered {

    /// @dev SafeMath library
    using SafeMath for uint256;

    address oracleContractService = address(0x0);

    /**
     * @notice Ambassador Transaction struct
     * @dev Ambassador Transaction struct
     * @param _token                                    Token address used for pay
     * @param walletAmbassador                          Ambassador wallet address
     * @param wallet                                    Buyer wallet address
     * @param commission                                Ambassador commission amount
     * @param amount                                    Amount payed for the buyer
     * @param timestamp                                 Timestamp of the transaction
     * @param oraclePrice                               Oracle price (WEI)
     */
    struct TransactionLog {
        address _token;
        address walletAmbassador;
        address wallet;
        uint256 commission;
        uint256 amount;
        uint256 timestamp;
        uint256 oraclePrice;
    }

    /**
     * ===============================================
     * @dev Mapping of transactions
     * ===============================================
     */

    /// @dev Mapping of Ambassador Transaction
    mapping(address => mapping(uint256 => TransactionLog)) private _ambassadorLogs;

    /// @dev Mapping of VIP Transaction
    mapping(address => mapping(uint256 => TransactionLog)) private _vipLogs;

    /// @dev Mapping of SuperAdmin Transaction
    mapping(address => mapping(uint256 => TransactionLog)) private _saLogs;

    /**
     * ===============================================
     * @dev Countes of transactions
     * ===============================================
     */

    /// @dev Count of ambassador transactions
    mapping(address => uint256) public countTransactionAmbassador;

    /// @dev Count of VIP transactions
    mapping(address => uint256) public countTransactionVIP;

    /// @dev Count of SuperAdmin transactions
    mapping(address => uint256) public countTransactionSA;

    /**
     * ===============================================
     * @dev Countes of Total Commissions
     * ===============================================
     */
    
    /// @dev Count of ambassador transactions
    mapping(address => uint256) public ambassadorTotalCommission;

    /// @dev Count of VIP transactions
    mapping(address => uint256) public vipTotalCommission;

    /// @dev Count of SuperAdmin transactions
    mapping(address => uint256) public saTotalCommission;

    /**
     * ===============================================
     * @dev Countes of Total Volumen
     * ===============================================
     */
    
    /// @dev Count of ambassador transactions
    mapping(address => uint256) public ambassadorTotalVolumen;

    /// @dev Count of VIP transactions
    mapping(address => uint256) public vipTotalVolumen;

    /// @dev Count of SuperAdmin transactions
    mapping(address => uint256) public saTotalVolumen;

    /**
     * ===============================================
     * @dev Set Oracle contract service address
     * ===============================================
     */
    function setOracleContractService(address _oracleContractService) external onlyUserOrOwner {
        oracleContractService = _oracleContractService;
    }

    /**
     * ===============================================
     * @dev         Store Transactions
     * ===============================================
     */

    /// @dev Store Ambassador transaction
    function _storeAmbassadorLog(
        address _token,
        address _host,
        address _buyer,
        uint256 commission,
        uint256 amount
    ) external onlyUserOrOwner {

        uint256 _count = countTransactionAmbassador[_host];

        /// @dev Get Oracle price
        uint256 oraclePrice = IOracle(oracleContractService).getUSDPrice(_token);

        /// @dev save transaction
        _ambassadorLogs[_host][_count] = TransactionLog(
            _token,
            _host,
            _buyer,
            commission,
            amount,
            block.timestamp,
            oraclePrice
        );

        /// @dev count the number of pairs
        countTransactionAmbassador[_host] = _count.add(1);
    }

    /// @dev Store VIP transaction
    function _storeVIPLog(
        address _token,
        address _host,
        address _buyer,
        uint256 commission,
        uint256 amount
    ) external onlyUserOrOwner {

        uint256 _count = countTransactionVIP[_host];

        /// @dev Get Oracle price
        uint256 oraclePrice = IOracle(oracleContractService).getUSDPrice(_token);

        /// @dev save transaction
        _vipLogs[_host][_count] = TransactionLog(
            _token,
            _host,
            _buyer,
            commission,
            amount,
            block.timestamp,
            oraclePrice
        );

        /// @dev count the number of pairs
        countTransactionVIP[_host] = _count.add(1);
    }

    /// @dev Store SA transaction
    function _storeSALog(
        address _token,
        address _host,
        address _buyer,
        uint256 commission,
        uint256 amount
    ) external onlyUserOrOwner {

        uint256 _count = countTransactionSA[_host];

        /// @dev Get Oracle price
        uint256 oraclePrice = IOracle(oracleContractService).getUSDPrice(_token);

        /// @dev save transaction
        _saLogs[_host][_count] = TransactionLog(
            _token,
            _host,
            _buyer,
            commission,
            amount,
            block.timestamp,
            oraclePrice
        );

        /// @dev count the number of pairs
        countTransactionSA[_host] = _count.add(1);
    }

    /**
     * ===============================================
     * @dev         List Transactions
     * ===============================================
     */

    /// @dev List Ambassador transactions
    function ambassadorLogs(
        address _host,
        uint256 _from,
        uint256 _to
    ) external view returns (TransactionLog[] memory) {
        unchecked {
            /// @dev count the number of pairs
            uint256 _count = countTransactionAmbassador[_host];
            uint256 to = (_to > _count) ? _count : _to;

            TransactionLog[] memory p = new TransactionLog[](to);

            for (uint256 i = _from; i < to; i++) {
                TransactionLog storage s = _ambassadorLogs[_host][i];
                p[i] = s;
            }

            return p;
        }
    }

    /// @dev List Ambassador transactions
    function vipLogs(
        address _host,
        uint256 _from,
        uint256 _to
    ) external view returns (TransactionLog[] memory) {
        unchecked {
            /// @dev count the number of pairs
            uint256 _count = countTransactionVIP[_host];
            uint256 to = (_to > _count) ? _count : _to;

            TransactionLog[] memory p = new TransactionLog[](to);

            for (uint256 i = _from; i < to; i++) {
                TransactionLog storage s = _vipLogs[_host][i];
                p[i] = s;
            }

            return p;
        }
    }

    /// @dev List SuperAdmin transactions
    function saLogs(
        address _host,
        uint256 _from,
        uint256 _to
    ) external view returns (TransactionLog[] memory) {
        unchecked {
            /// @dev count the number of pairs
            uint256 _count = countTransactionSA[_host];
            uint256 to = (_to > _count) ? _count : _to;

            TransactionLog[] memory p = new TransactionLog[](to);

            for (uint256 i = _from; i < to; i++) {
                TransactionLog storage s = _saLogs[_host][i];
                p[i] = s;
            }

            return p;
        }
    }

    /**
     * ===============================================
     * @dev      Manager Total Commission
     * ===============================================
     */

    /// @dev Update Ambassador Total Commission
    function updateAmbassadorCommission(
        uint8 _type,
        address _host,
        uint256 _commission
    ) public onlyUserOrOwner {
        if(_type == 1){
            ambassadorTotalCommission[_host] = ambassadorTotalCommission[_host].sub(_commission);
        }else if(_type == 2){
            ambassadorTotalCommission[_host] = ambassadorTotalCommission[_host].add(_commission);
        }
    }

    /// @dev Update VIP Total Commission
    function updateVIPCommission(
        uint8 _type,
        address _host,
        uint256 _commission
    ) public onlyUserOrOwner {
        if(_type == 1){
            vipTotalCommission[_host] = vipTotalCommission[_host].sub(_commission);
        }else if(_type == 2){
            vipTotalCommission[_host] = vipTotalCommission[_host].add(_commission);
        }
    }

    /// @dev Update SuperAdmin Total Commission
    function updateSACommission(
        uint8 _type,
        address _host,
        uint256 _commission
    ) public onlyUserOrOwner {
        if(_type == 1){
            saTotalCommission[_host] = saTotalCommission[_host].sub(_commission);
        }else if(_type == 2){
            saTotalCommission[_host] = saTotalCommission[_host].add(_commission);
        }
    }

    /**
     * ===============================================
     * @dev      Manager Total Volumen
     * ===============================================
     */

    /// @dev Update Ambassador Total Volumen
    function updateAmbassadorVolumen(
        uint8 _type,
        address _host,
        uint256 _commission
    ) public onlyUserOrOwner {
        if(_type == 1){
            ambassadorTotalVolumen[_host] = ambassadorTotalVolumen[_host].sub(_commission);
        }else if(_type == 2){
            ambassadorTotalVolumen[_host] = ambassadorTotalVolumen[_host].add(_commission);
        }
    }

    /// @dev Update VIP Total Volumen
    function updateVIPVolumen(
        uint8 _type,
        address _host,
        uint256 _commission
    ) public onlyUserOrOwner {
        if(_type == 1){
            vipTotalVolumen[_host] = vipTotalVolumen[_host].sub(_commission);
        }else if(_type == 2){
            vipTotalVolumen[_host] = vipTotalVolumen[_host].add(_commission);
        }
    }

    /// @dev Update SuperAdmin Total Volumen
    function updateSAVolumen(
        uint8 _type,
        address _host,
        uint256 _commission
    ) public onlyUserOrOwner {
        if(_type == 1){
            saTotalVolumen[_host] = saTotalVolumen[_host].sub(_commission);
        }else if(_type == 2){
            saTotalVolumen[_host] = saTotalVolumen[_host].add(_commission);
        }
    }

    /**
     * ===============================================
     * @dev      Start Counters
     * ===============================================
     */

    /// @dev Start Ambassador Counters
    function startAmbassadorCounters(
        address _host
    ) external onlyUserOrOwner {
        countTransactionAmbassador[_host] = 0;
        ambassadorTotalCommission[_host] = 0;
        ambassadorTotalVolumen[_host] = 0;
    }

    /// @dev Start VIP Counters
    function startVIPCounters(
        address _host
    ) external onlyUserOrOwner {
        countTransactionVIP[_host] = 0;
        vipTotalCommission[_host] = 0;
        vipTotalVolumen[_host] = 0;
    }

    /// @dev Start SuperAdmin Counters
    function startSACounters(
        address _host
    ) external onlyUserOrOwner {
        countTransactionSA[_host] = 0;
        saTotalCommission[_host] = 0;
        saTotalVolumen[_host] = 0;
    }

    /**
     * ===============================================
     * @dev      Increment Transaction Counters
     * ===============================================
     */

    /// @dev Increment Ambassador Transaction Counter
    function incrementAmbassadorLogCounter(
        address _host
    ) public onlyUserOrOwner {
        uint256 current = countTransactionAmbassador[_host];
        countTransactionAmbassador[_host] = current.add(1);
    }

    /// @dev Increment VIP Transaction Counter
    function incrementVIPLogCounter(
        address _host
    ) public onlyUserOrOwner {
        uint256 current = countTransactionVIP[_host];
        countTransactionVIP[_host] = current.add(1);
    }

    /// @dev Increment SuperAdmin Transaction Counter
    function incrementSALogCounter(
        address _host
    ) public onlyUserOrOwner {
        uint256 current = countTransactionSA[_host];
        countTransactionSA[_host] = current.add(1);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title Administered
 * @notice Implements Admin and User roles.
 */
contract SoftAdministered is
    Context
{

    /// @dev Wallet Access Struct
    struct WalletAccessStruct {
        address wallet;
        bool active;
    }

    /// @dev Mapping of Wallet Acces
    mapping(address => WalletAccessStruct) _walletAddressAccessList;

    /// @dev Owner
    address private _owner;

    constructor(){
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
     * @dev Throws if called by any account other than the user.
     */
    modifier onlyUser() {
        require(hasRole( _msgSender()), "Ownable: caller is not the user");
        _;
    }


    /**
     * @dev Throws if called by any account other than the user or owner
     */
    modifier onlyUserOrOwner(){
        require(
            (owner() == _msgSender()) || hasRole(_msgSender()), 
            "Ownable: caller is not valid"
        );
        _;
    }


    /// @dev Add `root` to the admin role as a member.
    function addRole(address _wallet)
        public virtual onlyOwner
    {
        if(!hasRole(_wallet)){
            _walletAddressAccessList[_wallet] = WalletAccessStruct(_wallet, true);
        }
    }

    /// @dev Revoke user role
    function revokeRole(address _wallet)
        public virtual onlyOwner
    {
        if(hasRole(_wallet)){
            _walletAddressAccessList[_wallet].active = false;
        }
    }


    /**
     * @dev Check if wallet address has already role
     */
    function hasRole(address _wallet)
        public view virtual returns (bool)
    {
        return _walletAddressAccessList[_wallet].active;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) 
        internal virtual 
    {
        _owner = newOwner;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) 
        public virtual onlyOwner 
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface for Contract Transactions
 */
interface IOracle {

    /**
     * @dev Get USD Price of token
     * @param _token                                                Token address
     * @return uint256                                              USD Price of token
     */
    function getUSDPrice(address _token) external view returns (uint256);

    /**
     * @dev Get last price of token
     * @param _oracle                                               Oracle address
     * @param _decimals                                             Decimals of token
     * @return uint256                                              Price of token
     */
    function getLatestPrice(
        address _oracle, 
        uint256 _decimals
    ) external view returns (uint256);

    /**
     * @dev Parse amount token from USD
     * @param _amount                                               Amount of token
     * @param _token                                                Token address   
     * @return uint256                                              Amount in tokens
     */
    function parseAmountFromUSD(
        uint256 _amount,
        address _token
    ) external view returns (uint256);

    /**
     * @dev Parse amount token to USD
     * @param _amount                                               Amount of token
     * @param _token                                                Token address   
     * @return uint256                                              Amount in USD
     */
    function parseAmountToUSD(
        uint256 _amount,
        address _token
    ) external view returns (uint256);

    /**
     * @notice Parse amount to 18 decimals
     * @dev Parse amount to 18 decimals
     * @param _amount                           Amount to convert   
     * @param _decimal                          Decimal to use convert
     */
    function transformAmountTo18Decimal(
        uint256 _amount, 
        uint256 _decimal
    ) external view returns (uint256);

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