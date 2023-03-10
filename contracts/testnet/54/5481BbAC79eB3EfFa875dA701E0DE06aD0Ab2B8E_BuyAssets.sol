// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/IERC721Custom.sol";

/// @dev Contract to Buy Landian ASSETS.
contract BuyAssets is Ownable {
    address public LANDIAN_ASSETS;
    address public BUSD_ADDRESS;
    address public USDT_ADDRESS;
    address public LNDA_ADDRESS;

    ///@dev minting enabler
    bool public isSale = false;

    ///@dev modifier Sell items in other erc20
    modifier sellInOtherCurrencies(uint256 price, address CURRENCY) {
        /// @dev  Check that the user's token balance is enough to pay the package
        if (price > 0) {
            require(
                IERC20(CURRENCY).balanceOf(msg.sender) >= price,
                "sell Package With CURRENCY: Your balance is lower than the price of this package"
            );

            /// @dev allowonce to pay the package
            require(
                IERC20(CURRENCY).allowance(msg.sender, address(this)) >= price,
                "sell Package With CURRENCY: You don't have enough tokens available to pay this package"
            );

            /// @dev Transfer token CURRENCY from sender To smart contract
            require(
                IERC20(CURRENCY).transferFrom(msg.sender, address(this), price),
                "sell Package With CURRENCY: Failed to transfer tokens from user to vendor"
            );
        }

        _;
    }

    modifier SaleIsActive() {
        require(!isSale, "Sale is Inactive");
        _;
    }

    /// @dev remove a Partner to the contract,
    constructor(
        address _landianAssets,
        address _usdtAddress,
        address _busdAddress,
        address _lndaAddress
    ) {
        LANDIAN_ASSETS = _landianAssets;
        LNDA_ADDRESS = _lndaAddress;
        USDT_ADDRESS = _usdtAddress;
        BUSD_ADDRESS = _busdAddress;
    }

    function buyPackageERC20(
        string memory erc20,
        uint256 amount,
        uint256 quantity
    )
        public
        sellInOtherCurrencies(
            (amount * quantity),
            (
                keccak256(bytes(erc20)) == keccak256("USDT")
                    ? USDT_ADDRESS
                    : keccak256(bytes(erc20)) == keccak256("BUSD")
                    ? BUSD_ADDRESS
                    : LNDA_ADDRESS
            )
        )
        SaleIsActive
        returns (uint256[] memory)
    {
        uint256[] memory tokens = new uint256[](quantity);
        for (uint256 i = 0; i < quantity; i++) {
            uint256 token = IERC721Custom(LANDIAN_ASSETS).mint(msg.sender);
            tokens[i] = token;
        }
        return tokens;
    }

    function buyPackageNative(
        uint256 price,
        uint256 quantity
    ) public payable SaleIsActive returns (uint256[] memory) {
        /// @dev This require Price is greater than BNB value
        require(
            msg.value >= price * quantity,
            "sell Package Native BNB: Price is greater than BNB value"
        );
        uint256[] memory tokens = new uint256[](quantity);
        for (uint256 i = 0; i < quantity; i++) {
            uint256 token = IERC721Custom(LANDIAN_ASSETS).mint(msg.sender);
            tokens[i] = token;
        }
        return tokens;
    }

    function withdrawAdmin(
        address account,
        uint256 amount,
        string memory erc20
    ) public onlyOwner {
        if (keccak256(bytes(erc20)) == keccak256("USDT")) {
            // @dev verify the amount of tokens from the SC to transfer
            require(
                IERC20(USDT_ADDRESS).balanceOf(address(this)) >= amount,
                "TransferTokensFor: Vendor contract has not enough tokens in its balance"
            );

            IERC20(USDT_ADDRESS).approve(address(this), amount);

            // @dev Transfer token from the SC to the wallet specificated
            require(
                IERC20(USDT_ADDRESS).transfer(account, amount),
                "TransferTokensFor: Failed to transfer tokens from the vendor to the admin"
            );
            // @dev withdraw BUSD
        } else if (keccak256(bytes(erc20)) == keccak256("BUSD")) {
            // @dev verify the amount of tokens from the SC to transfer
            require(
                IERC20(BUSD_ADDRESS).balanceOf(address(this)) >= amount,
                "TransferTokensFor: Vendor contract has not enough tokens in its balance"
            );

            IERC20(BUSD_ADDRESS).approve(address(this), amount);

            // @dev Transfer token from the SC to the wallet specificated
            require(
                IERC20(BUSD_ADDRESS).transfer(account, amount),
                "TransferTokensFor: Failed to transfer tokens from the vendor to the admin"
            );
            // @dev withdraw LNDA
        } else if (keccak256(bytes(erc20)) == keccak256("LNDA")) {
            // @dev verify the amount of tokens from the SC to transfer
            require(
                IERC20(LNDA_ADDRESS).balanceOf(address(this)) >= amount,
                "TransferTokensFor: Vendor contract has not enough tokens in its balance"
            );

            IERC20(LNDA_ADDRESS).approve(address(this), amount);

            // @dev Transfer token from the SC to the wallet specificated
            require(
                IERC20(LNDA_ADDRESS).transfer(account, amount),
                "TransferTokensFor: Failed to transfer tokens from the vendor to the admin"
            );
            // @dev withdraw BNB
        } else if (keccak256(bytes(erc20)) == keccak256("BNB")) {
            // @dev verify the amount of tokens from the SC to transfer
            require(
                address(this).balance >= amount,
                "TransferTokensFor: Vendor contract has not enough tokens in its balance"
            );

            // @dev Transfer token from the SC to the wallet specificated
            require(
                payable(address(account)).send(amount),
                "TransferTokensFor: Failed to transfer tokens from vender to admin"
            );
        }
    }

    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function setSale() external {
        isSale = !isSale;
    }

    function setLandianAssetsContract(address _landianAssetsContract) external {
        LANDIAN_ASSETS = _landianAssetsContract;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Custom is IERC721 {
    function mint(address account) external returns (uint256);
}