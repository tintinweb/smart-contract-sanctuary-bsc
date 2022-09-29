// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./abstract/AccessControl.sol";
import "./library/SafeMath.sol";
import "./library/SafeBEP20.sol";
import "./interface/IShip.sol";

contract ShipIssuer is AccessControl {
  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;

  IShip public shipNFT;
  IBEP20 public f4hToken;

  bytes32 public constant CREATOR_ADMIN_SERVER = keccak256("CREATOR_ADMIN_SERVER");
  string public stringNull = "";
  uint256 public feeShip = 50000000000000000000;
  address public receiveFee = payable(0x3631f25ea6f2368D3A927685acD2C5c43CE05049);

  constructor(
    address minter,
    address _ship,
    address _f4hToken
  ) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(CREATOR_ADMIN_SERVER, minter);
    shipNFT = IShip(_ship);
    f4hToken = IBEP20(_f4hToken);
  }

  event RequestShip(uint256 tokenId, address owner, uint256 shipNumber);
  event DeliverShip(
    address owner,
    uint256 tokenId,
    uint256 shipNumber,
    string shipName,
    string shipClass,
    string shipLevel,
    uint256 shipSpeed,
    uint256 shipWeight,
    uint256 shipTurningAngle,
    uint256 shipMissileSpeed,
    string shipLaserType,
    uint256 shipLaserSlot
  );

  /**
   * default state of ship
   */
  struct Ship {
    string shipName;
    string shipClass;
    string shipLevel;
    uint256 shipSpeed;
    uint256 shipWeight;
    uint256 shipTurningAngle;
    uint256 shipMissileSpeed;
    string shipLaserType;
    uint256 shipLaserSlot;
  }

  /**
   * level name
   */
  struct LevelName {
    string levelName;
  }
  mapping(uint256 => Ship) public ships; //  tokenId=> Ship Information
  LevelName[] public levelName; // level information

  function changeReceiveFee(address _receive) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, address(msg.sender)), "Caller is not a owner");
    require(_receive != address(0), "cant addr zero");
    receiveFee = payable(_receive);
  }

  function getLevelName() public view returns (LevelName[] memory) {
    return levelName;
  }

  function addLevelName(string[] memory _levelName) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, address(msg.sender)), "Caller is not a owner");
    for (uint256 i = 0; i < _levelName.length; i++) {
      levelName.push(LevelName(_levelName[i]));
    }
  }

  function editLevelName(uint256 _id, string memory _levelName) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, address(msg.sender)), "Caller is not a owner");
    levelName[_id].levelName = _levelName;
  }

  function getShip(uint256 _id) public view returns (Ship memory) {
    return ships[_id];
  }

  function addShip(
    uint256[] memory id,
    string[] memory _shipName,
    string[] memory _shipClass,
    string[] memory _shipLevel,
    uint256[] memory _shipSpeed,
    uint256[] memory _shipWeight,
    uint256[] memory _shipTurningAngle,
    uint256[] memory _shipMissileSpeed,
    string[] memory _shipLaserType,
    uint256[] memory _shipLaserSlot
  ) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, address(msg.sender)), "Caller is not a owner");
    for (uint256 i = 0; i < _shipName.length; i++) {
      ships[id[i]] = Ship(
        _shipName[i],
        _shipClass[i],
        _shipLevel[i],
        _shipSpeed[i],
        _shipWeight[i],
        _shipTurningAngle[i],
        _shipMissileSpeed[i],
        _shipLaserType[i],
        _shipLaserSlot[i]
      );
    }
  }

  function editShip(
    uint256 _id,
    string memory shipName,
    string memory _shipClass,
    string memory _shipLevel,
    uint256 _shipSpeed,
    uint256 _shipWeight,
    uint256 _shipTurningAngle,
    uint256 _shipMissileSpeed,
    string memory _shipLaserType,
    uint256 _shipLaserSlot
  ) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, address(msg.sender)), "Caller is not a owner");
    ships[_id].shipName = shipName;
    ships[_id].shipClass = _shipClass;
    ships[_id].shipLevel = _shipLevel;
    ships[_id].shipSpeed = _shipSpeed;
    ships[_id].shipWeight = _shipWeight;
    ships[_id].shipTurningAngle = _shipTurningAngle;
    ships[_id].shipMissileSpeed = _shipMissileSpeed;
    ships[_id].shipLaserType = _shipLaserType;
    ships[_id].shipLaserSlot = _shipLaserSlot;
  }

  function changeFee(uint256 _fee) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, address(msg.sender)), "Caller is not a owner");
    require(_fee > 0, "need fee > 0");
    feeShip = _fee;
  }

  function requestShip(uint256 _tokenId, uint256 _shipNumber) public {
    f4hToken.safeTransferFrom(address(msg.sender), address(receiveFee), feeShip);
    emit RequestShip(_tokenId, msg.sender, _shipNumber);
  }

  function deliverShip(
    address[] memory _owner,
    uint256[] memory _tokenId,
    uint256[] memory _shipNumber
  ) public {
    require(hasRole(CREATOR_ADMIN_SERVER, address(msg.sender)), "Caller is not a admin");
    require(_owner.length == _shipNumber.length && _tokenId.length == _shipNumber.length, "Input not true");
    for (uint256 i = 0; i < _tokenId.length; i++) {
      require(keccak256(bytes(ships[_shipNumber[i]].shipName)) != keccak256(bytes(stringNull)), "Ship not found");
      string memory level = levelName[0].levelName;
      shipNFT.safeMint(address(_owner[i]), _tokenId[i]);
      uint256 shipNumberTemp = _shipNumber[i];
      shipNFT.addShip(
        _tokenId[i],
        shipNumberTemp,
        ships[shipNumberTemp].shipName,
        ships[shipNumberTemp].shipClass,
        level,
        ships[shipNumberTemp].shipSpeed,
        ships[shipNumberTemp].shipWeight,
        ships[shipNumberTemp].shipTurningAngle,
        ships[shipNumberTemp].shipMissileSpeed,
        ships[shipNumberTemp].shipLaserType,
        ships[shipNumberTemp].shipLaserSlot
      );
      emit DeliverShip(
        _owner[i],
        _tokenId[i],
        shipNumberTemp,
        ships[shipNumberTemp].shipName,
        ships[shipNumberTemp].shipClass,
        level,
        ships[shipNumberTemp].shipSpeed,
        ships[shipNumberTemp].shipWeight,
        ships[shipNumberTemp].shipTurningAngle,
        ships[shipNumberTemp].shipMissileSpeed,
        ships[shipNumberTemp].shipLaserType,
        ships[shipNumberTemp].shipLaserSlot
      );
    }
  }

  function queryLevelName(string memory _level) public view returns (uint256) {
    uint256 result = 0;
    for (uint256 i = 0; i < levelName.length; i++) {
      if (keccak256(bytes(levelName[i].levelName)) == keccak256(bytes(_level))) {
        result = 1;
      }
    }
    return result;
  }

  function queryNumberLevel(string memory _level) public view returns (uint256) {
    uint256 result = 100;
    for (uint256 i = 0; i < levelName.length; i++) {
      if (keccak256(bytes(levelName[i].levelName)) == keccak256(bytes(_level))) {
        result = i;
      }
    }
    return result;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./ERC165.sol";
import "../interface/IAccessControl.sol";

abstract contract AccessControl is Context, IAccessControl, ERC165 {
  struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
  }
  mapping(bytes32 => RoleData) private _roles;
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
  }

  function hasRole(bytes32 role, address account) public view override returns (bool) {
    return _roles[role].members[account];
  }

  function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
    return _roles[role].adminRole;
  }

  function grantRole(bytes32 role, address account) public virtual override {
    require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");
    _grantRole(role, account);
  }

  function revokeRole(bytes32 role, address account) public virtual override {
    require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");
    _revokeRole(role, account);
  }

  function renounceRole(bytes32 role, address account) public virtual override {
    require(account == _msgSender(), "AccessControl: can only renounce roles for self");
    _revokeRole(role, account);
  }

  function _setupRole(bytes32 role, address account) internal virtual {
    _grantRole(role, account);
  }

  function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
    emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
    _roles[role].adminRole = adminRole;
  }

  function _grantRole(bytes32 role, address account) private {
    if (!hasRole(role, account)) {
      _roles[role].members[account] = true;
      emit RoleGranted(role, account, _msgSender());
    }
  }

  function _revokeRole(bytes32 role, address account) private {
    if (hasRole(role, account)) {
      _roles[role].members[account] = false;
      emit RoleRevoked(role, account, _msgSender());
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";

library SafeBEP20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IBEP20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IBEP20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IBEP20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeBEP20: approve from non-zero to non-zero allowance"
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IBEP20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IBEP20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function callOptionalReturn(IBEP20 token, bytes memory data) private {
    require(address(token).isContract(), "SafeBEP20: call to non-contract");
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, "SafeBEP20: low-level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), "SafeBEP20: ERC20 operation did not succeed");
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";

interface IShip is IERC721 {
  struct ShipInfo {
    uint256 shipNumber; // id of ship
    string shipName; // ship given name
    string shipClass; // body type : light, medium, heavy, destroyer
    string shipLevel; // scout, Scavenger, Squatter, Reclaimer, Colonist, Salvager of Hope
    uint256 shipSpeed;
    uint256 shipWeight;
    uint256 shipTurningAngle;
    uint256 shipMissileSpeed;
    string shipLaserType;
    uint256 shipLaserSlot;
  }

  function getShip(uint256 _tokenId) external view returns (ShipInfo memory);

  function safeMint(address _to, uint256 _tokenId) external;

  function burn(address _from, uint256 _tokenId) external;

  function addShip(
    uint256 _tokenId,
    uint256 _shipNumber,
    string memory _shipName,
    string memory _shipClass,
    string memory _shipLevel,
    uint256 _shipSpeed,
    uint256 _shipWeight,
    uint256 _shipTurningAngle,
    uint256 _shipMissileSpeed,
    string memory _shipLaserType,
    uint256 _shipLaserSlot
  ) external;

  function editLevel(uint256 tokenId, string memory _shipLevel) external;

  function editLaserType(uint256 tokenId, string memory _shipLaserType) external;

  function editSpeed(uint256 tokenId, uint256 _shipSpeed) external;

  function editWeight(uint256 tokenId, uint256 _shipWeight) external;

  function editTurningAngle(uint256 tokenId, uint256 _shipTurningAngle) external;

  function editMissileSpeed(uint256 tokenId, uint256 _shipMissileSpeed) external;

  function editLaserSlot(uint256 tokenId, uint256 _shipLaserSlot) external;

  function deleteShip(uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this;
    return msg.data;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IERC165.sol";

abstract contract ERC165 is IERC165 {
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC165).interfaceId;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccessControl {
  function hasRole(bytes32 role, address account) external view returns (bool);

  function getRoleAdmin(bytes32 role) external view returns (bytes32);

  function grantRole(bytes32 role, address account) external;

  function revokeRole(bytes32 role, address account) external;

  function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function decimals() external view returns (uint8);

  function mint(address account, uint256 amount) external returns (bool);

  function burn(address account, uint256 amount) external returns (bool);

  function addOperator(address minter) external returns (bool);

  function removeOperator(address minter) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC721 is IERC165 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function balanceOf(address owner) external view returns (uint256 balance);

  function ownerOf(uint256 tokenId) external view returns (address owner);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function approve(address to, uint256 tokenId) external;

  function getApproved(uint256 tokenId) external view returns (address operator);

  function setApprovalForAll(address operator, bool _approved) external;

  function isApprovedForAll(address owner, address operator) external view returns (bool);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;
}