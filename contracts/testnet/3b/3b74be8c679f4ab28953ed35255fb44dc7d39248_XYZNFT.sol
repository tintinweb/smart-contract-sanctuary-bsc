// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./ERC721Upgradeable.sol";
import "./IERC20Upgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";
import "./AccessControlUpgradeable.sol";
import "./SafeERC20Upgradeable.sol";

contract XYZNFT is ERC721Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
  struct HashInfo {
    uint256 hashRate;
    uint8 hashType; //hashType => 0 = Neon hash, 1 = Gold Hash, 2 = Silver Hash
  }
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  mapping(uint256 => HashInfo) public hashInfo;
  uint256 public tokenId;

  event Buy(uint256 tokenId, address indexed to, uint8 hashType, uint256 hashRate);

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 _interfaceId)
    public
    view
    virtual
    override(ERC721Upgradeable, AccessControlUpgradeable)
    returns (bool)
  {
    return super.supportsInterface(_interfaceId);
  }

  function __XYZNFT_init() public initializer {
    __Ownable_init();
    __ERC721_init("ustaad", "ustaad");
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    __AccessControl_init();
    __ReentrancyGuard_init();
    tokenId = 1;
  }

  function mint(
    address _to,
    uint8 _hashType,
    uint256 _hashRate
  ) external nonReentrant onlyRole(MINTER_ROLE) returns (uint256) {
    _mint(_to, tokenId);
    hashInfo[tokenId] = HashInfo(_hashRate, _hashType);
    emit Buy(tokenId, _to, _hashType, _hashRate);
    tokenId = tokenId + 1;
    return tokenId - 1;
  }

  function addHash(uint256 _tokenId, uint256 _hash) external nonReentrant onlyRole(MINTER_ROLE) {
    hashInfo[_tokenId].hashRate += _hash;
  }

  function totalNFTs() external view returns (uint256) {
    return tokenId - 1;
  }
}