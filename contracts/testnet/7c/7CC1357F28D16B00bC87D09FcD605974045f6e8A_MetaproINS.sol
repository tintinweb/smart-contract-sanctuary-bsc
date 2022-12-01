//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MetaproINS is Ownable, ERC1155Holder, ReentrancyGuard {
    using SafeMath for uint256;

    struct INSConfiguration {
        // @dev: nft token id
        uint256 tokenId;
        // @dev: price per 1 nft token - value in busd
        uint256 pricePerToken;
        // @dev: INS starting block
        uint256 startBlock;
        // @dev: INS ending block
        uint256 endBlock;
        // @dev: INS min token deposits - value in NFT token
        uint256 minCap;
        // @dev: INS max token deposits - value in NFT token
        uint256 maxCap;
        // @dev: INS max token deposits - value in BUSD
        uint256 maxCapInBusd;
        // @dev: INS min token deposits - value in BUSD
        uint256 minCapInBusd;
        // @dev: Referral fee - integer value - example: 5000 -> 5%
        uint256 referralFee;
        // @dev: Allow principants to do multiple deposits per INS
        bool multipleDeposits;
        // @dev: INS creator
        address operator;
        // @dev: Current capacity in BUSD
        uint256 currentCapInBusd;
        bool valid;
        uint256 insId;
    }

    struct INSDeposit {
        // @dev: principal wallet address
        address wallet;
        // @dev: deposit amount in busd
        uint256 amount;
        // @dev: referrer address - can be 0x000....
        address referrer;
    }

    IERC1155 public token;
    IERC20 public busd;
    address public tressuryAddress;

    address private tokenAddress;

    // @dev: Current created INS
    mapping(uint256 => INSConfiguration) public availableIns;

    // @dev: Tressury fee - interger value - example: 5000 -> 5%
    uint256 public tressuryFee = 2500; // 5000 = 5%

    // @dev: dictionary with principants deposits - token_id -> deposits
    mapping(uint256 => INSDeposit[]) private deposits;

    // @dev: list of active tokenId INS
    uint256[] private createdInsIds;

    uint256[] private createdInsTokenIds;

    mapping(uint256 => bool) private alreadyCompletedIns;

    mapping(uint256 => INSConfiguration[]) private tokenIns;

    uint256 private currentInsId = 1;

    event Deposit(
        uint256 _tokenId,
        uint256 _ins_id,
        address _target,
        uint256 _amount,
        address _referrer
    );
    event Withdraw(uint256 _tokenId, address _target, uint256 _amount);
    event BUSDGiveBack(address _target, uint256 amount);
    event BUSDAddressUpdated(address _address);
    event TokenAddressUpdated(address _address);
    event TressuryAddressUpdated(address _address);
    event INSComplete(uint256 _tokenId);
    event TressuryFeeUpdated(uint256 _fee);
    event INSCreated(
        uint256 tokenId,
        uint256 minCap,
        uint256 maxCap,
        uint256 pricePerToken,
        uint256 startBlock,
        uint256 endBlock,
        bool multipleDeposits
    );

    constructor(
        address _tokenAddress,
        address _busdAddress,
        address _tressuryAddress
    ) {
        token = IERC1155(_tokenAddress);
        tokenAddress = _tokenAddress;
        busd = IERC20(_busdAddress);
        tressuryAddress = _tressuryAddress;
    }

    function create(
        uint256 tokenId,
        uint256 minCap,
        uint256 maxCap,
        uint256 pricePerToken,
        uint256 startBlock,
        uint256 endBlock,
        uint256 referralFee,
        bool multipleDeposits,
        bytes memory _data
    ) external nonReentrant {
        require(tokenId > 0, "INS: tokenId must be greater than 0");
        require(pricePerToken > 0, "INS: pricePerToken must ge greater than 0");
        require(
            referralFee <= 10000,
            "INS: referralFee must be equal or less than 10000"
        );
        require(
            token.balanceOf(msg.sender, tokenId) != 0,
            "INS: Insufficient balance"
        );

        require(
            startBlock < endBlock,
            "INS: startBlock must be less than endBlock"
        );

        token.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            maxCap,
            _data
        );

        INSConfiguration memory configuration = INSConfiguration(
            tokenId,
            pricePerToken,
            startBlock,
            endBlock,
            minCap,
            maxCap,
            maxCap * pricePerToken,
            minCap * pricePerToken,
            referralFee,
            multipleDeposits,
            msg.sender,
            0,
            true,
            currentInsId
        );
        availableIns[currentInsId] = configuration;

        createdInsIds.push(currentInsId);

        bool tokenIdAlreadyexists = false;
        for (uint256 i = 0; i < createdInsTokenIds.length; ++i) {
            if (createdInsTokenIds[i] == tokenId) {
                tokenIdAlreadyexists = true;
            }
        }

        if (!tokenIdAlreadyexists) {
            createdInsTokenIds.push(tokenId);
        }

        tokenIns[tokenId].push(configuration);

        currentInsId++;

        emit INSCreated(
            tokenId,
            minCap,
            maxCap,
            pricePerToken,
            startBlock,
            endBlock,
            multipleDeposits
        );
    }

    function deposit(
        uint256 insId,
        uint256 amount,
        address _referrer
    ) external nonReentrant {
        INSConfiguration storage configuration = availableIns[insId];
        require(configuration.valid, "INS: tokenId configuration not found");

        require(
            amount.mod(configuration.pricePerToken) == uint256(0),
            "amount can't be greater than minimal configured by INS"
        );

        if (configuration.maxCapInBusd != 0) {
            if (configuration.currentCapInBusd == configuration.maxCapInBusd) {
                revert("INS: Cap full.");
            }

            uint256 availableCap = configuration.maxCapInBusd -
                configuration.currentCapInBusd;
            if (amount > availableCap) {
                revert("INS: amount exceeds available cap.");
            }
        }

        require(block.number >= configuration.startBlock, "INS not started");
        require(block.number <= configuration.endBlock, "INS ended");

        INSDeposit memory walletDeposit = INSDeposit(
            msg.sender,
            amount,
            _referrer
        );

        if (configuration.multipleDeposits) {
            busd.transferFrom(msg.sender, address(this), amount);
            deposits[insId].push(walletDeposit);
            configuration.currentCapInBusd =
                configuration.currentCapInBusd +
                amount;
        } else {
            INSDeposit[] memory insDeposits = deposits[insId];
            bool deposited = false;
            for (uint256 i = 0; i < insDeposits.length; ++i) {
                if (insDeposits[i].wallet == msg.sender) {
                    deposited = true;
                }
            }

            if (deposited) {
                revert("INS: doesn't support multiple deposits");
            } else {
                busd.transferFrom(msg.sender, address(this), amount);
                deposits[insId].push(walletDeposit);
                configuration.currentCapInBusd =
                    configuration.currentCapInBusd +
                    amount;
            }
        }

        emit Deposit(
            configuration.tokenId,
            insId,
            msg.sender,
            amount,
            _referrer
        );
    }

    function withdraw(uint256 insId, bytes memory _data) external {
        require(
            availableIns[insId].valid,
            "INS: tokenId configuration not found"
        );
        INSConfiguration storage configuration = availableIns[insId];

        require(
            configuration.operator == msg.sender,
            "INS: You must be operator of the token"
        );

        require(block.number >= configuration.endBlock, "INS: not ended");

        require(alreadyCompletedIns[insId] != true);

        uint256 tokenTransfered = 0;

        if (configuration.minCap != 0) {
            if (configuration.currentCapInBusd < configuration.minCapInBusd) {
                for (uint256 i = 0; i < deposits[insId].length; i++) {
                    busd.transfer(
                        deposits[insId][i].wallet,
                        deposits[insId][i].amount
                    );
                    emit BUSDGiveBack(
                        deposits[insId][i].wallet,
                        deposits[insId][i].amount
                    );
                }
            } else {
                tokenTransfered = processWithdraw(
                    configuration,
                    configuration.operator,
                    deposits[insId],
                    _data
                );
            }
        } else {
            tokenTransfered = processWithdraw(
                configuration,
                configuration.operator,
                deposits[insId],
                _data
            );
        }

        uint256 tokenBalance = configuration.maxCap - tokenTransfered;
        if (tokenBalance != 0) {
            token.safeTransferFrom(
                address(this),
                configuration.operator,
                configuration.tokenId,
                tokenBalance,
                _data
            );
        }

        alreadyCompletedIns[insId] = true;
        emit INSComplete(insId);
    }

    function walletDeposits(uint256 tokenId)
        public
        view
        returns (INSDeposit[] memory)
    {
        return deposits[tokenId];
    }

    function getCreatedInsTokenIds() public view returns (uint256[] memory) {
        return createdInsTokenIds;
    }

    function getCreatedInsIds() public view returns (uint256[] memory) {
        return createdInsIds;
    }

    function getTokenIns(uint256 tokenId)
        public
        view
        returns (INSConfiguration[] memory)
    {
        return tokenIns[tokenId];
    }

    function setTokenAddress(address _newAddress) external onlyOwner {
        token = IERC1155(_newAddress);
        tokenAddress = _newAddress;
        emit TokenAddressUpdated(_newAddress);
    }

    function setTressuryFee(uint256 _fee) external onlyOwner {
        require(_fee < 2500, "INS: Fee can't be greater than 2,5%; 2500");
        tressuryFee = _fee;
        emit TressuryFeeUpdated(_fee);
    }

    function setBusdAddress(address _newAddress) external onlyOwner {
        busd = IERC20(_newAddress);
        emit BUSDAddressUpdated(_newAddress);
    }

    function setTressuryAddress(address _newAddress) external onlyOwner {
        tressuryAddress = _newAddress;
        emit TressuryAddressUpdated(_newAddress);
    }

    function processWithdraw(
        INSConfiguration storage configuration,
        address operator,
        INSDeposit[] memory insWalletDeposits,
        bytes memory _data
    ) private returns (uint256) {
        if (insWalletDeposits.length == 0) {
            return 0;
        }

        uint256 tokenTransfered = 0;

        for (uint256 i = 0; i < insWalletDeposits.length; i++) {
            uint256 fee = (insWalletDeposits[i].amount.mul(tressuryFee)).div(
                100000
            );
            uint256 depositAmount = insWalletDeposits[i].amount - fee;

            if (insWalletDeposits[i].referrer != address(0)) {
                uint256 referrerFee = (
                    insWalletDeposits[i].amount.mul(configuration.referralFee)
                ).div(100000);
                depositAmount = depositAmount - referrerFee;
                busd.transfer(insWalletDeposits[i].referrer, referrerFee);
            }

            uint256 tokenAmount = insWalletDeposits[i].amount.div(
                configuration.pricePerToken
            );

            busd.transfer(operator, depositAmount);
            busd.transfer(tressuryAddress, fee);
            token.safeTransferFrom(
                address(this),
                insWalletDeposits[i].wallet,
                configuration.tokenId,
                tokenAmount,
                _data
            );
            tokenTransfered++;
        }

        return tokenTransfered;
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
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