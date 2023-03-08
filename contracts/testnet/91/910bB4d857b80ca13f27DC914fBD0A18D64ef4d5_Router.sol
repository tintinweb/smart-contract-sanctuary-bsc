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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
interface ITokenReward {
    function getReserves() external view returns (uint256 _reserveerc, uint256 _reservenft);
    function mint(address to) external returns (uint256 liquidity) ;
    function transferFrom(address from, address to, uint256 amount ) external returns (bool);
    function burn(address to) external returns (uint amounterc, uint amountnft);
    function updateReward(uint256 amount) external;
    function getPool() external view returns (address);
    function swap(uint amountercOut, uint amountnftOut, address to, uint amountFee, address from) external;
}

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./ITokenReward.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface Factory {
    function GetTokenReward(address tokenerc, address tokennft, uint256 id) external view returns(address);
    function createTokenReward(address tokenerc, address tokennft, uint256 id) external returns (address tokenReward);
}
interface IReferral {
    function referee(address user, address _sponsor) external;
    function getSponsor(address user) external view returns(address);
    function getRef(address user) external view returns(address[] memory);
}
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}
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
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
contract Router is ERC1155Holder, Ownable {
    using SafeMath for uint;
    Factory public factory;
    address public WETH;
    address public charity;
    address public referral;
    uint public feeReferral;
    mapping(uint => bool) public fee;
    mapping(address => uint) public feeOfExchange;
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'DeMask: EXPIRED');
        _;
    }
    constructor(address _factory, address _charity, address _referral, address _WETH){
        factory = Factory(_factory);
        fee[500] = true; // 0.05%
        fee[1000] = true; // 0.1%
        fee[2000] = true; // 0.2%
        fee[5000] = true; // 0.5%
        fee[10000] = true; // 1%
        charity = _charity;
        referral = _referral;
        feeReferral = 20; // 0.2 %
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    event Buy( 
        address to,
        address sender,
        address dml,
        uint amounterc,
        uint amountnft,
        uint blockTime
    );
    event Sell(
        address to,
        address sender,
        address dml,
        uint amounterc,
        uint amountnft,
        uint blockTime
    );
    event UpdateCharity(
        address charity,
        uint blockTime
    );
    event UpdateFeeReferral(
        uint fee,
        uint blockTime
    );
    function addLiquidity(
        address tokenerc, 
        address tokennft, 
        uint256 id,
        uint _fee,
        uint amountErcDesired,
        uint amountNftDesired,
        uint amountErcMin,
        address to, 
        uint deadline
        ) external ensure(deadline) returns(uint amountErc, uint amountNft, uint liquidity) {
        // mint token reward
        (amountErc, amountNft) = _addLiquidity(tokenerc, tokennft, id, _fee, amountErcDesired, amountNftDesired, amountErcMin);
        address _token = factory.GetTokenReward(tokenerc, tokennft, id);
        IERC20(tokenerc).transferFrom(msg.sender, _token, amountErc);
        IERC1155(tokennft).safeTransferFrom(msg.sender, _token, id, amountNft, '0x0');
        liquidity = ITokenReward(_token).mint(to);
    }

    function addLiquidityNative(
        address tokennft,
        uint256 id,
        uint _fee,
        uint amountNftDesired,
        uint amountNativeMin,
        address to,
        uint deadline
    ) external payable ensure(deadline) returns(uint amountNative, uint amountNft, uint liquidity) {
        (amountNative, amountNft) = _addLiquidity(WETH, tokennft, id, _fee, msg.value, amountNftDesired, amountNativeMin);
        address _token = factory.GetTokenReward(WETH, tokennft, id);
        IERC1155(tokennft).safeTransferFrom(msg.sender, _token, id, amountNft, '0x0');
        IWETH(WETH).deposit{value: amountNative}();
        assert(IWETH(WETH).transfer(_token, amountNative));
        liquidity = ITokenReward(_token).mint(to);
        if (msg.value > amountNative) TransferHelper.safeTransferETH(msg.sender, msg.value - amountNative);
    }
    function _addLiquidity(
        address tokenerc,
        address tokennft,
        uint256 id,
        uint _fee,
        uint amountErcDesired,
        uint amountNftDesired,
        uint amountErcMin
    ) internal virtual returns (uint amountErc, uint amountNft) {
        require(fee[_fee]);
        if(factory.GetTokenReward(tokenerc, tokennft,id) == address(0)){
            address DML = factory.createTokenReward(tokenerc, tokennft, id);
            feeOfExchange[DML] = _fee;
        }
        (uint256 _reserveerc, uint256 _reservenft, ) = getReserves(tokenerc, tokennft,id);
        if(_reserveerc == 0 && _reservenft == 0){
            (amountErc, amountNft) = (amountErcDesired, amountNftDesired);
        } else {
            uint amountErcOptimal = amountNftDesired * _reserveerc / _reservenft;
            require(amountErcOptimal <= amountErcDesired && amountErcOptimal >= amountErcMin, 'DeMask: INSUFFICIENT_ERC_AMOUNT');
            (amountErc, amountNft) = (amountErcOptimal, amountNftDesired);
        }

    }

    function getReserves(
        address tokenerc,
        address tokennft,
        uint256 id
    ) internal view returns(uint256 _reserveerc, uint256 _reservenft, address _token){
        _token = factory.GetTokenReward(tokenerc, tokennft, id);
        ( _reserveerc, _reservenft) = ITokenReward(_token).getReserves();
    }

    function removeLiquidity(
        address tokenerc,
        address tokennft,
        uint256 id,
        uint liquidity,
        uint amountErcMin,
        uint amountNftMin,
        address to,
        uint deadline
    ) public ensure(deadline) returns (uint amounterc, uint amountnft){
        // burn token reward
        address _token = factory.GetTokenReward(tokenerc, tokennft, id);
        ITokenReward(_token).transferFrom(msg.sender, _token, liquidity);
        (amounterc, amountnft) = ITokenReward(_token).burn(to);
        require(amounterc >= amountErcMin, 'DeMask: INSUFFICIENT_ERC_AMOUNT');
        require(amountnft >= amountNftMin, 'DeMask: INSUFFICIENT_NFT_AMOUNT');
    }

    function removeLiquidityNative(
        address tokennft,
        uint256 id,
        uint liquidity,
        uint amountNativeMin,
        uint amountNftMin,
        address to,
        uint deadline
    ) public ensure(deadline) returns (uint amountnative, uint amountnft) {
        (amountnative, amountnft) = removeLiquidity(
            WETH,
            tokennft,
            id,
            liquidity,
            amountNativeMin,
            amountNftMin,
            address(this),
            deadline
        );
        IERC1155(tokennft).safeTransferFrom(address(this), msg.sender, id, amountnft, '0x0');
        IWETH(WETH).withdraw(amountnative);
        TransferHelper.safeTransferETH(to, amountnative);
    }
    
    function getAmountBuy(
        address tokenerc,
        address tokennft,
        uint256 id,
        uint amountNft
    ) public view returns (uint amountWithFee, uint feeBuy){
        (uint256 _reserveerc, uint256 _reservenft, address _token) = getReserves(tokenerc, tokennft,id);
        require(amountNft > 0, 'DeMask: INSUFFICIENT_OUTPUT_AMOUNT');
        require(_reserveerc > 0 && _reservenft > 0, 'DeMask: INSUFFICIENT_LIQUIDITY');
        uint numerator = _reserveerc.mul(amountNft).mul(10000);
        uint denominator = _reservenft.sub(amountNft).mul(9975);
        uint amountIn = (numerator / denominator).add(1);
        feeBuy = amountIn * feeOfExchange[_token] / 1000000;
        amountWithFee = amountIn + feeBuy;
    }

    function getAmountSell(
        address tokenerc,
        address tokennft,
        uint256 id,
        uint amountNft
    ) public view returns (uint amountWithFee, uint feeSell){
        (uint256 _reserveerc, uint256 _reservenft, address _token) = getReserves(tokenerc, tokennft,id);
        require(amountNft > 0, 'DeMask: INSUFFICIENT_INPUT_AMOUNT');
        require(_reserveerc > 0 && _reservenft > 0, 'DeMask: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountNft.mul(9975);
        uint numerator = amountInWithFee.mul(_reserveerc);
        uint denominator = _reservenft.mul(10000).add(amountInWithFee);
        uint amountOut = numerator / denominator;
        feeSell = amountOut * feeOfExchange[_token] / 1000000;
        amountWithFee = amountOut - feeSell;
    }

    function buy(
        address tokenerc,
        address tokennft,
        uint256 id,
        uint amountNft,
        uint amountInMax,
        address to,
        uint deadline,
        address _sponsor
    ) external ensure(deadline) returns(uint) {
        // update reward
        IReferral(referral).referee(msg.sender, _sponsor);
        (,, address _token) = getReserves(tokenerc, tokennft,id);
        (uint amount, uint feeBuy) = getAmountBuy(tokenerc, tokennft, id, amountNft);
        require(amount <= amountInMax, 'DeMask: EXCESSIVE_INPUT_AMOUNT');
        _safeTransafer(_token, tokenerc, amount, feeBuy);
        _updateTokenReward(0, amountNft, to, 0, msg.sender, feeBuy, _token);
        emit Buy(to, msg.sender, _token, amount, amountNft, block.timestamp);
        return amount;
    }

    function _updateTokenReward(uint amountercOut, uint amountnftOut, address to, uint amountFee, address from, uint _fee, address _token) internal {
        ITokenReward(_token).swap(amountercOut, amountnftOut, to, amountFee, from);
        ITokenReward(_token).updateReward(_fee);
    }

    function _safeTransafer(address _token, address tokenerc, uint amount, uint feeBuy) internal {
        IERC20(tokenerc).transferFrom(msg.sender, _token, amount.sub(feeBuy));
        uint amounFeeReferral = feeBuy *  feeReferral / 10000; // 1% <-> 100
        if(IReferral(referral).getSponsor(msg.sender) != address(0)){
            IERC20(tokenerc).transferFrom(msg.sender, IReferral(referral).getSponsor(msg.sender), amounFeeReferral);
        }else {
            IERC20(tokenerc).transferFrom(msg.sender, charity, amounFeeReferral);
        }
        IERC20(tokenerc).transferFrom(msg.sender, ITokenReward(_token).getPool(), feeBuy.sub(amounFeeReferral));
    }

    function sell(
        address tokenerc,
        address tokennft,
        uint256 id,
        uint amountNft,
        uint amountOutMin,
        address to,
        uint deadline,
        address _sponsor
    ) external ensure(deadline) returns(uint)  {
        // update reward
        IReferral(referral).referee(msg.sender, _sponsor);
        (,, address _token) = getReserves(tokenerc, tokennft,id);
        (uint amount, uint feeSell) = getAmountSell(tokenerc, tokennft, id, amountNft);
        require(amount >= amountOutMin, 'DeMask: INSUFFICIENT_OUTPUT_AMOUNT');
        IERC1155(tokennft).safeTransferFrom(msg.sender, _token, id, amountNft, '0x0');
        _updateTokenReward(amount, 0, to, feeSell, msg.sender, feeSell, _token);
        emit Sell(to, msg.sender, _token, amount, amountNft, block.timestamp);
        return amount;
    }

    function updateCharity(address _charity) external onlyOwner {
        require(_charity != address(0));
        charity = _charity;
        emit UpdateCharity(_charity, block.timestamp);
    }

    function getCharity() external view returns (address){
        return charity;
    }
    function updateFeeReferral(uint _fee) external onlyOwner {
        require(_fee > 0);
        feeReferral = _fee;
        emit UpdateFeeReferral(_fee, block.timestamp);
    }
    function getFeeReferral() external view returns (uint){
        return feeReferral;
    }
    function getReferral() external view returns (address){
        return referral;
    }
}