// contracts/XWorldDCEquipMysteryBox.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Seriality/Seriality_1_0/SerialityUtility.sol";
import "../Seriality/Seriality_1_0/SerialityBuffer.sol";

import "../MysteryBoxes/XWorldMBRandomSourceBase.sol";
import "../MysteryBoxes/XWorldMysteryBoxBase.sol";
import "../MysteryBoxes/XWorldMysteryBoxShop.sol";
import "../MysteryBoxes/XWorldDirectMysteryBox.sol";

import "./XWorldDCEquip.sol";
import "./XWorldDCEquip1155.sol";

// ----------------------------------------------------------------------------
// mb random source & content minter v1
// ----------------------------------------------------------------------------
contract XWorldDCEquipMBStruct {
    using SerialityBuffer for SerialityBuffer.Buffer;

    struct DCEquipMBData {
        uint8 equip;
        uint8 role;
        uint8 grade;
        uint256 __end; // take position, not used
    }

    function _writeDCEquipMBData(DCEquipMBData memory mbdata)
        internal
        pure
        returns (bytes memory bytesdata)
    {
        // encode

        uint32 size = 1 + 1 + 1 + 32; // uint8 + uint8 + uint8 + uint256
        bytes memory buf = new bytes(size);

        SerialityBuffer.Buffer memory coder = SerialityBuffer.Buffer({
            index: size,
            buffer: buf
        });

        coder.writeUint8(mbdata.equip);
        coder.writeUint8(mbdata.role);
        coder.writeUint8(mbdata.grade);
        coder.writeUint256(mbdata.__end);

        return coder.getBuffer();
    }

    function _readDCEquipMBData(bytes memory bytesdata)
        internal
        pure
        returns (DCEquipMBData memory mbdata)
    {
        // decode

        SerialityBuffer.Buffer memory coder = SerialityBuffer.Buffer({
            index: bytesdata.length,
            buffer: bytesdata
        });

        mbdata.equip = coder.readUint8();
        mbdata.role = coder.readUint8();
        mbdata.grade = coder.readUint8();
        //mbdata.__end = coder.readUint256();

        return mbdata;
    }
}

contract XWorldDCEquipMBRandomSource is
    XWorldMBRandomSourceBase,
    XWorldDCEquipMBStruct
{
    using XWorldRandomPool for XWorldRandomPool.RandomPool;

    constructor() XWorldMBRandomSourceBase() {}

    function randomNFTData(uint256 r, uint32 mbTypeID)
        external
        view
        override
        returns (bytes memory structDatas)
    {
        uint32[] storage poolIDArray = _mbRandomSets[mbTypeID];

        require(poolIDArray.length == 3, "mb type config wrong");

        NFTRandPool storage equipPool = _randPools[poolIDArray[0]]; // index 0 : equip pool
        require(equipPool.exist, "equip pool not exist");

        NFTRandPool storage rolePool = _randPools[poolIDArray[1]]; // index 1 : role pool
        require(rolePool.exist, "role pool not exist");

        NFTRandPool storage gradePool = _randPools[poolIDArray[2]]; // index 2 : grade pool
        require(gradePool.exist, "grade pool not exist");

        uint32 index = 0;
        DCEquipMBData memory mbdata;

        //r = _rand.nextRand(++index, r);
        mbdata.equip = uint8(equipPool.randPool.random(r)); // rand equip

        r = _rand.nextRand(++index, r);
        mbdata.role = uint8(rolePool.randPool.random(r)); // rand role

        r = _rand.nextRand(++index, r);
        mbdata.grade = uint8(gradePool.randPool.random(r)); // rand grade

        return _writeDCEquipMBData(mbdata);
    }
}

contract XWorldDCEquipMBContentMinter is
    Context,
    AccessControl,
    XWorldDCEquipMBStruct,
    XWorldDCEquipStruct,
    IXWorldMysteryBoxContentMinter
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    XWorldDCEquip public _equipNFTContract;

    constructor(address nftAddr) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());

        _equipNFTContract = XWorldDCEquip(nftAddr);
    }

    function mintContentAssets(
        address userAddr,
        uint256 mbTokenId,
        bytes memory nftDatas
    ) external override returns (uint256 tokenId) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "XWorldDCEquipMBContentMinter: must have minter role to mint"
        );

        mbTokenId; // not used

        DCEquipMBData memory mbdata = _readDCEquipMBData(nftDatas);

        EquipData memory eqpdata = EquipData({
            equip: mbdata.equip,
            role: mbdata.role,
            grade: mbdata.grade,
            level: 1,
            exp: 0
        });

        return _equipNFTContract.mint(userAddr, eqpdata);
    }
}

// ----------------------------------------------------------------------------
// mb random source & content minter v2
// ----------------------------------------------------------------------------

contract XWorldDCEquipMBStruct_V2 {
    using SerialityBuffer for SerialityBuffer.Buffer;

    struct DCEquipNFTData {
        uint8 equip;
        uint8 role;
        uint8 grade;
    }
    struct DCEquip1155Data {
        uint8 id;
        uint8 value;
    }

    struct DCEquipMBBatchDatas {
        DCEquipNFTData[] equipNfts;
        DCEquip1155Data[] equip1155s;
    }

    function _writeDCEquipMBData(DCEquipMBBatchDatas memory mbdata)
        internal
        pure
        returns (bytes memory bytesdata)
    {
        // encode

        require(
            mbdata.equipNfts.length < 256 && mbdata.equip1155s.length < 256,
            "__en1"
        );

        uint32 size = uint32(
            1 +
                3 *
                mbdata.equipNfts.length +
                1 +
                2 *
                mbdata.equip1155s.length +
                32
        ); // calc size
        bytes memory buf = new bytes(size);

        SerialityBuffer.Buffer memory coder = SerialityBuffer.Buffer({
            index: size,
            buffer: buf
        });

        coder.writeUint8(uint8(mbdata.equipNfts.length));
        for (uint256 i = 0; i < mbdata.equipNfts.length; ++i) {
            coder.writeUint8(mbdata.equipNfts[i].equip);
            coder.writeUint8(mbdata.equipNfts[i].role);
            coder.writeUint8(mbdata.equipNfts[i].grade);
        }

        coder.writeUint8(uint8(mbdata.equip1155s.length));
        for (uint256 i = 0; i < mbdata.equip1155s.length; ++i) {
            coder.writeUint8(mbdata.equip1155s[i].id);
            coder.writeUint8(mbdata.equip1155s[i].value);
        }

        coder.writeUint256(0); // __end

        return coder.getBuffer();
    }

    function _readDCEquipMBData(bytes memory bytesdata)
        internal
        pure
        returns (DCEquipMBBatchDatas memory mbdata)
    {
        // decode

        SerialityBuffer.Buffer memory coder = SerialityBuffer.Buffer({
            index: bytesdata.length,
            buffer: bytesdata
        });

        uint8 equipCount = coder.readUint8();
        
        mbdata.equipNfts = new DCEquipNFTData[](equipCount);

        for (uint256 i = 0; i < mbdata.equipNfts.length; ++i) {
            mbdata.equipNfts[i].equip = coder.readUint8();
            mbdata.equipNfts[i].role = coder.readUint8();
            mbdata.equipNfts[i].grade = coder.readUint8();
        }

        uint8 equip1155Count = coder.readUint8();
       
        mbdata.equip1155s = new DCEquip1155Data[](equip1155Count);

        for (uint256 i = 0; i < mbdata.equip1155s.length; ++i) {
            mbdata.equip1155s[i].id = coder.readUint8();
            mbdata.equip1155s[i].value = coder.readUint8();
        }
        //mbdata.__end = coder.readUint256();

        return mbdata;
    }
}

contract XWorldDCEquipMBRandomSource_V2 is
    XWorldMBRandomSourceBase_V2,
    XWorldDCEquipMBStruct_V2
{
    using XWorldRandomPool for XWorldRandomPool.RandomPool;

    constructor() XWorldMBRandomSourceBase_V2() {}

    function randomNFTData(uint256 r, uint32 mbTypeID)
        external
        view
        override
        returns (bytes memory structDatas)
    {
        uint32[] storage poolIDArray = _mbRandomSets[mbTypeID];

        require(poolIDArray.length == 3, "mb type config wrong");

        NFTRandPool storage equipPool = _randPools[poolIDArray[0]]; // index 0 : equip pool
        require(equipPool.exist, "equip pool not exist");

        NFTRandPool storage rolePool = _randPools[poolIDArray[1]]; // index 1 : role pool
        require(rolePool.exist, "role pool not exist");

        NFTRandPool storage gradePool = _randPools[poolIDArray[2]]; // index 2 : grade pool
        require(gradePool.exist, "grade pool not exist");

        uint32 index = 0;
        DCEquipMBBatchDatas memory mbdata;

        //r = _rand.nextRand(++index, r);
        uint8 grade = uint8(gradePool.randPool.random(r)); // rand grade

        if (grade == 1) {
            // give equip pieces
            mbdata.equip1155s = new DCEquip1155Data[](1);
            mbdata.equip1155s[0] = DCEquip1155Data({id: 1, value: 1});
        } else {
            // give equip nft
            r = _rand.nextRand(++index, r);
            uint8 equip = uint8(equipPool.randPool.random(r)); // rand equip

            r = _rand.nextRand(++index, r);
            uint8 role = uint8(rolePool.randPool.random(r)); // rand role

            mbdata.equipNfts = new DCEquipNFTData[](1);
            mbdata.equipNfts[0] = DCEquipNFTData({
                equip: equip,
                role: role,
                grade: grade
            });
        }

        return _writeDCEquipMBData(mbdata);
    }

    function batchRandomNFTData(
        uint256 r,
        uint32 mbTypeID,
        uint8 batchCount
    ) external view override returns (bytes memory structDatas) {
        uint32[] storage poolIDArray = _mbRandomSets[mbTypeID];

        require(poolIDArray.length == 3, "mb type config wrong");

        NFTRandPool storage equipPool = _randPools[poolIDArray[0]]; // index 0 : equip pool
        require(equipPool.exist, "equip pool not exist");

        NFTRandPool storage rolePool = _randPools[poolIDArray[1]]; // index 1 : role pool
        require(rolePool.exist, "role pool not exist");

        NFTRandPool storage gradePool = _randPools[poolIDArray[2]]; // index 2 : grade pool
        require(gradePool.exist, "grade pool not exist");

        uint32 index = 0;
        DCEquipMBBatchDatas memory mbdata;

        // uint8 equipNftIndex = 0;

        uint8 nftcount = uint8(gradePool.randPool.random(r)) % batchCount;
        if (batchCount - nftcount > 0) {
            mbdata.equip1155s = new DCEquip1155Data[](1);
            mbdata.equip1155s[0] = DCEquip1155Data({
                id: 1,
                value: batchCount - nftcount
            });
        }
        if (nftcount > 0) {
            mbdata.equipNfts = new DCEquipNFTData[](nftcount);
            for (uint8 i = 0; i < nftcount; ++i) {
                mbdata.equipNfts[i] = DCEquipNFTData({
                    equip: 0,
                    role: 0,
                    grade: 0
                });
                r = _rand.nextRand(++index, r);
                mbdata.equipNfts[i].equip = uint8(equipPool.randPool.random(r)); // rand equip

                r = _rand.nextRand(++index, r);
                mbdata.equipNfts[i].role = uint8(rolePool.randPool.random(r)); // rand role
            }
        }
        // for (uint8 i = 0; i < batchCount; ++i) {
        //     r = _rand.nextRand(++index, r);
        //     uint8 grade = uint8(gradePool.randPool.random(r)); // rand grade

        //     if (grade == 1) {
        //         // give equip pieces
        //         if (mbdata.equip1155s.length <= 0) {
        //             mbdata.equip1155s[0] = DCEquip1155Data({id: 1, value: 1});
        //             // mbdata.equip1155s[0].id = 1;
        //             // mbdata.equip1155s[0].value = 1;
        //         } else {
        //             mbdata.equip1155s[0].value++;
        //         }
        //     } else {
        //         // give equip nft

        //         //mbdata.equipNfts[equipNftIndex].grade = grade;

        //         r = _rand.nextRand(++index, r);
        //         mbdata.equipNfts[equipNftIndex].equip = uint8(
        //             equipPool.randPool.random(r)
        //         ); // rand equip

        //         r = _rand.nextRand(++index, r);
        //         mbdata.equipNfts[equipNftIndex].role = uint8(
        //             rolePool.randPool.random(r)
        //         ); // rand role

        //         ++equipNftIndex;
        //     }
        // }

        return _writeDCEquipMBData(mbdata);
    }
}

contract XWorldDCEquipMBContentMinter_V2 is
    Context,
    AccessControl,
    XWorldDCEquipMBStruct_V2,
    XWorldDCEquipStruct,
    IXWorldMysteryBoxContentMinter_V2
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    XWorldDCEquip public _equipNFTContract;
    XWorldDCEquip1155 public _equip1155Contract;

    constructor(address nftAddr, address eqp1155Addr) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());

        _equipNFTContract = XWorldDCEquip(nftAddr);
        _equip1155Contract = XWorldDCEquip1155(eqp1155Addr);
    }

    function mintContentAssets(
        address userAddr,
        uint256 mbTokenId,
        bytes memory nftDatas
    ) external override returns (uint256 tokenId) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "XWorldDCEquipMBContentMinter_V2: must have minter role to mint"
        );

        mbTokenId; // not used

        DCEquipMBBatchDatas memory mbdata = _readDCEquipMBData(nftDatas);
        require(
            mbdata.equipNfts.length > 0 || mbdata.equip1155s.length > 0,
            "XWorldDCEquipMBContentMinter_V2: data empty"
        );

        if (mbdata.equipNfts.length > 0) {
            EquipData memory eqpdata = EquipData({
                equip: mbdata.equipNfts[0].equip,
                role: mbdata.equipNfts[0].role,
                grade: mbdata.equipNfts[0].grade,
                level: 1,
                exp: 0
            });

            return _equipNFTContract.mint(userAddr, eqpdata);
        }

        if (mbdata.equip1155s.length > 0) {
            _equip1155Contract.mint(
                userAddr,
                mbdata.equip1155s[0].id,
                mbdata.equip1155s[0].value,
                abi.encodePacked("mbmint")
            );
            return mbdata.equip1155s[0].id;
        }
    }

    function batchMintContentAssets(
        address userAddr,
        uint256 mbTokenId,
        uint8 batchCount,
        bytes memory nftDatas
    )
        external
        override
        returns (uint256[] memory tokenIds, uint256[] memory tokenValues)
    {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "XWorldDCEquipMBContentMinter_V2: must have minter role to mint"
        );

        mbTokenId; // not used

        DCEquipMBBatchDatas memory mbdata = _readDCEquipMBData(nftDatas);
        require(
            mbdata.equipNfts.length + mbdata.equip1155s.length <= batchCount,
            "XWorldDCEquipMBContentMinter_V2: data length wrong"
        );

        uint8 size = uint8(mbdata.equipNfts.length + mbdata.equip1155s.length);
        tokenIds = new uint256[](size);
        tokenValues = new uint256[](size);
        uint256 i = 0;
        for (; i < mbdata.equipNfts.length; ++i) {
            EquipData memory eqpdata = EquipData({
                equip: mbdata.equipNfts[i].equip,
                role: mbdata.equipNfts[i].role,
                grade: mbdata.equipNfts[i].grade,
                level: 1,
                exp: 0
            });

            tokenIds[i] = _equipNFTContract.mint(userAddr, eqpdata);
            tokenValues[i] = 0;
        }

        for (uint256 j = 0; j < mbdata.equip1155s.length; ++j) {
            _equip1155Contract.mint(
                userAddr,
                mbdata.equip1155s[j].id,
                mbdata.equip1155s[j].value,
                abi.encodePacked("mbbatchmint")
            );
            tokenIds[i + j] = mbdata.equip1155s[j].id;
            tokenValues[i + j] = mbdata.equip1155s[j].value;
        }
    }
}

// ----------------------------------------------------------------------------
// nft mb
// ----------------------------------------------------------------------------
contract XWorldDCEquipMBMinter is Context, AccessControl, IMysterBoxNFTMinter {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    XWorldMysteryBoxNFT public _nftContract;

    constructor(address nftAddr) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());

        _nftContract = XWorldMysteryBoxNFT(nftAddr);
    }

    function mintNFT(
        address to,
        uint32 mysteryBoxType,
        uint32 mysteryBoxTypeId
    ) external override returns (uint256 nftID) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "XWorldAvatarMBMinter: must have minter role to mint"
        );

        return _nftContract.mint(to, mysteryBoxType, mysteryBoxTypeId);
    }

    function batchMintNFT(
        address to,
        uint32 mysteryBoxType,
        uint32 mysteryBoxTypeId,
        uint32 count
    ) external override returns (uint256[] memory nftID) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "XWorldAvatarMBMinter: must have minter role to mint"
        );

        XWorldMysteryBoxNFTMintOption[]
            memory ops = new XWorldMysteryBoxNFTMintOption[](count);
        for (uint256 i = 0; i < count; ++i) {
            ops[i] = XWorldMysteryBoxNFTMintOption({
                to: to,
                mbType: mysteryBoxType,
                mbTypeId: mysteryBoxTypeId
            });
        }
        return _nftContract.batchMint(ops);
    }
}

contract XWorldDCEquipMBOpen is XWorldMysteryBoxBase {
    function getName() public pure override returns (string memory) {
        return "Dream Card Equip Mystery Box Open Contract";
    }
}

contract XWorldDCEquipMBOpen_V2 is XWorldMysteryBoxBase_V2 {
    function getName() public pure override returns (string memory) {
        return "Dream Card Equip Mystery Box Open Contract";
    }
}

contract XWorldDCEquipMBOpen_V3 is XWorldMysteryBoxBase_V3 {
    function getName() public pure override returns (string memory) {
        return "Dream Card Equip Mystery Box Open Contract";
    }
}

// ----------------------------------------------------------------------------
// direct mb
// ----------------------------------------------------------------------------
contract XWorldDCEquipDirectMB is XWorldDirectMysteryBox {
    function getName() public pure override returns (string memory) {
        return "Dream Card Equip Direct Mystery Box Contract";
    }
}

contract XWorldDCEquipDirectMB_V2 is XWorldDirectMysteryBox_V2 {
    function getName() public pure override returns (string memory) {
        return "Dream Card Equip Direct Mystery Box Contract";
    }
}

contract XWorldDCEquipDirectMB_V3 is XWorldDirectMysteryBox_V3 {
    function getName() public pure override returns (string memory) {
        return "Dream Card Equip Direct Mystery Box Contract";
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
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
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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
pragma solidity ^0.8.0;

library SerialityUtility {

    // size of
    
    function sizeOfString(string memory _in) internal pure  returns(uint _size){
        _size = bytes(_in).length / 32;
         if(bytes(_in).length % 32 != 0) 
            _size++;
            
        _size++; // first 32 bytes is reserved for the size of the string     
        _size *= 32;
    }

    // function sizeOfInt(uint16 _postfix) internal pure  returns(uint size){

    //     assembly{
    //         switch _postfix
    //             case 8 { size := 1 }
    //             case 16 { size := 2 }
    //             case 24 { size := 3 }
    //             case 32 { size := 4 }
    //             case 40 { size := 5 }
    //             case 48 { size := 6 }
    //             case 56 { size := 7 }
    //             case 64 { size := 8 }
    //             case 72 { size := 9 }
    //             case 80 { size := 10 }
    //             case 88 { size := 11 }
    //             case 96 { size := 12 }
    //             case 104 { size := 13 }
    //             case 112 { size := 14 }
    //             case 120 { size := 15 }
    //             case 128 { size := 16 }
    //             case 136 { size := 17 }
    //             case 144 { size := 18 }
    //             case 152 { size := 19 }
    //             case 160 { size := 20 }
    //             case 168 { size := 21 }
    //             case 176 { size := 22 }
    //             case 184 { size := 23 }
    //             case 192 { size := 24 }
    //             case 200 { size := 25 }
    //             case 208 { size := 26 }
    //             case 216 { size := 27 }
    //             case 224 { size := 28 }
    //             case 232 { size := 29 }
    //             case 240 { size := 30 }
    //             case 248 { size := 31 }
    //             case 256 { size := 32 }
    //             default  { size := 32 }
    //     }

    // }
    
    // function sizeOfUint(uint16 _postfix) internal pure  returns(uint size){
    //     return sizeOfInt(_postfix);
    // }

    function sizeOfInt8() internal pure  returns(uint size){
        return 1;
    }
    function sizeOfInt16() internal pure  returns(uint size){
        return 2;
    }
    function sizeOfInt24() internal pure  returns(uint size){
        return 3;
    }
    function sizeOfInt32() internal pure  returns(uint size){
        return 4;
    }
    // function sizeOfInt40() internal pure  returns(uint size){
    //     return 5;
    // }
    // function sizeOfInt48() internal pure  returns(uint size){
    //     return 6;
    // }
    // function sizeOfInt56() internal pure  returns(uint size){
    //     return 7;
    // }
    function sizeOfInt64() internal pure  returns(uint size){
        return 8;
    }
    // function sizeOfInt72() internal pure  returns(uint size){
    //     return 9;
    // }
    // function sizeOfInt80() internal pure  returns(uint size){
    //     return 10;
    // }
    // function sizeOfInt88() internal pure  returns(uint size){
    //     return 11;
    // }
    // function sizeOfInt96() internal pure  returns(uint size){
    //     return 12;
    // }
    // function sizeOfInt104() internal pure  returns(uint size){
    //     return 13;
    // }
    // function sizeOfInt112() internal pure  returns(uint size){
    //     return 14;
    // }
    // function sizeOfInt120() internal pure  returns(uint size){
    //     return 15;
    // }
    function sizeOfInt128() internal pure  returns(uint size){
        return 16;
    }
    // function sizeOfInt136() internal pure  returns(uint size){
    //     return 17;
    // }
    // function sizeOfInt144() internal pure  returns(uint size){
    //     return 18;
    // }
    // function sizeOfInt152() internal pure  returns(uint size){
    //     return 19;
    // }
    // function sizeOfInt160() internal pure  returns(uint size){
    //     return 20;
    // }
    // function sizeOfInt168() internal pure  returns(uint size){
    //     return 21;
    // }
    // function sizeOfInt176() internal pure  returns(uint size){
    //     return 22;
    // }
    // function sizeOfInt184() internal pure  returns(uint size){
    //     return 23;
    // }
    // function sizeOfInt192() internal pure  returns(uint size){
    //     return 24;
    // }
    // function sizeOfInt200() internal pure  returns(uint size){
    //     return 25;
    // }
    // function sizeOfInt208() internal pure  returns(uint size){
    //     return 26;
    // }
    // function sizeOfInt216() internal pure  returns(uint size){
    //     return 27;
    // }
    // function sizeOfInt224() internal pure  returns(uint size){
    //     return 28;
    // }
    // function sizeOfInt232() internal pure  returns(uint size){
    //     return 29;
    // }
    // function sizeOfInt240() internal pure  returns(uint size){
    //     return 30;
    // }
    // function sizeOfInt248() internal pure  returns(uint size){
    //     return 31;
    // }
    function sizeOfInt256() internal pure  returns(uint size){
        return 32;
    }
    
    function sizeOfUint8() internal pure  returns(uint size){
        return 1;
    }
    function sizeOfUint16() internal pure  returns(uint size){
        return 2;
    }
    function sizeOfUint24() internal pure  returns(uint size){
        return 3;
    }
    function sizeOfUint32() internal pure  returns(uint size){
        return 4;
    }
    // function sizeOfUint40() internal pure  returns(uint size){
    //     return 5;
    // }
    // function sizeOfUint48() internal pure  returns(uint size){
    //     return 6;
    // }
    // function sizeOfUint56() internal pure  returns(uint size){
    //     return 7;
    // }
    function sizeOfUint64() internal pure  returns(uint size){
        return 8;
    }
    // function sizeOfUint72() internal pure  returns(uint size){
    //     return 9;
    // }
    // function sizeOfUint80() internal pure  returns(uint size){
    //     return 10;
    // }
    // function sizeOfUint88() internal pure  returns(uint size){
    //     return 11;
    // }
    // function sizeOfUint96() internal pure  returns(uint size){
    //     return 12;
    // }
    // function sizeOfUint104() internal pure  returns(uint size){
    //     return 13;
    // }
    // function sizeOfUint112() internal pure  returns(uint size){
    //     return 14;
    // }
    // function sizeOfUint120() internal pure  returns(uint size){
    //     return 15;
    // }
    function sizeOfUint128() internal pure  returns(uint size){
        return 16;
    }
    // function sizeOfUint136() internal pure  returns(uint size){
    //     return 17;
    // }
    // function sizeOfUint144() internal pure  returns(uint size){
    //     return 18;
    // }
    // function sizeOfUint152() internal pure  returns(uint size){
    //     return 19;
    // }
    // function sizeOfUint160() internal pure  returns(uint size){
    //     return 20;
    // }
    // function sizeOfUint168() internal pure  returns(uint size){
    //     return 21;
    // }
    // function sizeOfUint176() internal pure  returns(uint size){
    //     return 22;
    // }
    // function sizeOfUint184() internal pure  returns(uint size){
    //     return 23;
    // }
    // function sizeOfUint192() internal pure  returns(uint size){
    //     return 24;
    // }
    // function sizeOfUint200() internal pure  returns(uint size){
    //     return 25;
    // }
    // function sizeOfUint208() internal pure  returns(uint size){
    //     return 26;
    // }
    // function sizeOfUint216() internal pure  returns(uint size){
    //     return 27;
    // }
    // function sizeOfUint224() internal pure  returns(uint size){
    //     return 28;
    // }
    // function sizeOfUint232() internal pure  returns(uint size){
    //     return 29;
    // }
    // function sizeOfUint240() internal pure  returns(uint size){
    //     return 30;
    // }
    // function sizeOfUint248() internal pure  returns(uint size){
    //     return 31;
    // }
    function sizeOfUint256() internal pure  returns(uint size){
        return 32;
    }

    function sizeOfAddress() internal pure  returns(uint8){
        return 20; 
    }
    
    function sizeOfBool() internal pure  returns(uint8){
        return 1; 
    }
    
    // to bytes
    
    function addressToBytes(uint _offst, address _input, bytes memory _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
        }
    }

    function bytes32ToBytes(uint _offst, bytes32 _input, bytes memory _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
            mstore(add(add(_output, _offst),32), add(_input,32))
        }
    }
    
    function boolToBytes(uint _offst, bool _input, bytes memory _output) internal pure {
        uint8 x = _input == false ? 0 : 1;
        assembly {
            mstore8(add(_output, _offst), x)
        }
    }
    
    function stringToBytes(uint _offst, bytes memory _input, bytes memory _output) internal pure {
        uint256 stack_size = _input.length / 32;
        if(_input.length % 32 > 0) stack_size++;
        
        assembly {
            stack_size := add(stack_size,1)//adding because of 32 first bytes memory as the length
            for { let index := 0 } lt(index,stack_size){ index := add(index ,1) } {
                mstore(add(_output, _offst), mload(add(_input,mul(index,32))))
                _offst := sub(_offst , 32)
            }
        }
    }

    function intToBytes(uint _offst, int _input, bytes memory  _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
        }
    } 
    
    function uintToBytes(uint _offst, uint _input, bytes memory _output) internal pure {

        assembly {
            mstore(add(_output, _offst), _input)
        }
    }   

    // bytes to

    function bytesToAddress(uint _offst, bytes memory _input) internal pure returns (address _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
    function bytesToBool(uint _offst, bytes memory _input) internal pure returns (bool _output) {
        
        uint8 x;
        assembly {
            x := mload(add(_input, _offst))
        }
        x==0 ? _output = false : _output = true;
    }   
        
    function getStringSize(uint _offst, bytes memory _input) internal pure returns(uint size){
        
        assembly{
            
            size := mload(add(_input,_offst))
            let chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {// if size%32 > 0
                chunk_count := add(chunk_count,1)
            } 
            
             size := mul(chunk_count,32)// first 32 bytes reseves for size in strings
        }
    }

    function bytesToString(uint _offst, bytes memory _input, bytes memory _output) internal pure {

        uint size = 32;
        assembly {
            
            let chunk_count
            
            size := mload(add(_input,_offst))
            chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {
                chunk_count := add(chunk_count,1)  // chunk_count++
            }
               
            for { let index:= 0 }  lt(index , chunk_count){ index := add(index,1) } {
                mstore(add(_output,mul(index,32)),mload(add(_input,_offst)))
                _offst := sub(_offst,32)           // _offst -= 32
            }
        }
    }

    function bytesToBytes32(uint _offst, bytes memory  _input, bytes32 _output) internal pure {
        
        assembly {
            mstore(_output , add(_input, _offst))
            mstore(add(_output,32) , add(add(_input, _offst),32))
        }
    }
    
    function bytesToInt8(uint _offst, bytes memory  _input) internal pure returns (int8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }
    
    function bytesToInt16(uint _offst, bytes memory _input) internal pure returns (int16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt24(uint _offst, bytes memory _input) internal pure returns (int24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToInt32(uint _offst, bytes memory _input) internal pure returns (int32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    // function bytesToInt40(uint _offst, bytes memory _input) internal pure returns (int40 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt48(uint _offst, bytes memory _input) internal pure returns (int48 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt56(uint _offst, bytes memory _input) internal pure returns (int56 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    function bytesToInt64(uint _offst, bytes memory _input) internal pure returns (int64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    // function bytesToInt72(uint _offst, bytes memory _input) internal pure returns (int72 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt80(uint _offst, bytes memory _input) internal pure returns (int80 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt88(uint _offst, bytes memory _input) internal pure returns (int88 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt96(uint _offst, bytes memory _input) internal pure returns (int96 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }
	
	// function bytesToInt104(uint _offst, bytes memory _input) internal pure returns (int104 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }
    
    // function bytesToInt112(uint _offst, bytes memory _input) internal pure returns (int112 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt120(uint _offst, bytes memory _input) internal pure returns (int120 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    function bytesToInt128(uint _offst, bytes memory _input) internal pure returns (int128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    // function bytesToInt136(uint _offst, bytes memory _input) internal pure returns (int136 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt144(uint _offst, bytes memory _input) internal pure returns (int144 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt152(uint _offst, bytes memory _input) internal pure returns (int152 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt160(uint _offst, bytes memory _input) internal pure returns (int160 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt168(uint _offst, bytes memory _input) internal pure returns (int168 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt176(uint _offst, bytes memory _input) internal pure returns (int176 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt184(uint _offst, bytes memory _input) internal pure returns (int184 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt192(uint _offst, bytes memory _input) internal pure returns (int192 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt200(uint _offst, bytes memory _input) internal pure returns (int200 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt208(uint _offst, bytes memory _input) internal pure returns (int208 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt216(uint _offst, bytes memory _input) internal pure returns (int216 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt224(uint _offst, bytes memory _input) internal pure returns (int224 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt232(uint _offst, bytes memory _input) internal pure returns (int232 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt240(uint _offst, bytes memory _input) internal pure returns (int240 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    // function bytesToInt248(uint _offst, bytes memory _input) internal pure returns (int248 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // }

    function bytesToInt256(uint _offst, bytes memory _input) internal pure returns (int256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

	function bytesToUint8(uint _offst, bytes memory _input) internal pure returns (uint8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint16(uint _offst, bytes memory _input) internal pure returns (uint16 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint24(uint _offst, bytes memory _input) internal pure returns (uint24 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	function bytesToUint32(uint _offst, bytes memory _input) internal pure returns (uint32 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	// function bytesToUint40(uint _offst, bytes memory _input) internal pure returns (uint40 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint48(uint _offst, bytes memory _input) internal pure returns (uint48 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint56(uint _offst, bytes memory _input) internal pure returns (uint56 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	function bytesToUint64(uint _offst, bytes memory _input) internal pure returns (uint64 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

	// function bytesToUint72(uint _offst, bytes memory _input) internal pure returns (uint72 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint80(uint _offst, bytes memory _input) internal pure returns (uint80 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint88(uint _offst, bytes memory _input) internal pure returns (uint88 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

	// function bytesToUint96(uint _offst, bytes memory _input) internal pure returns (uint96 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 
	
	// function bytesToUint104(uint _offst, bytes memory _input) internal pure returns (uint104 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint112(uint _offst, bytes memory _input) internal pure returns (uint112 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint120(uint _offst, bytes memory _input) internal pure returns (uint120 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    function bytesToUint128(uint _offst, bytes memory _input) internal pure returns (uint128 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    // function bytesToUint136(uint _offst, bytes memory _input) internal pure returns (uint136 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint144(uint _offst, bytes memory _input) internal pure returns (uint144 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint152(uint _offst, bytes memory _input) internal pure returns (uint152 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint160(uint _offst, bytes memory _input) internal pure returns (uint160 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint168(uint _offst, bytes memory _input) internal pure returns (uint168 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint176(uint _offst, bytes memory _input) internal pure returns (uint176 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint184(uint _offst, bytes memory _input) internal pure returns (uint184 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint192(uint _offst, bytes memory _input) internal pure returns (uint192 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint200(uint _offst, bytes memory _input) internal pure returns (uint200 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint208(uint _offst, bytes memory _input) internal pure returns (uint208 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint216(uint _offst, bytes memory _input) internal pure returns (uint216 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint224(uint _offst, bytes memory _input) internal pure returns (uint224 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint232(uint _offst, bytes memory _input) internal pure returns (uint232 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint240(uint _offst, bytes memory _input) internal pure returns (uint240 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    // function bytesToUint248(uint _offst, bytes memory _input) internal pure returns (uint248 _output) {
        
    //     assembly {
    //         _output := mload(add(_input, _offst))
    //     }
    // } 

    function bytesToUint256(uint _offst, bytes memory _input) internal pure returns (uint256 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SerialityUtility.sol";

library SerialityBuffer {

    struct Buffer{
        uint index;
        bytes buffer;
    }

    function _checkSpace(SerialityBuffer.Buffer memory _buf, uint size) private pure returns(bool) {
        return (_buf.index >= size && _buf.index >= 32);
    }

    function enlargeBuffer(SerialityBuffer.Buffer memory _buf, uint size) internal pure {
        _buf.buffer = new bytes(size);
        _buf.index = size;
    }
    function setBuffer(SerialityBuffer.Buffer memory _buf, bytes memory buffer) internal pure {
        _buf.buffer = buffer;
    }
    function getBuffer(SerialityBuffer.Buffer memory _buf) internal pure returns(bytes memory) {
        return _buf.buffer;
    }

    // writers
    function writeAddress(SerialityBuffer.Buffer memory _buf, address _input) internal pure {
        uint size = SerialityUtility.sizeOfAddress();
        require(_checkSpace(_buf, size), "writeAddress  Seriality: write buffer size not enough");

        SerialityUtility.addressToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeString(SerialityBuffer.Buffer memory _buf, string memory _input) internal pure {
        uint size = SerialityUtility.sizeOfString(_input);
        require(_checkSpace(_buf, size), "writeString   Seriality: write buffer size not enough");

        SerialityUtility.stringToBytes(_buf.index, bytes(_input), _buf.buffer);
        _buf.index -= size;
    }

    function writeBool(SerialityBuffer.Buffer memory _buf, bool _input) internal pure {
        uint size = SerialityUtility.sizeOfBool();
        require(_checkSpace(_buf, size), "writeBool Seriality: write buffer size not enough");

        SerialityUtility.boolToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeInt8(SerialityBuffer.Buffer memory _buf, int8 _input) internal pure {
        uint size = SerialityUtility.sizeOfInt8();
        require(_checkSpace(_buf, size), "writeInt8 Seriality: write buffer size not enough");

        SerialityUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt16(SerialityBuffer.Buffer memory _buf, int16 _input) internal pure {
        uint size = SerialityUtility.sizeOfInt16();
        require(_checkSpace(_buf, size), "writeInt16    Seriality: write buffer size not enough");

        SerialityUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt32(SerialityBuffer.Buffer memory _buf, int32 _input) internal pure {
        uint size = SerialityUtility.sizeOfInt32();
        require(_checkSpace(_buf, size), "writeInt32    Seriality: write buffer size not enough");

        SerialityUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt64(SerialityBuffer.Buffer memory _buf, int64 _input) internal pure {
        uint size = SerialityUtility.sizeOfInt64();
        require(_checkSpace(_buf, size), "writeInt64    Seriality: write buffer size not enough");

        SerialityUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeInt128(SerialityBuffer.Buffer memory _buf, int128 _input) internal pure {
        uint size = SerialityUtility.sizeOfInt128();
        require(_checkSpace(_buf, size), "writeInt128   Seriality: write buffer size not enough");

        SerialityUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeInt256(SerialityBuffer.Buffer memory _buf, int256 _input) internal pure {
        uint size = SerialityUtility.sizeOfInt256();
        require(_checkSpace(_buf, size), "writeInt256   Seriality: write buffer size not enough");

        SerialityUtility.intToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeUint8(SerialityBuffer.Buffer memory _buf, uint8 _input) internal pure {
        uint size = SerialityUtility.sizeOfUint8();
        require(_checkSpace(_buf, size), "writeUint8    Seriality: write buffer size not enough");

        SerialityUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint16(SerialityBuffer.Buffer memory _buf, uint16 _input) internal pure {
        uint size = SerialityUtility.sizeOfUint16();
        require(_checkSpace(_buf, size), "writeUint16   Seriality: write buffer size not enough");

        SerialityUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint32(SerialityBuffer.Buffer memory _buf, uint32 _input) internal pure {
        uint size = SerialityUtility.sizeOfUint32();
        require(_checkSpace(_buf, size), "writeUint32   Seriality: write buffer size not enough");

        SerialityUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint64(SerialityBuffer.Buffer memory _buf, uint64 _input) internal pure {
        uint size = SerialityUtility.sizeOfUint64();
        require(_checkSpace(_buf, size), "writeUint64   Seriality: write buffer size not enough");

        SerialityUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }
    
    function writeUint128(SerialityBuffer.Buffer memory _buf, uint128 _input) internal pure {
        uint size = SerialityUtility.sizeOfUint128();
        require(_checkSpace(_buf, size), "writeUint128  Seriality: write buffer size not enough");

        SerialityUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    function writeUint256(SerialityBuffer.Buffer memory _buf, uint256 _input) internal pure {
        uint size = SerialityUtility.sizeOfUint256();
        require(_checkSpace(_buf, size), "writeUint256  Seriality: write buffer size not enough");

        SerialityUtility.uintToBytes(_buf.index, _input, _buf.buffer);
        _buf.index -= size;
    }

    // readers
    function readAddress(SerialityBuffer.Buffer memory _buf) internal pure returns(address) {
        uint size = SerialityUtility.sizeOfAddress();
        require(_checkSpace(_buf, size), "readAddress   Seriality: read buffer size not enough");

        address addr = SerialityUtility.bytesToAddress(_buf.index, _buf.buffer);
        _buf.index -= size;

        return addr;
    }
    
    function readString(SerialityBuffer.Buffer memory _buf) internal pure returns(string memory) {
        uint size = SerialityUtility.getStringSize(_buf.index, _buf.buffer);
        require(_checkSpace(_buf, size), "readString    Seriality: read buffer size not enough");

        string memory str = new string (size);
        SerialityUtility.bytesToString(_buf.index, _buf.buffer, bytes(str));
        _buf.index -= size;

        return str;
    }

    function readBool(SerialityBuffer.Buffer memory _buf) internal pure returns(bool) {
        uint size = SerialityUtility.sizeOfBool();
        require(_checkSpace(_buf, size), "readBool  Seriality: read buffer size not enough");

        bool b = SerialityUtility.bytesToBool(_buf.index, _buf.buffer);
        _buf.index -= size;

        return b;
    }

    function readInt8(SerialityBuffer.Buffer memory _buf) internal pure returns(int8) {
        uint size = SerialityUtility.sizeOfInt8();
        require(_checkSpace(_buf, size), "readInt8  Seriality: read buffer size not enough");

        int8 i = SerialityUtility.bytesToInt8(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt16(SerialityBuffer.Buffer memory _buf) internal pure returns(int16) {
        uint size = SerialityUtility.sizeOfInt16();
        require(_checkSpace(_buf, size), "readInt16 Seriality: read buffer size not enough");

        int16 i = SerialityUtility.bytesToInt16(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt32(SerialityBuffer.Buffer memory _buf) internal pure returns(int32) {
        uint size = SerialityUtility.sizeOfInt32();
        require(_checkSpace(_buf, size), "readInt32 Seriality: read buffer size not enough");

        int32 i = SerialityUtility.bytesToInt32(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt64(SerialityBuffer.Buffer memory _buf) internal pure returns(int64) {
        uint size = SerialityUtility.sizeOfInt64();
        require(_checkSpace(_buf, size), "readInt64 Seriality: read buffer size not enough");

        int64 i = SerialityUtility.bytesToInt64(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readInt128(SerialityBuffer.Buffer memory _buf) internal pure returns(int128) {
        uint size = SerialityUtility.sizeOfInt128();
        require(_checkSpace(_buf, size), "readInt128    Seriality: read buffer size not enough");

        int128 i = SerialityUtility.bytesToInt128(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

    function readInt256(SerialityBuffer.Buffer memory _buf) internal pure returns(int256) {
        uint size = SerialityUtility.sizeOfInt256();
        require(_checkSpace(_buf, size), "readInt256    Seriality: read buffer size not enough");

        int256 i = SerialityUtility.bytesToInt256(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

    function readUint8(SerialityBuffer.Buffer memory _buf) internal pure returns(uint8) {
        uint size = SerialityUtility.sizeOfUint8();
        require(_checkSpace(_buf, size), "readUint8 Seriality: read buffer size not enough");

        uint8 i = SerialityUtility.bytesToUint8(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint16(SerialityBuffer.Buffer memory _buf) internal pure returns(uint16) {
        uint size = SerialityUtility.sizeOfUint16();
        require(_checkSpace(_buf, size), "readUint16    Seriality: read buffer size not enough");

        uint16 i = SerialityUtility.bytesToUint16(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint32(SerialityBuffer.Buffer memory _buf) internal pure returns(uint32) {
        uint size = SerialityUtility.sizeOfUint32();
        require(_checkSpace(_buf, size), "readUint32    Seriality: read buffer size not enough");

        uint32 i = SerialityUtility.bytesToUint32(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint64(SerialityBuffer.Buffer memory _buf) internal pure returns(uint64) {
        uint size = SerialityUtility.sizeOfUint64();
        require(_checkSpace(_buf, size), "readUint64    Seriality: read buffer size not enough");

        uint64 i = SerialityUtility.bytesToUint64(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }
    
    function readUint128(SerialityBuffer.Buffer memory _buf) internal pure returns(uint128) {
        uint size = SerialityUtility.sizeOfUint128();
        require(_checkSpace(_buf, size), "readUint128   Seriality: read buffer size not enough");

        uint128 i = SerialityUtility.bytesToUint128(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

    function readUint256(SerialityBuffer.Buffer memory _buf) internal pure returns(uint256) {
        uint size = SerialityUtility.sizeOfUint256();
        require(_checkSpace(_buf, size), "readUint256   Seriality: read buffer size not enough");

        uint256 i = SerialityUtility.bytesToUint256(_buf.index, _buf.buffer);
        _buf.index -= size;

        return i;
    }

}

// contracts/XWorldMBRandomSourceBase.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Utility/XWorldRandom.sol";
import "../Utility/XWorldRandomPool.sol";

import "./XWorldMBRandomSourceBase_History_V1.sol";

abstract contract XWorldMBRandomSourceBase_V2 is 
    Context, 
    AccessControl
{
    using XWorldRandomPool for XWorldRandomPool.RandomPool;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RANDOM_ROLE = keccak256("RANDOM_ROLE");

    struct NFTRandPool{
        bool exist;
        XWorldRandomPool.RandomPool randPool;
    }

    IXWorldRandom _rand;
    mapping(uint32 => NFTRandPool)    _randPools; // poolID => nft data random pools
    mapping(uint32 => uint32[])       _mbRandomSets; // mbTypeID => poolID array

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RANDOM_ROLE, _msgSender());
    }

    function setRandSource(address randAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()));

        _rand = IXWorldRandom(randAddr);
    }

    function getRandSource() external view returns(address) {
        // require(hasRole(MANAGER_ROLE, _msgSender()));
        return address(_rand);
    }
    function _addPool(uint32 poolID, XWorldRandomPool.RandomSet[] memory randSetArray) internal {
        NFTRandPool storage rp = _randPools[poolID];

        rp.exist = true;
        for(uint i=0; i<randSetArray.length; ++i){
            rp.randPool.pool.push(randSetArray[i]);
        }

        rp.randPool.initRandomPool();
    }

    function addPool(uint32 poolID, XWorldRandomPool.RandomSet[] memory randSetArray) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");
        require(!_randPools[poolID].exist,"rand pool already exist");

        _addPool(poolID, randSetArray);
    }

    function modifyPool(uint32 poolID, XWorldRandomPool.RandomSet[] memory randSetArray) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");
        require(_randPools[poolID].exist,"rand pool not exist");

        NFTRandPool storage rp = _randPools[poolID];

        delete rp.randPool.pool;

        for(uint i=0; i<randSetArray.length; ++i){
            rp.randPool.pool.push(randSetArray[i]);
        }

        rp.randPool.initRandomPool();
    }

    function removePool(uint32 poolID) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");
        require(_randPools[poolID].exist, "rand pool not exist");

        delete _randPools[poolID];
    }

    function getPool(uint32 poolID) public view returns(NFTRandPool memory) {
        require(_randPools[poolID].exist, "rand pool not exist");

        return _randPools[poolID];
    }

    function hasPool(uint32 poolID) external view returns(bool){
          return (_randPools[poolID].exist);
    }

    function setRandomSet(uint32 mbTypeID, uint32[] calldata poolIds) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");

        uint32[] storage poolIDArray = _mbRandomSets[mbTypeID];
        for(uint i=0; i< poolIds.length; ++i){
            poolIDArray.push(poolIds[i]);
        }
    }
    function unsetRandomSet(uint32 mbTypeID) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");

        delete _mbRandomSets[mbTypeID];
    }
    function getRandomSet(uint32 mbTypeID) external view returns(uint32[] memory poolIds) {
        return _mbRandomSets[mbTypeID];
    }
    
    function randomNFTData(uint256 r, uint32 mbTypeID) virtual external view returns(bytes memory structDatas);

    function batchRandomNFTData(uint256 r, uint32 mbTypeID, uint8 batchCount) virtual external view returns(bytes memory structDatas);
}

// contracts/XWorldMysteryBoxBase.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Utility/IXWorldRandom.sol";
import "../Utility/XWorldGasFeeCharger.sol";

import "./XWorldMysteryBoxNFT.sol";
import "./XWorldMBRandomSourceBase.sol";

import "./XWorldMysteryBoxBase_History_V2.sol";

interface IXWorldMysteryBoxContentMinter_V2 {
    function mintContentAssets(address userAddr, uint256 mbTokenId, bytes memory nftDatas) external returns(uint256 tokenId);

    function batchMintContentAssets(address userAddr, uint256 mbTokenId, uint8 batchCount, bytes memory nftDatas) external returns(uint256[] memory tokenIds, uint256[] memory tokenValues);
}

abstract contract XWorldMysteryBoxBase_V3 is 
    Context, 
    Pausable, 
    AccessControl,
    IXWorldOracleRandComsumer
{
    using XWorldGasFeeCharger for XWorldGasFeeCharger.MethodExtraFees;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");

    event XWorldOracleOpenMysteryBox(uint256 oracleRequestId, uint256 indexed mbTokenId, address owner);
    event XWorldOpenMysteryBox(uint256 indexed mbTokenId, uint256 indexed newTokenId, bytes nftData);

    struct MysteryBoxNFTData{
        address owner;
        uint32 mbType;
        uint32 mbTypeId;
    }
    struct UserData{
        uint256 tokenId;
        uint256 lockTime;
    }
    
    XWorldMysteryBoxNFT public _mbNFT;
    IXWorldMysteryBoxContentMinter_V2 public _minter;
    
    mapping(uint256 => MysteryBoxNFTData) _burnedTokens;
    mapping(uint32=>address) _randomDataSources; // indexed by mystery box type mbType
    mapping(uint256 => UserData) public _oracleUserData; // indexed by oracle request id

    // Method extra fee
    // For smart contract method which need extra transaction by other service, we define extra fee
    // extra fee charge by method call tx with `value` paramter, and send to target service wallet address
    XWorldGasFeeCharger.MethodExtraFees _methodExtraFees;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function getName() external virtual returns(string memory);

    function setNftAddress(address nftAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _mbNFT = XWorldMysteryBoxNFT(nftAddr);
    }

    function getNftAddress() external view returns(address) {
        return address(_mbNFT);
    }
    
    function setMysteryBoxContentMinter(address minter) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _minter = IXWorldMysteryBoxContentMinter_V2(minter);
    }

    function setRandomSource(uint32 nftType, address randomSrc) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _randomDataSources[nftType] = randomSrc;
    }

    function getRandomSource(uint32 nftType) external view returns(address){
        return _randomDataSources[nftType];
    }

    /**
    * @dev set smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need extra fee
    * @param value extra fee value
    * @param target target address where extra fee goes to
    */
    function setMethodExtraFee(uint8 methodKey, uint256 value, address target) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldMysteryBox: must have manager role"
        );

        _methodExtraFees.setMethodExtraFee(methodKey, value, target);
    }

    /**
    * @dev cancel smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need cancel extra fee
    */
    function removeMethodExtraFee(uint8 methodKey) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldMysteryBox: must have manager role"
        );

        _methodExtraFees.removeMethodExtraFee(methodKey);
    }

    /**
    * @dev open mystery box, emit {XWorldOracleOpenMysteryBox}
    * call `oracleRand` in {IXWorldRandom} of address from `getRandSource` in {XWorldDCEquipMBRandomSource}
    * send a oracle random request and emit {XWorldOracleRandRequest}
    *
    * Extrafees:
    * - `oracleOpenMysteryBox` call need charge extra fee for `fulfillRandom` in {XWorldRandom} call by oracle service
    * - methodKey = 1, extra gas fee = 0.0013 with tx.value needed
    *
    * Requirements:
    * - caller must out side contract, not from contract
    * - caller must owner of `tokenId` in {XWorldMysteryBoxNFT}
    * - `tokenId` in {XWorldMysteryBoxNFT} must not freezed
    * - contract not paused
    *
    * @param tokenId token id of {XWorldMysteryBoxNFT}, if succeed, token will be burned
    */
    function oracleOpenMysteryBox(uint256 tokenId) external payable whenNotPaused {
        require(tx.origin == _msgSender(), "XWorldMysteryBox: only for outside account");
        require(_mbNFT.notFreezed(tokenId), "XWorldMysteryBox: freezed token");
        require(_mbNFT.ownerOf(tokenId) == _msgSender(), "XWorldMysteryBox: ownership check failed");

        MysteryBoxNFTData storage nftData = _burnedTokens[tokenId];
        nftData.owner = _msgSender();
        (nftData.mbType, nftData.mbTypeId) = _mbNFT.getMysteryBoxData(tokenId);
        
        address randSrcAddr = _randomDataSources[nftData.mbType];
        require(randSrcAddr != address(0), "XWorldMysteryBox: not a mystry box");
        
        address rndAddr = XWorldMBRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "XWorldMysteryBox: rand address wrong");

        _methodExtraFees.chargeMethodExtraFee(1); // charge oracleOpenMysteryBox extra fee

        _mbNFT.burn(tokenId);
        require(!_mbNFT.exists(tokenId), "XWorldMysteryBox: burn mystery box failed");

        uint256 reqid = IXWorldRandom(rndAddr).oracleRand();

        UserData storage userData = _oracleUserData[reqid];
        userData.tokenId = tokenId;
        userData.lockTime = block.timestamp;
        
        emit XWorldOracleOpenMysteryBox(reqid, tokenId, _msgSender());
    }

    // call back from random contract which triger by service call {fulfillOracleRand} function
    function oracleRandResponse(uint256 reqid, uint256 randnum) override external {
        require(hasRole(RAND_ROLE, _msgSender()), "XWorldMysteryBox: must have rand role");

        UserData storage userData = _oracleUserData[reqid];
        MysteryBoxNFTData storage nftData = _burnedTokens[userData.tokenId];

        require(nftData.owner != address(0), "XWorldMysteryBox: nftdata owner not exist");

        address randSrcAddr = _randomDataSources[nftData.mbType];
        require(randSrcAddr != address(0), "XWorldMysteryBox: not a mystry box");

        address rndAddr = XWorldMBRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "XWorldMysteryBox: rand address wrong");

        bytes memory contentNFTDatas = XWorldMBRandomSourceBase(randSrcAddr).randomNFTData(randnum, nftData.mbTypeId);
        uint256 newTokenId = _minter.mintContentAssets(nftData.owner, userData.tokenId, contentNFTDatas);

        delete _oracleUserData[reqid];
        delete _burnedTokens[userData.tokenId];

        emit XWorldOpenMysteryBox(userData.tokenId, newTokenId, contentNFTDatas);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "XWorldMysteryBox: must have pauser role to pause");
        _pause();
    }
    
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "XWorldMysteryBox: must have pauser role to unpause");
        _unpause();
    }
    
}

// contracts/XWorldMysteryBoxShop.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";

import "./XWorldDirectMysteryBox.sol";
import "hardhat/console.sol";
interface IMysterBoxNFTMinter {
    function mintNFT(address to, uint32 mbType, uint32 mbTypeId) external returns(uint256 nftID);
    function batchMintNFT(address to, uint32 mbType, uint32 mbTypeId, uint32 count) external returns(uint256[] memory nftID);
}

contract XWorldMysteryBoxShop is 
    Context, 
    Pausable, 
    AccessControl
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    event XWorldOnSaleMysterBox(string pairName, address indexed nftMinterAddress, uint32 mysterBoxType, uint32 mysterBoxTypeId, address indexed tokenAddress, uint256 price, address indexed recyclePool);
    event XWorldOffSaleMysterBox(string pairName, address indexed nftMinterAddress, uint32 mysterBoxType, uint32 mysterBoxTypeId, address indexed tokenAddress, uint256 price, address indexed recyclePool);
    event XWorldBuyMysteryBox(address userAddr, address indexed nftMinterddress, address indexed tokenAddress, uint256 price, uint32 mysterBoxType, uint32 mysterBoxTypeId, uint256 nftID);
    event XWorldBatchBuyMysteryBox(address userAddr, address indexed nftMinterddress, address indexed tokenAddress, uint256 price, uint32 mysterBoxType, uint32 mysterBoxTypeId, uint256[] nftID);

    struct OnSaleMysterBox{
        IMysterBoxNFTMinter nftMinter;
        uint32 mysterBoxType;
        uint32 mysterBoxTypeId;

        IERC20 token;
        uint256 price;

        IXWGRecyclePoolManager recyclePoolMgr; // if recyclePoolMgr is set, than transfer income to recycle pool & lock them
        address recyclePool;
    }

    mapping(string=>OnSaleMysterBox) public _onSaleMysterBoxes;
    address public _receiveIncomAddress;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P1");
        _pause();
    }
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P2");
        _unpause();
    }

    function setOnSaleMysteryBox(string calldata pairName, address nftMinterAddress, uint32 mysterBoxType, uint32 mysterBoxTypeId, address tokenAddress, uint256 price, address recyclePool, address recyclePoolMgr) external whenNotPaused {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBoxShop: must have manager role to manage");

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        onSalePair.nftMinter = IMysterBoxNFTMinter(nftMinterAddress);
        onSalePair.mysterBoxType = mysterBoxType;
        onSalePair.mysterBoxTypeId = mysterBoxTypeId;
        onSalePair.token = IERC20(tokenAddress);
        onSalePair.price = price;
        onSalePair.recyclePoolMgr = IXWGRecyclePoolManager(recyclePoolMgr);
        onSalePair.recyclePool = recyclePool;

        emit XWorldOnSaleMysterBox(pairName, nftMinterAddress, mysterBoxType, mysterBoxTypeId, tokenAddress, price, recyclePool);
    }

    function unsetOnSaleMysteryBox(string calldata pairName) external whenNotPaused {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBoxShop: must have manager role to manage");

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        emit XWorldOffSaleMysterBox(pairName, address(onSalePair.nftMinter), onSalePair.mysterBoxType, onSalePair.mysterBoxTypeId, address(onSalePair.token), onSalePair.price, address(onSalePair.recyclePoolMgr));

        delete _onSaleMysterBoxes[pairName];
    }

    function setReceiveIncomeAddress(address incomAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBoxShop: must have manager role to manage");
        console.log("[sol]incomAddr=",incomAddr);
        _receiveIncomAddress = incomAddr;
    }

    function buyMysteryBox(string calldata pairName) external whenNotPaused {
        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        require(address(onSalePair.nftMinter) != address(0), "XWorldMysteryBoxShop: mystery box not on sale");

        if(onSalePair.price > 0){
            require(onSalePair.token.balanceOf(_msgSender()) >= onSalePair.price, "XWorldMysteryBoxShop: insufficient token");

            if(address(onSalePair.recyclePoolMgr) != address(0)) {
                TransferHelper.safeTransferFrom(address(onSalePair.token), _msgSender(), onSalePair.recyclePool, onSalePair.price);
                onSalePair.recyclePoolMgr.changeRecycleBalance(0, onSalePair.price);
            }
            else {
                TransferHelper.safeTransferFrom(address(onSalePair.token), _msgSender(), address(this), onSalePair.price);
            }
        }

        uint256 nftID = onSalePair.nftMinter.mintNFT(_msgSender(), onSalePair.mysterBoxType, onSalePair.mysterBoxTypeId);

        emit XWorldBuyMysteryBox(_msgSender(), address(onSalePair.nftMinter), address(onSalePair.token), onSalePair.price, onSalePair.mysterBoxType, onSalePair.mysterBoxTypeId, nftID);
    }

    function batchBuyMysterBox(string calldata pairName, uint32 count) external whenNotPaused {

        OnSaleMysterBox storage onSalePair = _onSaleMysterBoxes[pairName];
        require(address(onSalePair.nftMinter) != address(0), "XWorldMysteryBoxShop: mystery box not on sale");

        if(onSalePair.price > 0){
            require(onSalePair.token.balanceOf(_msgSender()) >= onSalePair.price*count, "XWorldMysteryBoxShop: insufficient token");

            if(address(onSalePair.recyclePoolMgr) != address(0)) {
                TransferHelper.safeTransferFrom(address(onSalePair.token), _msgSender(), address(onSalePair.recyclePoolMgr), onSalePair.price*count);
                onSalePair.recyclePoolMgr.changeRecycleBalance(0, onSalePair.price*count);
            }
            else {
                TransferHelper.safeTransferFrom(address(onSalePair.token), _msgSender(), address(this), onSalePair.price*count);
            }
        }

        uint256[] memory nftIDs = onSalePair.nftMinter.batchMintNFT(_msgSender(), onSalePair.mysterBoxType, onSalePair.mysterBoxTypeId, count);

        emit XWorldBatchBuyMysteryBox(_msgSender(), address(onSalePair.nftMinter), address(onSalePair.token), onSalePair.price, onSalePair.mysterBoxType, onSalePair.mysterBoxTypeId, nftIDs);
    
    }

    function fetchIncome(address tokenAddr, uint256 value) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBoxShop: must have manager role to manage");
        IERC20 token = IERC20(tokenAddr);

        uint bl = token.balanceOf(address(this));
        require(bl > 0, "XWorldMysteryBoxShop: zero balanceOf");

        console.log("[sol]fetchIncome",bl,value,tokenAddr);
        if(value <= 0){
            value = token.balanceOf(address(this));
        }

        require(value > 0, "XWorldMysteryBoxShop: zero value");

        TransferHelper.safeTransfer(tokenAddr, _receiveIncomAddress, value);
    }
}

// contracts/XWorldDirectMysteryBox.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";
import "../Utility/XWorldGasFeeCharger.sol";

import "../Seriality/Seriality_1_0/SerialityUtility.sol";
import "../Seriality/Seriality_1_0/SerialityBuffer.sol";

import "../MysteryBoxes/XWorldMBRandomSourceBase.sol";
import "../MysteryBoxes/XWorldMysteryBoxBase.sol";

import "./XWorldDirectMysteryBox_History_V2.sol";

abstract contract XWorldDirectMysteryBox_V3 is 
    Context,
    Pausable,
    AccessControl,
    IXWorldOracleRandComsumer
{
    using XWorldGasFeeCharger for XWorldGasFeeCharger.MethodExtraFees;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");

    event XWorldDirectMBOpen(address indexed useAddr, uint32 mbTypeId, uint256 value);
    event XWorldDirectMBGetResult(address indexed useAddr, uint32 mbTypeId, uint256 newTokenId);

    event XWorldDirectMBBatchOpen(address indexed useAddr, uint32 mbTypeId, uint256 value, uint256 batchCount);
    event XWorldDirectMBBatchGetResult(address indexed useAddr, uint32 mbTypeId, uint256[] newTokenId, uint256[] newTokenValue); // newTokenValue > 0 means 1155

    struct DirectMBOpenRecord {
        address userAddr;
        uint32 mbTypeId;
        uint8 batchCount;
    }

    XWorldMBRandomSourceBase_V2 public _mbRandSource;
    IXWorldMysteryBoxContentMinter_V2 public _contentMinter;
    IERC20 public _xwgToken;
    IXWGRecyclePoolManager public _xwgRecyclePoolMgr;
    address public _xwgRecyclePool;

    mapping(uint256=>DirectMBOpenRecord) public _openedRecord; // indexed by oracleRand request id
    mapping(uint32=>uint256) public _mbPrice; // indexed by mbtypeid;

    // Method extra fee
    // For smart contract method which need extra transaction by other service, we define extra fee
    // extra fee charge by method call tx with `value` paramter, and send to target service wallet address
    XWorldGasFeeCharger.MethodExtraFees _methodExtraFees;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function getName() public virtual returns(string memory);

    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have pauser role to unpause"
        );
        _unpause();
    }

    function setRandomSource(address randSource) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _mbRandSource = XWorldMBRandomSourceBase_V2(randSource);
    }

    function setMinter(address minter) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _contentMinter = IXWorldMysteryBoxContentMinter_V2(minter);
    }

    function setRecyclePool(address recyclePoolAddr, address recyclePoolMgrAddress) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _xwgRecyclePool = recyclePoolAddr;
        _xwgRecyclePoolMgr = IXWGRecyclePoolManager(recyclePoolMgrAddress);
    }

    function setXWGToken(address xwgToken) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _xwgToken = IERC20(xwgToken);
    }

    function setMBPrice(uint32 mbTypeId, uint256 price) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _mbPrice[mbTypeId] = price;
    }

    /**
    * @dev set smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need extra fee
    * @param value extra fee value
    * @param target target address where extra fee goes to
    */
    function setMethodExtraFee(uint8 methodKey, uint256 value, address target) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );

        _methodExtraFees.setMethodExtraFee(methodKey, value, target);
    }

    /**
    * @dev cancel smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need cancel extra fee
    */
    function removeMethodExtraFee(uint8 methodKey) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );

        _methodExtraFees.removeMethodExtraFee(methodKey);
    }

    /**
    * @dev direct open mystery box, emit {XWorldDirectMBOpen} event
    * call `oracleRand` in {IXWorldRandom} of address from `getRandSource` in {XWorldDCEquipMBRandomSource}
    * send a oracle random request and emit {XWorldOracleRandRequest}
    *
    * Extrafees:
    * - `openMB` call need charge extra fee for `fulfillRandom` in {XWorldRandom} call by oracle service
    * - methodKey = 1, extra gas fee = 0.0013 with tx.value needed
    *
    * Requirements:
    * - caller must out side contract, not from contract
    * - `_mbRandSource` must be set
    * - `_mbPrice` of `mbTypeId` must be set
    * - contract not paused
    *
    * @param mbTypeId mystery box type id
    */
    function openMB(uint32 mbTypeId) external payable whenNotPaused {
        require(tx.origin == _msgSender(), "XWorldDCEquipDirectMB: only for outside account");
        require(address(_mbRandSource) != address(0), "XWorldDCEquipDirectMB: equip random source need initialized");

        address rndAddr = XWorldMBRandomSourceBase_V2(_mbRandSource).getRandSource();
        require(rndAddr != address(0), "XWorldDCEquipDirectMB: rand address wrong");

        uint256 price = _mbPrice[mbTypeId];
        //require(price > 0, "XWorldDCEquipDirectMB: mb not exist");

        _methodExtraFees.chargeMethodExtraFee(1); // charge openMB extra fee

        if(price > 0){
            require(_xwgToken.balanceOf(_msgSender()) >= price, "XWorldDCEquipDirectMB: insufficient token");

            if(address(_xwgRecyclePoolMgr) != address(0)) {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), _xwgRecyclePool, price);
                _xwgRecyclePoolMgr.changeRecycleBalance(0, price);
            }
            else {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), address(this), price);
            }
        }

        // request random number
        uint256 reqid = IXWorldRandom(rndAddr).oracleRand();

        DirectMBOpenRecord storage openRec = _openedRecord[reqid];
        openRec.mbTypeId = mbTypeId;
        openRec.userAddr = _msgSender();
        openRec.batchCount = 0;

        // emit direct mb open event
        emit XWorldDirectMBOpen(_msgSender(), mbTypeId, price);
    }

    /**
    * @dev direct batch open mystery box, emit {XWorldDirectMBOpen} event
    * call `oracleRand` in {IXWorldRandom} of address from `getRandSource` in {XWorldDCEquipMBRandomSource}
    * send a oracle random request and emit {XWorldOracleRandRequest}
    *
    * Extrafees:
    * - `batchOpenMB` call need charge extra fee for `fulfillRandom` in {XWorldRandom} call by oracle service
    * - methodKey = 2, extra gas fee = 0.004 with tx.value needed
    *
    * Requirements:
    * - caller must out side contract, not from contract
    * - `_mbRandSource` must be set
    * - `_mbPrice` of `mbTypeId` must be set
    * - contract not paused
    *
    * @param mbTypeId mystery box type id
    */
    function batchOpenMB(uint32 mbTypeId, uint8 batchCount) external payable whenNotPaused {
        require(tx.origin == _msgSender(), "XWorldDCEquipDirectMB: only for outside account");
        require(address(_mbRandSource) != address(0), "XWorldDCEquipDirectMB: equip random source need initialized");
        require(batchCount >0 && batchCount <= 10, "XWorldDCEquipDirectMB: batch open count must <= 10");

        address rndAddr = XWorldMBRandomSourceBase_V2(_mbRandSource).getRandSource();
        require(rndAddr != address(0), "XWorldDCEquipDirectMB: rand address wrong");

        uint256 price = _mbPrice[mbTypeId] * batchCount;
        //require(price > 0, "XWorldDCEquipDirectMB: mb not exist");

        _methodExtraFees.chargeMethodExtraFee(2); // charge batchOpenMB extra fee

        if(price > 0){
            require(_xwgToken.balanceOf(_msgSender()) >= price, "XWorldDCEquipDirectMB: insufficient token");

            if(address(_xwgRecyclePoolMgr) != address(0)) {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), _xwgRecyclePool, price);
                _xwgRecyclePoolMgr.changeRecycleBalance(0, price);
            }
            else {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), address(this), price);
            }
        }

        // request random number
        uint256 reqid = IXWorldRandom(rndAddr).oracleRand();

        DirectMBOpenRecord storage openRec = _openedRecord[reqid];
        openRec.mbTypeId = mbTypeId;
        openRec.userAddr = _msgSender();
        openRec.batchCount = batchCount;

        // emit direct mb open event
        emit XWorldDirectMBBatchOpen(_msgSender(), mbTypeId, price, batchCount);
    }

    // get rand number, real open mystery box
    function oracleRandResponse(uint256 reqid, uint256 randnum) override external {
        require(hasRole(RAND_ROLE, _msgSender()), "XWorldDCEquipDirectMB: must have rand role");
        require(address(_contentMinter) != address(0), "XWorldDCEquipDirectMB: mb minter need initialized");
        require(address(_mbRandSource) != address(0), "XWorldDCEquipDirectMB: mb random source need initialized");

        address rndAddr = XWorldMBRandomSourceBase_V2(_mbRandSource).getRandSource();
        require(rndAddr != address(0), "XWorldDCEquipDirectMB: rand address wrong");

        DirectMBOpenRecord storage openRec = _openedRecord[reqid];

        require(openRec.userAddr != address(0), "XWorldDCEquipDirectMB: user address wrong");

        if(openRec.batchCount > 0){
            // batch dispatch equipment
            bytes memory contentNFTDatas = XWorldMBRandomSourceBase_V2(_mbRandSource).batchRandomNFTData(randnum, openRec.mbTypeId, openRec.batchCount);
            uint256[] memory newTokenIds;
            uint256[] memory newTokenValues;
            (newTokenIds, newTokenValues) = _contentMinter.batchMintContentAssets(openRec.userAddr, 0, openRec.batchCount, contentNFTDatas);

            // emit direct mb result event
            emit XWorldDirectMBBatchGetResult(openRec.userAddr, openRec.mbTypeId, newTokenIds, newTokenValues);
        }
        else {
            // dispatch equipment
            bytes memory contentNFTDatas = XWorldMBRandomSourceBase_V2(_mbRandSource).randomNFTData(randnum, openRec.mbTypeId);
            uint256 newTokenId = _contentMinter.mintContentAssets(openRec.userAddr, 0, contentNFTDatas);

            // emit direct mb result event
            emit XWorldDirectMBGetResult(openRec.userAddr, openRec.mbTypeId, newTokenId);
        }
    }
}

// contracts/XWorldDCEquip.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../XWorldNFT.sol";

contract XWorldDCEquipStruct {

    struct EquipData{
        uint8 equip; // 1: weapon, 2: armor
        uint8 role; // 1: knight, 2: assassin, 3: mage， 4: priest， 5: archer
        uint8 grade; // 1-5
        uint8 level; // level 1-15, level/5 = generations, level%5 = stars
        uint32 exp; // experience
    }

}

/**
 * @dev Dream card equipment nft contract
 */
contract XWorldDCEquip is XWorldExtendableNFT, XWorldDCEquipStruct {
    using Counters for Counters.Counter;
    
    event XWorldDCEquipMint(address indexed to, uint256 indexed tokenId, EquipData data);
    event XWorldDCEquipModify(uint256 indexed tokenId, EquipData data);

    mapping(uint256 => EquipData) private _equipDatas;

    // test net uri : "https://testnode.xwgdata.net/eqp_nft/"
    // main net uri : "https://metadata.nft.xwg.games/2/"
    constructor(string memory uri) XWorldExtendableNFT("XWorld DC Equipment", "XEQP", uri) {
        mint(_msgSender(), EquipData({
            equip: 0,
            role : 0,
            grade : 0,
            level : 0,
            exp : 0
        })); // mint first token to notify event scan
    }

    function mint(address to, EquipData memory data) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        EquipData storage nftData = _equipDatas[curID];
        nftData.equip = data.equip;
        nftData.exp = data.exp;
        nftData.grade = data.grade;
        nftData.level = data.level;
        nftData.role = data.role;

        emit XWorldDCEquipMint(to, curID, nftData);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    function modifyNftData(uint256 tokenId, EquipData calldata data) external whenNotPaused {
        require(hasRole(DATA_ROLE, _msgSender()), "R4");
        require(_exists(tokenId), "R5");

        EquipData storage nftData = _equipDatas[tokenId];

        // modify user data
        nftData.equip = data.equip;
        nftData.exp = data.exp;
        nftData.grade = data.grade;
        nftData.level = data.level;
        nftData.role = data.role;

        emit XWorldDCEquipModify(tokenId, nftData);
    }

    function getNftData(uint256 tokenId) external view returns(EquipData memory data){
        require(_exists(tokenId), "T1");

        data = _equipDatas[tokenId];
    }

}

// contracts/XWorldDCEquip1155.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../XWorld1155.sol";

// id = 1 : equip pieces

contract XWorldDCEquip1155 is XWorldExtendable1155 {
    
    // test net uri : "https://testnode.xwgdata.net/eqp_1155/{id}"
    // main net uri : "https://metadata.nft.xwg.games/eqp_1155/{id}"
    constructor(string memory uri) XWorldExtendable1155(uri) {
        mint(_msgSender(), 1, 1, new bytes(0)); // mint first token to notify event scan
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
     * bearer except when using {AccessControl-_setupRole}.
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
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

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
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

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
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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

// contracts/XWorldRandom.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./IXWorldRandom.sol";

/**
 * @dev A random source contract provids `seedRand`, `sealedRand` and `oracleRand` methods
 */
contract XWorldRandom is Context, AccessControl, IXWorldRandom {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    // an auto increased number by each _seedRand call
    uint32 _nonce;

    // an auto increased number by each setSealed call
    uint32 _sealedNonce;

    // an random seed set by manager
    uint256 _randomSeed;

    // an auto increased number by each oracleRand call
    uint256 _orcacleReqIDSeed;

    // sealed random seed data structure
    struct RandomSeed {
        uint32 sealedNonce;
        uint256 sealedNumber;
        uint256 seed;
        uint256 h1;
    }

    mapping(uint256 => RandomSeed) _sealedRandom; // _encodeSealedKey(addr) => sealed random seed data structure
    mapping(uint256 => address) _oracleRandRequests; // oracle rand request id => caller address

    /**
    * @dev emit when `oracleRand` called

    * @param reqid oracle rand request id
    * @param requestAddress caller address
    */
    event XWorldOracleRandRequest(uint256 reqid, address indexed requestAddress);

    /**
    * @dev emit when `fulfillOracleRand` called

    * @param reqid oracle rand request id
    * @param randnum random number feed to request caller
    * @param requestAddress `oracleRand` requrest caller address
    */
    event XWorldOracleRandResponse(uint256 reqid, uint256 randnum, address indexed requestAddress);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(ORACLE_ROLE, _msgSender());
    }

    /**
    * @dev check address is sealed, usually call by contract to check user seal status
    *
    * @param addr user addr
    * @return ture if user is sealed
    */
    function isSealed(address addr) external view returns (bool) {
        return _isSealedDirect(_encodeSealedKey(addr));
    }

    /**
    * @dev set random seed
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param s random seed
    */
    function setRandomSeed(uint256 s) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not manager");

        _randomSeed = s;
    }

    /**
    * @dev set user sealed, usually call by contract to seal a user
    * this function will `_encodeSealedKey` by tx.orgin and `_msgSender`
    * if success call this function, then user can call `sealedRand`
    */
    function setSealed() external override {

        require(block.number >= 100,"block is too small");
        
        uint256 sealedKey = _encodeSealedKey(tx.origin);
       
        require(!_isSealedDirect(sealedKey),"should not sealed");

        _sealedNonce++;

        RandomSeed storage rs = _sealedRandom[sealedKey];

        rs.sealedNumber = block.number + 1;
        rs.sealedNonce = _sealedNonce;
        rs.seed = _randomSeed;

        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(block.number, block.timestamp, _sealedNonce)
            )
        );
        uint32 n1 = uint32(seed % 100);
        rs.h1 = uint256(blockhash(block.number - n1));
    }

    /**
    * @dev seal rand and get a random number
    *
    * Requirements:
    * - caller must call `setSealed` first
    *
    * @return ret random number
    */
    function sealedRand() external override returns (uint256 ret) {
        return _sealedRand();
    }

    /**
    * @dev input a seed and get a random number depends on seed
    *
    * @param inputSeed random seed
    * @return ret random number depends on seed
    */
    function seedRand(uint256 inputSeed) external override returns (uint256 ret) {
        return _seedRand(inputSeed);
    }

    /**
    * @dev start an oracle rand, emit {XWorldOracleRandRequest}, call by contract
    * oracle service wait on {XWorldOracleRandRequest} event and call `fulfillOracleRand`
    *
    * Requirements:
    * - caller must implements `oracleRandResponse` of {IXWorldOracleRandComsumer}
    *
    * @return reqid is request id of oracle rand request
    */
    function oracleRand() external override returns (uint256 reqid) {
        ++_orcacleReqIDSeed;
        reqid = _orcacleReqIDSeed;

        _oracleRandRequests[reqid] = _msgSender();

        emit XWorldOracleRandRequest(reqid, _msgSender());

        return reqid;
    }

    /**
    * @dev fulfill an oracle rand, emit {XWorldOracleRandResponse}
    * call by oracle when it get {XWorldOracleRandRequest}, feed with an random number
    *
    * Requirements:
    * - caller must have `ORACLE_ROLE`
    *
    * @param reqid request id of oracle rand request
    * @param randnum random number feed by oracle
    * @return rand number
    */
    function fulfillOracleRand(uint256 reqid, uint256 randnum) external returns (uint256 rand) {
        require(hasRole(ORACLE_ROLE, _msgSender()),"need oracle role");
        require(_oracleRandRequests[reqid] != address(0),"reqid not exist");

        rand = _seedRand(randnum);
        IXWorldOracleRandComsumer comsumer = IXWorldOracleRandComsumer(_oracleRandRequests[reqid]);
        comsumer.oracleRandResponse(reqid, rand);

        delete _oracleRandRequests[reqid];

        emit XWorldOracleRandResponse(reqid, rand, address(comsumer));

        return rand;
    }

    /**
    * @dev input index and random number, return with new random number depends on input
    * use chain blockhash as random array, we can fetch many random number with a seed in one transaction
    *
    * @param index a number increased by caller, make sure that we don't get same outcome
    * @param randomNum random number as seed
    * @return ret is new rand number
    */
    function nextRand(uint32 index, uint256 randomNum) external override view returns(uint256 ret){
        uint256 n1 = randomNum % block.number;
        uint256 h1 = uint256(blockhash(n1));

        return uint256(
            keccak256(
                abi.encodePacked(n1, h1, index)
            )
        );
    }

    function _seedRand(uint256 inputSeed) internal returns (uint256 ret) {
        require(block.number >= 1000,"block.number need >=1000");

        uint256 seed = uint256(
            keccak256(abi.encodePacked(block.number, block.timestamp, inputSeed))
        );

        uint32 n1 = uint32(seed % 100);
            
        uint32 n2 = uint32(seed % 1000);

        uint256 h1 = uint256(blockhash(block.number - n1));
  
        uint256 h2 = uint256(blockhash(block.number - n2));

        _nonce++;
        uint256 v = uint256(
            keccak256(abi.encodePacked(_randomSeed, h1, h2, _nonce))
        );

        return v;
    }

    // addr usually be tx.origin
    function _encodeSealedKey(address addr) internal view returns (uint256 key) {
        return uint256(
            keccak256(
                abi.encodePacked(addr, _msgSender())
            )
        );
    }

    function _sealedRand() internal returns (uint256 ret) {
    
        uint256 sealedKey = _encodeSealedKey(tx.origin);
        bool v = _isSealedDirect(sealedKey);
        require(v == true,"should sealed");

        RandomSeed storage rs = _sealedRandom[sealedKey];

        uint256 h2 = uint256(blockhash(rs.sealedNumber));
        ret = uint256(
            keccak256(
                abi.encodePacked(
                    rs.seed,
                    rs.h1,
                    h2,
                    block.difficulty,
                    rs.sealedNonce
                )
            )
        );

        delete _sealedRandom[sealedKey];

        return ret;
    }

    function _isSealedDirect(uint256 sealedKey) internal view returns (bool){
        return _sealedRandom[sealedKey].sealedNumber != 0;
    }

}

// contracts/XWorldRandomPool.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./XWorldRandom.sol";

/**
 * @dev Random pool that allow user random in different rate section
 */
library XWorldRandomPool {

    // random set with rate and range
    struct RandomSet {
        uint32 rate;
        uint rangMin;
        uint rangMax;
    }

    // random pool with an array of random set
    struct RandomPool {
        uint32 totalRate;
        RandomSet[] pool;
    }

    // initialize a random pool
    function initRandomPool(RandomPool storage pool) external {
        for(uint i=0; i< pool.pool.length; ++i){
            pool.totalRate += pool.pool[i].rate;
        }

        require(pool.totalRate > 0);
    }

    // use and randomNum to fetch a random result in the random set array
    function random(RandomPool storage pool, uint256 r) external view returns(uint ret) {
        require(pool.totalRate > 0);

        uint32 rate = uint32((r>>224) % pool.totalRate);
        uint32 curRate = 0;
        for(uint i=0; i<pool.pool.length; ++i){
            curRate += pool.pool[i].rate;
            if(rate > curRate){
                continue;
            }

            return randBetween(pool.pool[i].rangMin, pool.pool[i].rangMax, r);
        }
    }

    // input r and min,max, return a number between [min, max] with r
    function randBetween(
        uint256 min,
        uint256 max,
        uint256 r
    ) public pure returns (uint256 ret) {
        if(min >= max) {
            return min;
        }

        uint256 rang = (max+1) - min;
        return uint256(min + (r % rang));
    }
}

// contracts/XWorldMBRandomSourceBase.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Utility/XWorldRandom.sol";
import "../Utility/XWorldRandomPool.sol";

abstract contract XWorldMBRandomSourceBase is 
    Context, 
    AccessControl
{
    using XWorldRandomPool for XWorldRandomPool.RandomPool;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RANDOM_ROLE = keccak256("RANDOM_ROLE");

    struct NFTRandPool{
        bool exist;
        XWorldRandomPool.RandomPool randPool;
    }

    IXWorldRandom _rand;
    mapping(uint32 => NFTRandPool)    _randPools; // poolID => nft data random pools
    mapping(uint32 => uint32[])       _mbRandomSets; // mbTypeID => poolID array

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RANDOM_ROLE, _msgSender());
    }

    function setRandSource(address randAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()));

        _rand = IXWorldRandom(randAddr);
    }

    function getRandSource() external view returns(address) {
        // require(hasRole(MANAGER_ROLE, _msgSender()));
        return address(_rand);
    }
    function _addPool(uint32 poolID, XWorldRandomPool.RandomSet[] memory randSetArray) internal {
        NFTRandPool storage rp = _randPools[poolID];

        rp.exist = true;
        for(uint i=0; i<randSetArray.length; ++i){
            rp.randPool.pool.push(randSetArray[i]);
        }

        rp.randPool.initRandomPool();
    }

    function addPool(uint32 poolID, XWorldRandomPool.RandomSet[] memory randSetArray) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");
        require(!_randPools[poolID].exist,"rand pool already exist");

        _addPool(poolID, randSetArray);
    }

    function modifyPool(uint32 poolID, XWorldRandomPool.RandomSet[] memory randSetArray) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");
        require(_randPools[poolID].exist,"rand pool not exist");

        NFTRandPool storage rp = _randPools[poolID];

        delete rp.randPool.pool;

        for(uint i=0; i<randSetArray.length; ++i){
            rp.randPool.pool.push(randSetArray[i]);
        }

        rp.randPool.initRandomPool();
    }

    function removePool(uint32 poolID) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");
        require(_randPools[poolID].exist, "rand pool not exist");

        delete _randPools[poolID];
    }

    function getPool(uint32 poolID) public view returns(NFTRandPool memory) {
        require(_randPools[poolID].exist, "rand pool not exist");

        return _randPools[poolID];
    }

    function hasPool(uint32 poolID) external view returns(bool){
          return (_randPools[poolID].exist);
    }

    function setRandomSet(uint32 mbTypeID, uint32[] calldata poolIds) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");

        uint32[] storage poolIDArray = _mbRandomSets[mbTypeID];
        for(uint i=0; i< poolIds.length; ++i){
            poolIDArray.push(poolIds[i]);
        }
    }
    function unsetRandomSet(uint32 mbTypeID) external {
        require(hasRole(MANAGER_ROLE, _msgSender()),"not a manager");

        delete _mbRandomSets[mbTypeID];
    }
    function getRandomSet(uint32 mbTypeID) external view returns(uint32[] memory poolIds) {
        return _mbRandomSets[mbTypeID];
    }
    
    function randomNFTData(uint256 r, uint32 mbTypeID) virtual external view returns(bytes memory structDatas);
}

// contracts/IXWorldRandom.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IXWorldOracleRandComsumer {
    function oracleRandResponse(uint256 reqid, uint256 randnum) external;
}

interface IXWorldRandom {
    function seedRand(uint256 inputSeed) external returns(uint256 ret);
    function sealedRand() external returns(uint256 ret);
    function setSealed() external;
    function oracleRand() external returns (uint256 reqid);
    function nextRand(uint32 index, uint256 randomNum) external view returns(uint256 ret);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// contracts/XWorldGasFeeCharger.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library XWorldGasFeeCharger {

    struct MethodWithExrtraFee {
        address target;
        uint256 value;
    }

    struct MethodExtraFees {
        mapping(uint8=>MethodWithExrtraFee) extraFees;
    }

    function setMethodExtraFee(MethodExtraFees storage extraFees, uint8 methodKey, uint256 value, address target) internal {
        MethodWithExrtraFee storage fee = extraFees.extraFees[methodKey];
        fee.value = value;
        fee.target = target;
    }

    function removeMethodExtraFee(MethodExtraFees storage extraFees, uint8 methodKey) internal {
        delete extraFees.extraFees[methodKey];
    }

    function chargeMethodExtraFee(MethodExtraFees storage extraFees, uint8 methodKey)  internal returns(bool) {
        MethodWithExrtraFee storage fee = extraFees.extraFees[methodKey];
        if(fee.target == address(0)){
            return true; // no need charge fee
        }

        require(msg.value >= fee.value, "msg fee not enough");

        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, ) = fee.target.call{value: msg.value}("");
        require(sent, "Trans fee err");

        return sent;
    }
    
}

// contracts/XWorldMysteryBoxNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../XWorldNFT.sol";

struct XWorldMysteryBoxNFTMintOption {
    address to;
    uint32 mbType;
    uint32 mbTypeId;
}

contract XWorldMysteryBoxNFT is XWorldExtendableNFT {
    using Counters for Counters.Counter;

    event XWorldMysteryBoxNFTMint(address indexed to, uint256 indexed tokenId, uint32 mbType, uint32 mbTypeId);
    event XWorldMysteryBoxNFTBatchMint(uint256[] mintids);

    struct NFTData{
        uint32      mbType;
        uint32      mbTypeId;
    }

    mapping(uint256 => NFTData) private _nftDatas;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        XWorldExtendableNFT(name, symbol, baseTokenURI) 
    {
        // mint(_msgSender(), 0, 0, 0, new bytes(0));
    }

    function getMysteryBoxData(uint256 tokenId) external view returns(uint32 mbType, uint32 mbTypeId){
        NFTData storage data = _nftDatas[tokenId];
        mbType = data.mbType;
        mbTypeId = data.mbTypeId;
    }

    function batchMint(XWorldMysteryBoxNFTMintOption[] calldata options) public returns(uint256[] memory) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        uint32 len = uint32(options.length);
        uint256[] memory mintids = new uint256[](len);

        for (uint32 i = 0; i <len; i++) {
            XWorldMysteryBoxNFTMintOption memory op = options[i];
            uint256 curID = _tokenIdTracker.current();
            _mint(op.to, curID);
            NFTData storage nftData = _nftDatas[curID];
            nftData.mbType = op.mbType;
            nftData.mbTypeId = op.mbTypeId;
            mintids[i] = curID;
            _tokenIdTracker.increment();
        }
        emit XWorldMysteryBoxNFTBatchMint(mintids);

        return mintids;
    }

    function mint(address to, uint32 mbType, uint32 mbTypeId) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        NFTData storage nftData = _nftDatas[curID];
        nftData.mbType = mbType;
        nftData.mbTypeId = mbTypeId;

        emit XWorldMysteryBoxNFTMint(to, curID, mbType, mbTypeId);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }
}

// contracts/XWorldMysteryBoxBase.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Utility/IXWorldRandom.sol";
import "../Utility/XWorldGasFeeCharger.sol";

import "./XWorldMysteryBoxNFT.sol";
import "./XWorldMBRandomSourceBase.sol";

import "./XWorldMysteryBoxBase_History_V1.sol";

abstract contract XWorldMysteryBoxBase_V2 is 
    Context, 
    Pausable, 
    AccessControl,
    IXWorldOracleRandComsumer
{
    using XWorldGasFeeCharger for XWorldGasFeeCharger.MethodExtraFees;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");

    event XWorldOracleOpenMysteryBox(uint256 oracleRequestId, uint256 indexed mbTokenId, address owner);
    event XWorldOpenMysteryBox(uint256 indexed mbTokenId, uint256 indexed newTokenId, bytes nftData);

    struct MysteryBoxNFTData{
        address owner;
        uint32 mbType;
        uint32 mbTypeId;
    }
    struct UserData{
        uint256 tokenId;
        uint256 lockTime;
    }
    
    XWorldMysteryBoxNFT public _mbNFT;
    IXWorldMysteryBoxContentMinter public _minter;
    
    mapping(uint256 => MysteryBoxNFTData) _burnedTokens;
    mapping(uint32=>address) _randomDataSources; // indexed by mystery box type mbType
    mapping(uint256 => UserData) public _oracleUserData; // indexed by oracle request id

    // Method extra fee
    // For smart contract method which need extra transaction by other service, we define extra fee
    // extra fee charge by method call tx with `value` paramter, and send to target service wallet address
    XWorldGasFeeCharger.MethodExtraFees _methodExtraFees;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function getName() external virtual returns(string memory);

    function setNftAddress(address nftAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _mbNFT = XWorldMysteryBoxNFT(nftAddr);
    }

    function getNftAddress() external view returns(address) {
        return address(_mbNFT);
    }
    
    function setMysteryBoxContentMinter(address minter) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _minter = IXWorldMysteryBoxContentMinter(minter);
    }

    function setRandomSource(uint32 nftType, address randomSrc) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _randomDataSources[nftType] = randomSrc;
    }

    function getRandomSource(uint32 nftType) external view returns(address){
        return _randomDataSources[nftType];
    }

    /**
    * @dev set smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need extra fee
    * @param value extra fee value
    * @param target target address where extra fee goes to
    */
    function setMethodExtraFee(uint8 methodKey, uint256 value, address target) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldMysteryBox: must have manager role"
        );

        _methodExtraFees.setMethodExtraFee(methodKey, value, target);
    }

    /**
    * @dev cancel smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need cancel extra fee
    */
    function removeMethodExtraFee(uint8 methodKey) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldMysteryBox: must have manager role"
        );

        _methodExtraFees.removeMethodExtraFee(methodKey);
    }

    /**
    * @dev open mystery box, emit {XWorldOracleOpenMysteryBox}
    * call `oracleRand` in {IXWorldRandom} of address from `getRandSource` in {XWorldDCEquipMBRandomSource}
    * send a oracle random request and emit {XWorldOracleRandRequest}
    *
    * Extrafees:
    * - `oracleOpenMysteryBox` call need charge extra fee for `fulfillRandom` in {XWorldRandom} call by oracle service
    * - methodKey = 1, extra gas fee = 0.0013 with tx.value needed
    *
    * Requirements:
    * - caller must out side contract, not from contract
    * - caller must owner of `tokenId` in {XWorldMysteryBoxNFT}
    * - `tokenId` in {XWorldMysteryBoxNFT} must not freezed
    * - contract not paused
    *
    * @param tokenId token id of {XWorldMysteryBoxNFT}, if succeed, token will be burned
    */
    function oracleOpenMysteryBox(uint256 tokenId) external payable whenNotPaused {
        require(tx.origin == _msgSender(), "XWorldMysteryBox: only for outside account");
        require(_mbNFT.notFreezed(tokenId), "XWorldMysteryBox: freezed token");
        require(_mbNFT.ownerOf(tokenId) == _msgSender(), "XWorldMysteryBox: ownership check failed");

        MysteryBoxNFTData storage nftData = _burnedTokens[tokenId];
        nftData.owner = _msgSender();
        (nftData.mbType, nftData.mbTypeId) = _mbNFT.getMysteryBoxData(tokenId);
        
        address randSrcAddr = _randomDataSources[nftData.mbType];
        require(randSrcAddr != address(0), "XWorldMysteryBox: not a mystry box");
        
        address rndAddr = XWorldMBRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "XWorldMysteryBox: rand address wrong");

        _methodExtraFees.chargeMethodExtraFee(1); // charge oracleOpenMysteryBox extra fee

        _mbNFT.burn(tokenId);
        require(!_mbNFT.exists(tokenId), "XWorldMysteryBox: burn mystery box failed");

        uint256 reqid = IXWorldRandom(rndAddr).oracleRand();

        UserData storage userData = _oracleUserData[reqid];
        userData.tokenId = tokenId;
        userData.lockTime = block.timestamp;
        
        emit XWorldOracleOpenMysteryBox(reqid, tokenId, _msgSender());
    }

    // call back from random contract which triger by service call {fulfillOracleRand} function
    function oracleRandResponse(uint256 reqid, uint256 randnum) override external {
        require(hasRole(RAND_ROLE, _msgSender()), "XWorldMysteryBox: must have rand role");

        UserData storage userData = _oracleUserData[reqid];
        MysteryBoxNFTData storage nftData = _burnedTokens[userData.tokenId];

        require(nftData.owner != address(0), "XWorldMysteryBox: nftdata owner not exist");

        address randSrcAddr = _randomDataSources[nftData.mbType];
        require(randSrcAddr != address(0), "XWorldMysteryBox: not a mystry box");

        address rndAddr = XWorldMBRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "XWorldMysteryBox: rand address wrong");

        bytes memory contentNFTDatas = XWorldMBRandomSourceBase(randSrcAddr).randomNFTData(randnum, nftData.mbTypeId);
        uint256 newTokenId = _minter.mintContentAssets(nftData.owner, userData.tokenId, contentNFTDatas);

        delete _oracleUserData[reqid];
        delete _burnedTokens[userData.tokenId];

        emit XWorldOpenMysteryBox(userData.tokenId, newTokenId, contentNFTDatas);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "XWorldMysteryBox: must have pauser role to pause");
        _pause();
    }
    
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "XWorldMysteryBox: must have pauser role to unpause");
        _unpause();
    }
    
}

// contracts/XWorldNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract ERC721PresetMinterPauserAutoId is
    Context,
    AccessControl,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter internal _tokenIdTracker;

    string internal _baseTokenURI;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P1");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P2");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

/**
 * @dev Extension of {ERC721PresetMinterPauserAutoId} that allows token dynamic extend data section
 */
contract XWorldExtendableNFT is ERC721PresetMinterPauserAutoId {
    
    bytes32 public constant DATA_ROLE = keccak256("DATA_ROLE");

    /**
    * @dev emit when token has been freezed or unfreeze

    * @param tokenId freezed token id
    * @param freeze freezed or not
    */
    event XWorldNFTFreeze(uint256 indexed tokenId, bool freeze);
    
    /**
    * @dev emit when new data section created

    * @param extendName new data section name
    * @param nameBytes data section name after keccak256
    */
    event XWorldNFTExtendName(string extendName, bytes32 nameBytes);

    /**
    * @dev emit when token data section changed

    * @param tokenId tokenid which data has been changed
    * @param nameBytes data section name after keccak256
    * @param extendData data after change
    */
    event XWorldNFTExtendModify(uint256 indexed tokenId, bytes32 nameBytes, bytes extendData);

    // record of token already extended data section
    struct NFTExtendsNames{
        bytes32[]   NFTExtendDataNames; // array of data sectioin name after keccak256
    }

    // extend data mapping
    struct NFTExtendData {
        bool _exist;
        mapping(uint256 => bytes) ExtendDatas; // tokenid => data mapping
    }

    mapping(uint256 => bool) private _nftFreezed; // tokenid => is freezed
    mapping(uint256 => NFTExtendsNames) private _nftExtendNames; // tokenid => extended data sections
    mapping(bytes32 => NFTExtendData) private _nftExtendDataMap; // extend name => extend datas mapping

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        ERC721PresetMinterPauserAutoId(name, symbol, baseTokenURI) 
    {
    }

    /**
    * @dev freeze token, emit {XWorldNFTFreeze} event
    *
    * Requirements:
    * - caller must have `MINTER_ROLE`
    *
    * @param tokenId token to freeze
    */
    function freeze(uint256 tokenId) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "R2");

        _nftFreezed[tokenId] = true;

        emit XWorldNFTFreeze(tokenId, true);
    }

    /**
    * @dev unfreeze token, emit {XWorldNFTFreeze} event
    *
    * Requirements:
    * - caller must have `MINTER_ROLE`
    *
    * @param tokenId token to unfreeze
    */
    function unFreeze(uint256 tokenId) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "R3");

        delete _nftFreezed[tokenId];

        emit XWorldNFTFreeze(tokenId, false);
    }

    /**
    * @dev check token, return true if not freezed
    *
    * @param tokenId token to check
    * @return ture if token is not freezed
    */
    function notFreezed(uint256 tokenId) public view returns (bool) {
        return !_nftFreezed[tokenId];
    }

    /**
    * @dev check token, return true if it's freezed
    *
    * @param tokenId token to check
    * @return ture if token is freezed
    */
    function isFreezed(uint256 tokenId) public view returns (bool) {
        return _nftFreezed[tokenId];
    }

    /**
    * @dev check token, return true if it exists
    *
    * @param tokenId token to check
    * @return ture if token exists
    */
    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    /**
    * @dev add new token data section, emit {XWorldNFTExtendName} event
    *
    * Requirements:
    * - caller must have `MINTER_ROLE`
    *
    * @param extendName string of new data section name
    */
    function extendNftData(string memory extendName) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "R5");

        bytes32 nameBytes = keccak256(bytes(extendName));
        NFTExtendData storage extendData = _nftExtendDataMap[nameBytes];
        extendData._exist = true;

        emit XWorldNFTExtendName(extendName, nameBytes);
    }

    /**
    * @dev add extend token data with specify 'extendName', emit {XWorldNFTExtendModify} event
    *
    * Requirements:
    * - caller must have general `DATA_ROLE` or `DATA_ROLE` with the specify `extendName`
    *
    * @param tokenId token to add extend data
    * @param extendName data section name in string
    * @param extendData extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function addTokenExtendNftData(
        uint256 tokenId,
        string memory extendName,
        bytes memory extendData
    ) external whenNotPaused {
        require(
            hasRole(DATA_ROLE, _msgSender()) ||
                hasRole(
                    keccak256(abi.encodePacked("DATA_ROLE", extendName)),
                    _msgSender()
                ),
            "R6"
        );

        bytes32 nameBytes = keccak256(bytes(extendName));
        require(_extendNameExist(nameBytes), "E1");
        require(!_tokenExtendNameExist(tokenId, nameBytes), "E2");

        // modify extend data
        NFTExtendData storage extendDatas = _nftExtendDataMap[nameBytes];
        extendDatas.ExtendDatas[tokenId] = extendData;

        // save token extend data names
        NFTExtendsNames storage nftData = _nftExtendNames[tokenId];
        nftData.NFTExtendDataNames.push(nameBytes);

        emit XWorldNFTExtendModify(tokenId, nameBytes, extendData);
    }

    /**
    * @dev modify extend token data with specify 'extendName', emit {XWorldNFTExtendModify} event
    *
    * Requirements:
    * - caller must have general `DATA_ROLE` or `DATA_ROLE` with the specify `extendName`
    *
    * @param tokenId token to modify extend data
    * @param extendName data section name in string
    * @param extendData extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function modifyTokenExtendNftData(
        uint256 tokenId,
        string memory extendName,
        bytes memory extendData
    ) external whenNotPaused {
        require(
            hasRole(DATA_ROLE, _msgSender()) ||
                hasRole(
                    keccak256(abi.encodePacked("DATA_ROLE", extendName)),
                    _msgSender()
                ),
            "E3"
        );

        bytes32 nameBytes = keccak256(bytes(extendName));
        require(_extendNameExist(nameBytes), "E4");
        require(_tokenExtendNameExist(tokenId, nameBytes), "E5");

        // modify extend data
        NFTExtendData storage extendDatas = _nftExtendDataMap[nameBytes];
        extendDatas.ExtendDatas[tokenId] = extendData;

        emit XWorldNFTExtendModify(tokenId, nameBytes, extendData);
    }

    /**
    * @dev get extend token data with specify 'extendName'
    *
    * @param tokenId token to get extend data
    * @param extendName data section name in string
    * @return extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function getTokenExtendNftData(uint256 tokenId, string memory extendName)
        external
        view
        returns (bytes memory)
    {
        bytes32 nameBytes = keccak256(bytes(extendName));
        require(_extendNameExist(nameBytes), "E6");

        NFTExtendData storage extendDatas = _nftExtendDataMap[nameBytes];
        return extendDatas.ExtendDatas[tokenId];
    }

    function _extendNameExist(bytes32 nameBytes) internal view returns (bool) {
        return _nftExtendDataMap[nameBytes]._exist;
    }
    function _tokenExtendNameExist(uint256 tokenId, bytes32 nameBytes) internal view returns(bool) {
        NFTExtendsNames memory nftData = _nftExtendNames[tokenId];
        for(uint i=0; i<nftData.NFTExtendDataNames.length; ++i){
            if(nftData.NFTExtendDataNames[i] == nameBytes){
                return true;
            }
        }
        return false;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(notFreezed(tokenId), "F1");

        super._beforeTokenTransfer(from, to, tokenId);

        if (to == address(0)) {
            // delete token extend datas;
            NFTExtendsNames memory nftData = _nftExtendNames[tokenId];
            for(uint i = 0; i< nftData.NFTExtendDataNames.length; ++i){
                NFTExtendData storage extendData = _nftExtendDataMap[nftData.NFTExtendDataNames[i]];
                delete extendData.ExtendDatas[tokenId];
            }

            // delete token datas
            delete _nftExtendNames[tokenId];
        }
    }
}

struct XWorldNFTMintOption {
    address To;
    uint32 NFTType;
    uint32 NFTTypeID;
    uint256 NFTFixedData;
    bytes NFTUserData;
}

/**
 * @dev Extension of {XWorldExtendableNFT} that with fixed token data struct
 */
contract XWorldNFT is XWorldExtendableNFT {
    using Counters for Counters.Counter;
    
    /**
    * @dev emit when new token has been minted, see {NFTData}
    *
    * @param to owner of new token
    * @param tokenId new token id
    * @param nftType type
    * @param nftTypeID type id
    * @param nftFixedData fixed data
    * @param nftUserData user data in bytes, encode or decode by codec outside
    */
    event XWorldNFTMint(address indexed to, uint256 indexed tokenId, uint32 nftType, uint32 nftTypeID, uint256 nftFixedData, bytes nftUserData);
    
    /**
    * @dev emit when new token has been batch minted
    *
    * @param mintids new tokens id array
    */
    event XWorldNFTBatchMint(uint256[] mintids);

    /**
    * @dev emit when new token data has been changed
    *
    * @param tokenId token id which data changed
    * @param nftFixedData fixed data
    * @param nftUserData user data in bytes, encode or decode by codec outside
    */
    event XWorldNFTModify(uint256 indexed tokenId, uint256 nftFixedData, bytes nftUserData);

    // nft fixed data
    struct NFTData{
        uint32      NFTType; // type of nft, depends on user case
        uint32      NFTTypeID; // type id of nft, depends on user case
        uint256     NFTFixedData; // fixed data of nft, depends on user case
        bytes       NFTUserData; // user data in bytes, encode or decode by codec outside, depends on user case
    }

    mapping(uint256 => NFTData) private _nftDatas; // token id => nft data stucture

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        XWorldExtendableNFT(name, symbol, baseTokenURI)
    {
        mint(_msgSender(), 0, 0, 0, new bytes(0)); // mint first token to notify event scan
    }

    /**
     * @dev Creates a new token for `to`, emit {XWorldNFTBatchMint}. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     *
     * @param options new token mint data array
     * @return array of new token id
     */
    function batchMint(XWorldNFTMintOption[] calldata options) public returns(uint256[] memory) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        uint32 len = uint32(options.length);
        uint256[] memory mintids = new uint256[](len);

        for (uint32 i = 0; i <len; i++) {
            XWorldNFTMintOption memory op = options[i];
            uint256 curID = _tokenIdTracker.current();
            _mint(op.To, curID);
            NFTData storage nftData = _nftDatas[curID];
            nftData.NFTType = op.NFTType;
            nftData.NFTTypeID = op.NFTTypeID;
            nftData.NFTFixedData = op.NFTFixedData;
            nftData.NFTUserData = op.NFTUserData;
            mintids[i] = curID;
            _tokenIdTracker.increment();
        }
        emit XWorldNFTBatchMint(mintids);

        return mintids;
    }

    /**
     * @dev Creates a new token for `to`, emit {XWorldNFTMint}. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     *
     * @param to new token owner address
     * @param nftType type
     * @param nftTypeID type id
     * @param nftFixedData fixed data
     * @param nftUserData user data in bytes, encode or decode by codec outside
     * @return new token id
     */
    function mint(address to, uint32 nftType, uint32 nftTypeID, uint256 nftFixedData, bytes memory nftUserData) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        NFTData storage nftData = _nftDatas[curID];
        nftData.NFTType = nftType;
        nftData.NFTTypeID = nftTypeID;
        nftData.NFTFixedData = nftFixedData;
        nftData.NFTUserData = nftUserData;

        emit XWorldNFTMint(to, curID, nftType, nftTypeID, nftFixedData, nftUserData);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    /**
     * @dev modify token data, typ and type id can't be modified, emit {XWorldNFTModify}
     *
     * @param tokenId token id
     * @param nftFixedData new fixed data
     * @param nftUserData new user data in bytes, encode or decode by codec outside
     */
    function modifyNftData(uint256 tokenId, uint256 nftFixedData, bytes memory nftUserData) external whenNotPaused {
        require(hasRole(DATA_ROLE, _msgSender()), "R4");
        require(_exists(tokenId), "R5");

        // only modify user data
        NFTData storage nftData = _nftDatas[tokenId];
        nftData.NFTFixedData = nftFixedData;
        nftData.NFTUserData = nftUserData;

        emit XWorldNFTModify(tokenId, nftFixedData, nftUserData);
    }

    /**
     * @dev get token data
     *
     * @param tokenId token id
     * @return nftId token id
     * @return nftType type
     * @return nftTypeID type id
     * @return nftFixedData fixed data
     * @return nftUserData user data in bytes, encode or decode by codec outside
     */
    function getNftData(uint256 tokenId) external view returns(uint256 nftId, uint32 nftType, uint32 nftTypeID, uint256 nftFixedData, bytes memory nftUserData){
        require(_exists(tokenId), "T1");

        NFTData memory nftData = _nftDatas[tokenId];

        nftId = tokenId;
        nftType = nftData.NFTType;
        nftTypeID = nftData.NFTTypeID;
        nftFixedData = nftData.NFTFixedData;
        nftUserData = nftData.NFTUserData;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
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
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

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
        bytes memory _data
    ) public virtual override {
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
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
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
        return _owners[tokenId] != address(0);
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
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
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

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

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
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

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
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
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
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
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
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC721 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC721Pausable is ERC721, Pausable {
    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
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
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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

// contracts/XWorldMysteryBoxBase.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../Utility/IXWorldRandom.sol";
import "./XWorldMysteryBoxNFT.sol";
import "./XWorldMBRandomSourceBase.sol";

interface IXWorldMysteryBoxContentMinter {
    function mintContentAssets(address userAddr, uint256 mbTokenId, bytes memory nftDatas) external returns(uint256 tokenId);
}

abstract contract XWorldMysteryBoxBase is 
    Context, 
    Pausable, 
    AccessControl,
    IXWorldOracleRandComsumer
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");

    event XWorldOracleOpenMysteryBox(uint256 oracleRequestId, uint256 indexed mbTokenId, address owner);
    event XWorldOpenMysteryBox(uint256 indexed mbTokenId, uint256 indexed newTokenId, bytes nftData);

    struct MysteryBoxNFTData{
        address owner;
        uint32 mbType;
        uint32 mbTypeId;
    }
    struct UserData{
        uint256 tokenId;
        uint256 lockTime;
    }
    
    XWorldMysteryBoxNFT public _mbNFT;
    IXWorldMysteryBoxContentMinter public _minter;
    
    mapping(uint256 => MysteryBoxNFTData) _burnedTokens;
    mapping(uint32=>address) _randomDataSources; // indexed by mystery box type mbType
    mapping(uint256 => UserData) public _oracleUserData; // indexed by oracle request id

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function getName() external virtual returns(string memory);

    function setNftAddress(address nftAddr) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _mbNFT = XWorldMysteryBoxNFT(nftAddr);
    }

    function getNftAddress() external view returns(address) {
        return address(_mbNFT);
    }
    
    function setMysteryBoxContentMinter(address minter) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _minter = IXWorldMysteryBoxContentMinter(minter);
    }

    function setRandomSource(uint32 nftType, address randomSrc) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "XWorldMysteryBox: must have manager role to manage");
        _randomDataSources[nftType] = randomSrc;
    }

    function getRandomSource(uint32 nftType) external view returns(address){
        return _randomDataSources[nftType];
    }

    // request from user
    function oracleOpenMysteryBox(uint256 tokenId) external whenNotPaused {
        require(tx.origin == _msgSender(), "XWorldMysteryBox: only for outside account");
        require(_mbNFT.notFreezed(tokenId), "XWorldMysteryBox: freezed token");
        require(_mbNFT.ownerOf(tokenId) == _msgSender(), "XWorldMysteryBox: ownership check failed");

        MysteryBoxNFTData storage nftData = _burnedTokens[tokenId];
        nftData.owner = _msgSender();
        (nftData.mbType, nftData.mbTypeId) = _mbNFT.getMysteryBoxData(tokenId);
        
        address randSrcAddr = _randomDataSources[nftData.mbType];
        require(randSrcAddr != address(0), "XWorldMysteryBox: not a mystry box");
        
        address rndAddr = XWorldMBRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "XWorldMysteryBox: rand address wrong");

        _mbNFT.burn(tokenId);
        require(!_mbNFT.exists(tokenId), "XWorldMysteryBox: burn mystery box failed");

        uint256 reqid = IXWorldRandom(rndAddr).oracleRand();

        UserData storage userData = _oracleUserData[reqid];
        userData.tokenId = tokenId;
        userData.lockTime = block.timestamp;
        
        emit XWorldOracleOpenMysteryBox(reqid, tokenId, _msgSender());
    }

    // call back from random contract which triger by service call {fulfillOracleRand} function
    function oracleRandResponse(uint256 reqid, uint256 randnum) override external {
        require(hasRole(RAND_ROLE, _msgSender()), "XWorldMysteryBox: must have rand role");

        UserData storage userData = _oracleUserData[reqid];
        MysteryBoxNFTData storage nftData = _burnedTokens[userData.tokenId];

        require(nftData.owner != address(0), "XWorldMysteryBox: nftdata owner not exist");

        address randSrcAddr = _randomDataSources[nftData.mbType];
        require(randSrcAddr != address(0), "XWorldMysteryBox: not a mystry box");

        address rndAddr = XWorldMBRandomSourceBase(randSrcAddr).getRandSource();
        require(rndAddr != address(0), "XWorldMysteryBox: rand address wrong");

        bytes memory contentNFTDatas = XWorldMBRandomSourceBase(randSrcAddr).randomNFTData(randnum, nftData.mbTypeId);
        uint256 newTokenId = _minter.mintContentAssets(nftData.owner, userData.tokenId, contentNFTDatas);

        delete _oracleUserData[reqid];
        delete _burnedTokens[userData.tokenId];

        emit XWorldOpenMysteryBox(userData.tokenId, newTokenId, contentNFTDatas);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "XWorldMysteryBox: must have pauser role to pause");
        _pause();
    }
    
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "XWorldMysteryBox: must have pauser role to unpause");
        _unpause();
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// contracts/TransferHelper.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// contracts/XWorldDirectMysteryBox.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";
import "../Utility/XWorldGasFeeCharger.sol";

import "../Seriality/Seriality_1_0/SerialityUtility.sol";
import "../Seriality/Seriality_1_0/SerialityBuffer.sol";

import "../MysteryBoxes/XWorldMBRandomSourceBase.sol";
import "../MysteryBoxes/XWorldMysteryBoxBase.sol";

import "./XWorldDirectMysteryBox_History_V1.sol";

abstract contract XWorldDirectMysteryBox_V2 is 
    Context,
    Pausable,
    AccessControl,
    IXWorldOracleRandComsumer
{
    using XWorldGasFeeCharger for XWorldGasFeeCharger.MethodExtraFees;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");

    event XWorldDirectMBOpen(address indexed useAddr, uint32 mbTypeId, uint256 value);
    event XWorldDirectMBGetResult(address indexed useAddr, uint32 mbTypeId, uint256 newTokenId);

    struct DirectMBOpenRecord {
        address userAddr;
        uint32 mbTypeId;
    }

    XWorldMBRandomSourceBase public _mbRandSource;
    IXWorldMysteryBoxContentMinter public _contentMinter;
    IERC20 public _xwgToken;
    IXWGRecyclePoolManager public _xwgRecyclePoolMgr;
    address public _xwgRecyclePool;

    mapping(uint256=>DirectMBOpenRecord) public _openedRecord; // indexed by oracleRand request id
    mapping(uint32=>uint256) public _mbPrice; // indexed by mbtypeid;

    // Method extra fee
    // For smart contract method which need extra transaction by other service, we define extra fee
    // extra fee charge by method call tx with `value` paramter, and send to target service wallet address
    XWorldGasFeeCharger.MethodExtraFees _methodExtraFees;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function getName() public virtual returns(string memory);

    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have pauser role to unpause"
        );
        _unpause();
    }

    function setRandomSource(address randSource) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _mbRandSource = XWorldMBRandomSourceBase(randSource);
    }

    function setMinter(address minter) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _contentMinter = IXWorldMysteryBoxContentMinter(minter);
    }

    function setRecyclePool(address recyclePoolAddr, address recyclePoolMgrAddress) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _xwgRecyclePool = recyclePoolAddr;
        _xwgRecyclePoolMgr = IXWGRecyclePoolManager(recyclePoolMgrAddress);
    }

    function setXWGToken(address xwgToken) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _xwgToken = IERC20(xwgToken);
    }

    function setMBPrice(uint32 mbTypeId, uint256 price) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _mbPrice[mbTypeId] = price;
    }

    /**
    * @dev set smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need extra fee
    * @param value extra fee value
    * @param target target address where extra fee goes to
    */
    function setMethodExtraFee(uint8 methodKey, uint256 value, address target) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );

        _methodExtraFees.setMethodExtraFee(methodKey, value, target);
    }

    /**
    * @dev cancel smart contract method invoke by transaction with extra fee
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param methodKey key of which method need cancel extra fee
    */
    function removeMethodExtraFee(uint8 methodKey) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );

        _methodExtraFees.removeMethodExtraFee(methodKey);
    }

    /**
    * @dev direct open mystery box, emit {XWorldDirectMBOpen} event
    * call `oracleRand` in {IXWorldRandom} of address from `getRandSource` in {XWorldDCEquipMBRandomSource}
    * send a oracle random request and emit {XWorldOracleRandRequest}
    *
    * Extrafees:
    * - `openMB` call need charge extra fee for `fulfillRandom` in {XWorldRandom} call by oracle service
    * - methodKey = 1, extra gas fee = 0.0013 with tx.value needed
    *
    * Requirements:
    * - caller must out side contract, not from contract
    * - `_mbRandSource` must be set
    * - `_mbPrice` of `mbTypeId` must be set
    * - contract not paused
    *
    * @param mbTypeId mystery box type id
    */
    function openMB(uint32 mbTypeId) external payable whenNotPaused {
        require(tx.origin == _msgSender(), "XWorldDCEquipDirectMB: only for outside account");
        require(address(_mbRandSource) != address(0), "XWorldDCEquipDirectMB: equip random source need initialized");

        address rndAddr = XWorldMBRandomSourceBase(_mbRandSource).getRandSource();
        require(rndAddr != address(0), "XWorldDCEquipDirectMB: rand address wrong");

        uint256 price = _mbPrice[mbTypeId];
        //require(price > 0, "XWorldDCEquipDirectMB: mb not exist");

        _methodExtraFees.chargeMethodExtraFee(1); // charge openMB extra fee

        if(price > 0){
            require(_xwgToken.balanceOf(_msgSender()) >= price, "XWorldDCEquipDirectMB: insufficient token");

            if(address(_xwgRecyclePoolMgr) != address(0)) {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), _xwgRecyclePool, price);
                _xwgRecyclePoolMgr.changeRecycleBalance(0, price);
            }
            else {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), address(this), price);
            }
        }

        // request random number
        uint256 reqid = IXWorldRandom(rndAddr).oracleRand();

        DirectMBOpenRecord storage openRec = _openedRecord[reqid];
        openRec.mbTypeId = mbTypeId;
        openRec.userAddr = _msgSender();

        // emit direct mb open event
        emit XWorldDirectMBOpen(_msgSender(), mbTypeId, price);
    }

    // get rand number, real open mystery box
    function oracleRandResponse(uint256 reqid, uint256 randnum) override external {
        require(hasRole(RAND_ROLE, _msgSender()), "XWorldDCEquipDirectMB: must have rand role");
        require(address(_contentMinter) != address(0), "XWorldDCEquipDirectMB: mb minter need initialized");
        require(address(_mbRandSource) != address(0), "XWorldDCEquipDirectMB: mb random source need initialized");

        address rndAddr = XWorldMBRandomSourceBase(_mbRandSource).getRandSource();
        require(rndAddr != address(0), "XWorldDCEquipDirectMB: rand address wrong");

        DirectMBOpenRecord storage openRec = _openedRecord[reqid];

        require(openRec.userAddr != address(0), "XWorldDCEquipDirectMB: user address wrong");

        // dispatch equipment
        bytes memory contentNFTDatas = XWorldMBRandomSourceBase(_mbRandSource).randomNFTData(randnum, openRec.mbTypeId);
        uint256 newTokenId = _contentMinter.mintContentAssets(openRec.userAddr, 0, contentNFTDatas);

        // emit direct mb result event
        emit XWorldDirectMBGetResult(openRec.userAddr, openRec.mbTypeId, newTokenId);
    }
}

// contracts/XWorldDirectMysteryBox.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";

import "../Seriality/Seriality_1_0/SerialityUtility.sol";
import "../Seriality/Seriality_1_0/SerialityBuffer.sol";

import "../MysteryBoxes/XWorldMBRandomSourceBase.sol";
import "../MysteryBoxes/XWorldMysteryBoxBase.sol";

interface IXWGRecyclePoolManager {
    // methType = 0 : lock, methType = 1 : unlock;
    function changeRecycleBalance(uint256 methType, uint256 amount) external;
}

abstract contract XWorldDirectMysteryBox is 
    Context,
    Pausable,
    AccessControl,
    IXWorldOracleRandComsumer
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant RAND_ROLE = keccak256("RAND_ROLE");

    event XWorldDirectMBOpen(address indexed useAddr, uint32 mbTypeId, uint256 value);
    event XWorldDirectMBGetResult(address indexed useAddr, uint32 mbTypeId, uint256 newTokenId);

    struct DirectMBOpenRecord {
        address userAddr;
        uint32 mbTypeId;
    }

    XWorldMBRandomSourceBase public _mbRandSource;
    IXWorldMysteryBoxContentMinter public _contentMinter;
    IERC20 public _xwgToken;
    IXWGRecyclePoolManager public _xwgRecyclePoolMgr;
    address public _xwgRecyclePool;

    mapping(uint256=>DirectMBOpenRecord) public _openedRecord; // indexed by oracleRand request id
    mapping(uint32=>uint256) public _mbPrice; // indexed by mbtypeid;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(RAND_ROLE, _msgSender());
    }

    function getName() public virtual returns(string memory);

    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "XWorldDCLevel: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "XWorldDCLevel: must have pauser role to unpause"
        );
        _unpause();
    }

    function setRandomSource(address randSource) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _mbRandSource = XWorldMBRandomSourceBase(randSource);
    }

    function setMinter(address minter) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _contentMinter = IXWorldMysteryBoxContentMinter(minter);
    }

    function setRecyclePool(address recyclePoolAddr, address recyclePoolMgrAddress) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _xwgRecyclePool = recyclePoolAddr;
        _xwgRecyclePoolMgr = IXWGRecyclePoolManager(recyclePoolMgrAddress);
    }

    function setXWGToken(address xwgToken) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _xwgToken = IERC20(xwgToken);
    }

    function setMBPrice(uint32 mbTypeId, uint256 price) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "XWorldDCEquipDirectMB: must have manager role"
        );
        _mbPrice[mbTypeId] = price;
    }

    // direct open mystery box
    function openMB(uint32 mbTypeId) external whenNotPaused {
        require(tx.origin == _msgSender(), "XWorldDCEquipDirectMB: only for outside account");
        require(address(_mbRandSource) != address(0), "XWorldDCEquipDirectMB: equip random source need initialized");

        address rndAddr = XWorldMBRandomSourceBase(_mbRandSource).getRandSource();
        require(rndAddr != address(0), "XWorldDCEquipDirectMB: rand address wrong");

        uint256 price = _mbPrice[mbTypeId];
        require(price > 0, "XWorldDCEquipDirectMB: mb not exist");

        if(price > 0){
            require(_xwgToken.balanceOf(_msgSender()) >= price, "XWorldDCEquipDirectMB: insufficient token");

            if(address(_xwgRecyclePoolMgr) != address(0)) {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), _xwgRecyclePool, price);
                _xwgRecyclePoolMgr.changeRecycleBalance(0, price);
            }
            else {
                TransferHelper.safeTransferFrom(address(_xwgToken), _msgSender(), address(this), price);
            }
        }

        // request random number
        uint256 reqid = IXWorldRandom(rndAddr).oracleRand();

        DirectMBOpenRecord storage openRec = _openedRecord[reqid];
        openRec.mbTypeId = mbTypeId;
        openRec.userAddr = _msgSender();

        // emit direct mb open event
        emit XWorldDirectMBOpen(_msgSender(), mbTypeId, price);
    }

    // get rand number, real open mystery box
    function oracleRandResponse(uint256 reqid, uint256 randnum) override external {
        require(hasRole(RAND_ROLE, _msgSender()), "XWorldMysteryBox: must have rand role");
        require(address(_contentMinter) != address(0), "XWorldDCEquipDirectMB: mb minter need initialized");
        require(address(_mbRandSource) != address(0), "XWorldDCEquipDirectMB: mb random source need initialized");

        address rndAddr = XWorldMBRandomSourceBase(_mbRandSource).getRandSource();
        require(rndAddr != address(0), "XWorldDCEquipDirectMB: rand address wrong");

        DirectMBOpenRecord storage openRec = _openedRecord[reqid];

        require(openRec.userAddr != address(0), "XWorldDCEquipDirectMB: user address wrong");

        // dispatch equipment
        bytes memory contentNFTDatas = XWorldMBRandomSourceBase(_mbRandSource).randomNFTData(randnum, openRec.mbTypeId);
        uint256 newTokenId = _contentMinter.mintContentAssets(openRec.userAddr, 0, contentNFTDatas);

        // emit direct mb result event
        emit XWorldDirectMBGetResult(openRec.userAddr, openRec.mbTypeId, newTokenId);
    }
}

// contracts/XWorld1155.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";


/**
 * @dev {ERC1155} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract ERC1155PresetMinterPauser is Context, AccessControl, ERC1155Burnable, ERC1155Pausable, ERC1155Supply {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `PAUSER_ROLE` to the account that
     * deploys the contract.
     */
    constructor(string memory uri) ERC1155(uri) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

contract XWorldExtendable1155 is ERC1155PresetMinterPauser {
    
    bytes32 public constant DATA_ROLE = keccak256("DATA_ROLE");

    /**
    * @dev emit when token data section changed

    * @param id 1155 id which data has been changed
    * @param extendData data after change
    */
    event XWorldExtned1155Modify(uint256 indexed id, bytes extendData);

    mapping(uint256=>bytes) _extendDatas;


    constructor(string memory uri) ERC1155PresetMinterPauser(uri) {

    }

    /**
    * @dev modify extend 1155 data, emit {XWorldExtned1155Modify} event
    *
    * Requirements:
    * - caller must have general `DATA_ROLE`
    *
    * @param id 1155 id to modify extend data
    * @param extendData extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function modifyExtendData(
        uint256 id,
        bytes memory extendData
    ) external whenNotPaused {
        require(
            hasRole(DATA_ROLE, _msgSender()),
            "E3"
        );

        require(
            exists(id),
            "E4"
        );

        // modify extend data
        _extendDatas[id] = extendData;

        emit XWorldExtned1155Modify(id, extendData);
    }

    /**
    * @dev get extend 1155 data 
    *
    * @param id 1155 id to get extend data
    * @return extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function getTokenExtendNftData(uint256 id)
        external
        view
        returns (bytes memory)
    {
        require(exists(id), "E6");

        return _extendDatas[id];
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC1155 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Pausable is ERC1155, Pausable {
    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}