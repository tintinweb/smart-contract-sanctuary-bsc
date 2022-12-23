// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error TokenExists();
error TokenNotFound();
error ReetrantCall();
error NotOwner();
error TransferFailed();
error InsufficientBalance();
error NeedsMoreThanZero();
error OwnerIsZeroAddress();
error ReceiverAddressLengthNotEqualWithSalaryAmountLength();
error EmptyPayrollDataNotAllowed();
error AddressNotValid();

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract KonnadexMultiSender {
    using SafeMath for uint256;
    EnteredState private status;
    address payable private owner;
    uint256 private salaryCharge;
    uint256 private feeAmountConverter;
    mapping(bytes8 => address) public tokens;

    enum EnteredState {
        ENTERED,
        NOT_ENTERED
    }
    event OwnershipTransferred(address oldOwner, address newOwner);

    event BulkPaymentSuccessful(
        bytes indexed _paymentReference,
        address indexed _tokenAddress,
        address indexed _caller,
        uint256 _recipientCount,
        uint256 _totalTokensSent,
        uint256 _feeAmount,
        address _feeAddress
    );

    event SalaryChargeChanged(
        address indexed _caller,
        uint256 _oldPrice,
        uint256 _newPrice
    );
    event NativeTokenMoved(
        address indexed _caller,
        address indexed _to,
        uint256 _amount,
        address indexed _tokenAddress
    );
    event TokensMoved(
        address indexed _caller,
        address indexed _to,
        uint256 _amount,
        address indexed _tokenAddress
    );
    event TokenAdded(bytes8 _symbol, address indexed _tokenAddress);
    event TransferNativeTokenFailed(
        address indexed _caller,
        bytes indexed _paymentReference,
        uint256 totalTokensSent,
        address indexed _reciepientAddress,
        uint256 _amount
    );

    event SingleSalaryPaymentSuccessful(
        bytes indexed _paymentReference,
        address indexed _tokenAddress,
        address indexed _caller,
        address _receiver,
        uint256 _totalTokensSent,
        uint256 _feeAmount,
        address _feeAddress,
        bool _shouldSenderPayFee
    );

    /**
     * Constructor function
     *
     * Initializes contract with salary charge.
     */
    constructor(uint256 _salaryCharge, uint256 _feeAmountConverter) {
        status = EnteredState.NOT_ENTERED;
        owner = payable(msg.sender);
        salaryCharge = _salaryCharge;
        feeAmountConverter = _feeAmountConverter;
    }

    modifier onlyUnsetToken(bytes8 symbol) {
        if (tokens[symbol] != address(0)) {
            revert TokenExists();
        }
        _;
    }

    modifier onlyValidAddress(address _address) {
        if (_address == address(0)) {
            revert AddressNotValid();
        }
        _;
    }

    modifier onlySetToken(bytes8 symbol) {
        if (tokens[symbol] == address(0)) {
            revert TokenNotFound();
        }
        _;
    }
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
    modifier nonReentrant() {
        if (status == EnteredState.ENTERED) {
            revert ReetrantCall();
        }
        status = EnteredState.ENTERED;
        _;
        status = EnteredState.NOT_ENTERED;
    }

    function addToken(bytes8 _symbol, address _tokenAddress)
        external
        onlyOwner
        onlyUnsetToken(_symbol)
    {
        tokens[_symbol] = _tokenAddress;
        emit TokenAdded(_symbol, _tokenAddress);
    }

    function removeToken(bytes8 _symbol)
        external
        onlyOwner
        onlySetToken(_symbol)
    {
        delete (tokens[_symbol]);
    }

    function getTokenBalance(bytes8 _symbol)
        public
        view
        onlySetToken(_symbol)
        returns (uint256)
    {
        return IERC20(tokens[_symbol]).balanceOf(address(this));
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * Distribute tokens
     *
     * Send `_salaryAmounts` tokens to `_addresses` from your account
     *
     * @param _addresses The address of the recipient
     * @param _salaryAmounts the amount to send
     * @param _reference the unique indentifier
     * @param _symbol token symbol
     **/
    function distributeToken(
        bytes calldata _reference,
        bytes8 _symbol,
        address[] calldata _addresses,
        uint256[] calldata _salaryAmounts
    ) external payable onlySetToken(_symbol) nonReentrant returns (bool) {
        if (_addresses.length != _salaryAmounts.length) {
            revert ReceiverAddressLengthNotEqualWithSalaryAmountLength();
        }
        if (_addresses.length == 0) {
            revert EmptyPayrollDataNotAllowed();
        }
        uint256 totalAmount = 0;
        for (uint256 index = 0; index < _salaryAmounts.length; index++) {
            totalAmount = totalAmount.add(_salaryAmounts[index]);
            require(_salaryAmounts[index] > 0, "Value invalid");
        }

        if (IERC20(tokens[_symbol]).balanceOf(msg.sender) <= totalAmount) {
            revert InsufficientBalance();
        }

        uint256 totalTokensSent = 0;
        uint256 feeAmount = (salaryCharge.mul(totalAmount)).div(
            feeAmountConverter
        );
        //send fee to contract
        IERC20(tokens[_symbol]).transferFrom(msg.sender, owner, feeAmount);
        for (uint256 i = 0; i < _addresses.length; i += 1) {
            require(_addresses[i] != address(0), "Address invalid");

            if (
                !IERC20(tokens[_symbol]).transferFrom(
                    msg.sender,
                    _addresses[i],
                    _salaryAmounts[i]
                )
            ) {
                revert TransferFailed();
            }
            totalTokensSent = totalTokensSent.add(_salaryAmounts[i]);
        }

        emit BulkPaymentSuccessful(
            _reference,
            tokens[_symbol],
            msg.sender,
            _addresses.length,
            totalTokensSent,
            feeAmount,
            owner
        );
        return true;
    }

    /**
     * Distribute Native tokens
     *
     * Send `_salaryAmounts` tokens to `_addresses` from your account
     *
     * @param _addresses The address of the recipient
     * @param _salaryAmounts the amount to send
     * @param _reference the unique indentifier
     **/

    function distributeNativeCoin(
        bytes calldata _reference,
        address[] calldata _addresses,
        uint256[] calldata _salaryAmounts
    ) external payable nonReentrant returns (bool) {
        if (_addresses.length != _salaryAmounts.length) {
            revert ReceiverAddressLengthNotEqualWithSalaryAmountLength();
        }
        if (_addresses.length == 0) {
            revert EmptyPayrollDataNotAllowed();
        }
        uint256 totalAmount = 0;
        for (uint256 index = 0; index < _salaryAmounts.length; index++) {
            totalAmount = totalAmount.add(_salaryAmounts[index]);
            require(_salaryAmounts[index] > 0, "Value invalid");
        }
        if (msg.value <= totalAmount) {
            revert InsufficientBalance();
        }
        uint256 totalTokensSent = 0;
        uint256 feeAmount = (salaryCharge.mul(totalAmount)).div(
            feeAmountConverter
        );

        //send fee to contract
        payable(owner).transfer(feeAmount);
        for (uint256 i = 0; i < _addresses.length; i += 1) {
            require(_addresses[i] != address(0), "Address invalid");
            (bool sent, ) = payable(_addresses[i]).call{
                value: _salaryAmounts[i]
            }("");
            if (!sent) {
                revert TransferFailed();
            }

            totalTokensSent = totalTokensSent.add(_salaryAmounts[i]);
        }

        emit BulkPaymentSuccessful(
            _reference,
            address(this),
            msg.sender,
            _addresses.length,
            totalTokensSent,
            feeAmount,
            owner
        );
        return true;
    }

    function moveNativeTokens(address payable _account)
        external
        onlyOwner
        returns (bool)
    {
        uint256 contractBalance = address(this).balance;
        (bool sendBackSuccess, ) = _account.call{value: contractBalance}("");
        require(
            sendBackSuccess,
            "Could not send remaining funds to the receiver"
        );
        emit NativeTokenMoved(
            msg.sender,
            _account,
            contractBalance,
            address(this)
        );
        return true;
    }

    function moveTokens(bytes8 _symbol, address _account)
        external
        onlyOwner
        onlySetToken(_symbol)
        returns (bool)
    {
        uint256 contractTokenBalance = IERC20(tokens[_symbol]).balanceOf(
            address(this)
        );
        IERC20(tokens[_symbol]).transfer(_account, contractTokenBalance);
        emit TokensMoved(
            msg.sender,
            _account,
            contractTokenBalance,
            tokens[_symbol]
        );
        return true;
    }

    function transferOwnership(address payable _newOwner)
        public
        virtual
        onlyOwner
    {
        if (_newOwner == address(0)) {
            revert OwnerIsZeroAddress();
        }
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    function getFeeConverter() public view returns (uint256) {
        return feeAmountConverter;
    }

    function setFeeAmountConverter(uint256 _feeConverter)
        external
        onlyOwner
        returns (uint256)
    {
        feeAmountConverter = _feeConverter;
        return feeAmountConverter;
    }

    function setSalaryCharge(uint256 _newSalaryCharge)
        external
        onlyOwner
        returns (bool)
    {
        uint256 oldPrice = salaryCharge;
        salaryCharge = _newSalaryCharge;
        emit SalaryChargeChanged(msg.sender, oldPrice, _newSalaryCharge);
        return true;
    }

    function getSalaryCharge() public view returns (uint256) {
        return salaryCharge;
    }

    //================================Single payment for employee====================================

    function paySingleEmployee(
        bytes calldata _reference,
        address _to,
        uint256 _amount,
        bytes8 _symbol,
        bool _senderShouldBearCharge
    )
        external
        payable
        moreThanZero(_amount)
        onlySetToken(_symbol)
        onlyValidAddress(_to)
        nonReentrant
        returns (bool)
    {
        if (
            _senderShouldBearCharge &&
            IERC20(tokens[_symbol]).balanceOf(msg.sender) <= _amount
        ) {
            revert InsufficientBalance();
        }
        if (
            !_senderShouldBearCharge &&
            IERC20(tokens[_symbol]).balanceOf(msg.sender) < _amount
        ) {
            revert InsufficientBalance();
        }

        uint256 feeAmount = (salaryCharge.mul(_amount)).div(feeAmountConverter);
        uint256 recipientAmount = 0;
        //send fee to contract
        IERC20(tokens[_symbol]).transferFrom(msg.sender, owner, feeAmount);
        if (_senderShouldBearCharge) {
            recipientAmount = _amount;
        }
        if (!_senderShouldBearCharge) {
            recipientAmount = _amount.sub(feeAmount);
        }
        if (
            !IERC20(tokens[_symbol]).transferFrom(
                msg.sender,
                _to,
                recipientAmount
            )
        ) {
            revert TransferFailed();
        }

        emit SingleSalaryPaymentSuccessful(
            _reference,
            tokens[_symbol],
            msg.sender,
            _to,
            recipientAmount,
            feeAmount,
            owner,
            _senderShouldBearCharge
        );
        return true;
    }

    function paySingleEmployeeWithNativeToken(
        bytes calldata _reference,
        address _to,
        uint256 _amount,
        bool _senderShouldBearCharge
    )
        external
        payable
        moreThanZero(_amount)
        onlyValidAddress(_to)
        nonReentrant
        returns (bool)
    {
        //if employer should bear the charge..his balance must be greater than the amount because of charges.
        if (_senderShouldBearCharge && msg.value <= _amount) {
            revert InsufficientBalance();
        }
        //if the employee should bear the charge
        if (!_senderShouldBearCharge && msg.value < _amount) {
            revert InsufficientBalance();
        }

        uint256 feeAmount = (salaryCharge.mul(_amount)).div(feeAmountConverter);
        uint256 recipientAmount = 0;

        if (_senderShouldBearCharge) {
            recipientAmount = _amount;
        }
        if (!_senderShouldBearCharge) {
            recipientAmount = _amount - feeAmount;
        }
        //send fee to contract
        payable(owner).transfer(feeAmount);
        // uint256 contractBalance = address(this).balance;

        (bool sent, ) = payable(_to).call{value: recipientAmount}("");
        if (!sent) {
            revert TransferFailed();
        }

        emit SingleSalaryPaymentSuccessful(
            _reference,
            address(this),
            msg.sender,
            _to,
            recipientAmount,
            feeAmount,
            owner,
            _senderShouldBearCharge
        );
        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}