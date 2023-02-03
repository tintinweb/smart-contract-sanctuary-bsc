// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./internal-upgradeable/BKFundForwarderUpgradeable.sol";

import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721PermitUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import "oz-custom/contracts/presets-upgradeable/base/ManagerUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProtocolFeeUpgradeable.sol";

import "./interfaces/IBK721.sol";
import "./interfaces/IBKTreasury.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/StringLib.sol";

abstract contract BK721 is
    IBK721,
    ManagerUpgradeable,
    ProtocolFeeUpgradeable,
    ERC721PermitUpgradeable,
    BKFundForwarderUpgradeable,
    ERC721EnumerableUpgradeable
{
    using SSTORE2 for *;
    using Bytes32Address for *;
    using StringLib for uint256;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    ///@dev value is equal to keccak256("Swap(address user,uint256 toId,uint256 deadline,uint256 nonce,uint256[] fromIds)")
    bytes32 private constant __MERGE_TYPE_HASH =
        0x085ba72701c4339ed5b893f5421cabf9405901f059ff0c12083eb0b1df6bc19a;

    bytes32 public version;
    bytes32 private _baseTokenURIPtr;
    mapping(uint256 => uint256) public typeIdTrackers;

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function setBaseURI(
        string calldata baseURI_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        _setBaseURI(baseURI_);
    }

    function merge(
        uint256[] calldata fromIds_,
        uint256 toId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external {
        if (block.timestamp > deadline_) revert BK721__Expired();

        if (_ownerOf[toId_] != 0) revert BK721__AlreadyMinted();

        address user = _msgSender();
        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(
                    keccak256(
                        abi.encode(
                            __MERGE_TYPE_HASH,
                            user,
                            toId_,
                            deadline_,
                            _useNonce(user.fillLast12Bytes()), // @dev resitance to reentrancy
                            keccak256(abi.encodePacked(fromIds_))
                        )
                    ),
                    signature_
                )
            )
        ) revert BK721__InvalidSignature();

        uint256 length = fromIds_.length;
        uint256 fromId;
        for (uint256 i; i < length; ) {
            fromId = fromIds_[i];
            if (ownerOf(fromId) != user) revert BK721__Unauthorized();
            _burn(fromId);
            unchecked {
                ++i;
            }
        }

        __mintTransfer(user, toId_);

        emit Merged(user, fromIds_, toId_);
    }

    function setRoyalty(
        IERC20Upgradeable feeToken_,
        uint96 feeAmt_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        if (!IBKTreasury(vault()).supportedPayment(address(feeToken_)))
            revert BK721__TokenNotSupported();

        _setRoyalty(feeToken_, feeAmt_);

        emit ProtocolFeeUpdated(_msgSender(), feeToken_, feeAmt_);
    }

    function safeMint(
        address to_,
        uint256 typeId_
    ) external onlyRole(Roles.PROXY_ROLE) returns (uint256 tokenId) {
        unchecked {
            _safeMint(
                to_,
                tokenId = (typeId_ << 32) | typeIdTrackers[typeId_]++
            );
        }
    }

    function mint(
        address to_,
        uint256 typeId_
    ) external onlyRole(Roles.MINTER_ROLE) returns (uint256 tokenId) {
        unchecked {
            _mint(to_, tokenId = (typeId_ << 32) | typeIdTrackers[typeId_]++);
        }
    }

    function mintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external onlyRole(Roles.MINTER_ROLE) returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](length_);
        uint256 cursor = nextIdFromType(typeId_);
        for (uint256 i; i < length_; ) {
            unchecked {
                _mint(to_, tokenIds[i] = cursor);
                ++cursor;
                ++i;
            }
        }
        typeIdTrackers[typeId_] = cursor;
        emit BatchMinted(_msgSender(), to_, length_);
    }

    function safeMintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external onlyRole(Roles.PROXY_ROLE) returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](length_);
        uint256 cursor = nextIdFromType(typeId_);
        for (uint256 i; i < length_; ) {
            unchecked {
                _safeMint(to_, tokenIds[i] = cursor);
                ++cursor;
                ++i;
            }
        }
        typeIdTrackers[typeId_] = cursor;
        emit BatchMinted(_msgSender(), to_, length_);
    }

    function baseURI() external view returns (string memory) {
        return string(_baseTokenURIPtr.read());
    }

    function metadataOf(
        uint256 tokenId_
    ) external view returns (uint256 typeId, uint256 index) {
        if (_ownerOf[tokenId_] == 0) revert BK721__NotMinted();
        typeId = tokenId_ >> 32;
        index = tokenId_ & ~uint32(0);
    }

    function nextIdFromType(uint256 typeId_) public view returns (uint256) {
        unchecked {
            return (typeId_ << 32) | (typeIdTrackers[typeId_] + 1);
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _baseTokenURIPtr.read(),
                    address(this),
                    "/",
                    tokenId.toString()
                )
            );
    }

    function supportsInterface(
        bytes4 interfaceId_
    )
        public
        view
        virtual
        override(
            ERC721Upgradeable,
            IERC165Upgradeable,
            ERC721EnumerableUpgradeable
        )
        returns (bool)
    {
        return
            type(IERC165Upgradeable).interfaceId == interfaceId_ ||
            super.supportsInterface(interfaceId_);
    }

    function _setBaseURI(string calldata baseURI_) internal {
        _baseTokenURIPtr = bytes(baseURI_).write();
    }

    function __BK_init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint96 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_,
        bytes32 version_
    ) internal onlyInitializing {
        __ERC721Permit_init(name_, symbol_);
        __Manager_init_unchained(authority_, 0);
        __ERC721_init_unchained(name_, symbol_);
        __ProtocolFee_init_unchained(feeToken_, feeAmt_);
        __FundForwarder_init_unchained(
            IFundForwarderUpgradeable(address(authority_)).vault()
        );

        __BK_init_unchained(baseURI_, version_);
    }

    function __BK_init_unchained(
        string calldata baseURI_,
        bytes32 version_
    ) internal onlyInitializing {
        version = version_;
        _setBaseURI(baseURI_);
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
    {
        _requireNotPaused();
        super._beforeTokenTransfer(from_, to_, tokenId_);

        address sender = _msgSender();
        _checkBlacklist(sender);
        _checkBlacklist(from_);
        _checkBlacklist(to_);

        if (
            from_ != address(0) &&
            to_ != address(0) &&
            !_hasRole(Roles.OPERATOR_ROLE, sender)
        ) {
            (IERC20Upgradeable feeToken, uint256 feeAmt) = feeInfo();
            if (feeAmt == 0) return;

            address _vault = vault();
            _safeTransferFrom(feeToken, sender, _vault, feeAmt);
            if (address(feeToken) != address(0))
                if (
                    IWithdrawableUpgradeable(_vault).notifyERC20Transfer(
                        address(feeToken),
                        feeAmt,
                        safeTransferHeader()
                    ) != IWithdrawableUpgradeable.notifyERC20Transfer.selector
                ) revert BK721__ExecutionFailed();
        }
    }

    function __mintTransfer(address to_, uint256 tokenId_) private {
        _mint(address(this), tokenId_);
        _transfer(address(this), to_, tokenId_);
    }

    function __safeMintTransfer(address to_, uint256 tokenId_) private {
        address sender = _msgSender();
        _safeMint(sender, tokenId_);
        _transfer(sender, to_, tokenId_);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return string(_baseTokenURIPtr.read());
    }

    uint256[47] private __gap;
}

interface IBKNFT {
    function initialize(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint96 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_
    ) external;
}

contract BKNFT is IBKNFT, BK721 {
    function initialize(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint96 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_
    ) external initializer {
        __BK_init(
            name_,
            symbol_,
            baseURI_,
            feeAmt_,
            feeToken_,
            authority_,
            /// @dev value is equal to keccak256("BKNFT_v1")
            0x379792d4af837d435deaf8f2b7ca3c489899f24f02d5309487fe8be0aa778cca
        );
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IBKAsset.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IBK721 is IBKAsset {
    error BK721__Expired();
    error BK721__NotMinted();
    error BK721__Unauthorized();
    error BK721__AlreadyMinted();
    error BK721__ExecutionFailed();
    error BK721__InvalidSignature();
    error BK721__TokenNotSupported();

    event Merged(address indexed account, uint256[] from, uint256 to);
    event BatchMinted(
        address indexed operator,
        address indexed to,
        uint256 indexed amount
    );

    function mint(
        address to_,
        uint256 tokenId_
    ) external returns (uint256 tokenId);

    function safeMint(
        address to_,
        uint256 tokenId_
    ) external returns (uint256 tokenId);

    function mintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external returns (uint256[] memory tokenIds);

    function safeMintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external returns (uint256[] memory tokenIds);

    function merge(
        uint256[] calldata fromIds_,
        uint256 toId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;

    function nextIdFromType(uint256 typeId_) external view returns (uint256);

    function baseURI() external view returns (string memory);

    function setBaseURI(string calldata baseURI_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBKAsset {
    function typeIdTrackers(uint256 typeId_) external view returns (uint256);

    function metadataOf(
        uint256 tokenId_
    ) external view returns (uint256 typeId, uint256 index);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/interfaces/IWithdrawableUpgradeable.sol";

interface IBKTreasury {
    error BKTreasury__LengthMismatch();
    error BKTreasury__UnsupportedToken();
    event PaymentsUpdated(
        address indexed operator,
        address[] payments,
        bool[] statuses
    );
    event PricesUpdated(
        address indexed operator,
        address[] tokens,
        uint256[] prices
    );

    function supportedPayment(address token_) external view returns (bool);

    function priceOf(address token_) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/internal-upgradeable/FundForwarderUpgradeable.sol";

abstract contract BKFundForwarderUpgradeable is FundForwarderUpgradeable {
    function safeRecoverHeader() public pure override returns (bytes memory) {
        /// @dev value is equal keccak256("SAFE_RECOVER_HEADER")
        return
            bytes.concat(
                bytes32(
                    0x556d79614195ebefcc31ab1ee514b9953934b87d25857902370689cbd29b49de
                )
            );
    }

    function safeTransferHeader() public pure override returns (bytes memory) {
        /// @dev value is equal keccak256("SAFE_TRANSFER")
        return
            bytes.concat(
                bytes32(
                    0xc9627ddb76e5ee80829319617b557cc79498bbbc5553d8c632749a7511825f5d
                )
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/internal/FundForwarder.sol";

abstract contract BKFundForwarder is FundForwarder {
    function safeRecoverHeader() public pure override returns (bytes memory) {
        /// @dev value is equal keccak256("SAFE_RECOVER_HEADER")
        return
            bytes.concat(
                bytes32(
                    0x556d79614195ebefcc31ab1ee514b9953934b87d25857902370689cbd29b49de
                )
            );
    }

    function safeTransferHeader() public pure override returns (bytes memory) {
        /// @dev value is equal keccak256("SAFE_TRANSFER")
        return
            bytes.concat(
                bytes32(
                    0xc9627ddb76e5ee80829319617b557cc79498bbbc5553d8c632749a7511825f5d
                )
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./internal/BKFundForwarder.sol";

import "oz-custom/contracts/internal/Cloner.sol";
import "oz-custom/contracts/internal/MultiDelegatecall.sol";

import "oz-custom/contracts/presets/base/Manager.sol";

import "./interfaces/IBKTreasury.sol";
import {IBKNFT} from "./BK721.sol";

contract NFTFactory is Manager, Cloner, BKFundForwarder, MultiDelegatecall {
    bytes32 public constant VERSION =
        0xc42665b4953fdd2cb30dcf1befa0156911485f4e84e3f90b1360ddfb4fa2f766;

    constructor(
        address implement_,
        IAuthority authority_
    )
        payable
        Cloner(implement_)
        Manager(authority_, Roles.FACTORY_ROLE)
        FundForwarder(IFundForwarder(address(authority_)).vault())
    {}

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function setImplement(
        address implement_
    ) external override onlyRole(Roles.OPERATOR_ROLE) {
        emit ImplementChanged(implement(), implement_);
        _setImplement(implement_);
    }

    function clone(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20 feeToken_
    ) external onlyRole(Roles.OPERATOR_ROLE) returns (address) {
        return
            _clone(
                keccak256(
                    abi.encodePacked(name_, symbol_, address(this), VERSION)
                ),
                IBKNFT.initialize.selector,
                abi.encode(name_, symbol_, baseURI_, feeAmt_, feeToken_)
            );
    }

    function cloneOf(
        string calldata name_,
        string calldata symbol_
    ) external view returns (address, bool) {
        return
            _cloneOf(
                keccak256(
                    abi.encodePacked(name_, symbol_, address(this), VERSION)
                )
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz-upgradeable/utils/ContextUpgradeable.sol";

import "./TransferableUpgradeable.sol";

import "./interfaces/IFundForwarderUpgradeable.sol";

/**
 * @title FundForwarderUpgradeable
 * @dev Abstract contract for forwarding funds to a specified address.
 */
abstract contract FundForwarderUpgradeable is
    ContextUpgradeable,
    TransferableUpgradeable,
    IFundForwarderUpgradeable
{
    /**
     * @dev Address to forward funds to
     */
    bytes32 private __vault;

    /**
     * @dev Receives funds and forwards them to the vault address
     */
    receive() external payable virtual {
        address _vault = vault();

        (bool ok, ) = _vault.call{value: msg.value}(safeRecoverHeader());
        if (!ok) revert FundForwarder__ForwardFailed();

        emit Forwarded(_msgSender(), msg.value);

        _afterRecover(_vault, address(0), abi.encode(msg.value));
    }

    function __FundForwarder_init(address vault_) internal onlyInitializing {
        __FundForwarder_init_unchained(vault_);
    }

    function __FundForwarder_init_unchained(
        address vault_
    ) internal onlyInitializing {
        _changeVault(vault_);
    }

    /// @inheritdoc IFundForwarderUpgradeable
    function recoverERC20(IERC20Upgradeable token_, uint256 amount_) external {
        __checkValidAddress(address(token_));
        address _vault = vault();

        _safeERC20Transfer(token_, _vault, amount_);

        emit Recovered(_msgSender(), address(token_), amount_);

        _afterRecover(_vault, address(token_), abi.encode(amount_));
    }

    /// @inheritdoc IFundForwarderUpgradeable
    function recoverNFT(IERC721Upgradeable token_, uint256 tokenId_) external {
        __checkValidAddress(address(token_));
        address _vault = vault();

        token_.safeTransferFrom(
            address(this),
            _vault,
            tokenId_,
            safeRecoverHeader()
        );

        emit Recovered(_msgSender(), address(token_), tokenId_);

        _afterRecover(_vault, address(token_), abi.encode(tokenId_));
    }

    /// @inheritdoc IFundForwarderUpgradeable
    function recoverNFTs(IERC721EnumerableUpgradeable token_) external {
        __checkValidAddress(address(token_));
        address _vault = vault();
        uint256 length = token_.balanceOf(address(this));
        uint256[] memory tokenIds = new uint256[](length);
        bytes memory recoverHeader = safeRecoverHeader();
        for (uint256 i; i < length; ) {
            token_.safeTransferFrom(
                address(this),
                _vault,
                tokenIds[i] = token_.tokenOfOwnerByIndex(address(this), i),
                recoverHeader
            );

            unchecked {
                ++i;
            }
        }

        _afterRecover(_vault, address(token_), abi.encode(tokenIds));

        emit RecoveredMulti(_msgSender(), address(token_), tokenIds);
    }

    /// @inheritdoc IFundForwarderUpgradeable
    function recoverNative() external {
        address _vault = vault();

        uint256 balance = address(this).balance;

        _safeNativeTransfer(_vault, address(this).balance);

        _afterRecover(_vault, address(0), abi.encode(balance));
    }

    function vault() public view returns (address vault_) {
        assembly {
            vault_ := sload(__vault.slot)
        }

        __checkValidAddress(vault_);
    }

    /**
     * @dev Changes the vault address
     * @param vault_ New vault address
     */
    function _changeVault(address vault_) internal {
        __checkValidAddress(vault_);

        address old;
        assembly {
            old := sload(__vault.slot)
        }
        emit VaultUpdated(old, vault_);

        assembly {
            sstore(__vault.slot, vault_)
        }
    }

    function safeRecoverHeader() public pure virtual returns (bytes memory);

    function safeTransferHeader() public pure virtual returns (bytes memory);

    function _afterRecover(
        address vault_,
        address token_,
        bytes memory value_
    ) internal virtual {}

    /**
     *@dev Asserts that the given address is not the zero address
     *@param addr_ The address to check
     *@custom:throws FundForwarder__InvalidArgument if the address is the zero address
     */
    function __checkValidAddress(address addr_) private view {
        if (addr_ == address(0) || addr_ == address(this))
            revert FundForwarder__InvalidArgument();
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBlacklistableUpgradeable {
    event UserStatusSet(
        address indexed operator,
        address indexed account,
        bool indexed isBlacklisted
    );

    /**
     * @dev Set the status of an account to either blacklisted or not blacklisted.
     * @param account_ The address to change the status of.
     * @param status The new status for the address. True for blacklisted, false for not blacklisted.
     */
    function setUserStatus(address account_, bool status) external;

    /**
     * @dev Check if an address is blacklisted.
     * @param account_ The address to check.
     * @return True if the address is blacklisted, false otherwise.
     */
    function isBlacklisted(address account_) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import {
    IERC721Upgradeable,
    IERC721EnumerableUpgradeable
} from "../../oz-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

interface IFundForwarderUpgradeable {
    error FundForwarder__ForwardFailed();
    error FundForwarder__InvalidArgument();

    /**
     * @dev Emits when the vault address is updated
     * @param from Old vault address
     * @param to New vault address
     */
    event VaultUpdated(address indexed from, address indexed to);

    /**
     *@dev Emits when a single ERC721 token is recovered
     *@param operator Address of the contract calling this function
     *@param token Address of the token contract
     *@param value Token ID of the recovered token
     */
    event Recovered(
        address indexed operator,
        address indexed token,
        uint256 indexed value
    );

    /**
     *@dev Emits when multiple ERC721 tokens are recovered
     *@param operator Address of the contract calling this function
     *@param token Address of the token contract
     *@param values Token IDs of the recovered tokens
     */
    event RecoveredMulti(
        address indexed operator,
        address indexed token,
        uint256[] values
    );

    /**
     * @dev Emits when funds are forwarded
     * @param from Address of the sender
     * @param amount Amount of funds forwarded
     */
    event Forwarded(address indexed from, uint256 indexed amount);

    function safeRecoverHeader() external pure returns (bytes memory);

    function safeTransferHeader() external pure returns (bytes memory);

    function vault() external view returns (address);

    function changeVault(address vault_) external;

    /**
     * @dev Recovers ERC20 token to the vault address
     * @param token_ ERC20 token contract
     * @param amount_ Amount of tokens to recover
     */
    function recoverERC20(IERC20Upgradeable token_, uint256 amount_) external;

    /**
     *@dev Recovers ERC721 token to the vault address
     *@param token_ ERC721 token contract
     *@param tokenId_ ID of the token to recover
     */
    function recoverNFT(IERC721Upgradeable token_, uint256 tokenId_) external;

    /**
     *@dev Recovers all ERC721 tokens of the contract to the vault address
     *@param token_ ERC721Enumerable token contract
     */
    function recoverNFTs(IERC721EnumerableUpgradeable token_) external;

    /**
     * @dev Recovers native currency to the vault address
     */
    function recoverNative() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IProtocolFeeUpgradeable {
    /**
     * @dev Fee information structure
     */
    struct FeeInfo {
        IERC20Upgradeable token;
        uint96 royalty;
    }

    event ProtocolFeeUpdated(
        address indexed operator,
        IERC20Upgradeable indexed payment,
        uint96 indexed royalty
    );

    function setRoyalty(IERC20Upgradeable token_, uint96 feeAmt_) external;

    /**
     * @dev Returns the fee information
     * @return  token feeAmt Token address of the fee and the fee amount
     */
    function feeInfo()
        external
        view
        returns (IERC20Upgradeable token, uint256 feeAmt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISignableUpgradeable {
    error Signable__InvalidSignature();

    event NonceIncremented(
        address indexed operator,
        bytes32 indexed id,
        uint256 indexed value
    );

    /**
     * @dev Returns the domain separator for EIP712 v4
     * @return Domain separator for EIP712 v4
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IWithdrawableUpgradeable {
    event Withdrawn(
        address indexed token,
        address indexed to,
        uint256 indexed value
    );

    /**
     * @dev Event emitted when funds are received by the contract
     */
    event Received(
        address indexed sender,
        address indexed token,
        bytes value,
        bytes data
    );

    function notifyERC20Transfer(
        address token_,
        uint256 value_,
        bytes calldata data_
    ) external returns (bytes4);

    /**
     * @dev Withdraws the given amount of tokens or Ether from the contract
     * @param token_ Address of the token contract to withdraw. If zero address, withdraw Ether.
     * @param to_ Address to send the tokens or Ether to
     * @param value_ Amount of tokens or Ether to withdraw
     */
    function withdraw(
        address token_,
        address to_,
        uint256 value_,
        bytes calldata data_
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz-upgradeable/utils/ContextUpgradeable.sol";
import "../oz-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/IProtocolFeeUpgradeable.sol";

/**
 * @title ProtocolFeeUpgradeable
 * @dev Abstract contract for protocol fees.
 * @dev An implementation of this contract should define the `_percentageFraction` function, which returns the percentage fraction of the fee.
 * @dev The fee amount is calculated as the product of the fee percentage and the fee value.
 */
abstract contract ProtocolFeeUpgradeable is
    Initializable,
    ContextUpgradeable,
    IProtocolFeeUpgradeable
{
    FeeInfo private __feeInfo;

    function __ProtocolFee_init(
        IERC20Upgradeable token_,
        uint96 feeAmt_
    ) internal onlyInitializing {
        __ProtocolFee_init_unchained(token_, feeAmt_);
    }

    function __ProtocolFee_init_unchained(
        IERC20Upgradeable token_,
        uint96 feeAmt_
    ) internal onlyInitializing {
        _setRoyalty(token_, feeAmt_);
    }

    /// @inheritdoc IProtocolFeeUpgradeable
    function feeInfo()
        public
        view
        returns (IERC20Upgradeable token, uint256 feeAmt)
    {
        assembly {
            let data := sload(__feeInfo.slot)
            token := data
            feeAmt := shr(160, data)
        }
    }

    /**
     * @dev Sets the royalty fee information
     * @param token_ Token address of the fee
     * @param amount_ Fee amount
     */
    function _setRoyalty(
        IERC20Upgradeable token_,
        uint96 amount_
    ) internal virtual {
        assembly {
            sstore(__feeInfo.slot, or(shl(160, amount_), token_))
        }

        emit ProtocolFeeUpdated(_msgSender(), token_, amount_);
    }

    /**
     * @dev Pure virtual function to return the percentage fraction of the fee
     * @return Percentage fraction of the fee
     */
    function _percentageFraction() internal pure virtual returns (uint256) {
        return 10_000;
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz-upgradeable/utils/ContextUpgradeable.sol";
import {
    ECDSAUpgradeable,
    EIP712Upgradeable
} from "../oz-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";

import "./interfaces/ISignableUpgradeable.sol";

import "../libraries/Bytes32Address.sol";

/**
 * @title SignableUpgradeable
 * @dev Abstract contract for signing and verifying typed data.
 */
abstract contract SignableUpgradeable is
    EIP712Upgradeable,
    ContextUpgradeable,
    ISignableUpgradeable
{
    using Bytes32Address for address;
    using ECDSAUpgradeable for bytes32;

    /**
     * @dev Mapping of nonces for each id
     */
    mapping(bytes32 => uint256) internal _nonces;

    /**
     * @dev Constructor that initializes EIP712 with the given name and version
     * @param name_ Name of the typed data
     * @param version_ Version of the typed data
     */
    function __Signable_init(
        string calldata name_,
        string calldata version_
    ) internal onlyInitializing {
        __Signable_init_unchained(name_, version_);
    }

    function __Signable_init_unchained(
        string memory name_,
        string memory version_
    ) internal onlyInitializing {
        __EIP712_init_unchained(name_, version_);
    }

    /**
     * @dev Verifies that the signer of the typed data is the given address
     * @param verifier_ Address to verify
     * @param structHash_ Hash of the typed data
     * @param signature_ Signature of the typed data
     */
    function _verify(
        address verifier_,
        bytes32 structHash_,
        bytes calldata signature_
    ) internal view virtual {
        if (_recoverSigner(structHash_, signature_) != verifier_)
            revert Signable__InvalidSignature();
    }

    /**
     * @dev Verifies that the signer of the typed data is the given address
     * @param verifier_ Address to verify
     * @param structHash_ Hash of the typed data
     * @param v ECDSA recovery value
     * @param r ECDSA r value
     * @param s ECDSA s value
     */
    function _verify(
        address verifier_,
        bytes32 structHash_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view virtual {
        if (_recoverSigner(structHash_, v, r, s) != verifier_)
            revert Signable__InvalidSignature();
    }

    /**
     * @dev Recovers the signer of the typed data from the signature
     * @param structHash_ Hash of the typed data
     * @param signature_ Signature of the typed data
     * @return Address of the signer
     */
    function _recoverSigner(
        bytes32 structHash_,
        bytes calldata signature_
    ) internal view returns (address) {
        return _hashTypedDataV4(structHash_).recover(signature_);
    }

    /**
     * @dev Recovers the signer of the typed data from the signature
     * @param structHash_ Hash of the typed data
     * @param v ECDSA recovery value
     * @param r ECDSA r value
     * @param s ECDSA s value
     * @return Address of the signer
     */
    function _recoverSigner(
        bytes32 structHash_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (address) {
        return _hashTypedDataV4(structHash_).recover(v, r, s);
    }

    /**
     * @dev Increases the nonce for the given account by 1
     * @param id_ ID to increase the nonce for
     * @return nonce The new nonce for the account
     */
    function _useNonce(bytes32 id_) internal virtual returns (uint256 nonce) {
        assembly {
            mstore(0x00, id_)
            mstore(0x20, _nonces.slot)
            let key := keccak256(0x00, 0x40)
            nonce := sload(key)
            sstore(key, add(nonce, 1))
        }

        emit NonceIncremented(_msgSender(), id_, nonce);
    }

    /**
     * @dev Returns the nonce for the given address
     * @param id_ ID to get the nonce for
     * @return nonce Nonce of the given address
     */
    function _nonce(bytes32 id_) internal view virtual returns (uint256 nonce) {
        assembly {
            mstore(0x00, id_)
            mstore(0x20, _nonces.slot)
            nonce := sload(keccak256(0x00, 0x40))
        }
    }

    /// @inheritdoc ISignableUpgradeable
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz-upgradeable/proxy/utils/Initializable.sol";
import "../oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

error Transferable__TransferFailed();
error Transferable__InvalidArguments();

/**
 * @dev Library for transferring Ether and tokens between accounts
 */
abstract contract TransferableUpgradeable is Initializable {
    function __Transferable_init() internal onlyInitializing {}

    function __Transferable_init_unchained() internal onlyInitializing {}

    /**
     * @dev Reverts the transaction if the transfer fails
     * @param token_ Address of the token contract to transfer. If zero address, transfer Ether.
     * @param from_ Address to transfer from
     * @param to_ Address to transfer to
     * @param value_ Amount of tokens or Ether to transfer
     */
    function _safeTransferFrom(
        IERC20Upgradeable token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20TransferFrom(token_, from_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    /**
     * @dev Reverts the transaction if the transfer fails
     * @param token_ Address of the token contract to transfer. If zero address, transfer Ether.
     * @param to_ Address to transfer to
     * @param value_ Amount of tokens or Ether to transfer
     */
    function _safeTransfer(
        IERC20Upgradeable token_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20Transfer(token_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    /**
     * @dev Reverts the transaction if the Ether transfer fails
     * @param to_ Address to transfer to
     * @param amount_ Amount of Ether to transfer
     */
    function _safeNativeTransfer(
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        if (!__nativeTransfer(to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20Transfer(
        IERC20Upgradeable token_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        if (!__ERC20Transfer(token_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20TransferFrom(
        IERC20Upgradeable token_,
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);

        if (!__ERC20TransferFrom(token_, from_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function __nativeTransfer(
        address to_,
        uint256 amount_
    ) private returns (bool success) {
        assembly {
            success := call(gas(), to_, amount_, 0, 0, 0, 0)
        }
    }

    function __ERC20Transfer(
        IERC20Upgradeable token_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to_) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), value_) // Append the "amount" argument.

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
    }

    function __ERC20TransferFrom(
        IERC20Upgradeable token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from_)
            mstore(add(freeMemoryPointer, 36), to_)
            mstore(add(freeMemoryPointer, 68), value_)

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }
    }

    function __checkValidTransfer(address to_, uint256 value_) private pure {
        if (value_ == 0 || to_ == address(0))
            revert Transferable__InvalidArguments();
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/proxy/Clones.sol";

import "./interfaces/ICloner.sol";

import "../libraries/Bytes32Address.sol";

abstract contract Cloner is ICloner {
    using Clones for address;
    using Bytes32Address for *;

    bytes32 private __implement;
    mapping(bytes32 => address[]) private __clones;

    constructor(address implement_) payable {
        _setImplement(implement_);
        emit ImplementChanged(address(0), implement_);
    }

    /// @inheritdoc ICloner
    function implement() public view returns (address) {
        return __implement.fromFirst20Bytes();
    }

    /**
     * @notice Returns a cloned contract instance of the given salt
     * @param salt_ The salt used to deterministically generate the clone's address
     * @return clone isCloned The cloned contract instance, and a boolean indicating whether the contract has already been cloned
     */
    function _cloneOf(
        bytes32 salt_
    ) internal view returns (address clone, bool isCloned) {
        clone = implement().predictDeterministicAddress(salt_);
        isCloned = clone.code.length != 0;
    }

    /// @inheritdoc ICloner
    function allClonesOf(
        address implement_
    ) external view returns (address[] memory clones) {
        return __clones[implement_.fillLast12Bytes()];
    }

    function _setImplement(address implement_) internal {
        __implement = implement_.fillLast12Bytes();
    }

    /**
     * @notice Creates a cloned contract instance of the given salt
     * @param salt_ The salt used to deterministically generate the clone's address
     * @param initSelector_ The optional selector for the clone's initialization function
     * @param initCode_ The optional data for the clone's initialization function
     * @return clone The cloned contract instance
     */
    function _clone(
        bytes32 salt_,
        bytes4 initSelector_,
        bytes memory initCode_
    ) internal returns (address clone) {
        address _implement = implement();
        clone = _implement.cloneDeterministic(salt_);
        if (initSelector_ != 0) {
            (bool ok, ) = clone.call(
                abi.encodePacked(initSelector_, initCode_)
            );
            if (!ok) revert Cloner__InitCloneFailed();
        }

        __clones[_implement.fillLast12Bytes()].push(clone);

        emit Cloned(_implement, clone, salt_, clone.codehash);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/utils/Context.sol";

import "./Transferable.sol";

import "./interfaces/IFundForwarder.sol";

/**
 * @title FundForwarder
 * @dev Abstract contract for forwarding funds to a specified address.
 */
abstract contract FundForwarder is Context, Transferable, IFundForwarder {
    /**
     * @dev Address to forward funds to
     */
    bytes32 private __vault;

    /**
     * @dev Constructor that sets the vault address
     * @param vault_ Address to forward funds to
     */
    constructor(address vault_) payable {
        _changeVault(vault_);
    }

    /**
     * @dev Receives funds and forwards them to the vault address
     */
    receive() external payable virtual {
        address _vault = vault();

        (bool ok, ) = _vault.call{value: msg.value}(safeRecoverHeader());
        if (!ok) revert FundForwarder__ForwardFailed();

        emit Forwarded(_msgSender(), msg.value);

        _afterRecover(_vault, address(0), abi.encode(msg.value));
    }

    /// @inheritdoc IFundForwarder
    function recoverERC20(IERC20 token_, uint256 amount_) external {
        __checkValidAddress(address(token_));
        address _vault = vault();

        _safeERC20Transfer(token_, _vault, amount_);

        emit Recovered(_msgSender(), address(token_), amount_);

        _afterRecover(_vault, address(token_), abi.encode(amount_));
    }

    /// @inheritdoc IFundForwarder
    function recoverNFT(IERC721 token_, uint256 tokenId_) external {
        __checkValidAddress(address(token_));
        address _vault = vault();

        token_.safeTransferFrom(
            address(this),
            _vault,
            tokenId_,
            safeRecoverHeader()
        );

        emit Recovered(_msgSender(), address(token_), tokenId_);

        _afterRecover(_vault, address(token_), abi.encode(tokenId_));
    }

    /// @inheritdoc IFundForwarder
    function recoverNFTs(IERC721Enumerable token_) external {
        __checkValidAddress(address(token_));
        address _vault = vault();
        uint256 length = token_.balanceOf(address(this));
        uint256[] memory tokenIds = new uint256[](length);
        bytes memory recoverHeader = safeRecoverHeader();
        for (uint256 i; i < length; ) {
            token_.safeTransferFrom(
                address(this),
                _vault,
                tokenIds[i] = token_.tokenOfOwnerByIndex(address(this), i),
                recoverHeader
            );

            unchecked {
                ++i;
            }
        }

        _afterRecover(_vault, address(token_), abi.encode(tokenIds));

        emit RecoveredMulti(_msgSender(), address(token_), tokenIds);
    }

    /// @inheritdoc IFundForwarder
    function recoverNative() external {
        address _vault = vault();
        uint256 balance = address(this).balance;
        _safeNativeTransfer(_vault, balance);

        emit Recovered(_msgSender(), address(0), balance);

        _afterRecover(_vault, address(0), abi.encode(balance));
    }

    function vault() public view returns (address vault_) {
        assembly {
            vault_ := sload(__vault.slot)
        }

        __checkValidAddress(vault_);
    }

    function safeRecoverHeader() public pure virtual returns (bytes memory);

    function safeTransferHeader() public pure virtual returns (bytes memory);

    /**
     * @dev Changes the vault address
     * @param vault_ New vault address
     */
    function _changeVault(address vault_) internal {
        __checkValidAddress(vault_);

        address old;
        assembly {
            old := sload(__vault.slot)
        }
        emit VaultUpdated(old, vault_);

        assembly {
            sstore(__vault.slot, vault_)
        }
    }

    function _afterRecover(
        address vault_,
        address token_,
        bytes memory value_
    ) internal virtual {}

    /**
     *@dev Asserts that the given address is not the zero address
     *@param addr_ The address to check
     *@custom:throws FundForwarder__InvalidArgument if the address is the zero address
     */
    function __checkValidAddress(address addr_) private view {
        if (addr_ == address(0) || addr_ == address(this))
            revert FundForwarder__InvalidArgument();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBlacklistable {
    event UserStatusSet(
        address indexed operator,
        address indexed account,
        bool indexed isBlacklisted
    );

    /**
     * @dev Set the status of an account to either blacklisted or not blacklisted.
     * @param account_ The address to change the status of.
     * @param status The new status for the address. True for blacklisted, false for not blacklisted.
     */
    function setUserStatus(address account_, bool status) external;

    /**
     * @dev Check if an address is blacklisted.
     * @param account_ The address to check.
     * @return True if the address is blacklisted, false otherwise.
     */
    function isBlacklisted(address account_) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICloner {
    error Cloner__InitCloneFailed();

    event Cloned(
        address indexed implement,
        address indexed clone,
        bytes32 indexed salt,
        bytes32 bytecodeHash
    );

    event ImplementChanged(address indexed from, address indexed to);

    /**
     * @notice Changes the contract's implementation address
     * @param implement_ The new implementation address
     */
    function setImplement(address implement_) external;

    /**
     * @notice Returns the contract's implementation address
     * @return The implementation address
     */
    function implement() external view returns (address);

    /**
     * @notice Returns all cloned contract instances of the given implementation address
     * @param implement_ The implementation address
     * @return clones The array of cloned contract instances
     */
    function allClonesOf(
        address implement_
    ) external view returns (address[] memory clones);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../oz/token/ERC20/IERC20.sol";

import {
    IERC721,
    IERC721Enumerable
} from "../../oz/token/ERC721/extensions/IERC721Enumerable.sol";

interface IFundForwarder {
    error FundForwarder__ForwardFailed();
    error FundForwarder__InvalidArgument();

    /**
     * @dev Emits when the vault address is updated
     * @param from Old vault address
     * @param to New vault address
     */
    event VaultUpdated(address indexed from, address indexed to);

    /**
     *@dev Emits when a single ERC721 token is recovered
     *@param operator Address of the contract calling this function
     *@param token Address of the token contract
     *@param value Token ID of the recovered token
     */
    event Recovered(
        address indexed operator,
        address indexed token,
        uint256 indexed value
    );

    /**
     *@dev Emits when multiple ERC721 tokens are recovered
     *@param operator Address of the contract calling this function
     *@param token Address of the token contract
     *@param values Token IDs of the recovered tokens
     */
    event RecoveredMulti(
        address indexed operator,
        address indexed token,
        uint256[] values
    );

    /**
     * @dev Emits when funds are forwarded
     * @param from Address of the sender
     * @param amount Amount of funds forwarded
     */
    event Forwarded(address indexed from, uint256 indexed amount);

    function safeRecoverHeader() external pure returns (bytes memory);

    function safeTransferHeader() external pure returns (bytes memory);

    function changeVault(address vault_) external;

    function vault() external view returns (address);

    /**
     * @dev Recovers ERC20 token to the vault address
     * @param token_ ERC20 token contract
     * @param amount_ Amount of tokens to recover
     */
    function recoverERC20(IERC20 token_, uint256 amount_) external;

    /**
     *@dev Recovers ERC721 token to the vault address
     *@param token_ ERC721 token contract
     *@param tokenId_ ID of the token to recover
     */
    function recoverNFT(IERC721 token_, uint256 tokenId_) external;

    /**
     *@dev Recovers all ERC721 tokens of the contract to the vault address
     *@param token_ ERC721Enumerable token contract
     */
    function recoverNFTs(IERC721Enumerable token_) external;

    /**
     * @dev Recovers native currency to the vault address
     */
    function recoverNative() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error MultiDelegatecall__OnlyDelegate();
error MultiDelegatecall__ExecutionFailed();

/**
 * @title MultiDelegatecall
 * @dev Abstract contract for performing multiple delegatecalls in a single transaction.
 */
abstract contract MultiDelegatecall {
    /**
     * @dev Address of the original contract
     */
    address private immutable __original;

    event BatchExecuted(
        address indexed operator,
        bytes[] callData,
        bytes[] results
    );

    /**
     * @dev Constructor that saves the address of the original contract
     */
    constructor() payable {
        __original = address(this);
    }

    /**
     * @dev Executes multiple delegatecalls in a single transaction
     * @param data_ Array of calldata for delegatecalls
     * @return results Array of delegatecall results
     */
    function _multiDelegatecall(
        bytes[] calldata data_
    ) internal returns (bytes[] memory results) {
        if (address(this) != __original)
            revert MultiDelegatecall__OnlyDelegate();

        uint256 length = data_.length;
        results = new bytes[](length);
        bool ok;
        for (uint256 i; i < length; ) {
            (ok, results[i]) = address(this).delegatecall(data_[i]);
            if (!ok) revert MultiDelegatecall__ExecutionFailed();
            unchecked {
                ++i;
            }
        }

        emit BatchExecuted(msg.sender, data_, results);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/token/ERC20/IERC20.sol";

error Transferable__TransferFailed();
error Transferable__InvalidArguments();

/**
 * @dev Library for transferring Ether and tokens between accounts
 */
abstract contract Transferable {
    /**
     * @dev Reverts the transaction if the transfer fails
     * @param token_ Address of the token contract to transfer. If zero address, transfer Ether.
     * @param from_ Address to transfer from
     * @param to_ Address to transfer to
     * @param value_ Amount of tokens or Ether to transfer
     */
    function _safeTransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20TransferFrom(token_, from_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    /**
     * @dev Reverts the transaction if the transfer fails
     * @param token_ Address of the token contract to transfer. If zero address, transfer Ether.
     * @param to_ Address to transfer to
     * @param value_ Amount of tokens or Ether to transfer
     */
    function _safeTransfer(
        IERC20 token_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20Transfer(token_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    /**
     * @dev Reverts the transaction if the Ether transfer fails
     * @param to_ Address to transfer to
     * @param amount_ Amount of Ether to transfer
     */
    function _safeNativeTransfer(
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        if (!__nativeTransfer(to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20Transfer(
        IERC20 token_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        if (!__ERC20Transfer(token_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20TransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);

        if (!__ERC20TransferFrom(token_, from_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function __nativeTransfer(
        address to_,
        uint256 amount_
    ) private returns (bool success) {
        assembly {
            success := call(gas(), to_, amount_, 0, 0, 0, 0)
        }
    }

    function __ERC20Transfer(
        IERC20 token_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to_) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), value_) // Append the "amount" argument.

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
    }

    function __ERC20TransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from_)
            mstore(add(freeMemoryPointer, 36), to_)
            mstore(add(freeMemoryPointer, 68), value_)

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }
    }

    function __checkValidTransfer(address to_, uint256 value_) private pure {
        if (value_ == 0 || to_ == address(0))
            revert Transferable__InvalidArguments();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Bytes32Address {
    function fromFirst20Bytes(
        bytes32 bytesValue
    ) internal pure returns (address addr) {
        assembly {
            addr := bytesValue
        }
    }

    function fillLast12Bytes(
        address addressValue
    ) internal pure returns (bytes32 value) {
        assembly {
            value := addressValue
        }
    }

    function fromFirst160Bits(
        uint256 uintValue
    ) internal pure returns (address addr) {
        assembly {
            addr := uintValue
        }
    }

    function fillLast96Bits(
        address addressValue
    ) internal pure returns (uint256 value) {
        assembly {
            value := addressValue
        }
    }

    function fromLast160Bits(
        uint256 uintValue
    ) internal pure returns (address addr) {
        assembly {
            addr := shr(0x60, uintValue)
        }
    }

    function fillFirst96Bits(
        address addressValue
    ) internal pure returns (uint256 value) {
        assembly {
            value := shl(0x60, addressValue)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Roles {
    bytes32 public constant PROXY_ROLE =
        0x77d72916e966418e6dc58a19999ae9934bef3f749f1547cde0a86e809f19c89b;
    bytes32 public constant SIGNER_ROLE =
        0xe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70;
    bytes32 public constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    bytes32 public constant MINTER_ROLE =
        0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;
    bytes32 public constant OPERATOR_ROLE =
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;
    bytes32 public constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;
    bytes32 public constant TREASURER_ROLE =
        0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07;
    bytes32 public constant FACTORY_ROLE =
        0xdfbefbf47cfe66b701d8cfdbce1de81c821590819cb07e71cb01b6602fb0ee27;
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    error SSTORE2__ReadOutOfBounds();
    error SSTORE2__DeploymentFailed();

    // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.
    uint256 internal constant DATA_OFFSET = 1;

    /*//////////////////////////////////////////////////////////////
                               WRITE LOGIC
    //////////////////////////////////////////////////////////////*/

    function write(bytes memory data) internal returns (bytes32 ptr) {
        // Note: The assembly block below does not expand the memory.
        address pointer;
        assembly {
            let originalDataLength := mload(data)

            // Add 1 to data size since we are prefixing it with a STOP opcode.
            let dataSize := add(originalDataLength, 1)

            /**
             * ------------------------------------------------------------------------------------+
             *   Opcode  | Opcode + Arguments  | Description       | Stack View                    |
             * ------------------------------------------------------------------------------------|
             *   0x61    | 0x61XXXX            | PUSH2 codeSize    | codeSize                      |
             *   0x80    | 0x80                | DUP1              | codeSize codeSize             |
             *   0x60    | 0x600A              | PUSH1 10          | 10 codeSize codeSize          |
             *   0x3D    | 0x3D                | RETURNDATASIZE    | 0 10 codeSize codeSize        |
             *   0x39    | 0x39                | CODECOPY          | codeSize                      |
             *   0x3D    | 0x3D                | RETURNDATASZIE    | 0 codeSize                    |
             *   0xF3    | 0xF3                | RETURN            |                               |
             *   0x00    | 0x00                | STOP              |                               |
             * ------------------------------------------------------------------------------------+
             * @dev Prefix the bytecode with a STOP opcode to ensure it cannot be called. Also PUSH2 is
             * used since max contract size cap is 24,576 bytes which is less than 2 ** 16.
             */
            mstore(
                data,
                or(
                    0x61000080600a3d393df300,
                    shl(64, dataSize) // shift `dataSize` so that it lines up with the 0000 after PUSH2
                )
            )

            // Deploy a new contract with the generated creation code.
            pointer := create(0, add(data, 21), add(dataSize, 10))

            // Restore original length of the variable size `data`
            mstore(data, originalDataLength)
        }

        if (pointer == address(0)) revert SSTORE2__DeploymentFailed();

        assembly {
            ptr := pointer
        }
    }

    function writeToAddr(bytes memory data) internal returns (address pointer) {
        // Note: The assembly block below does not expand the memory.
        assembly {
            let originalDataLength := mload(data)

            // Add 1 to data size since we are prefixing it with a STOP opcode.
            let dataSize := add(originalDataLength, 1)

            /**
             * ------------------------------------------------------------------------------------+
             *   Opcode  | Opcode + Arguments  | Description       | Stack View                    |
             * ------------------------------------------------------------------------------------|
             *   0x61    | 0x61XXXX            | PUSH2 codeSize    | codeSize                      |
             *   0x80    | 0x80                | DUP1              | codeSize codeSize             |
             *   0x60    | 0x600A              | PUSH1 10          | 10 codeSize codeSize          |
             *   0x3D    | 0x3D                | RETURNDATASIZE    | 0 10 codeSize codeSize        |
             *   0x39    | 0x39                | CODECOPY          | codeSize                      |
             *   0x3D    | 0x3D                | RETURNDATASZIE    | 0 codeSize                    |
             *   0xF3    | 0xF3                | RETURN            |                               |
             *   0x00    | 0x00                | STOP              |                               |
             * ------------------------------------------------------------------------------------+
             * @dev Prefix the bytecode with a STOP opcode to ensure it cannot be called. Also PUSH2 is
             * used since max contract size cap is 24,576 bytes which is less than 2 ** 16.
             */
            mstore(
                data,
                or(
                    0x61000080600a3d393df300,
                    shl(64, dataSize) // shift `dataSize` so that it lines up with the 0000 after PUSH2
                )
            )

            // Deploy a new contract with the generated creation code.
            pointer := create(0, add(data, 21), add(dataSize, 10))

            // Restore original length of the variable size `data`
            mstore(data, originalDataLength)
        }

        if (pointer == address(0)) revert SSTORE2__DeploymentFailed();
    }

    /*//////////////////////////////////////////////////////////////
                               READ LOGIC
    //////////////////////////////////////////////////////////////*/

    function read(address ptr) internal view returns (bytes memory) {
        address pointer;
        assembly {
            pointer := ptr
        }
        return
            readBytecode(
                pointer,
                DATA_OFFSET,
                pointer.code.length - DATA_OFFSET
            );
    }

    function read(bytes32 ptr) internal view returns (bytes memory) {
        address pointer;
        assembly {
            pointer := ptr
        }
        return
            readBytecode(
                pointer,
                DATA_OFFSET,
                pointer.code.length - DATA_OFFSET
            );
    }

    function read(
        address pointer,
        uint256 start
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        return readBytecode(pointer, start, pointer.code.length - start);
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        if (pointer.code.length < end) revert SSTORE2__ReadOutOfBounds();

        return readBytecode(pointer, start, end - start);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 63 (32 + 31) to size and running the result through the logic
            // above ensures the memory pointer remains word-aligned, following
            // the Solidity convention.
            mstore(0x40, add(data, and(add(size, 63), not(31))))

            // Store the size of the data in the first 32 byte chunk of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice Efficient library for creating string representations of integers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
/// @author Modified from Solady (https://github.com/Vectorized/solady/blob/main/src/utils/LibString.sol)
library StringLib {
    function toString(int256 value) internal pure returns (string memory str) {
        if (value >= 0) return toString(uint256(value));

        unchecked {
            str = toString(uint256(-value));

            /// @solidity memory-safe-assembly
            assembly {
                // Note: This is only safe because we over-allocate memory
                // and write the string from right to left in toString(uint256),
                // and thus can be sure that sub(str, 1) is an unused memory location.

                let length := mload(str) // Load the string length.
                // Put the - character at the start of the string contents.
                mstore(str, 45) // 45 is the ASCII code for the - character.
                str := sub(str, 1) // Move back the string pointer by a byte.
                mstore(str, add(length, 1)) // Update the string length.
            }
        }
    }

    function toString(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but we allocate 160 bytes
            // to keep the free memory pointer word aligned. We'll need 1 word for the length, 1 word for the
            // trailing zeros padding, and 3 other words for a max of 78 digits. In total: 5 * 32 = 160 bytes.
            let newFreeMemoryPointer := add(mload(0x40), 160)

            // Update the free memory pointer to avoid overriding our string.
            mstore(0x40, newFreeMemoryPointer)

            // Assign str to the end of the zone of newly allocated memory.
            str := sub(newFreeMemoryPointer, 32)

            // Clean the last word of memory it may not be overwritten.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                // Move the pointer 1 byte to the left.
                str := sub(str, 1)

                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))

                // Keep dividing temp until zero.
                temp := div(temp, 10)

                 // prettier-ignore
                if iszero(temp) { break }
            }

            // Compute and cache the final total length of the string.
            let length := sub(end, str)

            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 32)

            // Store the string's length at the start of memory allocated for our string.
            mstore(str, length)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    error AccessControl__Unauthorized();
    error AccessControl__RoleMissing(bytes32 role, address account);
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

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

    function DEFAULT_ADMIN_ROLE() external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

error ERC1967UpgradeUpgradeable__NonZeroAddress();
error ERC1967UpgradeUpgradeable__ExecutionFailed();
error ERC1967UpgradeUpgradeable__TargetIsNotContract();
error ERC1967UpgradeUpgradeable__ImplementationIsNotUUPS();
error ERC1967UpgradeUpgradeable__UnsupportedProxiableUUID();
error ERC1967UpgradeUpgradeable__DelegateCallToNonContract();
error ERC1967UpgradeUpgradeable__ImplementationIsNotContract();

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {}

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {}

    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT =
        0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return
            StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        if (!_isContract(newImplementation))
            revert ERC1967UpgradeUpgradeable__ImplementationIsNotContract();
        StorageSlotUpgradeable
            .getAddressSlot(_IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (forceCall || data.length > 0) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try
                IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()
            returns (bytes32 slot) {
                if (slot != _IMPLEMENTATION_SLOT)
                    revert ERC1967UpgradeUpgradeable__UnsupportedProxiableUUID();
            } catch {
                revert ERC1967UpgradeUpgradeable__ImplementationIsNotUUPS();
            }

            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        if (newAdmin == address(0))
            revert ERC1967UpgradeUpgradeable__NonZeroAddress();
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        if (!_isContract(newBeacon))
            revert ERC1967UpgradeUpgradeable__TargetIsNotContract();
        if (!_isContract(IBeaconUpgradeable(newBeacon).implementation()))
            revert ERC1967UpgradeUpgradeable__ImplementationIsNotContract();
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (forceCall || data.length > 0) {
            _functionDelegateCall(
                IBeaconUpgradeable(newBeacon).implementation(),
                data
            );
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(
        address target,
        bytes memory data
    ) private returns (bytes memory) {
        if (!_isContract(target))
            revert ERC1967UpgradeUpgradeable__DelegateCallToNonContract();

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata);
    }

    function _isContract(address addr_) internal view returns (bool) {
        return addr_.code.length != 0;
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata
    ) internal pure returns (bytes memory) {
        if (success) return returndata;
        else {
            // Look for revert reason and bubble it up if present
            if (returndata.length != 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    revert(add(32, returndata), mload(returndata))
                }
            } else revert ERC1967UpgradeUpgradeable__ExecutionFailed();
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

error Initializable__Initializing();
error Initializable__NotInitializing();
error Initializable__AlreadyInitialized();

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint256 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    uint256 private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint256 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _initializing != 2;
        uint256 initialized = _initialized;
        if (
            !((isTopLevelCall && initialized == 0) ||
                (initialized == 1 && address(this).code.length == 0))
        ) revert Initializable__AlreadyInitialized();

        _initialized = 1;
        if (isTopLevelCall) _initializing = 2;
        _;
        if (isTopLevelCall) {
            _initializing = 1;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint256 version) {
        if (_initializing != 1 || _initialized >= version)
            revert Initializable__AlreadyInitialized();
        _initialized = version & ~uint8(0);
        _initializing = 2;
        _;
        _initializing = 1;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        if (_initializing != 2) revert Initializable__NotInitializing();
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        if (_initializing != 1) revert Initializable__Initializing();
        if (_initialized < 0xff) {
            _initialized = 0xff;
            emit Initialized(0xff);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8 version) {
        assembly {
            version := sload(_initialized.slot)
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing == 2;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

error UUPSUpgradeable__OnlyCall();
error UUPSUpgradeable__OnlyDelegateCall();
error UUPSUpgradeable__OnlyActiveProxy();

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is
    Initializable,
    IERC1822ProxiableUpgradeable,
    ERC1967UpgradeUpgradeable
{
    function __UUPSUpgradeable_init() internal onlyInitializing {}

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {}

    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        address self = __self;
        if (address(this) == self) revert UUPSUpgradeable__OnlyDelegateCall();
        if (_getImplementation() != self)
            revert UUPSUpgradeable__OnlyActiveProxy();
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        if (address(this) != __self) revert UUPSUpgradeable__OnlyCall();
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID()
        external
        view
        virtual
        override
        notDelegated
        returns (bytes32)
    {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, "", false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    error ERC20__Expired();
    error ERC20__StringTooLong();
    error ERC20__InvalidSignature();
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.10;

import "../../utils/ContextUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../utils/structs/BitMapsUpgradeable.sol";
import "./IERC721Upgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";

import "../../../libraries/Bytes32Address.sol";

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721Upgradeable is
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC721Upgradeable,
    IERC721MetadataUpgradeable
{
    using Bytes32Address for *;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;
    string public symbol;

    function _baseURI() internal view virtual returns (string memory);

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => bytes32) internal _ownerOf;
    mapping(address => uint256) internal _balanceOf;

    function ownerOf(
        uint256 id
    ) public view virtual override returns (address owner) {
        assembly {
            mstore(0, id)
            mstore(32, _ownerOf.slot)
            owner := sload(keccak256(0, 64))
        }

        if (owner == address(0)) revert ERC721__NotMinted();
    }

    function balanceOf(
        address owner
    ) public view virtual returns (uint256 balance_) {
        if (owner == address(0)) revert ERC721__NonZeroAddress();

        assembly {
            mstore(0, owner)
            mstore(32, _balanceOf.slot)
            balance_ := sload(keccak256(0, 64))
        }
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => bytes32) internal _getApproved;

    mapping(address => BitMapsUpgradeable.BitMap) internal _isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(
        string calldata name_,
        string calldata symbol_
    ) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        if (bytes(name_).length > 32 || bytes(symbol_).length > 32)
            revert ERC721__StringTooLong();
        name = name_;
        symbol = symbol_;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner;
        assembly {
            mstore(0, id)
            mstore(32, _ownerOf.slot)
            owner := sload(keccak256(0, 64))
        }

        address sender = _msgSender();
        if (
            sender != owner &&
            !_isApprovedForAll[owner].get(sender.fillLast96Bits())
        ) revert ERC721__Unauthorized();

        assembly {
            //mstore(0, id)
            mstore(32, _getApproved.slot)
            sstore(keccak256(0, 64), spender)
        }

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        address sender = _msgSender();

        _isApprovedForAll[sender].setTo(operator.fillLast96Bits(), approved);

        emit ApprovalForAll(sender, operator, approved);
    }

    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {
        return _getApproved[tokenId].fromFirst20Bytes();
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool) {
        return _isApprovedForAll[owner].get(operator.fillLast96Bits());
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        address owner = ownerOf(tokenId);
        return
            (spender == owner ||
                _getApproved[tokenId] == spender.fillLast12Bytes()) ||
            _isApprovedForAll[owner].get(spender.fillLast96Bits());
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        if (to == address(0)) revert ERC721__InvalidRecipient();

        bytes32 ownerOfKey;
        address owner;
        assembly {
            mstore(0, id)
            mstore(32, _ownerOf.slot)
            ownerOfKey := keccak256(0, 64)
            owner := sload(ownerOfKey)
        }
        if (from != owner) revert ERC721__WrongFrom();

        _beforeTokenTransfer(from, to, id);

        address sender = _msgSender();
        if (
            sender != from &&
            sender.fillLast12Bytes() != _getApproved[id] &&
            !_isApprovedForAll[from].get(sender.fillLast96Bits())
        ) revert ERC721__Unauthorized();

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            ++_balanceOf[to];
            --_balanceOf[from];
        }

        assembly {
            sstore(ownerOfKey, to)
        }
        delete _getApproved[id];

        emit Transfer(from, to, id);

        _afterTokenTransfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(
                _msgSender(),
                from,
                id,
                ""
            ) !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        if (to == address(0)) revert ERC721__InvalidRecipient();

        address owner;
        bytes32 key;
        assembly {
            mstore(0, tokenId)
            mstore(32, _ownerOf.slot)
            key := keccak256(0, 64)
            owner := sload(key)
        }
        if (from != owner) revert ERC721__WrongFrom();

        _beforeTokenTransfer(from, to, tokenId);

        unchecked {
            ++_balanceOf[to];
            --_balanceOf[from];
        }

        assembly {
            sstore(key, to)
        }

        delete _getApproved[tokenId];

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);
        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(
                _msgSender(),
                from,
                id,
                data
            ) !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        if (to == address(0)) revert ERC721__InvalidRecipient();

        bytes32 key;
        bytes32 owner;
        assembly {
            mstore(0, id)
            mstore(32, _ownerOf.slot)
            key := keccak256(0, 64)
            owner := sload(key)
        }
        if (owner != 0) revert ERC721__AlreadyMinted();

        _beforeTokenTransfer(address(0), to, id);

        // Counter overflow is incredibly unrealistic.
        unchecked {
            ++_balanceOf[to];
        }

        assembly {
            sstore(key, to)
        }

        emit Transfer(address(0), to, id);

        _afterTokenTransfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        bytes32 key;
        address owner;
        assembly {
            mstore(0, id)
            mstore(32, _ownerOf.slot)
            key := keccak256(0, 64)
            owner := sload(key)
        }
        if (owner == address(0)) revert ERC721__NotMinted();

        _beforeTokenTransfer(owner, address(0), id);

        // Ownership check above ensures no underflow.
        unchecked {
            --_balanceOf[owner];
        }
        assembly {
            sstore(key, 0)
        }
        delete _getApproved[id];

        emit Transfer(owner, address(0), id);

        _afterTokenTransfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(
                _msgSender(),
                address(0),
                id,
                ""
            ) !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);
        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(
                _msgSender(),
                address(0),
                id,
                data
            ) !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiverUpgradeable {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiverUpgradeable.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is
    ERC721Upgradeable,
    IERC721EnumerableUpgradeable
{
    using Bytes32Address for address;
    // Mapping from owner to list of owned token IDs
    mapping(bytes32 => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    function __ERC721Enumerable_init() internal onlyInitializing {}

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view virtual override returns (uint256) {
        if (index >= balanceOf(owner)) revert ERC721Enumerable__OutOfBounds();
        return _ownedTokens[owner.fillLast12Bytes()][index];
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
    function tokenByIndex(
        uint256 index
    ) public view virtual override returns (uint256) {
        if (index != totalSupply()) revert ERC721Enumerable__OutOfBounds();
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

        if (from == address(0)) _addTokenToAllTokensEnumeration(tokenId);
        else if (from != to) _removeTokenFromOwnerEnumeration(from, tokenId);

        if (to == address(0)) _removeTokenFromAllTokensEnumeration(tokenId);
        else if (to != from) _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to.fillLast12Bytes()][length] = tokenId;
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
    function _removeTokenFromOwnerEnumeration(
        address from,
        uint256 tokenId
    ) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        bytes32 tokenIndexKey;
        uint256 tokenIndex;
        assembly {
            mstore(0, tokenId)
            mstore(32, _ownedTokensIndex.slot)
            tokenIndexKey := keccak256(0, 64)
            tokenIndex := sload(tokenIndexKey)
        }

        bytes32 lastTokenIdKey;
        uint256 lastTokenIndex = balanceOf(from) - 1;
        assembly {
            mstore(0, from)
            mstore(32, _ownedTokens.slot)
            mstore(32, keccak256(0, 64))
            mstore(0, lastTokenIndex)

            lastTokenIdKey := keccak256(0, 64)
        }
        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            //uint256 lastTokenId;
            assembly {
                let lastTokenId := sload(lastTokenIdKey)
                mstore(0, tokenIndex)
                sstore(keccak256(0, 64), lastTokenId)

                mstore(0, lastTokenId)
                mstore(32, _ownedTokensIndex.slot)
            }
            //_ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array

        assembly {
            sstore(tokenIndexKey, 0)
            sstore(lastTokenIdKey, 0)
        }
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        bytes32 tokenIndexKey;
        uint256 tokenIndex;
        assembly {
            mstore(0, tokenId)
            mstore(32, _allTokensIndex.slot)
            tokenIndexKey := keccak256(0, 64)
            tokenIndex := sload(tokenIndexKey)
        }

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId;

        _allTokens[tokenIndex] = lastTokenId = _allTokens[
            _allTokens.length - 1
        ]; // Move the last token to the slot of the to-delete token

        // This also deletes the contents at the last position of the array
        assembly {
            mstore(0, lastTokenId)
            sstore(keccak256(0, 64), tokenIndex)

            sstore(tokenIndexKey, 0)
        }

        _allTokens.pop();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.10;

import "../ERC721Upgradeable.sol";
import "./IERC721PermitUpgradeable.sol";

import "../../../../internal-upgradeable/SignableUpgradeable.sol";

/// @title ERC721 with permit
/// @notice Nonfungible tokens that support an approve via signature, i.e. permit
abstract contract ERC721PermitUpgradeable is
    ERC721Upgradeable,
    IERC721PermitUpgradeable,
    SignableUpgradeable
{
    using Bytes32Address for address;

    function __ERC721Permit_init(
        string calldata name_,
        string calldata symbol_
    ) internal onlyInitializing {
        __EIP712_init_unchained(name_, "1");
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721Permit_init_unchained() internal onlyInitializing {}

    /// @dev Gets the current nonce for a token ID and then increments it, returning the original value

    /// @inheritdoc IERC721PermitUpgradeable
    function DOMAIN_SEPARATOR()
        public
        view
        override(IERC721PermitUpgradeable, SignableUpgradeable)
        returns (bytes32)
    {
        return _domainSeparatorV4();
    }

    /// @dev Value is equal to to keccak256("Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)");
    bytes32 private constant __PERMIT_TYPEHASH =
        0x49ecf333e5b8c95c40fdafc95c1ad136e8914a8fb55e9dc8bb01eaa83a2df9ad;

    /// @inheritdoc IERC721PermitUpgradeable
    function permit(
        address spender_,
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external override {
        if (block.timestamp > deadline_) revert ERC721Permit__Expired();
        address owner = ownerOf(tokenId_);
        if (spender_ == owner) revert ERC721Permit__SelfApproving();
        _verify(
            owner,
            keccak256(
                abi.encode(
                    __PERMIT_TYPEHASH,
                    spender_,
                    tokenId_,
                    _useNonce(tokenId_),
                    deadline_
                )
            ),
            signature_
        );
        _getApproved[tokenId_] = spender_.fillLast12Bytes();
    }

    function nonces(uint256 tokenId_) external view override returns (uint256) {
        return _nonces[bytes32(tokenId_)];
    }

    function _useNonce(uint256 tokenId_) internal returns (uint256) {
        unchecked {
            return _nonces[bytes32(tokenId_)]++;
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    error ERC721Enumerable__OutOfBounds();

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.10;

import "../IERC721Upgradeable.sol";

/// @title ERC721 with permit
/// @notice Extension to ERC721 that includes a permit function for signature based approvals
interface IERC721PermitUpgradeable is IERC721Upgradeable {
    error ERC721Permit__Expired();
    error ERC721Permit__SelfApproving();

    /// @notice The domain separator used in the permit signature
    /// @return The domain seperator used in encoding of permit signature
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /// @notice function to be called by anyone to approve `spender` using a Permit signature
    /// @dev Anyone can call this to approve `spender`, even a third-party
    /// @param spender the actor to approve
    /// @param tokenId the token id
    /// @param deadline the deadline for the permit to be used
    /// @param signature permit
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes calldata signature
    ) external;

    function nonces(uint256 tokenId_) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    error ERC721__NotMinted();
    error ERC721__WrongFrom();
    error ERC721__Unauthorized();
    error ERC721__StringTooLong();
    error ERC721__AlreadyMinted();
    error ERC721__NonZeroAddress();
    error ERC721__UnsafeRecipient();
    error ERC721__InvalidRecipient();
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    ///@dev value is equal to keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
    bytes32 private constant _TYPE_HASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(
        string calldata name,
        string calldata version
    ) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(
        string memory name,
        string memory version
    ) internal onlyInitializing {
        _HASHED_NAME = keccak256(bytes(name));
        _HASHED_VERSION = keccak256(bytes(version));
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return
            _buildDomainSeparator(
                _TYPE_HASH,
                _EIP712NameHash(),
                _EIP712VersionHash()
            );
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    typeHash,
                    nameHash,
                    versionHash,
                    block.chainid,
                    address(this)
                )
            );
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(
        bytes32 structHash
    ) internal view virtual returns (bytes32) {
        return
            ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal view virtual returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal view virtual returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

//import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (address result) {
        assembly {
            // Copy the free memory pointer so that we can restore it later.
            let m := mload(0x40)
            // Directly load `s` from the calldata.
            let s := calldataload(add(signature.offset, 0x20))

            switch signature.length
            case 64 {
                // Here, `s` is actually `vs` that needs to be recovered into `v` and `s`.
                // Compute `v` and store it in the scratch space.
                mstore(0x20, add(shr(255, s), 27))
                // prettier-ignore
                s := and(s, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            }
            case 65 {
                // Compute `v` and store it in the scratch space.
                mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40))))
            }

            // If `s` in lower half order, such that the signature is not malleable.
            // prettier-ignore
            if iszero(gt(s, 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0)) {
                mstore(0x00, hash)
                calldatacopy(0x40, signature.offset, 0x20) // Directly copy `r` over.
                mstore(0x60, s)
                pop(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        0x01, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x40, // Start of output.
                        0x20 // Size of output.
                    )
                )
                // Restore the zero slot.
                mstore(0x60, 0)
                // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                result := mload(sub(0x60, returndatasize()))
            }
            // Restore the free memory pointer.
            mstore(0x40, m)
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (address result) {
        assembly {
            // Copy the free memory pointer so that we can restore it later.
            let m := mload(0x40)
            mstore(0x20, v)
            // If `s` in lower half order, such that the signature is not malleable.
            // prettier-ignore
            if iszero(gt(s, 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0)) {
                mstore(0x00, hash)
                mstore(0x40, r)
                mstore(0x60, s)
                pop(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        0x01, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x40, // Start of output.
                        0x20 // Size of output.
                    )
                )
                // Restore the zero slot.
                mstore(0x60, 0)
                // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                result := mload(sub(0x60, returndatasize()))
            }
            // Restore the free memory pointer.
            mstore(0x40, m)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(
        bytes32 hash
    ) internal pure returns (bytes32 result) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        assembly {
            // Store into scratch space for keccak256.
            mstore(0x20, hash)
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32")
            // 0x40 - 0x04 = 0x3c
            result := keccak256(0x04, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(
        bytes memory s
    ) internal pure returns (bytes32 result) {
        assembly {
            // We need at most 128 bytes for Ethereum signed message header.
            // The max length of the ASCII reprenstation of a uint256 is 78 bytes.
            // The length of "\x19Ethereum Signed Message:\n" is 26 bytes.
            // The next multiple of 32 above 78 + 26 is 128.

            // Instead of allocating, we temporarily copy the 128 bytes before the
            // start of `s` data to some variables.
            let m3 := mload(sub(s, 0x60))
            let m2 := mload(sub(s, 0x40))
            let m1 := mload(sub(s, 0x20))
            // The length of `s` is in bytes.
            let sLength := mload(s)

            let ptr := add(s, 0x20)

            // `end` marks the end of the memory which we will compute the keccak256 of.
            let end := add(ptr, sLength)

            // Convert the length of the bytes to ASCII decimal representation
            // and store it into the memory.
            for {
                let temp := sLength
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
                temp := div(temp, 10)
            } temp {
                temp := div(temp, 10)
            } {
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
            }

            // Move the pointer 32 bytes lower to make room for the string.
            // `start` marks the start of the memory which we will compute the keccak256 of.
            let start := sub(ptr, 32)
            // Copy the header over to the memory.
            mstore(
                start,
                "\x00\x00\x00\x00\x00\x00\x19Ethereum Signed Message:\n"
            )
            start := add(start, 6)

            // Compute the keccak256 of the memory.
            result := keccak256(start, sub(end, start))

            // Restore the previous memory.
            mstore(s, sLength)
            mstore(sub(s, 0x20), m1)
            mstore(sub(s, 0x40), m2)
            mstore(sub(s, 0x60), m3)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(
        bytes32 domainSeparator,
        bytes32 structHash
    ) internal pure returns (bytes32 result) {
        assembly {
            // Load free memory pointer
            let memPtr := mload(64)

            mstore(
                memPtr,
                0x1901000000000000000000000000000000000000000000000000000000000000
            ) // EIP191 header
            mstore(add(memPtr, 2), domainSeparator) // EIP712 domain hash
            mstore(add(memPtr, 34), structHash) // Hash of struct

            // Compute hash
            result := keccak256(memPtr, 66)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {}

    function __ERC165_init_unchained() internal onlyInitializing {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(
        bytes32 slot
    ) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(
        bytes32 slot
    ) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(
        bytes32 slot
    ) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/BitMaps.sol)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMapsUpgradeable {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(
        BitMap storage bitmap,
        uint256 index
    ) internal view returns (bool isSet) {
        uint256 value = bitmap._data[index >> 8] & (1 << (index & 0xff));

        assembly {
            isSet := value // Assign isSet to whether the value is non zero.
        }
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool shouldSet
    ) internal {
        uint256 value = bitmap._data[index >> 8];

        assembly {
            // The following sets the bit at `shift` without branching.
            let shift := and(index, 0xff)
            // Isolate the bit at `shift`.
            let x := and(shr(shift, value), 1)
            // Xor it with `shouldSet`. Results in 1 if both are different, else 0.
            x := xor(x, shouldSet)
            // Shifts the bit back. Then, xor with value.
            // Only the bit at `shift` will be flipped if they differ.
            // Every other bit will stay the same, as they are xor'ed with zeroes.
            value := xor(value, shl(shift, x))
        }
        bitmap._data[index >> 8] = value;
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        bitmap._data[index >> 8] |= 1 << (index & 0xff);
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        bitmap._data[index >> 8] &= ~(1 << (index & 0xff));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.17;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    error AccessControl__Unauthorized();
    error AccessControl__RoleMissing(bytes32 role, address account);
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

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

    function DEFAULT_ADMIN_ROLE() external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

error ERC1167__CreateFailed();
error ERC1167__Create2Failed();

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            instance := create(0, ptr, 0x37)
        }
        if (instance == address(0)) revert ERC1167__CreateFailed();
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(
        address implementation,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            instance := create2(0, ptr, 0x37, salt)
        }
        if (instance == address(0)) revert ERC1167__Create2Failed();
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000
            )
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    error ERC20__Expired();
    error ERC20__StringTooLong();
    error ERC20__InvalidSignature();
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.17;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    error ERC721Enumerable__OutOfBounds();

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.17;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    error ERC721__NotMinted();
    error ERC721__WrongFrom();
    error ERC721__Unauthorized();
    error ERC721__StringTooLong();
    error ERC721__AlreadyMinted();
    error ERC721__NonZeroAddress();
    error ERC721__UnsafeRecipient();
    error ERC721__InvalidRecipient();
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.17;

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.17;

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAuthority} from "../../interfaces/IAuthority.sol";

interface IManager {
    error Manager__Paused();
    error Manager__NotPaused();
    error Manager__AlreadySet();
    error Manager__Blacklisted();
    error Manager__Unauthorized();
    error Manager__RequestFailed();
    error Manager__InvalidArgument();

    event AuthorityUpdated(
        address indexed operator,
        IAuthority indexed from,
        IAuthority indexed to
    );
    event RequestRoleCached(address indexed operator, bytes32 indexed role);

    /**
     * @notice Updates the authority of this contract. This can only be done by an operator.
     * @param authority_ The new authority contract.
     * @dev The authority contract must allow this contract to have the role specified in the constructor.
     * @custom:throws Manager__AlreadySet if the new authority is the same as the current authority.
     * @custom:throws Manager__RequestFailed if the request to the new authority contract fails.
     */
    function updateAuthority(IAuthority authority_) external;

    /**
     * @notice Returns the authority contract of this contract.
     * @return authority_ is The address of the authority contract.
     */
    function authority() external view returns (IAuthority authority_);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../oz-upgradeable/utils/ContextUpgradeable.sol";
import "../../oz-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IManager.sol";

import "../../oz-upgradeable/access/IAccessControlUpgradeable.sol";
import "../../internal-upgradeable/interfaces/IBlacklistableUpgradeable.sol";

import "../../libraries/Roles.sol";

abstract contract ManagerUpgradeable is
    IManager,
    UUPSUpgradeable,
    ContextUpgradeable
{
    bytes32 private __authority;
    bytes32 private __requestedRole;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    modifier onlyWhitelisted() {
        _checkBlacklist(_msgSender());
        _;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function __Manager_init(
        IAuthority authority_,
        bytes32 role_
    ) internal onlyInitializing {
        __Manager_init_unchained(authority_, role_);
    }

    function __Manager_init_unchained(
        IAuthority authority_,
        bytes32 role_
    ) internal onlyInitializing {
        assembly {
            sstore(__requestedRole.slot, role_)
        }
        address sender = _msgSender();
        emit RequestRoleCached(sender, role_);

        (bool ok, ) = address(authority_).call(
            abi.encodeCall(IAuthority.requestAccess, (role_))
        );
        if (!ok) revert Manager__RequestFailed();
        __updateAuthority(authority_);
        emit AuthorityUpdated(sender, IAuthority(address(0)), authority_);
    }

    /// @inheritdoc IManager
    function updateAuthority(
        IAuthority authority_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        IAuthority old = authority();
        if (old == authority_) revert Manager__AlreadySet();
        (bool ok, ) = address(authority_).call(
            abi.encodeCall(IAuthority.requestAccess, (__requestedRole))
        );
        if (!ok) revert Manager__RequestFailed();

        __updateAuthority(authority_);

        emit AuthorityUpdated(_msgSender(), old, authority_);
    }

    /// @inheritdoc IManager
    function authority() public view returns (IAuthority authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(__authority.slot)
        }
    }

    /**
     * @notice Returns the address of the authority contract, for internal use.
     * @dev This function is for internal use only and should not be called by external contracts.
     * @return authority_ is the address of the authority contract.
     */
    function _authority() internal view returns (address authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(__authority.slot)
        }
    }

    /**
     * @notice Checks if the given account is blacklisted by the authority contract.
     * @param account_ The address to check for blacklisting.
     * @dev This function should be called before allowing the given account to perform certain actions.
     * @custom:throws Manager__Blacklisted if the given account is blacklisted.
     */
    function _checkBlacklist(address account_) internal view {
        (bool ok, ) = _authority().staticcall(
            abi.encodeCall(IBlacklistableUpgradeable.isBlacklisted, (account_))
        );
        if (ok) revert Manager__Blacklisted();
    }

    /**
     * @notice Checks if the given account has the given role.
     * @param role_ The role to check for.
     * @param account_ The address to check for the role.
     * @dev This function should be called before allowing the given account to perform certain actions.
     * @custom:throws Manager__Unauthorized if the given account does not have the given role.
     */
    function _checkRole(bytes32 role_, address account_) internal view {
        if (!_hasRole(role_, account_)) revert Manager__Unauthorized();
    }

    function __updateAuthority(IAuthority authority_) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(__authority.slot, authority_)
        }
    }

    function _requirePaused() internal view {
        (bool ok, ) = _authority().staticcall(
            abi.encodeCall(IAuthority.paused, ())
        );
        if (!ok) revert Manager__NotPaused();
    }

    function _requireNotPaused() internal view {
        (bool ok, ) = _authority().staticcall(
            abi.encodeCall(IAuthority.paused, ())
        );
        if (ok) revert Manager__Paused();
    }

    function _hasRole(
        bytes32 role_,
        address account_
    ) internal view returns (bool ok) {
        (ok, ) = _authority().staticcall(
            abi.encodeCall(IAccessControlUpgradeable.hasRole, (role_, account_))
        );
    }

    function _authorizeUpgrade(
        address implement_
    ) internal override onlyRole(Roles.UPGRADER_ROLE) {}

    uint256[48] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAuthority {
    error Authority__InvalidRole();
    error Authority__LengthMismatch();

    event ProxyAccessGranted(address indexed operator, address indexed proxy);

    /**
     * @dev Sets the admin of the specified role to the specified admin role.
     * @param role bytes32 representing the role to set the admin of
     * @param adminRole bytes32 representing the role to set as the admin of the role
     */
    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;

    /**
     * @dev Pauses all functions in the contract. Only callable by accounts with the PAUSER_ROLE.
     */
    function pause() external;

    /**
     * @dev Unpauses all functions in the contract. Only callable by accounts with the PAUSER_ROLE.
     */
    function unpause() external;

    /**
     * @dev Returns true if all functions in the contract are paused, false otherwise.
     * @return isPaused bool isPaused representing the paused state of the contract
     */
    function paused() external view returns (bool isPaused);

    /**
     * @dev Allows a user to request access to the contract as a proxy.
     * Only callable by accounts with the OPERATOR_ROLE and only if the sender is a proxy of the caller.
     * Grants the PROXY_ROLE and the specified role to the sender.
     * @param role bytes32 representing the role to grant to the sender in addition to the PROXY_ROLE
     */
    function requestAccess(bytes32 role) external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAuthority} from "../../interfaces/IAuthority.sol";

interface IManager {
    error Manager__Paused();
    error Manager__NotPaused();
    error Manager__AlreadySet();
    error Manager__Blacklisted();
    error Manager__Unauthorized();
    error Manager__RequestFailed();
    error Manager__InvalidArgument();

    event AuthorityUpdated(
        address indexed operator,
        IAuthority indexed from,
        IAuthority indexed to
    );
    event RequestRoleCached(address indexed operator, bytes32 indexed role);

    /**
     * @notice Updates the authority of this contract. This can only be done by an operator.
     * @param authority_ The new authority contract.
     * @dev The authority contract must allow this contract to have the role specified in the constructor.
     * @custom:throws Manager__AlreadySet if the new authority is the same as the current authority.
     * @custom:throws Manager__RequestFailed if the request to the new authority contract fails.
     */
    function updateAuthority(IAuthority authority_) external;

    /**
     * @notice Returns the authority contract of this contract.
     * @return authority_ is The address of the authority contract.
     */
    function authority() external view returns (IAuthority authority_);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../oz/utils/Context.sol";

import "./interfaces/IManager.sol";
import "../../oz/access/IAccessControl.sol";
import "../../internal/interfaces/IBlacklistable.sol";

import "../../libraries/Roles.sol";

abstract contract Manager is Context, IManager {
    bytes32 private __authority;
    bytes32 private __requestedRole;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    modifier onlyWhitelisted() {
        _checkBlacklist(_msgSender());
        _;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    constructor(IAuthority authority_, bytes32 role_) payable {
        assembly {
            sstore(__requestedRole.slot, role_)
        }
        address sender = _msgSender();
        emit RequestRoleCached(sender, role_);

        (bool ok, ) = address(authority_).call(
            abi.encodeCall(IAuthority.requestAccess, (role_))
        );
        if (!ok) revert Manager__RequestFailed();
        __updateAuthority(authority_);
        emit AuthorityUpdated(sender, IAuthority(address(0)), authority_);
    }

    /// @inheritdoc IManager
    function updateAuthority(
        IAuthority authority_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        IAuthority old = authority();
        if (old == authority_) revert Manager__AlreadySet();
        (bool ok, ) = address(authority_).call(
            abi.encodeCall(IAuthority.requestAccess, (__requestedRole))
        );
        if (!ok) revert Manager__RequestFailed();

        __updateAuthority(authority_);

        emit AuthorityUpdated(_msgSender(), old, authority_);
    }

    /// @inheritdoc IManager
    function authority() public view returns (IAuthority authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(__authority.slot)
        }
    }

    /**
     * @notice Returns the address of the authority contract, for internal use.
     * @dev This function is for internal use only and should not be called by external contracts.
     * @return authority_ is the address of the authority contract.
     */
    function _authority() internal view returns (address authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(__authority.slot)
        }
    }

    /**
     * @notice Checks if the given account is blacklisted by the authority contract.
     * @param account_ The address to check for blacklisting.
     * @dev This function should be called before allowing the given account to perform certain actions.
     * @custom:throws Manager__Blacklisted if the given account is blacklisted.
     */
    function _checkBlacklist(address account_) internal view {
        (bool ok, ) = _authority().staticcall(
            abi.encodeCall(IBlacklistable.isBlacklisted, (account_))
        );
        if (ok) revert Manager__Blacklisted();
    }

    /**
     * @notice Checks if the given account has the given role.
     * @param role_ The role to check for.
     * @param account_ The address to check for the role.
     * @dev This function should be called before allowing the given account to perform certain actions.
     * @custom:throws Manager__Unauthorized if the given account does not have the given role.
     */
    function _checkRole(bytes32 role_, address account_) internal view {
        if (!_hasRole(role_, account_)) revert Manager__Unauthorized();
    }

    function __updateAuthority(IAuthority authority_) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(__authority.slot, authority_)
        }
    }

    function _requirePaused() internal view {
        (bool ok, ) = _authority().staticcall(
            abi.encodeCall(IAuthority.paused, ())
        );
        if (!ok) revert Manager__NotPaused();
    }

    function _requireNotPaused() internal view {
        (bool ok, ) = _authority().staticcall(
            abi.encodeCall(IAuthority.paused, ())
        );
        if (ok) revert Manager__Paused();
    }

    function _hasRole(
        bytes32 role_,
        address account_
    ) internal view returns (bool ok) {
        (ok, ) = _authority().staticcall(
            abi.encodeCall(IAccessControl.hasRole, (role_, account_))
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAuthority {
    error Authority__InvalidRole();
    error Authority__LengthMismatch();

    event ProxyAccessGranted(address indexed operator, address indexed proxy);

    /**
     * @dev Sets the admin of the specified role to the specified admin role.
     * @param role bytes32 representing the role to set the admin of
     * @param adminRole bytes32 representing the role to set as the admin of the role
     */
    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;

    /**
     * @dev Pauses all functions in the contract. Only callable by accounts with the PAUSER_ROLE.
     */
    function pause() external;

    /**
     * @dev Unpauses all functions in the contract. Only callable by accounts with the PAUSER_ROLE.
     */
    function unpause() external;

    /**
     * @dev Returns true if all functions in the contract are paused, false otherwise.
     * @return isPaused bool isPaused representing the paused state of the contract
     */
    function paused() external view returns (bool isPaused);

    /**
     * @dev Allows a user to request access to the contract as a proxy.
     * Only callable by accounts with the OPERATOR_ROLE and only if the sender is a proxy of the caller.
     * Grants the PROXY_ROLE and the specified role to the sender.
     * @param role bytes32 representing the role to grant to the sender in addition to the PROXY_ROLE
     */
    function requestAccess(bytes32 role) external;
}