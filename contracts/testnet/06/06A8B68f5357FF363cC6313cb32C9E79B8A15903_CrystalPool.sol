/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// File: libraries/SignatureVerifier.sol


pragma solidity ^0.8.0;

library SignatureVerifier {

  function getSigner(bytes32 _messageHash, bytes memory _signature) internal pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
    return ecrecover(_messageHash, v, r, s);
  }

  function splitSignature(bytes memory sig)
    internal
    pure
    returns (
      bytes32 r,
      bytes32 s,
      uint8 v
    )
  {
    require(sig.length == 65, "invalid signature length");
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }
  }
  

}
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: WithSigner.sol


pragma solidity ^0.8.0;



abstract contract WithSigner is Context, Ownable {
  address private _signer;

  event SignerTransferred(address indexed previousSigner, address indexed newSigner);

  /**
   * @dev Initializes the contract setting the deployer as the initial signer.
   */
  constructor(address _newSigner) {
    _transferSigner(_newSigner);
  }

  /**
   * @dev Returns the address of the current signer.
   */
  function signer() public view virtual returns (address) {
    return _signer;
  }

  /**
   * @dev Transfers signer of the contract to a new account (`_newSigner`).
   * Can only be called by the current owner.
   */
  function transferSigner(address _newSigner) public virtual onlyOwner {
    require(_newSigner != address(0), "WithSigner: new signer is the zero address");
    _transferSigner(_newSigner);
  }

  /**
   * @dev Transfers signer of the contract to a new account (`_newSigner`).
   * Internal function without access restriction.
   */
  function _transferSigner(address _newSigner) internal virtual {
    address oldSigner = _signer;
    _signer = _newSigner;
    emit SignerTransferred(oldSigner, _newSigner);
  }
}

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: lockTokens/CrystalPool.sol


pragma solidity 0.8.15;






contract CrystalPool is Ownable, Pausable, WithSigner {
    using SignatureVerifier for bytes32;
    struct userData {
        address previusOwner;
        bool isBlock;
    }
    uint public maxProfitDeposit;

    mapping(bytes32 => bool) usedKeys;
    mapping(IERC20 => bool) public isTokenWhitelisted;
    mapping(address => bool) public isWhitelistedAddress;
    mapping(IERC20 => mapping(address => uint256)) public totalDeposits;
    mapping(IERC20 => mapping(address => uint256)) public lastDepositAmount;
    mapping(IERC20 => mapping(address => uint256)) public totalWitdraws; //can be more with totalDeposits

    modifier onlyWhitelistedTokens(IERC20 _token) {
        require(
            isTokenWhitelisted[_token],
            "MARKETPLACE: Token address not whitelisted"
        );
        _;
    }

    event Deposit(IERC20 _token, uint256 _amount, address _from);
    event Unlock(IERC20 _token, uint256 _amount, address _to);
    event Withdraw(IERC20 _token, uint256 _amount, address _to);

    // WithSigner(_signer) add in constructor
    constructor(IERC20[] memory _tokens,address _signer) WithSigner(_signer) {
        whitelistTokens(_tokens);
    }

    function whitelistTokens(IERC20[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isTokenWhitelisted[_tokens[i]] = true;
        }
    }

    function blacklistTokens(IERC20[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isTokenWhitelisted[_tokens[i]] = false;
        }
    }


    function whitelistAddress(address[] memory _Address) public onlyOwner {
        for (uint256 i = 0; i < _Address.length; i++) {
            isWhitelistedAddress[_Address[i]] = true;
        }
    }

    function blacklistAddress(address[] memory _Address) public onlyOwner {
        for (uint256 i = 0; i < _Address.length; i++) {
            isWhitelistedAddress[_Address[i]] = false;
        }
    }

    //Deposit
    function deposit(
        IERC20 _token, 
        uint256 _depositAmount,        
        bytes memory _signature,
        bytes32 _idempotencyKey
    )
        public
        onlyWhitelistedTokens(_token)
        returns (bool)
    {   
        bool house = isWhitelistedAddress[msg.sender];
        require( !house , "Only for users, you can use witdraw function");
        require(_token.transferFrom(msg.sender, address(this), _depositAmount));
        bool used = getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bool isPermitValid = validateData(_signature,_idempotencyKey, _depositAmount);
        require(isPermitValid, "No signer match");

        totalDeposits[_token][msg.sender] += _depositAmount;
        lastDepositAmount[_token][msg.sender] = _depositAmount;
        maxProfitDeposit = (_depositAmount * 10)/100;

        setUsedKeys(_idempotencyKey);
        emit Deposit(_token, _depositAmount, msg.sender);
        return true;
    }

    //unlock
    function unLock(
        IERC20 _token,
        uint256 _unLockAmount,
        bytes memory _signature,
        bytes32 _idempotencyKey
    ) public onlyWhitelistedTokens(_token) returns (bool) {
        bool house = isWhitelistedAddress[msg.sender];
        require( !house , "Only for users, you can use witdraw function");
        bool used = getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bool isPermitValid = validateData(_signature,_idempotencyKey, _unLockAmount);
        require(isPermitValid, "No signer match");
        
        totalWitdraws[_token][msg.sender] += _unLockAmount;
        _token.transfer(msg.sender, _unLockAmount);

        setUsedKeys(_idempotencyKey);
        emit Unlock(_token, _unLockAmount, msg.sender);
        return true;
    }

    function withdraw(
        IERC20 _token,
        uint256 _withdrawAmount,
        bytes memory _signature,
        bytes32 _idempotencyKey        
    ) public {
        require( isWhitelistedAddress[msg.sender] , "Only for admins, you can use unLock function");
        bool used = getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bool isPermitValid = validateData(_signature,_idempotencyKey, _withdrawAmount);
        require(isPermitValid, "No signer match");
        require(_withdrawAmount < maxProfitDeposit, "More of the max permit");

        maxProfitDeposit -= _withdrawAmount;
        _token.transfer(msg.sender, maxProfitDeposit);
        emit Withdraw(_token, _withdrawAmount, msg.sender);
    }

    function getUsedKeys(bytes32 _key) internal view  returns (bool) {
        return usedKeys[_key];
    }

    function setUsedKeys(bytes32 _key) internal {
        usedKeys[_key] = true;
    }

    function validateData(
        bytes memory _signature,
        bytes32 _idempotencyKey,
        uint _amount
    ) public view returns (bool) {
        bool used = getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bytes32 hash = getHash(_idempotencyKey, address(this), _amount);
        bytes32 messageHash = getEthSignedHash(hash);
        bool isPermitValid = verify(signer(), messageHash, _signature);
        return isPermitValid;
    }

    function getHash(
        bytes32 _idempotencyKey,
        address contractID,
        uint _amount
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(_idempotencyKey, contractID, _amount)
            );
    }

    function getEthSignedHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verify(
        address signer,
        bytes32 messageHash,
        bytes memory _signature
    ) public pure returns (bool) {
        return messageHash.getSigner(_signature) == signer;
    }
}