// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./INEFTiMPFeeCalcExt.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./IPancakeFactory.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract NEFTiMPFeeCalcExtension is Ownable {
    using SafeMath for uint256;

    bytes32 public version = keccak256("1.10.50");

    enum SaleMethods {
        DIRECT,         // 0x00,                                    (1) seller pays gas to get listing,
                        //                                          (2) buyer pays gas to purchase,
                        //                                          (3) seller receive payment from buyer - transaction fee

        AUCTION,        // 0x01,                                    (1) seller pays gas and auction listing fee,
                        //                                          (2) bidder pays gas for each bids to purchase,
                        //                                          (3) auction which have no bidder are able cancel by seller, costs gas
                        //                                          (4) bidder pays gas for cancellation, also costs transaction fee
                        //                                          (5) bidder unable to cancel bids last 1 hour before auction time expired
                        //                                          (6) seller may claim the highest bid when auction was completed
                        //                                              within 1 hour after the expiration time, cost gas and transaction fee
                        //                                          (7) or the company pays gas to set auto-expired for auction after 1 hour

        CONTRACT,       // 0x02, (RENT)                             (1) seller pays gas and rental listing fee,
                        //                                          (2) buyer pays gas to propose rent contract schedule
                        //                                              and notify the seller for new rent contract schedule
                        //                                          (3) seller pays gas to accept the new rent contract schedule, recieve rent fee - transaction fee
                        //                                          (4) buyer pays gas to renew (extend) rent contract, also rent fee
                        //                                          (5) seller pays gas to accept the new rent contract schedule, receive rent fee - transaction fee
                        //                                          (6) the company pays gas to mark rent to be expired (token => disabled state)
                        //                                              and notify both seller and buyer (if schedule has expired)

        ESCROW          // 0x03,                                    (1) seller pays gas and escrow listing fee
    }

    enum FeeTypes {
        none,
        
        DirectListingFee,                                   // FREE
        DirectListingCancellationFee,                       // FREE
        DirectNegotiateFee,                                 // FREE
        DirectNegotiateCancellationFee,                     // 0.5% x Negotiate Price
        DirectTransactionFee,                               // 0.8% x Item Price

        AuctionListingFee,                                  // 0.3% x Item Price
        AuctionListingCancellationFee,                      // 0.5% x Item Price
        AuctionBiddingFee,                                  // 0.1% x Bid Price
        AuctionBiddingCancellationFee,                      // 0.5% x Bid Price
        AuctionTransactionFee,                              // 0.8% x Item Price

        ContractListingFee,                                 // 0.3% x Item Price
        ContractListingCancellationFee,                     // 0.5% x Item Price
        ContractNegotiateFee,                               // 0.1% x Negotiate Price
        ContractNegotiateCancellationFee,                   // 0.5% x Negotiate Price
        ContractTransactionFee,                             // 0.8% x Item Price

        EscrowListingFee,                                   // 0.3% x Item Price
        EscrowListingCancellationFee,                       // 0.5% x Item Price
        EscrowNegotiateFee,                                 // 0.1% x Negotiate Price
        EscrowNegotiateCancellationFee,                     // 0.5% x Negotiate Price
        EscrowTransactionFee                                // 0.8% x Item Price
    }

    address[] private _tokens;
    
    /**
    ** @dev Map payment is enabled (activated)
    ** @params address Token contract address
    ** @return bool is enabled
    ** use case:  _isEnabled [ address ] = bool
    **/
    mapping(address => bool) private _isEnabled;

    /**
    ** @dev Map of fees
    ** @params FeeTypes kind of fee
    ** @return uint8 percentage fee
    ** use case:  _fees [ FeeTypes ] = uint8
    **/
    mapping(FeeTypes => uint16) private _fees;
    
    /**
    ** @dev Default Payment of Token
    **/
    address private _defaultPayment;
    uint256 public constant staticPercent = 1000;
    
    event DefaultPayment(address tokenContract);
    event EnabledPayment(address tokenContract, bool enabled);
    event FeeChanged(uint8 feeType, uint16 fee);

    /**
    ** @dev NWOMPFeeCalcExtension constructor
    ** @params _tokenAddresses List of Token's Contract Addresses as init payments
    **/
    constructor(
        address[] memory _tokenAddresses
    ) 
    {
        require(_tokenAddresses.length > 0, "ENEFTiMPFCE.01.EMPTY_INIT_PAYMENTS");
        
        _tokens.push( 0x0000000000000000000000000000000000000000 );
        _isEnabled[0x0000000000000000000000000000000000000000] = false;
        
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            _tokens.push( _tokenAddresses[i] );
            _isEnabled[ _tokenAddresses[i] ] = true;
        }
        _defaultPayment = _tokenAddresses[0];

        //---- DEFAULT FEES
        _fees[ FeeTypes.none ] = 0;

        _fees[ FeeTypes.DirectListingFee ] = 0;
        _fees[ FeeTypes.DirectListingCancellationFee ] = 0;
        _fees[ FeeTypes.DirectNegotiateFee ] = 0;
        _fees[ FeeTypes.DirectNegotiateCancellationFee ] = 5;
        _fees[ FeeTypes.DirectTransactionFee ] = 8;

        _fees[ FeeTypes.AuctionListingFee ] = 3;
        _fees[ FeeTypes.AuctionListingCancellationFee ] = 5;
        _fees[ FeeTypes.AuctionBiddingFee ] = 1;
        _fees[ FeeTypes.AuctionBiddingCancellationFee ] = 5;
        _fees[ FeeTypes.AuctionTransactionFee ] = 8;

        _fees[ FeeTypes.ContractListingFee ] = 3;
        _fees[ FeeTypes.ContractListingCancellationFee ] = 5;
        _fees[ FeeTypes.ContractNegotiateFee ] = 1;
        _fees[ FeeTypes.ContractNegotiateCancellationFee ] = 5;
        _fees[ FeeTypes.ContractTransactionFee ] = 8;

        _fees[ FeeTypes.EscrowListingFee ] = 3;
        _fees[ FeeTypes.EscrowListingCancellationFee ] = 5;
        _fees[ FeeTypes.EscrowNegotiateFee ] = 1;
        _fees[ FeeTypes.EscrowNegotiateCancellationFee ] = 5;
        _fees[ FeeTypes.EscrowTransactionFee ] = 8;
    }

    /**
    ** @dev Index from Payments List
    ** @params _tokenContract Token Contract Address
    ** @return { index, isActive }
    **/
    function _getIndexByAddress(address _tokenContract)
        private view
        returns (uint256 index, bool isActive)
    {
        if (_tokenContract == address(0)) { return (0, false); }
        for (uint256 i = 1; i < _tokens.length; i++) {
            if (_tokenContract == _tokens[i]) {
                return (i, _isEnabled[_tokenContract]);
            }
        }
    }

    /**
    ** @dev Add Default Payment Info
    ** @params tokenAddress Token Contract Address
    ** @return transaction Written transaction and event logs
    **/
    function addPayments(address tokenAddress)
      public onlyOwner
    {
      require(tokenAddress != address(0), "ENEFTiMPFCE.06.INVALID_CONTRACT");
      _tokens.push(tokenAddress);
    }
    
    /**
    ** @dev Show Default Payment Info
    ** @return { index, isEnabled, name, symbol, decimals, priceUSD }
    **/
    function defaultPayment()
        public view
        returns (address tokenContract, uint8 decimals, uint256 priceUSD)
    { 
        IERC20Metadata token = IERC20Metadata(_defaultPayment);
        uint8 _decimals = token.decimals();
        uint256 _priceUSD = 0;
        return (_defaultPayment, _decimals, _priceUSD);
    }
    
    /**
    ** @dev Show Default Payment Info
    ** @params _tokenContract Token Contract Address
    ** @return transaction Written transaction and event logs
    **/
    function setDefaultPayment(address _tokenContract)
        public onlyOwner
    {
        require(_tokenContract != address(0), "ENEFTiMPFCE.06.INVALID_CONTRACT");        
        _defaultPayment = _tokenContract;
        emit DefaultPayment(_tokenContract);
    }
    
    /**
    ** @dev Enable a Payment
    ** @params _tokenContract Token Contract Address
    ** @return transaction Written transaction and event logs
    **/
    function enablePayment(address _tokenContract)
        public onlyOwner
    {
        require(_tokenContract != address(0), "ENEFTiMPFCE.07.INVALID_CONTRACT");
        require(!_isEnabled[_tokenContract], "ENEFTiMPFCE.09.CONTRACT_EXISTS");        
        _tokens.push(_tokenContract);
        _isEnabled[_tokenContract] = true;
        emit EnabledPayment(_tokenContract, true);
    }
    
    /**
    ** @dev Disable a Payment
    ** @params _tokenContract Token Contract Address
    ** @return transaction Written transaction and event logs
    **/
    function disablePayment(address _tokenContract)
        public
    {
        require(_tokenContract != _defaultPayment, "ENEFTiMPFCE.10.NOT_ALLOWED_ON_DEFAULT");
        require(_tokens.length > 2, "ENEFTiMPFCE.11.MIN_PAYMENTS_LENGTH");
        require(_tokenContract != address(0), "ENEFTiMPFCE.12.INVALID_ADDRESS");
        
        for (uint256 i = 1; i < _tokens.length; i++) {
            if (_tokenContract == _tokens[i]) {
                _tokens[i] = _tokens[_tokens.length-1];
                // remove last index
                // delete _tokens[_tokens.length-1];
                _tokens.pop();
                _isEnabled[_tokenContract] = false;
                
                emit EnabledPayment(_tokenContract, false);
                return;
            }
        }
    }
    
    /**
    ** @dev Payments List
    ** @return cryptos List of available Token Contract Addresses 
    **/
    function payments()
        public view
        returns (address[] memory cryptos)
    { return _tokens; }
    
    /**
    ** @dev Payments is Enabled
    ** @params _tokenContract Token Contract Address
    ** @return bool Value will be True, if enabled
    **/
    function paymentIsEnabled(address _tokenContract)
        public view
        returns (bool)
    {
        if (_tokenContract == address(0)) { _tokenContract = _defaultPayment; }
        return ( _isEnabled[_tokenContract] );
    }
  
    
    /**
    ** @dev Show Payment Info of a Token
    ** @params _tokenContract Token Contract Address
    ** @return { index, isEnabled, name, symbol, decimals, priceUSD }
    **/
    function paymentInfo(address _tokenContract)
        public view
        returns (uint256 index, bool isEnabled, string memory name, string memory symbol, uint8 decimals, uint256 priceUSD)
    {
        if (_tokenContract == address(0)) { _tokenContract = _defaultPayment; }        
        IERC20Metadata token = IERC20Metadata(_tokenContract);
        (index, isEnabled) = _getIndexByAddress(_tokenContract);
        name = token.name();
        symbol = token.symbol();
        decimals = token.decimals();
        priceUSD = 0;
    }

    function setFeeFor(uint8 _feeType, uint16 _fee)
        public onlyOwner
    {
        require(_feeType > 0 && _feeType <= 20, "ENEFTiMPFCE.13.INVALID_FEE_TYPE");
        _fees[ FeeTypes(_feeType) ] = _fee;
        emit FeeChanged(_feeType, _fee);
    }

    function feeOf(uint8 _feeType)
        public view
        returns (uint16)
    {
        require(_feeType > 0 && _feeType <= 20, "ENEFTiMPFCE.13.INVALID_FEE_TYPE");
        return _fees[ FeeTypes(_feeType) ];
    }

    function calcFeeOf(uint8 _feeType, uint256 _price, uint256 _amount)
        public view
        returns (uint256)
    {
        require(_feeType > 0x00 && _feeType <= 0x14, "ENEFTiMPFCE.13.INVALID_FEE_TYPE");
        if (_amount == 0 || _price == 0) { return (0); }
        if (_fees[ FeeTypes(_feeType) ] == 0) { return (0); }
        return ( (_price * _amount * _fees[ FeeTypes(_feeType) ]).div(staticPercent) );
    }
    
}

/**
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface INEFTiMPFeeCalcExt {
    // used
    function defaultPayment()
        external view
        returns (address tokenContract, uint8 decimals, uint256 priceUSD);

    function setDefaultPayment(address _tokenContract)
        external;

    function enablePayment(address _tokenContract)
        external;

    function disablePayment(address _tokenContract)
        external;

    function payments()
        external view
        returns (address[] memory cryptos);

    function paymentIsEnabled(address _tokenContract)
        external view
        returns (bool);
    
    function usdFeeAsToken(uint256 _usdAmount, address _tokenContract)
        external view
        returns (uint256);
    
    function paymentInfo(address _tokenContract)
        external view
        returns (uint256 index, bool isEnabled, string memory name, string memory symbol, uint8 decimals, uint256 priceUSD);

    function staticPercent() external view returns (uint256);
    
    // used
    function feeOf(uint8 feeType) external view returns (uint16);
    // used
    function calcFeeOf(uint8 _feeType, uint256 _price, uint256 _amount)
        external view
        returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT OR Apache-2.0

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

pragma solidity >=0.7.4 <=0.8.9;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner_;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () {
    _owner_ = msg.sender;
    emit OwnershipTransferred(address(0), _owner_);
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == _owner_, "ENEFTiOA__onlyOwner__SENDER_IS_NOT_OWNER");
    _;
  }

  /**
   * @notice Transfers the ownership of the contract to new address
   * @param _newOwner Address of the new owner
   */
  function transferOwnership(address _newOwner)
    public onlyOwner
  {
    require(_newOwner != address(0), "ENEFTiOA__transferOwnership__INVALID_ADDRESS");
    emit OwnershipTransferred(_owner_, _newOwner);
    _owner_ = _newOwner;
  }

  /**
   * @notice Returns the address of the owner.
   */
  function owner()
    public view
    returns (address)
  { return _owner_; }
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

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}