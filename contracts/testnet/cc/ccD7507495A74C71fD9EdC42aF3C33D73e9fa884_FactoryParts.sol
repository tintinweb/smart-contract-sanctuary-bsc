/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


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

// File: libraries/MedapartMetadata.sol


pragma solidity ^0.8.0;

library MedapartMetadata {
  struct Metadata {
    Part partId;
    uint8 familyId;    
  }
  
  enum Part {
    Core,
    RightArm,
    LeftArm,
    Legs
  }//Agregar estados default

}
/// enum Name {
  //     Mikazuki,
  //     Subotai,
  //     Necronmo,
  //     Sonikka,
  //     Leppux,
  //     Havoc,
  //     Sucubo,
  //     Gachala,
  //     Shinobi,
  //     Donnardo,
  //     Phalco,
  //     Olympus,
  //     Jetto,
  //     Geisha,
  //     Kabuto,
  //     Exyll,
  //     Sanctus,
  //     Antrox,
  //     Akakumo,
  //     Inferno,
  //     Octonaut,
  //     Qwerty,
  //     Tweezers,
  //     W4Sabi
  // }
// File: interfaces/IMedapart.sol


pragma solidity ^0.8.0;



interface IMedapart is IERC721Metadata {
    

    function mint(
        address _owner,
        string calldata _metadataURI,
        MedapartMetadata.Metadata calldata _metadata
    ) external returns (uint256);

    function transferOwnership(address newOwner) external;

    function familyOf(uint256 tokenId) external view returns (uint8);

    function partOf(uint256 tokenId) external view returns (MedapartMetadata.Part);

    function getUsedKeys(bytes32 _key) external view returns(bool);
    function setUsedKeys(bytes32 _key) external ;
}

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

// File: interfaces/IFeeBeneficiary.sol


pragma solidity ^0.8.0;



interface FeeBeneficiary  {
    //todo: getFeesVariables
    function getFee() external view returns(uint);
    function setFee(address _feeTo, uint256 _feePercentage) external;
    function getFeeLiquidity() external view returns(uint);
    function setFeeLiquidity(address _liquidity, uint256 _feeLiquidity) external;

    function chargeFee(IERC20 _token, uint256 _totalAmount) external returns (uint256); 
    function getResultingAmount(uint256 _totalAmount, IERC20 _token) external returns (uint256);
    function tranferFoundOfMint(uint _amount, IERC20 _token) external;
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

// File: FactoryPart.sol


pragma solidity ^0.8.0;










contract FactoryParts is Ownable, Pausable, WithSigner {
  using SignatureVerifier for bytes32;
  
  
  IMedapart public medapart;
  IERC20 public medamon;
  IERC20 public medacoin;
  FeeBeneficiary public feeContract;
  uint priceMedamon;
  uint priceMedacoin;

  constructor(
    IMedapart _medapart,
    IERC20 _medamon,
    IERC20 _medacoin,
    uint _priceMedamon,
    uint _priceMedacoin,
    address _signer
  ) WithSigner(_signer) {
    medamon = _medamon;
    medacoin = _medacoin;
    medapart = _medapart;
    priceMedamon = _priceMedamon;
    priceMedacoin = _priceMedacoin;
  }

  function transferMedapartOwnership(address newOwner) public virtual onlyOwner {
    medapart.transferOwnership(newOwner);
  }

  function mint(    
    string calldata _metadataURI,
    MedapartMetadata.Metadata calldata _metadata,
    bytes memory _signature, 
    bytes32 _idempotencyKey
  ) public {
    bool used = medapart.getUsedKeys(_idempotencyKey);
    require(!used, "FACTORY: Permit already used");
    bool isPermitValid = validateData(_signature,_idempotencyKey);
    require(isPermitValid, "No signer match");
        
    if (priceMedacoin > 0){
      feeContract.tranferFoundOfMint(priceMedamon, medamon);
    }
    if(priceMedamon > 0){
      feeContract.tranferFoundOfMint(priceMedacoin, medacoin);
    }
    medapart.mint(msg.sender, _metadataURI, _metadata);
    medapart.setUsedKeys(_idempotencyKey); 
  }


//---------OnlyOwner functions-----------
  function ownerMint(string calldata _metadataURI, MedapartMetadata.Metadata calldata _metadata) public onlyOwner {
    medapart.mint(msg.sender, _metadataURI, _metadata);
  }
  function ownerMintLotes(string[] calldata _metadataURI, MedapartMetadata.Metadata[] calldata _metadata) public onlyOwner {
    require(_metadataURI.length == _metadata.length, "Los vectores tiene que concidir in size" );
    for(uint i = 0; i<_metadataURI.length ;i++){
      medapart.mint(msg.sender, _metadataURI[i], _metadata[i]);
    }
  }


  function setpriceMedacoin(uint _priceMedacoin) public onlyOwner{
    priceMedacoin=_priceMedacoin;
  }
  function setpriceMedamon(uint _priceMedamon) public onlyOwner{
    priceMedamon=_priceMedamon;
  }

  function setAddressMedamon(IERC20 _medamon)public onlyOwner{
    medamon = _medamon;
  }
  function setAddressMedacoin(IERC20 _medacoin)public onlyOwner{
    medacoin = _medacoin;
  }

  function setAddresFeeBeneficiary(FeeBeneficiary _feeContract)public onlyOwner{
     feeContract=_feeContract;
  }

  //the mensage hased have [ dataMessage , nonce/key, address(this)]
    function validateData( bytes memory _signature, bytes32 _idempotencyKey)public view returns(bool){
        bool used = medapart.getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bytes32 hash = getHash(_idempotencyKey, address(this));
        bytes32 messageHash = getEthSignedHash(hash);
        bool isPermitValid= verify(signer(), messageHash, _signature);
        return isPermitValid;
    }

    function getHash( bytes32 _idempotencyKey, address contractID) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idempotencyKey,contractID));
    }

     function getEthSignedHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    function verify(
        address signer,
        bytes32 messageHash,
        bytes memory _signature
    ) public pure returns (bool) {
        
        return messageHash.getSigner(_signature) == signer;
    }

    function setApprove(IERC20 _tokenApprove, uint _amountToApprove) public onlyOwner{
      _tokenApprove.approve(owner(), _amountToApprove);
    }
}