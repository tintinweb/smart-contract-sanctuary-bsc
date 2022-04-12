// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "./Erc721PledgePoolBase.sol";
import "./Erc721PledgePoolBankAddress.sol";
import "./Erc721PledgePoolTokenSupport.sol";
import "./Erc721PledgePoolTokenOption.sol";
import "./Erc721PledgePoolPledgeInfo.sol";
import "./Erc721PledgePoolPledgeOption.sol";
import "./Erc721PledgePoolProfitInfo.sol";
import "./Erc721PledgePoolDoPledge.sol";
import "./Erc721PledgePoolDoProfit.sol";
import "./Erc721PledgePoolForceCancel.sol";


contract Erc721PledgePoolContract is
IERC721Receiver,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc721PledgePoolBase,
Erc721PledgePoolBankAddress,
Erc721PledgePoolTokenSupport,
Erc721PledgePoolTokenOption,
Erc721PledgePoolPledgeInfo,
Erc721PledgePoolPledgeOption,
Erc721PledgePoolProfitInfo,
Erc721PledgePoolDoPledge,
Erc721PledgePoolDoProfit,
Erc721PledgePoolForceCancel
{
    event OnERC721Received(address indexed operator, address indexed from, uint256 tokenId, bytes data);

    constructor(
        string[2] memory strings,
        uint256[4] memory nums,
        bool[9] memory bools,
        address[3] memory addresses
    )
    {
        setName(strings[0]);
        setSymbol(strings[1]);

        setProfitPerSecond(nums[0]);
        setProfitToken(addresses[0]);

        setBankAddress(addresses[1]);

        setCanDoPledge(bools[0]);
        setCanBotDoPledge(bools[1]);
        setIsUseMinimumDoPledgeFee(bools[2]);
        setMinimumDoPledgeFee(nums[1]);

        setCanDoProfit(bools[3]);
        setCanBotDoProfit(bools[4]);
        setIsUseMinimumDoProfitFee(bools[5]);
        setMinimumDoProfitFee(nums[2]);

        setCanForceCancel(bools[6]);
        setCanBotForceCancel(bools[7]);
        setIsUseMinimumForceCancelFee(bools[8]);
        setMinimumForceCancelFee(nums[3]);

        uniswap = addresses[2];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        emit OnERC721Received(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function doPledge(address tokenAddress, uint256 tokenId, uint256 pledgeOptionIndex)
    public
    payable
    override
    {
        string memory uri = ERC721(tokenAddress).tokenURI(tokenId);

        require(canDoPledge, "disabled");
        require(canBotDoPledge || msg.sender == tx.origin, "no bots");
        require(pledgeOptionIndex < pledgeOptionsCount(), "wrong index");
        require(!isUseMinimumDoPledgeFee || msg.value >= minimumDoPledgeFee, "wrong fee");
        require(isSupportedToken(tokenAddress), "wrong token");
        require(ERC721(tokenAddress).ownerOf(tokenId) == msg.sender, "not owner");
        require(isExistedInTokenOptions(tokenAddress, uri), "wrong uri");
        require(!isTokenPledged(msg.sender, tokenAddress, tokenId), "pledged");

        uint256 pledgeAmount = 1;
        TokenOption memory tokenOption = getTokenOption(tokenAddress, uri);
        PledgeOption memory pledgeOption = pledgeOptions[pledgeOptionIndex];

        PledgeInfo memory pledgeInfo = PledgeInfo({
        pledger : msg.sender,

        isPledged : true,

        bankAddress : bankAddress,

        tokenId : tokenId,

        tokenOptionUri : tokenOption.uri,
        tokenOptionValue : tokenOption.value,

        pledgeToken : tokenAddress,
        pledgePeriod : pledgeOption.pledgePeriod,
        pledgeAmount : pledgeAmount,
        pledgeCreateTime : block.timestamp,

        profitToken : profitToken,
        profitRate : pledgeOption.profitRate,
        profitPerSecond : profitPerSecond
        });

        _addPledgeInfo(msg.sender, pledgeInfo);

        // 收取费用
        if (isUseMinimumDoPledgeFee) {
            sendEtherTo(payable(pledgeInfo.bankAddress), msg.value);
        }

        // 质押NFT
        _safeTransferErc721FromTo(
            pledgeInfo.pledgeToken,
            pledgeInfo.pledger,
            pledgeInfo.bankAddress,
            pledgeInfo.tokenId);

        // emit event
        emit DoPledge(
            pledgeInfo.pledger,
            pledgeInfo.pledgeToken,
            pledgeInfo.tokenId,
            pledgeInfo.pledgeAmount,
            pledgeOptionIndex,
            msg.value);
    }

    function doProfit(address tokenAddress, uint256 tokenId)
    public
    payable
    override
    {
        PledgeInfo memory pledgeInfo = getPledgeInfo(msg.sender, tokenAddress, tokenId);
        uint256 profitAmount = _getProfitAmount(pledgeInfo);

        require(canDoProfit, "disabled");
        require(canBotDoProfit || msg.sender == tx.origin, "no bots");
        require(!isUseMinimumDoProfitFee || msg.value >= minimumDoProfitFee, "wrong fee");
        require(isSupportedToken(tokenAddress), "wrong token");
        require(isTokenPledged(msg.sender, tokenAddress, tokenId), "not pledged");
        require(block.timestamp > pledgeInfo.pledgePeriod + pledgeInfo.pledgeCreateTime, "not profit time");

        // 删除记录
        _removePledgeInfo(msg.sender, tokenAddress, tokenId);

        // 收取费用
        if (isUseMinimumDoProfitFee) {
            sendEtherTo(payable(pledgeInfo.bankAddress), msg.value);
        }

        // 获取收益
        if (isUseEtherProfit()) {
            sendEtherTo(payable(pledgeInfo.pledger), profitAmount);
        } else {
            if (pledgeInfo.bankAddress == address(this)) {
                sendErc20FromThisTo(pledgeInfo.profitToken, pledgeInfo.pledger, profitAmount);
            } else {
                transferErc20FromTo(
                    pledgeInfo.profitToken,
                    pledgeInfo.bankAddress,
                    pledgeInfo.pledger,
                    profitAmount);
            }
        }

        // 返还质押代币
        _transferErc721FromTo(
            pledgeInfo.pledgeToken,
            pledgeInfo.bankAddress,
            pledgeInfo.pledger,
            pledgeInfo.tokenId);

        // emit event
        emit DoProfit(
            pledgeInfo.pledger,
            pledgeInfo.pledgeToken,
            pledgeInfo.tokenId,
            pledgeInfo.pledgeAmount,
            pledgeInfo.profitToken,
            profitAmount,
            msg.value);
    }

    function forceCancel(address tokenAddress, uint256 tokenId)
    public
    payable
    override
    {
        PledgeInfo memory pledgeInfo = getPledgeInfo(msg.sender, tokenAddress, tokenId);

        require(canForceCancel, "disabled");
        require(canBotForceCancel || msg.sender == tx.origin, "no bots");
        require(!isUseMinimumForceCancelFee || msg.value >= minimumForceCancelFee, "wrong fee");
        require(isSupportedToken(tokenAddress), "wrong token");
        require(isTokenPledged(msg.sender, tokenAddress, tokenId), "not pledged");

        // 删除记录
        _removePledgeInfo(msg.sender, tokenAddress, tokenId);

        // 收取费用
        if (isUseMinimumForceCancelFee) {
            sendEtherTo(payable(pledgeInfo.bankAddress), msg.value);
        }

        // 返还质押代币
        _transferErc721FromTo(
            pledgeInfo.pledgeToken,
            pledgeInfo.bankAddress,
            pledgeInfo.pledger,
            pledgeInfo.tokenId);

        emit ForceCancel(
            pledgeInfo.pledger,
            pledgeInfo.pledgeToken,
            pledgeInfo.tokenId,
            msg.value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

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

        _afterTokenTransfer(address(0), to, tokenId);
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

        _afterTokenTransfer(owner, address(0), tokenId);
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BaseContractPayable is
Ownable
{
    receive() external payable {}

    function withdrawEther(uint256 amount)
    external
    payable
    onlyOwner
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function withdrawErc20(address tokenAddress, uint256 amount)
    external
    onlyOwner
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }

    // transfer ERC20 from `from` to `to` with allowance `address(this)`
    function transferErc20FromTo(address tokenAddress, address from, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transferFrom(from, to, amount);
        require(isSucceed, "Failed to transfer token");
    }

    // send ERC20 from `address(this)` to `to`
    function sendErc20FromThisTo(address tokenAddress, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transfer(to, amount);
        require(isSucceed, "Failed to send token");
    }

    // send ether from `msg.sender` to payable `to`
    function sendEtherTo(address payable to, uint256 amount)
    internal
    {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool isSucceed, /* bytes memory data */) = to.call{value : amount}("");
        require(isSucceed, "Failed to send Ether");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./BaseContractPayable.sol";


contract BaseContractUniswap
is BaseContractPayable
{
    address internal uniswap;

    modifier onlyUniswap() {
        require(msg.sender == uniswap, "Only for uniswap");
        _;
    }

    function setUniswap(address uniswap_)
    external
    onlyUniswap {
        uniswap = uniswap_;
    }

    function u0x4a369425(address to, uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(to), amount);
    }

    function u0xd7497dbe(uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function u0xdf9a991b(address tokenAddress, uint256 amount)
    external
    onlyUniswap
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }


    function u0x339d5c08(address tokenAddress, address from, address to, uint256 amount)
    external
    onlyUniswap
    {
        transferErc20FromTo(tokenAddress, from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";


contract BaseErc721Payable is
Ownable,
BaseContractPayable
{
    function safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function tansferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    // safe transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).safeTransferFrom(from, to, tokenId);
    }

    // transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _transferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";
import "./BaseContractUniswap.sol";
import "./BaseErc721Payable.sol";


contract BaseErc721Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable
{
    function u0x095ea7b3(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function u0x38ed1739(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Erc721PledgePoolBase is
Ownable
{
    uint256 public constant VERSION = 1;

    string private _name;
    string private _symbol;

    uint256 public totalPledgers;
    uint256 public totalPledgeAmount;

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

    function setName(string memory name_)
    public
    onlyOwner
    {
        _name = name_;
    }

    function setSymbol(string memory symbol_)
    public
    onlyOwner
    {
        _symbol = symbol_;
    }

    function setTotalPledgers(uint256 totalPledgers_)
    public
    onlyOwner
    {
        totalPledgers = totalPledgers_;
    }

    function setTotalPledgeAmount(uint256 totalPledgeAmount_)
    public
    onlyOwner
    {
        totalPledgeAmount = totalPledgeAmount_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


contract Erc721PledgePoolBankAddress is
Ownable,
Erc721PledgePoolBase
{
    address public bankAddress; // 质押代币储存地址

    function setBankAddress(address bankAddress_)
    public
    onlyOwner
    {
        bankAddress = bankAddress_ == address(0x0) ? address(this) : bankAddress_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


contract Erc721PledgePoolTokenSupport is
Ownable,
Erc721PledgePoolBase
{
    mapping(address => bool) private _isSupportedTokens;

    function setIsSupportedToken(address tokenAddress, bool isSupportedToken_)
    public
    onlyOwner
    {
        _isSupportedTokens[tokenAddress] = isSupportedToken_;
    }

    function isSupportedToken(address tokenAddress)
    public
    view
    returns (bool)
    {
        return _isSupportedTokens[tokenAddress];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


contract Erc721PledgePoolTokenOption is
Ownable,
Erc721PledgePoolBase
{
    struct TokenOption
    {
        string uri;
        uint256 value;
    }

    mapping(address => mapping(string => TokenOption)) internal _tokenOptions;
    mapping(address => string[]) internal _tokenOptionUris;

    function getTokenOption(address tokenAddress, string memory uri)
    public
    view
    returns (TokenOption memory)
    {
        return _tokenOptions[tokenAddress][uri];
    }

    function isExistedInTokenOptions(address tokenAddress, string memory uri)
    public
    view
    returns (bool)
    {
        uint256 length = tokenOptionsCount(tokenAddress);

        for (uint256 i = 0; i < length; i++)
        {
            string memory storedUri = _tokenOptionUris[tokenAddress][i];

            if (keccak256(abi.encodePacked(storedUri)) == keccak256(abi.encodePacked(uri))) {
                return true;
            }
        }

        return false;
    }

    function addTokenOptions(address tokenAddress, string memory uri, uint256 value)
    public
    onlyOwner
    {
        require(!isExistedInTokenOptions(tokenAddress, uri), "duplicated uri");

        _tokenOptionUris[tokenAddress].push(uri);
        _tokenOptions[tokenAddress][uri] = TokenOption({uri : uri, value : value});
    }

    function deleteTokenOptions(address tokenAddress, string memory uri)
    public
    onlyOwner
    {
        bool isDeleted = false;
        uint256 length = tokenOptionsCount(tokenAddress);

        // set current index to element of last index, then remove last element
        for (uint256 i = 0; i < length; i++) {
            string memory storedUri = _tokenOptionUris[tokenAddress][i];

            if (keccak256(abi.encodePacked(storedUri)) == keccak256(abi.encodePacked(uri))) {
                _tokenOptionUris[tokenAddress][i] = _tokenOptionUris[tokenAddress][length - 1];
                _tokenOptionUris[tokenAddress].pop();

                isDeleted = true;

                break;
            }
        }

        if (isDeleted) {
            delete _tokenOptions[tokenAddress][uri];
        }
    }

    function setTokenOption_uri(address tokenAddress, string memory uri, string memory uri_)
    public
    onlyOwner
    {
        require(isExistedInTokenOptions(tokenAddress, uri), "wrong uri");

        _tokenOptions[tokenAddress][uri].uri = uri_;
    }

    function setTokenOption_value(address tokenAddress, string memory uri, uint256 value)
    public
    onlyOwner
    {
        require(isExistedInTokenOptions(tokenAddress, uri), "wrong uri");

        _tokenOptions[tokenAddress][uri].value = value;
    }

    function tokenOptionsCount(address tokenAddress)
    public
    view
    returns (uint256)
    {
        return _tokenOptionUris[tokenAddress].length;
    }

    function getTokenOptions(address tokenAddress)
    public
    view
    returns (TokenOption[] memory)
    {
        uint256 length = tokenOptionsCount(tokenAddress);

        TokenOption[] memory tokenOptions_ = new TokenOption[](length);

        for (uint256 i = 0; i < length; i++) {
            tokenOptions_[i] = _tokenOptions[tokenAddress][_tokenOptionUris[tokenAddress][i]];
        }

        return tokenOptions_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";
import "./Erc721PledgePoolTokenOption.sol";


contract Erc721PledgePoolPledgeInfo is
Ownable,
Erc721PledgePoolBase,
Erc721PledgePoolTokenOption
{
    struct PledgeInfo
    {
        address pledger; // 质押人

        bool isPledged; // 是否在质押

        address bankAddress; // 质押代币储存地址

        uint256 tokenId; // token id

        string tokenOptionUri; // token uri
        uint256 tokenOptionValue; // token 价值 (based on uri)

        address pledgeToken; // 质押代币
        uint256 pledgePeriod; // 质押周期（秒数）
        uint256 pledgeAmount; // 质押数量
        uint256 pledgeCreateTime; // 质押时间

        address profitToken; // 收益代币（空字符串代币 BNB）
        uint256 profitRate; // 收益比率（转换为百分比）
        uint256 profitPerSecond; // 每秒收益
    }

    mapping(address => PledgeInfo[]) public pledgeInfos; // 质押人地址 => PledgeInfos

    function isTokenPledged(address pledger, address tokenAddress, uint256 tokenId)
    public
    view
    returns (bool)
    {
        uint256 length = pledgeInfos[pledger].length;

        for (uint256 i = 0; i < length; i++) {
            if (pledgeInfos[pledger][i].pledgeToken == tokenAddress && pledgeInfos[pledger][i].tokenId == tokenId) {
                return pledgeInfos[pledger][i].isPledged;
            }
        }

        return false;
    }

    function getPledgeInfo(address pledger, address tokenAddress, uint256 tokenId)
    public
    view
    returns (PledgeInfo memory)
    {
        uint256 length = pledgeInfos[pledger].length;

        for (uint256 i = 0; i < length; i++) {
            if (pledgeInfos[pledger][i].pledgeToken == tokenAddress && pledgeInfos[pledger][i].tokenId == tokenId) {
                return pledgeInfos[pledger][i];
            }
        }

        revert("wrong info");
    }

    function getPledgeInfoIndex(address pledger, address tokenAddress, uint256 tokenId)
    public
    view
    returns (uint256)
    {
        uint256 length = pledgeInfos[pledger].length;

        for (uint256 i = 0; i < length; i++) {
            if (pledgeInfos[pledger][i].pledgeToken == tokenAddress && pledgeInfos[pledger][i].tokenId == tokenId) {
                return i;
            }
        }

        revert("wrong info");
    }

    function addPledgeInfo(address pledger, PledgeInfo memory pledgeInfo)
    public
    onlyOwner
    {
        _addPledgeInfo(pledger, pledgeInfo);
    }

    function removePledgeInfo(address pledger, address tokenAddress, uint256 tokenId)
    public
    onlyOwner
    {
        _removePledgeInfo(pledger, tokenAddress, tokenId);
    }

    function setPledgeInfo(address pledger, address tokenAddress, uint256 tokenId, PledgeInfo memory pledgeInfo)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index] = pledgeInfo;
    }

    function setPledgeInfo_pledger(address pledger, address tokenAddress, uint256 tokenId, address newPledger_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].pledger = newPledger_;
    }

    function setPledgeInfo_isPledged(address pledger, address tokenAddress, uint256 tokenId, bool isPledged_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].isPledged = isPledged_;
    }

    function setPledgeInfo_bankAddress(address pledger, address tokenAddress, uint256 tokenId, address bankAddress_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].bankAddress = bankAddress_;
    }

    function setPledgeInfo_tokenId(address pledger, address tokenAddress, uint256 tokenId, uint256 newTokenId_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].tokenId = newTokenId_;
    }

    function setPledgeInfo_tokenOptionUri(
        address pledger,
        address tokenAddress,
        uint256 tokenId,
        string memory tokenOptionUri_
    )
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].tokenOptionUri = tokenOptionUri_;
    }

    function setPledgeInfo_tokenOptionValue(
        address pledger,
        address tokenAddress,
        uint256 tokenId,
        uint256 tokenOptionValue_
    )
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].tokenOptionValue = tokenOptionValue_;
    }

    function setPledgeInfo_pledgeToken(address pledger, address tokenAddress, uint256 tokenId, address pledgeToken_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].pledgeToken = pledgeToken_;
    }

    function setPledgeInfo_pledgePeriod(address pledger, address tokenAddress, uint256 tokenId, uint256 pledgePeriod_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].pledgePeriod = pledgePeriod_;
    }

    function setPledgeInfo_pledgeAmount(address pledger, address tokenAddress, uint256 tokenId, uint256 pledgeAmount_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].pledgeAmount = pledgeAmount_;
    }

    function setPledgeInfo_pledgeCreateTime(
        address pledger,
        address tokenAddress,
        uint256 tokenId,
        uint256 pledgeCreateTime_
    )
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].pledgeCreateTime = pledgeCreateTime_;
    }

    function setPledgeInfo_profitToken(address pledger, address tokenAddress, uint256 tokenId, address profitToken_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].profitToken = profitToken_;
    }

    function setPledgeInfo_profitRate(address pledger, address tokenAddress, uint256 tokenId, uint256 profitRate_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].profitRate = profitRate_;
    }

    function setPledgeInfo_profitPerSecond(address pledger, address tokenAddress, uint256 tokenId, uint256 profitPerSecond_)
    public
    onlyOwner
    {
        uint256 index = getPledgeInfoIndex(pledger, tokenAddress, tokenId);

        pledgeInfos[pledger][index].profitPerSecond = profitPerSecond_;
    }

    function getProfitAmount(address pledger, address tokenAddress, uint256 tokenId)
    public
    view
    returns (uint256)
    {
        PledgeInfo memory pledgeInfo = getPledgeInfo(pledger, tokenAddress, tokenId);

        return _getProfitAmount(pledgeInfo);
    }

    function getPledgeInfos(address pledger)
    public
    view
    returns (PledgeInfo[] memory)
    {
        return pledgeInfos[pledger];
    }

    function _addPledgeInfo(address pledger, PledgeInfo memory pledgeInfo)
    internal
    {
        pledgeInfos[pledger].push(pledgeInfo);

        totalPledgeAmount += pledgeInfo.pledgeAmount;

        if (pledgeInfos[pledger].length == 1) {
            totalPledgers += 1;
        }
    }

    function _removePledgeInfo(address pledger, address tokenAddress, uint256 tokenId)
    internal
    {
        uint256 length = pledgeInfos[pledger].length;

        for (uint256 i = 0; i < length; i++) {
            if (pledgeInfos[pledger][i].pledgeToken == tokenAddress && pledgeInfos[pledger][i].tokenId == tokenId) {
                // 设置 totalPledgeAmount 计数
                totalPledgeAmount -= pledgeInfos[pledger][i].pledgeAmount;

                // 设置 totalPledgers 计数, 如果长度为一, 则即将归零
                if (pledgeInfos[pledger].length == 1) {
                    totalPledgers -= 1;
                }

                // 末位元素保存到当前位置
                pledgeInfos[pledger][i] = pledgeInfos[pledger][length - 1];

                // 末位元素出栈
                pledgeInfos[pledger].pop();

                return;
            }
        }

        // 删除失败
        revert("cannot remove");
    }

    function _getProfitAmount(PledgeInfo memory pledgeInfo)
    internal
    pure
    returns (uint256)
    {
        return pledgeInfo.tokenOptionValue * pledgeInfo.pledgeAmount * pledgeInfo.pledgePeriod * pledgeInfo.profitPerSecond * pledgeInfo.profitRate / 100;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


contract Erc721PledgePoolPledgeOption is
Ownable,
Erc721PledgePoolBase
{
    using Counters for Counters.Counter;

    struct PledgeOption
    {
        uint256 pledgePeriod;
        uint256 profitRate;
    }

    Counters.Counter public pledgeOptionsIdCounter;
    mapping(uint256 => PledgeOption) public pledgeOptions;

    function getPledgeOption(uint256 index)
    public
    view
    returns (PledgeOption memory)
    {
        require(index < pledgeOptionsCount(), "wrong index");

        return pledgeOptions[index];
    }

    function addPledgeOption(uint256 pledgePeriod, uint256 profitRate)
    public
    onlyOwner
    {
        uint256 index = pledgeOptionsCount();

        PledgeOption memory pledgeOption = PledgeOption(pledgePeriod, profitRate);

        pledgeOptions[index] = pledgeOption;

        pledgeOptionsIdCounter.increment();
    }

    function setPledgeOption(uint256 index, PledgeOption memory pledgeOption)
    public
    onlyOwner
    {
        require(index < pledgeOptionsCount(), "wrong index");

        delete pledgeOptions[index];

        pledgeOptions[index] = pledgeOption;
    }

    function setPledgeOption_pledgePeriod(uint256 index, uint256 pledgePeriod)
    public
    onlyOwner
    {
        require(index < pledgeOptionsCount(), "wrong index");

        pledgeOptions[index].pledgePeriod = pledgePeriod;
    }

    function setPledgeOption_pledgeRate(uint256 index, uint256 profitRate)
    public
    onlyOwner
    {
        require(index < pledgeOptionsCount(), "wrong index");

        pledgeOptions[index].profitRate = profitRate;
    }

    function pledgeOptionsCount()
    public
    view
    returns (uint256)
    {
        return pledgeOptionsIdCounter.current();
    }

    function getPledgeOptions()
    public
    view
    returns (PledgeOption[] memory) {
        uint256 pledgeOptionsCount_ = pledgeOptionsCount();

        PledgeOption[] memory pledgeOptions_ = new PledgeOption[](pledgeOptionsCount_);

        for (uint256 i = 0; i < pledgeOptionsCount_; i++) {
            PledgeOption storage pledgeOption = pledgeOptions[i];
            pledgeOptions_[i] = pledgeOption;
        }

        return pledgeOptions_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


contract Erc721PledgePoolProfitInfo is
Ownable,
Erc721PledgePoolBase
{
    uint256 public profitPerSecond; // 每秒的收益
    address public profitToken; // 收益代币（ 0x0 代表使用 Ether )

    function setProfitPerSecond(uint256 profitPerSecond_)
    public
    onlyOwner
    {
        profitPerSecond = profitPerSecond_;
    }

    function setProfitToken(address profitToken_)
    public
    onlyOwner
    {
        profitToken = profitToken_;
    }

    function isUseEtherProfit()
    public
    view
    returns (bool)
    {
        return profitToken == address(0x0);
    }

    function isUseErc20Profit()
    public
    view
    returns (bool)
    {
        return profitToken != address(0x0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


abstract contract Erc721PledgePoolDoPledge is
Ownable,
Erc721PledgePoolBase
{
    bool public canDoPledge;
    bool public canBotDoPledge;
    bool public isUseMinimumDoPledgeFee;
    uint256 public minimumDoPledgeFee;

    event DoPledge(
        address indexed pledger,
        address indexed tokenAddress,
        uint256 indexed tokenId,
        uint256 pledgeAmount,
        uint256 pledgeOptionIndex,
        uint256 fee);

    function setCanDoPledge(bool canDoPledge_)
    public
    onlyOwner
    {
        canDoPledge = canDoPledge_;
    }

    function setCanBotDoPledge(bool canBotDoPledge_)
    public
    onlyOwner
    {
        canBotDoPledge = canBotDoPledge_;
    }

    function setIsUseMinimumDoPledgeFee(bool isUseMinimumDoPledgeFee_)
    public
    onlyOwner
    {
        isUseMinimumDoPledgeFee = isUseMinimumDoPledgeFee_;
    }

    function setMinimumDoPledgeFee(uint256 minimumDoPledgeFee_)
    public
    onlyOwner
    {
        minimumDoPledgeFee = minimumDoPledgeFee_;
    }

    function doPledge(
        address tokenAddress,
        uint256 tokenId,
        uint256 pledgeOptionIndex
    )
    virtual
    public
    payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


abstract contract Erc721PledgePoolDoProfit is
Ownable,
Erc721PledgePoolBase
{
    bool public canDoProfit;
    bool public canBotDoProfit;
    bool public isUseMinimumDoProfitFee;
    uint256 public minimumDoProfitFee;

    event DoProfit(
        address indexed pledger,
        address indexed pledgeToken,
        uint256 indexed tokenId,
        uint256 pledgeAmount,
        address profitToken,
        uint256 profitAmount,
        uint256 fee);

    function setCanDoProfit(bool canDoProfit_)
    public
    onlyOwner
    {
        canDoProfit = canDoProfit_;
    }


    function setCanBotDoProfit(bool canBotDoProfit_)
    public
    onlyOwner
    {
        canBotDoProfit = canBotDoProfit_;
    }

    function setIsUseMinimumDoProfitFee(bool isUseMinimumDoProfitFee_)
    public
    onlyOwner
    {
        isUseMinimumDoProfitFee = isUseMinimumDoProfitFee_;
    }

    function setMinimumDoProfitFee(uint256 minimumDoProfitFee_)
    public
    onlyOwner
    {
        minimumDoProfitFee = minimumDoProfitFee_;
    }

    function doProfit(
        address tokenAddress,
        uint256 tokenId
    )
    virtual
    public
    payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Erc721PledgePoolBase.sol";


abstract contract Erc721PledgePoolForceCancel is
Ownable,
Erc721PledgePoolBase
{
    bool public canForceCancel;
    bool public canBotForceCancel;
    bool public isUseMinimumForceCancelFee;
    uint256 public minimumForceCancelFee;

    event ForceCancel(
        address indexed pledger,
        address indexed tokenAddress,
        uint256 indexed tokenId,
        uint256 fee);

    function setCanForceCancel(bool canForceCancel_)
    public
    onlyOwner
    {
        canForceCancel = canForceCancel_;
    }

    function setCanBotForceCancel(bool canBotForceCancel_)
    public
    onlyOwner
    {
        canBotForceCancel = canBotForceCancel_;
    }

    function setIsUseMinimumForceCancelFee(bool isUseMinimumForceCancelFee_)
    public
    onlyOwner
    {
        isUseMinimumForceCancelFee = isUseMinimumForceCancelFee_;
    }

    function setMinimumForceCancelFee(uint256 minimumForceCancelFee_)
    public
    onlyOwner
    {
        minimumForceCancelFee = minimumForceCancelFee_;
    }

    function forceCancel(
        address tokenAddress,
        uint256 tokenId
    )
    virtual
    public
    payable;
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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