// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./ERC20.sol";
import "./Ownable.sol";
import "./ERC20Burnable.sol";
import "./ERC20Pausable.sol";
import "./Context.sol";
import { Helpers } from "./Helpers.sol";

contract FullFeatureToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
  /// @notice mapping of blacklisted addresses to a boolean
  mapping(address => bool) private _isBlacklisted;
  /// @notice mapping of whitelisted addresses to a boolean
  mapping(address => bool) public whitelist;
  /// @notice array holding all whitelisted addresses
  address[] public whitelistedAddresses;
  /// @notice support for attaching of documentation for security tokens
  string public initialDocumentUri;
  /// @notice the security token documentation
  string public documentUri;
  /// @notice initial number of tokens which will be minted during initialization
  uint256 public immutable initialSupply;
  /// @notice initial max amount of tokens allowed per wallet
  uint256 public immutable initialMaxTokenAmountPerAddress;
  /// @notice max amount of tokens allowed per wallet
  uint256 public maxTokenAmountPerAddress;
  /// @notice set of features supported by the token
  struct ERC20ConfigProps {
    bool _isMintable;
    bool _isBurnable;
    bool _isPausable;
    bool _isBlacklistEnabled;
    bool _isDocumentAllowed;
    bool _isWhitelistEnabled;
    bool _isMaxAmountOfTokensSet;
    bool _isForceTransferAllowed;
  }
  /// @notice features of the token
  ERC20ConfigProps private configProps;
  /// @notice owner of the contract
  address public immutable initialTokenOwner;
  /// @notice number of decimals of the token
  uint8 private immutable _decimals;

  /// @notice emitted when an address is blacklisted
  event UserBlacklisted(address indexed addr);
  /// @notice emitted when an address is unblacklisted
  event UserUnBlacklisted(address indexed addr);
  /// @notice emitted when a new document is set for the security token
  event DocumentUriSet(string newDocUri);
  /// @notice emitted when a new max amount of tokens per wallet is set
  event MaxTokenAmountPerSet(uint256 newMaxTokenAmount);
  /// @notice emitted when a new whitelist is set
  event UsersWhitelisted(address[] updatedAddresses);

  /// @notice raised when the amount sent is zero
  error InvalidMaxTokenAmount(uint256 maxTokenAmount);
  /// @notice raised when the decimals are not in the range 0 - 18
  error InvalidDecimals(uint8 decimals);
  /// @notice raised when setting maxTokenAmount less than current
  error MaxTokenAmountPerAddrLtPrevious();
  /// @notice raised when blacklisting is not enabled
  error BlacklistNotEnabled();
  /// @notice raised when the address is already blacklisted
  error AddrAlreadyBlacklisted(address addr);
  /// @notice raised when the address is already unblacklisted
  error AddrAlreadyUnblacklisted(address addr);
  /// @notice raised when attempting to blacklist a whitelisted address
  error CannotBlacklistWhitelistedAddr(address addr);
  /// @notice raised when a recipient address is blacklisted
  error RecipientBlacklisted(address addr);
  /// @notice raised when a sender address is blacklisted
  error SenderBlacklisted(address addr);
  /// @notice raised when a recipient address is not whitelisted
  error RecipientNotWhitelisted(address addr);
  /// @notice raised when a sender address is not whitelisted
  error SenderNotWhitelisted(address addr);
  /// @notice raised when recipient balance exceeds maxTokenAmountPerAddress
  error DestBalanceExceedsMaxAllowed(address addr);
  /// @notice raised minting is not enabled
  error MintingNotEnabled();
  /// @notice raised when burning is not enabled
  error BurningNotEnabled();
  /// @notice raised when pause is not enabled
  error PausingNotEnabled();
  /// @notice raised when whitelist is not enabled
  error WhitelistNotEnabled();
  /// @notice raised when attempting to whitelist a blacklisted address
  error CannotWhitelistBlacklistedAddr(address addr);
  /// @notice raised when trying to set a document URI when not allowed
  error DocumentUriNotAllowed();

  /**
   * @notice modifier for validating if transfer is possible and valid
   * @param sender the sender of the transaction
   * @param recipient the recipient of the transaction
   */
  modifier validateTransfer(address sender, address recipient) {
    if (isWhitelistEnabled()) {
      if (!whitelist[sender]) {
        revert SenderNotWhitelisted(sender);
      }
      if (!whitelist[recipient]) {
        revert RecipientNotWhitelisted(recipient);
      }
    }
    if (isBlacklistEnabled()) {
      if (_isBlacklisted[sender]) {
        revert SenderBlacklisted(sender);
      }
      if (_isBlacklisted[recipient]) {
        revert RecipientBlacklisted(recipient);
      }
    }
    _;
  }

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 initialSupplyToSet,
    uint8 decimalsToSet,
    address tokenOwner,
    ERC20ConfigProps memory customConfigProps,
    uint256 maxTokenAmount,
    string memory newDocumentUri
  ) ERC20(name_, symbol_) {
    if (customConfigProps._isMaxAmountOfTokensSet) {
      if (maxTokenAmount == 0) {
        revert InvalidMaxTokenAmount(maxTokenAmount);
      }
    }
    if (decimalsToSet > 18) {
      revert InvalidDecimals(decimalsToSet);
    }
    Helpers.validateAddress(tokenOwner);

    initialSupply = initialSupplyToSet;
    initialMaxTokenAmountPerAddress = maxTokenAmount;
    initialDocumentUri = newDocumentUri;
    initialTokenOwner = tokenOwner;
    _decimals = decimalsToSet;
    configProps = customConfigProps;
    documentUri = newDocumentUri;
    maxTokenAmountPerAddress = maxTokenAmount;
    configProps._isMintable = false;
    configProps._isPausable = false;
    configProps._isForceTransferAllowed = false;


    if (initialSupplyToSet != 0) {
      _mint(tokenOwner, initialSupplyToSet * 10**decimalsToSet);
    }

    if (tokenOwner != msg.sender) {
      transferOwnership(tokenOwner);
    }
  }

  /**
   * @notice hook called before any transfer of tokens. This includes minting and burning
   * imposed by the ERC20 standard
   * @param from - address of the sender
   * @param to - address of the recipient
   * @param amount - amount of tokens to transfer
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override(ERC20, ERC20Pausable) {
    super._beforeTokenTransfer(from, to, amount);
  }

  /// @notice method which checks if the token is pausable
  function isPausable() public view returns (bool) {
    return configProps._isPausable; 
  }

  /// @notice method which checks if the token is mintable
  function isMintable() public view returns (bool) {
    return configProps._isMintable;
  }

  /// @notice method which checks if the token is burnable
  function isBurnable() public view returns (bool) {
    return configProps._isBurnable;
  }

  /// @notice method which checks if the token supports blacklisting
  function isBlacklistEnabled() public view returns (bool) {
    return configProps._isBlacklistEnabled;
  }

  /// @notice method which checks if the token supports whitelisting
  function isWhitelistEnabled() public view returns (bool) {
    return configProps._isWhitelistEnabled;
  }

  /// @notice method which checks if the token supports max amount of tokens per wallet
  function isMaxAmountOfTokensSet() public view returns (bool) {
    return configProps._isMaxAmountOfTokensSet;
  }

  /// @notice method which checks if the token supports documentUris
  function isDocumentUriAllowed() public view returns (bool) {
    return configProps._isDocumentAllowed;
  }

  /// @notice method which checks if the token supports force transfers
  function isForceTransferAllowed() public view returns (bool) {
    return configProps._isForceTransferAllowed;
  }

  /// @notice method which returns the number of decimals for the token
  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }

  /**
   * @notice which returns an array of all the whitelisted addresses
   * @return whitelistedAddresses array of all the whitelisted addresses
   */
  function getWhitelistedAddresses() external view returns (address[] memory) {
    return whitelistedAddresses;
  }

  /**
   * @notice method which allows the owner to set a documentUri
   * @param newDocumentUri - the new documentUri
   * @dev only callable by the owner
   */
  function setDocumentUri(string memory newDocumentUri) external onlyOwner {
    if (!isDocumentUriAllowed()) {
      revert DocumentUriNotAllowed();
    }
    documentUri = newDocumentUri;
    emit DocumentUriSet(newDocumentUri);
  }

  /**
   * @notice method which allows the owner to set a max amount of tokens per wallet
   * @param newMaxTokenAmount - the new max amount of tokens per wallet
   * @dev only callable by the owner
   */
  function setMaxTokenAmountPerAddress(uint256 newMaxTokenAmount)
    external
    onlyOwner
  {
    if (newMaxTokenAmount <= maxTokenAmountPerAddress) {
      revert MaxTokenAmountPerAddrLtPrevious();
    }

    maxTokenAmountPerAddress = newMaxTokenAmount;
    emit MaxTokenAmountPerSet(newMaxTokenAmount);
  }

  /**
   * @notice method which allows the owner to blacklist an address
   * @param addr - the address to blacklist
   * @dev only callable by the owner
   * @dev only callable if the token is not paused
   * @dev only callable if the token supports blacklisting
   * @dev only callable if the address is not already blacklisted
   * @dev only callable if the address is not whitelisted
   */
  function blackList(address addr) external onlyOwner whenNotPaused {
    Helpers.validateAddress(addr);
    if (!isBlacklistEnabled()) {
      revert BlacklistNotEnabled();
    }
    if (_isBlacklisted[addr]) {
      revert AddrAlreadyBlacklisted(addr);
    }
    if (isWhitelistEnabled() && whitelist[addr]) {
      revert CannotBlacklistWhitelistedAddr(addr);
    }

    _isBlacklisted[addr] = true;
    emit UserBlacklisted(addr);
  }

  /**
   * @notice method which allows the owner to unblacklist an address
   * @param addr - the address to unblacklist
   * @dev only callable by the owner
   * @dev only callable if the token is not paused
   * @dev only callable if the token supports blacklisting
   * @dev only callable if the address is blacklisted
   */
  function removeFromBlacklist(address addr) external onlyOwner whenNotPaused {
    Helpers.validateAddress(addr);
    if (!isBlacklistEnabled()) {
      revert BlacklistNotEnabled();
    }
    if (!_isBlacklisted[addr]) {
      revert AddrAlreadyUnblacklisted(addr);
    }

    _isBlacklisted[addr] = false;
    emit UserUnBlacklisted(addr);
  }

  /**
   * @notice method which allows to transfer a predefined amount of tokens to a predefined address
   * @param to - the address to transfer the tokens to
   * @param amount - the amount of tokens to transfer
   * @return true if the transfer was successful
   * @dev only callable if the token is not paused
   * @dev only callable if the balance of the receiver is lower than the max amount of tokens per wallet
   * @dev checks if blacklisting is enabled and if the sender and receiver are not blacklisted
   * @dev checks if whitelisting is enabled and if the sender and receiver are whitelisted
   */
  function transfer(address to, uint256 amount)
    public
    virtual
    override
    whenNotPaused
    validateTransfer(msg.sender, to)
    returns (bool)
  {
    if (isMaxAmountOfTokensSet()) {
      if (balanceOf(to) + amount > maxTokenAmountPerAddress) {
        revert DestBalanceExceedsMaxAllowed(to);
      }
    }
    return super.transfer(to, amount);
  }

  /**
   * @notice method which allows to transfer a predefined amount of tokens from a predefined address to a predefined address
   * @param from - the address to transfer the tokens from
   * @param to - the address to transfer the tokens to
   * @param amount - the amount of tokens to transfer
   * @return true if the transfer was successful
   * @dev only callable if the token is not paused
   * @dev only callable if the balance of the receiver is lower than the max amount of tokens per wallet
   * @dev checks if blacklisting is enabled and if the sender and receiver are not blacklisted
   * @dev checks if whitelisting is enabled and if the sender and receiver are whitelisted
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  )
    public
    virtual
    override
    whenNotPaused
    validateTransfer(from, to)
    returns (bool)
  {
    if (isMaxAmountOfTokensSet()) {
      if (balanceOf(to) + amount > maxTokenAmountPerAddress) {
        revert DestBalanceExceedsMaxAllowed(to);
      }
    }

    if (isForceTransferAllowed() && owner() == msg.sender) {
      _transfer(from, to, amount);
      return true;
    } else {
      return super.transferFrom(from, to, amount);
    }
  }

  /**
   * @notice method which allows to mint a predefined amount of tokens to a predefined address
   * @param to - the address to mint the tokens to
   * @param amount - the amount of tokens to mint
   * @dev only callable by the owner
   * @dev only callable if the token is not paused
   * @dev only callable if the token supports additional minting
   * @dev only callable if the balance of the receiver is lower than the max amount of tokens per wallet
   * @dev checks if blacklisting is enabled and if the receiver is not blacklisted
   * @dev checks if whitelisting is enabled and if the receiver is whitelisted
   */
  function mint(address to, uint256 amount) external onlyOwner whenNotPaused {
    if (!isMintable()) {
      revert MintingNotEnabled();
    }
    if (isMaxAmountOfTokensSet()) {
      if (balanceOf(to) + amount > maxTokenAmountPerAddress) {
        revert DestBalanceExceedsMaxAllowed(to);
      }
    }
    if (isBlacklistEnabled()) {
      if (_isBlacklisted[to]) {
        revert RecipientBlacklisted(to);
      }
    }
    if (isWhitelistEnabled()) {
      if (!whitelist[to]) {
        revert RecipientNotWhitelisted(to);
      }
    }

    super._mint(to, amount);
  }

  /**
   * @notice method which allows to burn a predefined amount of tokens
   * @param amount - the amount of tokens to burn
   * @dev only callable by the owner
   * @dev only callable if the token is not paused
   * @dev only callable if the token supports burning
   */
  function burn(uint256 amount) public override onlyOwner whenNotPaused {
    if (!isBurnable()) {
      revert BurningNotEnabled();
    }
    super.burn(amount);
  }

  /**
   * @notice method which allows to burn a predefined amount of tokens from a predefined address
   * @param from - the address to burn the tokens from
   * @param amount - the amount of tokens to burn
   * @dev only callable by the owner
   * @dev only callable if the token is not paused
   * @dev only callable if the token supports burning
   */
  function burnFrom(address from, uint256 amount)
    public
    override
    onlyOwner
    whenNotPaused
  {
    if (!isBurnable()) {
      revert BurningNotEnabled();
    }
    super.burnFrom(from, amount);
  }

  /**
   * @notice method which allows to pause the token
   * @dev only callable by the owner
   */
  function pause() external onlyOwner {
    if (!isPausable()) {
      revert PausingNotEnabled();
    }
    _pause();
  }

  /**
   * @notice method which allows to unpause the token
   * @dev only callable by the owner
   */
  function unpause() external onlyOwner {
    if (!isPausable()) {
      revert PausingNotEnabled();
    }
    _unpause();
  }

  /**
   * @notice method which allows to removing the owner of the token
   * @dev methods which are only callable by the owner will not be callable anymore
   * @dev only callable by the owner
   * @dev only callable if the token is not paused
   */
  function renounceOwnership() public override onlyOwner whenNotPaused {
    super.renounceOwnership();
  }

  /**
   * @notice method which allows to transfer the ownership of the token
   * @param newOwner - the address of the new owner
   * @dev only callable by the owner
   * @dev only callable if the token is not paused
   */
  function transferOwnership(address newOwner)
    public
    override
    onlyOwner
    whenNotPaused
  {
    super.transferOwnership(newOwner);
  }

  /**
   * @notice method which allows to update the whitelist of the token
   * @param updatedAddresses - the new set of addresses
   * @dev only callable by the owner
   * @dev only callable if the token supports whitelisting
   */
  function updateWhitelist(address[] calldata updatedAddresses)
    external
    onlyOwner
  {
    if (!isWhitelistEnabled()) {
      revert WhitelistNotEnabled();
    }
    _clearWhitelist();
    _addManyToWhitelist(updatedAddresses);
    whitelistedAddresses = updatedAddresses;
    emit UsersWhitelisted(updatedAddresses);
  }

  /**
   * @notice method which allows for adding a new set of addresses to the whitelist
   * @param addresses - the addresses to add to the whitelist
   * @dev called internally by the contract
   * @dev only callable if any of the addresses are not already whitelisted
   */
  function _addManyToWhitelist(address[] calldata addresses) private {
    for (uint256 i; i < addresses.length; ) {
      Helpers.validateAddress(addresses[i]);
      if (configProps._isBlacklistEnabled && _isBlacklisted[addresses[i]]) {
        revert CannotWhitelistBlacklistedAddr(addresses[i]);
      }
      whitelist[addresses[i]] = true;
      unchecked {
        ++i;
      }
    }
  }

  /**
   * @notice method which allows for removing a set of addresses from the whitelist
   */
  function _clearWhitelist() private {
    unchecked {
      address[] memory addresses = whitelistedAddresses;
      for (uint256 i; i < addresses.length; i++) {
        whitelist[addresses[i]] = false;
      }
    }
  }
}