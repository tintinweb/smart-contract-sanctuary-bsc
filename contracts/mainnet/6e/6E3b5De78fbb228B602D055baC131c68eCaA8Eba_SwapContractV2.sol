/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/zeppelin/proxy/Initializable.sol

pragma solidity 0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

// File: contracts/zeppelin/access/Ownable.sol

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity 0.8.0;

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // function initialize() internal{
    //     address msgSender = _msgSender();
    //     _owner = msgSender;
    //     emit OwnershipTransferred(address(0), msgSender);
    // }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/zeppelin/token/IERC20.sol

pragma solidity 0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: contracts/Signature.sol

pragma solidity 0.8.0;

contract Signature {
    function getMessageHash(address _token, address _pairToken, address _paymentReceiver, address _to, uint256 _tokenAmount, uint256 _pairTokenAmount, uint256 _cryptoFee, string memory _message, uint _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_token, _pairToken, _paymentReceiver, _to, _tokenAmount, _pairTokenAmount, _cryptoFee, _message, _nonce));
    }
    
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32){
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }
    
    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        ){
        require(sig.length == 65, "invalid signature length");
    
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    
        // implicitly return (r, s, v)
    }
    
    function verify(
        address _signer,
        address _token,
        address _pairToken,
        address _paymentReceiver,
        address _to,
        uint256 _tokenAmount,
        uint256 _pairTokenAmount,
        uint256 _cryptoFee,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_token, _pairToken, _paymentReceiver, _to, _tokenAmount, _pairTokenAmount, _cryptoFee, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }
    
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
}

pragma solidity 0.8.0;

contract SwapContractV2 is Ownable, Signature, Initializable{
    using SafeMath for uint256;
    mapping (address => uint) public nonces;
    address public taxReceiver;
    mapping(address => bool) public controllerAddresses;
    address public immutable WBNB;
    address public immutable FIAT;
    event Swap(address token, address pairToken, uint256 tokenAmount, uint256 pairTokenAmount, address indexed tokenOwner, uint256 cryptoFee);

    modifier onlyControllerOrOwner(){
        require(owner() == _msgSender() || controllerAddresses[_msgSender()] == true, "Ownable: caller is not the owner neither controller.");
        _;
    }

    constructor() {
        WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        FIAT = address(uint160(uint(keccak256(abi.encodePacked(block.timestamp)))));
        taxReceiver = _msgSender();
    }

    receive () external payable{}

    function changeTaxReceiver(address _newTaxReceiver) public onlyOwner{
        require(taxReceiver != address(0));
        taxReceiver = _newTaxReceiver;
    }
    
    function registerNewController(address newController) public onlyOwner{
        require(newController != address(0), "Invalid address");
        require(controllerAddresses[newController] == false, "Controller is already registered.");
        controllerAddresses[newController] = true;
    }

    function unregisterController(address controller) public onlyOwner{
        require(controller != address(0), "Invalid address");
        require(controllerAddresses[controller] == true, "Controller is not registered.");
        delete controllerAddresses[controller];
    }

    function contractTokenBalance(address token) public view returns(uint256){
        if(token == WBNB){
            return contractCryptoBalance();
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }

    function contractCryptoBalance() public view returns(uint256){
      return address(this).balance;
    }

    function swapTokenPerTokenBySig(address token, address pairToken, address paymentReceiver, uint256 tokenAmount, uint256 pairTokenAmount, uint256 _cryptoFee, address signer, string memory message, uint nonce, bytes memory signature) public payable {
        address tokenOwner = _msgSender();
        require(signer == owner() || controllerAddresses[signer] == true, "Signer must be owner or controller address");
        require(token != address(0), "Invalid payment token address");
        require(verify(signer, token, pairToken, paymentReceiver, tokenOwner, tokenAmount, pairTokenAmount, _cryptoFee, message, nonce, signature), "The signer must be the controller address");
        require(nonce == nonces[tokenOwner]++, "invalid nonce");
        require(IERC20(token).allowance(tokenOwner, address(this)) >= tokenAmount, "Token amount exceeds allowance");
        require(tokenOwner != address(0), "Invalid tokenOwner address");
        require(tokenAmount > 0, "Token amount too low.");
        require(pairTokenAmount > 0, "PairToken amount too low.");
        require(tokenAmount <= IERC20(token).balanceOf(tokenOwner), "Insuficient balance for payment amount");
        require(pairTokenAmount <= IERC20(pairToken).balanceOf(address(this)), "There is no liquidity for this pairToken amount.");
        require(msg.value >= _cryptoFee, "Insuficient bnb amount for fee");
        // Transfering tax
        (bool sent,) = taxReceiver.call{value: msg.value}("");
        require(sent, "Failed to send Crypto");
        // Transfering payment
        IERC20(token).transferFrom(tokenOwner, paymentReceiver, tokenAmount);
        // Sending token
        IERC20(pairToken).transfer(tokenOwner, pairTokenAmount);
        // Emitting event
        emit Swap(token, pairToken, tokenAmount, pairTokenAmount, tokenOwner, _cryptoFee);
    }

    function swapCryptoPerTokenBySig(address pairToken, uint256 cryptoAmount, address paymentReceiver, uint256 pairTokenAmount, uint256 _cryptoFee, address signer, string memory message, uint nonce, bytes memory signature) public payable {
        require(signer == owner() || controllerAddresses[signer] == true, "Signer must be owner or controller address");
        require(verify(signer, WBNB, pairToken, paymentReceiver, _msgSender(), cryptoAmount, pairTokenAmount, _cryptoFee, message, nonce, signature), "The signer must be the controller address");
        require(nonce == nonces[_msgSender()]++, "invalid nonce");
        require(_msgSender() != address(0), "Invalid cryptoOwner address");
        require(cryptoAmount > 0, "Token amount too low.");
        require(pairTokenAmount > 0, "PairToken amount too low.");
        require(pairTokenAmount <= IERC20(pairToken).balanceOf(address(this)), "There is no liquidity for this pairToken amount.");
        require(msg.value >= cryptoAmount, "Crypto value sent is different than parameter crypto amount.");
        require(msg.value > _cryptoFee, "Insuficient crypto amount for fee");
        uint256 finalValueToSend = msg.value.sub(_cryptoFee);
        // Transfering tax
        (bool sentTax,) = taxReceiver.call{value: _cryptoFee}("");
        require(sentTax, "Failed to send Crypto tax");
        // Transfering payment
        (bool sent,) = paymentReceiver.call{value: finalValueToSend}("");
        require(sent, "Failed to send Crypto payment");
        // Sending token
        IERC20(pairToken).transfer(_msgSender(), pairTokenAmount);
        // Emitting event
        emit Swap(WBNB, pairToken, cryptoAmount, pairTokenAmount, _msgSender(), _cryptoFee);
    }

    function swapTokenPerCryptoBySig(address token, address paymentReceiver, uint256 tokenAmount, uint256 pairCryptoAmount, uint256 _cryptoFee, address signer, string memory message, uint nonce, bytes memory signature) public payable{
        address tokenOwner = _msgSender();
        require(signer == owner() || controllerAddresses[signer] == true, "Signer must be owner or controller address");
        require(verify(signer, token, WBNB, paymentReceiver, tokenOwner, tokenAmount, pairCryptoAmount, _cryptoFee, message, nonce, signature), "The signer must be the controller address");
        require(nonce == nonces[tokenOwner]++, "invalid nonce");
        require(tokenOwner != address(0), "Invalid tokenOwner address");
        require(tokenAmount > 0, "Token amount too low.");
        require(pairCryptoAmount > 0, "PairToken amount too low.");
        require(pairCryptoAmount <= address(this).balance, "There is no liquidity for this pairToken amount.");
        require(tokenAmount <= IERC20(token).balanceOf(tokenOwner), "Insuficient balance for payment amount.");
        require(msg.value >= _cryptoFee, "Insuficient crypto amount for fee");
        // Transfering tax
        (bool sentTax,) = taxReceiver.call{value: msg.value}("");
        require(sentTax, "Failed to send Crypto");
        // Transfering payment
        IERC20(token).transferFrom(tokenOwner, paymentReceiver, tokenAmount);
        // Sending crypto
        (bool sent,) = tokenOwner.call{value: pairCryptoAmount}("");
        require(sent, "Failed to send Crypto");
        // Emitting event
        emit Swap(token, WBNB, tokenAmount, pairCryptoAmount, tokenOwner, _cryptoFee);
    }

    function swapFiatPerTokenBySig(address token, address pairToken, address paymentReceiver, uint256 tokenAmount, uint256 pairTokenAmount, uint256 cryptoFee, address signer, string memory message, uint256 nonce, bytes memory signature) public payable{
        require(token == FIAT, "Token must be unknown");
        require(verify(signer, token, pairToken, paymentReceiver, _msgSender(), tokenAmount, pairTokenAmount, cryptoFee, message, nonce, signature), "The signer must be the controller address");
        require(signer == owner() || controllerAddresses[signer] == true, "Signer must be owner or controller address");
        require(nonce == nonces[_msgSender()]++, "invalid nonce");
        require(tokenAmount > 0, "Token amount too low.");
        require(pairTokenAmount > 0, "PairToken amount too low.");
        require(pairTokenAmount <= IERC20(pairToken).balanceOf(address(this)), "There is no liquidity for this pairToken amount.");
        require(msg.value >= cryptoFee, "Insuficient crypto amount for fee");

        // Transfering tax
        (bool sentTax,) = taxReceiver.call{value: msg.value}("");
        require(sentTax, "Failed to send Crypto");

        // Sending token
        IERC20(pairToken).transfer(_msgSender(), pairTokenAmount);

        // Emitting event
        emit Swap(FIAT, pairToken, tokenAmount, pairTokenAmount, _msgSender(), cryptoFee);
    }

    function transferTokenPayingBNBFee(address token, address _to, uint256 _amount, uint256 _cryptoFee) public payable{
        require(msg.value >= _cryptoFee, "Insuficient crypto amount for fee");
        require(IERC20(token).allowance(_msgSender(), address(this)) >= _amount, "Token amount exceeds allowance");
        (bool sent,) = taxReceiver.call{value: msg.value}("");
        require(sent, "Failed to send Crypto");
        IERC20(token).transferFrom(_msgSender(), _to, _amount);
    }

    function transferCryptoPayingBNBFee(address _to, uint256 _cryptoFee) public payable{
        require(msg.value > _cryptoFee, "Insuficient crypto amount for fee");
        uint256 finalValueToSend = msg.value.sub(_cryptoFee);
        (bool sentTax,) = taxReceiver.call{value: _cryptoFee}("");
        require(sentTax, "Failed to send Crypto");
        (bool sent,) = _to.call{value: finalValueToSend}("");
        require(sent, "Failed to send Crypto");
    }

    function withdrawTokenBalance(address token, address _to, uint256 _amount) public onlyOwner{
        uint256 _contractTokenBalance = contractTokenBalance(token);
        require(_contractTokenBalance > 0, "Contract token balance is zero");
        require(_contractTokenBalance >= _amount, "Amount is greater than contract token balance");
        IERC20(token).transfer(_to, _amount);
    }

    function withdrawCrypto(uint256 _amount) public onlyOwner{
        uint256 _contractCryptoBalance = contractCryptoBalance();
        require(_contractCryptoBalance > 0, "Contract crypto balance is zero");
        require(_contractCryptoBalance >= _amount, "Amount is greater than available.");
        (bool sent,) = owner().call{value: _amount}("");
        require(sent, "Failed to send Crypto");
    }
}