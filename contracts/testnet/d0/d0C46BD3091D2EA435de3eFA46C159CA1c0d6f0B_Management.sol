// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IManagement.sol";

contract Management is IManagement, Ownable {
    uint256 public constant FEE_DENOMINATOR = 10**4;

    // fee = feeNumerator / FEE_DENOMINATOR. Supposed the fee is 25% then feeNumerator is set to 2500
    uint256 public feeNumerator;

    // referralFee = referralFeeNumerator / FEE_DENOMINATOR.
    uint256 public referralFeeNumerator;

    // the period of time a business between booking and paying it
    uint256 public payoutDelay;

    // the address that have an authority to deploy Property contracts
    address public operator;

    // the treasury address that receives fee and payments
    address public treasury;

    // the verifier address to verify signatures
    address public verifier;

    // factory contract address
    address public factory;

    // EIP712 contract address
    address public eip712;

    // list of supported payment ERC20 tokens
    mapping(address => bool) public paymentToken;

    constructor(
        uint256 _feeNumerator,
        uint256 _referralFeeNumerator,
        uint256 _paymentDelay,
        address _operator,
        address _treasury,
        address _verifier,
        address[] memory _tokens
    ) {
        require(
            _feeNumerator < FEE_DENOMINATOR &&
                _feeNumerator > _referralFeeNumerator,
            "InvalidFee"
        );
        require(
            _operator != address(0) &&
                _treasury != address(0) &&
                _verifier != address(0),
            "ZeroAddress"
        );
        feeNumerator = _feeNumerator;
        referralFeeNumerator = _referralFeeNumerator;
        payoutDelay = _paymentDelay;
        operator = _operator;
        treasury = _treasury;
        verifier = _verifier;

        for (uint256 i = 0; i < _tokens.length; i++) {
            paymentToken[_tokens[i]] = true;
        }
    }

    /**
       @notice Get admin address or contract owner
       @dev    Caller can be ANYONE
     */
    function admin() external view returns (address) {
        return owner();
    }

    /**
        @notice Set fee ratio
        @dev Caller must be ADMIN
        @param _feeNumerator the fee numerator
    */
    function setFeeRatio(uint256 _feeNumerator) external onlyOwner {
        require(
            _feeNumerator < FEE_DENOMINATOR &&
                _feeNumerator > referralFeeNumerator,
            "InvalidFee"
        );

        feeNumerator = _feeNumerator;

        emit NewFeeNumerator(_feeNumerator);
    }

    /**
        @notice Set referral fee ratio
        @dev Caller must be ADMIN and the referral fee must not be greater than the overall fee
        @param _feeNumerator the fee numerator
     */
    function setReferralFeeRatio(uint256 _feeNumerator) external onlyOwner {
        require(_feeNumerator < feeNumerator, "InvalidReferralFee");

        referralFeeNumerator = _feeNumerator;

        emit NewReferralFeeNumerator(_feeNumerator);
    }

    /**
        @notice Set payment delay period
        @dev Caller must be ADMIN
        @param _period the payment delay period
    */
    function setPayoutDelay(uint256 _period) external onlyOwner {
        payoutDelay = _period;

        emit NewPayoutDelay(_period);
    }

    /**
       @notice Set manager address
       @dev    Caller must be ADMIN
       @param _newOperator Address of new manager
     */
    function setOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0), "ZeroAddress");

        operator = _newOperator;

        emit NewOperator(_newOperator);
    }

    /**
       @notice Set treasury address
       @dev    Caller must be ADMIN
       @param _newTreasury Address of new treasury
     */
    function setTreasury(address _newTreasury) external onlyOwner {
        require(_newTreasury != address(0), "ZeroAddress");

        treasury = _newTreasury;

        emit NewTreasury(_newTreasury);
    }

    /**
       @notice Set verifier address
       @dev    Caller must be ADMIN
       @param _newVerifier Address of new verifier
     */
    function setVerifier(address _newVerifier) external onlyOwner {
        require(_newVerifier != address(0), "ZeroAddress");

        verifier = _newVerifier;

        emit NewVerifier(_newVerifier);
    }

    /**
       @notice Set factory contract address
       @dev    Caller must be ADMIN
       @param _factory Address of new factory
     */
    function setFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "ZeroAddress");

        factory = _factory;

        emit NewFactory(_factory);
    }

    /**
       @notice Set EIP-712 contract address
       @dev    Caller must be ADMIN
       @param _eip712 Address of new factory
     */
    function setEIP712(address _eip712) external onlyOwner {
        require(_eip712 != address(0), "ZeroAddress");

        eip712 = _eip712;

        emit NewEIP712(_eip712);
    }

    /**
       @notice add a new token/native coin to list of payment tokens
       @dev    Caller must be ADMIN
       @param _token new token address
     */
    function addPayment(address _token) external onlyOwner {
        require(_token != address(0), "ZeroAddress");
        require(!paymentToken[_token], "PaymentExisted");

        paymentToken[_token] = true;

        emit PaymentTokensAdd(_token);
    }

    /**
       @notice Remove a token/native coin from list of payment tokens
       @dev    Caller must be ADMIN
       @param _token token address to remove
     */
    function removePayment(address _token) external onlyOwner {
        require(_token != address(0), "ZeroAddress");
        require(paymentToken[_token], "PaymentNotFound");

        paymentToken[_token] = false;

        emit PaymentTokensRemove(_token);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IManagement {
    function feeNumerator() external returns (uint256);

    function referralFeeNumerator() external returns (uint256);

    function payoutDelay() external returns (uint256);

    function operator() external returns (address);

    function treasury() external returns (address);

    function verifier() external returns (address);

    function factory() external returns (address);

    function eip712() external returns (address);

    function paymentToken(address) external returns (bool);

    function admin() external returns (address);

    function setReferralFeeRatio(uint256 _feeNumerator) external;

    function setFeeRatio(uint256 _feeNumerator) external;

    function setPayoutDelay(uint256 _period) external;

    function setOperator(address _newManager) external;

    function setTreasury(address _newTreasury) external;

    function setVerifier(address _newVerifier) external;

    function setFactory(address _factory) external;

    function setEIP712(address _eip712) external;

    function addPayment(address _token) external;

    function removePayment(address _token) external;

    event NewFeeNumerator(uint256 feeNumerator);

    event NewReferralFeeNumerator(uint256 feeNumerator);

    event NewPayoutDelay(uint256 payoutDelay);

    event NewOperator(address indexed manager);

    event NewTreasury(address indexed treasury);

    event NewVerifier(address indexed verifier);

    event NewFactory(address indexed factory);

    event NewEIP712(address indexed eip712);

    event PaymentTokensAdd(address indexed token);

    event PaymentTokensRemove(address indexed token);
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