// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

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
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT

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
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketPlace is ERC721Holder, Ownable {
    event Reward(uint256 tokenId, address account, uint256 amount);

    // invite list level
    mapping(address => address) public inviteLists;

    // nft price
    mapping(uint256 => uint256) public priceLists;

    // invite exchange reward
    mapping(address => uint256) public exchangeRewards;

    // ranking reward
    mapping(address => uint256) public rankingRewards;

    address[] public inviteReward;

    mapping(address => uint256) public inviteRewardLists;

    uint256 lockAmt = 100000 ether;

    struct Market {
        uint256 price;
        address account;
    }

    mapping(uint256 => Market) public marketLists;

    mapping(uint256 => bool) public marketed;

    IERC20 erc20;
    IERC721 erc721;

    address platformAccount;

    modifier inMarket(uint256 _tokenId) {
        require(marketed[_tokenId], "not marketing");
        _;
    }

    constructor(
        address _erc20,
        address _erc721,
        address _platform
    ) {
        require(_erc20 != address(0), "invalid erc20 token");
        require(_erc721 != address(0), "invalid erc721 token");
        require(_platform != address(0), "invalid platform");
        erc20 = IERC20(_erc20);
        erc721 = IERC721(_erc721);
        platformAccount = _platform;
    }

    // add market
    function addMarket(uint256 _tokenId, uint256 _price) external {
        uint256 oldPrice = priceLists[_tokenId];
        require(!marketed[_tokenId], "marketing");
        require(_price >= (oldPrice * 104) / 100, "invalid price");
        priceLists[_tokenId] = _price;
        marketed[_tokenId] = true;

        marketLists[_tokenId] = Market({price: _price, account: msg.sender});
        require(erc721.ownerOf(_tokenId) == msg.sender, "invalid owner");
        erc721.safeTransferFrom(msg.sender, address(this), _tokenId);
    }

    // remove market
    function removeMarket(uint256 _tokenId) external inMarket(_tokenId) {
        require(_tokenId > 0, "invalid tokenId");
        Market memory nft = marketLists[_tokenId];
        require(nft.account == msg.sender, "invalid account");
        delete marketLists[_tokenId];
        marketed[_tokenId] = false;

        erc721.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    // invite rel
    function invite(address pinvite) external {
        require(pinvite != address(0), "invalid pinvite");
        require(inviteLists[msg.sender] == address(0), "invited");
        inviteLists[msg.sender] = pinvite;
    }

    // exchange nft
    function exchange(uint256 _tokenId) external inMarket(_tokenId) {
        require(_tokenId > 0, "invalid tokenId");
        Market memory nft = marketLists[_tokenId];

        uint256 balance = erc20.balanceOf(msg.sender);
        require(balance >= nft.price, "balance not enough");

        uint256 exAmount = 0;
        uint256 _amount = nft.price;
        uint256 _platform = 2;
        address p1 = inviteLists[msg.sender];
        require(p1 != address(0), "not invite");
        if (p1 != address(0)) {
            uint256 p1Balance = erc20.balanceOf(p1);
            require(p1Balance >= lockAmt, "invalid lock erc20");

            uint256 p1Amt = (nft.price * 100 * 5) / 100000;
            // erc20.transferFrom(msg.sender, p1, p1Amt);
            exchangeRewards[p1] += p1Amt;
            exAmount += p1Amt;
            _amount -= p1Amt;

            if (inviteRewardLists[p1] == 0) {
                inviteReward.push(p1);
                inviteRewardLists[p1] = p1Amt;
            } else {
                inviteRewardLists[p1] += p1Amt;
            }
            emit Reward(_tokenId, p1, p1Amt);
        } else {
            _platform += 5;
        }

        address p2 = inviteLists[p1];
        if (p2 != address(0)) {
            uint256 p2Balance = erc20.balanceOf(p2);
            require(p2Balance >= lockAmt, "invalid lock erc20");

            uint256 p2Amt = (nft.price * 100 * 2) / 100000;
            // erc20.transferFrom(msg.sender, p2, p2Amt);
            exchangeRewards[p2] += p2Amt;
            exAmount += p2Amt;
            _amount -= p2Amt;

            if (inviteRewardLists[p2] == 0) {
                inviteReward.push(p2);
                inviteRewardLists[p2] = p2Amt;
            } else {
                inviteRewardLists[p2] += p2Amt;
            }
            emit Reward(_tokenId, p2, p2Amt);
        } else {
            _platform += 2;
        }

        address p3 = inviteLists[p2];
        if (p3 != address(0)) {
            uint256 p3Balance = erc20.balanceOf(p3);
            require(p3Balance >= lockAmt, "invalid lock erc20");

            uint256 p3Amt = (nft.price * 100 * 1) / 100000;
            // erc20.transferFrom(msg.sender, p3, p3Amt);
            exchangeRewards[p3] += p3Amt;
            exAmount += p3Amt;
            _amount -= p3Amt;

            if (inviteRewardLists[p3] == 0) {
                inviteReward.push(p3);
                inviteRewardLists[p3] = p3Amt;
            } else {
                inviteRewardLists[p3] += p3Amt;
            }
            emit Reward(_tokenId, p3, p3Amt);
        } else {
            _platform += 1;
        }

        // 5 2 1 2
        if (platformAccount != address(0)) {
            uint256 platAmt = (nft.price * 100 * _platform) / 100000;
            erc20.transferFrom(msg.sender, platformAccount, platAmt);
            _amount -= platAmt;
            emit Reward(_tokenId, platformAccount, platAmt);
        }

        marketed[_tokenId] = false;
        erc20.transferFrom(msg.sender, nft.account, _amount);

        erc20.transferFrom(msg.sender, address(this), exAmount);

        erc721.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    // is invite
    function invited() external view returns (bool) {
        return inviteLists[msg.sender] != address(0);
    }

    // ranking list
    function ranking()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 len = inviteReward.length;
        require(len > 0, "ranking is empty");
        uint256[] memory amount = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            amount[i] = inviteRewardLists[inviteReward[i]];
        }
        return (inviteReward, amount);
    }

    function rankingReward(
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(
            accounts.length > 0 && accounts.length == amounts.length,
            "invalie params"
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "invalid account");
            require(amounts[i] > 0, "invalid amount");
            // erc20.transferFrom(address(this), accounts[i], amounts[i]);
            rankingRewards[accounts[i]] += amounts[i];
        }

        for (uint256 i = 0; i < inviteReward.length; i++) {
            delete inviteReward[i];
            delete inviteRewardLists[inviteReward[i]];
        }
    }

    // withdraw reward
    function withdrawReward() external {
        uint256 _ranking = rankingRewards[msg.sender];
        uint256 _exchange = exchangeRewards[msg.sender];
        require(_ranking + _exchange > 0, "reward amount is zero");
        erc20.transferFrom(address(this), msg.sender, _ranking + _exchange);
        delete rankingRewards[msg.sender];
        delete exchangeRewards[msg.sender];
    }
}