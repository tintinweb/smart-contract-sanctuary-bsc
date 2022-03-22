// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PancakeProfile} from "./PancakeProfile.sol";

/**
 * @title AnniversaryAchievement.
 * @notice It is a contract to distribute points for 1st anniversary.
 */
contract AnniversaryAchievement is Ownable {
    PancakeProfile public pancakeProfile;

    uint256 public campaignId;
    uint256 public numberPoints;
    uint256 public thresholdPoints;
    uint256 public endBlock;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    event NewCampaignId(uint256 campaignId);
    event NewEndBlock(uint256 endBlock);
    event NewNumberPointsAndThreshold(uint256 numberPoints, uint256 thresholdPoints);

    /**
     * @notice Constructor
     * @param _pancakeProfile: Pancake Profile
     * @param _numberPoints: number of points to give
     * @param _thresholdPoints: number of points required to claim
     * @param _campaignId: campaign id
     * @param _endBlock: end block for claiming
     */
    constructor(
        address _pancakeProfile,
        uint256 _numberPoints,
        uint256 _thresholdPoints,
        uint256 _campaignId,
        uint256 _endBlock
    ) public {
        pancakeProfile = PancakeProfile(_pancakeProfile);
        numberPoints = _numberPoints;
        thresholdPoints = _thresholdPoints;
        campaignId = _campaignId;
        endBlock = _endBlock;
    }

    /**
     * @notice Get anniversary points
     * @dev Users can claim these once.
     */
    function claimAnniversaryPoints() external {
        require(canClaim(msg.sender), "Claim: Cannot claim");

        hasClaimed[msg.sender] = true;

        pancakeProfile.increaseUserPoints(msg.sender, numberPoints, campaignId);
    }

    /**
     * @notice Change campaignId
     * @dev Only callable by owner.
     * @param _campaignId: campaign id
     */
    function changeCampaignId(uint256 _campaignId) external onlyOwner {
        campaignId = _campaignId;

        emit NewCampaignId(_campaignId);
    }

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     * @param _endBlock: end block for claiming
     */
    function changeEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;

        emit NewEndBlock(_endBlock);
    }

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     * @param _numberPoints: number of points to give
     * @param _thresholdPoints: number of points required to claim
     */
    function changeNumberPointsAndThreshold(uint256 _numberPoints, uint256 _thresholdPoints) external onlyOwner {
        numberPoints = _numberPoints;
        thresholdPoints = _thresholdPoints;

        emit NewNumberPointsAndThreshold(_numberPoints, _thresholdPoints);
    }

    /**
     * @notice Checks the claim status by user
     * @dev Only callable by owner.
     * @param _user: user address
     */
    function canClaim(address _user) public view returns (bool) {
        if (!pancakeProfile.getUserStatus(_user)) {
            return false;
        }

        (, uint256 numberUserPoints, , , , ) = pancakeProfile.getUserProfile(_user);

        return (!hasClaimed[_user]) && (block.number < endBlock) && (numberUserPoints >= thresholdPoints);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";

import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

/** @title PancakeProfile.
 * @notice It is a contract for users to bind their address
 * to a customizable profile by depositing a NFT.
 */
contract PancakeProfile is AccessControl, ERC721Holder {
    using Counters for Counters.Counter;
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    IBEP20 public cakeToken;

    bytes32 public constant NFT_ROLE = keccak256("NFT_ROLE");
    bytes32 public constant POINT_ROLE = keccak256("POINT_ROLE");
    bytes32 public constant SPECIAL_ROLE = keccak256("SPECIAL_ROLE");

    uint256 public numberActiveProfiles;
    uint256 public numberCakeToReactivate;
    uint256 public numberCakeToRegister;
    uint256 public numberCakeToUpdate;
    uint256 public numberTeams;

    mapping(address => bool) public hasRegistered;

    mapping(uint256 => Team) private teams;
    mapping(address => User) private users;

    // Used for generating the teamId
    Counters.Counter private _countTeams;

    // Used for generating the userId
    Counters.Counter private _countUsers;

    // Event to notify a new team is created
    event TeamAdd(uint256 teamId, string teamName);

    // Event to notify that team points are increased
    event TeamPointIncrease(uint256 indexed teamId, uint256 numberPoints, uint256 indexed campaignId);

    event UserChangeTeam(address indexed userAddress, uint256 oldTeamId, uint256 newTeamId);

    // Event to notify that a user is registered
    event UserNew(address indexed userAddress, uint256 teamId, address nftAddress, uint256 tokenId);

    // Event to notify a user pausing her profile
    event UserPause(address indexed userAddress, uint256 teamId);

    // Event to notify that user points are increased
    event UserPointIncrease(address indexed userAddress, uint256 numberPoints, uint256 indexed campaignId);

    // Event to notify that a list of users have an increase in points
    event UserPointIncreaseMultiple(address[] userAddresses, uint256 numberPoints, uint256 indexed campaignId);

    // Event to notify that a user is reactivating her profile
    event UserReactivate(address indexed userAddress, uint256 teamId, address nftAddress, uint256 tokenId);

    // Event to notify that a user is pausing her profile
    event UserUpdate(address indexed userAddress, address nftAddress, uint256 tokenId);

    // Modifier for admin roles
    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not the main admin");
        _;
    }

    // Modifier for point roles
    modifier onlyPoint() {
        require(hasRole(POINT_ROLE, _msgSender()), "Not a point admin");
        _;
    }

    // Modifier for special roles
    modifier onlySpecial() {
        require(hasRole(SPECIAL_ROLE, _msgSender()), "Not a special admin");
        _;
    }

    struct Team {
        string teamName;
        string teamDescription;
        uint256 numberUsers;
        uint256 numberPoints;
        bool isJoinable;
    }

    struct User {
        uint256 userId;
        uint256 numberPoints;
        uint256 teamId;
        address nftAddress;
        uint256 tokenId;
        bool isActive;
    }

    constructor(
        IBEP20 _cakeToken,
        uint256 _numberCakeToReactivate,
        uint256 _numberCakeToRegister,
        uint256 _numberCakeToUpdate
    ) public {
        cakeToken = _cakeToken;
        numberCakeToReactivate = _numberCakeToReactivate;
        numberCakeToRegister = _numberCakeToRegister;
        numberCakeToUpdate = _numberCakeToUpdate;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev To create a user profile. It sends the NFT to the contract
     * and sends CAKE to burn address. Requires 2 token approvals.
     */
    function createProfile(
        uint256 _teamId,
        address _nftAddress,
        uint256 _tokenId
    ) external {
        require(!hasRegistered[_msgSender()], "Already registered");
        require((_teamId <= numberTeams) && (_teamId > 0), "Invalid teamId");
        require(teams[_teamId].isJoinable, "Team not joinable");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");

        // Loads the interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);

        require(_msgSender() == nftToken.ownerOf(_tokenId), "Only NFT owner can register");

        // Transfer NFT to this contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer CAKE tokens to this contract
        cakeToken.safeTransferFrom(_msgSender(), address(this), numberCakeToRegister);

        // Increment the _countUsers counter and get userId
        _countUsers.increment();
        uint256 newUserId = _countUsers.current();

        // Add data to the struct for newUserId
        users[_msgSender()] = User({
            userId: newUserId,
            numberPoints: 0,
            teamId: _teamId,
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            isActive: true
        });

        // Update registration status
        hasRegistered[_msgSender()] = true;

        // Update number of active profiles
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Increase the number of users for the team
        teams[_teamId].numberUsers = teams[_teamId].numberUsers.add(1);

        // Emit an event
        emit UserNew(_msgSender(), _teamId, _nftAddress, _tokenId);
    }

    /**
     * @dev To pause user profile. It releases the NFT.
     * Callable only by registered users.
     */
    function pauseProfile() external {
        require(hasRegistered[_msgSender()], "Has not registered");

        // Checks whether user has already paused
        require(users[_msgSender()].isActive, "User not active");

        // Change status of user to make it inactive
        users[_msgSender()].isActive = false;

        // Retrieve the teamId of the user calling
        uint256 userTeamId = users[_msgSender()].teamId;

        // Reduce number of active users and team users
        teams[userTeamId].numberUsers = teams[userTeamId].numberUsers.sub(1);
        numberActiveProfiles = numberActiveProfiles.sub(1);

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(users[_msgSender()].nftAddress);

        // tokenId of NFT redeemed
        uint256 redeemedTokenId = users[_msgSender()].tokenId;

        // Change internal statuses as extra safety
        users[_msgSender()].nftAddress = address(0x0000000000000000000000000000000000000000);

        users[_msgSender()].tokenId = 0;

        // Transfer the NFT back to the user
        nftToken.safeTransferFrom(address(this), _msgSender(), redeemedTokenId);

        // Emit event
        emit UserPause(_msgSender(), userTeamId);
    }

    /**
     * @dev To update user profile.
     * Callable only by registered users.
     */
    function updateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], "Has not registered");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");
        require(users[_msgSender()].isActive, "User not active");

        address currentAddress = users[_msgSender()].nftAddress;
        uint256 currentTokenId = users[_msgSender()].tokenId;

        // Interface to deposit the NFT contract
        IERC721 nftNewToken = IERC721(_nftAddress);

        require(_msgSender() == nftNewToken.ownerOf(_tokenId), "Only NFT owner can update");

        // Transfer token to new address
        nftNewToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer CAKE token to this address
        cakeToken.safeTransferFrom(_msgSender(), address(this), numberCakeToUpdate);

        // Interface to deposit the NFT contract
        IERC721 nftCurrentToken = IERC721(currentAddress);

        // Transfer old token back to the owner
        nftCurrentToken.safeTransferFrom(address(this), _msgSender(), currentTokenId);

        // Update mapping in storage
        users[_msgSender()].nftAddress = _nftAddress;
        users[_msgSender()].tokenId = _tokenId;

        emit UserUpdate(_msgSender(), _nftAddress, _tokenId);
    }

    /**
     * @dev To reactivate user profile.
     * Callable only by registered users.
     */
    function reactivateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], "Has not registered");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");
        require(!users[_msgSender()].isActive, "User is active");

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);
        require(_msgSender() == nftToken.ownerOf(_tokenId), "Only NFT owner can update");

        // Transfer to this address
        cakeToken.safeTransferFrom(_msgSender(), address(this), numberCakeToReactivate);

        // Transfer NFT to contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Retrieve teamId of the user
        uint256 userTeamId = users[_msgSender()].teamId;

        // Update number of users for the team and number of active profiles
        teams[userTeamId].numberUsers = teams[userTeamId].numberUsers.add(1);
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Update user statuses
        users[_msgSender()].isActive = true;
        users[_msgSender()].nftAddress = _nftAddress;
        users[_msgSender()].tokenId = _tokenId;

        // Emit event
        emit UserReactivate(_msgSender(), userTeamId, _nftAddress, _tokenId);
    }

    /**
     * @dev To increase the number of points for a user.
     * Callable only by point admins
     */
    function increaseUserPoints(
        address _userAddress,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        // Increase the number of points for the user
        users[_userAddress].numberPoints = users[_userAddress].numberPoints.add(_numberPoints);

        emit UserPointIncrease(_userAddress, _numberPoints, _campaignId);
    }

    /**
     * @dev To increase the number of points for a set of users.
     * Callable only by point admins
     */
    function increaseUserPointsMultiple(
        address[] calldata _userAddresses,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        require(_userAddresses.length < 1001, "Length must be < 1001");
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            users[_userAddresses[i]].numberPoints = users[_userAddresses[i]].numberPoints.add(_numberPoints);
        }
        emit UserPointIncreaseMultiple(_userAddresses, _numberPoints, _campaignId);
    }

    /**
     * @dev To increase the number of points for a team.
     * Callable only by point admins
     */

    function increaseTeamPoints(
        uint256 _teamId,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        // Increase the number of points for the team
        teams[_teamId].numberPoints = teams[_teamId].numberPoints.add(_numberPoints);

        emit TeamPointIncrease(_teamId, _numberPoints, _campaignId);
    }

    /**
     * @dev To remove the number of points for a user.
     * Callable only by point admins
     */
    function removeUserPoints(address _userAddress, uint256 _numberPoints) external onlyPoint {
        // Increase the number of points for the user
        users[_userAddress].numberPoints = users[_userAddress].numberPoints.sub(_numberPoints);
    }

    /**
     * @dev To remove a set number of points for a set of users.
     */
    function removeUserPointsMultiple(address[] calldata _userAddresses, uint256 _numberPoints) external onlyPoint {
        require(_userAddresses.length < 1001, "Length must be < 1001");
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            users[_userAddresses[i]].numberPoints = users[_userAddresses[i]].numberPoints.sub(_numberPoints);
        }
    }

    /**
     * @dev To remove the number of points for a team.
     * Callable only by point admins
     */

    function removeTeamPoints(uint256 _teamId, uint256 _numberPoints) external onlyPoint {
        // Increase the number of points for the team
        teams[_teamId].numberPoints = teams[_teamId].numberPoints.sub(_numberPoints);
    }

    /**
     * @dev To add a NFT contract address for users to set their profile.
     * Callable only by owner admins.
     */
    function addNftAddress(address _nftAddress) external onlyOwner {
        require(IERC721(_nftAddress).supportsInterface(0x80ac58cd), "Not ERC721");
        grantRole(NFT_ROLE, _nftAddress);
    }

    /**
     * @dev Add a new teamId
     * Callable only by owner admins.
     */
    function addTeam(string calldata _teamName, string calldata _teamDescription) external onlyOwner {
        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_teamName);
        require(strBytes.length < 20, "Must be < 20");
        require(strBytes.length > 3, "Must be > 3");

        // Increment the _countTeams counter and get teamId
        _countTeams.increment();
        uint256 newTeamId = _countTeams.current();

        // Add new team data to the struct
        teams[newTeamId] = Team({
            teamName: _teamName,
            teamDescription: _teamDescription,
            numberUsers: 0,
            numberPoints: 0,
            isJoinable: true
        });

        numberTeams = newTeamId;
        emit TeamAdd(newTeamId, _teamName);
    }

    /**
     * @dev Function to change team.
     * Callable only by special admins.
     */
    function changeTeam(address _userAddress, uint256 _newTeamId) external onlySpecial {
        require(hasRegistered[_userAddress], "User doesn't exist");
        require((_newTeamId <= numberTeams) && (_newTeamId > 0), "teamId doesn't exist");
        require(teams[_newTeamId].isJoinable, "Team not joinable");
        require(users[_userAddress].teamId != _newTeamId, "Already in the team");

        // Get old teamId
        uint256 oldTeamId = users[_userAddress].teamId;

        // Change number of users in old team
        teams[oldTeamId].numberUsers = teams[oldTeamId].numberUsers.sub(1);

        // Change teamId in user mapping
        users[_userAddress].teamId = _newTeamId;

        // Change number of users in new team
        teams[_newTeamId].numberUsers = teams[_newTeamId].numberUsers.add(1);

        emit UserChangeTeam(_userAddress, oldTeamId, _newTeamId);
    }

    /**
     * @dev Claim CAKE to burn later.
     * Callable only by owner admins.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @dev Make a team joinable again.
     * Callable only by owner admins.
     */
    function makeTeamJoinable(uint256 _teamId) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");
        teams[_teamId].isJoinable = true;
    }

    /**
     * @dev Make a team not joinable.
     * Callable only by owner admins.
     */
    function makeTeamNotJoinable(uint256 _teamId) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");
        teams[_teamId].isJoinable = false;
    }

    /**
     * @dev Rename a team
     * Callable only by owner admins.
     */
    function renameTeam(
        uint256 _teamId,
        string calldata _teamName,
        string calldata _teamDescription
    ) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");

        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_teamName);
        require(strBytes.length < 20, "Must be < 20");
        require(strBytes.length > 3, "Must be > 3");

        teams[_teamId].teamName = _teamName;
        teams[_teamId].teamDescription = _teamDescription;
    }

    /**
     * @dev Update the number of CAKE to register
     * Callable only by owner admins.
     */
    function updateNumberCake(
        uint256 _newNumberCakeToReactivate,
        uint256 _newNumberCakeToRegister,
        uint256 _newNumberCakeToUpdate
    ) external onlyOwner {
        numberCakeToReactivate = _newNumberCakeToReactivate;
        numberCakeToRegister = _newNumberCakeToRegister;
        numberCakeToUpdate = _newNumberCakeToUpdate;
    }

    /**
     * @dev Check the user's profile for a given address
     */
    function getUserProfile(address _userAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            bool
        )
    {
        require(hasRegistered[_userAddress], "Not registered");
        return (
            users[_userAddress].userId,
            users[_userAddress].numberPoints,
            users[_userAddress].teamId,
            users[_userAddress].nftAddress,
            users[_userAddress].tokenId,
            users[_userAddress].isActive
        );
    }

    /**
     * @dev Check the user's status for a given address
     */
    function getUserStatus(address _userAddress) external view returns (bool) {
        return (users[_userAddress].isActive);
    }

    /**
     * @dev Check a team's profile
     */
    function getTeamProfile(uint256 _teamId)
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");
        return (
            teams[_teamId].teamName,
            teams[_teamId].teamDescription,
            teams[_teamId].numberUsers,
            teams[_teamId].numberPoints,
            teams[_teamId].isJoinable
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../math/SafeMath.sol";

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC721Receiver.sol";

  /**
   * @dev Implementation of the {IERC721Receiver} interface.
   *
   * Accepts all token transfers. 
   * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
   */
contract ERC721Holder is IERC721Receiver {

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

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
  function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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
pragma solidity ^0.6.0;

import "./IBEP20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

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
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IBEP20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance =
      token.allowance(address(this), spender).sub(
        value,
        "SafeBEP20: decreased allowance below zero"
      );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
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

    bytes memory returndata =
      address(token).functionCall(data, "SafeBEP20: low-level call failed");
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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../PancakeProfile.sol";

/** @title MockAdmin.
 * @notice It is a mock contract to test point roles
 * for PancakeProfile.
 */
contract MockAdmin is Ownable {
    PancakeProfile pancakeProfile;
    address public pancakeProfileAddress;

    mapping(address => bool) public hasReceivedPoints;

    uint256 public campaignId1;
    uint256 public campaignId2;
    uint256 public campaignId3;

    uint256 public numberFreePoints;

    constructor(address _pancakeProfileAddress) public {
        pancakeProfileAddress = _pancakeProfileAddress;
        pancakeProfile = PancakeProfile(pancakeProfileAddress);
        numberFreePoints = 88;
        campaignId1 = 711012101;
        campaignId2 = 811012101;
        campaignId3 = 511012101;
    }

    /**
     * @notice Increase number of team points. Only owner can call it.
     */
    function increaseTeamPointsPP(uint16 _teamId, uint256 _numberPoints) external onlyOwner {
        pancakeProfile.increaseTeamPoints(_teamId, _numberPoints, campaignId3);
    }

    /**
     * @notice Increase number of user points. Each address can call it once.
     */
    function increaseUserPointsPP() external {
        // Check if user has already claimed her free points
        require(!hasReceivedPoints[_msgSender()], "has claimed");

        // Check if user is active
        bool isActive;

        isActive = pancakeProfile.getUserStatus(_msgSender());

        require(isActive, "not active");

        // Increase the number of points
        hasReceivedPoints[_msgSender()] = true;
        pancakeProfile.increaseUserPoints(_msgSender(), numberFreePoints, campaignId1);
    }

    /**
     * @notice Increase number of points for multiple users. Only owner can call it.
     */
    function increaseUserPointsMultiplePP(address[] calldata _userAddresses, uint256 _numberPoints) external onlyOwner {
        pancakeProfile.increaseUserPointsMultiple(_userAddresses, _numberPoints, campaignId2);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/** @title MockCats.
 * @notice It is a mock contract to simulate
 * a new NFT token in tests.
 */
contract MockCats is ERC721, Ownable {
    using Counters for Counters.Counter;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    constructor() public ERC721("Mock Cats", "MC") {
        _setBaseURI("test/");
    }

    /**
     * @notice Mint NFTs to caller. Anyone can call it.
     */
    function mint() external returns (uint256) {
        uint256 newId = _tokenIds.current();
        _tokenIds.increment();
        _mint(address(msg.sender), newId);
        _setTokenURI(newId, "default");
        return newId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Receiver.sol";
import "../../introspection/ERC165.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";
import "../../utils/EnumerableSet.sol";
import "../../utils/EnumerableMap.sol";
import "../../utils/Strings.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
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
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a prefix in {tokenURI} to each token's URI, or
    * to the token ID if no specific URI is set for that token ID.
    */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
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
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
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
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
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
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

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

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/** @title MockBunnies.
 * @notice It is a mock contract to replace
 * PancakeBunnies in tests.
 */
contract MockBunnies is ERC721, Ownable {
    using Counters for Counters.Counter;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    constructor() public ERC721("Mock Bunnies", "MB") {
        _setBaseURI("test/");
    }

    /**
     * @notice Mint NFTs to caller. Anyone can call it.
     */
    function mint() external returns (uint256) {
        uint256 newId = _tokenIds.current();
        _tokenIds.increment();
        _mint(address(msg.sender), newId);
        _setTokenURI(newId, "default");
        return newId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/** @title PancakeBunnies.
 * @notice It is the contracts for PancakeSwap NFTs.
 */
contract PancakeBunnies is ERC721, Ownable {
    using Counters for Counters.Counter;

    // Map the number of tokens per bunnyId
    mapping(uint8 => uint256) public bunnyCount;

    // Map the number of tokens burnt per bunnyId
    mapping(uint8 => uint256) public bunnyBurnCount;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    // Map the bunnyId for each tokenId
    mapping(uint256 => uint8) private bunnyIds;

    // Map the bunnyName for a tokenId
    mapping(uint8 => string) private bunnyNames;

    constructor(string memory _baseURI) public ERC721("Pancake Bunnies", "PB") {
        _setBaseURI(_baseURI);
    }

    /**
     * @dev Get bunnyId for a specific tokenId.
     */
    function getBunnyId(uint256 _tokenId) external view returns (uint8) {
        return bunnyIds[_tokenId];
    }

    /**
     * @dev Get the associated bunnyName for a specific bunnyId.
     */
    function getBunnyName(uint8 _bunnyId) external view returns (string memory) {
        return bunnyNames[_bunnyId];
    }

    /**
     * @dev Get the associated bunnyName for a unique tokenId.
     */
    function getBunnyNameOfTokenId(uint256 _tokenId) external view returns (string memory) {
        uint8 bunnyId = bunnyIds[_tokenId];
        return bunnyNames[bunnyId];
    }

    /**
     * @dev Mint NFTs. Only the owner can call it.
     */
    function mint(
        address _to,
        string calldata _tokenURI,
        uint8 _bunnyId
    ) external onlyOwner returns (uint256) {
        uint256 newId = _tokenIds.current();
        _tokenIds.increment();
        bunnyIds[newId] = _bunnyId;
        bunnyCount[_bunnyId] = bunnyCount[_bunnyId].add(1);
        _mint(_to, newId);
        _setTokenURI(newId, _tokenURI);
        return newId;
    }

    /**
     * @dev Set a unique name for each bunnyId. It is supposed to be called once.
     */
    function setBunnyName(uint8 _bunnyId, string calldata _name) external onlyOwner {
        bunnyNames[_bunnyId] = _name;
    }

    /**
     * @dev Burn a NFT token. Callable by owner only.
     */
    function burn(uint256 _tokenId) external onlyOwner {
        uint8 bunnyIdBurnt = bunnyIds[_tokenId];
        bunnyCount[bunnyIdBurnt] = bunnyCount[bunnyIdBurnt].sub(1);
        bunnyBurnCount[bunnyIdBurnt] = bunnyBurnCount[bunnyIdBurnt].add(1);
        _burn(_tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./PancakeBunnies.sol";

/** @title BunnyMintingStation.
 * @dev This contract allows different factories to mint
 * Pancake Collectibles/Bunnies.
 */
contract BunnyMintingStation is AccessControl {
    PancakeBunnies public pancakeBunnies;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Modifier for minting roles
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Not a minting role");
        _;
    }

    // Modifier for admin roles
    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not an admin role");
        _;
    }

    constructor(PancakeBunnies _pancakeBunnies) public {
        pancakeBunnies = _pancakeBunnies;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Mint NFTs from the PancakeBunnies contract.
     * Users can specify what bunnyId they want to mint. Users can claim once.
     * There is a limit on how many are distributed. It requires CAKE balance to be > 0.
     */
    function mintCollectible(
        address _tokenReceiver,
        string calldata _tokenURI,
        uint8 _bunnyId
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = pancakeBunnies.mint(_tokenReceiver, _tokenURI, _bunnyId);
        return tokenId;
    }

    /**
     * @notice Set up names for bunnies.
     * @dev Only the main admins can set it.
     */
    function setBunnyName(uint8 _bunnyId, string calldata _bunnyName) external onlyOwner {
        pancakeBunnies.setBunnyName(_bunnyId, _bunnyName);
    }

    /**
     * @dev It transfers the ownership of the NFT contract to a new address.
     * @dev Only the main admins can set it.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        pancakeBunnies.transferOwnership(_newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "./interfaces/IPancakeProfile.sol";
import "./BunnyMintingStation.sol";

/** @title TradingCompV3.
@notice It is a contract for users to collect points
based on off-chain events
*/
contract TradingCompV3 is Ownable {
    using SafeBEP20 for IBEP20;

    BunnyMintingStation public bunnyMintingStation;
    IBEP20 public cakeToken;
    IBEP20 public moboxToken;
    IBEP20 public moboxMisteryBoxToken;

    IPancakeProfile public pancakeProfile;

    uint256 public constant numberTeams = 3;

    uint256 public competitionId;
    uint8 public bunnyId;
    uint256 public winningTeamId; // set to 0 as default
    string public bunnyTokenURI;

    enum CompetitionStatus {
        Registration,
        Open,
        Close,
        Claiming,
        Over
    }

    CompetitionStatus public currentStatus;

    mapping(address => UserStats) public userTradingStats;

    mapping(uint256 => CompetitionRewards) private _rewardCompetitions;

    struct CompetitionRewards {
        uint256[5] userCampaignId; // campaignId for user increase
        uint256[5] cakeRewards; // cake rewards per group
        uint256[5] moboxRewards; // cake rewards per group
        uint256[5] pointUsers; // number of points per user
    }

    struct UserStats {
        uint256 rewardGroup; // 0 to 4 --> 4 top / 0: bottom
        uint256 teamId; // 1 - 3
        bool canClaimMysteryBox; // true or false
        bool hasRegistered; // true or false
        bool hasClaimed; // true or false
    }

    event NewCompetitionStatus(CompetitionStatus status, uint256 competitionId);
    event TeamRewardsUpdate(uint256 teamId, uint256 competitionId);
    event UserRegister(address userAddress, uint256 teamId, uint256 competitionId);
    event UserUpdateMultiple(address[] userAddresses, uint256 rewardGroup, uint256 competitionId);
    event UserUpdateMultipleMobox(address[] userAddresses, bool canClaimMysteryBox, uint256 competitionId);
    event WinningTeam(uint256 teamId, uint256 competitionId);

    /**
     * @notice It initializes the contract.
     * @param _pancakeProfileAddress: PancakeProfile address
     * @param _bunnyStationAddress: BunnyMintingStation address
     * @param _cakeTokenAddress: the address of the CAKE token
     * @param _moboxTokenAddress: the address of the MOBOX token
     * @param _moboxMisteryBoxTokenAddress: the address of the MOBOX mystery box token
     * @param _competitionId: competition uniq id
     */
    constructor(
        address _pancakeProfileAddress,
        address _bunnyStationAddress,
        address _cakeTokenAddress,
        address _moboxTokenAddress,
        address _moboxMisteryBoxTokenAddress,
        uint256 _competitionId
    ) public {
        pancakeProfile = IPancakeProfile(_pancakeProfileAddress);
        bunnyMintingStation = BunnyMintingStation(_bunnyStationAddress);
        cakeToken = IBEP20(_cakeTokenAddress);
        moboxToken = IBEP20(_moboxTokenAddress);
        moboxMisteryBoxToken = IBEP20(_moboxMisteryBoxTokenAddress);
        competitionId = _competitionId;
        currentStatus = CompetitionStatus.Registration;
    }

    /**
     * @notice It allows users to claim reward after the end of trading competition.
     * @dev It is only available during claiming phase
     */
    function claimReward() external {
        address senderAddress = _msgSender();

        require(userTradingStats[senderAddress].hasRegistered, "NOT_REGISTERED");
        require(!userTradingStats[senderAddress].hasClaimed, "HAS_CLAIMED");
        require(currentStatus == CompetitionStatus.Claiming, "NOT_IN_CLAIMING");

        userTradingStats[senderAddress].hasClaimed = true;

        uint256 userRewardGroup = userTradingStats[senderAddress].rewardGroup;
        uint256 userTeamId = userTradingStats[senderAddress].teamId;
        bool canClaimMysteryBox = userTradingStats[senderAddress].canClaimMysteryBox;

        CompetitionRewards memory userRewards = _rewardCompetitions[userTeamId];

        if (userRewardGroup > 0) {
            cakeToken.safeTransfer(senderAddress, userRewards.cakeRewards[userRewardGroup]);
            moboxToken.safeTransfer(senderAddress, userRewards.moboxRewards[userRewardGroup]);

            // TOP 100 users
            if (userRewardGroup < 1) {
                bunnyMintingStation.mintCollectible(senderAddress, bunnyTokenURI, bunnyId);
                // send mobox avatar NFT
            }
            if (canClaimMysteryBox) {
                moboxMisteryBoxToken.safeTransfer(_msgSender(), 1000000000000000000);
            }
        }

        // User collects points
        pancakeProfile.increaseUserPoints(
            senderAddress,
            userRewards.pointUsers[userRewardGroup],
            userRewards.userCampaignId[userRewardGroup]
        );
    }

    /**
     * @notice It allows users to register for trading competition
     * @dev Only callable if the user has an active PancakeProfile.
     */
    function register() external {
        address senderAddress = _msgSender();

        // 1. Checks if user has registered
        require(!userTradingStats[senderAddress].hasRegistered, "HAS_REGISTERED");

        // 2. Check whether it is joinable
        require(currentStatus == CompetitionStatus.Registration, "NOT_IN_REGISTRATION");

        // 3. Check if active and records the teamId
        uint256 userTeamId;
        bool isUserActive;

        (, , userTeamId, , , isUserActive) = pancakeProfile.getUserProfile(senderAddress);

        require(isUserActive, "NOT_ACTIVE");

        // 4. Write in storage user stats for the registered user
        UserStats storage newUserStats = userTradingStats[senderAddress];
        newUserStats.teamId = userTeamId;
        newUserStats.hasRegistered = true;

        emit UserRegister(senderAddress, userTeamId, competitionId);
    }

    /**
     * @notice It allows the owner to change the competition status
     * @dev Only callable by owner.
     * @param _status: CompetitionStatus (uint8)
     */
    function updateCompetitionStatus(CompetitionStatus _status) external onlyOwner {
        require(_status != CompetitionStatus.Registration, "IN_REGISTRATION");

        if (_status == CompetitionStatus.Open) {
            require(currentStatus == CompetitionStatus.Registration, "NOT_IN_REGISTRATION");
        } else if (_status == CompetitionStatus.Close) {
            require(currentStatus == CompetitionStatus.Open, "NOT_OPEN");
        } else if (_status == CompetitionStatus.Claiming) {
            require(winningTeamId > 0, "WINNING_TEAM_NOT_SET");
            require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        } else {
            require(currentStatus == CompetitionStatus.Claiming, "NOT_CLAIMING");
        }

        currentStatus = _status;

        emit NewCompetitionStatus(currentStatus, competitionId);
    }

    /**
     * @notice It allows the owner to claim the CAKE remainder
     * @dev Only callable by owner.
     * @param _amount: amount of CAKE to withdraw (decimals = 18)
     */
    function claimCakeRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
    * @notice It allows the owner to claim the MOBOX remainder
     * @dev Only callable by owner.
     * @param _amount: amount of MOBOX to withdraw (decimals = 18)
     */
    function claimMoboxRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        moboxToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to claim the MOBOX mystery box remainder
     * @dev Only callable by owner.
     * @param _amount: amount of MOBOX mystery box to withdraw (decimals = 18)
     */
    function claimMoboxMysteryRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        moboxMisteryBoxToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to update team rewards
     * @dev Only callable by owner.
     * @param _teamId: the teamId
     * @param _userCampaignIds: campaignIds for each user group for teamId
     * @param _cakeRewards: CAKE rewards for each user group for teamId
     * @param _moboxRewards: MOBOX rewards for each user group for teamId
     * @param _pointRewards: point to collect for each user group for teamId
     */
    function updateTeamRewards(
        uint256 _teamId,
        uint256[5] calldata _userCampaignIds,
        uint256[5] calldata _cakeRewards,
        uint256[5] calldata _moboxRewards,
        uint256[5] calldata _pointRewards
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        _rewardCompetitions[_teamId].userCampaignId = _userCampaignIds;
        _rewardCompetitions[_teamId].cakeRewards = _cakeRewards;
        _rewardCompetitions[_teamId].moboxRewards = _moboxRewards;
        _rewardCompetitions[_teamId].pointUsers = _pointRewards;

        emit TeamRewardsUpdate(_teamId, competitionId);
    }

    /**
     * @notice It allows the owner to update user statuses
     * @dev Only callable by owner. Use with caution!
     * @param _addressesToUpdate: the array of addresses
     * @param _rewardGroup: the reward group
     */
    function updateUserStatusMultiple(address[] calldata _addressesToUpdate, uint256 _rewardGroup) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        require(_rewardGroup <= 4, "TOO_HIGH");
        for (uint256 i = 0; i < _addressesToUpdate.length; i++) {
            userTradingStats[_addressesToUpdate[i]].rewardGroup = _rewardGroup;
        }

        emit UserUpdateMultiple(_addressesToUpdate, _rewardGroup, competitionId);
    }

    /**
     * @notice It allows the owner to update user statuses for MOBOX mystery box reward
     * @dev Only callable by owner. Use with caution!
     * @param _addressesToUpdate: the array of addresses
     * @param _canClaimMysteryBox: flag for mystery box
     */
    function updateUserStatusMultiple(address[] calldata _addressesToUpdate, bool _canClaimMysteryBox) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        for (uint256 i = 0; i < _addressesToUpdate.length; i++) {
            userTradingStats[_addressesToUpdate[i]].canClaimMysteryBox = _canClaimMysteryBox;
        }

        emit UserUpdateMultipleMobox(_addressesToUpdate, _canClaimMysteryBox, competitionId);
    }

    /**
     * @notice It allows the owner to set the winning teamId (to collect NFT)
     * @dev Only callable by owner.
     * @param _winningTeamId: the winning teamId
     * @param _tokenURI: the tokenURI
     * @param _bunnyId: the bunnyId for winners (e.g. 15)
     */
    function updateWinningTeamAndTokenURIAndBunnyId(
        uint256 _winningTeamId,
        string calldata _tokenURI,
        uint8 _bunnyId
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        require((_winningTeamId > 0) && (_winningTeamId <= numberTeams), "NOT_VALID_TEAM_ID");
        require(_bunnyId > 14, "ID_TOO_LOW");
        winningTeamId = _winningTeamId;
        bunnyTokenURI = _tokenURI;
        bunnyId = _bunnyId;
        emit WinningTeam(_winningTeamId, competitionId);
    }

    /**
     * @notice It checks the claim information
     * @dev It does not check if user has a profile since registration required a profile.
     * @param _userAddress: the user address
     * @return hasRegistered: has the user registered
     * @return hasUserClaimed: whether user has claimed
     * @return userRewardGroup: the final reward group for each user (i.e. tier)
     * @return userCakeRewards: the CAKE to claim/claimed
     * @return userMoboxRewards: the MOBOX to claim/claimed
     * @return userPointReward: the number of points to claim/claimed
     * @return canClaimMysteryBox: whether the user gets/got a mystery box
     * @return canClaimNFT: whether the user gets/got a NFT
     */
    function claimInformation(address _userAddress)
        external
        view
        returns (
            bool,
            bool,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        UserStats memory userStats = userTradingStats[_userAddress];
        bool hasUserRegistered = userStats.hasRegistered;
        if ((currentStatus != CompetitionStatus.Claiming) && (currentStatus != CompetitionStatus.Over)) {
            return (hasUserRegistered, false, 0, 0, 0, 0, false, false);
        } else if (!hasUserRegistered) {
            return (hasUserRegistered, false, 0, 0, 0, 0, false, false);
        } else {
            uint256 userRewardGroup = userStats.rewardGroup;

            bool canClaimNFT;
            if (userRewardGroup < 1) {
                canClaimNFT = true;
            }

            uint256 userTeamId = userTradingStats[_userAddress].teamId;
            CompetitionRewards memory compRewards = _rewardCompetitions[userTeamId];

            return (
                hasUserRegistered,
                userStats.hasClaimed,
                userRewardGroup,
                compRewards.cakeRewards[userRewardGroup],
                compRewards.moboxRewards[userRewardGroup],
                compRewards.pointUsers[userRewardGroup],
                userStats.canClaimMysteryBox,
                canClaimNFT
            );
        }
    }

    /**
     * @notice It checks the reward groups for each team
     */
    function viewRewardTeams() external view returns (CompetitionRewards[] memory) {
        CompetitionRewards[] memory listCompetitionRewards = new CompetitionRewards[](numberTeams);
        for (uint256 i = 0; i < numberTeams; i++) {
            listCompetitionRewards[i] = _rewardCompetitions[i + 1];
        }
        return listCompetitionRewards;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/** @title IPancakeProfile.
 */
interface IPancakeProfile {
    function createProfile(
        uint256 _teamId,
        address _nftAddress,
        uint256 _tokenId
    ) external;

    /**
     * @dev To pause user profile. It releases the NFT.
     * Callable only by registered users.
     */
    function pauseProfile() external;

    /**
     * @dev To update user profile.
     * Callable only by registered users.
     */
    function updateProfile() external;

    /**
     * @dev To reactivate user profile.
     * Callable only by registered users.
     */
    function reactivateProfile(address _nftAddress, uint256 _tokenId) external;

    /**
     * @dev To increase the number of points for a user.
     * Callable only by point admins
     */
    function increaseUserPoints(
        address _userAddress,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external;

    /**
     * @dev To increase the number of points for a set of users.
     * Callable only by point admins
     */
    function increaseUserPointsMultiple(
        address[] calldata _userAddresses,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external;

    /**
     * @dev To increase the number of points for a team.
     * Callable only by point admins
     */

    function increaseTeamPoints(
        uint256 _teamId,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external;

    /**
     * @dev To remove the number of points for a user.
     * Callable only by point admins
     */
    function removeUserPoints(address _userAddress, uint256 _numberPoints) external;

    /**
     * @dev To remove a set number of points for a set of users.
     */
    function removeUserPointsMultiple(address[] calldata _userAddresses, uint256 _numberPoints) external;

    /**
     * @dev To remove the number of points for a team.
     * Callable only by point admins
     */

    function removeTeamPoints(uint256 _teamId, uint256 _numberPoints) external;

    /**
     * @dev To add a NFT contract address for users to set their profile.
     * Callable only by owner admins.
     */
    function addNftAddress(address _nftAddress) external;

    /**
     * @dev Add a new teamId
     * Callable only by owner admins.
     */
    function addTeam() external;

    /**
     * @dev Function to change team.
     * Callable only by special admins.
     */
    function changeTeam(address _userAddress, uint256 _newTeamId) external;

    /**
     * @dev Claim CAKE to burn later.
     * Callable only by owner admins.
     */
    function claimFee(uint256 _amount) external;

    /**
     * @dev Make a team joinable again.
     * Callable only by owner admins.
     */
    function makeTeamJoinable(uint256 _teamId) external;

    /**
     * @dev Make a team not joinable.
     * Callable only by owner admins.
     */
    function makeTeamNotJoinable(uint256 _teamId) external;

    /**
     * @dev Rename a team
     * Callable only by owner admins.
     */
    function renameTeam() external;

    /**
     * @dev Update the number of CAKE to register
     * Callable only by owner admins.
     */
    function updateNumberCake() external;

    /**
     * @dev Check the user's profile for a given address
     */
    function getUserProfile(address _userAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            bool
        );

    /**
     * @dev Check the user's status for a given address
     */
    function getUserStatus(address _userAddress) external view returns (bool);

    /**
     * @dev Check a team's profile
     */
    function getTeamProfile(uint256 _teamId)
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "./interfaces/IPancakeProfile.sol";
import "./BunnyMintingStation.sol";
import "./TradingCompV2.sol";

/** @title TradingCompV2RewardDistribution.
@notice It is a contract for users to collect points
based on off-chain events
*/
contract TradingCompV2RewardDistribution is Ownable {
    using SafeBEP20 for IBEP20;

    BunnyMintingStation public bunnyMintingStation;
    IBEP20 public cakeToken;
    IBEP20 public lazioToken;
    IBEP20 public portoToken;
    IBEP20 public santosToken;

    IPancakeProfile public pancakeProfile;
    TradingCompV2 public tradingCompV2;

    uint256 public constant numberTeams = 3;

    uint8 public bunnyId;
    uint256 public winningTeamId; // set to 0 as default
    string public tokenURI;

    enum CompetitionStatus {
        Registration,
        Open,
        Close,
        Claiming,
        Over
    }

    CompetitionStatus public currentStatus;

    mapping(address => UserStats) public userTradingStats;

    mapping(uint256 => CompetitionRewards) private _rewardCompetitions;

    struct CompetitionRewards {
        uint256[5] userCampaignId; // campaignId for user increase
        uint256[5] cakeRewards; // cake rewards per group
        uint256[5] lazioRewards; // lazio fan token rewards per group
        uint256[5] portoRewards; // porto fan token rewards per group
        uint256[5] santosRewards; // santos fan token rewards per group
        uint256[5] pointUsers; // number of points per user
    }

    struct UserStats {
        bool hasClaimed; // true or false
    }

    event NewCompetitionStatus(CompetitionStatus status);
    event TeamRewardsUpdate(uint256 teamId);
    event UserRegister(address userAddress, uint256 teamId);
    event UserUpdateMultiple(address[] userAddresses, uint256 rewardGroup);
    event WinningTeam(uint256 teamId);

    /**
     * @notice It initializes the contract.
     * @param _pancakeProfileAddress: PancakeProfile address
     * @param _bunnyStationAddress: BunnyMintingStation address
     * @param _cakeTokenAddress: the address of the CAKE token
     * @param _lazioTokenAddress: the address of the LAZIO fan token
     * @param _portoTokenAddress: the address of the PORTO fan token
     * @param _santosTokenAddress: the address of the SANTOS fan token
     * @param _tradingCompV2Address: the address of the TradingCompV2 fan token
     */
    constructor(
        address _pancakeProfileAddress,
        address _bunnyStationAddress,
        address _cakeTokenAddress,
        address _lazioTokenAddress,
        address _portoTokenAddress,
        address _santosTokenAddress,
        address _tradingCompV2Address
    ) public {
        pancakeProfile = IPancakeProfile(_pancakeProfileAddress);
        bunnyMintingStation = BunnyMintingStation(_bunnyStationAddress);
        cakeToken = IBEP20(_cakeTokenAddress);
        lazioToken = IBEP20(_lazioTokenAddress);
        portoToken = IBEP20(_portoTokenAddress);
        santosToken = IBEP20(_santosTokenAddress);
        tradingCompV2 = TradingCompV2(_tradingCompV2Address);
        currentStatus = CompetitionStatus.Open;
    }

    /**
     * @notice It allows users to claim reward after the end of trading competition.
     * @dev It is only available during claiming phase
     */
    function claimReward() external {
        address senderAddress = _msgSender();

        bool hasUserRegistered;
        bool hasUserClaimed;
        uint256 userRewardGroup;
        (hasUserRegistered, hasUserClaimed, userRewardGroup, , , , , , ) = tradingCompV2.claimInformation(
            senderAddress
        );

        uint256 userTeamId;
        (, , userTeamId, , , ) = pancakeProfile.getUserProfile(senderAddress);

        require(hasUserRegistered, "NOT_REGISTERED");
        require(!userTradingStats[senderAddress].hasClaimed && !hasUserClaimed, "HAS_CLAIMED");
        require(currentStatus == CompetitionStatus.Claiming, "NOT_IN_CLAIMING");

        userTradingStats[senderAddress].hasClaimed = true;

        CompetitionRewards memory userRewards = _rewardCompetitions[userTeamId];

        if (userRewardGroup > 0) {
            cakeToken.safeTransfer(senderAddress, userRewards.cakeRewards[userRewardGroup]);
            lazioToken.safeTransfer(senderAddress, userRewards.lazioRewards[userRewardGroup]);
            portoToken.safeTransfer(senderAddress, userRewards.portoRewards[userRewardGroup]);
            santosToken.safeTransfer(senderAddress, userRewards.santosRewards[userRewardGroup]);

            if (userTeamId == winningTeamId) {
                bunnyMintingStation.mintCollectible(senderAddress, tokenURI, bunnyId);
            }
        }

        // User collects points
        pancakeProfile.increaseUserPoints(
            senderAddress,
            userRewards.pointUsers[userRewardGroup],
            userRewards.userCampaignId[userRewardGroup]
        );
    }

    /**
     * @notice It allows the owner to change the competition status
     * @dev Only callable by owner.
     * @param _status: CompetitionStatus (uint8)
     */
    function updateCompetitionStatus(CompetitionStatus _status) external onlyOwner {
        currentStatus = _status;
        emit NewCompetitionStatus(currentStatus);
    }

    /**
     * @notice It allows the owner to claim the CAKE remainder
     * @dev Only callable by owner.
     * @param _amount: amount of CAKE to withdraw (decimals = 18)
     */
    function claimCakeRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to claim the LAZIO remainder
     * @dev Only callable by owner.
     * @param _amount: amount of LAZIO to withdraw (decimals = 8)
     */
    function claimLazioRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        lazioToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to claim the PORTO remainder
     * @dev Only callable by owner.
     * @param _amount: amount of PORTO to withdraw (decimals = 8)
     */
    function claimPortoRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        portoToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to claim the SANTOS remainder
     * @dev Only callable by owner.
     * @param _amount: amount of SANTOS to withdraw (decimals = 8)
     */
    function claimSantosRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        santosToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to update team rewards
     * @dev Only callable by owner.
     * @param _teamId: the teamId
     * @param _userCampaignIds: campaignIds for each user group for teamId
     * @param _cakeRewards: CAKE rewards for each user group for teamId
     * @param _lazioRewards: LAZIO rewards for each user group for teamId
     * @param _portoRewards: PORTO rewards for each user group for teamId
     * @param _santosRewards: SANTOS rewards for each user group for teamId
     * @param _pointRewards: point to collect for each user group for teamId
     */
    function updateTeamRewards(
        uint256 _teamId,
        uint256[5] calldata _userCampaignIds,
        uint256[5] calldata _cakeRewards,
        uint256[5] calldata _lazioRewards,
        uint256[5] calldata _portoRewards,
        uint256[5] calldata _santosRewards,
        uint256[5] calldata _pointRewards
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Open, "NOT_OPEN");
        _rewardCompetitions[_teamId].userCampaignId = _userCampaignIds;
        _rewardCompetitions[_teamId].cakeRewards = _cakeRewards;
        _rewardCompetitions[_teamId].lazioRewards = _lazioRewards;
        _rewardCompetitions[_teamId].portoRewards = _portoRewards;
        _rewardCompetitions[_teamId].santosRewards = _santosRewards;
        _rewardCompetitions[_teamId].pointUsers = _pointRewards;

        emit TeamRewardsUpdate(_teamId);
    }

    /**
     * @notice It allows the owner to set the winning teamId (to collect NFT)
     * @dev Only callable by owner.
     * @param _winningTeamId: the winning teamId
     * @param _tokenURI: the tokenURI
     * @param _bunnyId: the bunnyId for winners (e.g. 15)
     */
    function updateWinningTeamAndTokenURIAndBunnyId(
        uint256 _winningTeamId,
        string calldata _tokenURI,
        uint8 _bunnyId
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Open, "NOT_OPEN");
        require((_winningTeamId > 0) && (_winningTeamId <= numberTeams), "NOT_VALID_TEAM_ID");
        require(_bunnyId > 14, "ID_TOO_LOW");
        winningTeamId = _winningTeamId;
        tokenURI = _tokenURI;
        bunnyId = _bunnyId;
        emit WinningTeam(_winningTeamId);
    }

    /**
     * @notice It checks the claim information
     * @dev It does not check if user has a profile since registration required a profile.
     * @param _userAddress: the user address
     * @return hasRegistered: has the user registered
     * @return hasUserClaimed: whether user has claimed
     * @return userRewardGroup: the final reward group for each user (i.e. tier)
     * @return userCakeRewards: the CAKE to claim/claimed
     * @return userLazioRewards: the LAZIO to claim/claimed
     * @return userPortoRewards: the PORTO to claim/claimed
     * @return userSantosRewards: the Santos to claim/claimed
     * @return userPointReward: the number of points to claim/claimed
     * @return canClaimNFT: whether the user gets/got a NFT
     */
    function claimInformation(address _userAddress)
        external
        view
        returns (
            bool,
            bool,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        bool hasUserRegistered;
        bool hasUserClaimed;
        uint256 userRewardGroup;
        (hasUserRegistered, hasUserClaimed, userRewardGroup, , , , , , ) = tradingCompV2.claimInformation(_userAddress);
        hasUserClaimed = hasUserClaimed || userTradingStats[_userAddress].hasClaimed;

        uint256 userTeamId;
        (, , userTeamId, , , ) = pancakeProfile.getUserProfile(_userAddress);

        bool canClaimNFT;
        if ((userTeamId == winningTeamId) && (userRewardGroup > 0)) {
            canClaimNFT = true;
        }

        return (
            hasUserRegistered,
            hasUserClaimed,
            userRewardGroup,
            _rewardCompetitions[userTeamId].cakeRewards[userRewardGroup],
            _rewardCompetitions[userTeamId].lazioRewards[userRewardGroup],
            _rewardCompetitions[userTeamId].portoRewards[userRewardGroup],
            _rewardCompetitions[userTeamId].santosRewards[userRewardGroup],
            _rewardCompetitions[userTeamId].pointUsers[userRewardGroup],
            canClaimNFT
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "./interfaces/IPancakeProfile.sol";
import "./BunnyMintingStation.sol";

/** @title TradingCompV2.
@notice It is a contract for users to collect points
based on off-chain events
*/
contract TradingCompV2 is Ownable {
    using SafeBEP20 for IBEP20;

    BunnyMintingStation public bunnyMintingStation;
    IBEP20 public cakeToken;
    IBEP20 public lazioToken;
    IBEP20 public portoToken;
    IBEP20 public santosToken;

    IPancakeProfile public pancakeProfile;

    uint256 public constant numberTeams = 3;

    uint256 public competitionId;
    uint8 public bunnyId;
    uint256 public winningTeamId; // set to 0 as default
    string public tokenURI;

    enum CompetitionStatus {
        Registration,
        Open,
        Close,
        Claiming,
        Over
    }

    CompetitionStatus public currentStatus;

    mapping(address => UserStats) public userTradingStats;

    mapping(uint256 => CompetitionRewards) private _rewardCompetitions;

    struct CompetitionRewards {
        uint256[5] userCampaignId; // campaignId for user increase
        uint256[5] cakeRewards; // cake rewards per group
        uint256[5] lazioRewards; // lazio fan token rewards per group
        uint256[5] portoRewards; // porto fan token rewards per group
        uint256[5] santosRewards; // santos fan token rewards per group
        uint256[5] pointUsers; // number of points per user
    }

    struct UserStats {
        uint256 rewardGroup; // 0 to 4 --> 4 top / 0: bottom
        uint256 teamId; // 1 - 3
        bool hasRegistered; // true or false
        bool hasClaimed; // true or false
    }

    event NewCompetitionStatus(CompetitionStatus status, uint256 competitionId);
    event TeamRewardsUpdate(uint256 teamId, uint256 competitionId);
    event UserRegister(address userAddress, uint256 teamId, uint256 competitionId);
    event UserUpdateMultiple(address[] userAddresses, uint256 rewardGroup, uint256 competitionId);
    event WinningTeam(uint256 teamId, uint256 competitionId);

    /**
     * @notice It initializes the contract.
     * @param _pancakeProfileAddress: PancakeProfile address
     * @param _bunnyStationAddress: BunnyMintingStation address
     * @param _cakeTokenAddress: the address of the CAKE token
     * @param _lazioTokenAddress: the address of the LAZIO fan token
     * @param _portoTokenAddress: the address of the PORTO fan token
     * @param _santosTokenAddress: the address of the SANTOS fan token
     * @param _competitionId: competition uniq id
     */
    constructor(
        address _pancakeProfileAddress,
        address _bunnyStationAddress,
        address _cakeTokenAddress,
        address _lazioTokenAddress,
        address _portoTokenAddress,
        address _santosTokenAddress,
        uint256 _competitionId
    ) public {
        pancakeProfile = IPancakeProfile(_pancakeProfileAddress);
        bunnyMintingStation = BunnyMintingStation(_bunnyStationAddress);
        cakeToken = IBEP20(_cakeTokenAddress);
        lazioToken = IBEP20(_lazioTokenAddress);
        portoToken = IBEP20(_portoTokenAddress);
        santosToken = IBEP20(_santosTokenAddress);
        competitionId = _competitionId;
        currentStatus = CompetitionStatus.Registration;
    }

    /**
     * @notice It allows users to claim reward after the end of trading competition.
     * @dev It is only available during claiming phase
     */
    function claimReward() external {
        address senderAddress = _msgSender();

        require(userTradingStats[senderAddress].hasRegistered, "NOT_REGISTERED");
        require(!userTradingStats[senderAddress].hasClaimed, "HAS_CLAIMED");
        require(currentStatus == CompetitionStatus.Claiming, "NOT_IN_CLAIMING");

        userTradingStats[senderAddress].hasClaimed = true;

        uint256 userRewardGroup = userTradingStats[senderAddress].rewardGroup;
        uint256 userTeamId = userTradingStats[senderAddress].teamId;

        CompetitionRewards memory userRewards = _rewardCompetitions[userTeamId];

        if (userRewardGroup > 0) {
            cakeToken.safeTransfer(senderAddress, userRewards.cakeRewards[userRewardGroup]);
            lazioToken.safeTransfer(senderAddress, userRewards.lazioRewards[userRewardGroup]);
            portoToken.safeTransfer(senderAddress, userRewards.portoRewards[userRewardGroup]);
            santosToken.safeTransfer(senderAddress, userRewards.santosRewards[userRewardGroup]);

            if (userTeamId == winningTeamId) {
                bunnyMintingStation.mintCollectible(senderAddress, tokenURI, bunnyId);
            }
        }

        // User collects points
        pancakeProfile.increaseUserPoints(
            senderAddress,
            userRewards.pointUsers[userRewardGroup],
            userRewards.userCampaignId[userRewardGroup]
        );
    }

    /**
     * @notice It allows users to register for trading competition
     * @dev Only callable if the user has an active PancakeProfile.
     */
    function register() external {
        address senderAddress = _msgSender();

        // 1. Checks if user has registered
        require(!userTradingStats[senderAddress].hasRegistered, "HAS_REGISTERED");

        // 2. Check whether it is joinable
        require(currentStatus == CompetitionStatus.Registration, "NOT_IN_REGISTRATION");

        // 3. Check if active and records the teamId
        uint256 userTeamId;
        bool isUserActive;

        (, , userTeamId, , , isUserActive) = pancakeProfile.getUserProfile(senderAddress);

        require(isUserActive, "NOT_ACTIVE");

        // 4. Write in storage user stats for the registered user
        UserStats storage newUserStats = userTradingStats[senderAddress];
        newUserStats.teamId = userTeamId;
        newUserStats.hasRegistered = true;

        emit UserRegister(senderAddress, userTeamId, competitionId);
    }

    /**
     * @notice It allows the owner to change the competition status
     * @dev Only callable by owner.
     * @param _status: CompetitionStatus (uint8)
     */
    function updateCompetitionStatus(CompetitionStatus _status) external onlyOwner {
        require(_status != CompetitionStatus.Registration, "IN_REGISTRATION");

        if (_status == CompetitionStatus.Open) {
            require(currentStatus == CompetitionStatus.Registration, "NOT_IN_REGISTRATION");
        } else if (_status == CompetitionStatus.Close) {
            require(currentStatus == CompetitionStatus.Open, "NOT_OPEN");
        } else if (_status == CompetitionStatus.Claiming) {
            require(winningTeamId > 0, "WINNING_TEAM_NOT_SET");
            require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        } else {
            require(currentStatus == CompetitionStatus.Claiming, "NOT_CLAIMING");
        }

        currentStatus = _status;

        emit NewCompetitionStatus(currentStatus, competitionId);
    }

    /**
     * @notice It allows the owner to claim the CAKE remainder
     * @dev Only callable by owner.
     * @param _amount: amount of CAKE to withdraw (decimals = 18)
     */
    function claimCakeRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to claim the LAZIO remainder
     * @dev Only callable by owner.
     * @param _amount: amount of LAZIO to withdraw (decimals = 8)
     */
    function claimLazioRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        lazioToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to claim the PORTO remainder
     * @dev Only callable by owner.
     * @param _amount: amount of PORTO to withdraw (decimals = 8)
     */
    function claimPortoRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        portoToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to claim the SANTOS remainder
     * @dev Only callable by owner.
     * @param _amount: amount of SANTOS to withdraw (decimals = 8)
     */
    function claimSantosRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        santosToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to update team rewards
     * @dev Only callable by owner.
     * @param _teamId: the teamId
     * @param _userCampaignIds: campaignIds for each user group for teamId
     * @param _cakeRewards: CAKE rewards for each user group for teamId
     * @param _lazioRewards: LAZIO rewards for each user group for teamId
     * @param _portoRewards: PORTO rewards for each user group for teamId
     * @param _santosRewards: SANTOS rewards for each user group for teamId
     * @param _pointRewards: point to collect for each user group for teamId
     */
    function updateTeamRewards(
        uint256 _teamId,
        uint256[5] calldata _userCampaignIds,
        uint256[5] calldata _cakeRewards,
        uint256[5] calldata _lazioRewards,
        uint256[5] calldata _portoRewards,
        uint256[5] calldata _santosRewards,
        uint256[5] calldata _pointRewards
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        _rewardCompetitions[_teamId].userCampaignId = _userCampaignIds;
        _rewardCompetitions[_teamId].cakeRewards = _cakeRewards;
        _rewardCompetitions[_teamId].lazioRewards = _lazioRewards;
        _rewardCompetitions[_teamId].portoRewards = _portoRewards;
        _rewardCompetitions[_teamId].santosRewards = _santosRewards;
        _rewardCompetitions[_teamId].pointUsers = _pointRewards;

        emit TeamRewardsUpdate(_teamId, competitionId);
    }

    /**
     * @notice It allows the owner to update user statuses
     * @dev Only callable by owner. Use with caution!
     * @param _addressesToUpdate: the array of addresses
     * @param _rewardGroup: the reward group
     */
    function updateUserStatusMultiple(address[] calldata _addressesToUpdate, uint256 _rewardGroup) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        require(_rewardGroup <= 4, "TOO_HIGH");
        for (uint256 i = 0; i < _addressesToUpdate.length; i++) {
            userTradingStats[_addressesToUpdate[i]].rewardGroup = _rewardGroup;
        }

        emit UserUpdateMultiple(_addressesToUpdate, _rewardGroup, competitionId);
    }

    /**
     * @notice It allows the owner to set the winning teamId (to collect NFT)
     * @dev Only callable by owner.
     * @param _winningTeamId: the winning teamId
     * @param _tokenURI: the tokenURI
     * @param _bunnyId: the bunnyId for winners (e.g. 15)
     */
    function updateWinningTeamAndTokenURIAndBunnyId(
        uint256 _winningTeamId,
        string calldata _tokenURI,
        uint8 _bunnyId
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        require((_winningTeamId > 0) && (_winningTeamId <= numberTeams), "NOT_VALID_TEAM_ID");
        require(_bunnyId > 14, "ID_TOO_LOW");
        winningTeamId = _winningTeamId;
        tokenURI = _tokenURI;
        bunnyId = _bunnyId;
        emit WinningTeam(_winningTeamId, competitionId);
    }

    /**
     * @notice It checks the claim information
     * @dev It does not check if user has a profile since registration required a profile.
     * @param _userAddress: the user address
     * @return hasRegistered: has the user registered
     * @return hasUserClaimed: whether user has claimed
     * @return userRewardGroup: the final reward group for each user (i.e. tier)
     * @return userCakeRewards: the CAKE to claim/claimed
     * @return userLazioRewards: the LAZIO to claim/claimed
     * @return userPortoRewards: the PORTO to claim/claimed
     * @return userSantosRewards: the Santos to claim/claimed
     * @return userPointReward: the number of points to claim/claimed
     * @return canClaimNFT: whether the user gets/got a NFT
     */
    function claimInformation(address _userAddress)
        external
        view
        returns (
            bool,
            bool,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        bool hasUserRegistered = userTradingStats[_userAddress].hasRegistered;
        if ((currentStatus != CompetitionStatus.Claiming) && (currentStatus != CompetitionStatus.Over)) {
            return (hasUserRegistered, false, 0, 0, 0, 0, 0, 0, false);
        } else if (!hasUserRegistered) {
            return (hasUserRegistered, false, 0, 0, 0, 0, 0, 0, false);
        } else {
            uint256 userRewardGroup = userTradingStats[_userAddress].rewardGroup;
            uint256 userTeamId = userTradingStats[_userAddress].teamId;

            bool hasUserClaimed = userTradingStats[_userAddress].hasClaimed;
            bool canClaimNFT;

            if ((userTeamId == winningTeamId) && (userRewardGroup > 0)) {
                canClaimNFT = true;
            }

            return (
                hasUserRegistered,
                hasUserClaimed,
                userRewardGroup,
                _rewardCompetitions[userTeamId].cakeRewards[userRewardGroup],
                _rewardCompetitions[userTeamId].lazioRewards[userRewardGroup],
                _rewardCompetitions[userTeamId].portoRewards[userRewardGroup],
                _rewardCompetitions[userTeamId].santosRewards[userRewardGroup],
                _rewardCompetitions[userTeamId].pointUsers[userRewardGroup],
                canClaimNFT
            );
        }
    }

    /**
     * @notice It checks the reward groups for each team
     */
    function viewRewardTeams() external view returns (CompetitionRewards[] memory) {
        CompetitionRewards[] memory listCompetitionRewards = new CompetitionRewards[](numberTeams);
        for (uint256 i = 0; i < numberTeams; i++) {
            listCompetitionRewards[i] = _rewardCompetitions[i + 1];
        }
        return listCompetitionRewards;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "./interfaces/IPancakeProfile.sol";
import "./BunnyMintingStation.sol";

/** @title TradingCompV1.
@notice It is a contract for users to collect points
based on off-chain events
*/
contract TradingCompV1 is Ownable {
    using SafeBEP20 for IBEP20;

    BunnyMintingStation public bunnyMintingStation;
    IBEP20 public cakeToken;
    IPancakeProfile public pancakeProfile;

    uint256 public constant numberTeams = 3;

    uint8 public bunnyId;
    uint256 public winningTeamId; // set to 0 as default
    string public tokenURI;

    enum CompetitionStatus {
        Registration,
        Open,
        Close,
        Claiming,
        Over
    }

    CompetitionStatus public currentStatus;

    mapping(address => UserStats) public userTradingStats;

    mapping(uint256 => CompetitionRewards) private _rewardCompetitions;

    struct CompetitionRewards {
        uint256[5] userCampaignId; // campaignId for user increase
        uint256[5] cakeRewards; // cake rewards per group
        uint256[5] pointUsers; // number of points per user
    }

    struct UserStats {
        uint256 rewardGroup; // 0 to 4 --> 4 top / 0: bottom
        uint256 teamId; // 1 - 3
        bool hasRegistered; // true or false
        bool hasClaimed; // true or false
    }

    event NewCompetitionStatus(CompetitionStatus status);
    event TeamRewardsUpdate(uint256 teamId);
    event UserRegister(address userAddress, uint256 teamId);
    event UserUpdateMultiple(address[] userAddresses, uint256 rewardGroup);
    event WinningTeam(uint256 teamId);

    /**
     * @notice It initializes the contract.
     * @param _pancakeProfileAddress: PancakeProfile address
     * @param _bunnyStationAddress: BunnyMintingStation address
     * @param _cakeTokenAddress: the address of the CAKE token
     */
    constructor(
        address _pancakeProfileAddress,
        address _bunnyStationAddress,
        address _cakeTokenAddress
    ) public {
        pancakeProfile = IPancakeProfile(_pancakeProfileAddress);
        bunnyMintingStation = BunnyMintingStation(_bunnyStationAddress);
        cakeToken = IBEP20(_cakeTokenAddress);
        currentStatus = CompetitionStatus.Registration;
    }

    /**
     * @notice It allows users to claim reward after the end of trading competition.
     * @dev It is only available during claiming phase
     */
    function claimReward() external {
        address senderAddress = _msgSender();

        require(userTradingStats[senderAddress].hasRegistered, "NOT_REGISTERED");
        require(!userTradingStats[senderAddress].hasClaimed, "HAS_CLAIMED");
        require(currentStatus == CompetitionStatus.Claiming, "NOT_IN_CLAIMING");

        userTradingStats[senderAddress].hasClaimed = true;

        uint256 userRewardGroup = userTradingStats[senderAddress].rewardGroup;
        uint256 userTeamId = userTradingStats[senderAddress].teamId;

        CompetitionRewards memory userRewards = _rewardCompetitions[userTeamId];

        if (userRewardGroup > 0) {
            cakeToken.safeTransfer(senderAddress, userRewards.cakeRewards[userRewardGroup]);

            if (userTeamId == winningTeamId) {
                bunnyMintingStation.mintCollectible(senderAddress, tokenURI, bunnyId);
            }
        }

        // User collects points
        pancakeProfile.increaseUserPoints(
            senderAddress,
            userRewards.pointUsers[userRewardGroup],
            userRewards.userCampaignId[userRewardGroup]
        );
    }

    /**
     * @notice It allows users to register for trading competition
     * @dev Only callable if the user has an active PancakeProfile.
     */
    function register() external {
        address senderAddress = _msgSender();

        // 1. Checks if user has registered
        require(!userTradingStats[senderAddress].hasRegistered, "HAS_REGISTERED");

        // 2. Check whether it is joinable
        require(currentStatus == CompetitionStatus.Registration, "NOT_IN_REGISTRATION");

        // 3. Check if active and records the teamId
        uint256 userTeamId;
        bool isUserActive;

        (, , userTeamId, , , isUserActive) = pancakeProfile.getUserProfile(senderAddress);

        require(isUserActive, "NOT_ACTIVE");

        // 4. Write in storage user stats for the registered user
        UserStats storage newUserStats = userTradingStats[senderAddress];
        newUserStats.teamId = userTeamId;
        newUserStats.hasRegistered = true;

        emit UserRegister(senderAddress, userTeamId);
    }

    /**
     * @notice It allows the owner to change the competition status
     * @dev Only callable by owner.
     * @param _status: CompetitionStatus (uint8)
     */
    function updateCompetitionStatus(CompetitionStatus _status) external onlyOwner {
        require(_status != CompetitionStatus.Registration, "IN_REGISTRATION");

        if (_status == CompetitionStatus.Open) {
            require(currentStatus == CompetitionStatus.Registration, "NOT_IN_REGISTRATION");
        } else if (_status == CompetitionStatus.Close) {
            require(currentStatus == CompetitionStatus.Open, "NOT_OPEN");
        } else if (_status == CompetitionStatus.Claiming) {
            require(winningTeamId > 0, "WINNING_TEAM_NOT_SET");
            require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        } else {
            require(currentStatus == CompetitionStatus.Claiming, "NOT_CLAIMING");
        }

        currentStatus = _status;

        emit NewCompetitionStatus(currentStatus);
    }

    /**
     * @notice It allows the owner to claim the CAKE remainder
     * @dev Only callable by owner.
     * @param _amount: amount of CAKE to withdraw (decimals = 18)
     */
    function claimRemainder(uint256 _amount) external onlyOwner {
        require(currentStatus == CompetitionStatus.Over, "NOT_OVER");
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @notice It allows the owner to update team rewards
     * @dev Only callable by owner.
     * @param _teamId: the teamId
     * @param _userCampaignIds: campaignIds for each user group for teamId
     * @param _cakeRewards: CAKE rewards for each user group for teamId
     * @param _pointRewards: point to collect for each user group for teamId
     */
    function updateTeamRewards(
        uint256 _teamId,
        uint256[5] calldata _userCampaignIds,
        uint256[5] calldata _cakeRewards,
        uint256[5] calldata _pointRewards
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        _rewardCompetitions[_teamId].userCampaignId = _userCampaignIds;
        _rewardCompetitions[_teamId].cakeRewards = _cakeRewards;
        _rewardCompetitions[_teamId].pointUsers = _pointRewards;

        emit TeamRewardsUpdate(_teamId);
    }

    /**
     * @notice It allows the owner to update user statuses
     * @dev Only callable by owner. Use with caution!
     * @param _addressesToUpdate: the array of addresses
     * @param _rewardGroup: the reward group
     */
    function updateUserStatusMultiple(address[] calldata _addressesToUpdate, uint256 _rewardGroup) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        require(_rewardGroup <= 4, "TOO_HIGH");
        for (uint256 i = 0; i < _addressesToUpdate.length; i++) {
            userTradingStats[_addressesToUpdate[i]].rewardGroup = _rewardGroup;
        }

        emit UserUpdateMultiple(_addressesToUpdate, _rewardGroup);
    }

    /**
     * @notice It allows the owner to set the winning teamId (to collect NFT)
     * @dev Only callable by owner.
     * @param _winningTeamId: the winning teamId
     * @param _tokenURI: the tokenURI
     * @param _bunnyId: the bunnyId for winners (e.g. 15)
     */
    function updateWinningTeamAndTokenURIAndBunnyId(
        uint256 _winningTeamId,
        string calldata _tokenURI,
        uint8 _bunnyId
    ) external onlyOwner {
        require(currentStatus == CompetitionStatus.Close, "NOT_CLOSED");
        require((_winningTeamId > 0) && (_winningTeamId <= numberTeams), "NOT_VALID_TEAM_ID");
        require(_bunnyId > 14, "ID_TOO_LOW");
        winningTeamId = _winningTeamId;
        tokenURI = _tokenURI;
        bunnyId = _bunnyId;
        emit WinningTeam(_winningTeamId);
    }

    /**
     * @notice It checks the claim information
     * @dev It does not check if user has a profile since registration required a profile.
     * @param _userAddress: the user address
     * @return hasRegistered: has the user registered
     * @return hasUserClaimed: whether user has claimed
     * @return userRewardGroup: the final reward group for each user (i.e. tier)
     * @return userCakeRewards: the CAKE to claim/claimed
     * @return userPointReward: the number of points to claim/claimed
     * @return canClaimNFT: whether the user gets/got a NFT
     */
    function claimInformation(address _userAddress)
        external
        view
        returns (
            bool,
            bool,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        bool hasUserRegistered = userTradingStats[_userAddress].hasRegistered;
        if ((currentStatus != CompetitionStatus.Claiming) && (currentStatus != CompetitionStatus.Over)) {
            return (hasUserRegistered, false, 0, 0, 0, false);
        } else if (!hasUserRegistered) {
            return (hasUserRegistered, false, 0, 0, 0, false);
        } else {
            uint256 userRewardGroup = userTradingStats[_userAddress].rewardGroup;
            uint256 userTeamId = userTradingStats[_userAddress].teamId;

            uint256 userCakeRewards = _rewardCompetitions[userTeamId].cakeRewards[userRewardGroup];
            uint256 userPointRewards = _rewardCompetitions[userTeamId].pointUsers[userRewardGroup];

            bool hasUserClaimed = userTradingStats[_userAddress].hasClaimed;
            bool canClaimNFT;

            if ((userTeamId == winningTeamId) && (userRewardGroup > 0)) {
                canClaimNFT = true;
            }

            return (hasUserRegistered, hasUserClaimed, userRewardGroup, userCakeRewards, userPointRewards, canClaimNFT);
        }
    }

    /**
     * @notice It checks the reward groups for each team
     */
    function viewRewardTeams() external view returns (CompetitionRewards[] memory) {
        CompetitionRewards[] memory listCompetitionRewards = new CompetitionRewards[](numberTeams);
        for (uint256 i = 0; i < numberTeams; i++) {
            listCompetitionRewards[i] = _rewardCompetitions[i + 1];
        }
        return listCompetitionRewards;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

contract IFO is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        bool claimed; // default false
    }

    // admin address
    address public adminAddress;
    // The raising token
    IBEP20 public lpToken;
    // The offering token
    IBEP20 public offeringToken;
    // The block number when IFO starts
    uint256 public startBlock;
    // The block number when IFO ends
    uint256 public endBlock;
    // total amount of raising tokens need to be raised
    uint256 public raisingAmount;
    // total amount of offeringToken that will offer
    uint256 public offeringAmount;
    // total amount of raising tokens that have already raised
    uint256 public totalAmount;
    // address => amount
    mapping(address => UserInfo) public userInfo;
    // participators
    address[] public addressList;

    event Deposit(address indexed user, uint256 amount);

    event Harvest(address indexed user, uint256 offeringAmount, uint256 excessAmount);

    constructor(
        IBEP20 _lpToken,
        IBEP20 _offeringToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _offeringAmount,
        uint256 _raisingAmount,
        address _adminAddress
    ) public {
        lpToken = _lpToken;
        offeringToken = _offeringToken;
        startBlock = _startBlock;
        endBlock = _endBlock;
        offeringAmount = _offeringAmount;
        raisingAmount = _raisingAmount;
        totalAmount = 0;
        adminAddress = _adminAddress;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    function setOfferingAmount(uint256 _offerAmount) public onlyAdmin {
        require(block.number < startBlock, "no");
        offeringAmount = _offerAmount;
    }

    function setRaisingAmount(uint256 _raisingAmount) public onlyAdmin {
        require(block.number < startBlock, "no");
        raisingAmount = _raisingAmount;
    }

    function deposit(uint256 _amount) public {
        require(block.number > startBlock && block.number < endBlock, "not ifo time");
        require(_amount > 0, "need _amount > 0");
        lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        if (userInfo[msg.sender].amount == 0) {
            addressList.push(address(msg.sender));
        }
        userInfo[msg.sender].amount = userInfo[msg.sender].amount.add(_amount);
        totalAmount = totalAmount.add(_amount);
        emit Deposit(msg.sender, _amount);
    }

    function harvest() public nonReentrant {
        require(block.number > endBlock, "not harvest time");
        require(userInfo[msg.sender].amount > 0, "have you participated?");
        require(!userInfo[msg.sender].claimed, "nothing to harvest");
        uint256 offeringTokenAmount = getOfferingAmount(msg.sender);
        uint256 refundingTokenAmount = getRefundingAmount(msg.sender);
        offeringToken.safeTransfer(address(msg.sender), offeringTokenAmount);
        if (refundingTokenAmount > 0) {
            lpToken.safeTransfer(address(msg.sender), refundingTokenAmount);
        }
        userInfo[msg.sender].claimed = true;
        emit Harvest(msg.sender, offeringTokenAmount, refundingTokenAmount);
    }

    function hasHarvest(address _user) external view returns (bool) {
        return userInfo[_user].claimed;
    }

    // allocation 100000 means 0.1(10%), 1 meanss 0.000001(0.0001%), 1000000 means 1(100%)
    function getUserAllocation(address _user) public view returns (uint256) {
        return userInfo[_user].amount.mul(1e12).div(totalAmount).div(1e6);
    }

    // get the amount of IFO token you will get
    function getOfferingAmount(address _user) public view returns (uint256) {
        if (totalAmount > raisingAmount) {
            uint256 allocation = getUserAllocation(_user);
            return offeringAmount.mul(allocation).div(1e6);
        } else {
            // userInfo[_user] / (raisingAmount / offeringAmount)
            return userInfo[_user].amount.mul(offeringAmount).div(raisingAmount);
        }
    }

    // get the amount of lp token you will be refunded
    function getRefundingAmount(address _user) public view returns (uint256) {
        if (totalAmount <= raisingAmount) {
            return 0;
        }
        uint256 allocation = getUserAllocation(_user);
        uint256 payAmount = raisingAmount.mul(allocation).div(1e6);
        return userInfo[_user].amount.sub(payAmount);
    }

    function getAddressListLength() external view returns (uint256) {
        return addressList.length;
    }

    function finalWithdraw(uint256 _lpAmount, uint256 _offerAmount) public onlyAdmin {
        require(_lpAmount < lpToken.balanceOf(address(this)), "not enough token 0");
        require(_offerAmount < offeringToken.balanceOf(address(this)), "not enough token 1");
        lpToken.safeTransfer(address(msg.sender), _lpAmount);
        offeringToken.safeTransfer(address(msg.sender), _offerAmount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "lottery/contracts/interfaces/IPancakeSwapLottery.sol";

/** @title PancakeSwap Lottery.
 * @notice It is a contract for a lottery system using
 * randomness provided externally.
 */
contract MockPancakeSwapLottery is ReentrancyGuard, IPancakeSwapLottery, Ownable {
    using SafeERC20 for IERC20;

    address public injectorAddress;
    address public operatorAddress;
    address public treasuryAddress;

    uint256 public currentLotteryId;
    uint256 public currentTicketId;

    uint256 public maxNumberTicketsPerBuyOrClaim = 100;

    uint256 public maxPriceTicketInCake = 50 ether;
    uint256 public minPriceTicketInCake = 0.005 ether;

    uint256 public pendingInjectionNextLottery;

    uint256 public constant MIN_DISCOUNT_DIVISOR = 300;
    uint256 public constant MIN_LENGTH_LOTTERY = 4 hours - 5 minutes; // 4 hours
    uint256 public constant MAX_LENGTH_LOTTERY = 4 days + 5 minutes; // 4 days
    uint256 public constant MAX_TREASURY_FEE = 3000; // 30%

    IERC20 public cakeToken;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 priceTicketInCake;
        uint256 discountDivisor;
        uint256[6] rewardsBreakdown; // 0: 1 matching number // 5: 6 matching numbers
        uint256 treasuryFee; // 500: 5% // 200: 2% // 50: 0.5%
        uint256[6] cakePerBracket;
        uint256[6] countWinnersPerBracket;
        uint256 firstTicketId;
        uint256 firstTicketIdNextLottery;
        uint256 amountCollectedInCake;
        uint32 finalNumber;
    }

    struct Ticket {
        uint32 number;
        address owner;
    }

    // Mapping are cheaper than arrays
    mapping(uint256 => Lottery) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;

    // Bracket calculator is used for verifying claims for ticket prizes
    mapping(uint32 => uint32) private _bracketCalculator;

    // Keeps track of number of ticket per unique combination for each lotteryId
    mapping(uint256 => mapping(uint32 => uint256)) private _numberTicketsPerLotteryId;

    // Keep track of user ticket ids for a given lotteryId
    mapping(address => mapping(uint256 => uint256[])) private _userTicketIdsPerLotteryId;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    modifier onlyOwnerOrInjector() {
        require((msg.sender == owner()) || (msg.sender == injectorAddress), "Not owner or injector");
        _;
    }

    event AdminTokenRecovery(address token, uint256 amount);
    event LotteryClose(uint256 indexed lotteryId, uint256 firstTicketIdNextLottery);
    event LotteryInjection(uint256 indexed lotteryId, uint256 injectedAmount);
    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 endTime,
        uint256 priceTicketInCake,
        uint256 firstTicketId,
        uint256 injectedAmount
    );
    event LotteryNumberDrawn(uint256 indexed lotteryId, uint256 finalNumber, uint256 countWinningTickets);
    event NewOperatorAndTreasuryAndInjectorAddresses(address operator, address treasury, address injector);
    event TicketsPurchase(address indexed buyer, uint256 indexed lotteryId, uint256 numberTickets);
    event TicketsClaim(address indexed claimer, uint256 amount, uint256 indexed lotteryId, uint256 numberTickets);

    /**
     * @notice Constructor
     * @dev RandomNumberGenerator must be deployed prior to this contract
     * @param _cakeTokenAddress: address of the CAKE token
     */
    constructor(address _cakeTokenAddress) public {
        cakeToken = IERC20(_cakeTokenAddress);

        // Initializes a mapping
        _bracketCalculator[0] = 1;
        _bracketCalculator[1] = 11;
        _bracketCalculator[2] = 111;
        _bracketCalculator[3] = 1111;
        _bracketCalculator[4] = 11111;
        _bracketCalculator[5] = 111111;
    }

    /**
     * @notice Buy tickets for the current lottery
     * @param _lotteryId: lotteryId
     * @param _ticketNumbers: array of ticket numbers between 1,000,000 and 1,999,999
     * @dev Callable by users
     */
    function buyTickets(uint256 _lotteryId, uint32[] calldata _ticketNumbers)
        external
        override
        notContract
        nonReentrant
    {
        require(_ticketNumbers.length != 0, "No ticket specified");
        require(_ticketNumbers.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");

        require(_lotteries[_lotteryId].status == Status.Open, "Lottery is not open");
        require(block.timestamp < _lotteries[_lotteryId].endTime, "Lottery is over");

        // Calculate number of CAKE to this contract
        uint256 amountCakeToTransfer = _calculateTotalPriceForBulkTickets(
            _lotteries[_lotteryId].discountDivisor,
            _lotteries[_lotteryId].priceTicketInCake,
            _ticketNumbers.length
        );

        // Increment the total amount collected for the lottery round
        _lotteries[_lotteryId].amountCollectedInCake += amountCakeToTransfer;

        for (uint256 i = 0; i < _ticketNumbers.length; i++) {
            uint32 thisTicketNumber = _ticketNumbers[i];

            require((thisTicketNumber >= 1000000) && (thisTicketNumber <= 1999999), "Outside range");

            _numberTicketsPerLotteryId[_lotteryId][1 + (thisTicketNumber % 10)]++;
            _numberTicketsPerLotteryId[_lotteryId][11 + (thisTicketNumber % 100)]++;
            _numberTicketsPerLotteryId[_lotteryId][111 + (thisTicketNumber % 1000)]++;
            _numberTicketsPerLotteryId[_lotteryId][1111 + (thisTicketNumber % 10000)]++;
            _numberTicketsPerLotteryId[_lotteryId][11111 + (thisTicketNumber % 100000)]++;
            _numberTicketsPerLotteryId[_lotteryId][111111 + (thisTicketNumber % 1000000)]++;

            _userTicketIdsPerLotteryId[msg.sender][_lotteryId].push(currentTicketId);

            _tickets[currentTicketId] = Ticket({number: thisTicketNumber, owner: msg.sender});

            // Increase lottery ticket number
            currentTicketId++;
        }

        emit TicketsPurchase(msg.sender, _lotteryId, _ticketNumbers.length);
    }

    /**
     * @notice Claim a set of winning tickets for a lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @param _brackets: array of brackets for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external override notContract nonReentrant {
        require(_ticketIds.length == _brackets.length, "Not same length");
        require(_ticketIds.length != 0, "Length must be >0");
        require(_ticketIds.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");
        require(_lotteries[_lotteryId].status == Status.Claimable, "Lottery not claimable");

        // Initializes the rewardInCakeToTransfer
        uint256 rewardInCakeToTransfer;

        for (uint256 i = 0; i < _ticketIds.length; i++) {
            require(_brackets[i] < 6, "Bracket out of range"); // Must be between 0 and 5

            uint256 thisTicketId = _ticketIds[i];

            require(_lotteries[_lotteryId].firstTicketIdNextLottery > thisTicketId, "TicketId too high");
            require(_lotteries[_lotteryId].firstTicketId <= thisTicketId, "TicketId too low");
            require(msg.sender == _tickets[thisTicketId].owner, "Not the owner");

            // Update the lottery ticket owner to 0x address
            _tickets[thisTicketId].owner = address(0);

            uint256 rewardForTicketId = _calculateRewardsForTicketId(_lotteryId, thisTicketId, _brackets[i]);

            // Check user is claiming the correct bracket
            require(rewardForTicketId != 0, "No prize for this bracket");

            if (_brackets[i] != 5) {
                require(
                    _calculateRewardsForTicketId(_lotteryId, thisTicketId, _brackets[i] + 1) == 0,
                    "Bracket must be higher"
                );
            }

            // Increment the reward to transfer
            rewardInCakeToTransfer += rewardForTicketId;
        }

        // Transfer money to msg.sender
        // cakeToken.safeTransfer(msg.sender, rewardInCakeToTransfer);

        emit TicketsClaim(msg.sender, rewardInCakeToTransfer, _lotteryId, _ticketIds.length);
    }

    /**
     * @notice Close lottery
     * @param _lotteryId: lottery id
     * @dev Callable by operator
     */
    function closeLottery(uint256 _lotteryId) external override onlyOperator nonReentrant {
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");
        _lotteries[_lotteryId].firstTicketIdNextLottery = currentTicketId;

        _lotteries[_lotteryId].status = Status.Close;

        emit LotteryClose(_lotteryId, currentTicketId);
    }

    /**
     * @notice Draw the final number, calculate reward in CAKE per group, and make lottery claimable
     * @param _lotteryId: lottery id
     * @param _autoInjection: reinjects funds into next lottery (vs. withdrawing all)
     * @dev Callable by operator
     */
    function drawFinalNumberAndMakeLotteryClaimable(uint256 _lotteryId, bool _autoInjection)
        external
        override
        onlyOperator
        nonReentrant
    {
        require(_lotteries[_lotteryId].status == Status.Close, "Lottery not close");

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        uint32 finalNumber = 1999999;

        // Initialize a number to count addresses in the previous bracket
        uint256 numberAddressesInPreviousBracket;

        // Calculate the amount to share post-treasury fee
        uint256 amountToShareToWinners = (
            ((_lotteries[_lotteryId].amountCollectedInCake) * (10000 - _lotteries[_lotteryId].treasuryFee))
        ) / 10000;

        // Initializes the amount to withdraw to treasury
        uint256 amountToWithdrawToTreasury;

        // Calculate prizes in CAKE for each bracket by starting from the highest one
        for (uint32 i = 0; i < 6; i++) {
            uint32 j = 5 - i;
            uint32 transformedWinningNumber = _bracketCalculator[j] + (finalNumber % (uint32(10)**(j + 1)));

            _lotteries[_lotteryId].countWinnersPerBracket[j] =
                _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] -
                numberAddressesInPreviousBracket;

            // A. If number of users for this _bracket number is superior to 0
            if (
                (_numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] - numberAddressesInPreviousBracket) !=
                0
            ) {
                // B. If rewards at this bracket are > 0, calculate, else, report the numberAddresses from previous bracket
                if (_lotteries[_lotteryId].rewardsBreakdown[j] != 0) {
                    _lotteries[_lotteryId].cakePerBracket[j] =
                        ((_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners) /
                            (_numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] -
                                numberAddressesInPreviousBracket)) /
                        10000;

                    // Update numberAddressesInPreviousBracket
                    numberAddressesInPreviousBracket = _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber];
                }
                // A. No CAKE to distribute, they are added to the amount to withdraw to treasury address
            } else {
                _lotteries[_lotteryId].cakePerBracket[j] = 0;

                amountToWithdrawToTreasury +=
                    (_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners) /
                    10000;
            }
        }

        // Update internal statuses for lottery
        _lotteries[_lotteryId].finalNumber = finalNumber;
        _lotteries[_lotteryId].status = Status.Claimable;

        if (_autoInjection) {
            pendingInjectionNextLottery = amountToWithdrawToTreasury;
            amountToWithdrawToTreasury = 0;
        }

        amountToWithdrawToTreasury += (_lotteries[_lotteryId].amountCollectedInCake - amountToShareToWinners);

        emit LotteryNumberDrawn(currentLotteryId, finalNumber, numberAddressesInPreviousBracket);
    }

    /**
     * @notice Inject funds
     * @param _lotteryId: lottery id
     * @param _amount: amount to inject in CAKE token
     * @dev Callable by owner or injector address
     */
    function injectFunds(uint256 _lotteryId, uint256 _amount) external override onlyOwnerOrInjector {
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");

        cakeToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        _lotteries[_lotteryId].amountCollectedInCake += _amount;

        emit LotteryInjection(_lotteryId, _amount);
    }

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     * @param _endTime: endTime of the lottery
     * @param _priceTicketInCake: price of a ticket in CAKE
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _rewardsBreakdown: breakdown of rewards per bracket (must sum to 10,000)
     * @param _treasuryFee: treasury fee (10,000 = 100%, 100 = 1%)
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicketInCake,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown,
        uint256 _treasuryFee
    ) external override onlyOperator {
        require(
            (currentLotteryId == 0) || (_lotteries[currentLotteryId].status == Status.Claimable),
            "Not time to start lottery"
        );

        require(
            (_priceTicketInCake >= minPriceTicketInCake) && (_priceTicketInCake <= maxPriceTicketInCake),
            "Outside of limits"
        );

        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Discount divisor too low");
        require(_treasuryFee <= MAX_TREASURY_FEE, "Treasury fee too high");

        require(
            (_rewardsBreakdown[0] +
                _rewardsBreakdown[1] +
                _rewardsBreakdown[2] +
                _rewardsBreakdown[3] +
                _rewardsBreakdown[4] +
                _rewardsBreakdown[5]) == 10000,
            "Rewards must equal 10000"
        );

        currentLotteryId++;

        _lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: _endTime,
            priceTicketInCake: _priceTicketInCake,
            discountDivisor: _discountDivisor,
            rewardsBreakdown: _rewardsBreakdown,
            treasuryFee: _treasuryFee,
            cakePerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            countWinnersPerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            firstTicketId: currentTicketId,
            firstTicketIdNextLottery: currentTicketId,
            amountCollectedInCake: pendingInjectionNextLottery,
            finalNumber: 0
        });

        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            _endTime,
            _priceTicketInCake,
            currentTicketId,
            pendingInjectionNextLottery
        );

        pendingInjectionNextLottery = 0;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(cakeToken), "Cannot be CAKE token");

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Set CAKE price ticket upper/lower limit
     * @dev Only callable by owner
     * @param _minPriceTicketInCake: minimum price of a ticket in CAKE
     * @param _maxPriceTicketInCake: maximum price of a ticket in CAKE
     */
    function setMinAndMaxTicketPriceInCake(uint256 _minPriceTicketInCake, uint256 _maxPriceTicketInCake)
        external
        onlyOwner
    {
        require(_minPriceTicketInCake <= _maxPriceTicketInCake, "minPrice must be < maxPrice");

        minPriceTicketInCake = _minPriceTicketInCake;
        maxPriceTicketInCake = _maxPriceTicketInCake;
    }

    /**
     * @notice Set max number of tickets
     * @dev Only callable by owner
     */
    function setMaxNumberTicketsPerBuy(uint256 _maxNumberTicketsPerBuy) external onlyOwner {
        require(_maxNumberTicketsPerBuy != 0, "Must be > 0");
        maxNumberTicketsPerBuyOrClaim = _maxNumberTicketsPerBuy;
    }

    /**
     * @notice Set operator, treasury, and injector addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     * @param _treasuryAddress: address of the treasury
     * @param _injectorAddress: address of the injector
     */
    function setOperatorAndTreasuryAndInjectorAddresses(
        address _operatorAddress,
        address _treasuryAddress,
        address _injectorAddress
    ) external onlyOwner {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(_treasuryAddress != address(0), "Cannot be zero address");
        require(_injectorAddress != address(0), "Cannot be zero address");

        operatorAddress = _operatorAddress;
        treasuryAddress = _treasuryAddress;
        injectorAddress = _injectorAddress;

        emit NewOperatorAndTreasuryAndInjectorAddresses(_operatorAddress, _treasuryAddress, _injectorAddress);
    }

    /**
     * @notice Calculate price of a set of tickets
     * @param _discountDivisor: divisor for the discount
     * @param _priceTicket price of a ticket (in CAKE)
     * @param _numberTickets number of tickets to buy
     */
    function calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) external pure returns (uint256) {
        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Must be >= MIN_DISCOUNT_DIVISOR");
        require(_numberTickets != 0, "Number of tickets must be > 0");

        return _calculateTotalPriceForBulkTickets(_discountDivisor, _priceTicket, _numberTickets);
    }

    /**
     * @notice View current lottery id
     */
    function viewCurrentLotteryId() external override returns (uint256) {
        return currentLotteryId;
    }

    /**
     * @notice View ticker statuses and numbers for an array of ticket ids
     * @param _ticketIds: array of _ticketId
     */
    function viewNumbersAndStatusesForTicketIds(uint256[] calldata _ticketIds)
        external
        view
        returns (uint32[] memory, bool[] memory)
    {
        uint256 length = _ticketIds.length;
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            ticketNumbers[i] = _tickets[_ticketIds[i]].number;
            if (_tickets[_ticketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                ticketStatuses[i] = false;
            }
        }

        return (ticketNumbers, ticketStatuses);
    }

    /**
     * @notice View rewards for a given ticket, providing a bracket, and lottery id
     * @dev Computations are mostly offchain. This is used to verify a ticket!
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function viewRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) external view returns (uint256) {
        // Check lottery is in claimable status
        if (_lotteries[_lotteryId].status != Status.Claimable) {
            return 0;
        }

        // Check ticketId is within range
        if (
            (_lotteries[_lotteryId].firstTicketIdNextLottery < _ticketId) &&
            (_lotteries[_lotteryId].firstTicketId >= _ticketId)
        ) {
            return 0;
        }

        return _calculateRewardsForTicketId(_lotteryId, _ticketId, _bracket);
    }

    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given lottery
     * @param _user: user address
     * @param _lotteryId: lottery id
     * @param _cursor: cursor to start where to retrieve the tickets
     * @param _size: the number of tickets to retrieve
     */
    function viewUserInfoForLotteryId(
        address _user,
        uint256 _lotteryId,
        uint256 _cursor,
        uint256 _size
    )
        external
        view
        override
        returns (
            uint256[] memory,
            uint32[] memory,
            bool[] memory,
            uint256
        )
    {
        uint256 length = _size;
        uint256 numberTicketsBoughtAtLotteryId = _userTicketIdsPerLotteryId[_user][_lotteryId].length;

        if (length > (numberTicketsBoughtAtLotteryId - _cursor)) {
            length = numberTicketsBoughtAtLotteryId - _cursor;
        }
        uint256[] memory lotteryTicketIds = new uint256[](length);
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            lotteryTicketIds[i] = _userTicketIdsPerLotteryId[_user][_lotteryId][i + _cursor];
            ticketNumbers[i] = _tickets[lotteryTicketIds[i]].number;

            // True = ticket claimed
            if (_tickets[lotteryTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                // ticket not claimed (includes the ones that cannot be claimed)
                ticketStatuses[i] = false;
            }
        }

        return (lotteryTicketIds, ticketNumbers, ticketStatuses, _cursor + length);
    }

    /**
     * @notice Calculate rewards for a given ticket
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function _calculateRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) internal view returns (uint256) {
        // Retrieve the winning number combination
        uint32 winningTicketNumber = _lotteries[_lotteryId].finalNumber;

        // Retrieve the user number combination from the ticketId
        uint32 userNumber = _tickets[_ticketId].number;

        // Apply transformation to verify the claim provided by the user is true
        uint32 transformedWinningNumber = _bracketCalculator[_bracket] +
            (winningTicketNumber % (uint32(10)**(_bracket + 1)));

        uint32 transformedUserNumber = _bracketCalculator[_bracket] + (userNumber % (uint32(10)**(_bracket + 1)));

        // Confirm that the two transformed numbers are the same, if not throw
        if (transformedWinningNumber == transformedUserNumber) {
            return _lotteries[_lotteryId].cakePerBracket[_bracket];
        } else {
            return 0;
        }
    }

    /**
     * @notice Calculate final price for bulk of tickets
     * @param _discountDivisor: divisor for the discount (the smaller it is, the greater the discount is)
     * @param _priceTicket: price of a ticket
     * @param _numberTickets: number of tickets purchased
     */
    function _calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) internal pure returns (uint256) {
        return (_priceTicket * _numberTickets * (_discountDivisor + 1 - _numberTickets)) / _discountDivisor;
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface IPancakeSwapLottery {
    /**
     * @notice Buy tickets for the current lottery
     * @param _lotteryId: lotteryId
     * @param _ticketNumbers: array of ticket numbers between 1,000,000 and 1,999,999
     * @dev Callable by users
     */
    function buyTickets(uint256 _lotteryId, uint32[] calldata _ticketNumbers) external;

    /**
     * @notice Claim a set of winning tickets for a lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @param _brackets: array of brackets for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external;

    /**
     * @notice Close lottery
     * @param _lotteryId: lottery id
     * @dev Callable by operator
     */
    function closeLottery(uint256 _lotteryId) external;

    /**
     * @notice Draw the final number, calculate reward in CAKE per group, and make lottery claimable
     * @param _lotteryId: lottery id
     * @param _autoInjection: reinjects funds into next lottery (vs. withdrawing all)
     * @dev Callable by operator
     */
    function drawFinalNumberAndMakeLotteryClaimable(uint256 _lotteryId, bool _autoInjection) external;

    /**
     * @notice Inject funds
     * @param _lotteryId: lottery id
     * @param _amount: amount to inject in CAKE token
     * @dev Callable by operator
     */
    function injectFunds(uint256 _lotteryId, uint256 _amount) external;

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     * @param _endTime: endTime of the lottery
     * @param _priceTicketInCake: price of a ticket in CAKE
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _rewardsBreakdown: breakdown of rewards per bracket (must sum to 10,000)
     * @param _treasuryFee: treasury fee (10,000 = 100%, 100 = 1%)
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicketInCake,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown,
        uint256 _treasuryFee
    ) external;

    /**
     * @notice View current lottery id
     */
    function viewCurrentLotteryId() external returns (uint256);

    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given lottery
     * @param _user: user address
     * @param _lotteryId: lottery id
     * @param _cursor: cursor to start where to retrieve the tickets
     * @param _size: the number of tickets to retrieve
     */
    function viewUserInfoForLotteryId(
        address _user,
        uint256 _lotteryId,
        uint256 _cursor,
        uint256 _size
    )
        external
        view
        returns (
            uint256[] memory,
            uint32[] memory,
            bool[] memory,
            uint256
        );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IPancakeSwapLottery} from "lottery/contracts/interfaces/IPancakeSwapLottery.sol";
import {BunnyMintingStation} from "./BunnyMintingStation.sol";
import {PancakeProfile} from "./PancakeProfile.sol";

contract BunnySpecialLottery is Ownable {
    /*** Contracts ***/

    IPancakeSwapLottery public pancakeSwapLottery;
    BunnyMintingStation public bunnyMintingStation;
    PancakeProfile public pancakeProfile;

    /*** Storage ***/

    uint8 constant nftId1 = 18;
    uint8 constant nftId2 = 19;
    uint8 constant nftId3 = 20;

    uint256 public endBlock; // End of the distribution
    uint256 public startLotteryRound;
    uint256 public finalLotteryRound;

    mapping(uint8 => uint256) public campaignIds;
    mapping(uint8 => uint256) public numberPoints;
    mapping(uint8 => string) public tokenURIs;
    mapping(address => bool) public userWhitelistForNft3;
    mapping(address => mapping(uint8 => bool)) public hasClaimed;

    /*** Events ***/

    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);
    event NewAddressWhitelisted(address[] users);
    event NewCampaignId(uint8 bunnyId, uint256 campaignId);
    event NewEndBlock(uint256 endBlock);
    event NewLotteryRounds(uint256 startLotteryRound, uint256 finalLotteryRound);
    event NewNumberPoints(uint8 bunnyId, uint256 numberPoints);
    event NewTokenURI(uint8 bunnyId, string tokenURI);

    /*** Constructor ***/

    constructor(
        address _pancakeSwapLotteryAddress,
        address _bunnyMintingStationAddress,
        address _pancakeProfileAddress,
        uint256 _endBlock,
        string memory _tokenURI1,
        string memory _tokenURI2,
        string memory _tokenURI3,
        uint256 _numberPoints1,
        uint256 _numberPoints2,
        uint256 _numberPoints3,
        uint256 _campaignId1,
        uint256 _campaignId2,
        uint256 _campaignId3,
        uint256 _startLotteryRound,
        uint256 _finalLotteryRound
    ) public {
        pancakeSwapLottery = IPancakeSwapLottery(_pancakeSwapLotteryAddress);
        bunnyMintingStation = BunnyMintingStation(_bunnyMintingStationAddress);
        pancakeProfile = PancakeProfile(_pancakeProfileAddress);

        endBlock = _endBlock;

        tokenURIs[nftId1] = _tokenURI1;
        tokenURIs[nftId2] = _tokenURI2;
        tokenURIs[nftId3] = _tokenURI3;

        numberPoints[nftId1] = _numberPoints1;
        numberPoints[nftId2] = _numberPoints2;
        numberPoints[nftId3] = _numberPoints3;

        campaignIds[nftId1] = _campaignId1;
        campaignIds[nftId2] = _campaignId2;
        campaignIds[nftId3] = _campaignId3;

        startLotteryRound = _startLotteryRound;
        finalLotteryRound = _finalLotteryRound;
    }

    modifier validNftId(uint8 _bunnyId) {
        require(_bunnyId >= nftId1 && _bunnyId <= nftId3, "NFT: Id out of range");
        _;
    }

    /*** External ***/

    /**
     * @notice Mint a NFT from the BunnyMintingStation contract.
     * @dev Users can claim once. It maps to the teamId.
     * @param _lotteryId See _canClaim documentation
     * @param _cursor See _canClaim documentation
     */
    function mintNFT(
        uint8 _bunnyId,
        uint256 _lotteryId,
        uint256 _cursor
    ) external validNftId(_bunnyId) {
        require(_canClaim(msg.sender, _bunnyId, _lotteryId, _cursor), "User: Not eligible");

        hasClaimed[msg.sender][_bunnyId] = true;

        // Mint collectible and send it to the user.
        uint256 tokenId = bunnyMintingStation.mintCollectible(msg.sender, tokenURIs[_bunnyId], _bunnyId);

        // Increase point on PancakeSwap profile, for a given campaignId.
        pancakeProfile.increaseUserPoints(msg.sender, numberPoints[_bunnyId], campaignIds[_bunnyId]);

        emit BunnyMint(msg.sender, tokenId, _bunnyId);
    }

    /**
     * @notice Check if a user can claim NFT1
     * @dev External function are cheaper than public. Helpers for external calls only.
     * @param _lotteryId See _canClaim documentation
     */
    function canClaimNft1(address _userAddress, uint256 _lotteryId) external view returns (bool) {
        return _canClaim(_userAddress, nftId1, _lotteryId, 0);
    }

    /**
     * @notice Check if a user can claim NFT2
     * @dev External function are cheaper than public. Helpers for external calls only.
     * @param _lotteryId See _canClaim documentation
     * @param _cursor See _canClaim documentation
     */
    function canClaimNft2(
        address _userAddress,
        uint256 _lotteryId,
        uint256 _cursor
    ) external view returns (bool) {
        return _canClaim(_userAddress, nftId2, _lotteryId, _cursor);
    }

    /**
     * @notice Check if a user can claim NFT3
     * @dev External function are cheaper than public. Helpers for external calls only.
     */
    function canClaimNft3(address _userAddress) external view returns (bool) {
        return _canClaim(_userAddress, nftId3, startLotteryRound, 0);
    }

    /*** External - Owner ***/

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     */
    function changeEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;
        emit NewEndBlock(_endBlock);
    }

    /**
     * @notice Change the campaignId for PancakeSwap Profile.
     * @dev Only callable by owner.
     */
    function changeCampaignId(uint8 _bunnyId, uint256 _campaignId) external onlyOwner validNftId(_bunnyId) {
        campaignIds[_bunnyId] = _campaignId;
        emit NewCampaignId(_bunnyId, _campaignId);
    }

    /**
     * @notice Change the number of points for PancakeSwap Profile.
     * @dev Only callable by owner.
     */
    function changeNumberPoints(uint8 _bunnyId, uint256 _numberPoints) external onlyOwner validNftId(_bunnyId) {
        numberPoints[_bunnyId] = _numberPoints;
        emit NewNumberPoints(_bunnyId, _numberPoints);
    }

    /**
     * @notice Change the start and final round of the lottery.
     * @dev Only callable by owner.
     */
    function changeLotteryRounds(uint256 _startLotteryRound, uint256 _finalLotteryRound) external onlyOwner {
        require(_startLotteryRound < _finalLotteryRound, "Round: startLotteryRound > finalLotteryRound");
        startLotteryRound = _startLotteryRound;
        finalLotteryRound = _finalLotteryRound;
        emit NewLotteryRounds(_startLotteryRound, _finalLotteryRound);
    }

    /**
     * @notice Change the token uri of a nft
     * @dev Only callable by owner.
     */
    function changeTokenURI(uint8 _bunnyId, string calldata _tokenURI) external onlyOwner validNftId(_bunnyId) {
        tokenURIs[_bunnyId] = _tokenURI;
        emit NewTokenURI(_bunnyId, _tokenURI);
    }

    /**
     * @notice Whitelist a user address. Whitelisted address can claim the NFT 3.
     * @dev Only callable by owner.
     */
    function whitelistAddresses(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            userWhitelistForNft3[_users[i]] = true;
        }
        emit NewAddressWhitelisted(_users);
    }

    /*** Internal ***/

    /**
     * @notice Check if a user can claim.
     * @dev In order to reduce the gas spent during the minting, this function takes a lotteryId (avoid looping on all the lotteries),
            and a cursor (avoid looping on all the user tickets for a specific lottery). Theses info are easily 
            accessible by the FE.
     * @param _lotteryId Id of the lottery to check against
     * @param _cursor Cursor position of ticket to check against
     */
    function _canClaim(
        address _userAddress,
        uint8 _bunnyId,
        uint256 _lotteryId,
        uint256 _cursor
    ) internal view returns (bool) {
        // Common requirements for being able to claim any NFT
        if (
            hasClaimed[_userAddress][_bunnyId] ||
            !pancakeProfile.getUserStatus(_userAddress) ||
            block.number >= endBlock ||
            _lotteryId < startLotteryRound ||
            _lotteryId > finalLotteryRound
        ) {
            return false;
        }

        if (_bunnyId == nftId1) {
            uint256 size;
            (, , , size) = pancakeSwapLottery.viewUserInfoForLotteryId(_userAddress, _lotteryId, 0, 1);
            return size > 0;
        }
        if (_bunnyId == nftId2) {
            bool[] memory ticketStatuses;
            uint256 size;

            (, , ticketStatuses, size) = pancakeSwapLottery.viewUserInfoForLotteryId(
                _userAddress,
                _lotteryId,
                _cursor,
                1
            );

            return size > 0 && ticketStatuses[0];
        }
        if (_bunnyId == nftId3) {
            return userWhitelistForNft3[_userAddress];
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CakeToken.sol";
import "./SyrupBar.sol";

// import "@nomiclabs/buidler/console.sol";

interface IMigratorChef {
    // Perform LP token migration from legacy PancakeSwap to CakeSwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to PancakeSwap LP tokens.
    // CakeSwap must mint EXACTLY the same amount of CakeSwap LP tokens or
    // else something bad will happen. Traditional PancakeSwap does not
    // do that so be careful!
    function migrate(IERC20 token) external returns (IERC20);
}

// MasterChef is the master of Cake. He can make Cake and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once CAKE is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of CAKEs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accCakePerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accCakePerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint256 lastRewardBlock; // Last block number that CAKEs distribution occurs.
        uint256 accCakePerShare; // Accumulated CAKEs per share, times 1e12. See below.
    }

    // The CAKE TOKEN!
    CakeToken public cake;
    // The SYRUP TOKEN!
    SyrupBar public syrup;
    // Dev address.
    address public devaddr;
    // CAKE tokens created per block.
    uint256 public cakePerBlock;
    // Bonus muliplier for early cake makers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CAKE mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        CakeToken _cake,
        SyrupBar _syrup,
        address _devaddr,
        uint256 _cakePerBlock,
        uint256 _startBlock
    ) public {
        cake = _cake;
        syrup = _syrup;
        devaddr = _devaddr;
        cakePerBlock = _cakePerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({lpToken: _cake, allocPoint: 1000, lastRewardBlock: startBlock, accCakePerShare: 0}));

        totalAllocPoint = 1000;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accCakePerShare: 0})
        );
        updateStakingPool();
    }

    // Update the given pool's CAKE allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(3);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        cake.mint(devaddr, cakeReward.div(10));
        cake.mint(address(syrup), cakeReward);
        pool.accCakePerShare = pool.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "deposit CAKE by staking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeCakeTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "withdraw CAKE by unstaking");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeCakeTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeCakeTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        syrup.mint(msg.sender, _amount);
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeCakeTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);

        syrup.burn(msg.sender, _amount);
        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) internal {
        syrup.safeCakeTransfer(_to, _amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// CakeToken with Governance.
contract CakeToken is ERC20("PancakeSwap Token", "Cake"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @notice A record of each accounts delegate
    mapping(address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this))
        );

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CAKE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CAKE::delegateBySig: invalid nonce");
        require(now <= expiry, "CAKE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {
        require(blockNumber < block.number, "CAKE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CAKEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, "CAKE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CakeToken.sol";

// SyrupBar with Governance.
contract SyrupBar is ERC20("SyrupBar Token", "SYRUP"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
        _moveDelegates(_delegates[_from], address(0), _amount);
    }

    // The CAKE TOKEN!
    CakeToken public cake;

    constructor(CakeToken _cake) public {
        cake = _cake;
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) public onlyOwner {
        uint256 cakeBal = cake.balanceOf(address(this));
        if (_amount > cakeBal) {
            cake.transfer(_to, cakeBal);
        } else {
            cake.transfer(_to, _amount);
        }
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @notice A record of each accounts delegate
    mapping(address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this))
        );

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CAKE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CAKE::delegateBySig: invalid nonce");
        require(now <= expiry, "CAKE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {
        require(blockNumber < block.number, "CAKE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CAKEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, "CAKE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

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
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import {IPancakeProfile} from "./interfaces/IPancakeProfile.sol";
import "./BunnyMintingStation.sol";

contract BunnySpecialXmas is Ownable {
    BunnyMintingStation public immutable bunnyMintingStation;
    IPancakeProfile public immutable pancakeProfile;

    uint256 public endBlock; // End of the distribution

    // Pancake Profile points threshold
    uint256 public pancakeProfileThresholdPoints;

    uint8 public immutable nftId; // Nft can be minted
    string public tokenURI; // Nft token URI

    mapping(address => bool) public hasClaimed;

    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);
    event NewEndBlock(uint256 endBlock);
    event NewPancakeProfileThresholdPoints(uint256 thresholdPoints);
    event NewTokenURI(string tokenURI);

    /**
     * @notice It initializes the contract.
     * @param _bunnyMintingStationAddress: BunnyMintingStation address
     * @param _pancakeProfileAddress: PancakeProfile address
     * @param _pancakeProfileThresholdPoints: User points threshold for mint NFT
     * @param _nftId: Nft can be minted
     * @param _endBlock: the end of the block
     */
    constructor(
        address _bunnyMintingStationAddress,
        address _pancakeProfileAddress,
        uint256 _pancakeProfileThresholdPoints,
        uint8 _nftId,
        uint256 _endBlock
    ) public {
        bunnyMintingStation = BunnyMintingStation(_bunnyMintingStationAddress);
        pancakeProfile = IPancakeProfile(_pancakeProfileAddress);
        pancakeProfileThresholdPoints = _pancakeProfileThresholdPoints;
        nftId = _nftId;
        endBlock = _endBlock;
    }

    /**
     * @notice Update end block for distribution
     * @dev Only callable by owner.
     */
    function updateEndBlock(uint256 _newEndBlock) external onlyOwner {
        endBlock = _newEndBlock;
        emit NewEndBlock(_newEndBlock);
    }

    /**
     * @notice Update thresholdPoints for distribution
     * @dev Only callable by owner.
     */
    function updateThresholdPoints(uint256 _newThresholdPoints) external onlyOwner {
        pancakeProfileThresholdPoints = _newThresholdPoints;
        emit NewPancakeProfileThresholdPoints(_newThresholdPoints);
    }

    /**
     * @notice Update tokenURI for distribution
     * @dev Only callable by owner.
     */
    function updateTokenURI(string memory _newTokenURI) external onlyOwner {
        tokenURI = _newTokenURI;
        emit NewTokenURI(_newTokenURI);
    }

    /**
     * @notice Mint a NFT from the BunnyMintingStation contract.
     * @dev Users can claim once. It maps to the teamId.
     */
    function mintNFT() external {
        require(canClaim(msg.sender), "User: Not eligible");
        hasClaimed[msg.sender] = true;
        // Mint collectible and send it to the user.
        uint256 tokenId = bunnyMintingStation.mintCollectible(msg.sender, tokenURI, nftId);
        emit BunnyMint(msg.sender, tokenId, nftId);
    }

    /**
     * @notice Check if user can claim NFT.
     */
    function canClaim(address _userAddress) public view returns (bool) {
        (, uint256 numberUserPoints, , , , bool active) = pancakeProfile.getUserProfile(_userAddress);
        // If user is able to mint this NFT
        if (
            !hasClaimed[_userAddress] &&
            block.number < endBlock &&
            active &&
            numberUserPoints >= pancakeProfileThresholdPoints
        ) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "./BunnyMintingStation.sol";
import "./PancakeProfile.sol";

/** @title BunnySpecialV2.
 * @notice It is a contract for users to mint exclusive Easter
 * collectibles for their teams.
 */
contract BunnySpecialV2 is Ownable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    BunnyMintingStation public bunnyMintingStation;
    PancakeProfile public pancakeProfile;

    IBEP20 public cakeToken;

    uint8 public constant previousNumberBunnyIds = 12;

    uint256 public endBlock;
    uint256 public thresholdUser;

    // Map if bunnyId to its tokenURI
    mapping(uint8 => string) public bunnyTokenURI;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // Map teamId to its bunnyId
    mapping(uint256 => uint8) public teamIdToBunnyId;

    event BunnyAdd(uint8 bunnyId, uint256 teamId);

    // Event to notify when NFT is successfully minted
    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);

    event NewEndBlock(uint256 endBlock);
    event NewThresholdUser(uint256 thresholdUser);

    constructor(
        BunnyMintingStation _bunnyMintingStation,
        IBEP20 _cakeToken,
        PancakeProfile _pancakeProfile,
        uint256 _thresholdUser,
        uint256 _endBlock
    ) public {
        bunnyMintingStation = _bunnyMintingStation;
        cakeToken = _cakeToken;
        pancakeProfile = _pancakeProfile;
        thresholdUser = _thresholdUser;
        endBlock = _endBlock;
    }

    /**
     * @notice Mint a NFT from the BunnyMintingStation contract.
     * @dev Users can claim once. It maps to the teamId.
     */
    function mintNFT() external {
        require(block.number < endBlock, "TOO_LATE");

        address senderAddress = _msgSender();

        // Check _msgSender() has not claimed
        require(!hasClaimed[senderAddress], "ERR_HAS_CLAIMED");

        uint256 userId;
        uint256 userTeamId;
        bool isUserActive;

        (userId, , userTeamId, , , isUserActive) = pancakeProfile.getUserProfile(senderAddress);

        require(userId < thresholdUser, "ERR_USER_NOT_ELIGIBLE");
        require(isUserActive, "ERR_USER_NOT_ACTIVE");

        // Update that _msgSender() has claimed
        hasClaimed[senderAddress] = true;

        uint8 bunnyId = teamIdToBunnyId[userTeamId];

        require(bunnyId >= previousNumberBunnyIds, "NOT_VALID");

        string memory tokenURI = bunnyTokenURI[bunnyId];

        uint256 tokenId = bunnyMintingStation.mintCollectible(senderAddress, tokenURI, bunnyId);

        emit BunnyMint(senderAddress, tokenId, bunnyId);
    }

    /**
     * @notice Add/modify bunnyId for a teamId and metadata
     * @dev Only callable by owner.
     */
    function addBunny(
        uint8 _bunnyId,
        uint256 _teamId,
        string calldata _tokenURI
    ) external onlyOwner {
        require(_bunnyId >= previousNumberBunnyIds, "ERR_ID_LOW_2");

        teamIdToBunnyId[_teamId] = _bunnyId;
        bunnyTokenURI[_bunnyId] = _tokenURI;

        emit BunnyAdd(_bunnyId, _teamId);
    }

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     */
    function changeEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;
        emit NewEndBlock(_endBlock);
    }

    /**
     * @notice Change user threshold
     * @dev Only callable by owner.
     */
    function changeThresholdUser(uint256 _thresholdUser) external onlyOwner {
        thresholdUser = _thresholdUser;
        emit NewThresholdUser(_thresholdUser);
    }

    /**
     * @notice Check if a user can claim.
     */
    function canClaim(address _userAddress) external view returns (bool) {
        if (hasClaimed[_userAddress]) {
            return false;
        } else {
            if (!pancakeProfile.getUserStatus(_userAddress)) {
                return false;
            } else {
                uint256 userId;
                (userId, , , , , ) = pancakeProfile.getUserProfile(_userAddress);

                if (userId < thresholdUser) {
                    return true;
                } else {
                    return false;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "./BunnyMintingStation.sol";
import "./PancakeProfile.sol";

/** @title BunnySpecialV1.
 * @notice It is a contract for users to mint exclusive NFTs
 * based on a CAKE price and userId.
 */
contract BunnySpecialV1 is Ownable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    BunnyMintingStation public bunnyMintingStation;
    PancakeProfile public pancakeProfile;

    IBEP20 public cakeToken;

    uint256 public maxViewLength;
    uint256 public numberDifferentBunnies;

    // Map if address for a bunnyId has already claimed a NFT
    mapping(address => mapping(uint8 => bool)) public hasClaimed;

    // Map if bunnyId to its characteristics
    mapping(uint8 => Bunnies) public bunnyCharacteristics;

    // Number of previous series (i.e. different visuals)
    uint8 private constant previousNumberBunnyIds = 10;

    struct Bunnies {
        string tokenURI; // e.g. ipfsHash/hiccups.json
        uint256 thresholdUser; // e.g. 1900 or 100000
        uint256 cakeCost;
        bool isActive;
        bool isCreated;
    }

    // Event to notify a new bunny is mintable
    event BunnyAdd(uint8 indexed bunnyId, uint256 thresholdUser, uint256 costCake);

    // Event to notify one of the bunnies' requirements to mint differ
    event BunnyChange(uint8 indexed bunnyId, uint256 thresholdUser, uint256 costCake, bool isActive);

    // Event to notify when NFT is successfully minted
    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);

    constructor(
        BunnyMintingStation _bunnyMintingStation,
        IBEP20 _cakeToken,
        PancakeProfile _pancakeProfile,
        uint256 _maxViewLength
    ) public {
        bunnyMintingStation = _bunnyMintingStation;
        cakeToken = _cakeToken;
        pancakeProfile = _pancakeProfile;
        maxViewLength = _maxViewLength;
    }

    /**
     * @dev Mint NFTs from the BunnyMintingStation contract.
     * Users can claim once.
     */
    function mintNFT(uint8 _bunnyId) external {
        // Check that the _bunnyId is within boundary
        require(_bunnyId >= previousNumberBunnyIds, "ERR_ID_LOW");
        require(bunnyCharacteristics[_bunnyId].isActive, "ERR_ID_INVALID");

        address senderAddress = _msgSender();

        // 1. Check _msgSender() has not claimed
        require(!hasClaimed[senderAddress][_bunnyId], "ERR_HAS_CLAIMED");

        uint256 userId;
        bool isUserActive;

        (userId, , , , , isUserActive) = pancakeProfile.getUserProfile(senderAddress);

        require(userId < bunnyCharacteristics[_bunnyId].thresholdUser, "ERR_USER_NOT_ELIGIBLE");

        require(isUserActive, "ERR_USER_NOT_ACTIVE");

        // Check if there is any cost associated with getting the bunny
        if (bunnyCharacteristics[_bunnyId].cakeCost > 0) {
            cakeToken.safeTransferFrom(senderAddress, address(this), bunnyCharacteristics[_bunnyId].cakeCost);
        }

        // Update that _msgSender() has claimed
        hasClaimed[senderAddress][_bunnyId] = true;

        uint256 tokenId = bunnyMintingStation.mintCollectible(
            senderAddress,
            bunnyCharacteristics[_bunnyId].tokenURI,
            _bunnyId
        );

        emit BunnyMint(senderAddress, tokenId, _bunnyId);
    }

    function addBunny(
        uint8 _bunnyId,
        string calldata _tokenURI,
        uint256 _thresholdUser,
        uint256 _cakeCost
    ) external onlyOwner {
        require(!bunnyCharacteristics[_bunnyId].isCreated, "ERR_CREATED");
        require(_bunnyId >= previousNumberBunnyIds, "ERR_ID_LOW_2");

        bunnyCharacteristics[_bunnyId] = Bunnies({
            tokenURI: _tokenURI,
            thresholdUser: _thresholdUser,
            cakeCost: _cakeCost,
            isActive: true,
            isCreated: true
        });

        numberDifferentBunnies = numberDifferentBunnies.add(1);

        emit BunnyAdd(_bunnyId, _thresholdUser, _cakeCost);
    }

    /**
     * @dev It transfers the CAKE tokens back to the chef address.
     * Only callable by the owner.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    function updateBunny(
        uint8 _bunnyId,
        uint256 _thresholdUser,
        uint256 _cakeCost,
        bool _isActive
    ) external onlyOwner {
        require(bunnyCharacteristics[_bunnyId].isCreated, "ERR_NOT_CREATED");
        bunnyCharacteristics[_bunnyId].thresholdUser = _thresholdUser;
        bunnyCharacteristics[_bunnyId].cakeCost = _cakeCost;
        bunnyCharacteristics[_bunnyId].isActive = _isActive;

        emit BunnyChange(_bunnyId, _thresholdUser, _cakeCost, _isActive);
    }

    function updateMaxViewLength(uint256 _newMaxViewLength) external onlyOwner {
        maxViewLength = _newMaxViewLength;
    }

    function canClaimSingle(address _userAddress, uint8 _bunnyId) external view returns (bool) {
        if (!pancakeProfile.hasRegistered(_userAddress)) {
            return false;
        } else {
            uint256 userId;
            bool userStatus;

            (userId, , , , , userStatus) = pancakeProfile.getUserProfile(_userAddress);

            if (!userStatus) {
                return false;
            } else {
                bool claimStatus = _canClaim(_userAddress, userId, _bunnyId);
                return claimStatus;
            }
        }
    }

    function canClaimMultiple(address _userAddress, uint8[] calldata _bunnyIds) external view returns (bool[] memory) {
        require(_bunnyIds.length <= maxViewLength, "ERR_LENGTH_VIEW");

        if (!pancakeProfile.hasRegistered(_userAddress)) {
            bool[] memory responses = new bool[](0);
            return responses;
        } else {
            uint256 userId;
            bool userStatus;

            (userId, , , , , userStatus) = pancakeProfile.getUserProfile(_userAddress);

            if (!userStatus) {
                bool[] memory responses = new bool[](0);
                return responses;
            } else {
                bool[] memory responses = new bool[](_bunnyIds.length);

                for (uint256 i = 0; i < _bunnyIds.length; i++) {
                    bool claimStatus = _canClaim(_userAddress, userId, _bunnyIds[i]);
                    responses[i] = claimStatus;
                }
                return responses;
            }
        }
    }

    /**
     * @dev Check if user can claim.
     * If the address hadn't set up a profile, it will return an error.
     */
    function _canClaim(
        address _userAddress,
        uint256 userId,
        uint8 _bunnyId
    ) internal view returns (bool) {
        uint256 bunnyThreshold = bunnyCharacteristics[_bunnyId].thresholdUser;
        bool bunnyActive = bunnyCharacteristics[_bunnyId].isActive;

        if (hasClaimed[_userAddress][_bunnyId]) {
            return false;
        } else if (!bunnyActive) {
            return false;
        } else if (userId >= bunnyThreshold) {
            return false;
        } else {
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./interfaces/AggregatorV3Interface.sol";

contract BnbPricePrediction is Ownable, Pausable {
    using SafeMath for uint256;

    struct Round {
        uint256 epoch;
        uint256 startBlock;
        uint256 lockBlock;
        uint256 closeBlock;
        int256 lockPrice;
        int256 closePrice;
        uint256 lockOracleId;
        uint256 closeOracleId;
        uint256 totalAmount;
        uint256 bullAmount;
        uint256 bearAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        bool oracleCalled;
    }

    enum Position {
        Bull,
        Bear
    }

    struct BetInfo {
        Position position;
        uint256 amount;
        bool claimed; // default false
    }

    mapping(uint256 => Round) public rounds;
    mapping(uint256 => mapping(address => BetInfo)) public ledger;
    mapping(address => uint256[]) public userRounds;
    uint256 public currentEpoch;
    uint256 public intervalBlocks;
    uint256 public bufferBlocks;
    address public adminAddress;
    address public operatorAddress;
    uint256 public treasuryAmount;
    AggregatorV3Interface internal oracle;
    uint256 public oracleLatestRoundId;

    uint256 public constant TOTAL_RATE = 100; // 100%
    uint256 public rewardRate = 90; // 90%
    uint256 public treasuryRate = 10; // 10%
    uint256 public minBetAmount;
    uint256 public oracleUpdateAllowance; // seconds

    bool public genesisStartOnce = false;
    bool public genesisLockOnce = false;

    event StartRound(uint256 indexed epoch);
    event LockRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);
    event EndRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);
    event BetBull(address indexed sender, uint256 indexed currentEpoch, uint256 amount);
    event BetBear(address indexed sender, uint256 indexed currentEpoch, uint256 amount);
    event Claim(address indexed sender, uint256 indexed currentEpoch, uint256 amount);
    event ClaimTreasury(uint256 amount);
    event RatesUpdated(uint256 indexed epoch, uint256 rewardRate, uint256 treasuryRate);
    event MinBetAmountUpdated(uint256 indexed epoch, uint256 minBetAmount);
    event RewardsCalculated(
        uint256 indexed epoch,
        uint256 rewardBaseCalAmount,
        uint256 rewardAmount,
        uint256 treasuryAmount
    );
    event Pause(uint256 epoch);
    event Unpause(uint256 epoch);

    constructor(
        AggregatorV3Interface _oracle,
        address _adminAddress,
        address _operatorAddress,
        uint256 _intervalBlocks,
        uint256 _bufferBlocks,
        uint256 _minBetAmount,
        uint256 _oracleUpdateAllowance
    ) public {
        oracle = _oracle;
        adminAddress = _adminAddress;
        operatorAddress = _operatorAddress;
        intervalBlocks = _intervalBlocks;
        bufferBlocks = _bufferBlocks;
        minBetAmount = _minBetAmount;
        oracleUpdateAllowance = _oracleUpdateAllowance;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "operator: wut?");
        _;
    }

    modifier onlyAdminOrOperator() {
        require(msg.sender == adminAddress || msg.sender == operatorAddress, "admin | operator: wut?");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @dev set admin address
     * callable by owner
     */
    function setAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;
    }

    /**
     * @dev set operator address
     * callable by admin
     */
    function setOperator(address _operatorAddress) external onlyAdmin {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;
    }

    /**
     * @dev set interval blocks
     * callable by admin
     */
    function setIntervalBlocks(uint256 _intervalBlocks) external onlyAdmin {
        intervalBlocks = _intervalBlocks;
    }

    /**
     * @dev set buffer blocks
     * callable by admin
     */
    function setBufferBlocks(uint256 _bufferBlocks) external onlyAdmin {
        require(_bufferBlocks <= intervalBlocks, "Cannot be more than intervalBlocks");
        bufferBlocks = _bufferBlocks;
    }

    /**
     * @dev set Oracle address
     * callable by admin
     */
    function setOracle(address _oracle) external onlyAdmin {
        require(_oracle != address(0), "Cannot be zero address");
        oracle = AggregatorV3Interface(_oracle);
    }

    /**
     * @dev set oracle update allowance
     * callable by admin
     */
    function setOracleUpdateAllowance(uint256 _oracleUpdateAllowance) external onlyAdmin {
        oracleUpdateAllowance = _oracleUpdateAllowance;
    }

    /**
     * @dev set reward rate
     * callable by admin
     */
    function setRewardRate(uint256 _rewardRate) external onlyAdmin {
        require(_rewardRate <= TOTAL_RATE, "rewardRate cannot be more than 100%");
        rewardRate = _rewardRate;
        treasuryRate = TOTAL_RATE.sub(_rewardRate);

        emit RatesUpdated(currentEpoch, rewardRate, treasuryRate);
    }

    /**
     * @dev set treasury rate
     * callable by admin
     */
    function setTreasuryRate(uint256 _treasuryRate) external onlyAdmin {
        require(_treasuryRate <= TOTAL_RATE, "treasuryRate cannot be more than 100%");
        rewardRate = TOTAL_RATE.sub(_treasuryRate);
        treasuryRate = _treasuryRate;

        emit RatesUpdated(currentEpoch, rewardRate, treasuryRate);
    }

    /**
     * @dev set minBetAmount
     * callable by admin
     */
    function setMinBetAmount(uint256 _minBetAmount) external onlyAdmin {
        minBetAmount = _minBetAmount;

        emit MinBetAmountUpdated(currentEpoch, minBetAmount);
    }

    /**
     * @dev Start genesis round
     */
    function genesisStartRound() external onlyOperator whenNotPaused {
        require(!genesisStartOnce, "Can only run genesisStartRound once");

        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch);
        genesisStartOnce = true;
    }

    /**
     * @dev Lock genesis round
     */
    function genesisLockRound() external onlyOperator whenNotPaused {
        require(genesisStartOnce, "Can only run after genesisStartRound is triggered");
        require(!genesisLockOnce, "Can only run genesisLockRound once");
        require(
            block.number <= rounds[currentEpoch].lockBlock.add(bufferBlocks),
            "Can only lock round within bufferBlocks"
        );

        (uint256 currentRoundId, int256 currentPrice) = _getPriceFromOracle();
        _safeLockRound(currentEpoch, currentRoundId, currentPrice);

        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch);
        genesisLockOnce = true;
    }

    /**
     * @dev Start the next round n, lock price for round n-1, end round n-2
     */
    function executeRound() external onlyOperator whenNotPaused {
        require(
            genesisStartOnce && genesisLockOnce,
            "Can only run after genesisStartRound and genesisLockRound is triggered"
        );

        (uint256 currentRoundId, int256 currentPrice) = _getPriceFromOracle();
        // CurrentEpoch refers to previous round (n-1)
        _safeLockRound(currentEpoch, currentRoundId, currentPrice);
        _safeEndRound(currentEpoch - 1, currentRoundId, currentPrice);
        _calculateRewards(currentEpoch - 1);

        // Increment currentEpoch to current round (n)
        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch);
    }

    /**
     * @dev Bet bear position
     */
    function betBear() external payable whenNotPaused notContract {
        require(_bettable(currentEpoch), "Round not bettable");
        require(msg.value >= minBetAmount, "Bet amount must be greater than minBetAmount");
        require(ledger[currentEpoch][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        uint256 amount = msg.value;
        Round storage round = rounds[currentEpoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bearAmount = round.bearAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[currentEpoch][msg.sender];
        betInfo.position = Position.Bear;
        betInfo.amount = amount;
        userRounds[msg.sender].push(currentEpoch);

        emit BetBear(msg.sender, currentEpoch, amount);
    }

    /**
     * @dev Bet bull position
     */
    function betBull() external payable whenNotPaused notContract {
        require(_bettable(currentEpoch), "Round not bettable");
        require(msg.value >= minBetAmount, "Bet amount must be greater than minBetAmount");
        require(ledger[currentEpoch][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        uint256 amount = msg.value;
        Round storage round = rounds[currentEpoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bullAmount = round.bullAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[currentEpoch][msg.sender];
        betInfo.position = Position.Bull;
        betInfo.amount = amount;
        userRounds[msg.sender].push(currentEpoch);

        emit BetBull(msg.sender, currentEpoch, amount);
    }

    /**
     * @dev Claim reward
     */
    function claim(uint256 epoch) external notContract {
        require(rounds[epoch].startBlock != 0, "Round has not started");
        require(block.number > rounds[epoch].closeBlock, "Round has not ended");
        require(!ledger[epoch][msg.sender].claimed, "Rewards claimed");

        uint256 reward;
        // Round valid, claim rewards
        if (rounds[epoch].oracleCalled) {
            require(claimable(epoch, msg.sender), "Not eligible for claim");
            Round memory round = rounds[epoch];
            reward = ledger[epoch][msg.sender].amount.mul(round.rewardAmount).div(round.rewardBaseCalAmount);
        }
        // Round invalid, refund bet amount
        else {
            require(refundable(epoch, msg.sender), "Not eligible for refund");
            reward = ledger[epoch][msg.sender].amount;
        }

        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.claimed = true;
        _safeTransferBNB(address(msg.sender), reward);

        emit Claim(msg.sender, epoch, reward);
    }

    /**
     * @dev Claim all rewards in treasury
     * callable by admin
     */
    function claimTreasury() external onlyAdmin {
        uint256 currentTreasuryAmount = treasuryAmount;
        treasuryAmount = 0;
        _safeTransferBNB(adminAddress, currentTreasuryAmount);

        emit ClaimTreasury(currentTreasuryAmount);
    }

    /**
     * @dev Return round epochs that a user has participated
     */
    function getUserRounds(
        address user,
        uint256 cursor,
        uint256 size
    ) external view returns (uint256[] memory, uint256) {
        uint256 length = size;
        if (length > userRounds[user].length - cursor) {
            length = userRounds[user].length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = userRounds[user][cursor + i];
        }

        return (values, cursor + length);
    }

    /**
     * @dev called by the admin to pause, triggers stopped state
     */
    function pause() public onlyAdminOrOperator whenNotPaused {
        _pause();

        emit Pause(currentEpoch);
    }

    /**
     * @dev called by the admin to unpause, returns to normal state
     * Reset genesis state. Once paused, the rounds would need to be kickstarted by genesis
     */
    function unpause() public onlyAdmin whenPaused {
        genesisStartOnce = false;
        genesisLockOnce = false;
        _unpause();

        emit Unpause(currentEpoch);
    }

    /**
     * @dev Get the claimable stats of specific epoch and user account
     */
    function claimable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Round memory round = rounds[epoch];
        if (round.lockPrice == round.closePrice) {
            return false;
        }
        return
            round.oracleCalled &&
            ((round.closePrice > round.lockPrice && betInfo.position == Position.Bull) ||
                (round.closePrice < round.lockPrice && betInfo.position == Position.Bear));
    }

    /**
     * @dev Get the refundable stats of specific epoch and user account
     */
    function refundable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Round memory round = rounds[epoch];
        return !round.oracleCalled && block.number > round.closeBlock.add(bufferBlocks) && betInfo.amount != 0;
    }

    /**
     * @dev Start round
     * Previous round n-2 must end
     */
    function _safeStartRound(uint256 epoch) internal {
        require(genesisStartOnce, "Can only run after genesisStartRound is triggered");
        require(rounds[epoch - 2].closeBlock != 0, "Can only start round after round n-2 has ended");
        require(block.number >= rounds[epoch - 2].closeBlock, "Can only start new round after round n-2 closeBlock");
        _startRound(epoch);
    }

    function _startRound(uint256 epoch) internal {
        Round storage round = rounds[epoch];
        round.startBlock = block.number;
        round.lockBlock = block.number.add(intervalBlocks);
        round.closeBlock = block.number.add(intervalBlocks * 2);
        round.epoch = epoch;
        round.totalAmount = 0;

        emit StartRound(epoch);
    }

    /**
     * @dev Lock round
     */
    function _safeLockRound(
        uint256 epoch,
        uint256 roundId,
        int256 price
    ) internal {
        require(rounds[epoch].startBlock != 0, "Can only lock round after round has started");
        require(block.number >= rounds[epoch].lockBlock, "Can only lock round after lockBlock");
        require(block.number <= rounds[epoch].lockBlock.add(bufferBlocks), "Can only lock round within bufferBlocks");
        _lockRound(epoch, roundId, price);
    }

    function _lockRound(
        uint256 epoch,
        uint256 roundId,
        int256 price
    ) internal {
        Round storage round = rounds[epoch];
        round.lockPrice = price;
        round.lockOracleId = roundId;

        emit LockRound(epoch, roundId, round.lockPrice);
    }

    /**
     * @dev End round
     */
    function _safeEndRound(
        uint256 epoch,
        uint256 roundId,
        int256 price
    ) internal {
        require(rounds[epoch].lockBlock != 0, "Can only end round after round has locked");
        require(block.number >= rounds[epoch].closeBlock, "Can only end round after closeBlock");
        require(block.number <= rounds[epoch].closeBlock.add(bufferBlocks), "Can only end round within bufferBlocks");
        _endRound(epoch, roundId, price);
    }

    function _endRound(
        uint256 epoch,
        uint256 roundId,
        int256 price
    ) internal {
        Round storage round = rounds[epoch];
        round.closePrice = price;
        round.closeOracleId = roundId;
        round.oracleCalled = true;

        emit EndRound(epoch, roundId, round.closePrice);
    }

    /**
     * @dev Calculate rewards for round
     */
    function _calculateRewards(uint256 epoch) internal {
        require(rewardRate.add(treasuryRate) == TOTAL_RATE, "rewardRate and treasuryRate must add up to TOTAL_RATE");
        require(rounds[epoch].rewardBaseCalAmount == 0 && rounds[epoch].rewardAmount == 0, "Rewards calculated");
        Round storage round = rounds[epoch];
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        uint256 treasuryAmt;
        // Bull wins
        if (round.closePrice > round.lockPrice) {
            rewardBaseCalAmount = round.bullAmount;
            rewardAmount = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
            treasuryAmt = round.totalAmount.mul(treasuryRate).div(TOTAL_RATE);
        }
        // Bear wins
        else if (round.closePrice < round.lockPrice) {
            rewardBaseCalAmount = round.bearAmount;
            rewardAmount = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
            treasuryAmt = round.totalAmount.mul(treasuryRate).div(TOTAL_RATE);
        }
        // House wins
        else {
            rewardBaseCalAmount = 0;
            rewardAmount = 0;
            treasuryAmt = round.totalAmount;
        }
        round.rewardBaseCalAmount = rewardBaseCalAmount;
        round.rewardAmount = rewardAmount;

        // Add to treasury
        treasuryAmount = treasuryAmount.add(treasuryAmt);

        emit RewardsCalculated(epoch, rewardBaseCalAmount, rewardAmount, treasuryAmt);
    }

    /**
     * @dev Get latest recorded price from oracle
     * If it falls below allowed buffer or has not updated, it would be invalid
     */
    function _getPriceFromOracle() internal returns (uint256, int256) {
        uint256 leastAllowedTimestamp = block.timestamp.add(oracleUpdateAllowance);
        (uint80 roundId, int256 price, , uint256 timestamp, ) = oracle.latestRoundData();
        require(timestamp <= leastAllowedTimestamp, "Oracle update exceeded max timestamp allowance");
        require(roundId > oracleLatestRoundId, "Oracle update roundId must be larger than oracleLatestRoundId");
        oracleLatestRoundId = uint256(roundId);
        return (oracleLatestRoundId, price);
    }

    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     * @dev Determine if a round is valid for receiving bets
     * Round must have started and locked
     * Current block must be within startBlock and closeBlock
     */
    function _bettable(uint256 epoch) internal view returns (bool) {
        return
            rounds[epoch].startBlock != 0 &&
            rounds[epoch].lockBlock != 0 &&
            block.number > rounds[epoch].startBlock &&
            block.number < rounds[epoch].lockBlock;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

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
    constructor () internal {
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./interfaces/IMasterChef.sol";

contract CakeVault is Ownable, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 shares; // number of shares for a user
        uint256 lastDepositedTime; // keeps track of deposited time for potential penalty
        uint256 cakeAtLastUserAction; // keeps track of cake deposited at the last user action
        uint256 lastUserActionTime; // keeps track of the last user action time
    }

    IERC20 public immutable token; // Cake token
    IERC20 public immutable receiptToken; // Syrup token

    IMasterChef public immutable masterchef;

    mapping(address => UserInfo) public userInfo;

    uint256 public totalShares;
    uint256 public lastHarvestedTime;
    address public admin;
    address public treasury;

    uint256 public constant MAX_PERFORMANCE_FEE = 500; // 5%
    uint256 public constant MAX_CALL_FEE = 100; // 1%
    uint256 public constant MAX_WITHDRAW_FEE = 100; // 1%
    uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 72 hours; // 3 days

    uint256 public performanceFee = 200; // 2%
    uint256 public callFee = 25; // 0.25%
    uint256 public withdrawFee = 10; // 0.1%
    uint256 public withdrawFeePeriod = 72 hours; // 3 days

    event Deposit(address indexed sender, uint256 amount, uint256 shares, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event Harvest(address indexed sender, uint256 performanceFee, uint256 callFee);
    event Pause();
    event Unpause();

    /**
     * @notice Constructor
     * @param _token: Cake token contract
     * @param _receiptToken: Syrup token contract
     * @param _masterchef: MasterChef contract
     * @param _admin: address of the admin
     * @param _treasury: address of the treasury (collects fees)
     */
    constructor(
        IERC20 _token,
        IERC20 _receiptToken,
        IMasterChef _masterchef,
        address _admin,
        address _treasury
    ) public {
        token = _token;
        receiptToken = _receiptToken;
        masterchef = _masterchef;
        admin = _admin;
        treasury = _treasury;

        // Infinite approve
        IERC20(_token).safeApprove(address(_masterchef), uint256(-1));
    }

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "admin: wut?");
        _;
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Deposits funds into the Cake Vault
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in CAKE)
     */
    function deposit(uint256 _amount) external whenNotPaused notContract {
        require(_amount > 0, "Nothing to deposit");

        uint256 pool = balanceOf();
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 currentShares = 0;
        if (totalShares != 0) {
            currentShares = (_amount.mul(totalShares)).div(pool);
        } else {
            currentShares = _amount;
        }
        UserInfo storage user = userInfo[msg.sender];

        user.shares = user.shares.add(currentShares);
        user.lastDepositedTime = block.timestamp;

        totalShares = totalShares.add(currentShares);

        user.cakeAtLastUserAction = user.shares.mul(balanceOf()).div(totalShares);
        user.lastUserActionTime = block.timestamp;

        _earn();

        emit Deposit(msg.sender, _amount, currentShares, block.timestamp);
    }

    /**
     * @notice Withdraws all funds for a user
     */
    function withdrawAll() external notContract {
        withdraw(userInfo[msg.sender].shares);
    }

    /**
     * @notice Reinvests CAKE tokens into MasterChef
     * @dev Only possible when contract not paused.
     */
    function harvest() external notContract whenNotPaused {
        IMasterChef(masterchef).leaveStaking(0);

        uint256 bal = available();
        uint256 currentPerformanceFee = bal.mul(performanceFee).div(10000);
        token.safeTransfer(treasury, currentPerformanceFee);

        uint256 currentCallFee = bal.mul(callFee).div(10000);
        token.safeTransfer(msg.sender, currentCallFee);

        _earn();

        lastHarvestedTime = block.timestamp;

        emit Harvest(msg.sender, currentPerformanceFee, currentCallFee);
    }

    /**
     * @notice Sets admin address
     * @dev Only callable by the contract owner.
     */
    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Cannot be zero address");
        admin = _admin;
    }

    /**
     * @notice Sets treasury address
     * @dev Only callable by the contract owner.
     */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be zero address");
        treasury = _treasury;
    }

    /**
     * @notice Sets performance fee
     * @dev Only callable by the contract admin.
     */
    function setPerformanceFee(uint256 _performanceFee) external onlyAdmin {
        require(_performanceFee <= MAX_PERFORMANCE_FEE, "performanceFee cannot be more than MAX_PERFORMANCE_FEE");
        performanceFee = _performanceFee;
    }

    /**
     * @notice Sets call fee
     * @dev Only callable by the contract admin.
     */
    function setCallFee(uint256 _callFee) external onlyAdmin {
        require(_callFee <= MAX_CALL_FEE, "callFee cannot be more than MAX_CALL_FEE");
        callFee = _callFee;
    }

    /**
     * @notice Sets withdraw fee
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFee(uint256 _withdrawFee) external onlyAdmin {
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFee = _withdrawFee;
    }

    /**
     * @notice Sets withdraw fee period
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyAdmin {
        require(
            _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
        );
        withdrawFeePeriod = _withdrawFeePeriod;
    }

    /**
     * @notice Withdraws from MasterChef to Vault without caring about rewards.
     * @dev EMERGENCY ONLY. Only callable by the contract admin.
     */
    function emergencyWithdraw() external onlyAdmin {
        IMasterChef(masterchef).emergencyWithdraw(0);
    }

    /**
     * @notice Withdraw unexpected tokens sent to the Cake Vault
     */
    function inCaseTokensGetStuck(address _token) external onlyAdmin {
        require(_token != address(token), "Token cannot be same as deposit token");
        require(_token != address(receiptToken), "Token cannot be same as receipt token");

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Triggers stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyAdmin whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Returns to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyAdmin whenPaused {
        _unpause();
        emit Unpause();
    }

    /**
     * @notice Calculates the expected harvest reward from third party
     * @return Expected reward to collect in CAKE
     */
    function calculateHarvestCakeRewards() external view returns (uint256) {
        uint256 amount = IMasterChef(masterchef).pendingCake(0, address(this));
        amount = amount.add(available());
        uint256 currentCallFee = amount.mul(callFee).div(10000);

        return currentCallFee;
    }

    /**
     * @notice Calculates the total pending rewards that can be restaked
     * @return Returns total pending cake rewards
     */
    function calculateTotalPendingCakeRewards() external view returns (uint256) {
        uint256 amount = IMasterChef(masterchef).pendingCake(0, address(this));
        amount = amount.add(available());

        return amount;
    }

    /**
     * @notice Calculates the price per share
     */
    function getPricePerFullShare() external view returns (uint256) {
        return totalShares == 0 ? 1e18 : balanceOf().mul(1e18).div(totalShares);
    }

    /**
     * @notice Withdraws from funds from the Cake Vault
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares) public notContract {
        UserInfo storage user = userInfo[msg.sender];
        require(_shares > 0, "Nothing to withdraw");
        require(_shares <= user.shares, "Withdraw amount exceeds balance");

        uint256 currentAmount = (balanceOf().mul(_shares)).div(totalShares);
        user.shares = user.shares.sub(_shares);
        totalShares = totalShares.sub(_shares);

        uint256 bal = available();
        if (bal < currentAmount) {
            uint256 balWithdraw = currentAmount.sub(bal);
            IMasterChef(masterchef).leaveStaking(balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter.sub(bal);
            if (diff < balWithdraw) {
                currentAmount = bal.add(diff);
            }
        }

        if (block.timestamp < user.lastDepositedTime.add(withdrawFeePeriod)) {
            uint256 currentWithdrawFee = currentAmount.mul(withdrawFee).div(10000);
            token.safeTransfer(treasury, currentWithdrawFee);
            currentAmount = currentAmount.sub(currentWithdrawFee);
        }

        if (user.shares > 0) {
            user.cakeAtLastUserAction = user.shares.mul(balanceOf()).div(totalShares);
        } else {
            user.cakeAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

        token.safeTransfer(msg.sender, currentAmount);

        emit Withdraw(msg.sender, currentAmount, _shares);
    }

    /**
     * @notice Custom logic for how much the vault allows to be borrowed
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and held in MasterChef
     */
    function balanceOf() public view returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterchef).userInfo(0, address(this));
        return token.balanceOf(address(this)).add(amount);
    }

    /**
     * @notice Deposits tokens into MasterChef to earn staking rewards
     */
    function _earn() internal {
        uint256 bal = available();
        if (bal > 0) {
            IMasterChef(masterchef).enterStaking(bal);
        }
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "pancake-cake-vault/contracts/CakeVault.sol";

import "./BunnyMintingStation.sol";
import "./PancakeProfile.sol";

/**
 * @title BunnySpecialCakeVault.
 * @notice It is a contract for users to mint Cake Vault collectible.
 */
contract BunnySpecialCakeVault is Ownable {
    using SafeMath for uint256;

    BunnyMintingStation public bunnyMintingStation;
    CakeVault public cakeVault;
    PancakeProfile public pancakeProfile;

    uint8 public constant bunnyId = 16;

    // Collectible-related.
    uint256 public endBlock;
    uint256 public thresholdTimestamp;

    // PancakeSwap Profile related.
    uint256 public numberPoints;
    uint256 public campaignId;

    string public tokenURI;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);
    event NewCampaignId(uint256 campaignId);
    event NewEndBlock(uint256 endBlock);
    event NewNumberPoints(uint256 numberPoints);
    event NewThresholdTimestamp(uint256 thresholdTimestamp);

    constructor(
        address _cakeVault,
        address _bunnyMintingStation,
        address _pancakeProfile,
        uint256 _endBlock,
        uint256 _thresholdTimestamp,
        uint256 _numberPoints,
        uint256 _campaignId,
        string memory _tokenURI
    ) public {
        cakeVault = CakeVault(_cakeVault);
        bunnyMintingStation = BunnyMintingStation(_bunnyMintingStation);
        pancakeProfile = PancakeProfile(_pancakeProfile);
        endBlock = _endBlock;
        thresholdTimestamp = _thresholdTimestamp;
        numberPoints = _numberPoints;
        campaignId = _campaignId;
        tokenURI = _tokenURI;
    }

    /**
     * @notice Mint a NFT from the BunnyMintingStation contract.
     * @dev Users can claim once.
     */
    function mintNFT() external {
        require(block.number < endBlock, "TOO_LATE");

        // Check msg.sender has not claimed
        require(!hasClaimed[msg.sender], "ERR_HAS_CLAIMED");

        bool isUserActive;
        (, , , , , isUserActive) = pancakeProfile.getUserProfile(msg.sender);

        require(isUserActive, "ERR_USER_NOT_ACTIVE");

        bool isUserEligible;
        isUserEligible = _canClaim(msg.sender);

        require(isUserEligible, "ERR_USER_NOT_ELIGIBLE");

        // Update that msg.sender has claimed
        hasClaimed[msg.sender] = true;

        // Mint collectible and send it to the user.
        uint256 tokenId = bunnyMintingStation.mintCollectible(msg.sender, tokenURI, bunnyId);

        // Increase point on PancakeSwap profile, for a given campaignId.
        pancakeProfile.increaseUserPoints(msg.sender, numberPoints, campaignId);

        emit BunnyMint(msg.sender, tokenId, bunnyId);
    }

    /**
     * @notice Change the campaignId for PancakeSwap Profile.
     * @dev Only callable by owner.
     */
    function changeCampaignId(uint256 _campaignId) external onlyOwner {
        campaignId = _campaignId;

        emit NewCampaignId(_campaignId);
    }

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     */
    function changeEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;

        emit NewEndBlock(_endBlock);
    }

    /**
     * @notice Change the number of points for PancakeSwap Profile.
     * @dev Only callable by owner.
     */
    function changeNumberPoints(uint256 _numberPoints) external onlyOwner {
        numberPoints = _numberPoints;

        emit NewNumberPoints(_numberPoints);
    }

    /**
     * @notice Change threshold timestamp for distribution
     * @dev Only callable by owner.
     */
    function changeThresholdTimestamp(uint256 _thresholdTimestamp) external onlyOwner {
        thresholdTimestamp = _thresholdTimestamp;

        emit NewThresholdTimestamp(_thresholdTimestamp);
    }

    /**
     * @notice Check if a user can claim.
     */
    function canClaim(address _userAddress) external view returns (bool) {
        return _canClaim(_userAddress);
    }

    /**
     * @notice Check if a user can claim.
     */
    function _canClaim(address _userAddress) internal view returns (bool) {
        if (hasClaimed[_userAddress]) {
            return false;
        } else {
            if (!pancakeProfile.getUserStatus(_userAddress)) {
                return false;
            } else {
                uint256 lastDepositedTime;
                (, lastDepositedTime, , ) = cakeVault.userInfo(_userAddress);

                if (lastDepositedTime != 0) {
                    if (lastDepositedTime < thresholdTimestamp) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "predictions/contracts/BnbPricePrediction.sol";

import "./BunnyMintingStation.sol";
import "./PancakeProfile.sol";

/**
 * @title BunnySpecialPrediction.
 * @notice It is a contract for users to mint exclusive
 * collectibles if they participated in Prediction beta.
 */
contract BunnySpecialPrediction is Ownable {
    using SafeMath for uint256;

    BunnyMintingStation public bunnyMintingStation;
    PancakeProfile public pancakeProfile;
    BnbPricePrediction public pancakePrediction;

    uint8 public constant bunnyId = 17;

    // Collectible-related.
    uint256 public endBlock;
    uint256 public thresholdRound;

    // PancakeSwap Profile related.
    uint256 public numberPoints;
    uint256 public campaignId;

    string public tokenURI;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);
    event NewEndBlock(uint256 endBlock);
    event NewThresholdRound(uint256 thresholdRound);
    event NewNumberPoints(uint256 numberPoints);
    event NewCampaignId(uint256 campaignId);

    constructor(
        address _pancakePrediction,
        address _bunnyMintingStation,
        address _pancakeProfile,
        uint256 _endBlock,
        uint256 _thresholdRound,
        uint256 _numberPoints,
        uint256 _campaignId,
        string memory _tokenURI
    ) public {
        pancakePrediction = BnbPricePrediction(_pancakePrediction);
        bunnyMintingStation = BunnyMintingStation(_bunnyMintingStation);
        pancakeProfile = PancakeProfile(_pancakeProfile);
        endBlock = _endBlock;
        thresholdRound = _thresholdRound;
        numberPoints = _numberPoints;
        campaignId = _campaignId;
        tokenURI = _tokenURI;
    }

    /**
     * @notice Mint a NFT from the BunnyMintingStation contract.
     * @dev Users can claim once. It maps to the teamId.
     */
    function mintNFT() external {
        require(block.number < endBlock, "TOO_LATE");

        // Check that msg.sender has not claimed
        require(!hasClaimed[msg.sender], "ERR_HAS_CLAIMED");

        bool isUserActive;
        (, , , , , isUserActive) = pancakeProfile.getUserProfile(msg.sender);

        // Check that msg.sender has an active profile
        require(isUserActive, "ERR_USER_NOT_ACTIVE");

        bool isUserEligible;
        isUserEligible = _canClaim(msg.sender);

        // Check that msg.sender is eligible
        require(isUserEligible, "ERR_USER_NOT_ELIGIBLE");

        // Update that msg.sender has claimed
        hasClaimed[msg.sender] = true;

        // Mint collectible and send it to the user.
        uint256 tokenId = bunnyMintingStation.mintCollectible(msg.sender, tokenURI, bunnyId);

        // Increase point on PancakeSwap profile, for a given campaignId.
        pancakeProfile.increaseUserPoints(msg.sender, numberPoints, campaignId);

        emit BunnyMint(msg.sender, tokenId, bunnyId);
    }

    /**
     * @notice Change the campaignId for PancakeSwap Profile.
     * @dev Only callable by owner.
     */
    function changeCampaignId(uint256 _campaignId) external onlyOwner {
        campaignId = _campaignId;

        emit NewCampaignId(_campaignId);
    }

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     */
    function changeEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;

        emit NewEndBlock(_endBlock);
    }

    /**
     * @notice Change the number of points for PancakeSwap Profile.
     * @dev Only callable by owner.
     */
    function changeNumberPoints(uint256 _numberPoints) external onlyOwner {
        numberPoints = _numberPoints;

        emit NewNumberPoints(_numberPoints);
    }

    /**
     * @notice Change Round ID (Prediction) threshold
     * @dev Only callable by owner.
     */
    function changeThresholdRound(uint256 _thresholdRound) external onlyOwner {
        thresholdRound = _thresholdRound;

        emit NewThresholdRound(_thresholdRound);
    }

    /**
     * @notice Check if a user can claim.
     */
    function canClaim(address _userAddress) external view returns (bool) {
        return _canClaim(_userAddress);
    }

    /**
     * @notice Check if a user can claim.
     */
    function _canClaim(address _userAddress) internal view returns (bool) {
        if (hasClaimed[_userAddress]) {
            return false;
        } else {
            if (!pancakeProfile.getUserStatus(_userAddress)) {
                return false;
            } else {
                uint256[] memory roundId;
                (roundId, ) = pancakePrediction.getUserRounds(_userAddress, 0, 1);

                if (roundId.length > 0) {
                    if (roundId[0] <= thresholdRound) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "./archive/BunnyFactoryV2.sol";
import "./BunnyMintingStation.sol";

/** @title BunnyFactoryV3.
 * @notice It is a contract for users to mint 'starter NFTs'.
 */
contract BunnyFactoryV3 is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    BunnyFactoryV2 public bunnyFactoryV2;
    BunnyMintingStation public bunnyMintingStation;

    IBEP20 public cakeToken;

    // starting block
    uint256 public startBlockNumber;

    // Number of CAKEs a user needs to pay to acquire a token
    uint256 public tokenPrice;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // IPFS hash for new json
    string private ipfsHash;

    // number of total series (i.e. different visuals)
    uint8 private constant numberBunnyIds = 10;

    // number of previous series (i.e. different visuals)
    uint8 private constant previousNumberBunnyIds = 5;

    // Map the token number to URI
    mapping(uint8 => string) private bunnyIdURIs;

    // Event to notify when NFT is successfully minted
    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);

    /**
     * @dev
     */
    constructor(
        BunnyFactoryV2 _bunnyFactoryV2,
        BunnyMintingStation _bunnyMintingStation,
        IBEP20 _cakeToken,
        uint256 _tokenPrice,
        string memory _ipfsHash,
        uint256 _startBlockNumber
    ) public {
        bunnyFactoryV2 = _bunnyFactoryV2;
        bunnyMintingStation = _bunnyMintingStation;
        cakeToken = _cakeToken;
        tokenPrice = _tokenPrice;
        ipfsHash = _ipfsHash;
        startBlockNumber = _startBlockNumber;
    }

    /**
     * @dev Mint NFTs from the BunnyMintingStation contract.
     * Users can specify what bunnyId they want to mint. Users can claim once.
     */
    function mintNFT(uint8 _bunnyId) external {
        address senderAddress = _msgSender();

        bool hasClaimedV2 = bunnyFactoryV2.hasClaimed(senderAddress);

        // Check if _msgSender() has claimed in previous factory
        require(!hasClaimedV2, "Has claimed in v2");
        // Check _msgSender() has not claimed
        require(!hasClaimed[senderAddress], "Has claimed");
        // Check block time is not too late
        require(block.number > startBlockNumber, "too early");
        // Check that the _bunnyId is within boundary:
        require(_bunnyId >= previousNumberBunnyIds, "bunnyId too low");
        // Check that the _bunnyId is within boundary:
        require(_bunnyId < numberBunnyIds, "bunnyId too high");

        // Update that _msgSender() has claimed
        hasClaimed[senderAddress] = true;

        // Send CAKE tokens to this contract
        cakeToken.safeTransferFrom(senderAddress, address(this), tokenPrice);

        string memory tokenURI = bunnyIdURIs[_bunnyId];

        uint256 tokenId = bunnyMintingStation.mintCollectible(senderAddress, tokenURI, _bunnyId);

        emit BunnyMint(senderAddress, tokenId, _bunnyId);
    }

    /**
     * @dev It transfers the CAKE tokens back to the chef address.
     * Only callable by the owner.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @dev Set up json extensions for bunnies 5-9
     * Assign tokenURI to look for each bunnyId in the mint function
     * Only the owner can set it.
     */
    function setBunnyJson(
        string calldata _bunnyId5Json,
        string calldata _bunnyId6Json,
        string calldata _bunnyId7Json,
        string calldata _bunnyId8Json,
        string calldata _bunnyId9Json
    ) external onlyOwner {
        bunnyIdURIs[5] = string(abi.encodePacked(ipfsHash, _bunnyId5Json));
        bunnyIdURIs[6] = string(abi.encodePacked(ipfsHash, _bunnyId6Json));
        bunnyIdURIs[7] = string(abi.encodePacked(ipfsHash, _bunnyId7Json));
        bunnyIdURIs[8] = string(abi.encodePacked(ipfsHash, _bunnyId8Json));
        bunnyIdURIs[9] = string(abi.encodePacked(ipfsHash, _bunnyId9Json));
    }

    /**
     * @dev Allow to set up the start number
     * Only the owner can set it.
     */
    function setStartBlockNumber(uint256 _newStartBlockNumber) external onlyOwner {
        require(_newStartBlockNumber > block.number, "too short");
        startBlockNumber = _newStartBlockNumber;
    }

    /**
     * @dev Allow to change the token price
     * Only the owner can set it.
     */
    function updateTokenPrice(uint256 _newTokenPrice) external onlyOwner {
        tokenPrice = _newTokenPrice;
    }

    function canMint(address userAddress) external view returns (bool) {
        if ((hasClaimed[userAddress]) || (bunnyFactoryV2.hasClaimed(userAddress))) {
            return false;
        } else {
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "bsc-library/contracts/IBEP20.sol";

import "bsc-library/contracts/SafeBEP20.sol";

import "../PancakeBunnies.sol";

contract BunnyFactoryV2 is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    PancakeBunnies public pancakeBunnies;
    IBEP20 public cakeToken;

    // end block number to get collectibles
    uint256 public endBlockNumber;

    // starting block
    uint256 public startBlockNumber;

    // Number of CAKEs a user needs to pay to acquire a token
    uint256 public tokenPrice;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // IPFS hash for new json
    string private ipfsHash;

    // number of total series (i.e. different visuals)
    uint8 private constant numberBunnyIds = 10;

    // number of previous series (i.e. different visuals)
    uint8 private constant previousNumberBunnyIds = 5;

    // Map the token number to URI
    mapping(uint8 => string) private bunnyIdURIs;

    // Event to notify when NFT is successfully minted
    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);

    /**
     * @dev A maximum number of NFT tokens that is distributed by this contract
     * is defined as totalSupplyDistributed.
     */
    constructor(
        PancakeBunnies _pancakeBunnies,
        IBEP20 _cakeToken,
        uint256 _tokenPrice,
        string memory _ipfsHash,
        uint256 _startBlockNumber,
        uint256 _endBlockNumber
    ) public {
        pancakeBunnies = _pancakeBunnies;
        cakeToken = _cakeToken;
        tokenPrice = _tokenPrice;
        ipfsHash = _ipfsHash;
        startBlockNumber = _startBlockNumber;
        endBlockNumber = _endBlockNumber;
    }

    /**
     * @dev Mint NFTs from the PancakeBunnies contract.
     * Users can specify what bunnyId they want to mint. Users can claim once.
     * There is a limit on how many are distributed. It requires CAKE balance to be > 0.
     */
    function mintNFT(uint8 _bunnyId) external {
        // Check _msgSender() has not claimed
        require(!hasClaimed[_msgSender()], "Has claimed");
        // Check block time is not too late
        require(block.number > startBlockNumber, "too early");
        // Check block time is not too late
        require(block.number < endBlockNumber, "too late");
        // Check that the _bunnyId is within boundary:
        require(_bunnyId >= previousNumberBunnyIds, "bunnyId too low");
        // Check that the _bunnyId is within boundary:
        require(_bunnyId < numberBunnyIds, "bunnyId too high");

        // Update that _msgSender() has claimed
        hasClaimed[_msgSender()] = true;

        // Send CAKE tokens to this contract
        cakeToken.safeTransferFrom(address(_msgSender()), address(this), tokenPrice);

        string memory tokenURI = bunnyIdURIs[_bunnyId];

        uint256 tokenId = pancakeBunnies.mint(address(_msgSender()), tokenURI, _bunnyId);

        emit BunnyMint(_msgSender(), tokenId, _bunnyId);
    }

    /**
     * @dev It transfers the ownership of the NFT contract
     * to a new address.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        pancakeBunnies.transferOwnership(_newOwner);
    }

    /**
     * @dev It transfers the CAKE tokens back to the chef address.
     * Only callable by the owner.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        cakeToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @dev Set up json extensions for bunnies 5-9
     * Assign tokenURI to look for each bunnyId in the mint function
     * Only the owner can set it.
     */
    function setBunnyJson(
        string calldata _bunnyId5Json,
        string calldata _bunnyId6Json,
        string calldata _bunnyId7Json,
        string calldata _bunnyId8Json,
        string calldata _bunnyId9Json
    ) external onlyOwner {
        bunnyIdURIs[5] = string(abi.encodePacked(ipfsHash, _bunnyId5Json));
        bunnyIdURIs[6] = string(abi.encodePacked(ipfsHash, _bunnyId6Json));
        bunnyIdURIs[7] = string(abi.encodePacked(ipfsHash, _bunnyId7Json));
        bunnyIdURIs[8] = string(abi.encodePacked(ipfsHash, _bunnyId8Json));
        bunnyIdURIs[9] = string(abi.encodePacked(ipfsHash, _bunnyId9Json));
    }

    /**
     * @dev Set up names for bunnies 5-9
     * Only the owner can set it.
     */
    function setBunnyNames(
        string calldata _bunnyId5,
        string calldata _bunnyId6,
        string calldata _bunnyId7,
        string calldata _bunnyId8,
        string calldata _bunnyId9
    ) external onlyOwner {
        pancakeBunnies.setBunnyName(5, _bunnyId5);
        pancakeBunnies.setBunnyName(6, _bunnyId6);
        pancakeBunnies.setBunnyName(7, _bunnyId7);
        pancakeBunnies.setBunnyName(8, _bunnyId8);
        pancakeBunnies.setBunnyName(9, _bunnyId9);
    }

    /**
     * @dev Allow to set up the start number
     * Only the owner can set it.
     */
    function setStartBlockNumber(uint256 _newStartBlockNumber) external onlyOwner {
        require(_newStartBlockNumber > block.number, "too short");
        startBlockNumber = _newStartBlockNumber;
    }

    /**
     * @dev Allow to set up the end block number
     * Only the owner can set it.
     */
    function setEndBlockNumber(uint256 _newEndBlockNumber) external onlyOwner {
        require(_newEndBlockNumber > block.number, "too short");
        require(_newEndBlockNumber > startBlockNumber, "must be > startBlockNumber");
        endBlockNumber = _newEndBlockNumber;
    }

    /**
     * @dev Allow to change the token price
     * Only the owner can set it.
     */
    function updateTokenPrice(uint256 _newTokenPrice) external onlyOwner {
        tokenPrice = _newTokenPrice;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "bsc-library/contracts/IBEP20.sol";
import "bsc-library/contracts/SafeBEP20.sol";

import "../PancakeBunnies.sol";

contract BunnyMintingFarm is Ownable {
    using SafeMath for uint8;
    using SafeMath for uint256;

    using SafeBEP20 for IBEP20;

    PancakeBunnies public pancakeBunnies;
    IBEP20 public cakeToken;

    // Map if address can claim a NFT
    mapping(address => bool) public canClaim;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // starting block
    uint256 public startBlockNumber;

    // end block number to claim CAKEs by burning NFT
    uint256 public endBlockNumber;

    // number of total bunnies burnt
    uint256 public countBunniesBurnt;

    // Number of CAKEs a user can collect by burning her NFT
    uint256 public cakePerBurn;

    // current distributed number of NFTs
    uint256 public currentDistributedSupply;

    // number of total NFTs distributed
    uint256 public totalSupplyDistributed;

    // baseURI (on IPFS)
    string private baseURI;

    // Map the token number to URI
    mapping(uint8 => string) private bunnyIdURIs;

    // number of initial series (i.e. different visuals)
    uint8 private numberOfBunnyIds;

    // Event to notify when NFT is successfully minted
    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);

    // Event to notify when NFT is successfully minted
    event BunnyBurn(address indexed from, uint256 indexed tokenId);

    /**
     * @dev A maximum number of NFT tokens that is distributed by this contract
     * is defined as totalSupplyDistributed.
     */
    constructor(
        IBEP20 _cakeToken,
        uint256 _totalSupplyDistributed,
        uint256 _cakePerBurn,
        string memory _baseURI,
        string memory _ipfsHash,
        uint256 _endBlockNumber
    ) public {
        pancakeBunnies = new PancakeBunnies(_baseURI);
        cakeToken = _cakeToken;
        totalSupplyDistributed = _totalSupplyDistributed;
        cakePerBurn = _cakePerBurn;
        baseURI = _baseURI;
        endBlockNumber = _endBlockNumber;

        // Other parameters initialized
        numberOfBunnyIds = 5;

        // Assign tokenURI to look for each bunnyId in the mint function
        bunnyIdURIs[0] = string(abi.encodePacked(_ipfsHash, "swapsies.json"));
        bunnyIdURIs[1] = string(abi.encodePacked(_ipfsHash, "drizzle.json"));
        bunnyIdURIs[2] = string(abi.encodePacked(_ipfsHash, "blueberries.json"));
        bunnyIdURIs[3] = string(abi.encodePacked(_ipfsHash, "circular.json"));
        bunnyIdURIs[4] = string(abi.encodePacked(_ipfsHash, "sparkle.json"));

        // Set token names for each bunnyId
        pancakeBunnies.setBunnyName(0, "Swapsies");
        pancakeBunnies.setBunnyName(1, "Drizzle");
        pancakeBunnies.setBunnyName(2, "Blueberries");
        pancakeBunnies.setBunnyName(3, "Circular");
        pancakeBunnies.setBunnyName(4, "Sparkle");
    }

    /**
     * @dev Mint NFTs from the PancakeBunnies contract.
     * Users can specify what bunnyId they want to mint. Users can claim once.
     * There is a limit on how many are distributed. It requires CAKE balance to be >0.
     */
    function mintNFT(uint8 _bunnyId) external {
        // Check msg.sender can claim
        require(canClaim[msg.sender], "Cannot claim");
        // Check msg.sender has not claimed
        require(hasClaimed[msg.sender] == false, "Has claimed");
        // Check whether it is still possible to mint
        require(currentDistributedSupply < totalSupplyDistributed, "Nothing left");
        // Check whether user owns any CAKE
        require(cakeToken.balanceOf(msg.sender) > 0, "Must own CAKE");
        // Check that the _bunnyId is within boundary:
        require(_bunnyId < numberOfBunnyIds, "bunnyId unavailable");
        // Update that msg.sender has claimed
        hasClaimed[msg.sender] = true;

        // Update the currentDistributedSupply by 1
        currentDistributedSupply = currentDistributedSupply.add(1);

        string memory tokenURI = bunnyIdURIs[_bunnyId];

        uint256 tokenId = pancakeBunnies.mint(address(msg.sender), tokenURI, _bunnyId);

        emit BunnyMint(msg.sender, tokenId, _bunnyId);
    }

    /**
     * @dev Burn NFT from the PancakeBunnies contract.
     * Users can burn their NFT to get a set number of CAKE.
     * There is a cap on how many can be distributed for free.
     */
    function burnNFT(uint256 _tokenId) external {
        require(pancakeBunnies.ownerOf(_tokenId) == msg.sender, "Not the owner");
        require(block.number < endBlockNumber, "too late");

        pancakeBunnies.burn(_tokenId);
        countBunniesBurnt = countBunniesBurnt.add(1);
        cakeToken.safeTransfer(address(msg.sender), cakePerBurn);
        emit BunnyBurn(msg.sender, _tokenId);
    }

    /**
     * @dev Allow to set up the start number
     * Only the owner can set it.
     */
    function setStartBlockNumber() external onlyOwner {
        startBlockNumber = block.number;
    }

    /**
     * @dev Allow the contract owner to whitelist addresses.
     * Only these addresses can claim.
     */
    function whitelistAddresses(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            canClaim[users[i]] = true;
        }
    }

    /**
     * @dev It transfers the CAKE tokens back to the chef address.
     * Only callable by the owner.
     */
    function withdrawCake(uint256 _amount) external onlyOwner {
        require(block.number >= endBlockNumber, "too early");
        cakeToken.safeTransfer(address(msg.sender), _amount);
    }

    /**
     * @dev It transfers the ownership of the NFT contract
     * to a new address.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        pancakeBunnies.transferOwnership(_newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/IFO.sol";
import "./interfaces/IPancakeProfile.sol";

/** @title PointCenterIFO.
 * @notice It is a contract for users to collect points
 * for IFOs they participated in.
 */
contract PointCenterIFO is Ownable {
    IPancakeProfile pancakeProfile;

    uint256 public maxViewLength;

    mapping(address => IFOs) public ifos;
    mapping(address => mapping(address => bool)) private _users;

    event IFOAdd(
        address indexed contractAddress,
        uint256 thresholdToClaim,
        uint256 indexed campaignId,
        uint256 numberPoints
    );

    struct IFOs {
        uint256 thresholdToClaim;
        uint256 campaignId;
        uint256 numberPoints;
    }

    constructor(address _pancakeProfileAddress, uint256 _maxViewLength) public {
        pancakeProfile = IPancakeProfile(_pancakeProfileAddress);
        maxViewLength = _maxViewLength;
    }

    function getPoints(address _contractAddress) external {
        address senderAddress = _msgSender();

        // 1. Check if IFO is valid
        require((ifos[_contractAddress].campaignId > 0) && (ifos[_contractAddress].numberPoints > 0), "not valid");

        // 2. Check if he has claimed
        require(!_users[senderAddress][_contractAddress], "has claimed for this IFO");

        // 3. Check if he is active
        bool isUserActive = pancakeProfile.getUserStatus(senderAddress);
        require(isUserActive, "not active");

        // 4. Check if he can claim
        IFO currentIfo = IFO(_contractAddress);

        uint256 amountUser;
        bool hasUserClaimed;

        // Read user info
        (amountUser, hasUserClaimed) = currentIfo.userInfo(senderAddress);

        require(hasUserClaimed, "has not claimed");
        require(amountUser > ifos[_contractAddress].thresholdToClaim, "too small");

        // 5. Update the status
        _users[senderAddress][_contractAddress] = true;

        // 6. Increase user points of sender
        pancakeProfile.increaseUserPoints(
            senderAddress,
            ifos[_contractAddress].numberPoints,
            ifos[_contractAddress].campaignId
        );
    }

    function addIFOAddress(
        address _contractAddress,
        uint256 _thresholdToClaim,
        uint256 _campaignId,
        uint256 _numberPoints
    ) external onlyOwner {
        // Add data to the struct for ifos
        ifos[_contractAddress] = IFOs({
            thresholdToClaim: _thresholdToClaim,
            campaignId: _campaignId,
            numberPoints: _numberPoints
        });

        emit IFOAdd(_contractAddress, _thresholdToClaim, _campaignId, _numberPoints);
    }

    function updateMaxViewLength(uint256 _newMaxViewLength) external onlyOwner {
        maxViewLength = _newMaxViewLength;
    }

    function checkClaimStatus(address _userAddress, address _contractAddress) external view returns (bool) {
        bool status = _checkClaimStatus(_userAddress, _contractAddress);
        return status;
    }

    function checkClaimStatuses(address _userAddress, address[] memory _contractAddresses)
        external
        view
        returns (bool[] memory)
    {
        bool[] memory responses = new bool[](_contractAddresses.length);

        require(_contractAddresses.length <= maxViewLength, "Length must be <= maxViewLength");

        for (uint256 i = 0; i < _contractAddresses.length; i++) {
            bool status = _checkClaimStatus(_userAddress, _contractAddresses[i]);
            responses[i] = status;
        }

        return responses;
    }

    function _checkClaimStatus(address _userAddress, address _contractAddress) private view returns (bool) {
        IFO currentIfo = IFO(_contractAddress);

        uint256 amountUser;
        bool hasUserClaimed;

        // read user info
        (amountUser, hasUserClaimed) = currentIfo.userInfo(_userAddress);

        if ((!hasUserClaimed) || (amountUser < ifos[_contractAddress].thresholdToClaim)) {
            // 1. Check if user has claimed funds from IFO AND match threshold
            return false;
        } else if (_users[_userAddress][_contractAddress]) {
            // 2. Check if user has already claimed points for this IFO
            return false;
        } else if (
            // 3. Check if a campaignId AND numberPoints were set
            (ifos[_contractAddress].campaignId < 1) || (ifos[_contractAddress].numberPoints < 1)
        ) {
            return false;
        } else {
            // 4. Can claim
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BunnyMintingStation} from "./BunnyMintingStation.sol";

/**
 * @title BunnySpecialAdmin.
 * @notice It is a contract for community admins to claim a special bunny.
 */
contract BunnySpecialAdmin is Ownable {
    BunnyMintingStation public bunnyMintingStation;

    uint8 public constant bunnyId = 21;

    uint256 public endBlock;

    string public tokenURI;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // Map if address can claim NFT
    mapping(address => bool) private _canClaim;

    event BunnyMint(address indexed to, uint256 indexed tokenId, uint8 indexed bunnyId);
    event NewAddressesWhitelisted(address[] users);
    event NewAddressesUnwhitelisted(address[] users);
    event NewEndBlock(uint256 endBlock);

    /**
     * @notice Constructor
     * @param _bunnyMintingStation: address of the bunny minting station
     * @param _endBlock: end block for claiming
     * @param _tokenURI: tokenURI (string)
     */
    constructor(
        address _bunnyMintingStation,
        uint256 _endBlock,
        string memory _tokenURI
    ) public {
        bunnyMintingStation = BunnyMintingStation(_bunnyMintingStation);
        endBlock = _endBlock;
        tokenURI = _tokenURI;
    }

    /**
     * @notice Mint a NFT from the BunnyMintingStation contract.
     * @dev Users can claim once.
     */
    function mintNFT() external {
        require(block.number < endBlock, "Claim: Too late");

        // Check msg.sender has not claimed
        require(!hasClaimed[msg.sender], "Claim: Already claimed");

        require(_canClaim[msg.sender], "Claim: Not eligible");

        // Update that msg.sender has claimed
        hasClaimed[msg.sender] = true;

        // Mint collectible and send it to the user.
        uint256 tokenId = bunnyMintingStation.mintCollectible(msg.sender, tokenURI, bunnyId);

        emit BunnyMint(msg.sender, tokenId, bunnyId);
    }

    /**
     * @notice Change end block for distribution
     * @dev Only callable by owner.
     * @param _endBlock: end block for claiming
     */
    function changeEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;

        emit NewEndBlock(_endBlock);
    }

    /**
     * @notice Whitelist a list of addresses. Whitelisted addresses can claim the NFT.
     * @dev Only callable by owner.
     * @param _users: list of user addresses
     */
    function whitelistAddresses(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            _canClaim[_users[i]] = true;
        }

        emit NewAddressesWhitelisted(_users);
    }

    /**
     * @notice Unwhitelist a list of addresses.
     * @dev Only callable by owner.
     * @param _users: list of user addresses
     */
    function unwhitelistAddresses(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            _canClaim[_users[i]] = false;
        }

        emit NewAddressesUnwhitelisted(_users);
    }

    /**
     * @notice Return whether a user can claim
     * @param user: user address
     */
    function canClaim(address user) external view returns (bool) {
        return (!hasClaimed[user]) && (_canClaim[user]) && (block.number < endBlock);
    }
}