// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../main/Investment.sol";


/** 
* @author Formation.Fi.
* @notice Implementation of the contract InvestmentGamma.
*/

contract InvestmentGamma is Investment {
        constructor(uint256 _product, address _management,
        address _deposit, address _withdrawal) Investment( _product, _management,
         _deposit,  _withdrawal) {
        }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/Math.sol"; 
import "../utils/Pausable.sol";
import "./libraries/SafeBEP20.sol";
import "./Management.sol";
import "./DepositConfirmation.sol";
import "./WithdrawalConfirmation.sol";

/** 
* @author Formation.Fi.
* @notice Implementation of the contract Investement.
*/

interface IManagementParityInterface {
    function setDepositData(uint256 _amountMinted, uint256 _amountValidated, 
         uint256 _id) external;
    function setWithdrawalData(uint256 _amountMinted, uint256 _amountValidated, 
         uint256 _id) external;
}

interface IEventDataParityInterface {
    function setDepositData(uint256 _amountMinted, uint256 _amountValidated, 
        uint256 _id) external;
}

contract Investment is Pausable {
    using SafeBEP20 for IBEP20;
    using Math for uint256;

    uint256 public constant FACTOR_FEES_DECIMAL = 1e4;
    uint256 public constant FACTOR_PRICE_DECIMALS = 1e18;
    uint256 public product;
    uint256 public maxDeposit;
    uint256 public maxWithdrawal;
    uint256 public tokenPrice;
    uint256 public tokenPriceMean;
    uint256 public netDepositInd;
    uint256 public netAmountEvent;
    uint256 public withdrawalAmountTotal = 1;
    uint256 public withdrawalAmountTotalOld;
    uint256 public depositAmountTotal;
    uint256 public tokenTotalSupply;
    uint256 public tokenIdDeposit = 21;
    uint256 public tokenIdWithdraw = 16;

    mapping(address => uint256) private acceptedWithdrawalPerAddress;
    Management public management;
    DepositConfirmation public deposit;
    WithdrawalConfirmation public withdrawal;
    IManagementParityInterface public managementParity;
    IEventDataParityInterface public eventDataParity;
    event DepositRequest(address indexed _account, uint256 _amount);
    event CancelDepositRequest(address indexed _account, uint256 _amount);
    event WithdrawalRequest(address indexed _account, uint256 _amount);
    event CancelWithdrawalRequest(address indexed _account, uint256 _amount);
    event ValidateDeposit(address indexed _account, uint256 _validatedAmount, uint256 _mintedAmount);
    event ValidateWithdrawal(address indexed _account, uint256 _validatedAmount, uint256 _SentAmount);
   
    constructor(uint256 _product, address _management,  
        address _depositConfirmationAddress, 
        address _withdrawalConfirmationAddress) {
        require(_product >= 0 && _product <=2, 
        "Formation.Fi: not in range"); 
        require(
            _management != address(0),
            "Formation.Fi: zero address"
        );
        require(
           _depositConfirmationAddress != address(0),
            "Formation.Fi:  zero address"
        );
        require(
            _withdrawalConfirmationAddress != address(0),
            "Formation.Fi:  zero address"
        );
        product = _product;
        management = Management(_management);
        deposit = DepositConfirmation(_depositConfirmationAddress);
        withdrawal = WithdrawalConfirmation(_withdrawalConfirmationAddress);
    }
  
    modifier onlyManager() {
        require( management.isManager(msg.sender) == true, 
         "Formation.Fi: no manager");
        _;
    }

    modifier cancel() {
        bool _isCancel = management.isCancel();
        require( _isCancel == true, "Formation.Fi: no cancel");
        _;
    }

    /**
     * @dev getter functions.
    */

    function getTokenPrice() public view returns(uint256){
        return  management.tokenPrice();
    }

    function getDepositFee(uint256 _amount) public view returns (uint256){
        return management.getDepositFee(_amount);
    }

    /**
     * @dev Setter functions.
    */
    function setManagement(address _management) external onlyOwner {
        require(
            _management != address(0),
            "Formation.Fi: zero address"
        );
        management = Management(_management);
    }

    function setDepositConfirmation(address _depositConfirmationAddress) external onlyOwner {
        require(
            _depositConfirmationAddress != address(0),
            "Formation.Fi: zero address"
        );
        deposit = DepositConfirmation(_depositConfirmationAddress);
    }

    function setWithdrawalConfirmation(address _withdrawalConfirmationAddress) external onlyOwner {
        require(
            _withdrawalConfirmationAddress != address(0),
            "Formation.Fi: zero address"
        );
        withdrawal = WithdrawalConfirmation(_withdrawalConfirmationAddress);
    }
    
    function setManagementParity(address _address) external onlyOwner{
        require(
            _address != address(0),
            "Formation.Fi: zero address"
        );
        managementParity = IManagementParityInterface(_address);      
    }

     function setEventDataParity(address _address) external onlyOwner{
        require(
            _address != address(0),
            "Formation.Fi: zero address"
        );
        eventDataParity = IEventDataParityInterface(_address);      
    }
    
    /**
     * @dev Calculate the event parameters by the manager. 
    */
    function calculateEventParameters() external onlyManager {
        calculateNetAmountEvent();
        calculateMaxDepositAmount();
        calculateMaxWithdrawAmount();
    }

    /**
     * @dev Validate the deposit requests of users by the manager.
     * @param _accounts the addresses of users.
    */
    function validateDeposits(address[] memory _accounts) external 
        whenNotPaused onlyManager {
        uint256 _amountStable;
        uint256 _amountStableTotal;
        uint256 _amountToken;
        uint256 _amountTokenTotal;
        uint256 _tokenIdDeposit;
        Token _token = management.token();
        require (_accounts.length > 0, "Formation.Fi: no user");
        for (uint256 i = 0; i < _accounts.length; i++) {
            address _account =_accounts[i];
            if (deposit.balanceOf(_account) == 0) {
                continue;
            }
            if (maxDeposit <= _amountStableTotal) {
                break;
            }
            _tokenIdDeposit = deposit.getTokenId(_account);
            (  , _amountStable, ) = deposit.pendingDepositPerAddress(_account);
            _amountStable = Math.min(maxDeposit  - _amountStableTotal ,  _amountStable);
            _amountToken = Math.mulDiv(_amountStable, FACTOR_PRICE_DECIMALS, tokenPrice);
            if ((_account == address(managementParity)) && (_amountStable >0)) {
                managementParity.setDepositData(_amountToken, _amountStable, 
                product);

            }
            if ((_account == address(eventDataParity)) && (_amountStable >0)) {
                eventDataParity.setDepositData(_amountToken, _amountStable, 
                product);

            }
            _amountTokenTotal += _amountToken;
            _amountStableTotal += _amountStable;
            if (_amountToken > 0){
                if (_account == address(eventDataParity)){
                    _token.mint(address(managementParity), _amountToken);
                }
                else {
                    _token.mint(_account, _amountToken);
                }
                _token.addDeposit(_account, _amountToken, block.timestamp);
            }
            deposit.updateDepositData(_account, _tokenIdDeposit, _amountStable, false);
            emit ValidateDeposit(_account, _amountStable, _amountToken);
        }
        maxDeposit -= _amountStableTotal;
        depositAmountTotal -= _amountStableTotal;
        if (_amountTokenTotal > 0){
            tokenPriceMean  = ((tokenTotalSupply * tokenPriceMean) + 
            (_amountTokenTotal * tokenPrice)) /
            ( tokenTotalSupply + _amountTokenTotal);
            management.updateTokenPriceMean(tokenPriceMean);
        }
        
        if (management.managementFeeTime() == 0){
            management.updateManagementFeeTime(block.timestamp);   
        }
    }

    /**
     * @dev  Validate the withdrawal requests of users by the manager.
     * @param _accounts the addresses of users.
    */
    function validateWithdrawals(address[] memory _accounts) external
        whenNotPaused onlyManager {
        uint256 _tokensToBurn;
        uint256 _amountToken;
        uint256 _amountTokenTotal;
        uint256 _amountStable;
        uint256 _tokenIdWithdraw;
        uint256 _amountScaleDecimals = management.amountScaleDecimals();
        IBEP20 _stableToken = management.stableToken();
        Token _token = management.token();
        calculateAcceptedWithdrawalAmount(_accounts);
        for (uint256 i = 0; i < _accounts.length; i++) {
            address _account =_accounts[i];
            if (withdrawal.balanceOf(_account) == 0) {
                continue;
            }
            _amountToken = acceptedWithdrawalPerAddress[_account];
            delete acceptedWithdrawalPerAddress[_account]; 
            _amountTokenTotal += _amountToken;
            _amountStable = Math.mulDiv(_amountToken,  tokenPrice, 
            (FACTOR_PRICE_DECIMALS * _amountScaleDecimals));
            if ((_account == address(managementParity)) && (_amountToken > 0))  {
               managementParity.setWithdrawalData(_amountStable, _amountToken, 
               product);
            }
            _tokenIdWithdraw = withdrawal.getTokenId(_account);
            withdrawal.updateWithdrawalData(_account,  _tokenIdWithdraw, _amountToken, false);
            if (_amountStable > 0){
                _stableToken.safeTransfer(_account, _amountStable);
            }
            if (_amountToken > 0){
                _tokensToBurn += _amountToken;
                _token.updateTokenData(_account, _amountToken);
            }
            emit ValidateWithdrawal(_account,  _amountToken, _amountStable);
        }
        withdrawalAmountTotal -= _amountTokenTotal;
        
        if ((_tokensToBurn) > 0){
           _token.burn(address(this), _tokensToBurn);
        }
    }

    /**
     * @dev  Make a deposit request.
     * @param _account the addresses of the user.
     * @param _amount the deposit amount in Stablecoin.
     */
    function depositRequest(address _account, uint256 _amount) external whenNotPaused {
        uint256 _fee;
        if ((_account != address(managementParity)) && (_account!= address(eventDataParity))){
            require(_amount >= management.minAmount(), 
                "Formation.Fi: min Amount");
            _fee = getDepositFee(_amount);
            _amount-= _fee;
        }
        if (deposit.balanceOf(_account) == 0){
            tokenIdDeposit += 1;
            deposit.mint(_account, tokenIdDeposit, _amount);
        }
        else {
            uint256 _tokenIdDeposit = deposit.getTokenId(_account);
            deposit.updateDepositData(_account, _tokenIdDeposit, _amount, true);
        }
        depositAmountTotal += _amount; 
        IBEP20 _stableToken = management.stableToken();
        uint256 _amountScaleDecimals = management.amountScaleDecimals();
        if (_amount > 0){
            _stableToken.safeTransferFrom(msg.sender, address(this), _amount/_amountScaleDecimals);
        }
        if (_fee > 0){
            _stableToken.safeTransferFrom(msg.sender, management.treasury(), _fee /_amountScaleDecimals);
        }
        emit DepositRequest(_account, _amount);
    }

    /**
     * @dev  Cancel the deposit request.
     * @param _amount the deposit amount to cancel in Stablecoin.
     */
    function cancelDepositRequest(uint256 _amount) external whenNotPaused cancel {
        require(deposit.balanceOf(msg.sender) > 0, 
            "Formation.Fi: no deposit request"); 
        require(_amount > 0, 
            "Formation.Fi: zero amount"); 
        uint256 _tokenIdDeposit = deposit.getTokenId(msg.sender);
        deposit.updateDepositData(msg.sender,  _tokenIdDeposit, _amount, false);
        depositAmountTotal -= _amount; 
        IBEP20 _stableToken = management.stableToken();
        uint256 _amountScaleDecimals = management.amountScaleDecimals();
        _stableToken.safeTransfer(msg.sender, _amount/_amountScaleDecimals);
        emit CancelDepositRequest(msg.sender, _amount);      
    }
    
    /**
     * @dev  Make a withdrawal request.
     * @param _amount the withdrawal amount in Token.
    */
    function withdrawRequest(uint256 _amount) external whenNotPaused {
        require ( _amount > 0, 
            "Formation Fi: zero amount");
        require(withdrawal.balanceOf(msg.sender) == 0, 
            "Formation.Fi: request on pending");
        Token _token = management.token();
        if (msg.sender != address(managementParity)) {
            require(_token.checklWithdrawalRequest(msg.sender, _amount, management.lockupPeriodUser()),
                "Formation.Fi: locked position");
        }
        tokenIdWithdraw += 1;
        withdrawal.mint(msg.sender, tokenIdWithdraw, _amount);
        withdrawalAmountTotal += _amount;
        _token.transferFrom(msg.sender, address(this), _amount);
        emit WithdrawalRequest(msg.sender, _amount);   
    }

    /**
     * @dev Cancel the withdrawal request.
     * @param _amount the withdrawal amount in Token.
    */
    function cancelWithdrawalRequest( uint256 _amount) external whenNotPaused {
        require(_amount > 0, 
            "Formation Fi: zero amount");
        require(withdrawal.balanceOf(msg.sender) > 0, 
                "Formation.Fi: no withdrawal request"); 
        uint256 _tokenIdWithdraw = withdrawal.getTokenId(msg.sender);
        withdrawal.updateWithdrawalData(msg.sender, _tokenIdWithdraw, _amount, false);
        withdrawalAmountTotal -= _amount;
        Token _token = management.token();
        _token.transfer(msg.sender, _amount);
        emit CancelWithdrawalRequest(msg.sender, _amount);
    }
    
    /**
     * @dev Send Stablecoins to the SafeHouse by the manager.
     * @param _amount the amount to send.
    */
    function sendToSafeHouse(uint256 _amount) external 
        whenNotPaused onlyManager {
        require( _amount> 0,  
            "Formation.Fi: zero amount");
        uint256 _amountScaleDecimals = management.amountScaleDecimals();
        IBEP20 _stableToken = management.stableToken();
        uint256 _scaledAmount = _amount/ _amountScaleDecimals;
        address _safeHouse = management.safeHouse();
        require(
            _safeHouse != address(0),
            "Formation.Fi: zero address"
        );
        require(
            _stableToken.balanceOf(address(this)) >= _scaledAmount,
            "Formation.Fi: exceeds balance"
        );
        _stableToken.safeTransfer(_safeHouse, _scaledAmount);
    }


    /**
     * @dev Calculate net deposit indicator
    */
    function calculateNetAmountEvent( ) internal {
        getTokenData();
        management.calculateNetAmountEvent(depositAmountTotal, withdrawalAmountTotal,
        management.maxDepositAmount(), management.maxWithdrawalAmount());
        netDepositInd = management.netDepositInd();
        netAmountEvent = management.netAmountEvent();
    }

    /**
     * @dev Calculate the maximum deposit amount to be validated 
     * by the manager for users.
    */
    function calculateMaxDepositAmount( ) internal  {
             maxDeposit = Math.min(depositAmountTotal, management.maxDepositAmount());
        }
    
    /**
     * @dev Calculate the maximum withdrawal amount to be validated 
     * by the manager for users.
    */
    function calculateMaxWithdrawAmount( ) internal  {
        withdrawalAmountTotalOld = withdrawalAmountTotal;
        maxWithdrawal = Math.min(withdrawalAmountTotal , Math.mulDiv(management.maxWithdrawalAmount(), FACTOR_PRICE_DECIMALS,  tokenPrice));
    }

    
     /**
     * @dev update data from management contract.
     */
    function getTokenData() internal { 
        Token _token = management.token();
        tokenPrice = management.tokenPrice();
        tokenPriceMean = management.tokenPriceMean();
        tokenTotalSupply = _token.totalSupply();
    }
    
    /**
     * @dev Calculate the accepted withdrawal amounts for users.
     * @param _accounts the addresses of users.
     */
    function calculateAcceptedWithdrawalAmount(address[] memory _accounts) 
        internal {
        require(_accounts.length > 0, 
            "Formation.Fi: no user");
        uint256 _amountToken;
        address _account;
        for (uint256 i = 0; i < _accounts.length; ++i) {
            _account = _accounts[i];
            require(_account!= address(0), 
                "Formation.Fi: zero address");
            if (withdrawal.balanceOf(_account) == 0) {
                continue;
            }
            ( , _amountToken, ) = withdrawal.pendingWithdrawPerAddress(_account);
            _amountToken = Math.min(Math.mulDiv(maxWithdrawal, _amountToken,
            withdrawalAmountTotalOld), _amountToken);
            acceptedWithdrawalPerAddress[_account] = _amountToken;
        }   
    }
   
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused, "Transaction is not available");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused, "Transaction is available");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../IBEP20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol"; 
import "./libraries/SafeBEP20.sol";
import "./Token.sol";
/** 
* @author Formation.Fi.
* @notice Implementation of the contract Management.
*/

contract Management is Ownable {
    using SafeBEP20 for IBEP20;
    uint256 public constant FACTOR_FEES_DECIMALS = 1e4; 
    uint256 public constant FACTOR_PRICE_DECIMALS = 1e18;
    uint256 public constant  SECONDES_PER_YEAR = 365 days; 
    uint256 public maxDepositAmount = 1000000 * 1e18;
    uint256 public maxWithdrawalAmount = 1000000 * 1e18;
    uint256 public slippageTolerance = 200;
    uint256 public amountScaleDecimals; 
    uint256 public depositFeeRate = 50;  
    uint256 public minDepositFee;
    uint256 public maxDepositFee = 1000000000000000000000;
    uint256 public managementFeeRate = 200;
    uint256 public performanceFeeRate = 2000;
    uint256 public performanceFee;
    uint256 public managementFee;
    uint256 public managementFeeTime = 1670916182;
    uint256 public tokenPrice = 997758019855786000;
    uint256 public tokenPriceMean = 1000834742672732075;
    uint256 public minAmount= 100 * 1e18;
    uint256 public lockupPeriodUser = 604800; 
    uint256 public netDepositInd;
    uint256 public netAmountEvent;
    address public manager;
    address public treasury;
    address public safeHouse;
    address public investment;
    bool public isCancel;
    mapping(address => bool) public managers;
    Token public token;
    IBEP20 public stableToken;


    constructor( address _manager, address _treasury,  address _stableToken,
     address _token) {
        require(_manager!= address(0),
            "Formation.Fi: zero address");
        require(_treasury!= address(0),
            "Formation.Fi: zero address");
        require(_stableToken!= address(0),
            "Formation.Fi: zero address");
        require(_token!= address(0),
            "Formation.Fi: zero address");
        manager = _manager;
        managers[_manager] = true;
        treasury = _treasury; 
        token = Token(_token);
        stableToken = IBEP20(_stableToken);
        uint8 _stableTokenDecimals = uint8(18) - stableToken.decimals();
        amountScaleDecimals = 10 ** _stableTokenDecimals;
    }

    modifier onlyInvestment() {
        require(investment != address(0),
            "Formation.Fi: zero address");
        require(msg.sender == investment,
            "Formation.Fi: not investment");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager , 
            "Formation.Fi: not manager");
        _;
    }

    /**
     * @dev getter functions.
    */
    function getDepositFee(uint256 _value) public view    
        returns (uint256 _fee){
        _fee = Math.max(Math.mulDiv(depositFeeRate, _value, FACTOR_FEES_DECIMALS), minDepositFee);
        _fee = Math.min(_fee, maxDepositFee);    
    }

    function isManager(address _manager) public view returns(bool) {
        require(_manager != address(0),
            "Formation.Fi: zero address");
        return managers[_manager] ;
    }

    /**
     * @dev Setter functions to update the Portfolio Parameters.
    */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0),
            "Formation.Fi: zero address");
        treasury = _treasury;
    }

    function setManager(address _manager) external onlyOwner {
        require(_manager != address(0),
            "Formation.Fi: zero address");
        manager = _manager ;
    }

    function updateManagers(address _manager, bool _state) external onlyOwner {
        require(_manager != address(0),
            "Formation.Fi: zero address");
        managers[_manager] = _state ;
    }

    function setStableToken(address _stableTokenAddress) external onlyOwner {
        require(_stableTokenAddress != address(0),
            "Formation.Fi: zero address");
        stableToken = IBEP20(_stableTokenAddress);
        uint8 _stableTokenDecimals = uint8(18) - stableToken.decimals();
        amountScaleDecimals = 10 ** _stableTokenDecimals;
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0),
            "Formation.Fi: zero address");
        token = Token(_token);
    }

    function setInvestment(address _investment) external onlyOwner {
        require(_investment!= address(0),
            "Formation.Fi: zero address");
        investment = _investment;
    } 

    function setSafeHouse(address _safeHouse) external onlyOwner {
        require(_safeHouse!= address(0),
            "Formation.Fi: zero address");
        safeHouse = _safeHouse;
    } 

    function setCancel(bool _isCancel) external onlyManager {
        require(_isCancel!= isCancel,
            "Formation.Fi: no change");
        isCancel = _isCancel;
    }
  
    function setLockupPeriodUser(uint256 _lockupPeriodUser) external onlyManager {
        lockupPeriodUser = _lockupPeriodUser;
    }

    function setMaxDepositFee(uint256 _maxDepositFee) 
        external onlyManager {
        maxDepositFee = _maxDepositFee;
    }

    function setMinDepositFee(uint256 _minDepositFee) 
        external onlyManager {
        minDepositFee = _minDepositFee;
    }
 
    function setDepositFeeRate(uint256 _rate) external onlyManager {
        depositFeeRate= _rate;
    }

    function setSlippageTolerance(uint256 _value) external onlyManager {
        slippageTolerance = _value;
    }

    function setManagementFeeRate(uint256 _rate) external onlyManager {
        managementFeeRate = _rate;
    }

    function setPerformanceFeeRate(uint256 _rate) external onlyManager {
        performanceFeeRate  = _rate;
    }
    function setMinAmount(uint256 _minAmount) external onlyManager {
        minAmount= _minAmount;
    }

    function setMaxDepositAmount(uint256 _maxDepositAmount) external 
        onlyManager {
        maxDepositAmount = _maxDepositAmount;

    }
    function setMaxWithdrawalAmount(uint256 _maxWithdrawalAmount) external 
        onlyManager{
         maxWithdrawalAmount = _maxWithdrawalAmount;      
    }

    function updateTokenPrice(uint256 _price) external {
        require (managers[msg.sender] == true,
            "Formation.Fi: no manager");
        require(_price > 0,
            "Formation.Fi: zero price");
        tokenPrice = _price;
    }

    function updateTokenPriceMean(uint256 _price) external onlyInvestment {
        require(_price > 0,
            "Formation.Fi: zero price");
        tokenPriceMean = _price;
    }

    function updateManagementFeeTime(uint256 _time) external onlyInvestment {
        managementFeeTime = _time;
    }
    

    /**
     * @dev Calculate performance Fee.
    */
    function calculateperformanceFee() external {
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require(performanceFee == 0, 
            "Formation.Fi: fees on pending");
        uint256 _deltaPrice;
        if (tokenPrice > tokenPriceMean) {
            _deltaPrice = tokenPrice - tokenPriceMean;
            tokenPriceMean = tokenPrice;
            performanceFee = Math.mulDiv(token.totalSupply(),
            (_deltaPrice * performanceFeeRate), (tokenPrice * FACTOR_FEES_DECIMALS)); 
        }
    }

    /**
     * @dev Calculate management Fee.
    */
    function calculatemanagementFee() external {
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require(managementFee == 0, 
            "Formation.Fi: fees on pending");
        if (managementFeeTime!= 0){
           uint256 _deltaTime;
           _deltaTime = block.timestamp -  managementFeeTime; 
           managementFee = Math.mulDiv(token.totalSupply(), (managementFeeRate * _deltaTime),
           (FACTOR_FEES_DECIMALS * SECONDES_PER_YEAR));
           managementFeeTime = block.timestamp; 
        }
    }
     
    /**
     * @dev Mint Fees.
    */
    function mintFees() external{
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require ((performanceFee + managementFee) > 0, 
            "Formation.Fi: zero fees");
        token.mint(treasury, performanceFee + managementFee);
        performanceFee = 0;
        managementFee = 0;
    }

    /**
     * @dev Calculate net amount Event
     * @param _depositAmountTotal the total requested deposit amount by users.
     * @param  _withdrawalAmountTotal the total requested withdrawal amount by users.
     * @param _maxDepositAmount the maximum accepted deposit amount by event.
     * @param _maxWithdrawalAmount the maximum accepted withdrawal amount by event.
     */
    function calculateNetAmountEvent(uint256 _depositAmountTotal, 
        uint256 _withdrawalAmountTotal, uint256 _maxDepositAmount, 
        uint256 _maxWithdrawalAmount) external onlyInvestment{
        _depositAmountTotal = Math.min(_depositAmountTotal,
         _maxDepositAmount);
        _withdrawalAmountTotal = Math.mulDiv(_withdrawalAmountTotal, tokenPrice, FACTOR_PRICE_DECIMALS);
        _withdrawalAmountTotal= Math.min(_withdrawalAmountTotal,
        _maxWithdrawalAmount);
        if (_depositAmountTotal >= _withdrawalAmountTotal ){
            netDepositInd = 1;
            netAmountEvent = _depositAmountTotal - _withdrawalAmountTotal;
        }
        else {
            netDepositInd = 0;
            netAmountEvent = _withdrawalAmountTotal - _depositAmountTotal;

        }
    }
 
    /**
     * @dev Protect against slippage due to assets sale.
     * @param _withdrawalAmount the value of sold assets in Stablecoin.
     * _withdrawalAmount has to be sent to the contract.
     * treasury has to approve the contract for both Stablecoin and token.
     * @return Missed amount to send to the contract due to slippage.
     */
    function protectAgainstSlippage(uint256 _withdrawalAmount) external  
        returns (uint256) {
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require(_withdrawalAmount != 0, 
            "Formation.Fi: zero amount");
        require(netDepositInd == 0, 
            "Formation.Fi: no slippage");
        uint256 _amount; 
        uint256 _deltaAmount;
        uint256 _slippage;
        uint256  _tokenAmount;
        uint256 _balanceTokenTreasury = token.balanceOf(treasury);
        uint256 _balanceStableTreasury = stableToken.balanceOf(treasury) * amountScaleDecimals;
        if (_withdrawalAmount< netAmountEvent){
            _amount = netAmountEvent - _withdrawalAmount;   
            _slippage = Math.mulDiv(_amount, FACTOR_FEES_DECIMALS, netAmountEvent);
            if (_slippage >= slippageTolerance) {
                return netAmountEvent;
            }
            else {
                _deltaAmount = Math.min( _amount, _balanceStableTreasury);
                if (_deltaAmount > 0){
                    stableToken.safeTransferFrom(treasury, investment, _deltaAmount/amountScaleDecimals);
                    _tokenAmount = Math.mulDiv(_deltaAmount, FACTOR_PRICE_DECIMALS, tokenPrice);
                    token.mint(treasury, _tokenAmount);
                    return _amount - _deltaAmount;
                }
                else {
                     return _amount; 
                }  
            }    
        
        }
        else {
            _amount = _withdrawalAmount - netAmountEvent;   
            _tokenAmount = Math.mulDiv(_amount, FACTOR_PRICE_DECIMALS, tokenPrice);
            _tokenAmount = Math.min(_tokenAmount, _balanceTokenTreasury);
            if (_tokenAmount >0){
                _deltaAmount = Math.mulDiv(_tokenAmount, tokenPrice, FACTOR_PRICE_DECIMALS);
                stableToken.safeTransfer(treasury, _deltaAmount/amountScaleDecimals);   
                token.burn( treasury, _tokenAmount);
            }
            if ((_amount - _deltaAmount) > 0) {
                stableToken.safeTransfer(safeHouse, (_amount - _deltaAmount)/amountScaleDecimals); 
            }
        }
        return 0;

    } 
  
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/Data.sol";

/** 
* @author Formation.Fi.
* @notice The Implementation of the user's deposit proof token {ERC721}.
*/

contract DepositConfirmation is ERC721, Ownable {
    struct PendingDeposit {
        Data.State state;
        uint256 amount;
        uint256 listPointer;
    }
    uint256 public tolerance = 1e3; 
    address public proxyInvestement;
    string public baseURI;
    mapping(address => uint256) private tokenIdPerAddress;
    mapping(address => PendingDeposit) public pendingDepositPerAddress;
    address[] public usersOnPendingDeposit;
    event MintDeposit(address indexed _address, uint256 _id);
    event BurnDeposit(address indexed _address, uint256 _id);
    event UpdateBaseURI( string _baseURI);

    constructor(string memory _name , string memory _symbol)  
    ERC721 (_name,  _symbol){
    }

    modifier onlyProxy() {
        require(
            proxyInvestement != address(0),
            "Formation.Fi: zero address"
        );
        require(msg.sender == proxyInvestement, 
        "Formation.Fi: not proxy");
        _;
    }
    
     /**
     * @dev get the token id of user's address.
     * @param _account The user's address.
     * @return token id.
     */
    function getTokenId(address _account) external view returns (uint256) {
        require(
           _account!= address(0),
            "Formation.Fi: zero address"
        );
        return tokenIdPerAddress[_account];
    }

     /**
     * @dev get the number of users.
     * @return number of users.
     */
    function getUsersSize() external view  returns (uint256) {
        return usersOnPendingDeposit.length;
    }
    
     /**
     * @dev get addresses of users on deposit pending.
     * @return  addresses of users.
     */
    function getUsers() external view returns (address[] memory) {
        return usersOnPendingDeposit;
    }

     /**
     * @dev update the proxy.
     * @param _proxyInvestement the new proxy.
     */
    function setProxy(address _proxyInvestement) external onlyOwner {
        require(
            _proxyInvestement != address(0),
            "Formation.Fi: zero address"
        );
        proxyInvestement = _proxyInvestement;
    }    

    /**
     * @dev update the Metadata URI
     * @param _tokenURI the Metadata URI.
     */
    function setBaseURI(string calldata _tokenURI) external onlyOwner {
        baseURI = _tokenURI;
        emit UpdateBaseURI(_tokenURI);
    }

    function setTolerance(uint256 _value) external onlyOwner {
        tolerance = _value; 
    }

     /**
     * @dev mint the deposit proof ERC721 token.
     * @notice the user receives this token when he makes 
     * a deposit request.
     * Each user's address can at most have one deposit proof token.
     * @param _account The user's address.
     * @param _tokenId The id of the token.
     * @param _amount The deposit amount in the requested Stablecoin.
     * @notice Emits a {MintDeposit} event with `_account` and `_tokenId `.
     */
    function mint(address _account, uint256 _tokenId, uint256 _amount) 
       external onlyProxy {
       require (balanceOf(_account) == 0, "Formation.Fi: deposit token exists");
       _safeMint(_account,  _tokenId);
       updateDepositData( _account,  _tokenId, _amount, true);
       emit MintDeposit(_account, _tokenId);
    }

     /**
     * @dev burn the deposit proof ERC721 token.
     * @notice the token is burned  when the manager fully validates
     * the user's deposit request.
     * @param _tokenId The id of the token.
     * @notice Emits a {BurnDeposit} event with `owner` and `_tokenId `.
     */
    function burn(uint256 _tokenId) internal {
        address owner = ownerOf(_tokenId);
        require (pendingDepositPerAddress[owner].state != Data.State.PENDING,
        "Formation.Fi: deposit token on pending");
        _deleteDepositData(owner);
        _burn(_tokenId); 
        emit BurnDeposit(owner, _tokenId);
    }
     
     /**
     * @dev update the user's deposit data.
     * @notice this function is called after each desposit request 
     * by the user or after each validation by the manager.
     * @param _account The user's address.
     * @param _tokenId The depoist proof token id.
     * @param _amount  The deposit amount to be added or removed.
     * @param isAddCase  = 1 when the user makes a deposit request.
     * = 0, when the manager validates the user's deposit request.
     */
    function updateDepositData(address _account, uint256 _tokenId, 
        uint256 _amount, bool isAddCase) public onlyProxy {
        require (_exists(_tokenId), "Formation.Fi: no token");
        require (ownerOf(_tokenId) == _account , "Formation.Fi:  not owner");
        if(_amount > 0){
           if (isAddCase){
              if(pendingDepositPerAddress[_account].amount == 0){
                  pendingDepositPerAddress[_account].state = Data.State.PENDING;
                  pendingDepositPerAddress[_account].listPointer = usersOnPendingDeposit.length;
                  tokenIdPerAddress[_account] = _tokenId;
                  usersOnPendingDeposit.push(_account);
                }
                pendingDepositPerAddress[_account].amount +=  _amount;
            }
            else {
               require(pendingDepositPerAddress[_account].amount >= _amount, 
               "Formation Fi: amount exceeds balance");
               uint256 _newAmount = pendingDepositPerAddress[_account].amount - _amount;
               pendingDepositPerAddress[_account].amount = _newAmount;
               if (_newAmount <= tolerance){
                  pendingDepositPerAddress[_account].state = Data.State.NONE;
                  burn(_tokenId);
                }
            }
        }
    }    

    
     /**
     * @dev delete the user's deposit proof token data.
     * @notice this function is called when the user's deposit request is fully 
     * validated by the manager.
     * @param _account The user's address.
     */
    function _deleteDepositData(address _account) internal {
        require(
           _account!= address(0),
            "Formation.Fi: zero address"
        );

         uint256 _index = pendingDepositPerAddress[_account].listPointer;
         address _lastUser = usersOnPendingDeposit[usersOnPendingDeposit.length - 1];
         usersOnPendingDeposit[_index] = _lastUser;
         pendingDepositPerAddress[_lastUser].listPointer = _index;
         usersOnPendingDeposit.pop();
         delete pendingDepositPerAddress[_account]; 
         delete tokenIdPerAddress[_account];    
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
    require ((from == address(0)) || (to == address(0)), 
        "Formation.Fi: transfer not allowed");
    }

    /**
     * @dev Get the Metadata URI
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
      
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./libraries/Data.sol";

/** 
* @author Formation.Fi.
* @notice The Implementation of the user's withdrawal proof token {ERC721}.
*/

contract WithdrawalConfirmation is ERC721, Ownable { 
    struct PendingWithdrawal {
        Data.State state;
        uint256 amount;
        uint256 listPointer;
    }
    uint256 public tolerance = 1e3;
    address public proxyInvestement; 
    string public baseURI;
    mapping(address => uint256) private tokenIdPerAddress;
    mapping(address => PendingWithdrawal) public pendingWithdrawPerAddress;
    address[] public usersOnPendingWithdraw;
    event MintWithdrawal(address indexed _address, uint256 _id);
    event BurnWithdrawal(address indexed _address, uint256 _id);
    event UpdateBaseURI( string _baseURI);

    constructor(string memory _name , string memory _symbol)  
    ERC721 (_name,  _symbol){
    }

    modifier onlyProxy() {
        require(
            proxyInvestement != address(0),
            "Formation.Fi: zero address"
        );
        require(msg.sender == proxyInvestement, 
        "Formation.Fi: not proxy");
         _;
    }

     /**
     * @dev get the token id of user's address.
     * @param _account The user's address.
     * @return token id.
     */
    function getTokenId(address _account) external view returns (uint256) {
        return tokenIdPerAddress[ _account];
    }

      /**
     * @dev get the number of users.
     * @return number of users.
     */
     function getUsersSize() external view returns (uint256) {
        return usersOnPendingWithdraw.length;
    }

    /**
     * @dev get addresses of users on withdrawal pending.
     * @return  addresses of users.
     */
    function getUsers() public view returns (address[] memory) {
        return usersOnPendingWithdraw;
    }

    /**
     * @dev update the proxy.
     * @param _proxyInvestement the new proxy.
     */
    function setProxy(address _proxyInvestement) public onlyOwner {
        require(
            _proxyInvestement != address(0),
            "Formation.Fi: zero address"
        );
        proxyInvestement = _proxyInvestement;
    }    

    /**
     * @dev update the Metadata URI
     * @param _tokenURI the Metadata URI.
     */
    function setBaseURI(string calldata _tokenURI) external onlyOwner {
        baseURI = _tokenURI;
        emit UpdateBaseURI(_tokenURI);
    }

    function setTolerance(uint256 _value) external onlyOwner {
        tolerance = _value; 
    }
    
    /**
     * @dev mint the withdrawal proof ERC721 token.
     * @notice the user receives this token when he makes 
     * a withdrawal request.
     * Each user's address can at most have one withdrawal proof token.
     * @param _account The user's address.
     * @param _tokenId The id of the token.
     * @param _amount The withdrawal amount in the product token.
     * @notice Emits a {MintWithdrawal} event with `_account` and `_tokenId `.
     */
    function mint(address _account, uint256 _tokenId, uint256 _amount) 
       external onlyProxy {
       require (balanceOf( _account) == 0, "Formation.Fi: withdrawal token exists");
       _safeMint(_account,  _tokenId);
       tokenIdPerAddress[_account] = _tokenId;
       updateWithdrawalData (_account,  _tokenId,  _amount, true);
       emit MintWithdrawal(_account, _tokenId);
    }

     /**
     * @dev burn the withdrawal proof ERC721 token.
     * @notice the token is burned  when the manager fully validates
     * the user's withdrawal request.
     * @param _tokenId The id of the token.
     * @notice Emits a {BurnWithdrawal} event with `owner` and `_tokenId `.
     */
    function burn(uint256 _tokenId) internal {
        address owner = ownerOf(_tokenId);
        require (pendingWithdrawPerAddress[owner].state != Data.State.PENDING, 
        "Formation.Fi: withdrawal pending on pending");
        _deleteWithdrawalData(owner);
        _burn(_tokenId);   
        emit BurnWithdrawal(owner, _tokenId);
    }

    /**
     * @dev update the user's withdrawal data.
     * @notice this function is called after the withdrawal request 
     * by the user or after each validation by the manager.
     * @param _account The user's address.
     * @param _tokenId The withdrawal proof token id.
     * @param _amount  The withdrawal amount to be added or removed.
     * @param isAddCase  = 1 when teh user makes a withdrawal request.
     * = 0, when the manager validates the user's withdrawal request.
     */
    function updateWithdrawalData (address _account, uint256 _tokenId, 
        uint256 _amount, bool isAddCase) public onlyProxy {
        require (_exists(_tokenId), "Formation Fi: no token");
        require (ownerOf(_tokenId) == _account , 
         "Formation.Fi: not owner");

        if( _amount > 0){
            if (isAddCase){
               pendingWithdrawPerAddress[_account].state = Data.State.PENDING;
               pendingWithdrawPerAddress[_account].amount = _amount;
               pendingWithdrawPerAddress[_account].listPointer = usersOnPendingWithdraw.length;
               usersOnPendingWithdraw.push(_account);
            }
            else {
               require(pendingWithdrawPerAddress[_account].amount >= _amount, 
               "Formation.Fi: amount exceeds balance");
               uint256 _newAmount = pendingWithdrawPerAddress[_account].amount - _amount;
               pendingWithdrawPerAddress[_account].amount = _newAmount;
               if (_newAmount <= tolerance){
                   pendingWithdrawPerAddress[_account].state = Data.State.NONE;
                   burn(_tokenId);
                }
            }     
       }
    }

    /**
     * @dev delete the user's withdrawal proof token data.
     * @notice this function is called when the user's withdrawal request is fully 
     * validated by the manager.
     * @param _account The user's address.
     */
    function _deleteWithdrawalData(address _account) internal {
        require(
          _account!= address(0),
          "Formation.Fi: zero address"
        );
        uint256 _index = pendingWithdrawPerAddress[_account].listPointer;
        address _lastUser = usersOnPendingWithdraw[usersOnPendingWithdraw.length -1];
        usersOnPendingWithdraw[_index] = _lastUser ;
        pendingWithdrawPerAddress[_lastUser].listPointer = _index;
        usersOnPendingWithdraw.pop();
        delete pendingWithdrawPerAddress[_account]; 
        delete tokenIdPerAddress[_account];    
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
    require ((from == address(0)) || (to == address(0)), 
        "Formation.Fi: transfer is not allowed");
    }

    
    /**
     * @dev Get the Metadata URI
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
   
}

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BEP20.sol";
//import "./libraries/Math.sol";
import "@openzeppelin/contracts/utils/math/Math.sol"; 

/** 
* @author Formation.Fi.
* @notice  A common Implementation for tokens ALPHA, BETA and GAMMA.
*/

contract Token is BEP20 {
    struct Deposit{
        uint256 amount;
        uint256 time;
    }
    address public proxyInvestement;
    address private proxyAdmin;

    mapping(address => Deposit[]) public depositPerAddress;
    mapping(address => bool) public  whitelist;
    event SetProxyInvestement(address  _address);
    constructor(string memory _name, string memory _symbol) 
    BEP20(_name,  _symbol) {
    }

    modifier onlyProxy() {
        require(
            (proxyInvestement != address(0)) && (proxyAdmin != address(0)),
            "Formation.Fi: zero address"
        );

        require(
            (msg.sender == proxyInvestement) || (msg.sender == proxyAdmin),
             "Formation.Fi: not the proxy"
        );
        _;
    }
    modifier onlyProxyInvestement() {
        require(proxyInvestement != address(0),
            "Formation.Fi: zero address"
        );

        require(msg.sender == proxyInvestement,
             "Formation.Fi: not the proxy"
        );
        _;
    }

     /**
     * @dev Update the proxyInvestement.
     * @param _proxyInvestement.
     * @notice Emits a {SetProxyInvestement} event with `_proxyInvestement`.
     */
    function setProxyInvestement(address _proxyInvestement) external onlyOwner {
        require(
            _proxyInvestement!= address(0),
            "Formation.Fi: zero address"
        );

         proxyInvestement = _proxyInvestement;

        emit SetProxyInvestement( _proxyInvestement);

    } 

    /**
     * @dev Add a contract address to the whitelist
     * @param _contract The address of the contract.
     */
    function addToWhitelist(address _contract) external onlyOwner {
        require(
            _contract!= address(0),
            "Formation.Fi: zero address"
        );

        whitelist[_contract] = true;
    } 

    /**
     * @dev Remove a contract address from the whitelist
     * @param _contract The address of the contract.
     */
    function removeFromWhitelist(address _contract) external onlyOwner {
         require(
            whitelist[_contract] == true,
            "Formation.Fi: no whitelist"
        );
        require(
            _contract!= address(0),
            "Formation.Fi: zero address"
        );

        whitelist[_contract] = false;
    } 

    /**
     * @dev Update the proxyAdmin.
     * @param _proxyAdmin.
     */
    function setAdmin(address _proxyAdmin) external onlyOwner {
        require(
            _proxyAdmin!= address(0),
            "Formation.Fi: zero address"
        );
        
         proxyAdmin = _proxyAdmin;
    } 


    
    /**
     * @dev add user's deposit.
     * @param _account The user's address.
     * @param _amount The user's deposit amount.
     * @param _time The deposit time.
     */
    function addDeposit(address _account, uint256 _amount, uint256 _time) 
        external onlyProxyInvestement {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

        require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

        require(
            _time!= 0,
            "Formation.Fi: zero time"
        );
        Deposit memory _deposit = Deposit(_amount, _time); 
        depositPerAddress[_account].push(_deposit);
    } 

     /**
     * @dev mint the token product for the user.
     * @notice To receive the token product, the user has to deposit 
     * the required StableCoin in this product. 
     * @param _account The user's address.
     * @param _amount The amount to be minted.
     */
    function mint(address _account, uint256 _amount) external onlyProxy {
        require(
          _account!= address(0),
           "Formation.Fi: zero address"
        );

        require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

       _mint(_account,  _amount);
   }

    /**
     * @dev burn the token product of the user.
     * @notice When the user withdraws his Stablecoins, his tokens 
     * product are burned. 
     * @param _account The user's address.
     * @param _amount The amount to be burned.
     */
    function burn(address _account, uint256 _amount) external onlyProxy {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

         require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

        _burn( _account, _amount);
    }
    
     /**
     * @dev Verify the lock up condition for a user's withdrawal request.
     * @param _account The user's address.
     * @param _amount The amount to be withdrawn.
     * @param _period The lock up period.
     * @return _success  is true if the lock up condition is satisfied.
     */
    function checklWithdrawalRequest(address _account, uint256 _amount, uint256 _period) 
        external view returns (bool _success){
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

        require(
           _amount!= 0,
            "Formation.Fi: zero amount"
        );

        Deposit[] memory _deposit = depositPerAddress[_account];
        uint256 _amountTotal = 0;
        for (uint256 i = 0; i < _deposit.length; i++) {
             require ((block.timestamp - _deposit[i].time) >= _period, 
            "Formation.Fi:  position locked");
            if (_amount<= (_amountTotal + _deposit[i].amount)){
                break; 
            }
            _amountTotal = _amountTotal + _deposit[i].amount;
        }
        _success= true;
    }


     /**
     * @dev update the user's token data.
     * @notice this function is called after each desposit request 
     * validation by the manager.
     * @param _account The user's address.
     * @param _amount The deposit amount validated by the manager.
     */
    function updateTokenData( address _account,  uint256 _amount) 
        external onlyProxyInvestement {
        _updateTokenData(_account,  _amount);
    }

    function _updateTokenData( address _account,  uint256 _amount) internal {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

        require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

        Deposit[] memory _deposit = depositPerAddress[_account];
        uint256 _amountlocal = 0;
        uint256 _amountTotal = 0;
        uint256 _newAmount;
        uint256 k = 0;
        for (uint256 i = 0; i < _deposit.length; i++) {
            _amountlocal  = Math.min(_deposit[i].amount, _amount -  _amountTotal);
            _amountTotal = _amountTotal + _amountlocal;
            _newAmount = _deposit[i].amount - _amountlocal;
            depositPerAddress[_account][k].amount = _newAmount;
            if (_newAmount == 0){
               _deleteTokenData(_account, k);
            }
            else {
                k = k+1;
            }
            if (_amountTotal == _amount){
               break; 
            }
        }
    }
    
     /**
     * @dev delete the user's token data.
     * @notice This function is called when the user's withdrawal request is  
     * validated by the manager.
     * @param _account The user's address.
     * @param _index The index of the user in 'amountDepositPerAddress'.
     */
    function _deleteTokenData(address _account, uint256 _index) internal {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );
        uint256 _size = depositPerAddress[_account].length - 1;
        
        require( _index <= _size,
            "Formation.Fi: index is out"
        );
        for (uint256 i = _index; i< _size; i++){
            depositPerAddress[ _account][i] = depositPerAddress[ _account][i+1];
        }
        depositPerAddress[ _account].pop();   
    }
   
     /**
     * @dev update the token data of both the sender and the receiver 
       when the product token is transferred.
     * @param from The sender's address.
     * @param to The receiver's address.
     * @param amount The transferred amount.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
      ) internal virtual override{
      
       if ((to != address(0)) && (to != proxyInvestement) 
       && (to != proxyAdmin) && (from != address(0)) && (!whitelist[to])){
          _updateTokenData(from, amount);
          Deposit memory _deposit = Deposit(amount, block.timestamp);
          depositPerAddress[to].push(_deposit);
         
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import  "@openzeppelin/contracts/utils/Context.sol";
import './IBEP20.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }


    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);   
       _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

   
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
library Data {

enum State {
        NONE,
        PENDING
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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