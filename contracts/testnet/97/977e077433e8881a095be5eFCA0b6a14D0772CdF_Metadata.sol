// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMetadata.sol";
import "./interfaces/INFT.sol";

contract Metadata is AccessControl, IMetadata {
    /** ===== CONSTANTS ===== **/
    bytes32 public constant DAO = keccak256("DAO");

    using Strings for uint256;

    // 10 + 11 to get the index of level attribut
    uint256 private levelTypeIndex = 31;

    // struct to store each meta's data for metadata and rendering
    struct Meta {
        string name;
        string png;
    }

    string transparentPicture =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

    /** ===== SEMI-CONSTANTS ===== **/

    INFT public masterAndSlave;

    // string masterBackground = transparentPicture; //"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

    // string slaveBackground = transparentPicture; //"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

    string waitingRevealImage = transparentPicture; //"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

    bool reveal = false;

    // mapping from levelIndex to its score
    string[11] levels = [
        "11",
        "10",
        "9",
        "8",
        "7",
        "6",
        "5",
        "4",
        "3",
        "2",
        "1"
    ];

    // mapping from meta type (index) to its name
    string[10] metaTypes = [
        // Layer 0
        "Background",
        // Layer 1
        "Clothes",
        // Layer 2
        "Gun",
        // Layer 3
        "Head",
        // Layer 4
        "",
        // Layer 5
        "",
        // Layer 6
        "",
        // Layer 7
        "",
        // Layer 8
        "",
        // Layer 9
        ""
        // // Layer 10
        // "",
        // // Layer 11
        // ""
    ];

    /** ===== VARIABLES ===== **/

    // storage of each metadata name and base64 PNG data
    mapping(uint8 => mapping(uint8 => Meta)) public metaData;
    mapping(uint8 => uint8) public metaCountForType;

    /** ===== CONSTRUCTOR ===== **/

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(DAO, msg.sender);
    }

    /** ===== VIEW METHODS ===== **/

    function selectMeta(uint16 seed, uint8 metaType)
        external
        view
        override
        returns (uint8)
    {
        uint256 chance = seed % 100;
        if (metaType == levelTypeIndex) {
            if (chance > 98) {
                //2%
                return 0;
            } else if (chance > 96) {
                //2%
                return 1;
            } else if (chance > 94) {
                //2%
                return 2;
            } else if (chance > 92) {
                //2%
                return 3;
            } else if (chance > 90) {
                //2%
                return 4;
            } else if (chance > 75) {
                //15%
                return 5;
            } else if (chance > 60) {
                //15%
                return 6;
            } else if (chance > 45) {
                //15%
                return 7;
            } else if (chance > 30) {
                //15%
                return 8;
            } else if (chance > 15) {
                //15%
                return 9;
            } else {
                //15%
                return 10;
            }
        }

        if (chance > 60) {
            //40%
            return 0;
        } else if (chance > 35) {
            //25%
            return 1;
        } else if (chance > 15) {
            //20%
            return 2;
        } else if (chance > 5) {
            //10%
            return 3;
        } else {
            //5%
            return 4;
        }

        // uint8 modOf = metaCountForType[metaType] > 0 ? metaCountForType[metaType] : 10;
        // return uint8(seed % modOf);
    }

    /**
     * generates an <image> element using base64 encoded PNGs
     * @param meta the meta storing the PNG data
     * @return the <image> element
     */
    function drawMeta(Meta memory meta) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    meta.png,
                    '"/>'
                )
            );
    }

    function draw(string memory png) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    png,
                    '"/>'
                )
            );
    }

    /**
     * generates an entire SVG by composing multiple <image> elements of PNGs
     * @param tokenId the ID of the token to generate an SVG for
     *
     */
    function drawSVG(uint256 tokenId) public view returns (string memory) {
        INFT.NFTMetadata memory s = masterAndSlave.getTokenMetadata(tokenId);
        uint8 shift = s.Shift;

        string memory Layer0 = string(
            abi.encodePacked(
                //Layer 0
                drawMeta(
                    metaData[0 + shift][s.Layer0 % metaCountForType[0 + shift]]
                ),
                // // Picture of Slave Or Master
                // s.isSlave ? draw(slaveBackground) : draw(masterBackground),
                //Layer 1
                drawMeta(
                    metaData[1 + shift][s.Layer1 % metaCountForType[1 + shift]]
                ),
                //Layer 2
                drawMeta(
                    metaData[2 + shift][s.Layer2 % metaCountForType[2 + shift]]
                ),
                //Layer 3
                drawMeta(
                    metaData[3 + shift][s.Layer3 % metaCountForType[3 + shift]]
                ),
                //Layer 4
                drawMeta(
                    metaData[4 + shift][s.Layer4 % metaCountForType[4 + shift]]
                ),
                //Layer 5
                drawMeta(
                    metaData[5 + shift][s.Layer5 % metaCountForType[5 + shift]]
                ),
                //Layer 6
                drawMeta(
                    metaData[6 + shift][s.Layer6 % metaCountForType[6 + shift]]
                )
            )
        );

        string memory Layer1 = string(
            abi.encodePacked(
                //Layer 7
                drawMeta(
                    metaData[7 + shift][s.Layer7 % metaCountForType[7 + shift]]
                ),
                //Layer 8
                drawMeta(
                    metaData[8 + shift][s.Layer8 % metaCountForType[8 + shift]]
                ),
                //Layer 9
                drawMeta(
                    metaData[9 + shift][s.Layer9 % metaCountForType[9 + shift]]
                )
                // // Master Extra 20
                // !s.isSlave ? drawMeta(metaData[10 + shift][s.masterAttribut % metaCountForType[10 + shift]]) : '',
                // Master Extra 21
                //!s.isSlave ? drawMeta(metaData[11 + shift][s.levelIndex]) : ''
            )
        );

        string memory svgString = string(abi.encodePacked(Layer0, Layer1));

        // If the collection is not reveal yet we print a waiting image
        if (!reveal) {
            svgString = string(abi.encodePacked(draw(waitingRevealImage)));
        }

        return
            string(
                abi.encodePacked(
                    '<svg id="NavySealGame" width="100%" height="100%" version="1.1" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    svgString,
                    "</svg>"
                )
            );
    }

    /**
     * generates an attribute for the attributes array in the ERC721 metadata standard
     * @param metaType the meta type to reference as the metadata key
     * @param value the token's meta associated with the key
     * @return a JSON dictionary for the single attribute
     */
    function attributeForTypeAndValue(
        string memory metaType,
        string memory value
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "{",
                    '"trait_type":"',
                    metaType,
                    '","value":"',
                    value,
                    '"},'
                )
            );
    }

    /**
     * generates an array composed of all the individual metadata and values
     * @param tokenId the ID of the token to compose the metadata for
     * @return a JSON array of all of the attributes for given token ID
     */
    function compileAttributes(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        INFT.NFTMetadata memory s = masterAndSlave.getTokenMetadata(tokenId);
        uint8 shift = s.Shift;

        string memory Layer0 = string(
            abi.encodePacked(
                attributeForTypeAndValue(
                    metaTypes[0],
                    metaData[0 + shift][s.Layer0 % metaCountForType[0 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[1],
                    metaData[1 + shift][s.Layer1 % metaCountForType[1 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[2],
                    metaData[2 + shift][s.Layer2 % metaCountForType[2 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[3],
                    metaData[3 + shift][s.Layer3 % metaCountForType[3 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[4],
                    metaData[4 + shift][s.Layer4 % metaCountForType[4 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[5],
                    metaData[5 + shift][s.Layer5 % metaCountForType[5 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[6],
                    metaData[6 + shift][s.Layer6 % metaCountForType[6 + shift]]
                        .name
                )
            )
        );

        string memory Layer1 = string(
            abi.encodePacked(
                attributeForTypeAndValue(
                    metaTypes[7],
                    metaData[7 + shift][s.Layer7 % metaCountForType[7 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[8],
                    metaData[8 + shift][s.Layer8 % metaCountForType[8 + shift]]
                        .name
                ),
                attributeForTypeAndValue(
                    metaTypes[9],
                    metaData[9 + shift][s.Layer9 % metaCountForType[9 + shift]]
                        .name
                ),
                // !s.isSlave ? attributeForTypeAndValue(metaTypes[10], metaData[10 + shift][s.masterAttribut % metaCountForType[10 + shift]].name) : '',
                // !s.isSlave ? attributeForTypeAndValue(metaTypes[11], metaData[11 + shift][s.levelIndex % metaCountForType[11 + shift]].name) : '',
                !s.isSlave
                    ? attributeForTypeAndValue("Rank", levels[s.levelIndex])
                    : "",
                s.Shift == 20
                    ? attributeForTypeAndValue(
                        "Description",
                        "This is the mighty POTUS, the commander-in-chief, the guardian of America, the supreme commander that will bring power to all Navy Seals and death to all its enemies."
                    )
                    : ""
            )
        );

        string memory metadata = string(abi.encodePacked(Layer0, Layer1));

        // if (s.Shift == 20) {
        //     metadata = string(abi.encodePacked(
        //         attributeForTypeAndValue("Description","This is the mighty POTUS, the commander-in-chief, the guardian of America, the supreme commander that will bring power to all Navy Seals and death to all its enemies."),
        //         attributeForTypeAndValue("Ranks", levels[s.levelIndex])
        //     ));
        // }

        return
            string(
                abi.encodePacked(
                    "[",
                    metadata,
                    "{",
                    '"trait_type":"Generation","value":',
                    tokenId <= masterAndSlave.getPaidTokens()
                        ? '"Gen 0"'
                        : '"Gen 1"',
                    "},{",
                    '"trait_type":"Team","value":',
                    s.isSlave ? "Terrorist #" : (s.Shift == 10)
                        ? "NavySeal #"
                        : "POTUS #",
                    // s.isSlave ? '"Terrorist"' : '"NavySeal"',
                    "}]"
                )
            );
    }

    /**
     * generates a base64 encoded metadata response without referencing off-chain content
     * @param tokenId the ID of the token to generate the metadata for
     * @return a base64 encoded JSON dictionary of the token's metadata and SVG
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        INFT.NFTMetadata memory s = masterAndSlave.getTokenMetadata(tokenId);

        string memory metadataGame = string(
            abi.encodePacked(
                "{",
                '"name": "',
                s.isSlave ? "Terrorist #" : (s.Shift == 10)
                    ? "NavySeal #"
                    : "POTUS #",
                tokenId.toString(),
                '", "description":  "The Navy Seal Game is a new risk-to-earn NFT game on the Avalanche blockchain inspired by the world famous video game Counter Strike. Terrorists are planning to attack the U.S. with $TNT, will Navy Seals be able to stop them ? Will you choose to play in the terrorist team and suceed to run away with your $TNT ? Or will you choose to play in the Navy Seal team to capture the terrorists and seize all the $TNT they produced ? Welcome to the Navy Seal Game. All the metadata and images are generated and stored 100% on-chain.", "image": "data:image/svg+xml;base64,',
                base64(bytes(drawSVG(tokenId))),
                '", "attributes":',
                compileAttributes(tokenId),
                "}"
            )
        );

        // If the collection is not reveal yet we print a waiting image
        if (!reveal) {
            metadataGame = string(
                abi.encodePacked(
                    "{",
                    '"name": "',
                    "Navy Seal Game #",
                    tokenId.toString(),
                    '", "description":  "The Navy Seal Game is a new risk-to-earn NFT game on the Avalanche blockchain inspired by the world famous video game Counter Strike. Terrorists are planning to attack the U.S. with $TNT, will Navy Seals be able to stop them ? Will you choose to play in the terrorist team and suceed to run away with your $TNT ? Or will you choose to play in the Navy Seal team to capture the terrorists and seize all the $TNT they produced ? Welcome to the Navy Seal Game. All the metadata and images are generated and stored 100% on-chain.", "image": "data:image/svg+xml;base64,',
                    base64(bytes(drawSVG(tokenId))),
                    '", "attributes": [',
                    attributeForTypeAndValue("Status", "Unrevealed"),
                    "]}"
                )
            );
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    base64(bytes(metadataGame))
                )
            );
    }

    /***BASE 64 - Written by Brech Devos */
    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function base64(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }

    /** ===== ROLE MANAGEMENT ===== **/

    function grantDAORole(address _dao) external onlyRole(DAO) {
        grantRole(DAO, _dao);
    }

    function revokeDAO(address _DaoToRevoke) external onlyRole(DAO) {
        revokeRole(DAO, _DaoToRevoke);
    }

    /** ===== DAO METHODS ===== **/

    /**
     * administrative to upload the names and images associated with each meta
     * @param metaType the meta type to upload the metadata for (see metaTypes for a mapping)
     * @param metadata the names and base64 encoded PNGs for each meta
     */

    function uploadMetadata(
        uint8 metaType,
        uint8[] calldata metaIds,
        Meta[] calldata metadata
    ) external onlyRole(DAO) {
        require(metaIds.length == metadata.length, "Mismatched inputs");
        for (uint256 i = 0; i < metadata.length; i++) {
            metaData[metaType][metaIds[i]] = Meta(
                metadata[i].name,
                metadata[i].png
            );
        }
    }

    function setMetaCountForType(uint8[] memory _tType, uint8[] memory _len)
        public
        onlyRole(DAO)
    {
        for (uint256 i = 0; i < _tType.length; i++) {
            metaCountForType[_tType[i]] = _len[i];
        }
    }

    // Withdraws an amount of BNB stored on the contract
    function withdrawDAO(uint256 _amount) external onlyRole(DAO) {
        payable(msg.sender).transfer(_amount);
    }

    // Withdraws an amount of ERC20 tokens stored on the contract
    function withdrawERC20DAO(address _erc20, uint256 _amount)
        external
        onlyRole(DAO)
    {
        IERC20(_erc20).transfer(msg.sender, _amount);
    }

    /** ===== SETTERS ===== **/

    function setGame(address _masterAndSlave) external onlyRole(DAO) {
        masterAndSlave = INFT(_masterAndSlave);
    }

    // function uploadBackgroundMaster(string calldata _master) external onlyRole(DAO) {
    //     masterBackground = _master;
    // }

    // function uploadBackgroundSlave(string calldata _slave) external onlyRole(DAO) {
    //     slaveBackground = _slave;
    // }

    function uploadWaitingRevealImage(string calldata _waitingRevealImage)
        external
        onlyRole(DAO)
    {
        waitingRevealImage = _waitingRevealImage;
    }

    function setReveal(bool _reveal) external onlyRole(DAO) {
        reveal = _reveal;
    }

    function setLevels(string[4] memory _levels) external onlyRole(DAO) {
        levels = _levels;
    }

    function setMetaTypes(string[10] memory _metaTypes) external onlyRole(DAO) {
        metaTypes = _metaTypes;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IMetadata {
    function tokenURI(uint256 tokenId) external view returns (string memory);

    function selectMeta(uint16 seed, uint8 metaType)
        external
        view
        returns (uint8);
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface INFT {
    // struct to store each token's metas
    struct NFTMetadata {
        bool isSlave;
        //uint8 masterAttribut;
        uint8 levelIndex;
        //Shift tell the kind of NFT you have 0:slave ; 10:master ; 20:POTUS
        uint8 Shift;
        uint8 Layer0;
        uint8 Layer1;
        uint8 Layer2;
        uint8 Layer3;
        uint8 Layer4;
        uint8 Layer5;
        uint8 Layer6;
        uint8 Layer7;
        uint8 Layer8;
        uint8 Layer9;
    }

    function getPaidTokens() external view returns (uint256);

    function getTokenMetadata(uint256 tokenId)
        external
        view
        returns (NFTMetadata memory);

    function addAirdrops(address[] calldata accounts, uint256[] calldata values)
        external;

    function addWhiteList(
        address[] calldata accounts,
        uint256[] calldata values
    ) external;

    function withdraw() external;

    function setPaused(bool _paused) external;

    function setMINT_PRICE(uint256 _price) external;

    function setWhiteList(bool _OnlyWhiteList) external;
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